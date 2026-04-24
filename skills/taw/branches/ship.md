# branch: SHIP

Routed here when user wants to deploy / publish / go live. Supports 3 targets: Vercel (default cloud), Docker (container), VPS (SSH + systemd + nginx).

**Prereq:** router classified `tier1 = SHIP`.

## Step 1 — Security gate (BLOCKING)

Run `@branches/maintain/security.md` in quick mode (P0 only). Read the report.

- **0 P0** → emit `✓ Quét bảo mật: an toàn` and continue
- **≥1 P0** → STOP. Echo P0 list verbatim. Emit:
  ```
  🚨 Không thể deploy — còn {N} lỗi bảo mật P0.
  Gõ `/taw audit` để xem và fix, rồi thử deploy lại.
  ```
  Write `.taw/checkpoint.json`: `{"status":"blocked-by-security","p0_count":N}`. Do NOT proceed.

P1/P2 reported but never block.

## Step 2 — Pre-flight checks

Run ALL. Any fail → stop with matching message.

| # | Check | Command | Fail msg |
|---|---|---|---|
| 1 | Build passes | `npm run build` exit 0 | "Build đang lỗi. Gõ `/taw fix` trước." |
| 2 | `.env.local` exists | `test -f .env.local` | "Thiếu `.env.local`. Tạo file với keys Supabase+Polar." |
| 3 | Required env keys | grep `NEXT_PUBLIC_SUPABASE_URL` + `NEXT_PUBLIC_SUPABASE_ANON_KEY` | "Thiếu keys Supabase trong `.env.local`." |
| 4 | Next config exists | `test -f next.config.{js,mjs,ts}` | "Không thấy next config — đây có phải dự án taw-kit?" |

Emit: "Pre-flight checks... xong"

## Step 3 — Pick target

Parse `--target=` from args. If not given:
1. `.taw/deploy-target.txt` exists → read
2. Else ask:
   ```
   Deploy đi đâu?
     1. vercel — Free cloud, nhanh nhất (recommended)
     2. docker — Build image, chạy trên host bất kỳ
     3. vps    — VPS qua SSH (systemd + nginx)
   Gõ: vercel / docker / vps
   ```
3. Save choice to `.taw/deploy-target.txt`.

## Step 4 — Deploy

Read project name from `package.json` as `$PROJECT_NAME`.

### Target: vercel

```bash
npx vercel --prod --yes 2>&1
```

Parse stdout for `https://*.vercel.app` or custom domain. Success → Step 5 with URL. Failure → emit last 15 lines. Write checkpoint `{"status":"deploy-failed","target":"vercel","last_error":"..."}`. Stop.

If vercel prompts login: "Vercel cần login 1 lần — browser sẽ mở, nhấn Accept."

### Target: docker

Create `Dockerfile` if missing:
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

Create `.dockerignore` if missing (`node_modules`, `.next`, `.env*`, `.git`).

```bash
docker build -t $PROJECT_NAME:latest .
```

Emit:
```
Docker image ready: $PROJECT_NAME:latest

Chạy local:
  docker run --env-file .env.local -p 3000:3000 $PROJECT_NAME:latest

Push lên registry:
  docker tag $PROJECT_NAME:latest <registry>/$PROJECT_NAME:latest
  docker push <registry>/$PROJECT_NAME:latest
```

Write `.taw/deploy-url.txt`: `docker://$PROJECT_NAME:latest`.

### Target: vps

Require `.taw/vps.env` with `VPS_HOST`, `VPS_USER`, `VPS_PATH` (default `/var/www/$PROJECT_NAME`), `VPS_PORT` (default 22).

If missing:
```
Cần config VPS. Tạo .taw/vps.env:
  VPS_HOST=your-server.com
  VPS_USER=deploy
  VPS_PATH=/var/www/$PROJECT_NAME
  VPS_PORT=22
Rồi chạy lại /taw deploy --target=vps
```
Stop.

If present:
1. `npm run build`
2. Rsync:
   ```bash
   rsync -az --delete --exclude node_modules --exclude .env.local --exclude .git \
     ./ "$VPS_USER@$VPS_HOST:$VPS_PATH/"
   ```
3. Remote install + restart:
   ```bash
   ssh "$VPS_USER@$VPS_HOST" "cd $VPS_PATH && npm ci --omit=dev && sudo systemctl restart $PROJECT_NAME"
   ```
4. If systemd unit missing, emit the unit file:
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
5. Write nginx/Caddy snippet to `.taw/nginx.conf.snippet`.

Write `.taw/deploy-url.txt`: `ssh://$VPS_USER@$VPS_HOST$VPS_PATH` + public domain.

## Step 5 — Persist

```bash
echo "<url-or-id>" > .taw/deploy-url.txt
```

Update `.taw/checkpoint.json`:
```json
{"status":"deployed","target":"<t>","deploy_url":"<url>","deployed_at":"<ISO>"}
```

## Step 6 — Done

```
taw-kit: deploy xong! 🎉
<one of:>
  Live at:       https://...vercel.app               # vercel
  Image ready:   $PROJECT_NAME:latest                 # docker
  Deployed to:   $VPS_USER@$VPS_HOST:$VPS_PATH        # vps

Tiếp theo:
  → "thêm <tính năng>"     (mở rộng dự án)
  → "fix"                   (nếu prod có vấn đề)
  → "status"                (xem health của dự án vừa deploy)
```

## Constraints

- NEVER log tokens, SSH keys, credentials
- NEVER skip pre-flight, even when called from BUILD branch
- If called outside a taw-kit project: "Không thấy dự án ở đây. Cd vào project folder trước."
- Optional `domain-or-host` arg: Vercel `--scope <domain>`; VPS overrides `VPS_HOST`; Docker ignores
- Missing docker CLI → "Chưa có docker. Cài: `brew install docker` (Mac) hoặc Docker Desktop." Stop.
- Missing ssh/rsync on target=vps → install hint + stop
