# Kịch bản video taw-kit

2 kịch bản sẵn để quay YouTube / TikTok / Reels. Mỗi scene có: thời lượng, visual trên màn hình, lời dẫn. Coi lời dẫn là gợi ý — nói tự nhiên, đúng ý là được.

Phong cách đề xuất: quay màn hình thật, giọng dẫn bình tĩnh, bật caption. Không cần hiệu ứng loè loẹt. Người xem muốn thấy quá trình thật.

---

## Kịch bản A: Onboarding 5 phút

**Mục tiêu:** Ai đó vừa mua taw-kit. Xong video là họ đã cài xong và chạy lệnh đầu tiên.
**Thời lượng đích:** 5–6 phút.
**Platform:** YouTube 16:9; cắt dọc cho TikTok.

### [0:00–0:20] Hook

VISUAL: Chia đôi màn hình — trái: terminal trống; phải: 1 website quán cà phê đang live trên trình duyệt. Overlay text: "5 phút ra 1 web thật."

LỜI DẪN: "Nếu bạn vừa mua taw-kit mà chưa biết bắt đầu từ đâu, video này dành cho bạn. Trong 5 phút, mình sẽ dẫn bạn đi từ số 0 tới 1 web thật đang chạy trên internet. Không cần code. Không cần học thêm gì."

### [0:20–0:50] Chuẩn bị

VISUAL: Highlight 3 icon — app Claude Code, icon Claude Pro / icon chìa khoá API (hiện song song, có chữ "hoặc" ở giữa), app Terminal. Mỗi cái sáng xanh khi được nhắc đến.

LỜI DẪN: "Bạn cần 3 thứ. Một: Claude Code đã cài. Hai: 1 cách login Claude Code — hoặc subscription Claude Pro/Max, hoặc 1 API key Anthropic, 2 cái chọn 1. Ba: Terminal đang mở. Nếu Claude Code chưa có, tải từ trang chủ và cài như mọi app bình thường."

### [0:50–1:30] Cài taw-kit

VISUAL: Cận cảnh Terminal. Paste lệnh curl. Enter. Hiện ra "taw-kit installed successfully".

LỜI DẪN: "Bước một: cài taw-kit. Copy dòng này, paste vào Terminal, Enter. Chờ tầm 30 giây. Khi thấy 'installed successfully' là xong. Đơn giản vậy thôi."

### [1:30–2:10] Login Claude Code

VISUAL: Mở Claude Code bằng lệnh `claude`. Prompt cho 2 lựa chọn login. Host demo nhánh OAuth (nếu có Pro): trình duyệt mở, click Accept, quay lại terminal. Nếu quay kịch bản dùng API key thì paste `sk-ant-...` (che một phần).

LỜI DẪN: "Bước hai: gõ `claude` để mở Claude Code. Lần đầu nó hỏi cách login. Có Claude Pro/Max? Chọn nhánh subscription, trình duyệt mở, Accept, xong. Dùng API key? Vào console Anthropic, tạo key, copy `sk-ant-...`, paste vào đây. Lần sau nó tự nhớ."

### [2:10–3:00] Gõ /taw

VISUAL: Gõ `/taw làm cho tôi 1 website quán cà phê`. Enter. taw-kit liệt kê 5 câu hỏi.

LỜI DẪN: "Bước ba — phần vui. Gõ `/taw` rồi tả cái bạn muốn. Ví dụ, 'làm cho tôi 1 website quán cà phê'. Enter. taw-kit hỏi lại 5 câu — tên shop, có giỏ hàng không, tông màu. Trả lời theo ý. Câu nào không biết, cứ gõ 'tuỳ bạn'."

### [3:00–3:40] Duyệt plan

VISUAL: Plan 5 dòng hiện ra (stack, pages, đích deploy, ETA). Con trỏ nháy chờ.

LỜI DẪN: "Sau khi trả lời, taw-kit show 1 plan ngắn — thường 5 dòng. Đọc lướt. Ổn? Gõ `yes`. Muốn sửa? Gõ `edit`. Muốn huỷ? Gõ `cancel`. Mình gõ yes."

