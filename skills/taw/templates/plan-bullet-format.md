# Plan Bullet Format (Vietnamese)

Load during Step 3 of `/taw`. Render exactly 3–5 bullets in Vietnamese, covering the dimensions below.

## Format

```
Kế hoạch:
1. <Stack> — <1 dòng mô tả>
2. <Pages/Features> — <liệt kê 3–5 item>
3. <Data/Integrations> — <DB tables + tích hợp>
4. <Deploy> — <target + URL pattern>
5. <Ước tính thời gian> — <phút>
```

## Rules

- Bullets numbered 1–5 only. Không dùng dấu `-` hay `•`.
- Mỗi dòng ≤ 90 ký tự.
- Không emoji trong bullets (chỉ dùng ở Step 8 "Xong!").
- Dùng từ tiếng Việt cho user-facing; tên framework giữ tiếng Anh (Next.js, Supabase, v.v.).

## Examples

**Landing page bán khóa học:**
```
Kế hoạch:
1. Next.js + Tailwind + shadcn/ui (stack gọn, dễ sửa)
2. 3 section: hero + tính năng + form thu email
3. Supabase lưu email leads (bảng `leads`)
4. Deploy Vercel qua Shipkit, URL dạng <slug>.vercel.app
5. Ước tính 10–15 phút
```

**Shop online cà phê:**
```
Kế hoạch:
1. Next.js + Tailwind + Supabase + Polar
2. 4 trang: trang chủ, menu, giỏ hàng, cảm ơn
3. Bảng `products` (6 mẫu), `orders`, `customers`
4. Thanh toán Polar card + COD, deploy Vercel
5. Ước tính 18–22 phút
```

**CRM quản lý khách shop mỹ phẩm:**
```
Kế hoạch:
1. Next.js + Tailwind + shadcn + Supabase auth
2. 2 trang: danh sách khách, chi tiết khách
3. Bảng `customers` (tên, SĐT, email, ghi chú, tag, status)
4. Import CSV + nhập tay, deploy Vercel
5. Ước tính 12–15 phút
```

## Anti-patterns (do NOT do)

- KHÔNG liệt kê công nghệ từng cái (vd: "dùng useState + useEffect...") — user không cần biết.
- KHÔNG promise tính năng chưa confirm (vd: "có dark mode" nếu user không hỏi).
- KHÔNG bỏ sót "Ước tính thời gian" — user cần biết để chờ.
