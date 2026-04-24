# advisor: coverage

Render ASCII diagram of code paths + user flows + test coverage status for a target feature/folder. Identify GAPS and recommend unit vs E2E for each. Non-destructive — output is a diagram, not new tests.

**Prereq:** router classified `tier1 = ADVISOR`, `tier2 = coverage`.

**Philosophy:** coverage % is noise. A feature can have 80% line coverage and still miss the 1 path that breaks in prod. This branch shows **which specific paths need what kind of test**.

## Step 1 — Target resolution

Same pattern as `@analyze.md` Step 1:
```
/taw coverage auth        → feature name
/taw coverage app/api     → path
/taw coverage             → empty → ask "Check coverage cho phần nào?"
```

## Step 2 — Detect test framework (detection-first)

```bash
node -e "const p=require('./package.json'); console.log(Object.keys({...p.dependencies,...p.devDependencies}).filter(k=>['vitest','jest','@playwright/test','cypress'].includes(k)))"
```

Map:
- `vitest` → unit framework
- `jest` → unit framework (Jest)
- `@playwright/test` → E2E framework
- `cypress` → E2E framework (Cypress)
- none → still produce diagram, skip "what's tested" column, emit "no test framework" note

Read test config to know WHERE tests live:
- `vitest.config.*` → check `test.include` or follow defaults (`**/*.{test,spec}.{ts,tsx}`)
- `playwright.config.*` → `testDir`

## Step 3 — Read target + trace data flow

For each file in target:
1. Read full file (not just changed hunks)
2. Parse exports — each export is an entry point
3. For each export, trace:
   - Input sources (params, body, headers, cookies, props)
   - Transforms (validation, mapping, computation)
   - Output destinations (DB write, API response, rendered JSX, redirect)
   - Error paths (try/catch, early return, throw)
4. Follow calls into child functions — recurse max 2 levels

## Step 4 — Identify user flows (for UI features)

For `app/**/page.tsx` + `components/**`:
- Form submissions: each `<form action={...}>` or `onSubmit`
- Button handlers: each `onClick` triggering state mutation
- Navigation: each `router.push` or `<Link>`
- Auth boundaries: each protected route

For each flow, enumerate:
- Happy path (valid input, network OK, user logged in)
- Edge: empty/max-length input
- Edge: network failure (timeout, 500)
- Edge: double-submit (rapid click)
- Edge: stale session (page open 30min)
- Edge: concurrent tab (2 tabs same user)

## Step 5 — Match paths to existing tests

For each identified path:
```bash
# look for test covering it
grep -rn "<function-name>\|<route-name>" --include='*.test.*' --include='*.spec.*' 2>/dev/null
```

Classify each match:
- ★★★ — tests happy path + 2+ edge cases + error paths
- ★★   — tests happy path only
- ★    — existence check only ("it renders", "doesn't throw")
- GAP  — no test found

## Step 6 — E2E vs Unit decision per gap

For each GAP, recommend:

| Criteria | Recommendation |
|---|---|
| Pure function, clear inputs/outputs | UNIT test |
| Single component render + 1 interaction | UNIT (RTL) |
| Internal helper no side effects | UNIT |
| Flow spans 3+ components/services | **E2E** |
| Auth / payment / destructive action | **E2E** — too important for mocks |
| Integration of API → queue → DB | **E2E or integration** |
| LLM call with prompt change | **EVAL** (quality-score, not pass/fail) |
| Obscure edge, rarely hit | Unit (cheap), or skip if truly irrelevant |

## Step 7 — Render coverage diagram (VN-friendly)

```
Coverage: auth (stack: Next.js + Supabase + vitest + playwright)

────────────────────────────────────────────────
 CODE PATHS
────────────────────────────────────────────────

[+] lib/auth.ts
    │
    ├── signIn(email, password)
    │   ├── [★★★ TESTED] happy + wrong password + rate-limited — auth.test.ts:15
    │   ├── [GAP]        network timeout — NO TEST
    │   └── [GAP]        Supabase 500 — NO TEST
    │
    ├── signOut()
    │   └── [★   WEAK]   renders button only, no assertion — auth.test.ts:48
    │
    └── requireAuth(request)
        ├── [★★  OK]    happy + no session — middleware.test.ts:22
        └── [GAP]       expired token edge — NO TEST

[+] app/login/page.tsx
    │
    └── <LoginForm />
        ├── [GAP] [→E2E]  full login flow — needs Playwright, not unit
        └── [GAP]          form validation error display — UNIT ok

────────────────────────────────────────────────
 USER FLOWS
────────────────────────────────────────────────

[+] Sign-in flow
    │
    ├── [★★★ TESTED]  complete login → redirect dashboard — login.spec.ts:12
    ├── [GAP] [→E2E]  double-submit guard
    ├── [GAP]          "Forgot password" link behaviour
    └── [GAP]          stale session (page open 30min then submit)

[+] Error states
    │
    ├── [★★  OK]      wrong password toast — login.spec.ts:34
    ├── [GAP]          no network UX (what does user see?)
    └── [GAP]          account locked UX (5 failed attempts)

────────────────────────────────────────────────
 SUMMARY
────────────────────────────────────────────────
Code paths:  3/7 tested (43%)   ★★★:1 ★★:1 ★:1
User flows:  2/8 tested (25%)
Gaps: 9 total (3 need E2E, 6 unit-ok)

Most important gaps:
  1. [→E2E] Double-submit guard  — dễ gây order dupe
  2. [UNIT] Network timeout in signIn  — silent fail trong prod
  3. [UNIT] Expired token edge  — user stuck trên protected route

────────────────────────────────────────────────
 ACTIONS
────────────────────────────────────────────────
  /taw test unit lib/auth.ts        → gen 3 unit tests cho gaps có [UNIT]
  /taw test e2e login flow          → gen Playwright cho gaps có [→E2E]
  /taw fix                          → nếu gap là BUG thực (không chỉ thiếu test)
```

**If no test framework installed:**
Skip the ★ classification, show "NO TESTS" on all paths, emit at bottom:
```
⚠️ Project chưa có test framework. Em không biết path nào đã tested.
Gõ `/taw test` để setup vitest/playwright trước.
```

## Step 8 — Prioritization rule (REGRESSION-AWARE)

If any path is a **regression** (code exists, was working, diff recently modified without test):
- Mark with 🔥 RED icon
- Place at TOP of "Most important gaps"
- These are highest priority — bug-fixed-then-untested means nothing prevents the bug returning

## Constraints

- Read-only — never write tests, never modify source
- Max 3 levels of call tracing — don't go infinite into deps
- E2E vs Unit decision is OPINION — state reasoning briefly when unclear
- Don't over-recommend E2E (slow, expensive) — default to unit unless clearly multi-service
- If target has 0 code paths (folder empty) — emit "Không có gì để check. Anh build feature trước."
- "Most important gaps" ≤ 5 items. More = overwhelming, dev skips all.
- Don't grade on curve — 25% user-flow coverage IS bad, say so. No "overall pretty good!".
