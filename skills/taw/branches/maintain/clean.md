# maintain: clean

Remove dead code, unused dependencies, unused exports, stale imports. Report-first, destructive-on-approval only.

**Prereq:** router classified `tier2 = clean`.

## Step 1 — Scope

Ask (if not given):
```
Dọn gì?
  1. deps    — package không dùng trong package.json
  2. exports — hàm/component export nhưng không ai import
  3. files   — file orphan (không có import nào trỏ tới)
  4. imports — import không dùng trong file
  5. tất cả  — cả 4 loại trên
```

Default (empty): run all 4 in report mode.

## Step 2 — Tool bootstrap

Needed tools: `knip` (dead exports + files + deps), `depcheck` (fallback for deps only). Check:
```bash
command -v npx >/dev/null && npx knip --version >/dev/null 2>&1
```

If knip not reachable, install on-demand: `npx knip@latest` (fetches on first run). Respect user's tool-bootstrap protocol — ask before `npm install -D knip` if they want it permanent.

## Step 3 — Scan (dry-run, report only)

Run based on scope:

**deps:**
```bash
npx knip --reporter compact --include dependencies 2>&1
# or fallback
npx depcheck --json 2>&1
```

**exports:**
```bash
npx knip --reporter compact --include exports
```

**files:**
```bash
npx knip --reporter compact --include files
```

**imports (unused in file):**
```bash
# fast heuristic — eslint with no-unused-vars + unused-imports plugin
npx eslint . --rule '{"@typescript-eslint/no-unused-vars":"error","unused-imports/no-unused-imports":"error"}' --quiet 2>&1
```

## Step 4 — Render report (VN)

```
## Dọn code — báo cáo

**Dependencies không dùng** (4):
  - lodash          (import 0 lần, có thể xoá)
  - moment          (có date-fns rồi — dùng date-fns thay)
  - @types/jest     (project dùng vitest)
  - unused-pkg-x

**Exports không ai dùng** (12):
  - lib/utils.ts:45  `export function oldHelper()` — orphan
  - components/Card.tsx:12  `export type LegacyCardProps` — orphan
  ... (+10 nữa — gõ "xem hết" để hiện)

**File orphan** (2):
  - lib/old-auth.ts  (không có file nào import)
  - components/DeprecatedModal.tsx

**Imports không dùng**: 23 lỗi trong 18 file.

---

**Hành động:**
  1. dọn hết   — xoá tất cả (sẽ review trước khi commit)
  2. chỉ deps  — chỉ xoá dependencies thừa
  3. chỉ imports — chỉ fix imports trong file (an toàn nhất)
  4. chọn tay  — em đọc từng mục, anh gật/lắc
  5. huỷ       — không làm gì
```

## Step 5 — Apply (on approval)

**deps:**
```bash
npm uninstall <pkg1> <pkg2> ...
```
Then `npm install` to regen lockfile.

**exports + files:** for each item, `git rm <file>` or Edit to remove the export. Run `npm run build` after each batch of 5 files to catch missed imports.

**imports:**
```bash
npx eslint . --fix --rule '{"unused-imports/no-unused-imports":"error"}'
```

## Step 6 — Verify

```bash
npm run build && (npm test 2>/dev/null || true) && npx tsc --noEmit 2>/dev/null || true
```

Any red → revert the last batch:
```bash
git restore --staged . && git checkout .
```
Emit: "Phát hiện dọn nhầm. Đã revert. Thử lại với scope hẹp hơn."

All green → `taw-commit`:
```
type=chore, scope=cleanup, subject="remove {N} unused exports + {M} deps"
```

## Step 7 — Done

```
✓ Dọn xong.
  -4 dependencies     (-2.3 MB node_modules)
  -12 exports thừa
  -2 file orphan
  -23 imports không dùng

Build vẫn xanh. Tests pass.
```

## Constraints

- ALWAYS dry-run first, show report, wait for approval — NEVER auto-delete
- Skip `node_modules/`, `.next/`, `dist/`, `build/`, `.git/`
- Don't touch test files when dropping "unused exports" — test files import dynamically
- Don't touch `*.d.ts` ambient files (types can look unused but aren't)
- If the project has no build script, skip Step 6 verify and warn user: "Không có `npm run build` — không chắc clean có an toàn không. Ngừng và hỏi?"
- Preserve files listed in `knip.json` or `.knipignore` if present
