#!/usr/bin/env bash
# tawkit doctor — environment health check.
# Runs 10 checks, prints status per check, exits with count of failures.

set -u

TAW_ROOT="${TAW_ROOT:-$HOME/.taw-kit}"
[ -f "$TAW_ROOT/scripts/doctor.sh" ] || TAW_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/log.sh
. "$TAW_ROOT/scripts/lib/log.sh"

fails=0
warns=0

_pass()    { ok "$1";      }
_fail()    { err "$1";     fails=$((fails+1)); }
_warn_only(){ warn "$1";   warns=$((warns+1)); }

# 1. Claude Code installed
if command -v claude >/dev/null 2>&1; then
  ver="$(claude --version 2>/dev/null | head -1 || echo 'unknown')"
  _pass "Claude Code: $ver"
else
  _fail "Claude Code not installed. Install: https://docs.claude.com/claude-code"
fi

# 2. git ≥ 2.30
if command -v git >/dev/null 2>&1; then
  gv="$(git --version | awk '{print $3}')"
  _pass "git: $gv"
else
  _fail "git not installed"
fi

# 3. node ≥ 20
if command -v node >/dev/null 2>&1; then
  nv="$(node --version 2>/dev/null | sed 's/v//')"
  major="${nv%%.*}"
  if [ "${major:-0}" -ge 20 ] 2>/dev/null; then
    _pass "Node.js: v$nv"
  else
    _fail "Node.js is too old (v$nv). Needs v20 or higher. Install: https://nodejs.org"
  fi
else
  _fail "Node.js not installed. Install: https://nodejs.org"
fi

# 4. ~/.claude/ writable
if [ -w "$HOME/.claude" ]; then
  _pass "~/.claude/ writable"
else
  _fail "~/.claude/ not writable. Run: chmod -R u+w ~/.claude"
fi

# 5. Core skill installed
if [ -f "$HOME/.claude/skills/taw/SKILL.md" ]; then
  _pass "/taw skill installed"
else
  _fail "/taw skill not installed. Run: tawkit install"
fi

# 6. Hooks executable
if [ -x "$HOME/.claude/hooks/permission-classifier.sh" ]; then
  _pass "hooks are executable"
else
  _fail "hooks not executable. Run: chmod +x ~/.claude/hooks/*.sh"
fi

# 7. Anthropic auth (env var OR claude login)
if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  _pass "ANTHROPIC_API_KEY is set"
elif command -v claude >/dev/null 2>&1 && claude auth status >/dev/null 2>&1; then
  _pass "Claude Code authenticated (via claude login)"
else
  _warn_only "No API key or claude login detected (run: claude login  OR  export ANTHROPIC_API_KEY=...)"
fi

# 8. RTK (optional)
if command -v rtk >/dev/null 2>&1; then
  _pass "RTK (token saver) installed"
else
  _warn_only "RTK not installed (optional; saves 60-75% tokens on dev ops)"
fi

# 9. Polar token (warn only)
if [ -n "${POLAR_ACCESS_TOKEN:-}" ]; then
  _pass "POLAR_ACCESS_TOKEN is set"
else
  _warn_only "POLAR_ACCESS_TOKEN not set (only needed if you are selling on Polar)"
fi

# 10. Python 3 (optional — frontend-design skill is pure Markdown, no longer required)
if command -v python3 >/dev/null 2>&1; then
  pv="$(python3 --version 2>&1 | awk '{print $2}')"
  _pass "Python 3: $pv (optional, useful for ad-hoc scripts)"
else
  _warn_only "python3 not installed (optional — taw-kit core skills no longer require it)"
fi

# 11. Locale UTF-8
if locale 2>/dev/null | grep -q 'UTF-8'; then
  _pass "locale: UTF-8"
else
  _fail "locale is not UTF-8. Add to ~/.zshrc: export LANG=en_US.UTF-8"
fi

echo
if [ "$fails" -eq 0 ]; then
  ok "doctor: all checks passed ($warns non-critical warnings)"
  exit 0
else
  err "doctor: $fails failure(s), $warns warning(s)"
  exit "$fails"
fi
