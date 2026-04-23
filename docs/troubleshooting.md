# Khắc phục sự cố

20 lỗi thường gặp trong tuần đầu xài taw-kit, kèm cách fix từng bước. Nếu lỗi của bạn không có ở đây, thử `/taw-fix --deep` để taw-kit tự chẩn đoán.

**Quy ước:** Mọi lệnh đều gõ trong Terminal. Thay `<...>` bằng giá trị thật của bạn.

---

## A. Lỗi khi cài đặt

### "curl: command not found"
**Triệu chứng:** Chạy dòng cài đặt thì in ra `curl: command not found`.
**Nguyên nhân:** Máy không có `curl`. Hiếm gặp trên Mac/Windows hiện đại; thường thấy trên Linux bản minimal.
**Cách fix:**
1. Mac: `brew install curl`. Nếu chưa có Homebrew thì cài trước ở brew.sh.
2. Windows 10+: curl có sẵn — check lại chính tả.
3. Thử `wget` thay thế: `wget -qO- https://install.tawkit.dev | bash`.

**Vẫn tắc?** Tải `install-oneliner.sh` tay từ trang taw-kit rồi chạy `bash install-oneliner.sh`.

---

### /taw không có phản ứng gì sau khi cài
**Triệu chứng:** Trong Claude Code gõ `/taw` nhưng không có gì xảy ra.
**Nguyên nhân:** Claude Code chưa nhận skill. Thường do sai đường dẫn hoặc cần khởi động lại.
**Cách fix:**
1. Thoát Claude Code (Ctrl+D hoặc gõ `/exit`).
2. Mở lại: `claude`.
3. Gõ `/taw` lại. Nếu vẫn không thấy, check file `~/.claude/skills/taw/SKILL.md` có tồn tại không.
4. Nếu file bị thiếu: chạy lại one-liner cài đặt.

**Vẫn tắc?** Gõ `/taw-fix --deep` — nó check cài đặt và tự chữa.

---

### Permission denied khi cài
**Triệu chứng:** `Permission denied` hoặc `bash: /install.sh: Permission denied`.
**Nguyên nhân:** Script không có quyền thực thi, hoặc bạn đang ở folder không ghi được.
**Cách fix:**
1. Về home: `cd ~`.
2. Chạy lại one-liner cài đặt.
3. Không bao giờ dùng `sudo` để cài. taw-kit không cần quyền admin.

**Vẫn tắc?** Xoá `~/.claude/skills/taw` cũ rồi cài lại.

---

### "claude: command not found"
**Triệu chứng:** Gõ `claude` báo command not found.
**Nguyên nhân:** Claude Code chưa cài hoặc không có trong PATH.
**Cách fix:**
1. Cài Claude Code từ trang Anthropic.
2. Thoát và mở lại Terminal (để reload PATH).
3. Nếu vẫn thiếu, tìm binary (thường ở `/usr/local/bin/claude` trên Mac) và thêm folder đó vào PATH.

**Vẫn tắc?** Gỡ Claude Code và cài lại từ package chính thức.

---

## B. Lỗi login Claude Code

> taw-kit chỉ hỗ trợ login Claude Code qua **subscription Claude Pro/Max** (OAuth trình duyệt). Các lỗi dưới đây liên quan tới flow đó.

### Login hết hạn / bị đá ra giữa chừng
**Triệu chứng:** Claude Code báo phiên login không còn hợp lệ, hoặc đòi login lại.
**Nguyên nhân:** Token OAuth hết hạn sau 1 khoảng thời gian, hoặc bạn đổi mật khẩu tài khoản Claude.
**Cách fix:**
1. Trong Claude Code gõ `/logout`.
2. Thoát, mở lại: `claude`.
3. Chọn lại nhánh login bằng subscription → trình duyệt mở → Accept.

**Vẫn tắc?** Xoá cache auth: `rm -rf ~/.claude/auth.json` rồi login lại từ đầu.

