#!/usr/bin/env bash
# tawkit update — pull latest kit, re-run install steps, show changelog diff.

set -eu

TAW_ROOT="${TAW_ROOT:-$HOME/.taw-kit}"
# shellcheck source=lib/log.sh
. "$TAW_ROOT/scripts/lib/log.sh"

if [ ! -d "$TAW_ROOT/.git" ]; then
  err "$TAW_ROOT is not a git repo. Reinstall: curl -fsSL https://install.tawkit.dev | bash"
  exit 2
fi

cd "$TAW_ROOT"

OLD_VERSION="$(cat VERSION 2>/dev/null || echo 'unknown')"

info "fetching latest version..."
if ! git pull --ff-only 2>&1; then
  err "merge failed (you may have modified files in $TAW_ROOT)."
  info "try: tawkit doctor --reset  (back up your changes and re-merge)"
  exit 2
fi

NEW_VERSION="$(cat VERSION 2>/dev/null || echo 'unknown')"

if [ "$OLD_VERSION" = "$NEW_VERSION" ]; then
  ok "already on latest: $NEW_VERSION"
  exit 0
fi

info "version: $OLD_VERSION -> $NEW_VERSION"

# Re-run copy step so ~/.claude/ gets fresh files
bash "$TAW_ROOT/scripts/lib/copy-skills.sh" "$TAW_ROOT"

# Show changelog if present
if [ -f "$TAW_ROOT/CHANGELOG.md" ]; then
  info "what's new:"
  # Print section for new version if heading exists, else last 40 lines
  if grep -q "^## $NEW_VERSION" "$TAW_ROOT/CHANGELOG.md"; then
    awk "/^## $NEW_VERSION/{p=1;print;next} /^## /{if(p){exit}} p" "$TAW_ROOT/CHANGELOG.md"
  else
    tail -40 "$TAW_ROOT/CHANGELOG.md"
  fi
fi

ok "update complete. Restart Claude Code to pick up changes."
