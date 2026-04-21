---
name: shop-online
description: Online store with product list, cart, and checkout via Polar + COD.
---

## Pre-filled intent

I want an online store to sell physical or digital products. The store needs a
product list page, a product detail page, a cart, and a checkout that supports
Polar (international cards) and COD (cash on delivery). Product management goes
through the Supabase dashboard.

## Pre-filled clarifications

```yaml
product_type: "physical"
product_count_range: "1-50"
payment_methods:
  - polar
  - cod
cart_type: client-side
auth_needed: false
admin_needed: true
shipping_needed: true
language: en
```

## Stack overrides

```yaml
supabase_tables:
  - name: products
    columns: [id, name, description, price, image_url, stock, created_at]
    rls: true
  - name: orders
    columns: [id, customer_name, phone, address, items_json, total, payment_method, status, created_at]
    rls: false
polar_product_type: one-time
```

## Expected phases

- Product list page pulls from Supabase with filter + search
- Product detail page with image, description, add-to-cart button
- Client-side cart (localStorage) with order summary
- Checkout page: shipping form + Polar or COD choice
- Simple admin page: view + update order status

## Success criteria

- Add product to cart and check out successfully in Polar test mode
- COD orders save to Supabase `orders` table
- Product page renders correctly on mobile
- Admin can see the latest orders
- `npm run build` exits 0 cleanly