---

### Rate limit / "Too many requests"
**Triệu chứng:** `/taw` chạy được 1 lúc rồi dính `429 Too Many Requests` hoặc thông báo hết hạn mức 5 tiếng.
**Nguyên nhân:** Subscription Claude Pro/Max có hạn mức sử dụng theo cửa sổ 5 tiếng. Khi vượt, phải chờ reset.
**Cách fix:**
1. Chờ qua cửa sổ 5 tiếng (Claude Code thường báo còn bao lâu).
2. Gõ `/taw-fix` để chạy tiếp từ bước cuối.
3. Dùng nhiều → nâng lên gói Max hạn mức cao hơn.

**Vẫn tắc?** Tạm dừng build lớn, chờ reset hoặc nâng tier.

---

### "Subscription không hợp lệ" / tài khoản free
**Triệu chứng:** Claude Code báo tài khoản không có quyền dùng Claude Code, hoặc login xong thì chạy lỗi.
**Nguyên nhân:** Bạn đăng ký tài khoản Claude nhưng **chưa** có gói Pro hoặc Max.
**Cách fix:**
1. Vào [claude.ai](https://claude.ai) → Settings → Billing.
2. Nâng cấp lên Claude Pro hoặc Max.
3. Quay lại terminal: `claude` → chọn login → Accept.

**Lưu ý:** taw-kit không hỗ trợ login bằng API key Anthropic — chỉ subscription.

---

## C. Lỗi build

### "Module not found"
**Triệu chứng:** `Error: Cannot find module 'xyz'`.
**Nguyên nhân:** Thiếu dependency, hoặc `node_modules` bị hỏng.
**Cách fix:**
1. Trong folder dự án: `npm install`.
2. Nếu fail: `rm -rf node_modules package-lock.json && npm install`.
3. Vẫn fail: `/taw-fix --deep`.

---

### Lỗi TypeScript type
**Triệu chứng:** `Type 'X' is not assignable to type 'Y'` khi chạy `npm run build`.
**Nguyên nhân:** Component vừa sinh ra có type không khớp, hay gặp sau khi `/taw-add`.
**Cách fix:**
1. Gõ `/taw-fix` — tự xử lý phần lớn lỗi type.
2. Muốn tự fix, mở file nêu trong error và chỉnh type cho khớp.

---

### Thiếu biến môi trường
**Triệu chứng:** `Missing environment variable: NEXT_PUBLIC_SUPABASE_URL`.
**Nguyên nhân:** File `.env.local` bị thiếu hoặc thiếu key quan trọng.
**Cách fix:**
1. Mở `.env.local` trong folder dự án (tạo nếu chưa có).
2. Thêm dòng bị thiếu, ví dụ `NEXT_PUBLIC_SUPABASE_URL=https://xyz.supabase.co`.
3. Lấy giá trị từ Supabase → Project → Settings → API.
4. `/taw-fix` để build lại.

---

### Hết dung lượng ổ cứng
**Triệu chứng:** `ENOSPC: no space left on device`.
**Nguyên nhân:** Ổ đầy. 1 dự án Next.js cần ~500MB cho node_modules.
**Cách fix:**
1. Dọn dẹp: xoá Trash, xoá file không dùng.
2. Xoá `node_modules` cũ: `find ~/tawkit-projects -name node_modules -exec rm -rf {} +`.
3. Chuyển dự án sang ổ khác.

---

## D. Lỗi deploy

### Vercel auth failed
**Triệu chứng:** `Vercel authentication required` khi chạy `/taw-deploy`.
**Nguyên nhân:** Vercel CLI chưa login.
**Cách fix:**
1. Chạy `npx vercel login` và làm theo prompt trên trình duyệt.
2. `/taw-deploy` lại.

---

### Domain đã bị chiếm
**Triệu chứng:** `The requested domain is already in use`.
**Nguyên nhân:** Dự án khác trên Vercel đã dùng slug đó.
**Cách fix:**
1. Sửa `.taw/intent.json`, đổi `project_name` thành cái duy nhất.
2. `/taw-deploy` lại.

---

### Docker build fail
**Triệu chứng:** `docker build` thoát ở 1 bước nào đó.
**Nguyên nhân:** Thường do thiếu package, base image cũ, hoặc cache BuildKit lỗi.
**Cách fix:**
1. Chạy với cache sạch: `docker build --no-cache -t <name>:latest .`.
2. Xác nhận `.dockerignore` đã loại `node_modules` và `.env*`.
3. `/taw-fix` tự xử lý phần lớn lỗi Dockerfile.

---

### VPS deploy: "Permission denied (publickey)"
**Triệu chứng:** SSH từ chối kết nối khi chạy `/taw-deploy --target=vps`.
**Nguyên nhân:** VPS chưa có public key của bạn, hoặc `.taw/vps.env` sai user.
**Cách fix:**
1. Copy key lên: `ssh-copy-id $VPS_USER@$VPS_HOST`.
2. Check lại `VPS_USER` và `VPS_HOST` trong `.taw/vps.env`.
3. Test kết nối thô: `ssh $VPS_USER@$VPS_HOST echo ok`.

---

### Build OK local nhưng fail trên Vercel
**Triệu chứng:** `npm run build` OK trên máy bạn nhưng deploy thì fail.
**Nguyên nhân:** Thường do thiếu env var trên Vercel, hoặc tên file phân biệt hoa/thường trên Linux.
**Cách fix:**
1. Vercel dashboard → Settings → Environment Variables — thêm đúng các key như `.env.local`.
2. Check casing tên file trong import (Mac không phân biệt, Linux có phân biệt).
3. `/taw-fix` để thử auto-fix.

---

## E. Các rối chung

### /taw không phản hồi
**Triệu chứng:** Gõ `/taw` nhưng không thấy gì.
**Nguyên nhân:** Có thể không ở trong Claude Code, hoặc skill chưa load.
**Cách fix:**
1. Xác nhận prompt là `claude >` (không phải `$` hay `%`).
2. Gõ `/taw --help` — nếu hiện help thì skill đã load.
3. Nếu không, thoát và khởi động lại Claude Code.

---

### Output kỳ lạ (trắng, cắt giữa chừng, ký tự lỗi)
**Triệu chứng:** Trả lời rỗng hoặc cụt.
**Nguyên nhân:** Mạng chập chờn hoặc đạt giới hạn context.
**Cách fix:**
1. Check internet.
2. Gõ `/taw-fix` để chạy tiếp.
3. Nếu context đầy, bắt đầu session Claude Code mới — state taw-kit lưu trên đĩa.

---

### Trả lời sai ngôn ngữ
**Triệu chứng:** Phản hồi trộn lẫn tiếng Anh với tiếng Việt loạn xạ.
**Nguyên nhân:** Gợi ý ngôn ngữ bị mơ hồ.
**Cách fix:**
1. Ghi rõ ngay đầu prompt: "Trả lời bằng tiếng Việt giúp tôi." (hoặc tiếng Anh).
2. Skill `error-to-vi` của taw-kit có thể dịch error khi cần.

---

### Không hiểu code sinh ra
**Triệu chứng:** Mở folder dự án và không hiểu gì hết.
**Nguyên nhân:** Bình thường nếu bạn chưa code.
**Cách fix:**
1. Đừng sửa code tay. Dùng `/taw-add` để thay đổi.
2. Muốn học? Đọc Next.js quickstart — 2 tiếng là bạn nhận ra cấu trúc.
3. Cộng đồng có người thân thiện; hỏi kèm tên file cụ thể bạn đang xem.

---

Nếu lỗi của bạn không có trong list này, mở link cộng đồng taw-kit (có trong email đơn hàng), paste nội dung lỗi (che API key), và sẽ có người giúp.
