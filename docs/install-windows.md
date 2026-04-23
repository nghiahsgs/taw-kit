# Install taw-kit on Windows

> **TL;DR** — taw-kit's installer is a bash script. On Windows you need a Linux-compatible shell. The recommended way is **WSL2** (Windows Subsystem for Linux). This takes ~10 minutes the first time, then `/taw` works exactly like on Mac or Linux.

---

## Why WSL2, not cmd / PowerShell?

taw-kit ships with ~50 bash scripts (install, doctor, hooks, the `tawkit` CLI). Rewriting all of them for PowerShell would double maintenance and almost guarantee drift. Instead, we use WSL2 — Microsoft's official Linux layer inside Windows — so the **same** scripts run unchanged.

Benefits of this approach:

- Same scripts, same skills, same behaviour as Mac/Linux users
- Access to `apt`, `git`, `node`, `brew` (optional), all the standard Unix tooling
- Claude Code itself runs inside WSL with full performance
- You can still edit files from VS Code / any Windows editor — `\\wsl$\Ubuntu\home\you\...` is accessible

---

## Part 1 — Install WSL2 + Ubuntu (first time only, ~5 minutes)

### 1.1 Open PowerShell as Administrator

Press `Win + X`, choose "Windows Terminal (Admin)" or "PowerShell (Admin)".

### 1.2 Install WSL with Ubuntu

```powershell
wsl --install
```

This installs WSL2 + Ubuntu 22.04 (default) in one command. If you already have WSL but no distro:

```powershell
wsl --install -d Ubuntu-22.04
```

**Reboot the machine** when prompted.

### 1.3 Finish Ubuntu setup

After reboot, Ubuntu launches automatically in a window. It asks for:

