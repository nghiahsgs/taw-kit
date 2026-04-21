---
name: seo-basic
description: >
  Add essential SEO to taw-kit projects: meta tags, Open Graph, sitemap.xml,
  robots.txt, and structured data. Optimised for Vietnamese content and Google
  search in Vietnam market.
argument-hint: "[page-name hoac 'full-setup']"
---

# seo-basic — SEO Essentials

## Purpose

Add the minimum SEO needed for a taw-kit project to rank on Google Vietnam
and share correctly on Facebook/Zalo. Covers static and dynamic metadata.

## Static Metadata (app/layout.tsx)

```tsx
import type { Metadata } from "next"

export const metadata: Metadata = {
  metadataBase: new URL("https://tenwebsite.vn"),
  title: {
    default: "Ten Cua Hang | Mua sam truc tuyen",
    template: "%s | Ten Cua Hang",
  },
  description: "Mo ta ngan gon 150-160 ky tu — hien thi tren Google.",
  keywords: ["san pham", "mua online", "giao hang toan quoc"],
  authors: [{ name: "Ten Cua Hang" }],
  openGraph: {
    title: "Ten Cua Hang | Mua sam truc tuyen",
    description: "Mo ta cho Facebook/Zalo khi chia se link",
    url: "https://tenwebsite.vn",
    siteName: "Ten Cua Hang",
    images: [{ url: "/og-image.jpg", width: 1200, height: 630, alt: "Ten Cua Hang" }],
    locale: "vi_VN",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Ten Cua Hang",
    images: ["/og-image.jpg"],
  },
  robots: { index: true, follow: true },
  alternates: { canonical: "https://tenwebsite.vn" },
}
```

## Dynamic Metadata (per page)

```tsx
// app/products/[id]/page.tsx
export async function generateMetadata({ params }: { params: { id: string } }): Promise<Metadata> {
  const product = await getProduct(params.id)
  return {
    title: product.name,
    description: product.description?.slice(0, 155),
    openGraph: { images: [product.image_url] },
  }
}
```

## Sitemap (app/sitemap.ts)

```typescript
import { MetadataRoute } from "next"

export default function sitemap(): MetadataRoute.Sitemap {
  return [
    { url: "https://tenwebsite.vn", lastModified: new Date(), changeFrequency: "daily", priority: 1 },
    { url: "https://tenwebsite.vn/shop", lastModified: new Date(), changeFrequency: "daily", priority: 0.8 },
    { url: "https://tenwebsite.vn/lien-he", lastModified: new Date(), changeFrequency: "monthly", priority: 0.5 },
  ]
}
```
Sitemap auto-served at `/sitemap.xml`.

## robots.txt (app/robots.ts)

```typescript
import { MetadataRoute } from "next"

export default function robots(): MetadataRoute.Robots {
  return {
    rules: { userAgent: "*", allow: "/", disallow: ["/api/", "/dashboard/"] },
    sitemap: "https://tenwebsite.vn/sitemap.xml",
  }
}
```

## Product Structured Data (JSON-LD)

```tsx
// In product page component
const jsonLd = {
  "@context": "https://schema.org",
  "@type": "Product",
  name: product.name,
  description: product.description,
  image: product.image_url,
  offers: {
    "@type": "Offer",
    priceCurrency: "VND",
    price: product.price_vnd,
    availability: "https://schema.org/InStock",
  },
}

return (
  <>
    <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />
    {/* page content */}
  </>
)
```

## OG Image

Place `public/og-image.jpg` at 1200×630px. Use Vietnamese headline text on image
for better CTR when shared on Facebook groups and Zalo.
