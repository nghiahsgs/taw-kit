# maintain: types

Sync TypeScript types. Generate `Database` types from Supabase schema, API route types, regenerate typed Supabase client. Useful after any migration.

**Prereq:** router classified `tier2 = types`.

## Step 1 — Detect scope

Ask (if not given):
```
Đồng bộ type gì?
  1. supabase  — gen Database types từ schema hiện tại
  2. api       — gen types cho app/api/**/route.ts (request/response)
  3. env       — gen type cho process.env (từ .env.local)
  4. tất cả
```

Default (empty args): run all 3.

## Step 2 — Supabase types

Needs Supabase CLI. Check:
```bash
command -v supabase >/dev/null 2>&1
```

Missing → ask to install: `brew install supabase/tap/supabase` or `npm i -D supabase`.

### Step 2a — Get project ref

Read `.env.local` for `NEXT_PUBLIC_SUPABASE_URL`. Extract project ref (subdomain):
```
https://abcdxyz.supabase.co → ref = abcdxyz
```

If missing → ask user for ref, or for `SUPABASE_PROJECT_ID` env.

### Step 2b — Generate

```bash
# remote schema (cloud-hosted supabase)
npx supabase gen types typescript \
  --project-id <ref> \
  --schema public > types/supabase.ts

# OR local schema (if user runs supabase locally)
npx supabase gen types typescript --local > types/supabase.ts
```

Create `types/` dir if missing.

### Step 2c — Wire typed client

Check `lib/supabase.ts` (or `lib/supabaseClient.ts`, `utils/supabase/client.ts`). If present without generic, patch:
```ts
// from
import { createBrowserClient } from '@supabase/ssr'
export const supabase = createBrowserClient(...)

// to
import { createBrowserClient } from '@supabase/ssr'
import type { Database } from '@/types/supabase'
export const supabase = createBrowserClient<Database>(...)
```

Apply same patch to server client (`utils/supabase/server.ts`) if exists.

## Step 3 — API route types

For each `app/api/**/route.ts`, generate:

```ts
// Per route — auto-written to types/api.ts

// POST /api/checkout
export type CheckoutRequestBody = { /* inferred from body parsing */ }
export type CheckoutResponse = { /* inferred from NextResponse.json calls */ }
```

Approach:
1. Grep each route for `req.json()` callers → walk the destructure to infer body shape
2. Grep for `NextResponse.json(X)` callers → infer response shape
3. If a Zod schema is used, import it instead of regenerating

Write to `types/api.ts`.

**If the route is too complex to infer** (conditional branches, loops), mark as `// TODO: define manually` instead of guessing.

## Step 4 — Env types

Read `.env.local` + `.env.example`. Extract key names only (never values).

Generate `types/env.d.ts`:
```ts
declare namespace NodeJS {
  interface ProcessEnv {
    NEXT_PUBLIC_SUPABASE_URL: string
    NEXT_PUBLIC_SUPABASE_ANON_KEY: string
    SUPABASE_SERVICE_ROLE_KEY: string
    POLAR_ACCESS_TOKEN: string
    // ... each key from .env*
  }
}
```

Make sure `tsconfig.json` includes `types/` in `include` or uses `typeRoots`. Patch if needed.

## Step 5 — Verify

```bash
npx tsc --noEmit 2>&1 | tail -30
```

If new errors appeared (e.g. places using `any` on supabase responses now fail):
```
⚠️ Type check mới phát hiện {N} lỗi.
Đây là điều tốt — trước đây dùng `any` nên ẩn được.
Chọn:
  1. show — xem danh sách
  2. fix  — gọi /taw fix với lỗi type
  3. keep — em tự sửa
```

## Step 6 — Commit

`git-auto-commit`:
```
type=chore, scope=types, subject="sync types (supabase + api + env)"
```

## Step 7 — Done

```
✓ Types đồng bộ.
  types/supabase.ts — 14 tables, 3 enums
  types/api.ts — 8 routes typed
  types/env.d.ts — 12 env vars

tsc: xanh (hoặc: còn {N} lỗi mới phát hiện)
```

## Constraints

- NEVER write env VALUES into types — only the keys/name shape
- If `supabase/migrations/` doesn't match remote (drift detected by CLI), report drift before gen — offer to pull schema first
- `types/` is committed code (NOT gitignored) — it's the source of truth for TS
- If project uses Drizzle/Prisma instead of raw Supabase, skip Step 2 and point user to their ORM's gen command
- For API routes too complex to infer, do NOT fabricate types — use `unknown` or `// TODO` and tell user
