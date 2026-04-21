#!/usr/bin/env bash
# taw-kit — public one-liner bootstrap installer.
# Invoked by: curl -fsSL https://install.tawkit.vn | bash
#
# Responsibilities:
#   1. detect OS and abort cleanly on Windows (non-WSL)
#   2. ensure prerequisites: git, node ≥ 20, claude, gh
#   3. authenticate to GitHub (device flow) if not already
#   4. clone the private taw-kit repo into ~/.taw-kit/
#   5. hand off to the in-repo install.sh
#
# Colors + VN prefixes inline (cannot source lib before clone).

set -euo pipefail

# --- Colors ---
if [ -t 1 ] && [ "${NO_COLOR:-}" != "1" ]; then
  C_RED=$'\033[31m'; C_YEL=$'\033[33m'; C_GRN=$'\033[32m'; C_CYA=$'\033[36m'; C_OFF=$'\033[0m'
else
  C_RED=''; C_YEL=''; C_GRN=''; C_CYA=''; C_OFF=''
fi
info() { printf '%s[i]%s %s\n' "$C_CYA" "$C_OFF" "$*"; }
ok()   { printf '%s[ok]%s %s\n' "$C_GRN" "$C_OFF" "$*"; }
warn() { printf '%s[canh bao]%s %s\n' "$C_YEL" "$C_OFF" "$*" >&2; }
fail() { printf '%s[loi]%s %s\n' "$C_RED" "$C_OFF" "$*" >&2; exit "${2:-1}"; }

# --- Owner / repo constants ---
REPO_OWNER="${TAW_REPO_OWNER:-andienguyen-ecoligo}"
REPO_NAME="${TAW_REPO_NAME:-taw-kit}"
CLONE_DEST="$HOME/.taw-kit"
BUY_URL="https://taw-kit.dev/buy"

# --- 1. OS detection ---
kernel="$(uname -s 2>/dev/null || echo unknown)"
case "$kernel" in
  Darwin) OS="macos" ;;
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then OS="wsl"; else OS="linux"; fi
    ;;
  MINGW*|MSYS*|CYGWIN*)
    fail "Windows truc tiep chua ho tro. Vui long dung WSL2: https://taw-kit.dev/docs/vi/wsl2" 2
    ;;
  *) fail "He dieu hanh la: $kernel (chua ho tro)" 2 ;;
esac
info "He dieu hanh: $OS"

# --- 2. Prerequisites ---

_install_hint() {
  case "$1:$OS" in
    git:macos)      echo "brew install git" ;;
    git:linux)      echo "sudo apt install -y git" ;;
    git:wsl)        echo "sudo apt install -y git" ;;
    node:macos)     echo "brew install node" ;;
    node:linux|node:wsl) echo "curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt install -y nodejs" ;;
    claude:*)       echo "npm install -g @anthropic-ai/claude-code" ;;
    gh:macos)       echo "brew install gh" ;;
    gh:linux|gh:wsl) echo "sudo apt install -y gh" ;;
  esac
}

_need() {
  local tool="$1" cmd="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$tool: da cai"
    return 0
  fi
  warn "$tool chua cai"
  hint="$(_install_hint "$tool")"
  info "chay lenh: $hint"
  # Attempt auto-install if simple
  case "$tool" in
    claude) eval "$hint" && ok "$tool: cai xong" ;;
    gh|git|node)
      info "Yeu cau cai tay. Chay lenh tren roi chay lai script nay."
      fail "thieu $tool" 3
      ;;
  esac
}

_need git     git
_need node    node
_need claude  claude
_need gh      gh

# Node version check
node_major="$(node --version 2>/dev/null | sed 's/^v//' | cut -d. -f1)"
if [ "${node_major:-0}" -lt 20 ]; then
  fail "Node.js v$node_major qua cu. Can v20 tro len. Cai lai: https://nodejs.org" 3
fi

# --- 3. GitHub auth ---
if ! gh auth status >/dev/null 2>&1; then
  info "Chua dang nhap GitHub. Bat dau dang nhap..."
  gh auth login --web --git-protocol https || fail "dang nhap GitHub that bai" 1
fi
ok "GitHub: da dang nhap"

# --- 4. Clone repo ---
if [ -d "$CLONE_DEST/.git" ]; then
  info "$CLONE_DEST da ton tai; cap nhat thay vi clone moi"
  ( cd "$CLONE_DEST" && git pull --ff-only ) || fail "git pull that bai" 1
else
  info "Dang clone $REPO_OWNER/$REPO_NAME vao $CLONE_DEST..."
  if ! gh repo clone "$REPO_OWNER/$REPO_NAME" "$CLONE_DEST" 2>/tmp/taw-clone-err; then
    errmsg="$(cat /tmp/taw-clone-err 2>/dev/null || echo '')"
    if printf '%s' "$errmsg" | grep -qi 'not found\|denied\|403\|404'; then
      warn "khong co quyen vao repo $REPO_OWNER/$REPO_NAME"
      info "Co the ban chua mua taw-kit. Mua tai: $BUY_URL"
      info "Neu ban da mua, kiem tra email xac nhan moi vao repo."
      fail "khong truy cap duoc repo" 1
    else
      fail "clone loi: $errmsg" 1
    fi
  fi
fi
ok "Clone: xong"

# --- 5. Hand off to in-repo install.sh ---
info "Chuyen sang buoc 2: cai skills va agents vao ~/.claude/..."
bash "$CLONE_DEST/scripts/install.sh"

# --- 6. Celebration ---
cat <<EOF

${C_GRN}=============================================${C_OFF}
${C_GRN}  taw-kit da san sang.${C_OFF}
${C_GRN}=============================================${C_OFF}

Mo Claude Code, vao mot thu muc moi, va go:

  ${C_CYA}/taw lam cho toi landing page ban ca phe${C_OFF}

Video 5 phut huong dan:  https://taw-kit.dev/docs/vi/quickstart
Tai lieu day du:         https://taw-kit.dev/docs
Ho tro:                  https://taw-kit.dev/support

EOF
