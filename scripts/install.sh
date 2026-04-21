#!/usr/bin/env bash
# tawkit install — idempotent local setup
# Copies skills/agents/hooks → ~/.claude/, merges settings, symlinks tawkit

set -eu

TAW_ROOT="${TAW_ROOT:-$HOME/.taw-kit}"
[ -f "$TAW_ROOT/scripts/install.sh" ] || TAW_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/log.sh
. "$TAW_ROOT/scripts/lib/log.sh"

OS="$(bash "$TAW_ROOT/scripts/lib/detect-os.sh")"
case "$OS" in
  macos|linux|wsl) info "He dieu hanh: $OS" ;;
  *) err "He dieu hanh chua ho tro: $OS. Can macOS, Linux, hoac WSL2."; exit 2 ;;
esac

# --- 1. Copy skills, agents, hooks ---
bash "$TAW_ROOT/scripts/lib/copy-skills.sh" "$TAW_ROOT"

# --- 2. Merge settings.json.tmpl into ~/.claude/settings.json ---
SETTINGS="$HOME/.claude/settings.json"
TMPL="$TAW_ROOT/templates/settings.json.tmpl"
VERSION="$(cat "$TAW_ROOT/VERSION" 2>/dev/null || echo '0.1.0')"

# Render template (substitute {{TAW_KIT_VERSION}})
rendered="$(sed "s/{{TAW_KIT_VERSION}}/$VERSION/g" "$TMPL")"

if [ -f "$SETTINGS" ]; then
  # Merge: preserve existing keys, add taw-kit keys. Needs jq.
  if command -v jq >/dev/null 2>&1; then
    tmp_file="$(mktemp)"
    printf '%s' "$rendered" > "$tmp_file"
    jq -s '.[0] * .[1]' "$SETTINGS" "$tmp_file" > "$SETTINGS.new" \
      && mv "$SETTINGS.new" "$SETTINGS" \
      && rm -f "$tmp_file"
    ok "da merge settings.json (giu nguyen cai cu)"
  else
    warn "khong co jq — khong merge tu dong. Ban can tay copy hooks tu templates/settings.json.tmpl vao $SETTINGS"
    info "cai jq: brew install jq (Mac) hoac sudo apt install jq (Linux)"
  fi
else
  printf '%s\n' "$rendered" > "$SETTINGS"
  ok "da tao $SETTINGS"
fi

# --- 3. Symlink tawkit to /usr/local/bin ---
TARGET="/usr/local/bin/tawkit"
SOURCE="$TAW_ROOT/scripts/tawkit"

if [ -w "$(dirname "$TARGET")" ] 2>/dev/null; then
  ln -sf "$SOURCE" "$TARGET" && ok "da symlink: $TARGET -> $SOURCE"
elif command -v sudo >/dev/null 2>&1; then
  info "can quyen sudo de tao symlink $TARGET"
  if sudo ln -sf "$SOURCE" "$TARGET" 2>/dev/null; then
    ok "da symlink: $TARGET -> $SOURCE"
  else
    warn "symlink that bai. Them vao PATH thu cong:"
    info "  echo 'export PATH=\"$TAW_ROOT/scripts:\$PATH\"' >> ~/.zshrc && source ~/.zshrc"
  fi
else
  warn "khong tao duoc symlink. Them vao PATH thu cong:"
  info "  echo 'export PATH=\"$TAW_ROOT/scripts:\$PATH\"' >> ~/.zshrc && source ~/.zshrc"
fi

# --- 4. Ensure hooks are executable ---
chmod +x "$HOME/.claude/hooks/"*.sh 2>/dev/null || true

# --- 5. Run doctor at end ---
info "dang kiem tra cai dat..."
bash "$TAW_ROOT/scripts/doctor.sh" || true

ok "taw-kit da san sang. Mo Claude Code va go: /taw <mo ta san pham bang tieng Viet>"
