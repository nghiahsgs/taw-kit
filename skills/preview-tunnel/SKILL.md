---
name: preview-tunnel
description: >
  Run Next.js dev server and expose it via localtunnel for live preview sharing.
  Returns a public URL the user can send to clients or view on mobile.
  Activated after scaffold to let user see their site before deploy.
argument-hint: "[port hoac 'start']"
---

# preview-tunnel — Live Preview via Tunnel

## Purpose

Give non-dev users a shareable preview URL for their locally running Next.js app
without needing to deploy. Useful for client reviews and mobile testing.

## Workflow

### Step 1: Start Dev Server

```bash
npm run dev
# Runs on http://localhost:3000 by default
```

### Step 2: Open Tunnel

```bash
npx localtunnel --port 3000
# Returns: your url is: https://random-name.loca.lt
```

Or with a fixed subdomain (not guaranteed, best effort):
```bash
npx localtunnel --port 3000 --subdomain ten-cua-hang
# Returns: https://ten-cua-hang.loca.lt
```

### Step 3: Share URL

Provide user with the tunnel URL and this note in Vietnamese:
```
Link xem thu: https://ten-cua-hang.loca.lt
(Link nay chi hoat dong khi may tinh ban dang bat.
De co link thuong tru, dung /taw-deploy)
```

## Running Both in Parallel

```bash
# Terminal 1
npm run dev

# Terminal 2
npx localtunnel --port 3000
```

Or with a single command using `concurrently`:
```bash
npm install --save-dev concurrently
```
Add to `package.json`:
```json
{
  "scripts": {
    "preview": "concurrently \"npm run dev\" \"npx localtunnel --port 3000\""
  }
}
```
Then: `npm run preview`

## Common Issues

| Issue | Fix |
|-------|-----|
| "localtunnel: command not found" | Run `npx localtunnel` (no global install needed) |
| Tunnel URL shows password prompt | Enter any text — it's loca.lt's anti-abuse gate |
| Port 3000 already in use | Kill with `lsof -ti:3000 \| xargs kill -9` or use port 3001 |
| Slow tunnel | Normal for loca.lt; for faster preview use Vercel deploy |

## Alternative: Vercel Preview

If localtunnel is unreliable, deploy a preview branch instead:
```bash
vercel deploy --prebuilt
# Returns a preview URL like: https://project-abc123.vercel.app
```

## Note on Supabase

Supabase auth redirect URLs must include the tunnel URL for magic-link auth to
work during preview. Add `https://*.loca.lt` to allowed redirect URLs in
Supabase dashboard → Auth → URL Configuration.
