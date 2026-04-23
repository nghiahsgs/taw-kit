# Cài taw-kit trên Windows

> **Tóm tắt** — Trình cài đặt của taw-kit là bash script. Trên Windows bạn cần một shell tương thích Linux. Cách khuyến nghị là **WSL2** (Windows Subsystem for Linux). Lần đầu mất ~10 phút, xong rồi `/taw` chạy y hệt như trên Mac hay Linux.

---

## Tại sao lại WSL2, không phải cmd / PowerShell?

taw-kit đi kèm ~50 bash script (install, doctor, hooks, CLI `tawkit`). Viết lại hết cho PowerShell thì khối lượng bảo trì tăng gấp đôi và gần như chắc chắn sẽ drift. Thay vào đó, mình dùng WSL2 — tầng Linux chính thức của Microsoft bên trong Windows — để **cùng một bộ script** chạy không đổi.

Lợi ích:

- Cùng script, cùng skill, cùng hành vi như người xài Mac/Linux
- Dùng được `apt`, `git`, `node`, `brew` (tuỳ chọn), đủ bộ công cụ Unix
- Claude Code cũng chạy luôn trong WSL, hiệu năng full
- Bạn vẫn sửa file bằng VS Code / editor Windows nào cũng được — đường dẫn `\\wsl$\Ubuntu\home\you\...` truy cập được từ Windows

---

## Phần 1 — Cài WSL2 + Ubuntu (chỉ làm 1 lần, ~5 phút)

### 1.1 Mở PowerShell với quyền Administrator

Bấm `Win + X`, chọn "Windows Terminal (Admin)" hoặc "PowerShell (Admin)".

### 1.2 Cài WSL kèm Ubuntu

```powershell
wsl --install
```

Lệnh này cài WSL2 + Ubuntu 22.04 (mặc định) trong 1 phát. Nếu đã có WSL nhưng chưa có distro:

```powershell
wsl --install -d Ubuntu-22.04
```

**Khởi động lại máy** khi nó bảo.

### 1.3 Hoàn tất setup Ubuntu

Sau khi reboot, Ubuntu tự mở lên. Nó sẽ hỏi:

- 1 **username** cho tài khoản Linux (đặt gì cũng được, chữ thường, không khoảng trắng — ví dụ `nate`)
- 1 **password** (chỉ dùng cho `sudo` trong Ubuntu; ít khi phải gõ)

Bạn đã có 1 terminal Linux hoạt động. Từ đây, **mọi lệnh taw-kit đều chạy trong terminal Ubuntu này**, không phải PowerShell.

### 1.4 Xác nhận WSL2

Quay lại PowerShell (admin), check chắc bạn đang ở WSL2 (không phải WSL1):

```powershell
wsl -l -v
```

Bạn sẽ thấy kiểu:

```
  NAME            STATE           VERSION
* Ubuntu          Running         2
```

Nếu VERSION là `1`, upgrade:

```powershell
wsl --set-version Ubuntu 2
```

---

## Phần 2 — Cài prerequisites trong Ubuntu (~3 phút)

Mở **Ubuntu** (search "Ubuntu" ở Start menu). Từ đây mọi lệnh đều gõ **trong Ubuntu**.

### 2.1 Update package

```bash
sudo apt update && sudo apt upgrade -y
```

(Lần đầu sẽ hỏi password Ubuntu.)

### 2.2 Cài công cụ cốt lõi

```bash
sudo apt install -y git curl build-essential jq
```

- `git` — quản lý version
- `curl` — tải file
- `build-essential` — compiler (cần cho vài package npm)
- `jq` — xử lý JSON (bộ merge settings của taw-kit cần)

### 2.3 Cài Node.js (v20 LTS)

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
node --version   # phải in v20.x.x
```

### 2.4 Cài Claude Code

Trong Ubuntu:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

Sau khi cài, login 1 lần:

```bash
claude login
```

1 tab trình duyệt Windows sẽ mở — bấm Accept, quay lại Ubuntu. Xong.

Xác nhận:

```bash
claude --version
```

---

## Phần 3 — Cài taw-kit (~1 phút)

Vẫn trong Ubuntu:

```bash
# Clone
git clone https://github.com/nghiahsgs/taw-kit.git ~/.taw-kit

