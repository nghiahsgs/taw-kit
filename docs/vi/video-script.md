# Kịch bản video taw-kit

Hai kịch bản sẵn để quay YouTube / TikTok / Facebook Reels. Mỗi cảnh có: thời gian, gợi ý hình ảnh trên màn hình, lời thoại tiếng Việt. Người dẫn nói tự nhiên, không cần đọc nguyên văn — cứ bám ý chính.

Phong cách khuyên dùng: quay màn hình thật, giọng thuyết minh chậm rãi, có phụ đề tiếng Việt. Không cần hiệu ứng lòe loẹt. Người xem muốn thấy quy trình thật.

---

## Script A: Onboarding 5 phút

**Mục tiêu:** Người xem mới mua taw-kit. Xem xong biết cài đặt và chạy lệnh đầu tiên.
**Độ dài mục tiêu:** 5–6 phút.
**Nền tảng:** YouTube (tỷ lệ 16:9) hoặc bản cắt dọc cho TikTok.

### [0:00–0:20] Hook
VISUAL: Cảnh trước/sau — bên trái là màn hình terminal trống, bên phải là một web bán cà phê đẹp đang chạy trên trình duyệt. Chữ lớn: "5 phút để có web thật."
LỜI THOẠI: "Nếu bạn vừa mua taw-kit và đang mở ra chưa biết bắt đầu từ đâu, video này là cho bạn. Trong 5 phút, tôi sẽ dắt bạn đi từ con số 0 đến có một trang web thật đang chạy trên internet. Bạn không cần biết code, không cần học gì hết."

### [0:20–0:50] Prerequisites
VISUAL: Highlight 3 icon: Claude Code app, biểu tượng chìa khóa (API key), ứng dụng Terminal. Mỗi cái gạch xanh khi nhắc tới.
LỜI THOẠI: "Trước khi bắt đầu, bạn cần đúng ba thứ. Một, Claude Code đã cài trên máy. Hai, API key của Anthropic — hiểu nôm na là mã tài khoản. Ba, cửa sổ Terminal đang mở sẵn. Nếu chưa có Claude Code, bạn vào trang chủ tải về, cài như một app bình thường."

### [0:50–1:30] Install taw-kit
VISUAL: Terminal zoom lớn. Dán lệnh curl. Enter. Hiện dòng "taw-kit installed successfully".
LỜI THOẠI: "Bước một, cài taw-kit. Copy dòng lệnh này, dán vào Terminal, nhấn Enter. Chờ khoảng 30 giây. Khi thấy dòng 'installed successfully' là xong. Đơn giản vậy thôi."

### [1:30–2:10] Paste API key
VISUAL: Mở Claude Code bằng lệnh `claude`. Claude hỏi API key. Người quay dán chuỗi sk-ant-... (che một phần). Enter.
LỜI THOẠI: "Bước hai, gõ `claude` để mở Claude Code. Lần đầu, nó hỏi API key. Bạn lên console của Anthropic, tạo key, copy cái chuỗi bắt đầu bằng sk-ant, dán vào đây. Xong. Lần sau khỏi phải nhập lại."

### [2:10–3:00] Gõ /taw
VISUAL: Gõ `/taw làm cho tôi trang bán cà phê`. Nhấn Enter. taw-kit hiện ra danh sách 5 câu hỏi.
LỜI THOẠI: "Bước ba, đây là phần hay nhất. Gõ slash-taw, rồi mô tả bằng tiếng Việt bạn muốn làm cái gì. Ví dụ, tôi gõ 'làm cho tôi trang bán cà phê'. Enter. taw-kit sẽ hỏi lại 5 câu — tên quán, có giỏ hàng không, tông màu... Trả lời theo ý bạn. Cái nào không biết ghi 'tùy bạn' là được."

### [3:00–3:40] Duyệt kế hoạch
VISUAL: Hiện 5 dòng kế hoạch (stack, số trang, deploy, thời gian). Cursor nhấp nháy chờ trả lời.
LỜI THOẠI: "Sau khi trả lời, taw-kit đưa ra một kế hoạch ngắn — thường chỉ 5 dòng. Bạn đọc qua xem có ổn không. Ổn thì gõ 'yes'. Muốn điều chỉnh thì gõ 'sửa'. Muốn dừng thì gõ 'hủy'. Tôi gõ yes."

