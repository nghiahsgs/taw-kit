---
name: github-actions-ci
description: >
  Generate GitHub Actions CI workflows for taw-kit Next.js / Expo projects.
  Detection-first — reads package.json scripts and existing .github/workflows/
  to avoid overwriting user's custom CI. Covers lint/type/test/build matrix,
  Playwright browsers, Supabase schema checks, and optional preview deploys.
  Trigger phrases (EN + VN): "github actions", "ci cd", "set up ci",
  "gen workflow", "tao ci", "chay test tren github", "workflow yaml".
allowed-tools: Read, Write, Edit, Bash, Grep
---

# github-actions-ci — Workflow Generator

## Step 0 — Detect

```bash
# existing workflows?
ls .github/workflows/ 2>/dev/null

# available scripts to run in CI
node -e "console.log(Object.keys(require('./package.json').scripts||{}).join('\n'))"

# mobile (Expo) or web?
test -f app.json && echo "mobile (Expo)" || echo "web (Next.js)"
```

If `.github/workflows/ci.yml` already exists → read, show user, ask before overwriting. Never clobber silently.

If directory missing → `mkdir -p .github/workflows`.

## Step 1 — Pick workflow flavour

Based on detected scripts:

| Scripts present | Include in CI |
|---|---|
| `lint` (any — `next lint`, `eslint`) | lint job |
| `test` | unit test job |
| `test:e2e` | E2E job (needs Playwright browsers) |
| `test:rls` | RLS pgTAP job (needs Supabase start) |
| `build` | always include |
| `typecheck` or tsc exists | typecheck job |

## Step 2 — Core workflow template

`.github/workflows/ci.yml`:
```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  # ──────────────── Install + cache ────────────────
  setup:
    name: Setup
    runs-on: ubuntu-latest
    outputs:
      cache-hit: ${{ steps.cache.outputs.cache-hit }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci

  # ──────────────── Lint ────────────────
  lint:
    name: Lint
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      - run: npm run lint

  # ──────────────── Typecheck ────────────────
  typecheck:
    name: Typecheck
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      - run: npx tsc --noEmit

  # ──────────────── Unit tests ────────────────
  test:
    name: Unit tests
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      - run: npm test

  # ──────────────── Build ────────────────
  build:
    name: Build
    needs: [lint, typecheck, test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      - run: npm run build
        env:
          NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.NEXT_PUBLIC_SUPABASE_URL }}
          NEXT_PUBLIC_SUPABASE_ANON_KEY: ${{ secrets.NEXT_PUBLIC_SUPABASE_ANON_KEY }}
          # add any build-time env vars here — NEVER hardcode secrets
```

## Step 3 — Add-on jobs (include if relevant scripts exist)

### E2E (Playwright)
```yaml
  e2e:
    name: E2E
    needs: setup
    runs-on: ubuntu-latest
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      - run: npx playwright install --with-deps chromium
      - run: npm run test:e2e
        env:
          NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.NEXT_PUBLIC_SUPABASE_URL }}
          NEXT_PUBLIC_SUPABASE_ANON_KEY: ${{ secrets.NEXT_PUBLIC_SUPABASE_ANON_KEY }}
      - if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 7
```

### RLS tests (Supabase + pgTAP)
```yaml
  rls:
    name: Supabase RLS
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: supabase/setup-cli@v1
        with: { version: latest }
      - run: supabase start
      - run: supabase test db
```

### Expo mobile (EAS build preview on PR)
```yaml
  eas-preview:
    name: EAS Preview (PR)
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - uses: expo/expo-github-action@v8
        with:
          eas-version: latest
          token: ${{ secrets.EXPO_TOKEN }}
      - run: npm ci
      - run: eas build --platform all --profile preview --non-interactive
```

### Vercel preview deploy
Actually Vercel handles this automatically via its GitHub app — don't add a workflow for it unless user has NO Vercel GitHub integration. If self-managing:
```yaml
  deploy-preview:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    needs: [build]
    steps:
      - uses: actions/checkout@v4
      - run: npm install -g vercel
      - run: vercel pull --yes --environment=preview --token=${{ secrets.VERCEL_TOKEN }}
      - run: vercel build --token=${{ secrets.VERCEL_TOKEN }}
      - id: deploy
        run: |
          URL=$(vercel deploy --prebuilt --token=${{ secrets.VERCEL_TOKEN }})
          echo "url=$URL" >> "$GITHUB_OUTPUT"
      - uses: marocchino/sticky-pull-request-comment@v2
        with:
          message: "✓ Preview deployed: ${{ steps.deploy.outputs.url }}"
```

### Security scan (taw-security quick mode)
```yaml
  security:
    name: Security audit
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      # just the P0-level checks that can run statically
      - run: |
          # secret leak detection
          if git grep -nE 'sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9]{30,}'; then
            echo "::error::Hardcoded secret found"
            exit 1
          fi
          # .env committed
          if git ls-files | grep -E '^\.env(\.|$)' | grep -v '\.env\.example$'; then
            echo "::error::.env file committed"
            exit 1
          fi
      - run: npm audit --audit-level=high || true
```

## Step 4 — Secrets to configure

User must add in GitHub repo → Settings → Secrets and variables → Actions:

| Secret | Used by |
|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | build, e2e |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | build, e2e |
| `SUPABASE_SERVICE_ROLE_KEY` | build (server-only Supabase routes) |
| `STRIPE_SECRET_KEY` | build (if using Stripe) |
| `STRIPE_WEBHOOK_SECRET` | e2e |
| `SENTRY_AUTH_TOKEN` | build (source map upload) |
| `VERCEL_TOKEN` | deploy-preview |
| `EXPO_TOKEN` | eas-preview |

Emit reminder to user:
```
✓ CI workflow đã tạo tại .github/workflows/ci.yml

Cần add secrets vào GitHub repo:
  Settings → Secrets and variables → Actions → New repository secret

Secrets cần: (based on your stack)
  - NEXT_PUBLIC_SUPABASE_URL
  - NEXT_PUBLIC_SUPABASE_ANON_KEY
  - ... (danh sách còn lại)
```

## Step 5 — Dependabot (optional but recommended)

`.github/dependabot.yml`:
```yaml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
    groups:
      minor-patch:
        update-types: ["minor", "patch"]
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "monthly"
```

## Gotchas

- **`npm ci` fails locally but works CI (or vice versa)** — Node version mismatch. Pin via `.nvmrc` + `actions/setup-node` both at Node 20.
- **Playwright "browser not found"** → `npx playwright install --with-deps` is required before `test:e2e`; `--with-deps` installs OS libs (libgbm, etc).
- **E2E flaky on CI only** → disable parallelism with `workers: 1` in playwright.config.
- **Build needs secrets but PR from fork** — secrets aren't exposed to fork PRs (security feature). Either use `pull_request_target` (dangerous) or require secrets only on main push.
- **Concurrent workflow runs racing** → `concurrency.cancel-in-progress: true` (in template above) auto-cancels superseded runs.

## Constraints

- NEVER commit secret values into workflow YAML — reference `${{ secrets.X }}` only
- Pin action versions with major tag (`@v4`) — not `@main` or `@latest`, prevents supply-chain drift
- If project has custom CI already, show diff + ask before overwriting
- Keep CI budget under 10 min total — parallelize where possible, cancel superseded runs
- For Expo projects, default to EAS preview on PR; don't deploy to stores from CI without explicit ask
