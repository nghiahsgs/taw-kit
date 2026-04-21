#!/usr/bin/env bash
# taw-kit hook: RTK (Rust Token Killer) wrapper
# If RTK is installed, suggest commands that benefit from its compression.
# Passive: emits a one-line hint to the log; never blocks or rewrites.
# Exits 0 always.

set -u

LOG="${HOME}/.taw-kit/logs/hooks.log"
mkdir -p "$(dirname "$LOG")" 2>/dev/null || true
log() { printf '[%s] rtk-wrap: %s\n' "$(date -u +%FT%TZ)" "$1" >> "$LOG" 2>/dev/null || true; }

# Check once per session via cache file (avoid repeated `command -v`)
cache="${HOME}/.taw-kit/.rtk-available"
if [ ! -f "$cache" ]; then
  mkdir -p "$(dirname "$cache")" 2>/dev/null || true
  if command -v rtk >/dev/null 2>&1; then
    printf '1\n' > "$cache"
    log "RTK detected: $(command -v rtk)"
  else
    printf '0\n' > "$cache"
    log "RTK not installed; commands pass through unchanged"
  fi
fi

# Always exit 0 — this hook is advisory only
exit 0
