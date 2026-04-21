---
name: landing-page
description: Trang giới thiệu sản phẩm/dịch vụ với hero, tính năng nổi bật, và form thu thập email.
---

## Pre-filled intent

Tôi muốn tạo một trang landing page chuyên nghiệp để giới thiệu sản phẩm hoặc dịch vụ
của tôi và thu thập email khách hàng tiềm năng. Trang gồm 3 phần chính: hero nổi bật
với lời kêu gọi hành động, phần tính năng/lợi ích, và form đăng ký nhận thông tin.

## Pre-filled clarifications

```yaml
product_name: "Sản phẩm của tôi"
hero_cta: "Đăng ký ngay"
sections:
  - hero
  - features
  - email-capture-form
email_storage: supabase
payment_needed: false
auth_needed: false
language: vi
seo_needed: true
```

## Stack overrides

```yaml
skip_supabase_auth: true
skip_polar: true
supabase_tables:
  - name: leads
    columns: [email, name, created_at]
    rls: true
```

## Expected phases

- Tạo trang chủ Next.js App Router với layout hero full-width
- Xây phần tính năng dạng grid 3 cột với icon + mô tả
- Tạo form thu thập email kết nối Supabase bảng `leads`
- Cấu hình SEO meta tags, Open Graph, sitemap.xml
- Deploy lên Vercel qua Shipkit

## Success criteria

- Trang tải dưới 2 giây (Lighthouse ≥ 90)
- Form gửi email lưu thành công vào Supabase
- Hiển thị đúng trên mobile + desktop
- `npm run build` xanh không lỗi
- URL live trả về sau deploy
