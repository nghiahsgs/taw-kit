---
name: taw-fix
description: >
  DEPRECATED — use `/taw` instead. This shim forwards to `/taw` with the FIX branch.
  Kept for backward compatibility with earlier taw-kit versions.
argument-hint: "[error text] — use /taw from next version"
allowed-tools: Skill, Read, Write, Edit, Bash, Grep, Glob
---

# taw-fix — compat shim

This command was merged into `/taw` (see `skills/taw/branches/fix.md`).

When invoked:

1. Emit (VN default):
   ```
   Giờ chỉ cần `/taw` thôi nha — em tự hiểu là fix lỗi.
   Gợi ý lần sau: gõ  /taw fix  hoặc  /taw lỗi rồi
   ```
2. Forward to `/taw`:
   ```
   Skill({ skill: "taw", args: "fix <user-args>" })
   ```
3. `/taw` routes to `@branches/fix.md`.

## Sunset plan

Removed in a future version. Users should switch to `/taw fix` or `/taw lỗi rồi`.