### [3:40–4:40] Chờ các công nhân AI
VISUAL: Fast-forward 15 phút xuống còn 40 giây. Hiện từng dòng "✓ Đã xong: lập kế hoạch", "✓ Đã xong: viết code", v.v.
LỜI THOẠI: "Và bây giờ bạn chỉ việc ngồi đợi. taw-kit có 5 công nhân AI chạy lần lượt — một cái lập kế hoạch, một cái tra tài liệu, một cái viết code, một cái kiểm thử, một cái review an toàn. Mỗi công nhân làm xong báo một dòng. Tổng cộng khoảng 15 đến 20 phút. Trong lúc này đi pha cà phê, không phải làm gì."

### [4:40–5:20] Nhận URL
VISUAL: Dòng cuối "Xong! Truy cập: https://shop-cafe-linh.vercel.app". Click link. Mở trình duyệt, hiện web thật, cuộn qua các trang.
LỜI THOẠI: "Và đây. Dòng cuối báo 'Xong' kèm một URL. Click vào. Boom — web của bạn đang chạy trên internet thật. Gửi link cho bạn bè, khoe lên Facebook. Hosting miễn phí luôn. Thấy chưa, không khó như bạn nghĩ."

### [5:20–5:50] Recap + next
VISUAL: Text overlay 3 bullet: "Cài 30s — Gõ /taw — Nhận URL". Cuối cùng link video tiếp theo "Dựng shop online trong 30 phút".
LỜI THOẠI: "Tóm lại: cài 30 giây, gõ slash-taw, đợi 15 phút, nhận URL. Nếu bị lỗi, file troubleshooting.md trong thư mục docs có đủ. Video tiếp theo tôi sẽ dẫn làm một shop online hoàn chỉnh có giỏ hàng, thanh toán, trong 30 phút. Hẹn gặp lại."

---

## Script B: Dựng shop online trong 30 phút

**Mục tiêu:** Demo đầy đủ từ lệnh đầu tiên đến web có giỏ hàng, thanh toán, live URL.
**Độ dài mục tiêu:** 12–15 phút (cắt từ 30 phút quay gốc bằng fast-forward).
**Nền tảng:** YouTube dài. Có thể cắt 2 bản TikTok ngắn.

### [0:00–0:30] Hook
VISUAL: Tua nhanh cảnh cuối — shop online đang chạy, có chatbot, có giỏ hàng, có checkout QR MoMo. Text: "30 phút. 1 lệnh. Không code."
LỜI THOẠI: "Trong video này, tôi sẽ dựng một shop bán đồ handmade hoàn chỉnh từ con số 0. Có menu sản phẩm, giỏ hàng, thanh toán online, admin đăng sản phẩm. Tất cả trong 30 phút, gõ đúng một lệnh tiếng Việt. Không phải ảo, không phải cắt ghép. Nếu bạn chưa xem video onboarding 5 phút, xem nó trước đã."

### [0:30–1:30] Chuẩn bị
VISUAL: Mở Claude Code. Highlight Supabase dashboard ở tab bên cạnh (URL + anon key sẵn sàng copy).
LỜI THOẠI: "Trước khi bắt đầu, tôi chuẩn bị thêm Supabase — đây là dịch vụ database miễn phí để lưu sản phẩm, đơn hàng, tài khoản. Đăng ký tại supabase.com, tạo project mới, copy URL với anon key ra ghi chú tạm. Nếu bạn chỉ làm landing page thì không cần bước này."

### [1:30–2:30] Gõ /taw với mô tả chi tiết
VISUAL: Gõ lệnh dài: `/taw làm cho tôi shop bán đồ handmade, có danh sách sản phẩm, giỏ hàng, thanh toán qua MoMo, có trang admin đăng sản phẩm`. Enter.
LỜI THOẠI: "Giờ tôi gõ slash-taw, rồi mô tả càng chi tiết càng tốt. Để ý tôi nói rõ: shop bán đồ handmade, có danh sách sản phẩm, giỏ hàng, thanh toán MoMo, trang admin đăng sản phẩm. Càng cụ thể, kết quả càng đúng ý."

### [2:30–4:30] Clarify + trả lời
VISUAL: taw-kit hỏi 5 câu (tên shop, logo, màu, số sản phẩm ban đầu, có tài khoản khách không). Gõ trả lời lần lượt.
LỜI THOẠI: "taw-kit hỏi lại 5 câu. Tên shop 'Handmade Linh'. Logo — tôi nói 'tùy bạn chọn font và icon'. Màu chủ đạo — be và nâu nhạt. Số sản phẩm mẫu — 8 cái. Có tài khoản khách đăng nhập bằng Google. Trả lời xong, nhấn Enter."

### [4:30–5:30] Duyệt kế hoạch + yes
VISUAL: Kế hoạch hiện ra 5 bullet. Scroll từng dòng. Gõ `yes`.
LỜI THOẠI: "Kế hoạch có đủ: Next.js với Tailwind và Supabase, bốn trang chính, tích hợp Polar cho thanh toán MoMo, deploy lên Vercel qua Shipkit, dự kiến 25 phút. Đọc qua thấy ổn, gõ yes."

