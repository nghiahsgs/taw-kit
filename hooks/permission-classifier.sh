#!/usr/bin/env bash
# taw-kit hook: PreToolUse (Bash)
# Classifies a proposed bash command into allow / ask / deny so non-devs
# don't have to approve every npm install, but destructive ops still prompt.
#
# Input: Claude Code passes the tool-use JSON on stdin. We extract the command
#        string; if parsing fails we fall back to $1.
# Exit codes (Claude Code contract):
#   0 = allow (auto-approve)
#   1 = ask   (prompt user)
#   2 = deny  (block)

set -u

LOG="${HOME}/.taw-kit/logs/hooks.log"
mkdir -p "$(dirname "$LOG")" 2>/dev/null || true
log() { printf '[%s] perm-class: %s\n' "$(date -u +%FT%TZ)" "$1" >> "$LOG" 2>/dev/null || true; }

# Read command: prefer stdin JSON, fall back to $1
cmd=""
if [ -t 0 ]; then
  cmd="${1:-}"
else
  payload="$(cat)"
  cmd="$(printf '%s' "$payload" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
  [ -z "$cmd" ] && cmd="${1:-}"
fi

[ -z "$cmd" ] && { log "no command; ask"; exit 1; }

# DENY (destructive / supply-chain) — checked first
deny_patterns='
^sudo rm -rf /
rm -rf /($| )
rm -rf \*
rm -rf ~($| |/)
:\(\)\{.*fork
mkfs\.
dd if=.*of=/dev/
curl[[:space:]].*\|[[:space:]]*(sh|bash)([[:space:]]|$)
wget[[:space:]].*\|[[:space:]]*(sh|bash)([[:space:]]|$)
chmod 777 /
chown -R .* /
git push .*( -f |--force )([^-]|$).*(origin/)?(main|master)
DROP (DATABASE|TABLE|SCHEMA)
'
while IFS= read -r pat; do
  [ -z "$pat" ] && continue
  if printf '%s' "$cmd" | grep -Eq "$pat"; then
    log "DENY: $cmd (match: $pat)"
    exit 2
  fi
done <<< "$deny_patterns"

# ALLOW (safe dev ops)
allow_patterns='
^(npm|pnpm|yarn)[[:space:]]+(install|i|run|test|exec|ci|ls|outdated|run-script)
^(npx|pnpx)[[:space:]]
^node[[:space:]]
^git[[:space:]]+(status|log|diff|branch|show|remote|config --get|stash list)
^git[[:space:]]+add[[:space:]]
^git[[:space:]]+commit[[:space:]]+-m[[:space:]]
^(vercel|netlify|cloudflared|docker|rsync|ssh)[[:space:]]
^(next|vite|tsc|eslint|prettier)[[:space:]]
^ls([[:space:]]|$)
^pwd([[:space:]]|$)
^cat[[:space:]][^>|]*$
^echo[[:space:]][^>|]*$
^mkdir -p[[:space:]]
^which[[:space:]]
^curl -fsSL https://taw-kit\.dev
'
while IFS= read -r pat; do
  [ -z "$pat" ] && continue
  if printf '%s' "$cmd" | grep -Eq "$pat"; then
    log "ALLOW: $cmd"
    exit 0
  fi
done <<< "$allow_patterns"

# Default: ask
log "ASK: $cmd"
exit 1
