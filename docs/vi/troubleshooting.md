# Hướng dẫn sửa lỗi thường gặp

20 lỗi mà đa số người dùng gặp phải trong tuần đầu tiên, kèm cách sửa từng bước. Nếu lỗi của bạn không có ở đây, thử chạy `/taw-fix --deep` để taw-kit tự phân tích.

**Quy ước:** Tất cả lệnh gõ trong Terminal. Thay `<...>` bằng giá trị thật của bạn.

---

## A. Lỗi cài đặt

### Lỗi: Curl báo "command not found"
**Triệu chứng:** Khi chạy `curl -fsSL https://tawkit.dev/install.sh | bash` thấy báo `curl: command not found` hoặc `-bash: curl: command not found`.
**Nguyên nhân:** Máy bạn chưa có tiện ích `curl`. Mac đời rất cũ và một số bản Windows tối thiểu không có sẵn.
**Cách sửa:**
1. Trên Mac: mở Terminal, gõ `brew install curl`. Nếu chưa có `brew`, cài Homebrew trước theo hướng dẫn tại brew.sh.
2. Trên Windows 10 trở lên: `curl` đã có sẵn, kiểm tra đã đánh đúng chính tả chưa.
3. Thử thay `curl` bằng `wget`: `wget -qO- https://tawkit.dev/install.sh | bash`.

**Vẫn không được?** Tải thủ công file install.sh từ trang chủ taw-kit, lưu về máy, rồi chạy `bash install.sh`.

---

### Lỗi: Cài xong nhưng gõ /taw không có gì xảy ra
**Triệu chứng:** Bên trong Claude Code, gõ `/taw` nhưng không hiện menu, không có phản hồi.
**Nguyên nhân:** Skill taw chưa được Claude Code nhận diện. Thường do đường dẫn cài sai hoặc chưa restart Claude.
**Cách sửa:**
1. Thoát Claude Code (Ctrl+D hoặc gõ `/exit`).
2. Mở lại bằng lệnh `claude`.
3. Gõ `/taw` lại. Nếu vẫn không có, kiểm tra file tại đường dẫn `~/.claude/skills/taw/SKILL.md` có tồn tại không.
4. Nếu file không có: chạy lại lệnh cài curl ở Bước 1.

**Vẫn không được?** Gõ `/taw-fix --deep`, nó sẽ tự kiểm tra cài đặt và vá lại.

---

### Lỗi: Permission denied khi chạy install
**Triệu chứng:** Terminal báo `Permission denied` hoặc `bash: /install.sh: Permission denied`.
**Nguyên nhân:** Script không có quyền thực thi, hoặc bạn đang ở thư mục không có quyền ghi.
**Cách sửa:**
1. Chuyển về thư mục nhà: `cd ~`.
2. Chạy lại lệnh cài curl.
3. Tuyệt đối không dùng `sudo` cho lệnh cài. taw-kit không cần quyền admin.

**Vẫn không được?** Xóa thư mục `~/.claude/skills/taw` cũ (nếu có) rồi chạy lại lệnh cài.

---

