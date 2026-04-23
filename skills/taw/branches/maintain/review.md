# maintain: review

Local pre-push review. Runs lint + typecheck + test + security quick-scan, shows a unified report before pushing. Zero-cloud fallback for users without ultrareview.

**Prereq:** router classified `tier2 = review`.

## Step 1 — What's being reviewed

Check git state:
```bash
git branch --show-current
git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null || git log -5 --oneline
```

If on `main`/`master` and no unpushed commits: "Không thấy gì để review. Anh đang muốn review gì cụ thể?"

Otherwise, collect diff:
```bash
# changes since branch diverged from main
git diff main...HEAD --stat
git diff main...HEAD --name-only
```

Render preview (VN):
```
Review scope:
  Branch: feat/checkout
  Commits mới: 7
  File thay đổi: 14
  Lines: +342 / -89
```

## Step 2 — Run all checks in parallel (fast path)

Issue all checks at once, collect results:

```bash
# parallel execution — all must complete
(npx tsc --noEmit 2>&1 | tee .taw/review-tsc.log) &
(npm run lint 2>&1 | tee .taw/review-lint.log) &
(npm test 2>&1 | tee .taw/review-test.log) &
(npm run build 2>&1 | tee .taw/review-build.log) &
wait
```

Track exit codes of each.

## Step 3 — Security quick-scan

Load `@branches/maintain/security.md` in `quick` mode (P0 only, <30s). Collect P0 findings.

## Step 4 — Diff review (heuristic)

For each changed file in Step 1, check:

| Smell | How |
|---|---|
| `console.log` left in | `git diff main...HEAD` grep `+.*console\.log` |
| `TODO:` or `FIXME:` added | grep `+.*\b(TODO\|FIXME)\b` |
| Disabled tests | grep `+.*\b(\.skip\|\.only\|xdescribe\|xit)\b` |
| Committed credentials | grep pattern from security P0-1 in diff |
| Unused imports | (already caught by lint) |
| New `any` types | grep `+.*:\s*any\b` |

## Step 5 — Render unified report (VN)

```
## Review — pre-push

**Tổng quát:** branch feat/checkout · 7 commits · 14 file

| Check         | Kết quả |
|---------------|---------|
| TypeScript    | ✓ 0 lỗi |
| Lint          | ⚠️ 3 warnings |
| Tests         | ✓ 24/24 pass |
| Build         | ✓ xanh |
| Security (P0) | ✓ 0 findings |
| Code smells   | ⚠️ 2 findings |

---

### ⚠️ Lint (3)
  - app/checkout/page.tsx:45  no-unused-vars: `oldFn`
  - components/Cart.tsx:12     react-hooks/exhaustive-deps
  - lib/format.ts:8            prefer-const

### ⚠️ Code smells (2)
  - app/checkout/page.tsx:+78  `console.log('order', order)` — xoá trước khi merge
  - lib/api.ts:+23             thêm type `any`

---

**Quyết định:**
  - ✓ có thể push (không có P0 block)
  - gõ `fix` — em auto-fix lint + xoá console.log
  - gõ `push` — push lên remote luôn
  - gõ `detail` — xem chi tiết 1 check
```

If ANY check is a hard fail (tsc error / test fail / build fail / P0 security):
```
🚨 Không nên push — còn {N} vấn đề nghiêm trọng.
  Gõ `fix` để em thử fix auto, hoặc `/taw fix` cho lỗi build.
```

## Step 6 — Actions

### `fix`

Auto-fixable:
- Lint → `npm run lint -- --fix`
- `console.log` → Edit file to remove line
- Security auto-fixable (P0-3, P0-6, P1-3) → delegate to `@branches/maintain/security.md` fix mode

NOT auto-fixable (report only):
- tsc errors (need real thinking — delegate to `/taw fix`)
- Test failures (could be real bugs)
- `any` types (need context)

After fix, re-run failed checks only.

### `push`

Guard check:
```bash
# refuse to push if build red or tests failing
```

```bash
git push -u origin $(git branch --show-current) 2>&1
```

If `--force` mentioned anywhere in user input: refuse unless branch is NOT `main/master` AND explicit "force push" confirmation.

### `detail`

Ask which check to expand. Show full log from `.taw/review-*.log`.

## Step 7 — Cleanup

```bash
rm -f .taw/review-*.log
```

## Constraints

- NEVER push if build red or tests red — block hard
- NEVER force-push `main`/`master` — refuse outright
- Don't run long tools (ultrareview) — this is the local fast path, under 2 minutes
- Parallel execution is important — running 4 checks serial takes 4× longer
- If any tool missing (tsc, lint, test script), skip that check gracefully with "ℹ️ skipped — no config"
- Keep report under 60 lines — expand via `detail` on demand
