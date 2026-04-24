# maintain: upgrade

Bump dependencies safely — check breaking changes, run tests, offer rollback if anything breaks. Target is either a specific package, all deps, or the framework (Next/React) as a major upgrade.

**Prereq:** router classified `tier2 = upgrade`.

## Step 1 — Detect scope

Parse user args:

| Pattern | Scope |
|---|---|
| `next@15` / "next lên 15" | major-framework upgrade → `next` |
| `all` / "hết" / "tất cả" | all deps to latest minor |
| `<pkg-name>` | single package to latest |
| empty | show menu, ask |

Menu if empty:
```
Nâng cấp gì?
  1. patch — chỉ fix bugs, an toàn (npm update)
  2. minor — tính năng mới, vẫn tương thích
  3. major — phiên bản lớn (có thể breaking) — next, react, supabase
  4. một package cụ thể — gõ tên
```

## Step 2 — Snapshot current state

Before any change:
```bash
git status --porcelain
```

If dirty → "Anh đang có thay đổi chưa commit. Commit hoặc stash trước rồi mới upgrade?" Stop unless user confirms.

Record current versions:
```bash
npm ls --json --depth=0 > .taw/upgrade-snapshot.json
git rev-parse HEAD > .taw/upgrade-sha.txt
```

## Step 3 — Check breaking changes

For each package being bumped:
1. Read current version from `package.json`
2. Fetch target: `npm view <pkg> version` (for `latest`) or use user-specified
3. If major bump (X.Y.Z → (X+1).0.0), fetch release notes:
   ```bash
   npm view <pkg> repository.url
   ```
   Then try `gh release list -R <repo> --limit 5` if gh available, else `npm view <pkg> versions --json | tail -20`.
4. For top 5 major libs (next, react, @supabase/supabase-js, typescript, tailwindcss), load skill `docs-seeker` with query "breaking changes <pkg> <old>-><new>".

Show summary to user (VN):
```
Tóm tắt thay đổi:
  next:  14.2.3 → 15.0.1   (MAJOR — có breaking)
    • async cookies() API — cần thêm await
    • fetch caching default changed
  react: 18.3.1 → 19.0.0   (MAJOR)
    • use() hook cho Promise
  @supabase/supabase-js: 2.39.1 → 2.45.0  (minor, safe)

Tiếp tục? (y/n)
```

Wait for `y` before any install.

## Step 4 — Apply upgrade

```bash
# single pkg
npm install <pkg>@<version>

# all latest minor
npx npm-check-updates --target minor -u && npm install

# all latest major (user confirmed)
npx npm-check-updates -u && npm install
```

Emit progress: "Đang cài... (1-2 phút)"

## Step 5 — Codemods for known majors

Run automated migrations when available:
```bash
# Next.js major
npx @next/codemod@latest

# React major
npx codemod@latest react/19/migration-recipe
```

Apply and stage changes.

## Step 6 — Verify

Run in sequence, stop on first failure:
```bash
npm run build
npm test 2>/dev/null || echo "(no tests)"
npm run lint 2>/dev/null || echo "(no lint)"
npx tsc --noEmit 2>/dev/null || echo "(no tsc)"
```

## Step 7 — Decision

**All green:**
```
✓ Upgrade xong.
  next: 14.2.3 → 15.0.1
  react: 18.3.1 → 19.0.0
  +5 package khác

Build xanh, tests pass.
```

Then `taw-commit`: `type=chore, scope=deps, subject="upgrade {main pkg} to vX"`

**Anything red:**
```
⚠️ Upgrade xong nhưng {build/test/type} lỗi.
Chọn:
  1. keep  — giữ version mới, fix thủ công (gõ /taw fix)
  2. revert — quay lại bản cũ (safe, không mất gì)
  3. show  — xem chi tiết lỗi trước khi quyết
```

- `revert` → 
  ```bash
  git reset --hard $(cat .taw/upgrade-sha.txt)
  npm install
  ```
  Emit "Đã quay lại bản trước upgrade."
- `keep` → write `.taw/checkpoint.json`: `{"status":"upgrade-partial","need_fix":true}`. Done.
- `show` → echo error summary, then re-ask.

## Step 8 — Clean up

If committed successfully:
```bash
rm -f .taw/upgrade-snapshot.json .taw/upgrade-sha.txt
```

## Constraints

- NEVER auto-commit if any check is red
- NEVER bump major without showing breaking changes summary first
- Always snapshot git SHA before install — revert path must stay safe
- Peer dep conflicts (`ERESOLVE`) → show conflict, ask user: "Thử --legacy-peer-deps?" do NOT use it silently
- If `npm-check-updates` not installed, `npx` will fetch it — no need to pre-install
