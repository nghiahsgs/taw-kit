# Invite SOP — Internal Seller Runbook

**Audience:** You (the seller). NOT shipped to buyers.
**Updated:** 2026-04-21

## Daily routine

1. **Morning (9-10am)** — check Polar dashboard for new orders overnight.
2. **For each new order:**
   - Confirm payment cleared (status = `succeeded`).
   - Check your inbox for the buyer's reply with their GitHub username.
   - If no reply after 4 hours: send the template reminder email.
3. **Run the invite:**
   ```bash
   bash ~/.taw-kit/scripts/invite-buyer.sh <github_username> <polar_order_id> <buyer_email>
   ```
4. **Paste the generated email template** (script prints it to stdout) into Gmail, customize the last line, send.
5. **Mark the Sheet row** as `invited_at = now()` (Apps Script webhook handles this automatically).

## Fraud detection

Red flags — investigate before inviting:

| Signal | Action |
|--------|--------|
| GitHub account created < 7 days ago | Ask for a second verification (LinkedIn, X) before inviting |
| Order from a high-fraud country with card BIN mismatch | Hold 24h; Polar usually catches this, but verify |
| Same email used for 2+ orders in 24h | Offer consolidation; don't invite twice |
| Buyer asks to transfer access to "my developer friend" | Refuse — one license per person per EULA §3 |

## Refund handling

- Buyer emails requesting refund → reply within 48h.
- Check qualification per [REFUND-POLICY.md](../legal/REFUND-POLICY.md).
- If qualified:
  1. Issue refund in Polar (click "Refund" on order page).
  2. Revoke GitHub access:
     ```bash
     bash ~/.taw-kit/scripts/invite-buyer.sh --revoke <github_username>
     ```
  3. Update Sheet row with `refunded_at` + reason.
  4. Send confirmation email.

## SLA targets

| Task | Target | Escalate if |
|------|--------|-------------|
| Reply to purchase emails | < 24h weekday | > 48h elapsed |
| Reply to support emails | < 24h weekday | > 72h elapsed |
| Issue refund | < 48h from request | > 5 days |
| Invite buyer to repo | < 24h from username received | > 48h |

## When inbox volume exceeds 5/day sustained

Automation time. Build webhook-based auto-invite:
1. Polar webhook → Cloudflare Worker.
2. Worker calls `gh api` to invite the GitHub user from Polar metadata field.
3. Worker posts to Sheet webhook.

Estimated effort: 6h. Defer until volume warrants.

## Weekly review (Sunday night)

- Count invites sent this week; compare to Polar orders.
- Spot gap: orders without matching invite → missing buyer replies (email them).
- Spot gap: invites without matching order → fraud or testing. Investigate.
- Review support emails for recurring issues; update `docs/vi/troubleshooting.md`.

## Quarterly review

- Review refund rate. Target < 5%.
- Review NPS / email feedback.
- Review `docs/vi/troubleshooting.md` against actual support tickets; prune entries nobody hits.

## Contact

Primary: namkent1612000@gmail.com
