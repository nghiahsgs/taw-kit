---
name: shipkit-deploy
description: >
  Deploy taw-kit projects to Vercel via Shipkit MCP tool. Covers ensure-deploy-key,
  deploy, and get-deployment-status commands. Activated by taw-deploy skill.
argument-hint: "[project-name hoac 'status']"
---

# shipkit-deploy — Vercel Deploy via Shipkit MCP

## Purpose

Wraps Shipkit MCP commands to deploy Next.js projects to Vercel.
Called exclusively by `taw-deploy` skill — do not invoke directly.

## Prerequisites

- Vercel account linked to Shipkit
- `VERCEL_TOKEN` in environment or Shipkit config
- `npm run build` passes locally

## Command Sequence

### Step 1: Ensure Deploy Key
```
mcp__shipkit__ensure-deploy-key
  project: <project-name-from-package-json>
```
Verifies Vercel auth. If missing, prompts user to run Shipkit setup.

### Step 2: Deploy
```
mcp__shipkit__deploy
  project: <project-name>
  environment: production
```
Returns a `deploymentId` and initial status.

### Step 3: Poll Status
```
mcp__shipkit__get-deployment-status
  deploymentId: <id-from-step-2>
```
Poll every 10 seconds until `status` is `READY` or `ERROR`.

## Success Response

```json
{
  "status": "READY",
  "url": "https://ten-cua-hang.vercel.app",
  "deploymentId": "dpl_abc123"
}
```

Return URL to user with Vietnamese message:
"Website cua ban da len mang tai: https://ten-cua-hang.vercel.app"

## Error Handling

| Error | Vietnamese message | Fix |
|-------|--------------------|-----|
| Auth failed | "Chua ket noi Vercel, chay Shipkit setup truoc" | Run Shipkit auth |
| Build failed | "Build bi loi, dang kiem tra..." | Route to `taw-fix` |
| Timeout (>5 min) | "Deploy qua lau, kiem tra Vercel dashboard" | Manual check |

## Environment Variables on Vercel

After first deploy, set production env vars via Vercel dashboard or CLI:
```bash
vercel env add NEXT_PUBLIC_SUPABASE_URL production
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production
vercel env add POLAR_ACCESS_TOKEN production
```

These are NOT set automatically — user must do this once.
