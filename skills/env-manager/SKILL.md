---
name: env-manager
description: >
  Generate and validate .env.local and .env.example files for taw-kit projects.
  Ensures all required secrets are present before build or deploy. Never logs
  secret values. Activated at project init and before taw-deploy.
argument-hint: "[generate | validate | 'them bien moi']"
---

# env-manager — Environment Variable Management

## Purpose

Generate `.env.local` templates, validate required keys exist, and produce
`.env.example` with placeholder values safe to commit. Runs before every deploy.

## Required Variables for taw-kit

```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://xxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGci...

# Polar (payment)
POLAR_ACCESS_TOKEN=polar_at_...
POLAR_WEBHOOK_SECRET=whsec_...

# App
NEXT_PUBLIC_APP_URL=https://tenwebsite.vn
```

## .env.example (safe to commit)

```bash
# Supabase — lay tu supabase.com/dashboard > Settings > API
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=

# Polar — lay tu polar.sh/dashboard > Settings > API Keys
POLAR_ACCESS_TOKEN=
POLAR_WEBHOOK_SECRET=

# URL cua website (khong co dau / cuoi)
NEXT_PUBLIC_APP_URL=
```

## Validation Script

```typescript
// scripts/validate-env.ts
const required = [
  "NEXT_PUBLIC_SUPABASE_URL",
  "NEXT_PUBLIC_SUPABASE_ANON_KEY",
  "NEXT_PUBLIC_APP_URL",
]

const missing = required.filter(key => !process.env[key])
if (missing.length > 0) {
  console.error("Thieu bien moi truong:", missing.join(", "))
  console.error("Kiem tra file .env.local va dien day du truoc khi chay.")
  process.exit(1)
}
console.log("Tat ca bien moi truong hop le.")
```

Add to `package.json`:
```json
{
  "scripts": {
    "predev": "npx ts-node scripts/validate-env.ts",
    "prebuild": "npx ts-node scripts/validate-env.ts"
  }
}
```

## Security Rules

- `.env.local` is in `.gitignore` — never commit it
- `.env.example` has empty values only — safe to commit
- Never `console.log` any env value in server code
- `NEXT_PUBLIC_` prefix = exposed to browser — only use for non-secret config
- Supabase anon key is safe for `NEXT_PUBLIC_` (designed for client use)
- `POLAR_ACCESS_TOKEN` and `POLAR_WEBHOOK_SECRET` must NOT have `NEXT_PUBLIC_` prefix

## Vercel Environment Variables

After deploy, set via Vercel dashboard:
Project → Settings → Environment Variables → Add each key for Production.

Or via CLI:
```bash
vercel env add POLAR_ACCESS_TOKEN production
```
