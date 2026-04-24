# maintain: refactor

Safe structural changes — rename a symbol, extract a component, split a file, move files between folders. Preserves behaviour. Always builds+tests before committing.

**Prereq:** router classified `tier2 = refactor`.

## Step 1 — Identify the refactor type

Parse user args:

| Pattern | Type |
|---|---|
| "rename X to Y" / "đổi tên X thành Y" | rename-symbol |
| "extract ... thành component" / "split Z.tsx" | extract-component |
| "tách file Z" / "split file" | split-file |
| "move X to Y" / "chuyển X sang Y" | move-file |
| "đổi default export" / "to named export" | export-style |
| empty / unclear | show menu |

Menu:
```
Refactor gì?
  1. đổi tên   — rename function/component/variable everywhere
  2. tách      — extract component/hook/util ra file riêng
  3. chia file — chia 1 file dài thành nhiều file
  4. di chuyển — move file sang folder khác, sửa imports
  5. named/default — đổi kiểu export
```

## Step 2 — Gather targets

For each type, required info:

- **rename**: old name, new name. Confirm they don't collide (grep for new name first).
- **extract**: source file + line range (or description), new filename.
- **split**: source file, rules ("tách mỗi component ra file riêng" / "component + hooks riêng + types riêng").
- **move**: source path, target path.
- **export-style**: target file/folder.

If user didn't give details, ask ONE concise question at a time.

## Step 3 — Tool check

For rename + move: `ast-grep` (or `sg`) is ideal. Check:
```bash
command -v sg >/dev/null 2>&1 || command -v ast-grep >/dev/null 2>&1
```

If missing, follow tool-bootstrap protocol from user's CLAUDE.md: ask ONCE to install (`brew install ast-grep`). Decline → fall back to Grep + manual Edit (slower, still works).

## Step 4 — Snapshot

```bash
git status --porcelain
```
Dirty → "Commit hoặc stash thay đổi trước." Stop.

```bash
git rev-parse HEAD > .taw/refactor-sha.txt
```

## Step 5 — Execute

### rename-symbol

With ast-grep:
```bash
# tsx/ts only
sg run -p 'identifier[name="<oldName>"]' -r '<newName>' --lang tsx --update-all
sg run -p 'identifier[name="<oldName>"]' -r '<newName>' --lang ts --update-all
```

Without ast-grep (fallback):
```bash
grep -rln '<oldName>' app/ components/ lib/ --include='*.ts' --include='*.tsx'
```
Then Edit each file, replacing `<oldName>` → `<newName>` ONLY on word boundaries (use `\b<oldName>\b` pattern or visual confirm). **Refuse to proceed if matches in strings/comments look intentional** — ask user.

### extract-component

1. Read source file, find the JSX block at specified line range
2. Identify: props used (from parent scope), state needed (hooks), styles (Tailwind classes already inline)
3. Create new file `components/<NewName>.tsx`:
   ```tsx
   type Props = { /* inferred */ }
   export function NewName({ ... }: Props) {
     /* extracted JSX */
   }
   ```
4. In source file: replace block with `<NewName {...inferredProps} />` and add `import { NewName } from '@/components/NewName'`

### split-file

1. Read source file
2. Parse top-level exports. Group by type:
   - React components → `components/<Name>.tsx`
   - Hooks (start with `use`) → `hooks/<name>.ts`
   - Types/interfaces → `<dir>/types.ts`
   - Pure functions → `<dir>/utils.ts`
3. Move each group, preserve imports. Update the original file to re-export from new locations (keep public API), OR delete original if user says so.

### move-file

With ast-grep:
```bash
mv oldPath newPath
# update all imports
sg run -p '"oldPath"' -r '"newPath"' --update-all
sg run -p "'oldPath'" -r "'newPath'" --update-all
```

Without ast-grep:
```bash
mv oldPath newPath
grep -rln 'oldPath' . --include='*.ts' --include='*.tsx'
```
Edit each match (relative path recalc — care with `..`).

### export-style

Default → named:
```bash
# find `export default function Foo` → `export function Foo`
```
Then update all `import Foo from '...'` → `import { Foo } from '...'`.

Named → default: reverse.

## Step 6 — Verify

```bash
npx tsc --noEmit 2>&1 | tail -30
npm run build 2>&1 | tail -30
npm test 2>/dev/null 2>&1 | tail -20
```

**All green** → Step 7.

**Any red** →
```
⚠️ Refactor xong nhưng {tsc/build/test} lỗi.
Chọn:
  1. show  — xem chi tiết
  2. revert — quay lại bản trước refactor
  3. keep  — giữ, em tự sửa
```

- `revert` → `git reset --hard $(cat .taw/refactor-sha.txt)` + `npm install`

## Step 7 — Commit

`taw-commit`:
```
type=refactor, scope=<inferred>, subject="<refactor type>: <from> → <to>"
```

## Step 8 — Done

```
✓ Refactor xong.
  Type: rename-symbol
  Thay đổi: 12 file, 47 lần thay
  Build + tests: xanh
```

Delete `.taw/refactor-sha.txt`.

## Constraints

- NEVER rename across string literals / comments unless user explicitly confirms
- NEVER delete source file in split-file without showing the import map first
- If tsc was ALREADY failing before refactor, note that and don't blame the refactor
- Don't touch `node_modules/`, generated files (`.next/`, `dist/`), or `*.d.ts` ambient types
- For rename affecting >50 files, show count + confirm before executing
- If project has no `tsc` / no tests, rely on `npm run build` only and warn user coverage is lower
