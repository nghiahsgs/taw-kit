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

# Block if sensitive FILENAMES are staged or would be added
sensitive_patterns='^\.env($|\.)|\.key$|\.pem$|\.p12$|\.pfx$|credentials|service[-_]account|id_rsa$|id_ed25519$|id_ecdsa$'
candidates="$(git status --porcelain 2>/dev/null | awk '{print $2}')"
if [ -n "$candidates" ]; then
  if printf '%s\n' "$candidates" | grep -Eq "$sensitive_patterns"; then
    log "REFUSE commit — sensitive files in working tree: $candidates"
    exit 0
  fi
fi

# Nothing changed? nothing to do. Use porcelain so untracked new files count too.
if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
  log "no diff; skip"
  exit 0
fi

# Stage everything not sensitive
git add -A >/dev/null 2>&1 || true

# Double-check filenames after add (race)
if git diff --cached --name-only | grep -Eq "$sensitive_patterns"; then
  log "ABORT — sensitive file slipped into index; unstaging all"
  git reset >/dev/null 2>&1 || true
  exit 0
fi

# Scan staged CONTENT for well-known secret shapes (AWS key, GitHub PAT, OpenAI,
# JWT, PEM header, DB URL with inline password). Patterns from public specs.
# Set TAW_AUTOCOMMIT_CONTENT_SCAN=0 to disable (if too slow on huge diffs).
if [ "${TAW_AUTOCOMMIT_CONTENT_SCAN:-1}" = "1" ]; then
  content_patterns='AKIA[0-9A-Z]{16}|(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,}|sk_live_[0-9A-Za-z]{24,}|AIza[0-9A-Za-z_-]{35}|xox[abpr]-[0-9A-Za-z-]{10,}|-----BEGIN( RSA| EC| OPENSSH| PGP| DSA)? ?PRIVATE KEY-----|(mongodb|postgres|postgresql|mysql|redis)://[^:[:space:]]+:[^@[:space:]]+@|eyJ[A-Za-z0-9_=-]{10,}\.eyJ[A-Za-z0-9_=-]{10,}\.[A-Za-z0-9_=-]+'
  offending="$(git diff --cached -U0 2>/dev/null | grep -EIn "$content_patterns" | head -n1 || true)"
  if [ -n "$offending" ]; then
    log "ABORT — secret-shaped content detected; unstaging all (first hit: ${offending%%:*})"
    git reset >/dev/null 2>&1 || true
    exit 0
  fi
fi

# Derive a meaningful subject from the staged diff so history is traceable.
# Pattern: "chore(auto): <verb> <top-path> (+N file[s])"
# - verb: "add" if any new file, "update" otherwise
# - top-path: the most-changed file's top-2 path segments (e.g. "src/ViewProfile")
# - +N only appended when >1 file changed
derive_subject() {
  local stat top_path verb n_files n_added
  stat="$(git diff --cached --numstat 2>/dev/null)"
  [ -z "$stat" ] && { echo "auto-save (no diff)"; return; }

  n_files=$(printf '%s\n' "$stat" | wc -l | tr -d ' ')
  n_added=$(git diff --cached --name-status 2>/dev/null | grep -c '^A' 2>/dev/null | head -n1 | tr -d ' ')
  [ -z "$n_added" ] && n_added=0
  verb="update"; [ "$n_added" -gt 0 ] && verb="add"

  # Top-changed file = highest (added+deleted) lines. Fallback to first file.
  top_path="$(printf '%s\n' "$stat" \
    | awk '{a=$1; d=$2; if(a=="-")a=0; if(d=="-")d=0; print (a+d)"\t"$3}' \
    | sort -rn | head -n1 | cut -f2)"
  [ -z "$top_path" ] && top_path="$(printf '%s\n' "$stat" | head -n1 | awk '{print $3}')"

  # Shorten: keep up to 2 leading segments + basename-without-ext
  local short
  short="$(printf '%s' "$top_path" | awk -F/ '{
    if (NF<=2) print $0;
    else print $1"/"$(NF-1)"/"$NF
  }')"
  short="${short%.*}"

  if [ "$n_files" -gt 1 ]; then
    echo "$verb $short (+$((n_files-1)) file$([ $((n_files-1)) -gt 1 ] && echo s))"
  else
    echo "$verb $short"
  fi
}

subject="$(derive_subject)"
msg="chore(auto): ${subject}"

# Amend-chain: if the previous commit is also an auto-save (chore(auto): ... or
# legacy "taw: auto-save ..."), fold this into it. Keeps history clean during
# rapid edits. Any intentional commit (feat/fix/etc via git-auto-commit) breaks
# the chain and the next auto-save starts a new commit.
prev_subject="$(git log -1 --pretty=%s 2>/dev/null || true)"
case "$prev_subject" in
  "chore(auto):"*|"taw: auto-save"*)
    # Only amend if previous commit is unpushed (safe to rewrite).
    # No upstream configured → treat everything as local-only → safe to amend.
    safe_to_amend=0
    if ! git rev-parse --abbrev-ref '@{push}' >/dev/null 2>&1; then
      safe_to_amend=1
    elif [ -n "$(git log '@{push}..HEAD' --oneline 2>/dev/null)" ]; then
      safe_to_amend=1
    fi
    if [ "$safe_to_amend" = "1" ]; then
      if git commit --amend --no-verify -m "$msg" >/dev/null 2>&1; then
        log "amended into previous auto-save: $msg"
        echo "$now" > "$stamp_file" 2>/dev/null || true
        exit 0
      fi
    fi
    ;;
esac

if git commit --no-verify -m "$msg" >/dev/null 2>&1; then
  log "committed: $msg"
  echo "$now" > "$stamp_file" 2>/dev/null || true
else
  log "commit failed (hook, probably nothing staged after filters)"
fi

exit 0
