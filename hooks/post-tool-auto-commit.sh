#!/usr/bin/env bash
# taw-kit hook: PostToolUse (Write|Edit)
# Auto-commits file changes so non-devs never lose work. Opt-out via either
# TAW_NO_AUTOCOMMIT=1 or TAW_AUTO_COMMIT=0. Blocks commits that would include
# secrets (.env*, *.key, credentials).
# Exits 0 always.

set -u

LOG="${HOME}/.taw-kit/logs/hooks.log"
mkdir -p "$(dirname "$LOG")" 2>/dev/null || true
log() { printf '[%s] auto-commit: %s\n' "$(date -u +%FT%TZ)" "$1" >> "$LOG" 2>/dev/null || true; }

# Opt-out env vars
if [ "${TAW_NO_AUTOCOMMIT:-0}" = "1" ] || [ "${TAW_AUTO_COMMIT:-1}" = "0" ]; then
  log "disabled via env var; skip"
  exit 0
fi

# Must be inside a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  log "not a git repo; skip"
  exit 0
fi

# Debounce: skip if we auto-committed in the last N seconds. This avoids the
# "10 commits per minute" spam when Claude is doing rapid-fire edits. Tune with
# TAW_AUTOCOMMIT_DEBOUNCE_SECONDS (default 60).
DEBOUNCE="${TAW_AUTOCOMMIT_DEBOUNCE_SECONDS:-60}"
stamp_file=".git/.taw-last-autocommit"
now="$(date +%s)"
if [ -f "$stamp_file" ]; then
  last="$(cat "$stamp_file" 2>/dev/null || echo 0)"
  if [ $((now - last)) -lt "$DEBOUNCE" ]; then
    log "debounced (last commit was $((now - last))s ago; threshold ${DEBOUNCE}s)"
    exit 0
  fi
fi

# Block if sensitive files are staged or would be added
sensitive_patterns='^\.env($|\.)|\.key$|credentials|service[-_]account|/\.pem$'
candidates="$(git status --porcelain 2>/dev/null | awk '{print $2}')"
if [ -n "$candidates" ]; then
  if printf '%s\n' "$candidates" | grep -Eq "$sensitive_patterns"; then
    log "REFUSE commit — sensitive files in working tree: $candidates"
    exit 0
  fi
fi

# Nothing changed? nothing to do
if git diff --quiet && git diff --cached --quiet; then
  log "no diff; skip"
  exit 0
fi

# Stage everything not sensitive, commit with timestamp
git add -A >/dev/null 2>&1 || true

# Double-check after add (race)
if git diff --cached --name-only | grep -Eq "$sensitive_patterns"; then
  log "ABORT — sensitive file slipped into index; unstaging all"
  git reset >/dev/null 2>&1 || true
  exit 0
fi

msg="taw: auto-save $(date +%s)"
if git commit --no-verify -m "$msg" >/dev/null 2>&1; then
  log "committed: $msg"
  echo "$now" > "$stamp_file" 2>/dev/null || true
else
  log "commit failed (hook, probably nothing staged after filters)"
fi

exit 0
