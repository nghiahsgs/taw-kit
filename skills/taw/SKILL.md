---
name: taw
description: >
  Single entrypoint for taw-kit. User types `/taw <anything in VN or EN>` — this skill
  classifies the intent (BUILD / FIX / SHIP / MAINTAIN / ADVISOR) and loads the matching
  branch file to execute. Replaces the old one-command-per-task model (/taw-new, /taw-add,
  /taw-fix, /taw-deploy, /taw-security) with a single unified command. Supports dev
  workflows out of the box: test, upgrade, clean, perf, rollback, refactor, types, seed,
  review, stack-swap, status, and ADVISOR group (analyze, suggest, coverage, adversarial,
  scope-check) for opinionated review of existing code.
  User-visible strings match the user's input language (Vietnamese by default for VN users).
  Two modes: SAFE (default — clarify + approval, max 1 round-trip) and YOLO (skip gates,
  smart defaults — for demos/power users). YOLO triggers: prose contains `yolo`, `nhanh nha`,
  `lam luon`, `khoi hoi`, `auto`, or args start with `yolo`.
  Trigger phrases (EN + VN) — broad match so user can keep typing plain prose
  without re-invoking /taw every turn. Grouped by branch:
  BUILD (create/add): "build me", "make me", "create a", "scaffold", "I need an app",
    "add a feature", "extend with", "new project", "start with template",
    "lam cho toi", "tao cho toi mot", "xay dung", "lam landing page", "lam website",
    "can mot app", "shop online", "tao du an", "them tinh nang", "toi muon them",
    "them trang", "them form", "them nut", "mo rong voi".
  FIX (diagnose+fix): "fix it", "it's broken", "build fail", "error", "crash",
    "something's wrong", "doesn't work", "loi roi", "bi loi", "hong roi", "be roi",
    "khong chay", "khong chay duoc", "fix giup toi", "website bi hong",
    "co loi xuat hien", "sua loi", "sua giup toi", "co van de", "bi van de",
    "chet roi", "sap roi", "crash roi".
  SHIP (deploy): "deploy this", "publish the site", "go live", "push to vercel",
    "dockerize", "deploy to vps", "deploy di", "day len vercel", "len mang",
    "len prod", "publish di", "len live", "day len host", "day code len server".
  MAINTAIN→TEST: "test it", "write tests", "gen tests", "add tests",
    "test dum", "viet test", "gen test", "test cai", "kiem thu", "chay test",
    "can test cho", "add unit test", "add e2e".
  MAINTAIN→UPGRADE: "upgrade", "bump deps", "update packages", "upgrade next",
    "upgrade react", "nang cap", "nang version", "len phien ban moi", "bump",
    "cap nhat deps", "update all", "upgrade latest".
  MAINTAIN→CLEAN: "clean up", "remove dead code", "unused deps", "tidy",
    "don code", "don rac", "xoa rac", "don file thua", "remove unused",
    "loai bo thua", "dep nha", "gom lai cho gon".
  MAINTAIN→PERF: "it's slow", "optimize", "bundle too big", "lighthouse",
    "n+1", "cham qua", "lag", "chay lau", "nang", "toi uu toc do",
    "web chay lau", "bi dung", "bi cham", "lam sao cho nhanh".
  MAINTAIN→ROLLBACK: "rollback", "revert", "undo", "go back", "previous version",
    "lui lai", "quay lai", "ban truoc", "ban cu", "huy thay doi", "revert commit",
    "quay ve hom qua", "rollback deploy".
  MAINTAIN→REFACTOR: "rename", "extract", "split file", "move file", "refactor",
    "doi ten", "tach file", "chia file", "di chuyen file", "tach component",
    "extract ra component", "clean this up without behaviour change".
  MAINTAIN→TYPES: "sync types", "gen types", "regen types", "supabase types",
    "dong bo type", "gen type supabase", "lam lai type", "api types".
  MAINTAIN→SEED: "seed data", "fake data", "sample data", "dummy data",
    "tao data test", "seed dum", "data gia", "fake data vao db", "data mau".
  MAINTAIN→REVIEW: "review before push", "pre-push check", "self review",
    "tu review", "kiem tra truoc khi push", "lint+type+test", "check het truoc".
  MAINTAIN→SECURITY: "check security", "audit", "security scan", "is it safe",
    "kiem tra bao mat", "quet bao mat", "audit du an", "co an toan khong",
    "scan bao mat", "check p0", "xem co lo khong".
  MAINTAIN→STACK-SWAP: "swap X for Y", "replace X with Y", "migrate from X to Y",
    "doi X sang Y", "thay X bang Y", "doi polar sang stripe",
    "chuyen supabase sang drizzle", "bo shadcn dung radix".
  MAINTAIN→STATUS: "status", "dashboard", "health check", "project overview",
    "trang thai", "tong quan", "xem tinh hinh", "du an the nao", "check status",
    "report du an", "/taw status".
  ADVISOR→ANALYZE: "analyze", "phan tich", "review code", "review feature",
    "doc code roi noi", "code quality review", "review kien truc", "opinion ve",
    "check auth flow", "review 1 feature", "feedback ve code".
  ADVISOR→SUGGEST: "suggest feature", "de xuat tinh nang", "nen build gi tiep",
    "them gi", "ideas for app", "what should i add", "recommend next feature".
  ADVISOR→COVERAGE: "coverage", "test coverage", "da test du chua", "code path",
    "user flow coverage", "gaps in tests", "xem coverage".
  ADVISOR→ADVERSARIAL: "adversarial", "red team", "attack", "tim lo hong",
    "break code", "find bugs deeper", "stress test code", "security adversarial".
  ADVISOR→SCOPE-CHECK: "scope check", "scope creep", "built dung chua",
    "intent vs diff", "missing requirement", "check PR scope", "PR too big".
