# Phase 10 — Payment & Distribution

## Context Links
- Phase 08 (install one-liner — the thing buyers get)
- Phase 09 (marketing copy sources)
- Research: `research/researcher-02-vn-market-260421-0224.md` §2 (pricing), §5 (channels)
- Research: `research/researcher-01-kit-patterns-260421-0130.md` §5.5

## Overview
- **Priority:** P3 (non-blocking for tech build, but blocks public launch)
- **Status:** pending
- **Effort:** ~8h (Polar: 2h, invite SOP: 2h, landing: 3h, TOS: 1h)
- **Description:** Set up Polar store, manual-invite SOP, legal boilerplate. Payment → invite → install → first app.

## Key Insights
- User confirmed **manual invite is acceptable for first 50 buyers**. No webhook-based automation needed.
- Polar handles VAT; Gumroad fallback if VN-side tax issues arise.
- Manual invite = fast to ship, quality control on buyer quality, catches fraud early. Automation is a phase-2 problem.

## Requirements
**Functional**
1. Polar product page: $39 one-time, VN description, "what you get" bullets (from phase 05/09).
2. Post-purchase email (Polar automation): "Chào mừng! Vui lòng gửi GitHub username về namkent1612000@gmail.com để nhận truy cập trong 24h".
3. Google Sheet tracker: columns [paid_at, email, polar_order_id, github_username, invited_at, first_install_at, notes].
4. `scripts/invite-buyer.sh` (internal seller tool): input = github username; output = `gh api` call inviting to private repo + logs to Sheet via CSV append.
5. Landing page (static, phase 10.b): VN-first, hero + demo video + pricing + FAQ + Polar checkout button.
6. TOS + License: commercial EULA (use, no redistribution, no reselling kit itself, MIT-style for user-generated products).
7. Refund policy: 7-day money-back if `/taw` hasn't successfully built an app (prove via `.taw/deploy-url.txt` check).

**Non-functional**
- Manual invite SLA: <24h weekday, <48h weekend.
- Invite script is single-file bash, runnable from anywhere with `gh` auth.
- Landing page is static HTML/MD (Shipkit deploy) — dogfood the kit itself.

## Architecture

**Buyer journey:**
```
Video/TikTok → Landing page (tawkit.vn)
  │
  ▼ click "Mua ngay — $39"
Polar checkout (auto-VAT, MoMo via Wise/Stripe fallback)
  │
  ▼ success
Polar email: "gửi GitHub username để nhận truy cập"
  │
  ▼ buyer replies
Seller runs: bash scripts/invite-buyer.sh <github_username> <order_id>
  │
  ▼ GitHub invite sent
Buyer accepts → runs curl|bash one-liner → tawkit doctor → /taw
  │
  ▼ first deploy
Seller logs first_install_at in Sheet (optional: welcome DM)
```

**`invite-buyer.sh` data flow:**
```
args: $GH_USER $ORDER_ID
  → gh api repos/<user>/taw-kit/collaborators/$GH_USER -X PUT -F permission=pull
  → curl Google Sheets CSV append endpoint (via Apps Script webhook)
  → send VN confirmation email template (resend.com or just print to clipboard)
```

**Tracker Sheet columns:**
| paid_at | email | polar_order_id | github_username | invited_at | first_install_at | notes |

**Landing page sections (phase 10.b):**
1. Hero: "Ship phần mềm trong 10 phút, không cần biết code"
2. 30-sec demo video
3. "Cho ai?" — Persona A/B/C from research-02
4. "Cái gì trong kit?" — 25 skills summary + 5 presets
5. Pricing: $39 one-time, "mua một lần — dùng mãi"
6. FAQ (top 10, from phase 09)
7. Polar checkout button
8. Support community links (phase 10 Facebook group)

## Related Code Files
**Create:**
- `scripts/invite-buyer.sh`
- `docs/legal/LICENSE.md` (commercial EULA)
- `docs/legal/TOS.md`
- `docs/legal/REFUND-POLICY.md`
- `docs/internal/invite-sop.md` (seller runbook — NOT in public docs)
- `docs/internal/sheet-template.csv`
- `landing/` — static site source (or external repo; TBD)

**Modify:**
- `LICENSE` (phase 01 stub → point to `docs/legal/LICENSE.md`)
- `README.md` — add pricing + link to Polar

**Delete:** none.

