---
title: "taw-kit: Claude Code orchestrator kit for Vietnamese non-developers"
description: "Paid Claude Code kit with /taw orchestrator that turns Vietnamese prose into shipped products"
status: pending
priority: P1
effort: ~80h total (critical path ~30h)
branch: main
tags: [kit, orchestrator, vietnamese, claude-code, mvp]
created: 2026-04-21
---

# taw-kit Overview

**Goal:** Ship a paid Claude Code kit ($39 one-time) that lets Vietnamese non-devs run `/taw <mô tả>` and get a live product URL. Target first 50 buyers.

**Stack defaults:** Next.js + Tailwind + shadcn + Supabase + Polar + Shipkit deploy.

**UX principle:** Question-driven clarification (Pattern B from research-01) + L0→L3 agent hierarchy (Pattern A) + Vietnamese-first UX + approval gate before execution.

## Phases

| # | Phase | Priority | Status | Effort | Blocks |
|---|-------|----------|--------|--------|--------|
| 01 | Repo Architecture | P1 critical | pending | 4h | 02,06,07 |
| 02 | Curate Skills & Agents | P1 critical | pending | 8h | 03,04 |
| 03 | Core `/taw` Skill | P1 critical | pending | 10h | 04,09 |
| 04 | Supporting Skills (`/taw-fix`, `/taw-deploy`, `/taw-add`, `/taw-new`) | P2 | pending | 8h | — |
| 05 | Preset Library (5 presets) | P2 | pending | 6h | — |
| 06 | Hooks & settings.json | P2 | pending | 5h | — |
| 07 | `tawkit` CLI Wrapper | P2 | pending | 6h | 08,10 |
| 08 | Install Script (one-liner) | P2 | pending | 4h | 10 |
| 09 | Docs & Onboarding (VN) | P2 | pending | 10h | 10 |
| 10 | Payment & Distribution | P3 | pending | 8h | — |

## Critical Path (launch-blocking)

**Phase 01 → 02 → 03** = MVP demo (`/taw` produces real output). ~22h.
Phases 04–10 ship post-launch iteratively.

## Key Dependencies

- **External:** Claude Code CLI, `gh` CLI, git, Node ≥20, npm, bash/zsh. Optional: existing user global `.claude/` skills.
- **User assets:** 100+ personal skills (to be curated in phase 02), payment-integration skill, Shipkit MCP.
- **Paid services:** Polar account ($39 product), private GitHub repo under user org.

## Ship Gates

- After **phase 03**: private demo to 3 test users (Vietnamese, non-dev).
- After **phase 06**: internal dogfood — user builds their own landing page using the kit.
- After **phase 10**: public launch with Gumroad/Polar checkout + manual GitHub invite flow.

## Unresolved Questions (to resolve before launch)

1. **VN diacritics in Claude Code CLI** (research-01 Q1): test on Mac/Linux/WSL2; if broken, wrap stdin with `iconv -t UTF-8`. Mitigation: phase 03 smoke test.
2. **Approval-gate granularity** (research-01 Q3): MVP = single gate after plan bullets; auto-approve bash/file writes inside project root, prompt on destructive (rm, migrations). Defer fine-grained classifier to post-launch.
3. **Polar vs Gumroad vs Lemon Squeezy** (research-01 Q4 + research-02 pricing): user confirmed Polar. Phase 10 sets up Polar; fallback Gumroad if Polar VN tax issues surface.
4. **VN business registration for GitHub repo sales** (research-02 Q1): defer — user operates as individual seller via Polar (US entity handles tax). Revisit at 100 sales.
5. **API rate limits at scale** (research-02 Q3): N/A for MVP (users bring own API key). Re-examine if we ever move to server-side orchestration.
6. **Localization depth** (research-02 Q2): MVP = VN docs + VN error messages in `/taw` output; English SKILL.md internals (Claude reads English better). Full VN skill internals = phase 2.
7. **Live preview** (research-01 Q2): deferred per spec. MVP uses `npm run dev` + local tunnel instructions.
