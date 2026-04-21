#!/usr/bin/env bash
# tawkit update — pull latest kit, re-run install steps, show changelog diff.

set -eu

TAW_ROOT="${TAW_ROOT:-$HOME/.taw-kit}"
# shellcheck source=lib/log.sh
. "$TAW_ROOT/scripts/lib/log.sh"

if [ ! -d "$TAW_ROOT/.git" ]; then
  err "$TAW_ROOT khong phai git repo. Cai lai: curl -fsSL https://taw-kit.dev/install.sh | bash"
  exit 2
fi

cd "$TAW_ROOT"

OLD_VERSION="$(cat VERSION 2>/dev/null || echo 'unknown')"

info "lay ban cap nhat moi nhat..."
if ! git pull --ff-only 2>&1; then
  err "khong merge duoc (co the ban da sua file trong $TAW_ROOT)."
  info "thu: tawkit doctor --reset  (se backup thay doi cua ban va merge lai)"
  exit 2
fi

NEW_VERSION="$(cat VERSION 2>/dev/null || echo 'unknown')"

if [ "$OLD_VERSION" = "$NEW_VERSION" ]; then
  ok "da la ban moi nhat: $NEW_VERSION"
  exit 0
fi

info "phien ban moi: $OLD_VERSION -> $NEW_VERSION"

# Re-run copy step so ~/.claude/ gets fresh files
bash "$TAW_ROOT/scripts/lib/copy-skills.sh" "$TAW_ROOT"

# Show changelog if present
if [ -f "$TAW_ROOT/CHANGELOG.md" ]; then
  info "thay doi trong phien ban moi:"
  # Print section for new version if heading exists, else last 40 lines
  if grep -q "^## $NEW_VERSION" "$TAW_ROOT/CHANGELOG.md"; then
    awk "/^## $NEW_VERSION/{p=1;print;next} /^## /{if(p){exit}} p" "$TAW_ROOT/CHANGELOG.md"
  else
    tail -40 "$TAW_ROOT/CHANGELOG.md"
  fi
fi

ok "cap nhat xong. Khoi dong lai Claude Code de nhan thay doi."
