# Clarify Questions Bank (Vietnamese)

Load this file during Step 2 of `/taw`. Pick 3–5 questions matching the classified intent. Skip any question the user already answered in their initial prompt.

Every question has a sensible DEFAULT — if user says "skip" or gives a non-answer, apply the default.

---

## For all intents (pick 1–2)

**Q1. Tên dự án là gì?**
- Default: sinh từ mô tả (slug hóa bằng tiếng Anh, vd: "coffee-shop-hanoi")

**Q2. Bạn đã có domain riêng chưa?**
- Default: dùng domain subdomain Vercel miễn phí (`<slug>.vercel.app`)

**Q3. Có cần đăng nhập (login) không?**
- Default: không. Nếu có → dùng Supabase magic-link (gửi qua email)

---

## landing-page (pick 2–3)

**Q4. Mục tiêu chính của trang là gì?**
- Options: thu email lead / bán khóa học / giới thiệu dịch vụ / ra mắt sản phẩm
- Default: thu email lead

**Q5. Có muốn form thu lead không? Gửi về đâu?**
- Default: có form, lưu vào Supabase + gửi email xác nhận

**Q6. Có phần bán hàng không (giá, nút mua)?**
- Default: không

---

## shop-online (pick 3–4)

**Q7. Bán sản phẩm gì? Bao nhiêu mặt hàng dự kiến?**
- Default: mô phỏng 6 sản phẩm mẫu; user tự thêm sau

**Q8. Thanh toán qua đâu?**
- Options: Polar (card quốc tế) / MoMo / Chuyển khoản bank / COD
- Default: Polar + COD fallback

**Q9. Có cần quản lý tồn kho không?**
- Default: không (MVP); trường `stock` trong DB nhưng UI không hiện cảnh báo

**Q10. Có ship hàng không? Tính phí ship thế nào?**
- Default: flat fee 30k cho toàn quốc; user có thể sửa sau

---

## crm (pick 3–4)

**Q11. Ai là người dùng (1 chủ shop / team nhiều người)?**
- Default: 1 chủ shop, không cần phân quyền phức tạp

**Q12. Nguồn khách hàng đến từ đâu?**
- Options: nhập tay / import CSV / tự động từ form web
- Default: nhập tay + import CSV

**Q13. Cần theo dõi gì cho mỗi khách?**
- Default: tên, SĐT, email, ghi chú, tag, trạng thái (new/qualified/won/lost)

**Q14. Có cần nhắc nhở follow-up không?**
- Default: không (phase 2); chỉ hiện trường `next_contact_date`

---

## blog (pick 2–3)

**Q15. Có bao nhiêu tác giả viết bài?**
- Default: 1 tác giả

**Q16. Bài viết lưu ở đâu?**
- Options: Markdown trong repo / Supabase / Notion API
- Default: Markdown trong repo (đơn giản nhất)

**Q17. Có cần comment không?**
- Default: không (giảm spam); có thể bật Giscus sau

---

## dashboard (pick 3)

**Q18. Dashboard hiển thị số liệu gì?**
- Default: doanh thu hôm nay / đơn hàng hôm nay / khách mới / top sản phẩm

**Q19. Nguồn dữ liệu từ đâu?**
- Options: Supabase / Google Sheets / import tay
- Default: Supabase

**Q20. Có cần xuất báo cáo (PDF/Excel) không?**
- Default: không (phase 2)

---

## Deploy (all intents, 1 question)

**Q21. Deploy lên đâu khi xong?**
- Options: Vercel (mặc định) / Shipkit MCP / tự deploy sau
- Default: Vercel qua Shipkit MCP nếu có, fallback `vercel --prod`