## Implementation Steps
1. Create Polar account; add product "taw-kit v0.1 — $39 USD one-time".
2. Set Polar automated email template (VN) asking for GitHub username.
3. Create Google Sheet with tracker columns. Set up Apps Script webhook for CSV append.
4. Write `scripts/invite-buyer.sh`:
   - Validate GH username format.
   - `gh api repos/<seller>/taw-kit/collaborators/$1 -X PUT -F permission=pull`.
   - POST to Sheets webhook with order details.
   - Print VN email template + invite confirmation for seller to paste.
5. Write `docs/internal/invite-sop.md`: seller runbook — daily/weekday schedule, how to detect fraud, refund triggers.
6. Write `docs/legal/LICENSE.md` — commercial EULA:
   - Allowed: use on your own machines, build unlimited products, modify for own use.
   - Not allowed: resell kit, redistribute publicly, open-source the kit files.
   - Products built WITH kit → user owns them outright.
7. Write `docs/legal/TOS.md` + `docs/legal/REFUND-POLICY.md` (7-day).
8. Build landing page (dogfood: `/taw-new landing-page` in a separate repo, then adjust copy):
   - VN hero, video embed, pricing, FAQ, Polar button.
   - Deploy via Shipkit to `tawkit.vn`.
9. Record 30-sec demo video (phase 09 video 2 compressed).
10. Launch: TikTok + Facebook groups + YouTube creator outreach (phase 10 lives in marketing ops, not code).
11. Commit: `feat: payment, invite SOP, legal boilerplate`.

## Todo List
- [ ] Create Polar product ($39, VN copy)
- [ ] Set Polar post-purchase email (VN)
- [ ] Set up Google Sheet tracker + Apps Script webhook
- [ ] Write `scripts/invite-buyer.sh`
- [ ] Write `docs/internal/invite-sop.md`
- [ ] Write `docs/legal/LICENSE.md`
- [ ] Write `docs/legal/TOS.md`
- [ ] Write `docs/legal/REFUND-POLICY.md`
- [ ] Build landing page (dogfood via taw-kit itself)
- [ ] Record 30-sec demo video
- [ ] Deploy landing to `tawkit.vn` (or temp subdomain)
- [ ] End-to-end dry run: test purchase → invite → install → build
- [ ] Commit

## Success Criteria
- Test purchase completes in Polar within 3 min.
- `scripts/invite-buyer.sh test_user ORD_123` sends invite + appends Sheet row.
- Landing page scores ≥90 on Lighthouse Mobile (non-dev buyers shop on phones).
- EULA, TOS, refund docs linked from footer + Polar checkout.
- Internal dry run completes buyer journey in <30 min from checkout to live URL.

## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Polar doesn't support MoMo/ZaloPay directly | High | High | Primary = Polar (card/intl); secondary = Gumroad or direct MoMo bank transfer (manual); document both |
| Manual invite doesn't scale past 50 sales | Medium | Medium | Monitor invite queue; build webhook automation once sustained >5 sales/day |
| Refund fraud (buyer installs kit, demands refund, keeps access) | Medium | Medium | Refund policy requires first 7 days + no successful deploy; revoke GitHub access on refund |
| VN tax/compliance flags selling from non-VN entity | Low | High | Polar handles US-side VAT; sell-from-US entity; consult VN tax advisor if >100 sales |
| GitHub suspends private repo for commercial distribution | Low | Critical | GitHub TOS allows private-repo commerce; document in LICENSE to be safe |
| Landing page typos hurt conversion | Medium | Low | Native speaker review (from phase 09); A/B test headlines post-launch |

## Security Considerations
- **Never commit Polar API keys or GitHub admin tokens.** Invite script reads from `~/.config/tawkit/seller-creds.env`.
- Sheet webhook URL is secret; store in seller env, not repo.
- EULA explicitly prohibits kit redistribution; legal fallback if leaked.
- Refund flow must revoke GitHub access immediately (`gh api -X DELETE` in invite-buyer script with `--revoke` flag).
- PII: tracker Sheet contains emails + GitHub usernames. Limit access to seller + accountant only.

## Next Steps
- Post-launch: build webhook-based auto-invite (phase 11 in future plan) once sales >5/day.
- Post-launch: add localized payment (MoMo direct) if Polar conversion drops below 50%.
- Post-launch: commission structure for TikTok/YouTube affiliates (research-02 §5).
