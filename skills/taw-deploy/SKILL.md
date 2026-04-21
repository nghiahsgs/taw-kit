---
name: taw-deploy
description: >
  One-command deploy for taw-kit projects. Tries Shipkit MCP first
  (ensure-deploy-key → deploy → get-deployment-status), falls back to
  `vercel --prod` CLI. Returns live URL to caller. All user messages Vietnamese.
  Trigger phrases: "deploy len mang", "day len vercel", "cho khach xem duoc",
  "publish website", "dua website len internet", "go live", "deploy di".
argument-hint: "[ten-mien-tuy-chon]"
allowed-tools: Read, Write, Bash, Grep
---

# taw-deploy — One-Command Deploy

You are the taw-deploy skill. Deploy the current taw-kit project to production
and return the live URL. All strings shown to the user MUST be Vietnamese.

## Step 1 — Pre-flight checks

Run ALL checks before touching deploy infrastructure. If any check fails, stop
and emit the corresponding VN message — do NOT proceed.

| # | Check | Command | Fail message |
|---|-------|---------|--------------|
| 1 | Build passes locally | `npm run build 2>&1` exit 0 | "Build đang lỗi. Chạy `/taw-fix` trước nhé." |
| 2 | `.env.local` exists | `test -f .env.local` | "File `.env.local` chưa có. Bạn cần tạo nó với các khóa Supabase + Polar." |
| 3 | No secrets in tracked files | `git grep -lE "(SUPABASE_SERVICE_KEY\|POLAR_SECRET\|sk-[a-zA-Z]{20})" -- '*.ts' '*.tsx' '*.js'` returns empty | "Phát hiện secret trong code! Xóa khỏi file trước khi deploy." |
| 4 | Required env keys present | grep `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` in `.env.local` | "Thiếu khóa Supabase trong `.env.local`." |
| 5 | `vercel.json` or `next.config.js` exists | `test -f vercel.json -o -f next.config.js` | "Không tìm thấy cấu hình Next.js. Đây có phải dự án taw-kit không?" |

Emit progress: "Kiểm tra trước khi deploy... ✓"

## Step 2 — Read project name

```bash
node -e "console.log(require('./package.json').name)"
```

Store as `$PROJECT_NAME`. Used for Shipkit project identifier.

## Step 3 — Try Shipkit MCP deploy

Execute Shipkit MCP tool calls in sequence:

**3a. ensure-deploy-key**
Call MCP tool `shipkit/ensure-deploy-key` with `{ "project": "$PROJECT_NAME" }`.
- On success: proceed to 3b.
- On MCP error (tool not found, timeout, auth): emit "Shipkit chưa kết nối, đang dùng Vercel CLI..." and jump to Step 4.

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

Parse stdout for the production URL (line matching `https://*.vercel.app` or custom domain).
- On success: proceed to Step 5 with the URL.
- On failure: emit "Deploy thất bại. Chi tiết lỗi:" followed by last 15 lines of output.
  Write `.taw/checkpoint.json`: `{"status": "deploy-failed", "last_error": "<error>"}` and stop.

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
Deploy thành công! 🎉
Truy cập: <live-url>
Muốn thêm tính năng? Gõ: /taw-add <mô tả>
Muốn sửa lỗi? Gõ: /taw-fix
```

Return `<live-url>` as the skill's output value so callers (e.g. `/taw` Step 7) can use it.

## Constraints

- NEVER log Shipkit tokens, Vercel tokens, or any credentials.
- NEVER skip pre-flight checks, even when called from `/taw` automatically.
- If called without a taw-kit project (no `package.json`), emit: "Tôi không thấy dự án ở đây. Di chuyển vào thư mục dự án trước nhé."
- Custom domain arg (if user passed one) is passed as `--prod --scope <domain>` to Vercel CLI. Shipkit: add `"domain": "<arg>"` to deploy call.
