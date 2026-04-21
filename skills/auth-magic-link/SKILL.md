---
name: auth-magic-link
description: >
  Implement Supabase magic-link email authentication for taw-kit projects.
  No password required — user enters email, receives a login link. Includes
  middleware-based route protection and session management.
argument-hint: "[setup | protect-route | check-session]"
---

# auth-magic-link — Passwordless Auth

## Purpose

Add email magic-link authentication to a taw-kit project using Supabase Auth.
Non-devs' users never need to remember a password — one click from email logs them in.

## Dependencies

```bash
npm install @supabase/ssr @supabase/supabase-js
```

## 1. Supabase Client Setup

```typescript
// lib/supabase/client.ts
import { createBrowserClient } from "@supabase/ssr"

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

```typescript
// lib/supabase/server.ts
import { createServerClient } from "@supabase/ssr"
import { cookies } from "next/headers"

export function createClient() {
  const cookieStore = cookies()
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies: { getAll: () => cookieStore.getAll(), setAll: (c) => c.forEach(({ name, value, options }) => cookieStore.set(name, value, options)) } }
  )
}
```

## 2. Login Form Component

```tsx
// components/login-form.tsx
"use client"
import { useState } from "react"
import { createClient } from "@/lib/supabase/client"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"

export function LoginForm() {
  const [email, setEmail] = useState("")
  const [sent, setSent] = useState(false)
  const [loading, setLoading] = useState(false)

  async function handleLogin() {
    setLoading(true)
    const supabase = createClient()
    const { error } = await supabase.auth.signInWithOtp({
      email,
      options: { emailRedirectTo: `${window.location.origin}/auth/callback` },
    })
    if (!error) setSent(true)
    setLoading(false)
  }

  if (sent) return (
    <div className="text-center p-6">
      <p className="text-lg font-medium">Kiem tra email cua ban!</p>
      <p className="text-slate-500 mt-2">Chung toi da gui link dang nhap den <strong>{email}</strong></p>
    </div>
  )

  return (
    <div className="space-y-4 max-w-sm mx-auto p-6">
      <h2 className="text-xl font-bold">Dang nhap</h2>
      <Input type="email" placeholder="ban@email.com" value={email} onChange={e => setEmail(e.target.value)} />
      <Button onClick={handleLogin} disabled={loading || !email} className="w-full">
        {loading ? "Dang gui..." : "Gui link dang nhap"}
      </Button>
    </div>
  )
}
```

## 3. Auth Callback Route

```typescript
// app/auth/callback/route.ts
import { createClient } from "@/lib/supabase/server"
import { NextRequest, NextResponse } from "next/server"

export async function GET(req: NextRequest) {
  const code = req.nextUrl.searchParams.get("code")
  if (code) {
    const supabase = createClient()
    await supabase.auth.exchangeCodeForSession(code)
  }
  return NextResponse.redirect(new URL("/dashboard", req.url))
}
```

## 4. Middleware Route Protection

```typescript
// middleware.ts
import { createServerClient } from "@supabase/ssr"
import { NextRequest, NextResponse } from "next/server"

export async function middleware(req: NextRequest) {
  const res = NextResponse.next()
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies: { getAll: () => req.cookies.getAll(), setAll: (c) => c.forEach(({ name, value, options }) => res.cookies.set(name, value, options)) } }
  )
  const { data: { user } } = await supabase.auth.getUser()
  if (!user && req.nextUrl.pathname.startsWith("/dashboard")) {
    return NextResponse.redirect(new URL("/login", req.url))
  }
  return res
}

export const config = { matcher: ["/dashboard/:path*"] }
```

## Sign Out

```typescript
const supabase = createClient()
await supabase.auth.signOut()
// redirect to /
```

## Supabase Dashboard Settings

Auth → URL Configuration:
- Site URL: `https://tenwebsite.vn`
- Redirect URLs: `https://tenwebsite.vn/auth/callback`
