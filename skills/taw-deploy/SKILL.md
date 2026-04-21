---
name: taw-deploy
description: >
  One-command deploy for taw-kit projects. Supports three targets:
  Vercel (default, cloud), Docker (container image for any host), and VPS
  (self-managed server via SSH + systemd + nginx). User-visible strings are
  simple English. Trigger phrases (EN + VN): "deploy this", "publish the
  site", "go live", "push to vercel", "dockerize", "deploy to my vps",
  "deploy di", "day len vercel".
argument-hint: "[--target=vercel|docker|vps] [domain-or-host]"
allowed-tools: Read, Write, Bash, Grep, Task
---

# taw-deploy — One-Command Deploy

You are the taw-deploy skill. Ship the current taw-kit project to production and return a live URL (for Vercel) or access instructions (Docker/VPS). All strings shown to the user MUST be simple English.

## Step 1 — Pre-flight checks

Run ALL checks before touching deploy infrastructure. If any check fails, stop and emit the matching message — do NOT proceed.

| # | Check | Command | Fail message |
|---|-------|---------|--------------|
| 1 | Build passes locally | `npm run build 2>&1` exit 0 | "Build is failing. Run `/taw-fix` first." |
| 2 | `.env.local` exists | `test -f .env.local` | "`.env.local` is missing. Create it with your Supabase + Polar keys." |
| 3 | No secrets in tracked files | `git grep -lE "(SUPABASE_SERVICE_KEY\|POLAR_SECRET\|sk-[a-zA-Z]{20})" -- '*.ts' '*.tsx' '*.js'` returns empty | "Secret detected in source. Remove it before deploying." |
| 4 | Required env keys present | grep `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` in `.env.local` | "Missing Supabase keys in `.env.local`." |
| 5 | Config file exists | `test -f next.config.js -o -f next.config.mjs -o -f next.config.ts` | "Next.js config not found. Is this a taw-kit project?" |

Emit progress: "Pre-flight checks... done"

## Step 2 — Pick a deploy target

Parse target from args (`--target=vercel|docker|vps`). If not given:

1. If `.taw/deploy-target.txt` exists, read from it.
2. Otherwise ask:
   ```
   Where do you want to deploy?
     1. vercel  — Free cloud hosting, fastest to set up (recommended)
     2. docker  — Build a Docker image; run it on any host you own
     3. vps     — Deploy to your own VPS over SSH (systemd + nginx)
   Type: vercel / docker / vps
   ```
3. Save the choice to `.taw/deploy-target.txt`.

## Step 3 — Deploy

Read project name from `package.json` (`$PROJECT_NAME`).

### Target: vercel

```bash
npx vercel --prod --yes 2>&1
```

- Parse stdout for a URL matching `https://*.vercel.app` or the user's custom domain.
- On success: go to Step 4 with the URL.
- On failure: emit "Deploy failed. Error details below:" + last 15 lines. Write `.taw/checkpoint.json`: `{"status": "deploy-failed", "target": "vercel", "last_error": "..."}`. Stop.

Vercel auth: if `npx vercel` prompts for login, tell the user:
```
Vercel needs a one-time login. A browser will open — click "Accept".
```

### Target: docker

Create a production-ready `Dockerfile` if missing:

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 3000
CMD ["npm", "start"]
```

Also create `.dockerignore` if missing (`node_modules`, `.next`, `.env*`, `.git`).

Build the image:
```bash
docker build -t $PROJECT_NAME:latest .
```

Then emit:
```
Docker image ready: $PROJECT_NAME:latest

Run it locally:
  docker run --env-file .env.local -p 3000:3000 $PROJECT_NAME:latest

Push to a registry:
  docker tag $PROJECT_NAME:latest <registry>/$PROJECT_NAME:latest
  docker push <registry>/$PROJECT_NAME:latest

Then run on your host. See docs/troubleshooting.md for nginx reverse proxy notes.
```

Write `.taw/deploy-url.txt`: `docker://$PROJECT_NAME:latest`.

### Target: vps

Require `.taw/vps.env` with: `VPS_HOST`, `VPS_USER`, `VPS_PATH` (defaults `/var/www/$PROJECT_NAME`), `VPS_PORT` (defaults 22).

If the file is missing, emit:
```
VPS config needed. Create .taw/vps.env with:
  VPS_HOST=your-server.com
  VPS_USER=deploy
  VPS_PATH=/var/www/$PROJECT_NAME
  VPS_PORT=22
Re-run /taw-deploy --target=vps when ready.
```
Stop.

If present:

1. Build locally:
   ```bash
   npm run build
   ```
2. Rsync build output + required runtime files:
   ```bash
   rsync -az --delete \
     --exclude node_modules --exclude .env.local --exclude .git \
     ./ "$VPS_USER@$VPS_HOST:$VPS_PATH/"
   ```
3. On the remote, install prod deps and (re)start via systemd:
   ```bash
   ssh "$VPS_USER@$VPS_HOST" "cd $VPS_PATH && npm ci --omit=dev && sudo systemctl restart $PROJECT_NAME"
   ```
4. If systemd unit is missing, emit the unit content and instructions:
   ```
   Add /etc/systemd/system/$PROJECT_NAME.service on your VPS:

   [Unit]
   Description=$PROJECT_NAME (taw-kit)
   After=network.target

   [Service]
   Type=simple
   WorkingDirectory=$VPS_PATH
   EnvironmentFile=$VPS_PATH/.env.local
   ExecStart=/usr/bin/node node_modules/.bin/next start -p 3000
   Restart=always
   User=$VPS_USER

   [Install]
   WantedBy=multi-user.target

   Then:
     sudo systemctl daemon-reload
     sudo systemctl enable --now $PROJECT_NAME
   ```
5. Point a reverse proxy (nginx/Caddy) to `127.0.0.1:3000`. Example nginx snippet written to `.taw/nginx.conf.snippet` for the user to copy.

Write `.taw/deploy-url.txt`: `ssh://$VPS_USER@$VPS_HOST$VPS_PATH` + the public domain the user points at the VPS.

## Step 4 — Capture and persist

```bash
echo "<url-or-identifier>" > .taw/deploy-url.txt
```

Update `.taw/checkpoint.json`:
```json
{"status": "deployed", "target": "<vercel|docker|vps>", "deploy_url": "<url>", "deployed_at": "<ISO timestamp>"}
```

## Step 5 — Done

Emit exactly (substitute the relevant line):
```
Deploy succeeded! 🎉
<one of:>
  Live at: <https://...vercel.app>              # vercel
  Image ready: $PROJECT_NAME:latest             # docker
  Deployed to: $VPS_USER@$VPS_HOST:$VPS_PATH    # vps

Want to add a feature? Type: /taw-add <description>
Something broken? Type: /taw-fix
```

## Constraints

- NEVER log tokens, SSH keys, or credentials.
- NEVER skip pre-flight checks, even when called from `/taw` automatically.
- If called outside a taw-kit project (no `package.json`): emit "I don't see a project here. Cd into the project folder first."
- Optional `domain-or-host` arg overrides: Vercel → `--prod --scope <domain>`; VPS → `VPS_HOST=<arg>`; Docker → ignored.
- If Docker CLI is missing on target=docker: emit install hint (`brew install docker` on Mac / Docker Desktop elsewhere) and stop.
- If `ssh` or `rsync` is missing on target=vps: emit install hint and stop.
