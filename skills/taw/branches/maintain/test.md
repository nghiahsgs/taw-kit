# maintain: test

Auto-generate tests for an existing taw-kit project. Picks the right tool based on what's already installed (or proposes one). Scoped so dev doesn't have to configure anything.

**Prereq:** router classified `tier2 = test`.

## Step 1 — Verify project + detect test setup

Read `package.json`. Detect current test stack:

| Signal | Stack |
|---|---|
| `vitest` in devDeps | Unit = vitest |
| `jest` in devDeps | Unit = jest (warn: prefer vitest for new tests) |
| `@playwright/test` in devDeps | E2E = playwright |
| `cypress` in devDeps | E2E = cypress |
| none | Ask user (Step 2) |

Detect project target (web vs mobile) from `.taw/intent.json` or presence of `app.json` (Expo).

## Step 2 — Pick scope + install if missing

Ask (if args don't specify):
```
Test gì?
  1. unit   — hàm/component đơn lẻ (vitest)
  2. e2e    — luồng user thật (playwright)
  3. rls    — Supabase Row Level Security (sql + pgTAP)
  4. tất cả — cả 3 loại trên
```

If no test runner installed, confirm before install:
```
Chưa có test framework. Cài {vitest/playwright} không? (y/n)
```

Install if `y`:
```bash
# unit (web)
npm install -D vitest @vitest/ui @testing-library/react @testing-library/jest-dom jsdom

# e2e (web)
npm init playwright@latest -- --quiet --browser=chromium --no-examples

# rls
# (no npm — uses supabase CLI + pgTAP)
```

Add scripts to `package.json` if missing:
```json
"test": "vitest run",
"test:watch": "vitest",
"test:e2e": "playwright test",
"test:rls": "supabase db test"
```

Create `vitest.config.ts` if missing:
```ts
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
export default defineConfig({
  plugins: [react()],
  test: { environment: 'jsdom', setupFiles: ['./test/setup.ts'], globals: true },
})
```

Create `test/setup.ts`:
```ts
import '@testing-library/jest-dom/vitest'
```

## Step 3 — Pick target files

If user named a path (`/taw test lib/cart.ts`) → scope to that file + its callers.
Else ask:
```
Test cho phần nào? Ví dụ:
  - lib/cart.ts
  - components/LoginForm.tsx
  - app/api/checkout/route.ts
  - (để trống) → gen test cho tất cả file thay đổi trong 5 commit gần đây
```

Default scope (empty input): files changed in `git diff HEAD~5 --name-only` filtered to `.ts/.tsx` excluding test files themselves.

## Step 4 — Generate tests

For each target file, spawn `fullstack-dev` with this prompt:
```
Task: Generate tests for {file_path}.
Stack: {vitest | playwright | pgTAP based on type}.
Rules:
  - Unit: cover happy path + 2 edge cases per exported function. Use existing types — do NOT rewrite the source file.
  - Component: render + 1 user interaction + 1 assertion. Use @testing-library.
  - E2E: cover 1 golden path end-to-end (auth, checkout, form submit).
  - RLS: for each table with policies in supabase/migrations/, write pgTAP tests for allow + deny cases.
  - Mock Supabase via `vi.mock` at module level. Do NOT mock the database for RLS tests — use a test branch.
  - Name test files `<source>.test.ts` next to source, OR `tests/e2e/<slug>.spec.ts` for E2E.
End: run the generated tests. Report pass/fail.
```

## Step 5 — Run + report

```bash
npm test        # unit
npm run test:e2e # if e2e scoped
npm run test:rls # if rls scoped
```

Capture pass/fail counts. Render (VN):
```
Test xong:
  ✓ Unit: 14 pass / 0 fail
  ✓ E2E: 3 pass / 0 fail
  Time: 4.2s

Files created:
  - lib/cart.test.ts
  - tests/e2e/checkout.spec.ts
```

If any test fails, show the failure block + ask "Fix bằng cách sửa test hay sửa code?"

## Step 6 — Commit

Invoke `taw-commit`:
```
type=test, scope=<inferred>, subject="add tests for <files>"
```

## Constraints

- NEVER rewrite the source file while generating tests — tests must match existing behaviour
- NEVER mock at integration/RLS level — those need real DB
- If tests fail due to a real bug (not test mistake), offer `/taw fix` instead of adjusting tests
- Budget: stop after 10 minutes, commit what's green, report what's red