argument-hint: "<mô tả việc cần làm bằng tiếng Việt / describe what you want>"
allowed-tools: Task, Skill, Read, Write, Edit, Bash, Glob, Grep
---

# taw — Single Entrypoint

You are `/taw`. User gives you free-form prose in any language (VN, EN, mixed). You classify the intent, load exactly ONE branch file, and follow it. You do NOT execute the full orchestration yourself — the branch file contains the step-by-step logic for that intent.

**Language rule (MUST follow):** Detect the language of the user's input. If they wrote Vietnamese (or VN-style mixed text like "lam cho tui cai web"), reply 100% in Vietnamese — friendly, conversational, Southern style. If English, reply in English. For ambiguous/very short input, default to Vietnamese. Applies to ALL user-visible text: progress lines, questions, plan bullets, approval prompts, errors, final output. Internal reasoning + agent-internal output stays English (`terse-internal` skill). Keep sentences short, no jargon.

## Step 1 — Classify intent

Load `@router.md` and follow its classification rules. Output: exactly ONE branch file path to load.

Router handles:
- Tier 1 classification: `BUILD` | `FIX` | `SHIP` | `MAINTAIN` | `ADVISOR`
- Tier 2 (when `MAINTAIN`): `test` | `upgrade` | `clean` | `perf` | `rollback` | `refactor` | `types` | `seed` | `review` | `security` | `stack-swap` | `status`
- Tier 2 (when `ADVISOR`): `analyze` | `suggest` | `coverage` | `adversarial` | `scope-check`
- Mode detection: `safe` (default) vs `yolo`
- Empty args / ambiguous → ask ONE clarifying question, then re-classify

Write the routing decision to `.taw/intent.json`:
```json
{
  "tier1": "MAINTAIN",
  "tier2": "test",
  "raw": "<user text>",
  "mode": "safe",
  "branch_loaded": "branches/maintain/test.md"
}
```

## Step 2 — Load + execute the branch

Load the branch file via `@`-reference (e.g. `@branches/build.md`). Execute its Steps 1..N in order. The branch file is the source of truth for its flow — this SKILL.md does not duplicate the logic.

