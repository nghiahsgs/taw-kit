---
name: payment-integration
description: >
  Integrate Polar checkout for digital products and subscriptions, plus Vietnamese
  payment fallbacks (SePay/MoMo QR). Activated by taw when payment is part of
  the product description.
argument-hint: "[polar | momo | sepay | 'full-setup']"
---

# payment-integration — Payments for Vietnamese Market

## Purpose

Wire up payment processing: Polar for international/card payments and
MoMo/SePay QR for Vietnamese bank transfers — the dominant local payment method.

## Part 1: Polar Checkout (Digital Products / Subscriptions)

### Install

```bash
npm install @polar-sh/sdk
```

### Create Checkout Session (Server Action)

```typescript
// app/actions/checkout.ts
"use server"
import { Polar } from "@polar-sh/sdk"

const polar = new Polar({ accessToken: process.env.POLAR_ACCESS_TOKEN! })

export async function createCheckoutSession(productId: string, customerEmail?: string) {
  const checkout = await polar.checkouts.create({
    productId,
    successUrl: `${process.env.NEXT_PUBLIC_APP_URL}/thanh-toan/thanh-cong`,
    customerEmail,
  })
  return { url: checkout.url }
}
```

### Checkout Button Component

```tsx
// components/buy-button.tsx
"use client"
import { createCheckoutSession } from "@/app/actions/checkout"
import { Button } from "@/components/ui/button"
import { useState } from "react"

export function BuyButton({ productId, label = "Mua ngay" }: { productId: string; label?: string }) {
  const [loading, setLoading] = useState(false)
  async function handleBuy() {
    setLoading(true)
    const { url } = await createCheckoutSession(productId)
    window.location.href = url
  }
  return (
    <Button onClick={handleBuy} disabled={loading} className="w-full bg-orange-500 hover:bg-orange-600">
      {loading ? "Dang chuyen trang..." : label}
    </Button>
  )
}
```

### Polar Webhook Handler

```typescript
// app/api/webhooks/polar/route.ts
import { NextRequest, NextResponse } from "next/server"
import { Webhooks } from "@polar-sh/sdk"

export async function POST(req: NextRequest) {
  const body = await req.text()
  const signature = req.headers.get("webhook-signature") ?? ""
  const wh = new Webhooks({ secret: process.env.POLAR_WEBHOOK_SECRET! })
  try {
    const event = wh.constructEvent(body, signature)
    if (event.type === "checkout.order_paid") {
      // Fulfill order: update Supabase, send confirmation email, etc.
      const { customerEmail, productId } = event.data
      // await fulfillOrder(customerEmail, productId)
    }
    return NextResponse.json({ received: true })
  } catch {
    return NextResponse.json({ error: "Invalid signature" }, { status: 400 })
  }
}
```

## Part 2: MoMo / SePay QR (Vietnamese Bank Transfer)

For users who prefer local bank transfer — generates a VietQR code.

```tsx
// components/vietqr-payment.tsx
interface VietQRProps {
  bankCode: string      // e.g. "MB", "VCB", "TCB"
  accountNumber: string
  accountName: string
  amountVnd: number
  description: string   // e.g. "Thanh toan don hang #123"
}

export function VietQRPayment({ bankCode, accountNumber, accountName, amountVnd, description }: VietQRProps) {
  const qrUrl = `https://img.vietqr.io/image/${bankCode}-${accountNumber}-compact2.png` +
    `?amount=${amountVnd}&addInfo=${encodeURIComponent(description)}&accountName=${encodeURIComponent(accountName)}`
  return (
    <div className="text-center space-y-3 p-4 border rounded-xl">
      <p className="font-medium">Chuyen khoan ngan hang</p>
      <img src={qrUrl} alt="QR chuyen khoan" className="mx-auto w-48 h-48" />
      <div className="text-sm text-slate-600">
        <p>Ngan hang: {bankCode}</p>
        <p>So TK: {accountNumber}</p>
        <p>Ten TK: {accountName}</p>
        <p className="font-bold text-orange-600">{amountVnd.toLocaleString('vi-VN')}d</p>
        <p>Noi dung: {description}</p>
      </div>
    </div>
  )
}
```

## Environment Variables Needed

```bash
POLAR_ACCESS_TOKEN=polar_at_...
POLAR_WEBHOOK_SECRET=whsec_...
NEXT_PUBLIC_APP_URL=https://tenwebsite.vn
```
