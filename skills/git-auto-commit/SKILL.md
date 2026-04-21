---
name: git-auto-commit
description: >
  Wrap git add + commit with meaningful conventional commit messages. Used by
  taw and taw-add after successful builds. Ensures clean git history without
  requiring user to know git commands.
argument-hint: "[commit-message hoac 'tu dong']"
---

# git-auto-commit — Automated Git Commits

## Purpose

Stage changed files and commit with a well-formed conventional commit message.
Called internally after each successful feature implementation or fix.
User never needs to type git commands.

## Workflow

### 1. Stage Changed Files

```bash
# Stage all tracked changes (never includes .env.local — it's in .gitignore)
git add -A
```

Before staging, verify no secrets leak:
```bash
git diff --cached --name-only | xargs grep -lE "(ghp_|sk-[a-zA-Z]|SUPABASE_SERVICE_KEY)" 2>/dev/null
# If any match: unstage that file with `git reset HEAD <file>`
```

### 2. Commit with Conventional Message

```bash
git commit -m "feat: them trang san pham voi gio hang"
git commit -m "fix: sua loi xac thuc magic link tren mobile"
git commit -m "chore: cap nhat bien moi truong cho Vercel"
```

### Commit Type Reference

| Type | When to use |
|------|-------------|
| `feat:` | New feature added |
| `fix:` | Bug fixed |
| `chore:` | Config, deps, env changes |
| `style:` | UI/CSS only, no logic change |
| `refactor:` | Code restructure, no behavior change |
| `docs:` | README, comments only |

### 3. Auto-generate Message from Changes

When no message is provided, inspect `git diff --cached --stat` and generate:
```
feat: <verb> <main changed component>

Examples from diff stats:
- app/shop/page.tsx added → "feat: them trang danh sach san pham"
- components/contact-form.tsx modified → "fix: sua form lien he"
- .env.example added → "chore: them env.example cho onboarding"
```

## Safety Rules

- Never commit `.env.local`, `*.key`, `*.pem` files
- Never commit `node_modules/`
- Check `.gitignore` exists before first commit; create if missing:

```gitignore
# .gitignore minimum
.env.local
.env*.local
node_modules/
.next/
out/
*.key
*.pem
```

## First-Time Setup

```bash
git init
git config user.email "user@email.com"
git config user.name "Ten Cua Ban"
```

Ask user for email/name if not already configured (`git config user.email` returns empty).
