---
name: sentry-errors
description: >
  Sentry error tracking + performance monitoring for Next.js App Router.
  Detection-first: adapts if already installed; otherwise installs fresh.
  Covers client + server + edge runtime, source map upload, and PII scrubbing.
  Trigger phrases (EN + VN): "sentry", "error tracking", "monitor loi",
  "theo doi loi", "crash reporting", "cai sentry", "app loi khong biet".
allowed-tools: Read, Write, Edit, Bash, Grep
---

# sentry-errors — Error Tracking

## Step 0 — Detect existing setup

```bash
# installed?
grep -l '@sentry/nextjs' package.json 2>/dev/null

# env keys?
grep -E 'SENTRY_DSN|NEXT_PUBLIC_SENTRY_DSN|SENTRY_AUTH_TOKEN' .env.local .env.example 2>/dev/null

# config files?
ls sentry.client.config.* sentry.server.config.* sentry.edge.config.* 2>/dev/null
```

If installed + configured → read existing, skip install. Apply additional patterns only.
If installed but misconfigured → fix the gap (often: source map upload missing in CI).
If nothing → new setup, Step 1.

## Step 1 — Install + wizard (new)

```bash
npx @sentry/wizard@latest -i nextjs
```

The wizard:
- Creates `sentry.{client,server,edge}.config.ts`
- Patches `next.config.mjs` to wrap with `withSentryConfig`
- Prompts for DSN + optional auth token
- Adds `.sentryclirc` (gitignore this)

If user declines to run wizard (wants manual): continue to Step 2.

## Step 2 — Manual install

```bash
npm install @sentry/nextjs
```

`sentry.client.config.ts`:
```ts
import * as Sentry from '@sentry/nextjs'

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  tracesSampleRate: 0.1,
  replaysSessionSampleRate: 0.0,
  replaysOnErrorSampleRate: 1.0,
  integrations: [Sentry.replayIntegration()],
  beforeSend(event, hint) {
    // scrub PII from client-side events
    if (event.request?.cookies) delete event.request.cookies
    return event
  },
})
```

`sentry.server.config.ts`:
```ts
import * as Sentry from '@sentry/nextjs'
Sentry.init({
  dsn: process.env.SENTRY_DSN,
  tracesSampleRate: 0.1,
})
```

`sentry.edge.config.ts`:
```ts
import * as Sentry from '@sentry/nextjs'
Sentry.init({ dsn: process.env.SENTRY_DSN, tracesSampleRate: 0.1 })
```

Patch `next.config.mjs`:
```js
import { withSentryConfig } from '@sentry/nextjs'
const nextConfig = { /* ... */ }
export default withSentryConfig(nextConfig, {
  org: 'your-org',
  project: 'your-project',
  silent: !process.env.CI,          // silent in dev
  widenClientFileUpload: true,
  hideSourceMaps: true,
  disableLogger: true,
})
```

## Step 3 — Env vars

```bash
NEXT_PUBLIC_SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx   # public — safe to ship
SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx                # server — usually same as public, but keep as server var
SENTRY_AUTH_TOKEN=sntrys_...                                   # CI only, for source map upload
SENTRY_ORG=your-org
SENTRY_PROJECT=your-project
```

Get DSN: Sentry dashboard → Settings → Projects → (your project) → Client Keys.
Get auth token: User Settings → Auth Tokens → Create with `project:write` scope.

## Step 4 — Manual capture patterns

### Log an error with context
```ts
import * as Sentry from '@sentry/nextjs'

try {
  await riskyThing()
} catch (err) {
  Sentry.captureException(err, {
    tags: { section: 'checkout' },
    extra: { orderId: order.id, user: user.id },
  })
  throw err  // re-throw if caller needs to know
}
```

### Set user context (after login)
```ts
Sentry.setUser({ id: user.id, email: user.email })
// clear on logout:
Sentry.setUser(null)
```

### Breadcrumbs
```ts
Sentry.addBreadcrumb({ category: 'cart', message: 'item added', level: 'info' })
```

### Sentry-wrapped Route Handler
```ts
import * as Sentry from '@sentry/nextjs'

export const POST = Sentry.wrapApiHandlerWithSentry(async (req) => {
  // ... your handler
  return Response.json({ ok: true })
}, '/api/your-route')
```

(Note: for App Router route handlers, use `wrapRouteHandlerWithSentry`.)

## Step 5 — Source map upload in CI

For readable stack traces in production, upload source maps during build. The wizard adds this to `next.config.mjs` automatically via `withSentryConfig`.

In CI (GitHub Actions), ensure `SENTRY_AUTH_TOKEN` is in secrets. Build step:
```yaml
- name: Build
  run: npm run build
  env:
    SENTRY_AUTH_TOKEN: ${{ secrets.SENTRY_AUTH_TOKEN }}
    SENTRY_ORG: your-org
    SENTRY_PROJECT: your-project
```

Verify upload: in Sentry dashboard, recent deploys should show "source maps uploaded".

## Step 6 — PII scrubbing (important for VN compliance)

Default Sentry Data Scrubber catches passwords, tokens, CC numbers. Add project-specific rules:

Dashboard → Settings → Security & Privacy → Data Scrubbing → add fields:
- `email`, `phone`, `address`, `cccd`, `cmnd` (VN ID numbers)

Or in code via `beforeSend`:
```ts
beforeSend(event) {
  if (event.user?.email) event.user.email = event.user.email.replace(/(.).*@/, '$1***@')
  return event
}
```

## Step 7 — Alert rules

Dashboard → Alerts → Create Alert. Recommended:
- **Error spike**: `>20 events in 1 min` → Slack/email immediately
- **Regression**: `Issue seen before in prod resolved, now unresolved` → email
- **Crash free users < 99%** (mobile projects)

## Step 8 — Test the integration

```ts
// app/test-sentry/route.ts  (delete after testing)
export function GET() {
  throw new Error('Sentry smoke test — ignore')
}
```
Hit `/test-sentry`, then check Sentry dashboard — issue should appear within 30s.

## Gotchas

- **"No release found"** in Sentry issues → source maps not uploaded. Check CI has `SENTRY_AUTH_TOKEN`.
- **Duplicate events** → Sentry captures uncaught errors automatically AND you called `captureException`. Don't double-capture; use one or the other.
- **Rate limit hit** → tune `tracesSampleRate` down; at scale, `0.01` is plenty for perf traces.
- **Edge runtime errors not caught** → `sentry.edge.config.ts` must exist and be imported.
- **Stack traces show minified code** → source map upload failed. Re-run `sentry-cli releases files upload-sourcemaps`.

## Constraints

- NEVER put secret DSN-like tokens in `NEXT_PUBLIC_*` vars — DSN is designed to be public but auth token is NOT
- Don't capture PII in breadcrumbs or user context — scrub before `captureException`
- Sampling: 0.1 traces in prod, 1.0 errors always
- Source maps MUST be uploaded for production builds — otherwise stack traces are useless
- Don't skip `beforeSend` scrubbing if handling VN user data (email + phone are PII)