### [3:40–4:40] Để các nhân công AI chạy

VISUAL: Tua nhanh 15 phút thành 40 giây. Hiện từng dòng `✓ Done:`.

LỜI DẪN: "Giờ bạn chờ. taw-kit có 5 nhân công AI chạy theo thứ tự — plan, research, code, test, security review. Mỗi nhân công xong báo 1 dòng. Tổng thời gian: 15 tới 20 phút. Đi pha cà phê cũng được."

### [4:40–5:20] Lấy URL

VISUAL: Dòng cuối "Done! Open: https://your-coffee-shop.vercel.app". Click link. Trình duyệt hiện web thật; cuộn qua các page.

LỜI DẪN: "Và đây. Dòng cuối: 'Done' kèm 1 URL. Click vào. Bùm — web của bạn đang trên internet thật. Share link cho bạn bè, đăng mạng xã hội. Hosting free. Không khó như bạn nghĩ đâu."

### [5:20–5:50] Tóm tắt + next

VISUAL: Overlay 3 gạch đầu dòng: "Cài 30s — Gõ /taw — Nhận URL". End card link tới video tiếp theo "Build shop online thật trong 30 phút".

LỜI DẪN: "Tóm tắt: cài 30 giây, gõ /taw, chờ 15 phút, lấy URL. Nếu hỏng gì, file troubleshooting trong docs có các lỗi thường gặp. Video sau mình sẽ dựng nguyên 1 shop online có giỏ hàng và checkout trong 30 phút. Gặp lại."

---

## Kịch bản B: Dựng shop online thật trong 30 phút

**Mục tiêu:** Demo đầy đủ từ lệnh số 0 tới shop có giỏ hàng, checkout, URL live.
**Thời lượng đích:** 12–15 phút (tua từ 30 phút footage gốc).
**Platform:** YouTube long-form. Cắt được 2 TikTok short.

### [0:00–0:30] Hook

VISUAL: Xem nhanh kết quả cuối — shop live, giỏ hàng, checkout có QR. Overlay: "30 phút. 1 lệnh. Không code."

LỜI DẪN: "Trong video này mình dựng full 1 shop đồ handmade từ số 0. Danh sách sản phẩm, giỏ hàng, thanh toán online, trang admin để đăng sản phẩm. Tất cả trong 30 phút với 1 câu lệnh tự nhiên. Không giả, không cắt ghép mánh khoé. Nếu bạn chưa xem video onboarding 5 phút, xem cái đó trước đã."

### [0:30–1:30] Chuẩn bị

VISUAL: Mở Claude Code. Dashboard Supabase ở tab bên (URL + anon key sẵn để copy).

LỜI DẪN: "Trước khi bắt đầu, mình setup Supabase — dịch vụ database free để lưu sản phẩm, đơn hàng, tài khoản. Đăng ký ở supabase.com, tạo project, copy URL + anon key. Bỏ qua bước này nếu bạn chỉ làm landing page."

### [1:30–2:30] Gõ /taw với mô tả chi tiết

VISUAL: Gõ lệnh dài: `/taw dựng cho tôi 1 shop handmade có danh sách sản phẩm, giỏ hàng, checkout Polar, và trang admin`. Enter.

LỜI DẪN: "Giờ mình gõ /taw và tả chi tiết. Để ý mình tả cụ thể: shop handmade, danh sách sản phẩm, giỏ hàng, checkout Polar, trang admin. Input càng cụ thể, output càng chính xác."

### [2:30–4:30] Hỏi lại + trả lời

VISUAL: taw-kit hỏi 5 câu (tên shop, logo, màu, số sản phẩm ban đầu, có login không). Trả lời từng câu.

LỜI DẪN: "taw-kit hỏi 5 câu. Tên shop: 'Handmade Linh'. Logo: 'chọn font sạch và 1 icon'. Màu: beige và nâu nhạt. Sản phẩm mẫu: 8. Cho khách login bằng Google. Xong, Enter."

### [4:30–5:30] Duyệt plan

VISUAL: Plan 5 gạch đầu dòng hiện ra. Cuộn qua từng gạch. Gõ `yes`.

