---
name: git-trace
description: >
  Look up taw-kit git history without needing to know git. Find which commit
  added a feature, changed a file, or ran during which phase. Reads the strict
  format written by `git-auto-commit` (type(scope): subject [P<n>]).
  Vietnamese trigger phrases: "xem lich su", "ai sua cai nay", "khi nao them",
  "commit nao lam hong", "tra lai phase".
argument-hint: "<scope | phase | file | feature>   vd: auth | P2 | app/login/page.tsx | tiktok-shop"
---

# git-trace — Commit History Lookup

## Purpose

Non-dev users should be able to ask "khi nào thêm trang đăng nhập?" or "commit nào làm hỏng checkout?" and get a straight answer. This skill wraps common `git log` / `git blame` queries behind a single interface and translates SHAs into plain prose in the user's input language (Vietnamese by default for VN users).

## Input modes

Detect what the user gave:

| Input shape | Example | Query |
|-------------|---------|-------|
| Scope name | `auth`, `shop`, `checkout` | `git log --grep="($scope)"` |
| Phase tag | `P2`, `P5`, `phase 3` | `git log --grep="\[P$n\]"` |
| File path | `app/login/page.tsx` | `git log --follow -- <file>` |
| Feature slug | `tiktok-shop`, `magic-link` | `git log --grep="$slug" --all-match` |
| SHA | `abc1234` | `git show --stat <sha>` |
| `who` + file | `who app/shop/page.tsx` | `git blame -L 1,40 <file>` |

If ambiguous, ask once in VN: "Tìm theo **feature** (vd: auth), **phase** (P2), hay **file** (app/...)?"

## Workflow

### 1. By scope — "mọi commit về auth"

```bash
git log --grep="(auth)" --pretty=format:"%h  %ad  %s" --date=short -20
```

Output template for user (VN, max 10 dòng):
```
Lich su thay doi auth:
abc1234  2026-01-15  feat(auth): add magic-link sign-in [P2]
def5678  2026-01-18  fix(auth): handle expired OTP link
9a0b1c2  2026-02-03  refactor(auth): extract middleware helper
```

### 2. By phase — "phase 2 làm gì"

```bash
git log --grep="\[P2\]" --pretty=format:"%h  %s" -30
```

Also read `.taw/plan.md` if it exists, echo the phase description above the commit list so the user remembers what P2 meant.

### 3. By file — "ai sửa app/login/page.tsx"

```bash
git log --follow --pretty=format:"%h  %an  %ad  %s" --date=short -- "$file"
```

For per-line authorship (only when user asks "ai viết dòng X"):
```bash
git blame -L <start>,<end> -- "$file"
```

### 4. By feature slug — "khi nào thêm TikTok shop"

Run both a subject-grep and a body-grep (user may have written it in either):
```bash
git log --grep="tiktok" -i --pretty=format:"%h  %ad  %s" --date=short
```

### 5. Reverse lookup — "commit nào làm hỏng X"

Ask user for the last known-good and last known-broken sha or date, then:
```bash
git log --oneline <good>..<broken> -- <path-or-scope>
# Offer `git bisect` only if >10 commits in range.
```

## Safety / UX rules

- Always limit output to **20 commits max** unless user asks "tất cả".
- Always translate SHAs the user will paste back (truncate to 7 chars).
- Never run `git reset`, `git checkout <sha>`, `git revert` from this skill — it is read-only. If user asks to roll back, emit: "Muốn revert commit abc1234? Type /taw revert abc1234" (future skill, not in this one).
- If `.git/` missing: "Project chua co git. Chay /taw hoac `git init` truoc."

## Output convention

Always print in simple Vietnamese with a short EN header showing the raw command used, so advanced users can re-run it:

```
$ git log --grep="(checkout)" -10

3 commit lien quan checkout:
  abc1234  2026-03-02  feat(checkout): add Polar webhook [P5]
  def5678  2026-03-04  fix(checkout): handle retry 409
  9a0b1c2  2026-03-09  chore(checkout): log webhook body in dev
```

## When to invoke

- User asks "khi nào", "ai sửa", "commit nào", "lịch sử", "thay đổi gì"
- Debugging: before `/taw-fix`, surface the last 5 commits touching the broken area
- Before `/taw-deploy`: show commits since last deploy tag (if exists)
