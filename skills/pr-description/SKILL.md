---
name: pr-description
description: >
  Generate high-signal pull request descriptions from the actual branch diff.
  Reads commits + file diff + existing .github/PULL_REQUEST_TEMPLATE.md (if any)
  + linked issues, then writes Summary, Changes, Test Plan, and Screenshots
  placeholder. Pairs with gh CLI to open the PR. Adapts to project's template
  when one exists.
  Trigger phrases (EN + VN): "pr description", "open pr", "mo pr", "viet pr",
  "pr body", "pr template", "create pull request", "gen pr text".
allowed-tools: Read, Bash, Grep
---

# pr-description — Write the PR Body for Them

## Step 0 — Detect template + base branch

```bash
# existing template?
cat .github/PULL_REQUEST_TEMPLATE.md 2>/dev/null || \
  cat .github/pull_request_template.md 2>/dev/null || \
  cat docs/PULL_REQUEST_TEMPLATE.md 2>/dev/null

# what branch did we diverge from?
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@.*/@@' || echo main

# current branch
git branch --show-current
```

If template exists → fill its sections. If not → use the default template below (matches common taw-kit convention).

## Step 1 — Gather branch context

```bash
BASE=${BASE:-main}
HEAD=$(git branch --show-current)

# commits on this branch
git log $BASE..HEAD --pretty=format:'- %s (%h)'

# file stats
git diff $BASE...HEAD --stat

# actual diff
git diff $BASE...HEAD
```

Collect:
- Number of commits
- Files changed, insertions, deletions
- Touched areas (top-level folders)
- Any linked issue in commits (look for `#123`, `Closes #X`, `Fixes #Y`)

## Step 2 — Extract issue links

Scan commit messages + branch name for issue references:
```bash
git log $BASE..HEAD --pretty=%B | command grep -oE '#[0-9]+|[Cc]loses #[0-9]+|[Ff]ixes #[0-9]+' | sort -u
echo "$HEAD" | command grep -oE '[0-9]+' | head -1   # e.g. feat/234-checkout → 234
```

If found, use in the body. Ask user if unsure which is primary.

## Step 3 — Classify PR purpose (for title)

Use same logic as `commit-message-smart` Step 2 — scan diff to identify primary type. Title mirrors conventional commit style:

```
feat(checkout): add Stripe Checkout for one-time purchase
fix(auth): reject expired magic links before session create
refactor(cart): extract calcTotal + add tests
chore(deps): upgrade next 14 → 15
```

Title MUST be ≤72 chars. If PR has multiple disparate changes, suggest splitting — but if user insists, use umbrella scope.

## Step 4 — Fill the template

### Default taw-kit template (when none exists)

```markdown
## Summary

<1-3 bullets — WHAT and WHY, not a commit dump>
- <outcome 1>
- <outcome 2>

<Optional: 1-paragraph context if non-obvious — why this approach over alternative>

## Changes

<Grouped by area, not by commit. Don't list files.>
- **<area>** — <what changed there, in plain terms>
- **<area>** — <...>

## Test Plan

<Checklist the reviewer can run locally>
- [ ] <step 1 — usually run dev server, navigate to /route>
- [ ] <step 2 — golden-path action>
- [ ] <step 3 — edge case or failure mode>
- [ ] Run `npm test` — all pass
- [ ] Run `npm run build` — succeeds

## Screenshots / Recording

<For UI changes. Placeholder — user drops image.>
<!-- drag image here, or `gh pr comment` with video link -->

## Related

Closes #<N>  |  Refs: <link>
```

### When template exists

Read each `##` section heading. For each, auto-fill what you can:
- `## Summary` / `## What` → 1-3 outcome bullets
- `## Why` → 1 sentence on motivation (from commit messages + linked issue)
- `## How` / `## Changes` → grouped by area, not files
- `## Test Plan` / `## Testing` → checklist, skip if project has E2E coverage autoplugin
- `## Screenshots` → placeholder
- `## Checklist` (typical: linted, typed, tested) → tick boxes that map to CI job status

Leave sections you can't fill confidently as empty with a `<!-- todo: fill -->` marker so user knows to edit.

## Step 5 — Render for user review

Show the full body in VN-friendly prompt:
```
PR description đã gen — review trước khi mở PR:

────────────────────────────────────────
Title: <title>
────────────────────────────────────────

<BODY>

────────────────────────────────────────

Gõ:
  open       → mở PR ngay (gh pr create)
  edit       → em mở editor để anh sửa tay
  shorter    → em rút gọn lại
  longer     → em thêm context
  cancel     → huỷ
```

## Step 6 — Open the PR

### With `gh` CLI (preferred)
```bash
gh pr create \
  --base "$BASE" \
  --title "<title>" \
  --body-file .taw/pr-body.md \
  --web   # opens browser to edit before submit — safer
```

For immediate submit (no browser):
```bash
gh pr create --base "$BASE" --title "<title>" --body-file .taw/pr-body.md
```

### Without `gh` (fallback)
Emit URL user pastes in browser:
```
Tạo PR tại link này, paste title/body từ .taw/pr-body.md:
https://github.com/<owner>/<repo>/compare/<base>...<head>?expand=1
```

## Step 7 — Post-create

```
PR đã mở: https://github.com/<owner>/<repo>/pull/<N>

Suggested:
  - chờ CI xanh (sẽ notify)
  - assign reviewer: gh pr edit <N> --add-reviewer <user>
  - add labels: gh pr edit <N> --add-label <label>
```

Clean up `.taw/pr-body.md` after 24h OR on next PR.

## Gotchas

- **Diff quá lớn (>50 files, >1000 lines)** → PR quá to. Soft-warn: "PR này lớn — reviewer sẽ mệt. Chia nhỏ bằng `/taw review` rồi push từng phần?"
- **Branch name khác với commit intent** — dùng commit msg, không dùng branch name
- **Đã có PR cho branch này** — `gh pr status` check trước. Nếu có → offer `gh pr edit --body-file ...` thay vì tạo mới
- **"Changes" section thành commit log copy** — tệ. Group by AREA (component/module), không liệt kê commit-by-commit
- **Sensitive info trong diff** — scan for `.env`, token patterns, PII before posting. Block if found.

## Constraints

- Title: ≤72 chars, conventional commit style
- Body: reader-friendly, imperative mood, NOT a commit log paste
- Test Plan: actionable checklist reviewer can copy-run
- Always offer `--web` flag first — lets user double-check before submit
- Respect existing template — don't rewrite project's PR format
- Never submit PR without user explicit `open` confirmation
- If `gh` CLI not installed, fall back to URL — don't error out
