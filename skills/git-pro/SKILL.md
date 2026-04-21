---
name: git-pro
description: >
  Advanced git workflows for taw-kit users who have graduated beyond
  /taw auto-commit: create branches, open pull requests via `gh`, merge,
  and recover from common mistakes. Complements `git-auto-commit` (single
  commits) and `git-trace` (history lookup). Simple English UI; Vietnamese
  triggers. Based on public specs (conventionalcommits.org, gh CLI docs).
argument-hint: "branch <name> | pr [base] | merge [from] | undo"
---

# git-pro — Branch, PR, Merge, Recover

## When to invoke

User says any of:
- "tao branch moi" / "new branch"
- "mo PR" / "create pull request" / "push len github"
- "merge branch vao main"
- "huy commit" / "revert" / "undo last commit"

For single-commit staging, delegate to `git-auto-commit` instead.
For lookups ("khi nao them X", "ai sua Y"), delegate to `git-trace`.

## Sub-commands

### 1. `branch <name>` — Create & switch

Branch names use kebab-case with a type prefix that matches the conventional commit types used by `git-auto-commit`:

| Prefix | For |
|--------|-----|
| `feature/` | new user-visible feature |
| `fix/` | bug fix |
| `refactor/` | restructure, no behavior change |
| `chore/` | deps, config, env |
| `hotfix/` | urgent production fix |
| `experiment/` | throwaway spike |

Workflow:
```bash
# 1. Sync main first so the new branch starts from latest
git fetch origin
git switch main
git pull --ff-only origin main

# 2. Create + switch
git switch -c feature/<name>
```

If `main` is dirty (uncommitted work), stop and tell user: "Branch main đang có thay đổi chưa commit. Lưu trước rồi mới tạo branch."

### 2. `pr [base]` — Open pull request

Default base is `main`. Use `gh` CLI, always compare **remote** refs (not local) so unpushed commits are visible on GitHub.

Preflight:
```bash
# Must have gh and must be authenticated
command -v gh >/dev/null || { echo "gh CLI not installed. brew install gh"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "gh not logged in. Run: gh auth login"; exit 1; }

# Must have a remote
git remote get-url origin >/dev/null 2>&1 || { echo "No origin remote."; exit 1; }
```

Push current branch if not already on remote:
```bash
HEAD_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
[ "$HEAD_BRANCH" = "main" ] && { echo "Không mở PR từ main."; exit 1; }
git push -u origin "$HEAD_BRANCH"
```

Read remote diff to build title + body:
```bash
BASE="${1:-main}"
git fetch origin "$BASE"
git log "origin/$BASE..origin/$HEAD_BRANCH" --pretty="- %s" > /tmp/taw-pr-commits.txt
git diff "origin/$BASE...origin/$HEAD_BRANCH" --stat > /tmp/taw-pr-stat.txt
```

**PR title** — reuse the most significant commit subject (feat > fix > refactor > chore). Strip trailing `[P<n>]` tags. Max 72 chars.

**PR body template** (HEREDOC to preserve formatting):
```bash
gh pr create --base "$BASE" --head "$HEAD_BRANCH" \
  --title "$TITLE" \
  --body "$(cat <<EOF
## Summary
$(cat /tmp/taw-pr-commits.txt)

## Files changed
\`\`\`
$(cat /tmp/taw-pr-stat.txt)
\`\`\`

## Test plan
- [ ] Run \`npm run build\` locally — build passes
- [ ] Smoke-test the changed pages in dev server
- [ ] Verify no env vars missing in Vercel preview
EOF
)"
```

Output URL to user so they can click through.

### 3. `merge [from]` — Fast-forward merge into main

Only fast-forward merges from this skill. Non-fast-forward requires manual review.

```bash
FROM="${1:-$(git rev-parse --abbrev-ref HEAD)}"
git switch main
git pull --ff-only origin main
git merge --ff-only "$FROM" || {
  echo "Merge không phải fast-forward. Rebase branch '$FROM' lên main trước, hoặc merge thủ công."
  exit 1
}
git push origin main
```

Offer to delete the merged branch after successful push:
```
Merged $FROM into main. Xoá branch '$FROM'? (y/N)
```

On yes:
```bash
git branch -d "$FROM"
git push origin --delete "$FROM"
```

### 4. `undo` — Recover from last commit

Interactive. Ask user which scenario:

| Scenario | Command | Effect |
|----------|---------|--------|
| Đổi ý, muốn sửa message | `git commit --amend` | Rewrites last commit message |
| Muốn bỏ commit, giữ file đã edit | `git reset --soft HEAD~1` | Changes back in staging |
| Muốn bỏ commit + unstage | `git reset HEAD~1` | Changes back in working tree |
| Muốn xoá hẳn (NGUY HIỂM) | `git reset --hard HEAD~1` | **All work gone** — confirm twice |

Refuse `--hard` if the commit touched > 10 files or > 200 lines unless user types the exact SHA.

Refuse any amend/reset if the commit is already pushed to a protected branch (`main`, `master`, `production`). Instead suggest `git revert <sha>` (creates a new inverse commit — safe for shared history).

## Safety rules

- Never `git push --force` to `main`, `master`, or `production`. Push-force only allowed to feature branches the user owns, and only after explicit confirmation.
- Never run `git clean -fd` from this skill (can delete untracked work).
- Never run `gh pr merge --admin` (bypasses branch protection).
- Before any destructive op, print: "Sẽ chạy: <command>. Commit SHA hiện tại: <sha>. Xác nhận? (y/N)"
- If `git status` shows unmerged paths, refuse and tell user to resolve conflicts first.

## References (public specs — not copied, just cited)

- Conventional Commits: https://www.conventionalcommits.org/en/v1.0.0/
- GitHub CLI manual: https://cli.github.com/manual/
- Pro Git book (free): https://git-scm.com/book

## Output style

Short, simple English. Always show the raw git command being run so power users can learn. Never emoji.