# Cài
bash ~/.taw-kit/scripts/install.sh
```

Installer tự nhận WSL và đi theo nhánh Linux. Bạn sẽ thấy output kiểu:

```
[info] OS detected: wsl
[ok]   installed skills, agents, and hooks into /home/nate/.claude
[ok]   merged settings.json (existing keys preserved)
[ok]   appended tool-bootstrap section to ~/.claude/CLAUDE.md
[ok]   /taw skill installed
...
[ok]   doctor: all checks passed
[ok]   taw-kit is ready. Open Claude Code and try: /taw <describe what you want to build>
```

---

## Phần 4 — Chạy thử lần đầu

```bash
mkdir my-first-project && cd my-first-project
claude
```

Claude Code mở lên, gõ:

```
/taw làm landing page bán khoá học
```

Nếu thấy agent planner → researcher → fullstack-dev spawn theo thứ tự là xong.

---

## Tuỳ chọn: cài `ast-grep` để điều tra code nhanh hơn

Không bắt buộc — Claude sẽ hỏi bạn sau nếu thật sự cần. Nhưng muốn cài trước thì:

```bash
sudo apt install cargo -y    # package manager của Rust
cargo install ast-grep
export PATH="$HOME/.cargo/bin:$PATH"   # thêm vào ~/.bashrc để giữ lâu dài
```

Xác nhận:

```bash
sg --version
```

---

## Sửa file bằng VS Code

Không cần học `nano` hay `vim` — VS Code Windows mở được file trong WSL trực tiếp.

1. Cài [WSL extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl) trong VS Code.
2. Từ Ubuntu: `code ~/my-first-project` — VS Code mở folder WSL.
3. Sửa file bình thường; terminal trong VS Code chạy trong WSL.

App Windows khác cũng vậy: đường dẫn `\\wsl$\Ubuntu\home\<username>\my-first-project` truy cập được từ File Explorer.

---

## Khắc phục sự cố

### "wsl: command not found" trong PowerShell

Bạn đang ở Windows 10 build cũ hơn 2004. Update Windows, hoặc bật WSL thủ công qua Control Panel → Programs → Turn Windows features on/off → Windows Subsystem for Linux.

### Installer báo `detect-os.sh: unsupported`

Shell của bạn không phải bash. Check bạn đang ở trong Ubuntu (`echo $SHELL` phải in `/bin/bash`), không phải PowerShell hay Git Bash. Mở lại bằng icon Ubuntu ở Start menu.

### `claude: command not found` sau khi cài

Đóng và mở lại Ubuntu. Nếu vẫn thiếu:

```bash
source ~/.bashrc
# hoặc
export PATH="$HOME/.local/bin:$PATH"
```

Thêm dòng `export` đó vào `~/.bashrc` để giữ lâu dài.

### `jq: command not found` khi cài

Bạn bỏ qua bước 2.2. Chạy:

```bash
sudo apt install jq -y
bash ~/.taw-kit/scripts/install.sh   # chạy lại, idempotent
```

### Thao tác file chậm khi dự án nằm ở `/mnt/c/`

WSL2 truy cập file trong filesystem Linux (`~/` hoặc `/home/`) nhanh hơn nhiều so với ổ Windows mount (`/mnt/c/`). Luôn giữ dự án taw-kit trong `~/` ở Ubuntu, đừng để ở `C:\Users\...`.

### Deploy `vercel` đòi login mỗi lần

Deploy lần đầu từ WSL mở trình duyệt Windows; token lưu trong `~/.vercel/` của WSL. Nếu Vercel cứ hỏi lại, xoá `~/.vercel/` rồi chạy lại 1 lần.

---

## Cách B — Copy thủ công (không cần WSL, không cần cài gì thêm)

> **Dành cho ai:** Windows không cho cài WSL (máy công ty khoá, Windows cũ), hoặc chỉ muốn xài `/taw` nhanh mà không cần cả bộ kit.
>
> **Cái này chạy được:** `/taw`, tất cả skills, tất cả agents trong Claude Code.
>
> **Cái này KHÔNG có:** lệnh `tawkit` (doctor / update / uninstall), hooks auto-commit, installer tự merge settings.

### Bước 1 — Cài Claude Code cho Windows

Tải và cài từ [docs.claude.com/claude-code](https://docs.claude.com/claude-code). Mở 1 lần, login xong là được.

### Bước 2 — Tải taw-kit về máy

Vào [github.com/nghiahsgs/taw-kit](https://github.com/nghiahsgs/taw-kit) → nút xanh **Code** → **Download ZIP**. Giải nén ra 1 chỗ bất kỳ (vd `C:\Users\YourName\Downloads\taw-kit-main\`).

Hoặc nếu có Git:

```powershell
git clone https://github.com/nghiahsgs/taw-kit.git "%USERPROFILE%\taw-kit"
```

### Bước 3 — Copy 2 thư mục vào `.claude`

Mở File Explorer, gõ vào thanh địa chỉ:

```
%USERPROFILE%\.claude
```

Nhấn Enter. Nếu chưa có thư mục `.claude` thì tạo mới.

Bên trong `.claude`, copy 2 thư mục sau từ taw-kit đã tải về:

| Copy từ | Vào |
|---------|-----|
| `taw-kit-main\skills\*` | `%USERPROFILE%\.claude\skills\` |
| `taw-kit-main\agents\*` | `%USERPROFILE%\.claude\agents\` |

Xong. Không cần cài gì thêm.

### Bước 4 — Mở Claude Code và thử

Mở 1 folder trống bất kỳ trong Claude Code, gõ:

```
/taw làm landing page bán khoá học online
```

Nếu thấy agent planner → researcher → fullstack-dev chạy thì đã thành công.

### Giới hạn của cách này

- Không có lệnh `tawkit doctor` để check môi trường — tự đảm bảo máy có **Node.js ≥ 20** và **git** đã cài (tải tại [nodejs.org](https://nodejs.org) và [git-scm.com](https://git-scm.com/download/win))
- Không có auto-commit hook — bạn tự `git commit` sau mỗi phase
- Muốn update thì tự tải ZIP mới rồi copy đè 2 thư mục

Khi nào rảnh hoặc cần full feature, quay lại làm Phần 1 ở đầu file để cài WSL2.

---

## Cách C — Git Bash (thử nghiệm, KHÔNG khuyên dùng)

Nếu bạn tuyệt đối không dùng được WSL2 (máy công ty khoá, Windows cũ), có thể thử Git Bash. Cách này chưa được test kỹ và có khả năng hỏng ở vài script. Bạn tự chịu rủi ro.

1. Cài [Git for Windows](https://git-scm.com/download/win) — ship kèm Git Bash
2. Cài jq: `scoop install jq` (cài [Scoop](https://scoop.sh/) trước)
3. Mở Git Bash và chạy: `bash ~/.taw-kit/scripts/install.sh`

Lỗi đã biết trên Git Bash:

- Permission hook có thể không kích hoạt (Git Bash không emulate đủ permission Linux)
- Auto-commit hook có thể chạy khác
- CLI `tawkit` có thể không symlink đúng; phải gọi bằng full path
- Không đảm bảo support — bug report từ Git Bash được ưu tiên thấp

Nếu hỏng, chuyển sang WSL2. Chỉ thêm 10 phút nhưng đỡ đau đầu rất nhiều.

---

## Gỡ cài đặt

Trong Ubuntu:

```bash
bash ~/.taw-kit/scripts/uninstall.sh
# Hoặc, để xoá luôn repo đã clone:
bash ~/.taw-kit/scripts/uninstall.sh --full
```

Gỡ hẳn WSL (xoá Ubuntu và mọi file của nó):

```powershell
wsl --unregister Ubuntu
```

---

## Checklist tóm tắt

- [ ] Windows 10 build 2004+ hoặc Windows 11
- [ ] Đã cài WSL2 + Ubuntu
- [ ] Đã chạy `sudo apt install git curl build-essential jq -y` trong Ubuntu
- [ ] Đã cài Node.js v20 trong Ubuntu
- [ ] `claude login` thành công trong Ubuntu
- [ ] `bash ~/.taw-kit/scripts/install.sh` báo `[ok] doctor: all checks passed`
- [ ] `/taw <mô tả>` trong Claude Code có spawn agent

Tick đủ 7 ô là bạn sẵn sàng chạy production.
