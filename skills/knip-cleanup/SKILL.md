---
name: knip-cleanup
description: >
  Detect unused files, exports, dependencies, and imports in Next.js/TypeScript
  projects using knip. Safe-by-default: report first, delete only on approval.
  Used by branches/maintain/clean.md.
  Trigger phrases (EN + VN): "knip", "dead code", "unused exports",
  "unused deps", "don code", "xoa file thua".
allowed-tools: Read, Write, Edit, Bash, Grep
---

# knip-cleanup — Dead Code Detection

## Step 0 — Detect existing config

Check for `knip.json` / `knip.ts` / knip section in `package.json`. If present, read and respect existing config — don't rewrite.

If missing, plan to generate a starter config in Step 2.

Verify knip is reachable:
```bash
npx knip --version 2>/dev/null || echo "not installed — will use npx"
```

## Step 1 — Run in report mode

Always dry-run first. Never delete anything in the first pass.

```bash
# full report (all categories)
npx knip --reporter compact

# only dependencies
npx knip --include dependencies

# only exports
npx knip --include exports

# only files
npx knip --include files

# JSON output for parsing
npx knip --reporter json > .taw/knip-report.json
```

Compact output shape:
```
Unused dependencies (4)
  lodash
  moment
  ...

Unused exports (12)
  lib/utils.ts:45  oldHelper
  ...

Unused files (2)
  lib/old-auth.ts
  components/DeprecatedModal.tsx
```

## Step 2 — Starter `knip.json` for taw-kit projects

If project has no config, generate:
```json
{
  "$schema": "https://unpkg.com/knip@latest/schema.json",
  "entry": [
    "app/**/{page,layout,route,error,loading,not-found,template}.{ts,tsx}",
    "app/**/opengraph-image.{ts,tsx,png}",
    "app/**/*.{css,scss}",
    "middleware.ts",
    "next.config.{js,mjs,ts}",
    "tailwind.config.{js,ts}",
    "postcss.config.{js,mjs}",
    "scripts/**/*.{ts,js}"
  ],
  "project": ["**/*.{ts,tsx,js,jsx}!"],
  "ignoreDependencies": [
    "tailwindcss",
    "postcss",
    "autoprefixer",
    "@types/*",
    "eslint-*"
  ],
  "ignore": [
    "supabase/migrations/**",
    "types/supabase.ts",
    "*.d.ts"
  ],
  "next": { "entry": ["next.config.{js,mjs,ts}"] }
}
```

Save as `knip.json` at repo root.

## Step 3 — False-positive patterns to whitelist

knip often flags these — add to `ignore` / `ignoreDependencies` / `ignoreExportsUsedInFile`:

| Pattern | Why it's actually used |
|---|---|
| `app/**/opengraph-image.tsx` | Next.js reads by filename convention |
| `app/sitemap.ts`, `robots.ts` | filename convention |
| `tailwind.config.*` plugins | CSS-side, invisible to TS graph |
| `@types/*` | Ambient, no import statement |
| `eslint-*`, `prettier*` | Tool CLI, invoked via script |
| Route segment configs (`export const dynamic = 'force-dynamic'`) | side-effectful export |
| Server actions (`'use server'` exports) | called via `action={...}` prop |

## Step 4 — Apply fixes (only on approval)

Per category:

### Unused dependencies
```bash
npm uninstall <pkg1> <pkg2>
```
Re-run `npm install` to refresh lockfile.

### Unused exports
For each flagged export, decide: (1) delete the function entirely if no external users, (2) un-export (keep the function internal) if still used inside the file.

Use Edit to modify source file — don't rm the whole file unless knip also flags it as "unused file".

### Unused files
```bash
git rm <file>
```
After every 5 deletes: `npm run build` to catch missed imports. Roll back the last batch if build breaks.

### Unused imports (per-file)
```bash
npx eslint . --fix --rule '{"unused-imports/no-unused-imports":"error"}'
```
Requires `eslint-plugin-unused-imports` — install if missing:
```bash
npm install -D eslint-plugin-unused-imports
```

## Step 5 — Verify

```bash
npm run build
npm test 2>/dev/null || true
npx tsc --noEmit
```

Any failure → revert the batch:
```bash
git restore --staged . && git checkout .
```

## Step 6 — Report

```
Dọn xong:
  - 4 deps           (-2.3 MB node_modules)
  - 12 unused exports
  - 2 orphan files
  - 23 unused imports

Build: xanh. Tests: pass.
```

## Gotchas

- **"Unused dependency: next"** → knip config is wrong (entry missing). Check `entry` patterns.
- **"Unused export: default"** on API routes → false positive; add `app/api/**/*.ts` to `ignore` OR use `entry` pattern.
- **Barrel files (`index.ts`)** re-exporting lots → knip may not trace through; add to `ignoreExportsUsedInFile`.
- **CSS imports** (`import './globals.css'`) seen as unused → they're side-effects; knip usually handles but edge cases need `ignore`.

## Constraints

- NEVER delete without user approval — always report first
- Skip `node_modules/`, `.next/`, `dist/`, `supabase/migrations/`, generated files
- Run `npm run build` after each batch of ≤5 deletes so rollback stays small
- Preserve `knip.json` / `.knipignore` if user already tuned them
