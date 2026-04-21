# Phase 09 — Docs & Onboarding (Vietnamese)

## Context Links
- All prior phases (docs reference them)
- Research: `research/researcher-02-vn-market-260421-0224.md` §4 (VN UX expectations), §5 (channels)

## Overview
- **Priority:** P2 (blocks 10 — marketing uses these)
- **Status:** pending
- **Effort:** ~10h (docs: 5h, video scripts: 3h, troubleshooting: 2h)
- **Description:** Vietnamese-first docs + video scripts + error-recovery guide. English README for SEO only.

## Key Insights
- Research-02 §4 #3: VN non-devs learn by watching, not reading. Docs exist for Googling errors; videos drive adoption.
- Troubleshooting guide is the single highest-leverage doc (deflects support tickets).
- English README = SEO hook only. All learning is in `docs/vi/`.

## Requirements
**Functional**
1. `README.md` (English) — product pitch + one-liner install + link to VN docs + feature table.
2. `docs/vi/quickstart.md` — 5-min read: install → first app → live URL.
3. `docs/vi/commands.md` — reference for `/taw`, `/taw-fix`, `/taw-deploy`, `/taw-add`, `/taw-new`, plus `tawkit` CLI.
4. `docs/vi/presets.md` — describe 5 presets with "what you'll get" bullets (reuses phase 05 `what_you_get_vi`).
5. `docs/vi/troubleshooting.md` — top 20 non-dev errors + how `/taw-fix` handles each.
6. `docs/vi/video-script.md` — 5 video scripts (2–5 min each): install, first-app, shop preset, deploy, troubleshooting.
7. `docs/vi/faq.md` — top 15 pre-sales + post-sales Qs (pricing, refunds, API key, Windows, etc.).
8. `CHANGELOG.md` — seeded with v0.1.0 entry; used by `tawkit update`.

**Non-functional**
- Every VN doc ≤ 400 lines (scannable).
- Code blocks are copy-pasteable without edits (use `{{placeholder}}` only when explained inline).
- Screenshots stored at `docs/vi/assets/` (PNG, ≤ 200KB each, phase 10 populates).

## Architecture

**Doc flow for new buyer:**
```
README.md (EN) → lands from Polar receipt
   │
   ▼
docs/vi/quickstart.md → 5-min walkthrough
   │
   ▼ (when stuck)
docs/vi/troubleshooting.md → search error message
   │
   ▼ (when exploring)
docs/vi/commands.md + docs/vi/presets.md
   │
   ▼ (video-first learners)
Links to YouTube playlist (scripted in video-script.md)
```

**Video script structure (each):**
- Hook (5s): what you'll build.
- Prereq (10s): what you need (one-liner covers most).
- Demo (2–4 min): real-time typing, no edits.
- Recap + next video link (15s).
- Total target: 2–5 min per video.

## Related Code Files
**Create:**
- `README.md`
- `docs/vi/quickstart.md`
- `docs/vi/commands.md`
- `docs/vi/presets.md`
- `docs/vi/troubleshooting.md`
- `docs/vi/video-script.md`
- `docs/vi/faq.md`
- `docs/vi/install.md` (stubbed in phase 08, expanded here)
- `docs/vi/assets/.gitkeep`
- `CHANGELOG.md`
- `docs/en/architecture.md` — 1-page for technical buyers/forkers (post-launch SEO)

**Modify:** `README.md` from phase 01 stub → full product pitch.

**Delete:** none.

## Implementation Steps
1. Flesh out `README.md`:
   - Badge row (version, license).
   - 1-paragraph pitch (English).
   - Install one-liner (from phase 08) prominently.
   - Feature table.
   - Links: `docs/vi/quickstart.md`, pricing page, support community.
2. Write `docs/vi/quickstart.md` — opinionated 5-min path:
   - Step 1: Install (one-liner).
   - Step 2: `tawkit doctor`.
   - Step 3: `/taw "trang bán cà phê"` → live URL.
3. Write `docs/vi/commands.md` — 6-section reference (5 taw skills + tawkit CLI).
4. Write `docs/vi/presets.md` — 5 sections, one per preset, pull from phase 05 `what_you_get_vi`.
5. Write `docs/vi/troubleshooting.md` — compile top 20 from: phase 04 `fix-patterns.md`, test-user bugs, common Claude Code gotchas. For each: symptom + `/taw-fix` resolution + manual fallback.
6. Write `docs/vi/video-script.md` — 5 scripts:
   - Video 1 "Cài đặt taw-kit trong 2 phút"
   - Video 2 "Xây trang landing đầu tiên (3 phút)"
   - Video 3 "Dựng shop bán online với MoMo (5 phút)"
   - Video 4 "Triển khai lên Shipkit miễn phí (3 phút)"
   - Video 5 "Khi bị lỗi: dùng /taw-fix (5 phút)"
7. Write `docs/vi/faq.md` — 15 Qs covering pricing, payment, refund, OS support, API key, data privacy, updates, commercial use.
8. Write `CHANGELOG.md` with v0.1.0 entry.
9. Write `docs/en/architecture.md` — 1-page L0→L3 diagram + pointers to skills dirs.
10. Review VN docs with native speaker (user); iterate for tone (friendly, not formal).
11. Commit: `docs: vietnamese onboarding + video scripts`.

## Todo List
- [ ] Finish `README.md` (EN) — pitch + install + table
- [ ] Write `docs/vi/quickstart.md`
- [ ] Write `docs/vi/commands.md`
- [ ] Write `docs/vi/presets.md` (reuse phase 05 bullets)
- [ ] Write `docs/vi/troubleshooting.md` (20 entries)
- [ ] Write `docs/vi/video-script.md` (5 scripts)
- [ ] Write `docs/vi/faq.md` (15 Qs)
- [ ] Seed `CHANGELOG.md` (v0.1.0)
- [ ] Write `docs/en/architecture.md`
- [ ] Native-speaker review pass
- [ ] Commit

## Success Criteria
- Fresh buyer can run `/taw` end-to-end using ONLY `docs/vi/quickstart.md` + `docs/vi/install.md` (tested with 1 non-dev friend).
- Troubleshooting doc covers ≥15 of the top-20 errors encountered during internal dogfooding.
- Video scripts are 300–600 words each (≈2–5 min delivery).
- README passes markdown lint + all relative links resolve.

## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| VN docs have translation errors | High | Medium | Native speaker review; Facebook community catches + reports |
| Videos go stale when kit updates | High | Medium | Caption videos with version; re-record on major version bumps |
| Quickstart assumes knowledge non-devs lack | Medium | High | Test with 1 real non-dev before launch; iterate |
| Screenshot paths broken when renamed | Low | Low | All images under `docs/vi/assets/`; relative links only |
| English README misleads about VN-first UX | Low | Medium | Explicit "docs in Vietnamese" banner near top |

## Security Considerations
- Docs never show real API keys. Use `sk-xxxxxx` placeholders.
- FAQ addresses data privacy: where `.taw/intent.json` lives (local only), what Polar sees (payment only), what we collect (nothing beyond Polar receipts).
- Troubleshooting doc warns against sharing `.env.local` when asking for help.

## Next Steps
- Phase 10 uses `what_you_get_vi` + video scripts for landing page + Polar product copy.
- Post-launch: translate more docs to EN as SEO demands.
