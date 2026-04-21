# Planner Report — taw-kit Orchestrator Kit

**Date:** 2026-04-21
**Plan dir:** `plans/260421-0130-tawkit-orchestrator-kit/`

## Phase List + Effort

| # | Phase | Priority | Effort |
|---|-------|----------|--------|
| 01 | Repo Architecture | P1 | 4h |
| 02 | Curate Skills & Agents (25 skills, 5 agents) | P1 | 8h |
| 03 | Core `/taw` Orchestrator Skill | P1 | 10h |
| 04 | Supporting Skills (`/taw-fix,-deploy,-add,-new`) | P2 | 8h |
| 05 | Preset Library (5 presets) | P2 | 6h |
| 06 | Hooks & settings.json + CLAUDE.md tmpl | P2 | 5h |
| 07 | `tawkit` CLI Wrapper | P2 | 6h |
| 08 | Install Script (curl \| bash one-liner) | P2 | 4h |
| 09 | Docs & Onboarding (VN docs + video scripts) | P2 | 10h |
| 10 | Payment & Distribution (Polar, invite SOP, landing) | P3 | 8h |

**Total:** ~69h (plus ~10h buffer for testing/polish).

## Critical Path

**Phase 01 → 02 → 03** = ~22h. Ships as private demo (`/taw` produces runnable app).
Phase 04 (depends on 03) adds deploy + fix + add + new = ~30h to full user-facing demo.
Phases 05–10 ship iteratively post-launch.

## Architecture Summary

- **Input model:** Vietnamese prose after `/taw`, question-driven clarify loop (Pattern B from lovable/bolt).
- **Orchestration:** L0 `/taw` skill → L1 agents (planner, researcher×2 parallel, fullstack-dev, tester, reviewer) via Task tool dispatch.
- **Approval:** single gate after 3–5 bullet plan rendered in VN; non-autonomous but not over-interactive.
- **Stack defaults:** Next.js + Tailwind + shadcn + Supabase + Polar + Shipkit deploy.
- **State:** `.taw/intent.json`, `.taw/checkpoint.json`, `.taw/deploy-url.txt` — shared across skills.
- **Hooks:** session-start context, post-tool auto-commit, permission classifier, RTK wrapper.
- **Distribution:** $39 Polar → manual GitHub invite → `curl | bash` installs via `gh` CLI.
- **Languages:** SKILL.md internals English (Claude parses better); ALL user-visible strings Vietnamese; READMEs English for SEO, `docs/vi/` primary.

## Top Risks

1. **VN diacritics in Claude Code CLI** (research-01 Q1) — mitigate via UTF-8 wrap in phase 07 CLI + smoke test on 3 OS.
2. **Skills leaking user's private API keys** during phase 02 curation — grep audit before commit, documented in phase 02.
3. **Shipkit MCP unavailable** at deploy time — fallback to raw `vercel --prod`; doctor warns.
4. **Auto-commit pollutes git history** — env-var opt-out + documented squash recipe.
5. **Polar doesn't support MoMo** — Polar primary (card), Gumroad or manual MoMo bank transfer as fallback; documented in phase 10.
6. **Manual invite doesn't scale** past ~5 sales/day — acceptable for first 50 buyers; webhook automation is post-launch phase 11.
7. **Refund fraud** (install then demand refund) — revoke GitHub access via `invite-buyer.sh --revoke`; policy requires no successful deploy.

## Unresolved Questions (carried to launch)

1. **VN diacritics working end-to-end?** Needs phase-03 smoke test on mac/linux/WSL2; if broken, stdin UTF-8 wrap in CLI.
2. **Approval-gate granularity** — MVP = single gate; fine-grained classifier deferred.
3. **Polar vs Gumroad vs Lemon Squeezy** — user confirmed Polar; phase 10 sets up, Gumroad fallback if VN tax issues.
4. **VN business registration** — deferred, sell as individual via Polar's US entity; revisit at 100 sales.
5. **API rate limits** — N/A for MVP (users bring own API key); revisit only if server-side orchestration adopted.
6. **Localization depth** — MVP ships VN docs + VN `/taw` output only; skill internals English; full skill translation = phase 2.
7. **Live preview** — deferred per spec; MVP uses `npm run dev` + tunnel instructions.

## Ship Gates

- **After phase 03:** private demo to 3 VN non-devs.
- **After phase 06:** internal dogfood — user builds own landing page using the kit.
- **After phase 10:** public launch (Polar + TikTok/YouTube influencer outreach per research-02 §5).

**Status:** DONE
**Summary:** 10-phase plan written with critical path phases 01→03 (22h) shipping MVP demo and phases 04–10 (47h) iteratively completing UX, tooling, docs, and Polar distribution for a $39 Vietnamese non-dev Claude Code kit.
