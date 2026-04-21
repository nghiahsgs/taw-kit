#!/usr/bin/env bash
# tawkit doctor — environment health check.
# Runs 10 checks, prints VN status per check, exits with count of failures.

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
  _fail "Claude Code chua cai. Huong dan: https://docs.claude.com/claude-code"
fi

# 2. git ≥ 2.30
if command -v git >/dev/null 2>&1; then
  gv="$(git --version | awk '{print $3}')"
  _pass "git: $gv"
else
  _fail "git chua cai"
fi

# 3. node ≥ 20
if command -v node >/dev/null 2>&1; then
  nv="$(node --version 2>/dev/null | sed 's/v//')"
  major="${nv%%.*}"
  if [ "${major:-0}" -ge 20 ] 2>/dev/null; then
    _pass "Node.js: v$nv"
  else
    _fail "Node.js qua cu (v$nv). Can v20 tro len. Cai: https://nodejs.org"
  fi
else
  _fail "Node.js chua cai. Cai: https://nodejs.org"
fi

# 4. ~/.claude/ writable
if [ -w "$HOME/.claude" ]; then
  _pass "~/.claude/ ghi duoc"
else
  _fail "~/.claude/ khong ghi duoc. Chay: chmod -R u+w ~/.claude"
fi

# 5. Core skill installed
if [ -f "$HOME/.claude/skills/taw/SKILL.md" ]; then
  _pass "skill /taw da cai"
else
  _fail "skill /taw chua cai. Chay: tawkit install"
fi

# 6. Hooks executable
if [ -x "$HOME/.claude/hooks/permission-classifier.sh" ]; then
  _pass "hooks co quyen chay"
else
  _fail "hooks khong chay duoc. Chay: chmod +x ~/.claude/hooks/*.sh"
fi

# 7. API key works (best-effort; skip if offline)
if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  _pass "ANTHROPIC_API_KEY da set"
else
  _warn_only "ANTHROPIC_API_KEY chua set (chay: export ANTHROPIC_API_KEY=...)"
fi

# 8. RTK (optional)
if command -v rtk >/dev/null 2>&1; then
  _pass "RTK (tiet kiem token) da cai"
else
  _warn_only "RTK chua cai (tuy chon; tiet kiem 60-75% token)"
fi

# 9. Polar token (warn only)
if [ -n "${POLAR_ACCESS_TOKEN:-}" ]; then
  _pass "POLAR_ACCESS_TOKEN da set"
else
  _warn_only "POLAR_ACCESS_TOKEN chua set (chi can neu ban ban hang tren Polar)"
fi

# 10. Locale UTF-8 (critical for Vietnamese diacritics)
if locale 2>/dev/null | grep -q 'UTF-8'; then
  _pass "locale: UTF-8 (tieng Viet OK)"
else
  _fail "locale khong phai UTF-8. Them vao ~/.zshrc: export LANG=en_US.UTF-8"
fi

echo
if [ "$fails" -eq 0 ]; then
  ok "doctor: tat ca OK ($warns canh bao khong quan trong)"
  exit 0
else
  err "doctor: $fails loi can sua, $warns canh bao"
  exit "$fails"
fi
