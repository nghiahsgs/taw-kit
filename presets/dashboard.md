---
name: dashboard
description: Bảng điều khiển KPI với cards số liệu, biểu đồ, và dữ liệu từ Supabase. Yêu cầu đăng nhập.
---

## Pre-filled intent

Tôi cần một dashboard quản trị để theo dõi các chỉ số kinh doanh quan trọng. Dashboard
cần có các thẻ KPI (doanh thu, số đơn hàng, khách mới), biểu đồ đường và cột theo thời
gian, bảng dữ liệu chi tiết, tất cả lấy từ Supabase. Chỉ người có tài khoản mới vào được.

## Pre-filled clarifications

```yaml
kpi_cards:
  - total_revenue
  - order_count
  - new_customers
  - conversion_rate
chart_types:
  - line (doanh thu theo ngày)
  - bar (đơn hàng theo tuần)
date_filter: last-30-days
auth_needed: true
auth_method: magic-link
data_source: supabase
refresh_interval: manual
language: vi
```

## Stack overrides

```yaml
supabase_auth: magic-link
chart_library: recharts
supabase_tables:
  - name: metrics_daily
    columns: [date, revenue, orders, new_customers]
    rls: true
  - name: events
    columns: [id, type, value, metadata, created_at]
    rls: true
skip_polar: true
```

## Expected phases

- Auth gate: Supabase magic link, redirect unauthenticated users to login
- Layout: sidebar navigation + header với user info + logout
- KPI cards: 4 thẻ số liệu với so sánh kỳ trước (% thay đổi)
- Biểu đồ: line chart doanh thu + bar chart đơn hàng dùng Recharts
- Bảng chi tiết: 20 sự kiện gần nhất với phân trang

## Success criteria

- Route `/dashboard` redirect về `/login` nếu chưa đăng nhập
- KPI cards tải dữ liệu thực từ Supabase trong dưới 1 giây
- Biểu đồ render đúng với dữ liệu mẫu seed sẵn
- Filter ngày thay đổi dữ liệu tất cả charts + cards
- `npm run build` xanh không lỗi