Branch files live at:
- `branches/build.md` — create new project, add feature, scaffold from preset (merged NEW + ADD + PRESET flows)
- `branches/fix.md` — diagnose + auto-fix broken build/runtime
- `branches/ship.md` — deploy to Vercel / Docker / VPS
- `branches/maintain/security.md` — security audit (P0/P1/P2)
- `branches/maintain/test.md` — auto-gen unit/e2e/RLS tests
- `branches/maintain/upgrade.md` — bump deps (single / minor / major)
- `branches/maintain/clean.md` — remove dead code / unused deps / orphan files
- `branches/maintain/perf.md` — bundle / lighthouse / N+1 audit
- `branches/maintain/rollback.md` — revert code and/or deploy
- `branches/maintain/refactor.md` — rename / extract / split / move
- `branches/maintain/types.md` — sync Supabase/API/env types
- `branches/maintain/seed.md` — gen realistic seed data
- `branches/maintain/review.md` — local pre-push review (lint+type+test+security)
- `branches/maintain/stack-swap.md` — swap payment / db / ui / email / etc
- `branches/maintain/status.md` — project health dashboard (git + build + deploy + security + tests)
- `branches/advisor/analyze.md` — deep-read a feature, opinionated review (correctness/security/architecture/quality/UX)
- `branches/advisor/suggest.md` — propose 2-3 features based on demand evidence (3 forcing questions)
- `branches/advisor/coverage.md` — ASCII diagram of code paths + user flows + test gaps + unit-vs-E2E recommendations
- `branches/advisor/adversarial.md` — red-team the branch diff, scope-gated by diff size (skip <50 lines)
- `branches/advisor/scope-check.md` — compare intent (.taw/intent.json + PR + TODOS.md) vs diff — creep + missing

Between steps inside a branch, emit a short progress line:
```
✓ Done: <3-word summary>
```

## Step 3 — Common post-steps (apply to every branch)

After a branch completes its main work, before emitting the final "Done" message:

