---
name: tiktok-shop-embed
description: >
  Embed TikTok Shop product cards and affiliate links into taw-kit Next.js pages.
  Supports product widget, video embed, and shop affiliate link generation.
  For Vietnamese sellers who also sell on TikTok Shop.
argument-hint: "[product-id hoac shop-url]"
---

# tiktok-shop-embed — TikTok Shop Integration

## Purpose

Let Vietnamese sellers display their TikTok Shop products on their website
without leaving TikTok's ecosystem. Drives cross-traffic between website and shop.

## Embed Methods

### Method 1: TikTok Product Widget (iframe)

TikTok Shop provides an embeddable product card via their seller center.

```tsx
// components/tiktok-product-card.tsx
"use client"

interface TikTokProductCardProps {
  productId: string
  shopRegion?: string // default: "VN"
}

export function TikTokProductCard({ productId, shopRegion = "VN" }: TikTokProductCardProps) {
  return (
    <div className="rounded-xl overflow-hidden border border-slate-200 shadow-sm">
      <iframe
        src={`https://www.tiktok.com/embed/product/${productId}?region=${shopRegion}`}
        className="w-full h-[500px]"
        allowFullScreen
        loading="lazy"
        title="San pham TikTok Shop"
      />
    </div>
  )
}
```

### Method 2: Affiliate Link Button

```tsx
interface TikTokShopLinkProps {
  affiliateUrl: string
  productName: string
  priceVnd: number
}

export function TikTokShopLink({ affiliateUrl, productName, priceVnd }: TikTokShopLinkProps) {
  return (
    <a
      href={affiliateUrl}
      target="_blank"
      rel="noopener noreferrer"
      className="flex items-center gap-3 p-3 rounded-lg bg-[#FE2C55] text-white hover:bg-[#e0264b] transition-colors"
    >
      <span className="font-medium">Mua tren TikTok Shop</span>
      <span className="ml-auto font-bold">{priceVnd.toLocaleString('vi-VN')}d</span>
    </a>
  )
}
```

### Method 3: TikTok Video Embed (product demo)

```tsx
export function TikTokVideo({ videoId }: { videoId: string }) {
  return (
    <blockquote
      className="tiktok-embed rounded-xl overflow-hidden"
      cite={`https://www.tiktok.com/@shop/video/${videoId}`}
      data-video-id={videoId}
    >
      <section />
    </blockquote>
  )
}
```

Add to `app/layout.tsx`:
```tsx
<Script src="https://www.tiktok.com/embed.js" strategy="lazyOnload" />
```

## Usage in a Page

```tsx
import { TikTokProductCard } from "@/components/tiktok-product-card"
import { TikTokShopLink } from "@/components/tiktok-product-card"

export default function ProductPage() {
  return (
    <div className="max-w-md mx-auto p-4 space-y-4">
      <TikTokProductCard productId="1234567890" />
      <TikTokShopLink
        affiliateUrl="https://s.tiktok.com/abc123"
        productName="Giay sneaker nam"
        priceVnd={450000}
      />
    </div>
  )
}
```

## Finding Your Product ID

1. Go to TikTok Shop Seller Center
2. Products → select product → copy ID from URL
3. Or use affiliate link generator in Creator tools
