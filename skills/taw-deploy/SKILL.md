---
name: taw-deploy
description: >
  DEPRECATED — use `/taw` instead. This shim forwards to `/taw` with the SHIP branch.
  Kept for backward compatibility with earlier taw-kit versions.
argument-hint: "[--target=vercel|docker|vps] — use /taw from next version"
allowed-tools: Skill, Read, Write, Bash, Grep, Task
---

# taw-deploy — compat shim

This command was merged into `/taw` (see `skills/taw/branches/ship.md`).

When invoked:

1. Emit (VN default):
   ```
   Giờ chỉ cần `/taw` thôi nha — em tự hiểu là deploy.
   Gợi ý lần sau: gõ  /taw deploy  hoặc  /taw đẩy lên vercel
   ```
2. Forward to `/taw`:
   ```
   Skill({ skill: "taw", args: "deploy <user-args>" })
   ```
3. `/taw` routes to `@branches/ship.md`.

## Sunset plan

Removed in a future version. Users should switch to `/taw deploy` or `/taw đẩy lên vercel`.