### Lỗi: Báo "claude: command not found"
**Triệu chứng:** Gõ `claude` trong Terminal báo không tìm thấy lệnh.
**Nguyên nhân:** Claude Code chưa được cài hoặc chưa nằm trong `PATH`.
**Cách sửa:**
1. Kiểm tra đã cài Claude Code chưa tại trang chủ của Anthropic.
2. Sau khi cài xong, thoát Terminal và mở lại (để `PATH` được nạp mới).
3. Nếu vẫn không có: tìm file thực thi (thường ở `/usr/local/bin/claude` trên Mac hoặc `C:\Program Files\Claude Code\` trên Windows) và thêm vào PATH.

**Vẫn không được?** Gỡ cài đặt Claude Code và cài lại bằng gói cài chính thức.

---

## B. Lỗi API key

### Lỗi: "Invalid API key"
**Triệu chứng:** Claude Code báo `Error: invalid_api_key` hoặc `401 Unauthorized` khi vừa gõ lệnh.
**Nguyên nhân:** Key nhập sai, key bị copy thiếu ký tự, hoặc key đã bị vô hiệu hóa.
**Cách sửa:**
1. Vào trang quản lý API key của Anthropic, kiểm tra key còn hiệu lực.
2. Copy lại toàn bộ chuỗi bắt đầu bằng `sk-ant-` — chú ý không copy khoảng trắng thừa hai đầu.
3. Trong Claude Code gõ `/logout` rồi gõ lại `claude`, dán key mới.

**Vẫn không được?** Tạo key mới trên console Anthropic, xóa key cũ, dùng key mới.

---

### Lỗi: Rate limit / "Too many requests"
**Triệu chứng:** Đang chạy `/taw` được nửa chừng thì báo `429 Too Many Requests` hoặc `rate limit exceeded`.
**Nguyên nhân:** Bạn gọi quá giới hạn trong phút của tài khoản Anthropic (thường là bản miễn phí hoặc tài khoản mới).
**Cách sửa:**
1. Đợi 60 giây, sau đó gõ `/taw-fix` để tiếp tục từ chỗ dừng.
2. Kiểm tra tier tài khoản tại console Anthropic. Nạp thêm tiền để lên tier cao hơn (rate limit tăng).
3. Nếu bạn đang dùng key chung với người khác, tạo key riêng cho mỗi người.

**Vẫn không được?** Tạm ngưng việc build lớn, đợi 1 giờ hoặc nâng tier.

---

### Lỗi: "Insufficient credits"
**Triệu chứng:** Claude báo `credits exhausted` hoặc `billing_error`.
**Nguyên nhân:** Hết số tiền trong tài khoản Anthropic.
**Cách sửa:**
1. Đăng nhập console Anthropic, vào mục Billing.
2. Nạp thêm tối thiểu 5 đô. Một project taw-kit tốn khoảng 0,5–2 đô.
3. Quay lại Terminal, gõ `/taw-fix` để tiếp tục.

**Vẫn không được?** Kiểm tra thẻ ngân hàng của bạn có bị chặn thanh toán quốc tế không. Dùng thẻ Visa/Master quốc tế.

---

### Lỗi: Không biết API key là gì
**Triệu chứng:** Claude Code hỏi "API key" nhưng bạn chưa có.
**Nguyên nhân:** Chưa đăng ký tài khoản Anthropic.
**Cách sửa:**
1. Vào console.anthropic.com, đăng ký bằng email.
2. Xác thực số điện thoại (nhận mã SMS).
3. Nạp tối thiểu 5 đô bằng thẻ Visa/Master.
4. Vào mục "API Keys", click "Create Key", copy chuỗi bắt đầu bằng `sk-ant-`.
5. Quay lại Claude Code, dán key vào.

**Vẫn không được?** Kiểm tra hộp thư spam để xác nhận email đăng ký.

---

## C. Lỗi build / chạy code

### Lỗi: "Module not found"
**Triệu chứng:** Trong quá trình build, taw-kit báo `Cannot find module 'xxx'` hoặc `Module not found: Can't resolve 'yyy'`.
**Nguyên nhân:** Thiếu thư viện. Thường do `npm install` bị ngắt giữa chừng.
**Cách sửa:**
1. Vào thư mục dự án: `cd ~/tawkit-projects/<tên>`.
2. Xóa cache: `rm -rf node_modules package-lock.json`.
3. Cài lại: `npm install`.
4. Chạy lại build: `npm run build`.

**Vẫn không được?** Gõ `/taw-fix`, taw-kit sẽ tự cài lại đúng phiên bản thư viện.

---

### Lỗi: TypeScript error ngẫu nhiên
**Triệu chứng:** Terminal đầy các dòng màu đỏ kiểu `Type 'X' is not assignable to type 'Y'` hoặc `Property 'z' does not exist`.
**Nguyên nhân:** Code do AI sinh có thể có lỗi kiểu dữ liệu khi tương tác với thư viện mới cập nhật.
**Cách sửa:**
1. Gõ `/taw-fix` — lệnh này chuyên để bắt loại lỗi này.
2. Nếu vẫn còn, gõ `/taw-fix --deep` để quét sâu hơn.
3. Trong trường hợp xấu: gõ `/taw-fix --strict` buộc taw-kit viết lại phần đó từ đầu.

**Vẫn không được?** Post đoạn lỗi (3–5 dòng) vào cộng đồng taw-kit. Đừng gửi toàn bộ file.

---

### Lỗi: Thiếu biến môi trường (missing env)
**Triệu chứng:** Ứng dụng chạy được nhưng trang trắng, console browser báo `process.env.XXX is undefined`.
**Nguyên nhân:** File `.env.local` chưa có giá trị API key cần thiết (Supabase URL, Polar token, v.v.).
**Cách sửa:**
1. Mở file `.env.local` trong thư mục dự án bằng trình soạn thảo (VS Code / Notepad).
2. Kiểm tra các biến có đủ giá trị không (không được để trống).
3. Lấy giá trị thật từ dashboard của dịch vụ tương ứng (Supabase project settings, Polar dashboard).
4. Lưu file, chạy lại `npm run dev`.

**Vẫn không được?** Gõ `/taw-fix`, taw-kit sẽ hỏi lại từng env bạn còn thiếu.

---

### Lỗi: Build chạy mãi không kết thúc
**Triệu chứng:** `npm run build` đứng yên 5+ phút, không báo gì.
**Nguyên nhân:** Kẹt ở bước compile, hoặc RAM không đủ với project lớn.
**Cách sửa:**
1. Nhấn `Ctrl+C` để hủy.
2. Đóng các ứng dụng ngốn RAM (Chrome nhiều tab, Photoshop, v.v.).
3. Chạy lại: `npm run build`.
4. Nếu máy dưới 8GB RAM: thêm trước lệnh `NODE_OPTIONS="--max-old-space-size=4096"`.

**Vẫn không được?** Khởi động lại máy, thử lại một lần. Nếu vẫn đứng, báo trong cộng đồng kèm cấu hình máy.

---

## D. Lỗi deploy

### Lỗi: Vercel bắt đăng nhập
**Triệu chứng:** Khi deploy, terminal mở trình duyệt yêu cầu đăng nhập Vercel.
**Nguyên nhân:** Bình thường cho lần deploy đầu tiên — bạn chưa liên kết tài khoản.
**Cách sửa:**
1. Trong trình duyệt vừa mở, đăng nhập bằng GitHub (khuyên dùng) hoặc email.
2. Nhấn Allow khi Vercel CLI xin quyền.
3. Quay lại Terminal, deploy sẽ tự tiếp tục.

**Vẫn không được?** Gõ `vercel logout` rồi `vercel login` để reset liên kết.

---

### Lỗi: Domain đã tồn tại
**Triệu chứng:** Khi deploy báo `Domain <tên>.vercel.app is already taken`.
**Nguyên nhân:** Tên bạn chọn trùng với project của người khác.
**Cách sửa:**
1. Đổi tên dự án: mở file `vercel.json` hoặc `package.json`, sửa trường `name` thành tên độc đáo hơn.
2. Ví dụ: từ `shop-ca-phe` thành `shop-ca-phe-linh-2026`.
3. Deploy lại.

**Vẫn không được?** Xóa project trên dashboard Vercel rồi deploy lại từ đầu.

---

### Lỗi: Shipkit MCP không phản hồi
**Triệu chứng:** Tới bước deploy, taw-kit báo `Shipkit MCP timeout` hoặc `connection refused`.
**Nguyên nhân:** Dịch vụ Shipkit tạm thời đứt.
**Cách sửa:**
1. Đợi 2–3 phút, chạy lại `/taw-deploy`.
2. Nếu vẫn lỗi: deploy thẳng bằng Vercel CLI — `cd <thư mục dự án>` rồi `vercel --prod`.
3. Theo dõi trạng thái Shipkit trên trang status của họ.

**Vẫn không được?** Dùng Vercel trực tiếp (bước 2). Khi Shipkit trở lại, bạn chạy `/taw-deploy` sẽ sync.

---

### Lỗi: Deploy xong nhưng mở URL thấy trang 404
**Triệu chứng:** Deploy báo thành công, nhưng khi click URL thấy `404: NOT_FOUND` hoặc trang trắng.
**Nguyên nhân:** Routing chưa đúng, hoặc build output rỗng.
**Cách sửa:**
1. Vào dashboard Vercel, mở mục Deployments, xem log của lần deploy cuối.
2. Tìm các dòng màu đỏ — thường có chỉ dẫn cụ thể.
3. Gõ `/taw-fix --deploy`, taw-kit sẽ đọc log và sửa.
4. Chờ deploy lại (1–2 phút).

**Vẫn không được?** Xóa thư mục `.vercel/` trong dự án, rồi gõ `/taw-deploy` để redeploy từ đầu.

---

## E. Lỗi "tôi không hiểu chuyện gì đang xảy ra"

### Lỗi: Gõ /taw không thấy phản hồi gì cả
**Triệu chứng:** Gõ `/taw làm web bán phở` rồi Enter, màn hình vẫn trống trơn không có gì.
**Nguyên nhân:** Claude Code đang xử lý (có thể mất 5–10 giây lần đầu), hoặc bạn đang ở thư mục không có quyền ghi.
**Cách sửa:**
1. Đợi thêm 30 giây, nhìn kỹ góc dưới có chữ "thinking..." không.
2. Nếu vẫn không có, thoát Claude Code (Ctrl+D), mở lại, gõ lại.
3. Đảm bảo đang ở thư mục nhà: `cd ~`.

**Vẫn không được?** Gõ `/taw-fix --deep`. Nếu vẫn bế tắc, restart máy.

---

### Lỗi: Kết quả kỳ quá / không giống mô tả
**Triệu chứng:** taw-kit build xong một trang, nhưng nhìn không giống ý bạn (màu sai, thiếu tính năng, chữ sai).
**Nguyên nhân:** Mô tả ban đầu chưa rõ, AI hiểu nhầm.
**Cách sửa:**
1. Đừng hủy dự án vội. Gõ `/taw-add <mô tả điều chỉnh>`.
2. Ví dụ: `/taw-add đổi màu chủ đạo sang xanh lá, thêm phần giới thiệu đầu bếp`.
3. taw-kit sẽ sửa và deploy lại.

**Vẫn không được?** Nếu sai nhiều, gõ `/taw` lại từ đầu với mô tả chi tiết hơn. Dự án cũ không bị xóa.

---

### Lỗi: Terminal đóng giữa chừng
**Triệu chứng:** Đang chạy `/taw` thì vô tình đóng cửa sổ Terminal.
**Nguyên nhân:** Đóng nhầm, máy sleep, mất điện.
**Cách sửa:**
1. Mở lại Terminal, gõ `claude` vào Claude Code.
2. Gõ `/taw-fix --resume` — lệnh này đọc file `.taw/checkpoint.json` và tiếp từ bước dang dở.
3. Nếu checkpoint hư: `/taw` lại từ đầu, nhanh hơn sửa lỗi.

**Vẫn không được?** Copy file `.taw/intent.json` ra chỗ an toàn để dùng lại nội dung, rồi `/taw` mới.

---

### Lỗi: "Tôi không biết phải gõ gì tiếp theo"
**Triệu chứng:** Bạn đang đứng trước màn hình Claude Code trống trơn, không biết phải làm gì.
**Nguyên nhân:** Bình thường thôi. Ai mới cũng vậy.
**Cách sửa:**
1. Gõ `/help` — Claude Code liệt kê mọi lệnh có sẵn.
2. Gõ `/taw` (không có gì phía sau) — taw-kit sẽ hỏi bạn muốn làm gì.
3. Đọc lại [quickstart.md](./quickstart.md) để nhớ 5 bước cơ bản.

**Vẫn không được?** Vào cộng đồng taw-kit, mô tả bạn muốn làm gì, mọi người sẽ chỉ lệnh phù hợp.

---

## Khi tất cả đều vô vọng

1. **Chạy `/taw-fix --deep`** — lệnh này bật chế độ chẩn đoán sâu, chạy mất 3–5 phút nhưng sửa được khoảng 80% ca khó.
2. **Copy toàn bộ log lỗi**, chỉ 20–30 dòng quanh chỗ báo đỏ. Dán vào Google — nhiều khi có người khác đã gặp.
3. **Vào cộng đồng taw-kit** (link trong email đơn hàng). Post: mô tả mục tiêu + 20 dòng log lỗi + phiên bản taw-kit (gõ `tawkit --version`). **Không dán file `.env.local`** — chứa mật khẩu.
4. **Cuối cùng:** email support qua địa chỉ trong email đơn hàng. Phản hồi trong 24h giờ VN.

Chúc bạn sửa lỗi nhẹ nhàng!
