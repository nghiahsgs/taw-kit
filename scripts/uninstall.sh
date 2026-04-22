#!/usr/bin/env bash
# tawkit uninstall — remove taw-kit files from ~/.claude/ without touching
# the user's own skills. Optionally also remove the cloned repo at ~/.taw-kit/.
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
tawkit uninstall — remove taw-kit from your machine

Two levels:
  tawkit uninstall           Remove skills, agents, and hooks from ~/.claude/
                             Keep ~/.taw-kit/ (for quick reinstall later)
  tawkit uninstall --full    Remove EVERYTHING, including ~/.taw-kit/

Options:
  --yes / -y                 Skip the confirmation prompt
  --help / -h                Show this help

Your personal skills (not owned by taw-kit) are never touched.
EOF
      exit 0 ;;
  esac
done

# --- Confirm ---
if [ "$ASSUME_YES" -eq 0 ]; then
  info "About to remove taw-kit from $CLAUDE_DIR"
  [ "$FULL" -eq 1 ] && warn "--full: will also delete $TAW_ROOT"
  printf "Continue? (yes/no): "
  read -r ans
  case "$ans" in
    yes|y|Yes|YES) ;;
    *) info "cancelled"; exit 0 ;;
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
  ok "removed $removed_count taw-kit skill(s)"
fi

# --- 2. Remove our agents by known name ---
agent_count=0
for a in planner researcher fullstack-dev mobile-dev tester reviewer; do
  f="$CLAUDE_DIR/agents/$a.md"
  if [ -f "$f" ]; then
    rm -f "$f"
    agent_count=$((agent_count+1))
  fi
done
if [ "$agent_count" -gt 0 ]; then
  ok "removed $agent_count taw-kit agent(s)"
  warn "if you had your own 'planner/researcher/fullstack-dev/mobile-dev/tester/reviewer' before install, those were overwritten. Check any ~/.claude backup dir you may have kept."
fi

# --- 2b. Strip tool-bootstrap block from ~/.claude/CLAUDE.md ---
USER_CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
if [ -f "$USER_CLAUDE_MD" ] && grep -q "taw-kit:tool-bootstrap:begin" "$USER_CLAUDE_MD"; then
  awk '
    /<!-- taw-kit:tool-bootstrap:begin -->/ { skip=1; next }
    /<!-- taw-kit:tool-bootstrap:end -->/   { skip=0; next }
    !skip                                   { print }
  ' "$USER_CLAUDE_MD" > "$USER_CLAUDE_MD.new" && mv "$USER_CLAUDE_MD.new" "$USER_CLAUDE_MD"
  # If file is now empty or only blank lines, delete it entirely
  if [ ! -s "$USER_CLAUDE_MD" ] || ! grep -q '[^[:space:]]' "$USER_CLAUDE_MD"; then
    rm -f "$USER_CLAUDE_MD"
    ok "removed empty ~/.claude/CLAUDE.md"
  else
    ok "stripped tool-bootstrap section from ~/.claude/CLAUDE.md"
  fi
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
[ "$hook_count" -gt 0 ] && ok "removed $hook_count hook(s)"

# --- 4. Strip taw keys from settings.json ---
# Schema: hooks.<Event>[].hooks[].command — strip inner hook entries whose
# command references a taw-kit hook script. Drop matcher entries with empty
# inner hooks arrays. Drop event keys with empty arrays. Drop hooks key if
# entire object becomes empty. Strip env.TAW_* keys.
SETTINGS="$CLAUDE_DIR/settings.json"
TAW_HOOK_PATTERN='taw-kit|/\.claude/hooks/(session-start-context|post-tool-auto-commit|permission-classifier|rtk-wrapper)\.sh'
if [ -f "$SETTINGS" ]; then
  if command -v jq >/dev/null 2>&1; then
    tmp="$(mktemp)"
    jq --arg pat "$TAW_HOOK_PATTERN" '
      (.hooks // empty) |= (
        with_entries(
          .value |= (
            map(.hooks |= (map(select((.command // "") | test($pat) | not))))
            | map(select((.hooks | length) > 0))
          )
        )
        | with_entries(select((.value | length) > 0))
      )
      | if (.hooks // {}) == {} then del(.hooks) else . end
      | (.env // empty) |= with_entries(select(.key | startswith("TAW_") | not))
      | if (.env // {}) == {} then del(.env) else . end
      | del(.note | select(. != null and (contains("taw-kit"))))
    ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
    ok "cleaned settings.json (other keys preserved)"
  else
    warn "jq not installed — settings.json not auto-cleaned. Edit $SETTINGS manually if needed"
  fi
fi

# --- 5. Remove symlink if exists ---
LINK="/usr/local/bin/tawkit"
if [ -L "$LINK" ]; then
  if rm -f "$LINK" 2>/dev/null; then
    ok "removed symlink $LINK"
  elif command -v sudo >/dev/null 2>&1 && sudo rm -f "$LINK" 2>/dev/null; then
    ok "removed symlink $LINK"
  else
    warn "could not remove $LINK. Run manually: sudo rm $LINK"
  fi
fi

# --- 6. Remove kit cache ---
rm -rf "$HOME/.taw-kit/.rtk-available" 2>/dev/null || true

# --- 7. --full: remove ~/.taw-kit/ ---
if [ "$FULL" -eq 1 ] && [ -d "$TAW_ROOT" ]; then
  # Safety: only remove if it's a git repo with our marker (sanity)
  if [ -d "$TAW_ROOT/.git" ] && [ -f "$TAW_ROOT/VERSION" ]; then
    rm -rf "$TAW_ROOT"
    ok "removed $TAW_ROOT"
  else
    warn "$TAW_ROOT does not look like a taw-kit clone — skipping (delete manually if you really want to)"
  fi
fi

ok "uninstall complete. Have a nice day."
