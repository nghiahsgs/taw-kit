---
name: crm
description: Quản lý danh sách khách hàng với nhập liệu CSV, thêm thủ công, và trang chi tiết.
---

## Pre-filled intent

Tôi cần một ứng dụng CRM đơn giản để quản lý danh sách khách hàng và leads. Cần có trang
danh sách khách hàng với tìm kiếm và lọc, trang chi tiết từng khách, khả năng thêm khách
thủ công qua form, và nhập hàng loạt qua file CSV. Dữ liệu lưu trong Supabase với quyền
truy cập được bảo vệ bằng đăng nhập.

## Pre-filled clarifications

```yaml
fields:
  - name
  - email
  - phone
  - company
  - status
  - notes
  - created_at
auth_needed: true
auth_method: magic-link
csv_import: true
export_needed: true
notes_per_customer: true
language: vi
```

## Stack overrides

```yaml
supabase_auth: magic-link
supabase_tables:
  - name: customers
    columns: [id, name, email, phone, company, status, notes, owner_id, created_at]
    rls: true
    rls_policy: "owner_id = auth.uid()"
  - name: activities
    columns: [id, customer_id, note, created_by, created_at]
    rls: true
skip_polar: true
```

## Expected phases

- Auth với Supabase magic link (email OTP, không cần mật khẩu)
- Trang danh sách khách: bảng + search + lọc theo trạng thái
- Trang chi tiết khách: thông tin + lịch sử tương tác + ghi chú
- Form thêm khách mới (thủ công) + validate email/phone
- Nhập CSV: upload file, parse, preview, xác nhận trước khi lưu

## Success criteria

- Đăng nhập magic link hoạt động, chỉ thấy khách của mình (RLS)
- Import 50 dòng CSV thành công không lỗi
- Tìm kiếm khách theo tên/email phản hồi dưới 300ms
- Export danh sách ra CSV
- `npm run build` xanh không lỗi
