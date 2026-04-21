---
name: git-auto-commit
description: >
  Stage changed files and write a conventional commit so every change is traceable
  back to the taw phase, feature, or fix that produced it. Format is strict:
  `type(scope): subject [P<phase>]`. Used by taw, taw-add, taw-fix after a successful
  build. User never types git commands.
argument-hint: "[type] [scope] [subject]   (hoac bo trong de auto-generate)"
---

# git-auto-commit — Conventional Commits with Phase Tracing

## Purpose

Every commit in a taw-kit project must be traceable back to:
- the **phase** in `.taw/plan.md` (if run by taw orchestrator), OR
- the **feature** added (taw-add), OR
- the **error** fixed (taw-fix).

This skill enforces a single format so `git log --grep "(auth)"` or `git log --grep "\[P2\]"` returns the exact commits you want, years later.

## Commit Format (strict)

```
<type>(<scope>): <subject-in-simple-english>

<optional body: 1-3 bullets of what changed and why>

<optional trailer: [P<phase>] or Refs: <feature-id>>
```

- **type** — one of: `feat`, `fix`, `chore`, `refactor`, `style`, `docs`, `test`, `perf`, `build`, `revert`
- **scope** — the touched area in kebab-case: `auth`, `shop`, `checkout`, `seo`, `env`, `db`, `ui`, `deploy`, `deps`
- **subject** — imperative, lowercase, ≤ 60 chars, no trailing period
- **phase tag** — `[P<n>]` when invoked from taw (n = phase number from `.taw/plan.md`)

### Examples

```
feat(auth): add magic-link sign-in [P2]

- app/login/page.tsx: email form + Supabase signInWithOtp
- middleware.ts: protect /dashboard
- wired to SUPABASE_URL + SUPABASE_ANON_KEY

Refs: phase-2-authentication.md
```

```
fix(checkout): handle Polar webhook retry [P5]
```

```
chore(deps): bump next from 14.2.3 to 14.2.5
```

```
feat(shop): add product grid with TikTok Shop embed
Refs: feature-tiktok-shop
```

## Workflow

### 1. Derive phase / scope context

Read `.taw/checkpoint.json` if it exists:
```json
{ "phase": 2, "phase_file": "phase-2-authentication.md", "scope": "auth" }
```

Map `phase_file` → `scope` using the first noun after the phase number:
- `phase-2-authentication.md` → `auth`
- `phase-3-product-catalog.md` → `shop`
- `phase-4-checkout-polar.md` → `checkout`

If no checkpoint (ad-hoc commit), infer `scope` from the largest diff directory:
- `app/shop/**` → `shop`
- `app/api/auth/**` → `auth`
- `components/ui/**` → `ui`
- `*.env*`, `next.config.*`, `tailwind.config.*` → `env` or `build`

### 2. Pre-commit security check

```bash
git add -A
git diff --cached --name-only > /tmp/taw-staged.txt
```

Refuse to commit (reset and abort) if any of these match staged paths or content:

| Blocker | Rule |
|---------|------|
| `.env.local`, `.env.*.local` | Always unstage: `git reset HEAD <file>` |
| `*.key`, `*.pem`, `*.p12` | Always unstage |
| `node_modules/**` | Always unstage |
| Content matches `(ghp_[A-Za-z0-9]{20,}\|sk-[A-Za-z0-9]{20,}\|SUPABASE_SERVICE_ROLE_KEY=)` | Unstage offending file and warn user in VN |

Check `.gitignore` exists; create minimum if missing:
```gitignore
.env.local
.env*.local
node_modules/
.next/
out/
dist/
*.key
*.pem
.DS_Store
```

### 3. Generate subject (when caller did not supply one)

From `git diff --cached --stat`:

```
Rules:
- New file under app/<area>/page.tsx → "feat(<area>): add <area> page"
- Modified file under app/<area>/ → "fix(<area>): update <short-description>"
- Only *.env*, *.config.*, package.json changed → "chore(env): ..." or "chore(deps): ..."
- Only README.md / docs/ changed → "docs: ..."
- Only *.test.* or __tests__/** changed → "test(<scope>): ..."
```

Subject must be simple English, imperative, ≤ 60 chars. No emoji.

### 4. Commit

Use a HEREDOC to keep body formatting intact:

```bash
git commit -m "$(cat <<'EOF'
feat(auth): add magic-link sign-in [P2]

- app/login/page.tsx: email form + Supabase signInWithOtp
- middleware.ts: protect /dashboard routes

Refs: phase-2-authentication.md
EOF
)"
```

### 5. First-time setup (only if `git rev-parse` fails)

```bash
git init
git branch -M main
# Ask user for email/name only if git config returns empty:
#   git config user.email
#   git config user.name
```

Do **not** override existing git config.

## Type Reference

| Type | When to use |
|------|-------------|
| `feat` | New user-visible feature or page |
| `fix` | Bug in existing feature |
| `chore` | Config, env, deps, non-code housekeeping |
| `refactor` | Code restructure, no behavior change |
| `style` | CSS / Tailwind / formatting only |
| `docs` | README, comments, `.taw/*.md` |
| `test` | Adding or updating tests |
| `perf` | Performance improvement |
| `build` | Build system, bundler, CI |
| `revert` | Revert a previous commit (append `Reverts: <sha>`) |

## Safety Rules

- Never `git commit --no-verify` unless user explicitly asks.
- Never `git commit --amend` on a commit that's already pushed.
- Never force-push from this skill. Force-push lives in user hands only.
- If `git status` shows merge conflict markers, abort and tell user in VN: "Đang có conflict, sửa xong rồi /taw tiếp."

## Output to user

After a successful commit, print a one-liner (EN, simple):

```
Committed: feat(auth): add magic-link sign-in [P2] — abc1234
```

That's it. No long summary — the log speaks for itself.
