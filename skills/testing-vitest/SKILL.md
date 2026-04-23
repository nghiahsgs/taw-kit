---
name: testing-vitest
description: >
  Set up and write Vitest unit/component tests for Next.js / React projects.
  Detection-first: adapts to whatever test runner is already installed. Used
  by branches/maintain/test.md when gen'ing unit or component tests.
  Trigger phrases (EN + VN): "vitest setup", "unit test", "gen test", "viết test",
  "test component", "jsdom test", "@testing-library".
allowed-tools: Read, Write, Edit, Bash, Grep
---

# testing-vitest — Vitest Setup + Patterns

## Step 0 — Detect existing test runner

Read `package.json` → scan `devDependencies`:

| Found | Action |
|---|---|
| `vitest` | Use existing config. Skip install. Read `vitest.config.*` to understand setup. |
| `jest` | Project is Jest-based. Offer to write Jest-style tests OR migrate to Vitest (warn: migration is a separate branch, out of scope here). Default = write Jest style. |
| neither | New setup. Continue to Step 1. |

NEVER install Vitest if Jest is already present — user must explicitly request migration.

## Step 1 — Install (new setup only)

```bash
npm install -D vitest @vitest/ui @testing-library/react @testing-library/jest-dom @testing-library/user-event jsdom @vitejs/plugin-react
```

Add scripts to `package.json`:
```json
"test": "vitest run",
"test:watch": "vitest",
"test:ui": "vitest --ui",
"test:coverage": "vitest run --coverage"
```

## Step 2 — Config file

Create `vitest.config.ts` at repo root:
```ts
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import path from 'node:path'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./test/setup.ts'],
    css: true,
    coverage: { provider: 'v8', reporter: ['text', 'html'] },
  },
  resolve: {
    alias: { '@': path.resolve(__dirname, './') },
  },
})
```

Create `test/setup.ts`:
```ts
import '@testing-library/jest-dom/vitest'
import { afterEach } from 'vitest'
import { cleanup } from '@testing-library/react'
afterEach(() => cleanup())
```

Add to `tsconfig.json` types: `"types": ["vitest/globals", "@testing-library/jest-dom"]`

## Step 3 — Patterns

### Pattern: pure function (happy + edge)
```ts
// lib/cart.test.ts
import { describe, it, expect } from 'vitest'
import { calcTotal, applyDiscount } from './cart'

describe('calcTotal', () => {
  it('sums item prices', () => {
    expect(calcTotal([{ price: 100 }, { price: 50 }])).toBe(150)
  })
  it('handles empty cart', () => {
    expect(calcTotal([])).toBe(0)
  })
  it('ignores negative prices', () => {
    expect(calcTotal([{ price: -10 }, { price: 5 }])).toBe(5)
  })
})
```

### Pattern: React component
```tsx
// components/LoginForm.test.tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, it, expect, vi } from 'vitest'
import { LoginForm } from './LoginForm'

describe('LoginForm', () => {
  it('submits with entered email', async () => {
    const onSubmit = vi.fn()
    render(<LoginForm onSubmit={onSubmit} />)
    await userEvent.type(screen.getByLabelText(/email/i), 'a@b.com')
    await userEvent.click(screen.getByRole('button', { name: /login/i }))
    expect(onSubmit).toHaveBeenCalledWith({ email: 'a@b.com' })
  })
})
```

### Pattern: mock Supabase client
```ts
import { vi } from 'vitest'

vi.mock('@/lib/supabase', () => ({
  supabase: {
    from: vi.fn(() => ({
      select: vi.fn(() => ({ eq: vi.fn(() => ({ data: [{ id: 1 }], error: null })) })),
    })),
    auth: { getUser: vi.fn(() => ({ data: { user: { id: 'u1' } }, error: null })) },
  },
}))
```

### Pattern: Next.js Server Component
Server Components can't mount via RTL directly — test the async function's return shape:
```tsx
import { describe, it, expect } from 'vitest'
import Page from './page'

it('returns items from DB', async () => {
  const result = await Page()
  expect(result.props.children).toBeDefined()
})
```
For full render, prefer Playwright (E2E).

### Pattern: API route handler
```ts
// app/api/hello/route.test.ts
import { GET } from './route'
import { NextRequest } from 'next/server'

it('returns 200 with message', async () => {
  const req = new NextRequest('http://localhost/api/hello')
  const res = await GET(req)
  expect(res.status).toBe(200)
  expect(await res.json()).toEqual({ message: 'hello' })
})
```

## Step 4 — Gotchas

- **"ReferenceError: window is not defined"** → test file imports something needing jsdom, but `environment` not set. Fix: add `// @vitest-environment jsdom` at top.
- **Module alias `@/` not found** → check `resolve.alias` in `vitest.config.ts` matches `tsconfig.json` paths.
- **Next.js server-only modules** (`next/headers`, `cookies()`) → mock them; real ones throw outside request context.
- **CSS imports fail** → keep `css: true` in vitest config OR use `vite-plugin-virtual` to stub them.

## Constraints

- Adapt to existing test runner — do NOT install vitest alongside jest
- Test files sit next to source (`lib/x.ts` → `lib/x.test.ts`) for visibility
- Never commit `.vitest/` cache directory — add to `.gitignore` if missing