1. **Commit** — if the branch made code changes, invoke the `git-auto-commit` skill with the appropriate `type` (feat/fix/chore/refactor/perf/test/revert) that the branch specifies. Phase-less branches (add-feature, maintain/*) omit the `[P<n>]` tag.
2. **Update checkpoint** — write `.taw/checkpoint.json` with `{status, last_branch, last_error?, deploy_url?}` so subsequent `/taw` invocations know the state.
3. **Next-step hints** — in the final "Done" message, always suggest 2-3 relevant next commands. Always in the form `/taw <verb>`:
   - After BUILD → `/taw deploy`, `/taw <new feature description>`
   - After FIX → `/taw deploy`, `/taw review`
   - After SHIP → `/taw <new feature>`, `/taw fix` (if anything broken)
   - After MAINTAIN/* → branch-specific hints

## Step 4 — Error recovery (branch-agnostic)

If a branch reports a failure it can't handle:
1. Compact the error to ≤100 tokens.
2. Let the branch's own retry/revert logic run ONCE. If the branch escalates back here, do NOT retry again.
3. Write `.taw/checkpoint.json`:
   ```json
   {"status": "failed", "branch": "<name>", "last_error": "<compact>", "next_action": "Try /taw <suggested verb>"}
   ```
4. Emit the error template from `skills/taw/templates/error-messages.md` (translated to VN if user input was VN) with a pointer to the next action.

Never retry past the branch's own retry budget. Never silently skip failed steps.

## State files

All taw state lives in `.taw/` (gitignored):
- `.taw/intent.json` — classified intent + mode + branch loaded + clarifications
- `.taw/plan.md` — approved plan bullets (BUILD branch only)
- `.taw/checkpoint.json` — {status, last_branch, last_error?, deploy_url?}
- `.taw/design.json` — design tokens from frontend-design (BUILD branch only)
- `.taw/<branch>-session.json` — branch-specific transient state (e.g. fix-session, upgrade-snapshot, review-*.log)
- `.taw/deploy-target.txt`, `.taw/deploy-url.txt`, `.taw/vps.env` — SHIP branch artefacts

NEVER write API keys, tokens, or secrets into `.taw/` files. Redact before write.

## Stack adaptation rule (MUST follow for every branch + every loaded skill)

The default stack (Next.js + Tailwind + shadcn + Supabase + Polar) is a **suggestion for NEW projects only**. For existing projects, do the opposite: **detect what's already there and adapt**.

Before a branch or a loaded skill writes any code / runs any install, execute this detection pass:

1. **Read `package.json`** — map installed deps to categories:
   - Auth: `@supabase/supabase-js`, `@clerk/nextjs`, `next-auth`, `better-auth`, `lucia`
   - Payment: `@polar-sh/sdk`, `stripe`, `@lemonsqueezy/lemonsqueezy.js`
   - DB client: raw `@supabase/supabase-js` vs `drizzle-orm` vs `prisma` vs `@libsql/client`
   - UI: shadcn (`class-variance-authority` + `@radix-ui/*`) vs bare Radix vs Chakra vs MUI
   - Styling: `tailwindcss` vs `unocss` vs `styled-components` vs CSS modules
   - Data fetch: `@tanstack/react-query`, `swr`, `@trpc/*`
   - Email: `resend`, `@sendgrid/mail`, `postmark`, `nodemailer`
   - Analytics: `posthog-js`, `@vercel/analytics`, `plausible-tracker`
   - Error tracking: `@sentry/nextjs`, `bugsnag`, `@logtail/next`
   - Queue/Cron: `inngest`, `trigger.dev`, `@upstash/qstash`
   - Cache/Rate limit: `@upstash/ratelimit`, `ioredis`, `next-rate-limit`
   - Storage: `@supabase/storage-js`, `uploadthing`, `@aws-sdk/client-s3`
   - Testing: `vitest`, `jest`, `@playwright/test`, `cypress`

2. **Read `.env.local` / `.env.example`** (keys only, never values) — corroborate: `STRIPE_SECRET_KEY` confirms Stripe, `CLERK_SECRET_KEY` confirms Clerk, etc.

3. **Read `supabase/migrations/` or `drizzle/` or `prisma/schema.prisma`** — determine DB layer.

4. **Decide adaptation mode:**
   - **Empty project / no matching dep** → follow taw-kit default (suggest install).
   - **One alternative detected** → use that alternative throughout this branch. Load the matching skill (e.g. `stripe-checkout` instead of `payment-integration`, `clerk-auth` instead of `auth-magic-link`).
   - **Multiple alternatives in same category** (rare — e.g. both Clerk AND Supabase auth) → ask user which one is the source of truth.
   - **User explicitly requested something different** in their prose ("add auth with Clerk" even if project has Supabase) → honour the request, but warn about mixing.

5. **Never silently install a "taw-kit default" alongside an existing alternative.** Example: if project has Stripe, do NOT `npm install @polar-sh/sdk`. If project has Drizzle, do NOT rewrite queries to raw Supabase client.

This rule is **absolute** — every branch and every loaded skill must begin with this detection pass OR explicitly delegate to a skill that does. See `skills/<any-stack-skill>/SKILL.md` Step 0 for the canonical pattern.

When calling a skill via `Skill({ skill: "<name>", args: "..." })`, pass the detection summary as context so the skill doesn't repeat the detection from scratch.

## Shell compatibility rule (prevents silent bugs)

Inside Claude Code, `grep` is a shell function that wraps `ugrep` with extra flags. This wrapper has **non-POSIX exit-code semantics in pipelines** — `grep -v <pattern> >/dev/null` can return exit 0 even when output is empty, which silently corrupts boolean checks.

**Rule for every branch and every skill using bash:**
- For boolean decisions (`if grep ...; then`) → use `command grep` or `/usr/bin/grep`, NEVER bare `grep`
- For display-only output (`grep | wc -l`, `grep | head`) → bare `grep` is fine
- `git grep` is NOT affected (git has its own grep implementation) — safe to use bare
- `sed`, `awk`, `find`, `cut` — no wrappers, use normally

Example of the bug:
```bash
# BAD — may trigger even when no match found, due to wrapper
if git ls-files | grep -E 'env' | grep -v 'example' >/dev/null; then
  alert "env file committed"
fi

# GOOD — `command grep` forces POSIX behaviour
if git ls-files | command grep -E 'env' | command grep -v 'example' >/dev/null; then
  alert "env file committed"
fi
```

This rule is absolute — any new branch/skill doing security checks or state-detection with grep pipelines MUST follow it or risk false positives.

## Constraints

- **One entrypoint, one command.** The old `/taw-new`, `/taw-add`, `/taw-fix`, `/taw-deploy`, `/taw-security` skills are kept as thin shims that redirect to `/taw`. Do NOT add new top-level `/taw-*` skills — add a new branch file under `branches/` instead.
- **One approval gate per BUILD flow.** Branches MAINTAIN/* ask targeted confirmations as needed but never bundle a full project-wide approval step. FIX auto-fixes but asks before destructive actions. SHIP runs security as a blocking gate.
- **Default stack**: Next.js 14 App Router + Tailwind + shadcn/ui + Supabase + Polar. Deploy default is Vercel. Override only if user explicitly asks or the project is Expo/mobile.
- **Context budget**: if conversation grows past 150k tokens during a long branch (BUILD agent chain especially), compact via `.taw/artifacts/` on disk and summarize.
- **Empty args**: let the router emit its own "what do you want to do?" menu (see `router.md` → Empty args). Do not pre-empt it here.
- **Language consistency**: once language is detected on first interaction, keep it for the entire session unless user explicitly switches.