LỜI DẪN: "Plan đã ổn: Next.js với Tailwind và Supabase, 4 page chính, tích hợp Polar, deploy Vercel, ETA 25 phút. Đúng ý. yes."

### [5:30–7:00] Planner + Researcher

VISUAL: Tua nhanh. `✓ Done: detailed plan ready`, rồi `✓ Done: Supabase + Polar docs fetched` (2 researcher chạy song song).

LỜI DẪN: "Nhân công đầu là planner, chia plan tổng thành 6 phase nhỏ. Tiếp đó, 2 researcher chạy song song — 1 lấy docs Supabase, 1 lấy docs Polar, để call API đúng. Mất tầm 3 phút."

### [7:00–10:00] Fullstack-dev viết code

VISUAL: Pane trái hiện file được sinh nhanh (auto-scroll). Pane phải hiện % tiến độ. Tua 4x.

LỜI DẪN: "Tiếp là fullstack-dev, nhân công quan trọng nhất. Nó scaffold Next.js, tạo 4 page, viết component giỏ hàng, gắn Supabase cho database, tích hợp Polar cho checkout. Đồng thời chạy npm install và log từng bước. Tầm 8–12 phút. Mình tua."

### [10:00–11:30] Tester + Reviewer

VISUAL: `✓ Done: build tested`, rồi `✓ Done: security reviewed`. Checklist xanh bên cạnh.

LỜI DẪN: "2 nhân công cuối chạy nhanh. Tester chạy build và smoke test để chắc không crash. Reviewer quét các vấn đề bảo mật — có key lộ không, có pattern nguy hiểm không. Tổng tầm 2 phút."

### [11:30–13:00] Deploy

VISUAL: "Deploying to Vercel..." rồi "Done! https://handmade-linh.vercel.app". Click link. Trình duyệt mở.

LỜI DẪN: "Bước cuối: deploy. taw-kit đẩy lên Vercel qua CLI chính thức. 1–2 phút, nó trả về URL thật. Click. Đây rồi — Handmade Linh đã live trên internet."

### [13:00–14:30] Đi qua shop thật

VISUAL: Cuộn homepage; xem 8 sản phẩm mẫu; click 1 sản phẩm; thêm vào giỏ; mở giỏ; click checkout; QR hiện ra. Chuyển sang tab admin, login bằng Google, đăng thêm 1 sản phẩm.

LỜI DẪN: "Đây là homepage — banner, menu, 8 sản phẩm taw-kit seed sẵn. Click 1 sản phẩm, trang chi tiết hiện. Thêm vào giỏ. Mở giỏ, click checkout. Flow Polar checkout thật — scan QR là tính tiền thật (mình không scan đâu). Sang tab admin, login Google, thêm sản phẩm mới. Frontend update ngay lập tức."

### [14:30–15:00] Tóm tắt + next

VISUAL: Overlay timer 30:00. 3 gạch: "1 lệnh — 30 phút — Shop live thật." Link tới video tiếp theo "Khi hỏng: dùng /taw-fix".

LỜI DẪN: "Tóm tắt: 1 lệnh, 30 phút, shop live thật. Muốn thêm tính năng? `/taw-add`. Muốn fix gì? `/taw-fix`. Video sau mình nói về taw-fix — vì sớm muộn gì bạn cũng cần. Subscribe để không bỏ lỡ."

---

## Ghi chú sản xuất

- **Giọng:** Nói chậm, rõ, như dạy em út. Tránh kiểu hype-bro. User mới dễ panic khi quá nhanh.
- **Tốc độ gõ:** Đừng tua đoạn gõ lệnh đầu — người xem cần theo. Chỉ tua lúc nhân công đang chạy.
- **Caption:** Bắt buộc. Chữ đen nền trắng, đọc được khi tắt tiếng.
- **Branding:** Logo taw-kit góc dưới trái suốt video. Kết thúc bằng CTA card link tới trang mua.
- **Thumbnail:** Chữ đậm kiểu "Trong 5 phút" hay "Shop thật 30 phút". Bỏ mấy mũi tên đỏ và mặt shock — nhàm rồi.
