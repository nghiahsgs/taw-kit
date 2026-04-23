# Cài taw-kit trên Windows

> **Tóm tắt** — Trên Windows, cách đơn giản nhất là tải taw-kit về rồi copy hai thư mục vào `.claude`. Không cần cài đặt gì thêm. Xong trong 2 phút.
>
> **Chạy được:** `/taw`, tất cả skills, tất cả agents trong Claude Code.
>
> **Không có:** lệnh `tawkit` (doctor / update / uninstall) và hook auto-commit — nhưng thực tế hiếm khi cần.

---

## Bước 1 — Cài Claude Code cho Windows

Tải và cài từ [docs.claude.com/claude-code](https://docs.claude.com/claude-code). Mở một lần, đăng nhập bằng gói Claude Pro/Max xong là được.

## Bước 2 — Tải taw-kit về máy

Vào [github.com/nghiahsgs/taw-kit](https://github.com/nghiahsgs/taw-kit) → nút xanh **Code** → **Download ZIP**. Giải nén ra một chỗ bất kỳ (ví dụ `C:\Users\YourName\Downloads\taw-kit-main\`).

Hoặc nếu đã có Git:

```powershell
git clone https://github.com/nghiahsgs/taw-kit.git "%USERPROFILE%\taw-kit"
```

## Bước 3 — Copy hai thư mục vào `.claude`

Mở File Explorer, gõ vào thanh địa chỉ:

```
%USERPROFILE%\.claude
```

Nhấn Enter. Nếu chưa có thư mục `.claude` thì tạo mới.

Bên trong `.claude`, copy hai thư mục sau từ taw-kit đã tải về:

| Copy từ | Vào |
|---------|-----|
| `taw-kit-main\skills\*` | `%USERPROFILE%\.claude\skills\` |
| `taw-kit-main\agents\*` | `%USERPROFILE%\.claude\agents\` |

Xong.

## Bước 4 — Mở Claude Code và thử

Mở một thư mục trống bất kỳ trong Claude Code, gõ:

```
/taw làm landing page bán khoá học online
```

Nếu thấy agent planner → researcher → fullstack-dev chạy thì đã thành công.

---

## Yêu cầu máy

- **Node.js ≥ 20** — tải tại [nodejs.org](https://nodejs.org)
- **Git** — tải tại [git-scm.com](https://git-scm.com/download/win)

Cả hai chạy installer rồi Next → Next → Finish là xong, không cần cấu hình gì thêm.

## Cập nhật

Thi thoảng quay lại GitHub tải ZIP mới, copy đè hai thư mục `skills` và `agents` vào `.claude` là xong.

## Gỡ cài đặt

Vào `%USERPROFILE%\.claude`, xoá hai thư mục `skills` và `agents` (hoặc chỉ xoá các file có tên liên quan tới taw-kit nếu bạn còn skill cá nhân khác).
