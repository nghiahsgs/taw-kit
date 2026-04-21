---
name: taw-deploy
description: >
  One-command deploy of taw-kit projects to Vercel via Shipkit MCP.
  Handles env vars, domain linking, and deployment status in Vietnamese.
  Trigger phrases: "deploy len mang", "day len vercel", "cho khach xem duoc",
  "publish website", "dua website len internet".
argument-hint: "[ten mien tuy chon]"
---

# taw-deploy — One-Command Deploy

## Purpose

Takes a locally working taw-kit project and deploys it to Vercel via Shipkit MCP,
ensuring environment variables are set, build passes, and the live URL is returned
to the user in Vietnamese.

## Trigger Phrases (VN + EN)

Vietnamese: "deploy len mang", "day len vercel", "cho khach xem", "publish website"
English: "/taw-deploy", "deploy to production", "go live", "publish the site"

## Invocation Pattern

```
/taw-deploy
/taw-deploy ten-mien-cua-toi.com
/taw-deploy kiem tra trang thai deploy
```

## What This Skill Does

1. Activates `shipkit-deploy` skill to run Shipkit MCP commands in sequence.
2. Calls `ensure-deploy-key` to verify Vercel auth token is configured.
3. Validates `.env.local` has all required keys via `env-manager` skill.
4. Runs `npm run build` locally; if it fails, routes to `taw-fix` automatically.
5. Calls Shipkit `deploy` command with project name derived from `package.json`.
6. Polls `get-deployment-status` until deployment completes or fails.
7. Returns live URL to user with Vietnamese confirmation message.
8. On failure: translates Vercel error to Vietnamese via `error-to-vi` skill.

## Pre-Deploy Checklist

- `.env.local` has `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `POLAR_ACCESS_TOKEN` set if payment is enabled
- `npm run build` exits 0 locally
- `next.config.js` does not have `output: 'export'` (incompatible with Supabase SSR)

## Non-Dev Guarantees

- User receives a plain Vietnamese message: "Da deploy thanh cong!" + URL.
- Failed deploys show actionable Vietnamese fix hints, not raw Vercel logs.
- Env vars are never logged or echoed to terminal output.

> Implementation: see phase-04
