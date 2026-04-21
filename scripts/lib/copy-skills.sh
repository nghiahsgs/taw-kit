#!/usr/bin/env bash
# Copy taw-kit skills, agents, and hooks into ~/.claude/ without clobbering
# the user's own (non-taw-prefixed) content.
#
# Strategy:
#   - skills/taw-*/        → always overwrite (ours)
#   - skills/<other>/      → overwrite only if dir does not exist OR was ours
#                            (tracked by marker file .taw-kit-owned)
#   - agents/{planner,researcher,fullstack-dev,tester,reviewer}.md
#                          → overwrite (ours)
#   - hooks/*.sh           → overwrite (ours; names start with taw-kit patterns)
#
# Prune: skills with the `.taw-kit-owned` marker that no longer exist in the
# repo source are removed. This keeps the live install in sync after the kit
# drops or renames a skill. User-authored skills (no marker) are never touched.
#
# Usage: bash scripts/lib/copy-skills.sh <TAW_ROOT>

set -eu

TAW_ROOT="${1:-$PWD}"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
MARKER=".taw-kit-owned"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=log.sh
. "$SCRIPT_DIR/log.sh"

mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents" "$CLAUDE_DIR/hooks"

# Copy a skill dir, writing the marker
_copy_skill() {
  local src="$1" name; name="$(basename "$src")"
  local dst="$CLAUDE_DIR/skills/$name"
  if [ -d "$dst" ] && [ ! -f "$dst/$MARKER" ] && [[ "$name" != taw* ]]; then
    warn "skipping $name (exists and is not owned by taw-kit)"
    return 0
  fi
  mkdir -p "$dst"
  # shellcheck disable=SC2086
  cp -R "$src"/. "$dst"/
  touch "$dst/$MARKER"
}

# --- Copy skills from repo into live install ---
for d in "$TAW_ROOT"/skills/*/; do
  [ -d "$d" ] || continue
  _copy_skill "${d%/}"
done

# --- Prune: owned skills that disappeared from the repo source ---
pruned=0
for d in "$CLAUDE_DIR"/skills/*/; do
  [ -d "$d" ] || continue
  name="$(basename "${d%/}")"
  [ -f "$d/$MARKER" ] || continue           # not ours, skip
  [ -d "$TAW_ROOT/skills/$name" ] && continue  # still in repo, keep
  rm -rf "$d"
  pruned=$((pruned+1))
done
[ "$pruned" -gt 0 ] && ok "pruned $pruned skill(s) no longer in taw-kit"

# --- Agents — always overwrite (we own these names) ---
for a in "$TAW_ROOT"/agents/*.md; do
  [ -f "$a" ] || continue
  cp "$a" "$CLAUDE_DIR/agents/$(basename "$a")"
done

# --- Hooks — always overwrite; preserve exec bit ---
for h in "$TAW_ROOT"/hooks/*.sh; do
  [ -f "$h" ] || continue
  cp "$h" "$CLAUDE_DIR/hooks/$(basename "$h")"
  chmod +x "$CLAUDE_DIR/hooks/$(basename "$h")"
done

ok "installed skills, agents, and hooks into $CLAUDE_DIR"
