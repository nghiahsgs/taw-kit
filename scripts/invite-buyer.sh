#!/usr/bin/env bash
# invite-buyer.sh — seller tool. Invites a paid buyer to the private repo
# and logs the invite to a Google Sheet (via Apps Script webhook).
#
# Usage:
#   bash scripts/invite-buyer.sh <github_username> <polar_order_id> [buyer_email]
#   bash scripts/invite-buyer.sh --revoke <github_username>          # for refunds
#
# Requires seller creds at ~/.config/tawkit/seller-creds.env:
#   REPO_OWNER=nghiahsgs
#   REPO_NAME=taw-kit
#   SHEET_WEBHOOK_URL=https://script.google.com/macros/s/.../exec
#   SELLER_EMAIL=namkent1612000@gmail.com

set -euo pipefail

CREDS="${HOME}/.config/tawkit/seller-creds.env"
if [ ! -f "$CREDS" ]; then
  echo "[err] $CREDS not found" >&2
  echo "create the file with: REPO_OWNER, REPO_NAME, SHEET_WEBHOOK_URL, SELLER_EMAIL" >&2
  exit 2
fi
# shellcheck disable=SC1090
. "$CREDS"

: "${REPO_OWNER:?REPO_OWNER not set}"
: "${REPO_NAME:?REPO_NAME not set}"

if ! command -v gh >/dev/null 2>&1; then
  echo "[err] gh CLI required. Install: brew install gh  (Mac)  or  apt install gh  (Linux)" >&2
  exit 3
fi
if ! gh auth status >/dev/null 2>&1; then
  echo "[err] gh not logged in. Run: gh auth login" >&2
  exit 3
fi

_validate_gh_user() {
  local u="$1"
  if ! [[ "$u" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,38}[a-zA-Z0-9])?$ ]]; then
    echo "[err] invalid github username: $u" >&2
    exit 1
  fi
}

_log_to_sheet() {
  local event="$1" gh_user="$2" order_id="$3" email="${4:-}"
  [ -z "${SHEET_WEBHOOK_URL:-}" ] && return 0
  curl -fsSL -X POST "$SHEET_WEBHOOK_URL" \
    -H 'Content-Type: application/json' \
    -d "{\"event\":\"$event\",\"gh_user\":\"$gh_user\",\"order_id\":\"$order_id\",\"email\":\"$email\",\"ts\":\"$(date -u +%FT%TZ)\"}" \
    >/dev/null 2>&1 || echo "[warn] sheet log failed (ignored)" >&2
}

if [ "${1:-}" = "--revoke" ]; then
  # Refund path — remove collaborator access
  gh_user="${2:-}"; _validate_gh_user "$gh_user"
  echo "[info] revoking access for $gh_user..."
  gh api -X DELETE "/repos/$REPO_OWNER/$REPO_NAME/collaborators/$gh_user" \
    && echo "[ok] revoked $gh_user"
  _log_to_sheet "revoked" "$gh_user" "" ""
  exit 0
fi

# Normal invite path
gh_user="${1:-}"
order_id="${2:-}"
buyer_email="${3:-}"

if [ -z "$gh_user" ] || [ -z "$order_id" ]; then
  cat <<EOF >&2
Usage:
  bash scripts/invite-buyer.sh <github_username> <polar_order_id> [buyer_email]
  bash scripts/invite-buyer.sh --revoke <github_username>
EOF
  exit 1
fi

_validate_gh_user "$gh_user"

echo "[info] inviting $gh_user to $REPO_OWNER/$REPO_NAME (pull permission)..."
gh api -X PUT "/repos/$REPO_OWNER/$REPO_NAME/collaborators/$gh_user" \
  -f permission=pull \
  >/dev/null

_log_to_sheet "invited" "$gh_user" "$order_id" "$buyer_email"

cat <<EOF

[ok] invited $gh_user

--- Email template (copy into Gmail) ---
Hi,

Thanks for buying taw-kit!

I just sent a GitHub invitation to the username "$gh_user" (Order: $order_id).
Please check your email from GitHub and click "Accept invitation".

Then, open Terminal and run:

  curl -fsSL https://install.tawkit.dev | bash

If you run into any issue, just reply to this email.

-- $SELLER_EMAIL
-----------------------------------------

EOF
