#!/usr/bin/env bash
# taw-kit hook: PreToolUse (Bash)
# Classifies a proposed bash command into allow / ask / deny so non-devs
# don't have to approve every npm install, but destructive ops still prompt.
#
# Input: Claude Code passes the tool-use JSON on stdin.
# Contract (Claude Code v2): always exit 0. Signal decisions via stdout JSON:
#   {"decision": "block", "reason": "..."}  → deny with message
#   (no stdout)                              → let Claude Code handle normally
#
# NOTE: the old exit-code-based contract (0=allow / 1=ask / 2=deny) triggered
# Claude Code v2's "Failed with non-blocking status code" noise on every
# non-allowed command. Always exiting 0 kills that noise.

set -u

LOG="${HOME}/.taw-kit/logs/hooks.log"
mkdir -p "$(dirname "$LOG")" 2>/dev/null || true
log() { printf '[%s] perm-class: %s\n' "$(date -u +%FT%TZ)" "$1" >> "$LOG" 2>/dev/null || true; }

# Read command from stdin JSON, fall back to $1
cmd=""
if [ -t 0 ]; then
  cmd="${1:-}"
else
  payload="$(cat)"
  cmd="$(printf '%s' "$payload" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
  [ -z "$cmd" ] && cmd="${1:-}"
fi

# No command = nothing to classify; proceed normally
[ -z "$cmd" ] && exit 0

# DENY (destructive / supply-chain) — emit block JSON on stdout, exit 0
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
  if printf '%s' "$cmd" | command grep -Eq "$pat"; then
    log "DENY: $cmd (match: $pat)"
    printf '{"decision":"block","reason":"taw-kit: lenh bi chan - pattern nguy hiem: %s"}\n' "$pat"
    exit 0
  fi
done <<< "$deny_patterns"

# ALLOW (safe dev ops) — just log, exit 0 silently. Claude Code's default
# handling (bypass mode on = auto-run; bypass off = standard prompt) is fine.
allow_patterns='
^(npm|pnpm|yarn)[[:space:]]+(install|i|run|test|exec|ci|ls|outdated|run-script)
^(npx|pnpx)[[:space:]]
^node[[:space:]]
^git[[:space:]]+(status|log|diff|branch|show|remote|config --get|stash list|rev-parse|ls-files)
^git[[:space:]]+add[[:space:]]
^git[[:space:]]+commit[[:space:]]+-m[[:space:]]
^(vercel|netlify|cloudflared|docker|rsync|ssh)[[:space:]]
^(next|vite|tsc|eslint|prettier)[[:space:]]
^ls($|[[:space:]])
^pwd([[:space:]]|$)
^cat[[:space:]][^>|]*$
^echo[[:space:]][^>|]*$
^mkdir -p[[:space:]]
^which[[:space:]]
^command[[:space:]]+(grep|which)[[:space:]]
^find[[:space:]]
^grep[[:space:]]
^head[[:space:]]
^tail[[:space:]]
^wc[[:space:]]
^awk[[:space:]]
^sed[[:space:]][^|&;]*$
^sort[[:space:]]
^uniq[[:space:]]
^cut[[:space:]]
^jq[[:space:]]
^test[[:space:]]+-[dfe]
^curl -fsSL https://taw-kit\.dev
'
while IFS= read -r pat; do
  [ -z "$pat" ] && continue
  if printf '%s' "$cmd" | command grep -Eq "$pat"; then
    log "ALLOW: $cmd"
    exit 0
  fi
done <<< "$allow_patterns"

# Default: no classification — let Claude Code handle normally
log "DEFAULT: $cmd"
exit 0
