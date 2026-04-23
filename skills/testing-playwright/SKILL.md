---
name: testing-playwright
description: >
  Set up and write Playwright E2E tests for Next.js projects. Detection-first —
  adapts to existing Playwright/Cypress setup if present. Referenced by
  branches/maintain/test.md when gen'ing end-to-end tests.
  Trigger phrases (EN + VN): "playwright", "e2e test", "end to end", "test luong",
  "browser test", "test user flow", "cypress".
allowed-tools: Read, Write, Edit, Bash, Grep
---

# testing-playwright — E2E Patterns

## Step 0 — Detect existing E2E runner

Read `package.json`:

| Found | Action |
|---|---|
| `@playwright/test` | Use existing. Read `playwright.config.*`. Skip install. |
| `cypress` | Write Cypress-style test (syntax differs). Warn: migration out of scope. |
| neither | New setup. Continue to Step 1. |

## Step 1 — Install (new setup)

```bash
npm init playwright@latest -- --quiet --browser=chromium --no-examples
```

This creates `playwright.config.ts` + `tests/` + installs `@playwright/test`. On success, the config webServer section needs manual tweaking (Step 2).

Add scripts to `package.json`:
```json
"test:e2e": "playwright test",
"test:e2e:ui": "playwright test --ui",
"test:e2e:debug": "playwright test --debug"
```

## Step 2 — Config for Next.js

Edit `playwright.config.ts`:
```ts
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: process.env.PLAYWRIGHT_BASE_URL ?? 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    // uncomment if multi-browser needed:
    // { name: 'firefox',  use: { ...devices['Desktop Firefox'] } },
    // { name: 'webkit',   use: { ...devices['Desktop Safari'] } },
  ],
  webServer: {
    command: 'npm run build && npm run start',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
  },
})
```

Add `tests/e2e` to `.gitignore` only for `test-results/`, `playwright-report/`, `/blob-report/`. The specs themselves ARE committed.

## Step 3 — Patterns

### Pattern: golden-path smoke
```ts
// tests/e2e/smoke.spec.ts
import { test, expect } from '@playwright/test'

test('homepage loads', async ({ page }) => {
  await page.goto('/')
  await expect(page).toHaveTitle(/My Shop/)
  await expect(page.getByRole('heading', { name: /welcome/i })).toBeVisible()
})
```

### Pattern: sign-up → login → purchase
```ts
test('user can buy a product', async ({ page }) => {
  await page.goto('/signup')
  await page.getByLabel('Email').fill(`test+${Date.now()}@example.com`)
  await page.getByLabel('Password').fill('Passw0rd!')
  await page.getByRole('button', { name: /sign up/i }).click()
  await expect(page).toHaveURL(/\/dashboard/)

  await page.goto('/products/1')
  await page.getByRole('button', { name: /add to cart/i }).click()
  await page.goto('/checkout')
  await expect(page.getByText(/total/i)).toBeVisible()
})
```

### Pattern: auth reuse (skip login each test)

`tests/e2e/auth.setup.ts`:
```ts
import { test as setup, expect } from '@playwright/test'

setup('authenticate', async ({ page }) => {
  await page.goto('/login')
  await page.getByLabel('Email').fill(process.env.E2E_USER_EMAIL!)
  await page.getByLabel('Password').fill(process.env.E2E_USER_PASS!)
  await page.getByRole('button').click()
  await page.waitForURL('/dashboard')
  await page.context().storageState({ path: 'tests/.auth/user.json' })
})
```

In `playwright.config.ts` add a project that depends on auth:
```ts
projects: [
  { name: 'setup', testMatch: /auth\.setup\.ts/ },
  { name: 'chromium', use: { ...devices['Desktop Chrome'], storageState: 'tests/.auth/user.json' }, dependencies: ['setup'] },
]
```

### Pattern: mock API response
```ts
test('handles failing checkout', async ({ page }) => {
  await page.route('**/api/checkout', route => route.fulfill({
    status: 500, body: JSON.stringify({ error: 'stripe_down' }),
  }))
  await page.goto('/checkout')
  await page.getByRole('button', { name: /pay/i }).click()
  await expect(page.getByText(/thử lại sau/i)).toBeVisible()
})
```

### Pattern: VN form with special chars
```ts
await page.getByLabel('Họ tên').fill('Nguyễn Văn Ánh')
await page.getByLabel('Địa chỉ').fill('123 đường Nguyễn Du, Q.1, TP.HCM')
```

## Step 4 — CI integration

For GitHub Actions, see `github-actions-ci` skill. Key pieces:
- `npx playwright install --with-deps chromium` before running
- Upload `playwright-report/` as artifact on failure

## Step 5 — Gotchas

- **"net::ERR_CONNECTION_REFUSED"** → webServer not started. Check `npm run start` works manually.
- **Flaky tests** → don't use `page.waitForTimeout(1000)`; use `expect(...).toBeVisible()` with auto-retry.
- **Playwright mismatched version with downloaded browsers** → `npx playwright install`.
- **Tests passing locally, failing CI** → headless rendering differs; enable traces (`trace: 'on'`) and download on CI artifact.
- **Supabase magic-link in E2E** → magic links email-only is hard; use password auth path OR mock the auth endpoint.

## Constraints

- E2E is slow — don't replace unit tests with E2E. Use E2E only for golden paths (1-5 specs per app).
- Never commit `tests/.auth/` storage states (they contain session tokens).
- `baseURL` must match running server — localhost for dev, preview URL for staging runs.
