---
name: stripe-checkout
description: >
  Stripe Checkout + webhook integration for Next.js App Router. Alternative to
  Polar (payment-integration skill). Detection-first: if project already has
  Stripe installed, adapts to existing setup; only new setup installs from scratch.
  Covers one-time products, subscriptions, and the webhook signature verification
  pattern that security-audit requires.
  Trigger phrases (EN + VN): "stripe", "stripe checkout", "card payment",
  "stripe webhook", "subscription billing", "thanh toan the",
  "tich hop stripe", "doi polar sang stripe".
allowed-tools: Read, Write, Edit, Bash, Grep
---

# stripe-checkout — Next.js Integration

## Step 0 — Detect existing setup

```bash
# installed?
node -e "try{require('stripe')}catch{process.exit(1)}" 2>/dev/null && echo installed || echo missing

# env keys?
grep -E 'STRIPE_SECRET_KEY|STRIPE_WEBHOOK_SECRET|NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY' .env.local .env.example 2>/dev/null

# existing checkout route?
ls app/api/checkout/ app/api/webhooks/stripe/ 2>/dev/null
```

If **installed + env present + routes exist** → read them, adapt. Don't overwrite.
If **installed but routes missing** → add only what's missing.
If **nothing** → new setup, Step 1.

**Never run side-by-side with Polar.** If project has `@polar-sh/sdk`, ask user: "Dự án đang dùng Polar. Thêm Stripe vào song song, hay đổi hẳn Polar → Stripe (dùng `/taw đổi Polar sang Stripe`)?"

## Step 1 — Install

```bash
npm install stripe
# client-side redirect (optional — server-side redirect works too):
npm install @stripe/stripe-js
```

## Step 2 — Env vars

Add to `.env.example` (anh then copy to `.env.local` with real values):
```bash
STRIPE_SECRET_KEY=sk_test_...                    # server-only, test key
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...   # client-safe
STRIPE_WEBHOOK_SECRET=whsec_...                  # from `stripe listen` or dashboard
```

Get test keys: https://dashboard.stripe.com/test/apikeys

## Step 3 — Server client

`lib/stripe.ts`:
```ts
import Stripe from 'stripe'

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-12-18.acacia',  // pin to latest major at install time
  typescript: true,
})
```

## Step 4 — One-time checkout (Server Action)

`app/actions/checkout.ts`:
```ts
'use server'
import { stripe } from '@/lib/stripe'
import { redirect } from 'next/navigation'
import { headers } from 'next/headers'

export async function createCheckoutSession(priceId: string) {
  const origin = (await headers()).get('origin') ?? 'http://localhost:3000'

  const session = await stripe.checkout.sessions.create({
    mode: 'payment',          // 'payment' | 'subscription' | 'setup'
    line_items: [{ price: priceId, quantity: 1 }],
    success_url: `${origin}/checkout/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${origin}/checkout/cancel`,
    // optional: attach user context
    // customer_email: user.email,
    // metadata: { user_id: user.id, order_id: order.id },
  })

  redirect(session.url!)
}
```

Use in a Server Component:
```tsx
<form action={async () => { 'use server'; await createCheckoutSession('price_xxx') }}>
  <button type="submit">Checkout</button>
</form>
```

## Step 5 — Subscription checkout

Same as Step 4 but:
```ts
mode: 'subscription',
line_items: [{ price: 'price_monthly_xxx', quantity: 1 }],
subscription_data: {
  trial_period_days: 14,  // optional
  metadata: { plan: 'pro' },
},
```

## Step 6 — Webhook route (CRITICAL — signature verify required)

`app/api/webhooks/stripe/route.ts`:
```ts
import { headers } from 'next/headers'
import { NextResponse } from 'next/server'
import Stripe from 'stripe'
import { stripe } from '@/lib/stripe'

export async function POST(req: Request) {
  const body = await req.text()
  const sig = (await headers()).get('stripe-signature')!

  let event: Stripe.Event
  try {
    event = stripe.webhooks.constructEvent(
      body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET!
    )
  } catch (err) {
    return NextResponse.json({ error: 'bad signature' }, { status: 400 })
  }

  switch (event.type) {
    case 'checkout.session.completed': {
      const session = event.data.object
      // mark order paid, provision access, etc.
      // await markOrderPaid(session.metadata?.order_id)
      break
    }
    case 'invoice.paid':
    case 'invoice.payment_succeeded': {
      const invoice = event.data.object
      // extend subscription period
      break
    }
    case 'customer.subscription.deleted':
    case 'customer.subscription.updated': {
      const sub = event.data.object
      // update local subscription status
      break
    }
    default:
      // noop for events you don't care about
  }

  return NextResponse.json({ received: true })
}
```

**Never skip `constructEvent`** — the security audit P0-7 fails without it. Anyone could forge a webhook call otherwise.

## Step 7 — Local webhook testing

```bash
# terminal 1 — dev server
npm run dev

# terminal 2 — stripe CLI forwards real events to localhost
stripe listen --forward-to localhost:3000/api/webhooks/stripe
# copy the printed `whsec_...` to STRIPE_WEBHOOK_SECRET in .env.local

# terminal 3 — trigger a test event
stripe trigger checkout.session.completed
```

Stripe CLI install: `brew install stripe/stripe-cli/stripe`.

## Step 8 — Prices + products

Two ways to create:
1. Dashboard: https://dashboard.stripe.com/test/products — simpler, ongoing admin use
2. Code (migrations, CI): `stripe.products.create(...)` + `stripe.prices.create(...)`

Store `price_xxx` IDs in your DB (`plans` table) or env. Never hardcode in UI.

## Step 9 — Customer portal (self-service subscription mgmt)

```ts
const portal = await stripe.billingPortal.sessions.create({
  customer: user.stripe_customer_id,
  return_url: `${origin}/account`,
})
redirect(portal.url)
```

Configure allowed actions in dashboard: Settings → Billing → Customer portal.

## Step 10 — Security checklist (for security-audit)

| Check | Pass? |
|---|---|
| `STRIPE_SECRET_KEY` never imported in `'use client'` files | grep `STRIPE_SECRET_KEY` under `app/**` — should only appear in server files |
| Webhook route has `constructEvent` | required |
| `STRIPE_WEBHOOK_SECRET` set in production env | check deploy target |
| No `NEXT_PUBLIC_STRIPE_SECRET_*` anywhere | would leak to client bundle — P0 |
| `success_url` doesn't leak session metadata to URL | use `session_id={CHECKOUT_SESSION_ID}` and look up server-side |

## Gotchas

- **"You cannot use both `customer` and `customer_email` at the same time"** → pick one. Use `customer` (existing Stripe customer) for repeat users.
- **Webhook receives duplicates** → make handler idempotent (check `event.id` against a `processed_events` table).
- **Test mode vs Live mode** → `sk_test_` and `sk_live_` keys, separate customers/prices. Environment must not mix.
- **Cents vs VND** → Stripe's `amount` is in smallest currency unit. For VND (no decimals), amount = VND number directly (e.g. 250000 = 250,000 VND). For USD, amount = cents.
- **Currency restrictions** — VND is supported; some payment methods restrict it. Check https://stripe.com/docs/currencies.

## Constraints

- Never expose `STRIPE_SECRET_KEY` to client — only use in Server Actions / Route Handlers
- Webhook signature verification is MANDATORY — missing = P0 security finding
- Pin `apiVersion` on Stripe client to avoid silent breaking changes
- Don't reimplement subscription state — Stripe is source of truth; your DB just caches
- For `subscription` mode, `success_url` must be absolute (relative URLs break)
