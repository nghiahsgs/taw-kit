---
name: taw-security
description: >
  DEPRECATED — use `/taw` instead. This shim forwards to `/taw` with the
  MAINTAIN/security branch. Kept for backward compatibility with earlier
  taw-kit versions.
argument-hint: "[full | quick | path] — use /taw from next version"
allowed-tools: Skill, Read, Bash, Grep, Glob, Edit, Write
---

# taw-security — compat shim

This command was merged into `/taw` (see `skills/taw/branches/maintain/security.md`).

When invoked:

1. Emit (VN default):
   ```
   Giờ chỉ cần `/taw` thôi nha — em tự hiểu là audit bảo mật.
   Gợi ý lần sau: gõ  /taw audit  hoặc  /taw kiểm tra bảo mật
   ```
2. Forward to `/taw`:
   ```
   Skill({ skill: "taw", args: "audit <user-args>" })
   ```
3. `/taw` routes to `@branches/maintain/security.md`.

## Sunset plan

Removed in a future version. Users should switch to `/taw audit` or `/taw kiểm tra bảo mật`.
