---
name: shop-online
description: Cửa hàng online với danh sách sản phẩm, giỏ hàng, thanh toán Polar và COD.
---

## Pre-filled intent

Tôi muốn xây một cửa hàng online để bán sản phẩm vật lý hoặc số. Cửa hàng cần có trang
danh sách sản phẩm, trang chi tiết sản phẩm, giỏ hàng, và trang thanh toán hỗ trợ Polar
(thẻ quốc tế) và COD (thanh toán khi nhận hàng). Quản trị sản phẩm qua Supabase dashboard.

## Pre-filled clarifications

```yaml
product_type: "vật lý"
product_count_range: "1-50"
payment_methods:
  - polar
  - cod
cart_type: client-side
auth_needed: false
admin_needed: true
shipping_needed: true
language: vi
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

- Trang danh sách sản phẩm lấy từ Supabase với filter + search
- Trang chi tiết sản phẩm với ảnh, mô tả, nút thêm vào giỏ
- Giỏ hàng client-side (localStorage) với tóm tắt đơn hàng
- Trang checkout: form thông tin giao hàng + chọn Polar hoặc COD
- Trang admin đơn giản: xem + cập nhật trạng thái đơn hàng

## Success criteria

- Thêm sản phẩm vào giỏ và checkout thành công với Polar test mode
- Đơn COD lưu vào Supabase bảng `orders`
- Trang sản phẩm render đúng trên mobile
- Admin có thể xem đơn hàng mới nhất
- `npm run build` xanh không lỗi