- A **username** for your Linux account (anything you like, lowercase, no spaces — e.g. `nate`)
- A **password** (this is only for `sudo` inside Ubuntu; you'll use it rarely)

You now have a working Linux terminal. From now on, **every taw-kit command runs inside this Ubuntu terminal**, not in PowerShell.

### 1.4 Verify WSL2

Back in PowerShell (admin), confirm you're on WSL2 (not WSL1):

```powershell
wsl -l -v
```

You should see something like:

```
  NAME            STATE           VERSION
* Ubuntu          Running         2
```

If VERSION says `1`, upgrade:

```powershell
wsl --set-version Ubuntu 2
```

---

## Part 2 — Install prerequisites inside Ubuntu (~3 minutes)

Open **Ubuntu** (search "Ubuntu" in the Start menu). From here on, every command is typed **inside Ubuntu**.

### 2.1 Update package lists

```bash
sudo apt update && sudo apt upgrade -y
```

(First time asks for your Ubuntu password.)

### 2.2 Install core tooling

```bash
sudo apt install -y git curl build-essential jq
```

- `git` — version control
- `curl` — downloader
- `build-essential` — compilers (needed for some npm packages)
- `jq` — JSON processor (required by taw-kit's settings merger)

### 2.3 Install Node.js (v20 LTS)

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
node --version   # should print v20.x.x
```

### 2.4 Install Claude Code

Inside Ubuntu:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

After install, log in once:

```bash
claude login
```

A browser opens on Windows — click Accept, return to Ubuntu. You're done.

Verify:

```bash
claude --version
```

---

## Part 3 — Install taw-kit (~1 minute)

Still inside Ubuntu:

```bash
# Clone
git clone https://github.com/nghiahsgs/taw-kit.git ~/.taw-kit

# Install
bash ~/.taw-kit/scripts/install.sh
```

The installer auto-detects WSL and proceeds the Linux path. You'll see output like:

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

## Part 4 — First run

```bash
mkdir my-first-project && cd my-first-project
claude
```

Once Claude Code opens, type:

```
/taw lam landing page ban khoa hoc
```

If you see planner → researcher → fullstack-dev agents spawn in order, you're set.

---

## Optional: install `ast-grep` for faster code investigation

Not required — Claude will ask you later if you actually need it. But if you want to pre-install:

```bash
sudo apt install cargo -y    # Rust's package manager
cargo install ast-grep
export PATH="$HOME/.cargo/bin:$PATH"   # add to ~/.bashrc to persist
```

Verify:

```bash
sg --version
```

---

## Editing files with VS Code

You don't need to use `nano` or `vim` — Windows VS Code can open files inside WSL natively.

1. Install the [WSL extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl) in VS Code.
2. From Ubuntu: `code ~/my-first-project` — VS Code opens with the WSL folder.
3. Edit files normally; terminal inside VS Code runs in WSL.

Same for any Windows app: the path `\\wsl$\Ubuntu\home\<username>\my-first-project` is accessible from File Explorer.

---

## Troubleshooting

### "wsl: command not found" in PowerShell

You're on Windows 10 older than build 2004. Update Windows or manually enable WSL via Control Panel → Programs → Turn Windows features on/off → Windows Subsystem for Linux.

### Installer errors `detect-os.sh: unsupported`

Your shell isn't bash. Check you're inside Ubuntu (`echo $SHELL` should print `/bin/bash`), not PowerShell or Git Bash. Re-enter via the Ubuntu icon in Start menu.

### `claude: command not found` after install

Close and reopen Ubuntu. If still missing:

```bash
source ~/.bashrc
# or
export PATH="$HOME/.local/bin:$PATH"
```

Add that `export` line to `~/.bashrc` to persist.

### `jq: command not found` during install

Skipped step 2.2. Run:

```bash
sudo apt install jq -y
bash ~/.taw-kit/scripts/install.sh   # re-run, idempotent
```

### Slow file operations when project is in `/mnt/c/`

WSL2 is much faster accessing files inside the Linux filesystem (`~/` or `/home/`) than on Windows-mounted drives (`/mnt/c/`). Always keep your taw-kit projects under `~/` in Ubuntu, not on `C:\Users\...`.

### `deploy` target `vercel` asks to login every time

First deploy from WSL opens a Windows browser; the token is stored in WSL's `~/.vercel/`. If Vercel keeps asking, delete `~/.vercel/` and re-run once.

---

## Option B — Copy thủ công (không cần WSL, không cần cài gì thêm)

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

Khi nào rảnh hoặc cần full feature, quay lại làm Part 1 ở đầu file để cài WSL2.

---

## Alternative: Git Bash (experimental, NOT recommended)

If you absolutely cannot use WSL2 (corporate lockdown, older Windows), you can try Git Bash. This is untested and likely to break on some scripts. Proceed at your own risk.

1. Install [Git for Windows](https://git-scm.com/download/win) — ships with Git Bash
2. Install jq: `scoop install jq` (install [Scoop](https://scoop.sh/) first)
3. Open Git Bash and run: `bash ~/.taw-kit/scripts/install.sh`

Known issues on Git Bash:

- Permission hooks may not fire (Git Bash doesn't fully emulate Linux permissions)
- Auto-commit hook may behave differently
- The `tawkit` CLI may not symlink correctly; invoke via full path instead
- No support guaranteed — bug reports from Git Bash installs get lower priority

If things break, switch to WSL2. It's 10 extra minutes for dramatically fewer headaches.

---

## Uninstall

Inside Ubuntu:

```bash
bash ~/.taw-kit/scripts/uninstall.sh
# Or, to also delete the cloned repo:
bash ~/.taw-kit/scripts/uninstall.sh --full
```

To uninstall WSL entirely (removes Ubuntu and all its files):

```powershell
wsl --unregister Ubuntu
```

---

## Summary checklist

- [ ] Windows 10 build 2004+ or Windows 11
- [ ] WSL2 + Ubuntu installed
- [ ] `sudo apt install git curl build-essential jq -y` done in Ubuntu
- [ ] Node.js v20 installed in Ubuntu
- [ ] `claude login` successful in Ubuntu
- [ ] `bash ~/.taw-kit/scripts/install.sh` reports `[ok] doctor: all checks passed`
- [ ] `/taw <prose>` in a Claude Code session spawns agents

If all 7 boxes are ticked, you're production-ready.
