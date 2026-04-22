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

**Step 2a — Sanity unstage (run BEFORE checks below):** auto-unstage any staged files matching the local-state directories below — these are NEVER meant for git, regardless of whether `.gitignore` is up to date:

```bash
for pat in '.claude/' '.claudebk/' '.taw/' '.expo/' '.expo-shared/' '.eas/' '.DS_Store' 'Thumbs.db' '*.log' '*.tsbuildinfo' 'node_modules/' '.next/' 'dist/' 'build/' 'ios/build/' 'android/build/' 'android/.gradle/' 'android/app/build/'; do
  files=$(git diff --cached --name-only | grep -E "^${pat}" || true)
  if [ -n "$files" ]; then
    git reset HEAD -- $files >/dev/null 2>&1
    echo "↩ unstaged $pat (local-state, never commit)"
  fi
done
git diff --cached --name-only > /tmp/taw-staged.txt  # refresh after unstage
```

If after sanity unstage there are 0 staged files left, abort with: "Không có file nào đáng commit (toàn local state). Bỏ qua." — exit 0, do NOT make empty commit.

Refuse to commit (reset and abort) if any of these match staged paths or content.

**Filename blockers** (always unstage with `git reset HEAD <file>`):

| Pattern | What it is |
|---------|------------|
| `.env`, `.env.local`, `.env.*.local` | Env vars with secrets |
| `*.key`, `*.pem`, `*.p12`, `*.pfx` | Private keys (PEM/PKCS#12 — RFC 7468) |
| `id_rsa`, `id_ed25519`, `id_ecdsa` | SSH private keys |
| `credentials.json`, `service-account*.json` | Cloud IAM credentials |
| `node_modules/**`, `.next/**`, `dist/**`, `out/**`, `build/**`, `.expo/**`, `ios/build/**`, `android/build/**` | Build artefacts (web + mobile) |
| `.claude/**`, `.claudebk/**` | **Claude Code local state** — session transcripts, hooks, MCP config. Local-only, NEVER commit. |
| `.taw/**` | **taw-kit local state** — intent.json, checkpoint.json, deploy-target.txt. Local-only, NEVER commit. |
| `.DS_Store`, `Thumbs.db` | OS metadata cruft |
| `*.log`, `*.tsbuildinfo` | Generated logs / TS build cache |
| `.eas/`, `.expo-shared/` | EAS / Expo local cache (mobile) |

**Content blockers** — run on the staged diff:

```bash
git diff --cached | grep -InE "$CONTENT_PATTERN"
```

where `$CONTENT_PATTERN` is built from well-known public token formats:

| Source | Pattern |
|--------|---------|
| AWS access key ID (AWS docs) | `AKIA[0-9A-Z]{16}` |
| AWS secret key assignment | `aws_secret_access_key[[:space:]]*=[[:space:]]*[A-Za-z0-9/+=]{40}` |
| GitHub PAT / OAuth (gh docs) | `(ghp\|gho\|ghu\|ghs\|ghr)_[A-Za-z0-9]{20,}` |
| OpenAI / Anthropic-style | `sk-[A-Za-z0-9]{20,}` |
| Google API key | `AIza[0-9A-Za-z\-_]{35}` |
| Slack token | `xox[abpr]-[0-9A-Za-z-]{10,}` |
| Stripe live key | `sk_live_[0-9A-Za-z]{24,}` |
| JWT (RFC 7519 shape) | `eyJ[A-Za-z0-9_=-]{10,}\.eyJ[A-Za-z0-9_=-]{10,}\.[A-Za-z0-9_=\-]+` |
| PEM private key header (RFC 7468) | `-----BEGIN (RSA\|EC\|OPENSSH\|PGP\|DSA)? ?PRIVATE KEY-----` |
| DB URL with inline password | `(mongodb\|postgres\|postgresql\|mysql\|redis)://[^:]+:[^@]+@` |
| Supabase service-role assignment | `SUPABASE_SERVICE_ROLE_KEY[[:space:]]*=[[:space:]]*[A-Za-z0-9._-]+` |
| Generic `password = "..."` | `(password\|passwd\|pwd)[[:space:]]*=[[:space:]]*['\"][^'\"]{6,}['\"]` |

On hit:
1. Print which file + line matched (not the value).
2. Unstage the file: `git reset HEAD <file>`.
3. Tell user in VN: "File `<path>` có lộ secret ở dòng <n>. Đã unstage. Di chuyển giá trị vào `.env.local` trước khi commit."

Check `.gitignore` exists; create minimum if missing (or APPEND missing entries if file exists but lacks them):

```gitignore
# Env / secrets
.env
.env.local
.env*.local
*.key
*.pem
*.p12
credentials.json
service-account*.json

# Web build artefacts
node_modules/
.next/
out/
dist/
build/
*.tsbuildinfo

# Mobile build artefacts (Expo / RN)
.expo/
.expo-shared/
ios/build/
android/build/
android/.gradle/
android/app/build/
.eas/

# Local state — NEVER commit
.claude/
.claudebk/
.taw/

# OS / IDE cruft
.DS_Store
Thumbs.db
*.log
.idea/
.vscode/
```

**Append-only rule:** if `.gitignore` already exists, do NOT overwrite it. Read it, identify which patterns from the list above are missing, append only those (with a `# Added by taw-kit` separator comment).

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
