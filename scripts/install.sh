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
  macos|linux|wsl) info "OS detected: $OS" ;;
  *) err "unsupported OS: $OS. Requires macOS, Linux, or WSL2."; exit 2 ;;
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
    ok "merged settings.json (existing keys preserved)"
  else
    warn "jq not installed — skipping auto-merge. Copy hooks from templates/settings.json.tmpl into $SETTINGS manually"
    info "install jq: brew install jq  (Mac)  or  sudo apt install jq  (Linux)"
  fi
else
  printf '%s\n' "$rendered" > "$SETTINGS"
  ok "created $SETTINGS"
fi

# --- 3. Symlink tawkit to /usr/local/bin ---
TARGET="/usr/local/bin/tawkit"
SOURCE="$TAW_ROOT/scripts/tawkit"

if [ -w "$(dirname "$TARGET")" ] 2>/dev/null; then
  ln -sf "$SOURCE" "$TARGET" && ok "symlinked $TARGET -> $SOURCE"
elif command -v sudo >/dev/null 2>&1; then
  info "sudo required to create symlink at $TARGET"
  if sudo ln -sf "$SOURCE" "$TARGET" 2>/dev/null; then
    ok "symlinked $TARGET -> $SOURCE"
  else
    warn "symlink failed. Add to PATH manually:"
    info "  echo 'export PATH=\"$TAW_ROOT/scripts:\$PATH\"' >> ~/.zshrc && source ~/.zshrc"
  fi
else
  warn "cannot create symlink. Add to PATH manually:"
  info "  echo 'export PATH=\"$TAW_ROOT/scripts:\$PATH\"' >> ~/.zshrc && source ~/.zshrc"
fi

# --- 4. Ensure hooks are executable ---
chmod +x "$HOME/.claude/hooks/"*.sh 2>/dev/null || true

# --- 5. Run doctor at end ---
info "running install checks..."
bash "$TAW_ROOT/scripts/doctor.sh" || true

ok "taw-kit is ready. Open Claude Code and try: /taw <describe what you want to build>"