### [5:30–7:00] Planner + Researcher
VISUAL: Tua nhanh. Hiện dòng "✓ Đã xong: lập kế hoạch chi tiết", rồi "✓ Đã xong: tra tài liệu Supabase + Polar" (hai cái researcher chạy song song).
LỜI THOẠI: "Công nhân đầu tiên là planner, chia kế hoạch tổng thành 6 pha nhỏ. Công nhân thứ hai là hai researcher chạy song song, một cái tra tài liệu Supabase, một cái tra tài liệu Polar để biết gọi API đúng cách. Mục này khoảng 3 phút."

### [7:00–10:00] Fullstack-dev viết code
VISUAL: Cửa sổ trái hiện file code đang được tạo ra nhanh (scroll tự động). Cửa sổ phải hiện % tiến độ. Tua nhanh x4.
LỜI THOẠI: "Giờ tới fullstack-dev — đây là công nhân quan trọng nhất. Nó scaffold Next.js, tạo 4 trang, viết component giỏ hàng, kết nối Supabase cho database, tích hợp Polar cho thanh toán. Đồng thời nó chạy npm install, ghi nhận từng bước. Phần này mất khoảng 8 đến 12 phút. Tôi tua nhanh."

### [10:00–11:30] Tester + Reviewer
VISUAL: Hiện "✓ Đã xong: kiểm thử build" rồi "✓ Đã xong: review an toàn". Kèm checklist màu xanh bên cạnh.
LỜI THOẠI: "Hai công nhân cuối chạy nhanh. Tester chạy lệnh build và smoke test để chắc web không lỗi khi bấm vào. Reviewer quét security — xem có lộ API key không, có bug bảo mật không. Hai bước này mất khoảng 2 phút."

### [11:30–13:00] Deploy
VISUAL: Hiện "Đang deploy lên Shipkit..." rồi "Xong! https://handmade-linh.vercel.app". Click link. Trình duyệt mở.
LỜI THOẠI: "Bước cuối là deploy. taw-kit gọi Shipkit MCP để đẩy code lên Vercel. Khoảng 1 đến 2 phút, nó trả về một URL thật. Tôi click vào. Đây rồi — shop Handmade Linh đang chạy trên internet."

### [13:00–14:30] Walkthrough shop thật
VISUAL: Cuộn trang chủ, xem 8 sản phẩm mẫu, click vào sản phẩm, thêm vô giỏ, mở giỏ, nhấn checkout, QR MoMo hiện ra. Đăng nhập Google ở tab admin, đăng thêm 1 sản phẩm.
LỜI THOẠI: "Đây là trang chủ — có banner, có menu, có 8 sản phẩm taw-kit đã tạo sẵn. Click một sản phẩm, hiện chi tiết. Thêm vào giỏ. Mở giỏ, nhấn thanh toán. QR MoMo hiện ra thật luôn — quét sẽ trừ tiền thật (dĩ nhiên tôi không quét demo). Chuyển sang tab admin, đăng nhập Google, tôi thêm một sản phẩm mới. Xong, frontend update ngay."

### [14:30–15:00] Recap + next
VISUAL: Timer 30:00 nổi. 3 bullet: "1 lệnh — 30 phút — Web live thật". Link video tiếp "Khi gặp lỗi: dùng /taw-fix".
LỜI THOẠI: "Tóm lại: một lệnh, 30 phút, shop thật đang chạy. Muốn thêm tính năng sau, gõ slash-taw-add. Muốn sửa lỗi, slash-taw-fix. Video tiếp theo tôi sẽ dạy cách dùng taw-fix khi bị lỗi — vì chắc chắn có lúc bạn sẽ cần. Đăng ký kênh để không bỏ lỡ."

---

## Ghi chú quay phim

- **Giọng:** Nói chậm, rõ, như đang dạy em út. Tránh giọng "hype bro". Người mới sợ lỡ nhịp.
- **Tốc độ gõ phím:** Không tua nhanh phần gõ lệnh đầu tiên — người xem cần theo kịp. Chỉ tua khi các công nhân đang chạy.
- **Phụ đề:** Bắt buộc có, font đen nền trắng để đọc cả khi mute.
- **Branding:** Logo taw-kit góc dưới bên trái suốt video. Kết thúc bằng frame CTA mua kit kèm URL.
- **Thumbnail:** Text lớn "Trong 5 phút" hoặc "30 phút shop thật". Không dùng mũi tên đỏ và mặt người ngạc nhiên — lỗi mốt rồi.
