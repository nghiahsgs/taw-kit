# maintain: stack-swap

Swap a library or service for an alternative — Supabase ↔ Drizzle, Polar ↔ Stripe, shadcn ↔ Radix, Tailwind ↔ UnoCSS, etc. Heavy surgery — always branch + snapshot + verify + easy revert.

**Prereq:** router classified `tier2 = stack-swap`.

## Step 1 — Identify the swap

Parse args:

| User said | from → to |
|---|---|
| "đổi Polar sang Stripe" | Polar → Stripe |
| "chuyển Supabase → Drizzle" | Supabase → Drizzle (keeps Postgres) |
| "bỏ shadcn dùng Radix" | shadcn/ui → Radix + custom styling |
| "đổi Next → Remix" | (REFUSE — too big, suggest new project) |

Supported swaps (currently):
- **Payment**: Polar ↔ Stripe
- **DB client**: raw Supabase ↔ Drizzle ORM (Postgres backend unchanged)
- **Auth**: Supabase Auth ↔ NextAuth ↔ Clerk
- **UI**: shadcn/ui ↔ Radix primitives
- **Styling**: Tailwind ↔ UnoCSS
- **Email**: Resend ↔ Postmark ↔ SendGrid
- **Analytics**: PostHog ↔ Plausible ↔ Umami
- **Deploy**: Vercel ↔ Fly.io ↔ Railway (config only)

Refuse (too invasive — suggest fresh project):
- Next.js ↔ Remix / SvelteKit / Nuxt
- React ↔ Vue / Solid
- TypeScript ↔ JavaScript (reverse direction)

## Step 2 — Preflight

```bash
git status --porcelain
```
Dirty → "Commit hoặc stash trước." Stop.

Create swap branch:
```bash
git checkout -b swap/<from>-to-<to>
git rev-parse HEAD > .taw/swap-sha.txt
```

## Step 3 — Impact estimate

For swap X→Y, grep for X usages:
```bash
# example: Polar → Stripe
grep -rln '@polar-sh\|polar\.' app/ components/ lib/ | wc -l
```

Render (VN):
```
Swap: Polar → Stripe

Phạm vi ảnh hưởng:
  - 8 file đang dùng Polar
  - 2 webhook routes
  - 1 checkout page
  - 3 env var cần đổi
  - Độ khó: TRUNG BÌNH
  - Thời gian ước tính: 15-25 phút

Tiếp tục? (y/n)
```

## Step 4 — Execute swap

Use pre-written swap recipes. Each is a fullstack-dev task with explicit steps.

### Recipe: Polar → Stripe

```
Task: Swap payment provider from Polar to Stripe.
Steps:
  1. npm uninstall @polar-sh/sdk && npm install stripe
  2. Move env: POLAR_ACCESS_TOKEN → STRIPE_SECRET_KEY in .env.example
  3. Rewrite lib/polar.ts → lib/stripe.ts with Stripe client init
  4. For each file importing @polar-sh/sdk:
     - Replace Polar checkout creation with stripe.checkout.sessions.create()
     - Replace Polar webhook verify with stripe.webhooks.constructEvent()
     - Map Polar product → Stripe price mapping
  5. Update supabase/migrations/ if there's a polar_customer_id column → rename to stripe_customer_id (migration)
  6. Rewrite app/api/webhooks/polar/route.ts → app/api/webhooks/stripe/route.ts with event.type switch for checkout.session.completed, invoice.paid, customer.subscription.deleted
End: npm run build. Report diff stats.
```

### Recipe: Supabase → Drizzle (same Postgres backend)

```
Task: Move from raw @supabase/supabase-js to Drizzle ORM.
Keep: Postgres database (Supabase-hosted), auth (keep Supabase Auth).
Change: query layer only.
Steps:
  1. npm install drizzle-orm postgres && npm install -D drizzle-kit
  2. Create drizzle.config.ts pointing to Supabase DB url
  3. Run `npx drizzle-kit introspect` → gen schema.ts from existing tables
  4. Replace each `supabase.from('X').select()` → `db.select().from(schema.X)`
     (preserve semantics: .eq, .in, .range, .single)
  5. Keep `supabase.auth.*` calls AS-IS
  6. Service role key still used for admin queries
End: npm run build. Verify a sample query returns same shape.
```

### Recipe: shadcn/ui → Radix primitives

```
Task: Remove shadcn/ui components, use bare Radix primitives with Tailwind.
Steps:
  1. npm uninstall @shadcn/ui (if listed; shadcn is usually copy-paste)
  2. For each components/ui/* file (Button, Card, Dialog, ...):
     - Keep Radix imports
     - Remove CVA (class-variance-authority) if only shadcn used it
     - Simplify variants: keep default + 1-2 custom, drop the rest
  3. If tailwind.config has shadcn colour tokens (hsl(var(--primary))), decide: keep CSS vars (recommended) or replace with flat Tailwind colours
  4. Don't touch page-level components — only the primitives layer
End: npm run build. Visual smoke test (npm run dev + open /).
```

### Recipe: Vercel → Fly.io

```
Task: Switch deploy target from Vercel to Fly.io.
Steps:
  1. Install flyctl: brew install flyctl (ask user)
  2. Generate fly.toml with app name, internal_port 3000, auto-stop/start
  3. Generate Dockerfile (Next.js standalone output)
  4. Add output: 'standalone' to next.config.js
  5. fly launch --no-deploy (creates app)
  6. fly secrets set NEXT_PUBLIC_SUPABASE_URL=... (from .env.local)
  7. Update .taw/deploy-target.txt from 'vercel' to 'fly'
End: fly deploy --dry-run (verify, don't actually deploy).
```

(Add more recipes inline as needed — keep each under 30 lines of spec.)

## Step 5 — Verify

```bash
npx tsc --noEmit
npm run build
npm test 2>/dev/null
```

All green → Step 6.
Any red → show lib-specific migration doc (via `docs-seeker` skill) + offer:
  1. fix manual (pause, let user fix)
  2. revert (back to pre-swap)
  3. continue (force-keep, accept breakage)

## Step 6 — Decision

```
Swap xong:
  ✓ 8 file rewritten
  ✓ Build xanh
  ✓ Tests pass

Chọn:
  1. keep  — merge về main
  2. test thêm — deploy lên preview trước
  3. revert — quay lại Polar
```

`keep` →
```bash
git checkout main
git merge swap/<from>-to-<to>
git branch -d swap/<from>-to-<to>
```

`revert` →
```bash
git checkout main
git branch -D swap/<from>-to-<to>
```

## Step 7 — Done + follow-ups

```
✓ Stack swap xong.
  Payment: Polar → Stripe

Bước tiếp:
  - Update env trên Vercel/VPS: STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET
  - Test webhook với `stripe listen --forward-to localhost:3000/api/webhooks/stripe`
  - Cập nhật tài liệu nội bộ nếu có
```

## Constraints

- ALWAYS work on a branch (`swap/<from>-to-<to>`) — never on main
- NEVER delete old library code until new one is verified green
- For DB swaps (Supabase ↔ Drizzle), NEVER run `DROP TABLE` or destructive migrations — this branch changes query layer only
- Refuse "swap framework" (Next→Remix etc) — too invasive, suggest new project
- If user's swap isn't in the recipe list, ask: "Em chưa có recipe cho swap này. Anh có hướng dẫn cụ thể không?" — don't improvise
- Always run `@branches/maintain/test.md` after a swap if tests exist
