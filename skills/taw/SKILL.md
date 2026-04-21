---
name: taw
description: >
  Main orchestrator for taw-kit. Converts Vietnamese product descriptions into
  full-stack web apps (Next.js + Tailwind + shadcn + Supabase + Polar).
  Trigger phrases: "taw lam website", "taw build cho toi", "tao muon co website",
  "xay dung website ban hang", "lam app cho toi".
argument-hint: "<mo ta san pham bang tieng Viet>"
---

# taw — Main Orchestrator

## Purpose

When user writes `/taw <Vietnamese description>`, this skill orchestrates the full
product build pipeline: plan → research → scaffold → implement → deploy.
It coordinates all internal skills and agents to deliver a working product.

## Trigger Phrases (VN + EN)

Vietnamese: "lam website", "tao web", "xay dung", "tao cho toi mot", "can mot website"
English: "/taw", "build me a", "create a web app"

## Invocation Pattern

```
/taw ban giay sneaker truc tuyen, thanh toan qua MoMo, khach hang o TP.HCM
/taw website dat lich cat toc, co form dat lich va thong bao Zalo
/taw landing page cho khoa hoc online, collect email, ban qua Polar
```

## What This Skill Does

1. Parses the Vietnamese description to extract: product type, target users, payment method, key features.
2. Delegates to `approval-plan` skill — renders a 3-5 bullet plan for user confirmation.
3. Spawns `planner` agent to create `plans/<timestamp>-<slug>/` with phase files.
4. Spawns `researcher` agents in parallel to look up relevant docs (Next.js, Supabase, etc.).
5. Spawns `fullstack-dev` agent to scaffold and implement per plan phases.
6. Spawns `tester` agent to run `npm run build`; surfaces errors in Vietnamese via `error-to-vi`.
7. Spawns `reviewer` agent for security/quality check.
8. Optionally triggers `taw-deploy` for one-command Vercel deploy.

## Orchestration Flow

```
user input (VN prose)
  → parse intent
  → approval-plan (confirm with user)
  → planner agent (create phases)
  → researcher agents (parallel docs lookup)
  → fullstack-dev agent (implement phases)
  → tester agent (npm run build)
  → reviewer agent (quality check)
  → taw-deploy (optional)
```

## Non-Dev Guarantees

- User never sees raw error messages — `error-to-vi` translates all failures to Vietnamese.
- User confirms the plan before any code is written.
- Intermediate previews shared via `preview-tunnel` after scaffold is done.

## Notes

- Requires Supabase project URL + anon key in `.env.local` before first run.
- Vietnamese strings in UI; English in code, comments, and git messages.
- Stack is fixed: Next.js 14 App Router + Tailwind + shadcn/ui + Supabase + Polar.

> Implementation: see phase-03
