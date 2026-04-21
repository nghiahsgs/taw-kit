#!/usr/bin/env bash
# tawkit uninstall — remove taw-kit files from ~/.claude/ without touching
# user's own skills. Optionally also remove the cloned repo at ~/.taw-kit/.
#
# Usage:
#   tawkit uninstall            # remove ~/.claude/ taw-kit files, keep ~/.taw-kit/
#   tawkit uninstall --full     # also remove ~/.taw-kit/
#   tawkit uninstall --yes      # skip confirmation prompt

set -eu

TAW_ROOT="${TAW_ROOT:-$HOME/.taw-kit}"
[ -f "$TAW_ROOT/scripts/uninstall.sh" ] || TAW_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/log.sh
. "$TAW_ROOT/scripts/lib/log.sh"

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
MARKER=".taw-kit-owned"

FULL=0
ASSUME_YES=0
for a in "$@"; do
  case "$a" in
    --full) FULL=1 ;;
    --yes|-y) ASSUME_YES=1 ;;
    --help|-h)
      cat <<EOF
tawkit uninstall — go bo taw-kit khoi may

Co 2 muc do:
  tawkit uninstall           Go skills, agents, hooks khoi ~/.claude/
                             Giu lai ~/.taw-kit/ (de cai lai nhanh sau nay)
  tawkit uninstall --full    Go TAT CA, ke ca ~/.taw-kit/

Tuy chon:
  --yes / -y                 Khong hoi xac nhan
  --help / -h                In huong dan nay

Skills ca nhan cua ban (khong phai cua taw-kit) se khong bi dong toi.
EOF
      exit 0 ;;
  esac
done

# --- Confirm ---
if [ "$ASSUME_YES" -eq 0 ]; then
  info "Sap go bo taw-kit khoi $CLAUDE_DIR"
  [ "$FULL" -eq 1 ] && warn "--full: se xoa luon $TAW_ROOT"
  printf "Tiep tuc? (yes/no): "
  read -r ans
  case "$ans" in
    yes|y|Yes|YES|co) ;;
    *) info "da huy"; exit 0 ;;
  esac
fi

removed_count=0

# --- 1. Remove skills with our marker ---
if [ -d "$CLAUDE_DIR/skills" ]; then
  for d in "$CLAUDE_DIR/skills"/*/; do
    [ -d "$d" ] || continue
    if [ -f "$d/$MARKER" ]; then
      rm -rf "$d"
      removed_count=$((removed_count+1))
    fi
  done
  ok "da go $removed_count skill cua taw-kit"
fi

# --- 2. Remove our agents by known name ---
agent_count=0
for a in planner researcher fullstack-dev tester reviewer; do
  f="$CLAUDE_DIR/agents/$a.md"
  if [ -f "$f" ]; then
    rm -f "$f"
    agent_count=$((agent_count+1))
  fi
done
if [ "$agent_count" -gt 0 ]; then
  ok "da go $agent_count agent cua taw-kit"
  warn "neu ban co ban 'planner/researcher/fullstack-dev/tester/reviewer' rieng truoc khi cai, ban do da bi ghi de luc install. Kiem tra ~/.claude_bk hoac ~/.claude_taw-test neu co."
fi

# --- 3. Remove our hooks by known name ---
hook_count=0
for h in session-start-context post-tool-auto-commit permission-classifier rtk-wrapper; do
  f="$CLAUDE_DIR/hooks/$h.sh"
  if [ -f "$f" ]; then
    rm -f "$f"
    hook_count=$((hook_count+1))
  fi
done
[ "$hook_count" -gt 0 ] && ok "da go $hook_count hook"

# --- 4. Strip taw keys from settings.json ---
SETTINGS="$CLAUDE_DIR/settings.json"
if [ -f "$SETTINGS" ]; then
  if command -v jq >/dev/null 2>&1; then
    tmp="$(mktemp)"
    # Remove hook entries referencing taw-kit hook files + env.TAW_*
    jq '
      .hooks |= (
        if . == null then null
        else
          with_entries(
            .value |= (
              if type == "array" then
                map(select((.command // "") | test("taw-kit|/\\.claude/hooks/(session-start-context|post-tool-auto-commit|permission-classifier|rtk-wrapper)\\.sh") | not))
              else . end
            )
          )
          | to_entries
          | map(select((.value | length // 1) > 0 or (.value | type) != "array"))
          | from_entries
        end
      )
      | .env |= (if . == null then null else with_entries(select(.key | startswith("TAW_") | not)) end)
    ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
    ok "da clean settings.json (giu nguyen cac key khac)"
  else
    warn "khong co jq — settings.json khong tu dong clean. Sua tay $SETTINGS neu can"
  fi
fi

# --- 5. Remove symlink if exists ---
LINK="/usr/local/bin/tawkit"
if [ -L "$LINK" ]; then
  if rm -f "$LINK" 2>/dev/null; then
    ok "da go symlink $LINK"
  elif command -v sudo >/dev/null 2>&1 && sudo rm -f "$LINK" 2>/dev/null; then
    ok "da go symlink $LINK"
  else
    warn "khong go duoc $LINK. Xoa tay: sudo rm $LINK"
  fi
fi

# --- 6. Remove kit cache ---
rm -rf "$HOME/.taw-kit/.rtk-available" 2>/dev/null || true

# --- 7. --full: remove ~/.taw-kit/ ---
if [ "$FULL" -eq 1 ] && [ -d "$TAW_ROOT" ]; then
  # Safety: only remove if it's a git repo with our marker (sanity)
  if [ -d "$TAW_ROOT/.git" ] && [ -f "$TAW_ROOT/VERSION" ]; then
    rm -rf "$TAW_ROOT"
    ok "da xoa $TAW_ROOT"
  else
    warn "$TAW_ROOT khong giong clone taw-kit — bo qua (xoa tay neu muon)"
  fi
fi

ok "da go bo xong. Chuc ngay vui."
