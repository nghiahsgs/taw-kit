# Error Messages (Vietnamese)

Load during Step 6 (error recovery) of `/taw`. Pick the template matching the failure mode.

## Principles

- Luôn dùng tiếng Việt, tone thân thiện, KHÔNG dùng jargon tiếng Anh nguyên bản.
- Luôn đề xuất 1 next action cụ thể (không để user bơ vơ).
- KHÔNG log raw stack trace vào user-visible output — save vào `.taw/checkpoint.json` thay vì in ra.

---

## Template: Build failed (npm run build error)

```
❌ Build bị lỗi sau 2 lần thử. Đã lưu lại thông tin lỗi.
Bạn có thể:
  1. Gõ `/taw-fix` để tôi thử phân tích và sửa tự động
  2. Mở file `.taw/checkpoint.json` xem chi tiết
  3. Hủy và bắt đầu lại với mô tả khác: `/taw <mô tả mới>`
```

## Template: Install failed (npm install error)

```
❌ Cài package bị lỗi. Thường do mạng hoặc đụng phiên bản.
Thử:
  1. Kiểm tra internet
  2. Chạy `npm cache clean --force` rồi `/taw-fix`
  3. Nếu vẫn không được, gõ `/taw-fix --deep` (tôi sẽ xóa node_modules và cài lại)
```

## Template: Deploy failed

```
⚠️ Code đã build thành công nhưng deploy lỗi.
Dự án vẫn chạy được ở máy bạn (gõ `npm run dev`).
Thử deploy lại: `/taw-deploy`
Hoặc deploy thủ công: `vercel --prod`
```

## Template: Missing env var

```
❌ Thiếu biến môi trường: <VAR_NAME>.
Bạn cần tạo file `.env.local` với dòng:
  <VAR_NAME>=<value>
Hướng dẫn lấy <VAR_NAME>: <docs-link>
Sau đó gõ lại `/taw-fix`.
```

## Template: API key invalid (Claude rate limit or bad key)

```
❌ API key Claude của bạn không hợp lệ hoặc hết hạn mức.
Kiểm tra:
  1. `ANTHROPIC_API_KEY` trong biến môi trường
  2. Số dư trong console.anthropic.com
  3. Thử lại sau vài phút nếu bị rate limit
```

## Template: Disk space

```
❌ Máy bạn hết dung lượng. Dự án Next.js cần ~500MB cho node_modules.
Thử:
  1. Xóa node_modules cũ: `find . -name node_modules -exec rm -rf {} +`
  2. Đổi thư mục dự án sang ổ khác
```

## Template: Git conflict

```
⚠️ Git có thay đổi chưa commit. Tôi không ghi đè lên công sức bạn.
Gõ `git status` để xem.
Nếu muốn tiếp tục, commit trước hoặc stash: `git stash`
```

## Template: Unknown error (catchall)

```
❌ Có lỗi không rõ: <1-line summary tiếng Việt>
Đã lưu chi tiết vào `.taw/checkpoint.json`.
Thử `/taw-fix` hoặc gửi file checkpoint cho support qua Discord.
```

## Template: Clarification timeout

```
Tôi đợi hơi lâu rồi. Bạn muốn tiếp tục không?
  - Gõ `yes` để tiếp tục với default
  - Gõ `/taw <mô tả mới>` để bắt đầu lại
```

## Template: User interrupted (Ctrl+C mid-run)

```
⚠️ Tôi bị ngắt giữa chừng ở bước: <step name>
Đã lưu checkpoint. Gõ `/taw-fix` để tiếp tục từ điểm dừng.
```
