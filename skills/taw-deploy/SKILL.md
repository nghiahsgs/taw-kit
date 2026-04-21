---
name: taw-deploy
description: >
  One-command deploy for taw-kit projects. Tries Shipkit MCP first
  (ensure-deploy-key → deploy → get-deployment-status), falls back to
  `vercel --prod` CLI. Returns live URL to caller. User-visible strings
  are simple English. Trigger phrases (EN + VN): "deploy this", "push to
  vercel", "publish the site", "go live", "deploy di", "day len vercel".
argument-hint: "[optional-custom-domain]"
allowed-tools: Read, Write, Bash, Grep
---

# taw-deploy — One-Command Deploy

You are the taw-deploy skill. Deploy the current taw-kit project to production and return the live URL. All strings shown to the user MUST be simple English.

## Step 1 — Pre-flight checks

Run ALL checks before touching deploy infrastructure. If any check fails, stop and emit the matching message — do NOT proceed.

| # | Check | Command | Fail message |
|---|-------|---------|--------------|
| 1 | Build passes locally | `npm run build 2>&1` exit 0 | "Build is failing. Run `/taw-fix` first." |
| 2 | `.env.local` exists | `test -f .env.local` | "`.env.local` is missing. You need it with your Supabase + Polar keys." |
| 3 | No secrets in tracked files | `git grep -lE "(SUPABASE_SERVICE_KEY\|POLAR_SECRET\|sk-[a-zA-Z]{20})" -- '*.ts' '*.tsx' '*.js'` returns empty | "Secret detected in source. Remove it before deploying." |
| 4 | Required env keys present | grep `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` in `.env.local` | "Missing Supabase keys in `.env.local`." |
| 5 | Config file exists | `test -f vercel.json -o -f next.config.js` | "Next.js config not found. Is this a taw-kit project?" |

Emit progress: "Pre-flight checks... done"

## Step 2 — Read project name

```bash
node -e "console.log(require('./package.json').name)"
```

Store as `$PROJECT_NAME`. Used as the Shipkit project identifier.

## Step 3 — Try Shipkit MCP deploy

Execute Shipkit MCP tool calls in sequence:

**3a. ensure-deploy-key**
Call MCP tool `shipkit/ensure-deploy-key` with `{ "project": "$PROJECT_NAME" }`.
- On success: proceed to 3b.
- On MCP error (tool not found, timeout, auth): emit "Shipkit not connected; falling back to Vercel CLI..." and jump to Step 4.

**3b. deploy**
Call MCP tool `shipkit/deploy` with `{ "project": "$PROJECT_NAME", "env": "production" }`.
- On success: receive `deployment_id`. Proceed to 3c.
- On error: jump to Step 4.

**3c. get-deployment-status**
Poll MCP tool `shipkit/get-deployment-status` with `{ "deployment_id": "<id>" }` every 10s.
- Continue polling until `status` is `"ready"` or `"error"` (max 12 polls = 2 min).
- On `"ready"`: extract `url` field. Proceed to Step 5 with this URL.
- On `"error"` or timeout: jump to Step 4.

## Step 4 — Fallback: Vercel CLI

```bash
npx vercel --prod --yes 2>&1
```

Parse stdout for the production URL (line matching `https://*.vercel.app` or a custom domain).
- On success: proceed to Step 5 with the URL.
- On failure: emit "Deploy failed. Error details below:" followed by the last 15 lines of output. Write `.taw/checkpoint.json`: `{"status": "deploy-failed", "last_error": "<error>"}` and stop.

## Step 5 — Capture and persist URL

Write the live URL:
```bash
echo "<url>" > .taw/deploy-url.txt
```

Update `.taw/checkpoint.json`:
```json
{"status": "deployed", "deploy_url": "<url>", "deployed_at": "<ISO timestamp>"}
```

## Step 6 — Done

Emit exactly:
```
Deploy succeeded! 🎉
Live at: <live-url>
Want to add a feature? Type: /taw-add <description>
Something broken? Type: /taw-fix
```

Return `<live-url>` as the skill's output so callers (e.g. `/taw` Step 7) can use it.

## Constraints

- NEVER log Shipkit tokens, Vercel tokens, or any credentials.
- NEVER skip pre-flight checks, even when called from `/taw` automatically.
- If called without a taw-kit project (no `package.json`): emit "I don't see a project here. Cd into the project folder first."
- Custom domain arg (if the user passed one) is passed as `--prod --scope <domain>` to Vercel CLI. For Shipkit: add `"domain": "<arg>"` to the deploy call.
