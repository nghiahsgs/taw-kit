---
name: nextjs-app-router
description: >
  Next.js 14 App Router conventions for taw-kit projects. Covers file-based
  routing, layouts, Server Components, Client Components, API route handlers,
  and middleware. Reference for fullstack-dev agent during code generation.
argument-hint: "[route-pattern hoac component-type]"
---

# nextjs-app-router — Routing & Conventions

## File Conventions

```
app/
├── layout.tsx          # Root layout (HTML shell, providers)
├── page.tsx            # Home page → /
├── globals.css         # Global styles
├── (marketing)/        # Route group — no URL segment
│   ├── layout.tsx      # Shared marketing layout
│   └── about/page.tsx  # → /about
├── shop/
│   ├── page.tsx        # → /shop
│   └── [id]/page.tsx   # → /shop/123 (dynamic)
├── dashboard/
│   ├── layout.tsx      # Dashboard shell with sidebar
│   └── page.tsx        # → /dashboard
└── api/
    └── webhook/route.ts # POST /api/webhook
```

## Server vs Client Components

**Server Component (default — no `"use client"`):**
```tsx
// app/products/page.tsx
import { createClient } from "@/lib/supabase/server"

export default async function ProductsPage() {
  const supabase = createClient()
  const { data: products } = await supabase.from("products").select("*")
  return <ul>{products?.map(p => <li key={p.id}>{p.name}</li>)}</ul>
}
```

**Client Component (interactivity):**
```tsx
"use client"
import { useState } from "react"

export function AddToCart({ productId }: { productId: string }) {
  const [count, setCount] = useState(0)
  return <button onClick={() => setCount(c => c + 1)}>Them vao gio ({count})</button>
}
```

## API Route Handler

```typescript
// app/api/orders/route.ts
import { NextRequest, NextResponse } from "next/server"

export async function POST(req: NextRequest) {
  const body = await req.json()
  // process order...
  return NextResponse.json({ success: true }, { status: 201 })
}
```

## Metadata (SEO)

```tsx
// app/layout.tsx
import type { Metadata } from "next"

export const metadata: Metadata = {
  title: "Ten cua hang | Mua sam truc tuyen",
  description: "Mo ta ngan gon cho Google",
  openGraph: { title: "...", images: ["/og.jpg"] },
}
```

## Loading & Error States

```
app/shop/
├── page.tsx
├── loading.tsx   # Shown while page.tsx suspends
└── error.tsx     # "use client" — catches runtime errors
```

## Supabase Client Helpers

```
lib/supabase/
├── client.ts     # createBrowserClient() — for Client Components
└── server.ts     # createServerClient() — for Server Components & route handlers
```

## Key Rules

- Never import `"use client"` components directly into Server Components without a wrapper.
- `fetch()` in Server Components is auto-cached; add `{ cache: "no-store" }` for dynamic data.
- Dynamic routes use `params: { id: string }` prop, not `useParams()` in Server Components.
- Middleware lives at `middleware.ts` in project root (not inside `app/`).
