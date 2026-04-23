---
name: taw-new
description: >
  DEPRECATED — use `/taw` instead. This shim forwards to `/taw` with the BUILD branch
  (preset path). Kept for backward compatibility with earlier taw-kit versions.
argument-hint: "<preset-name> — use /taw from next version"
allowed-tools: Skill, Read, Write, Bash, Glob, Task
---

# taw-new — compat shim

This command was merged into `/taw` (see `skills/taw/branches/build.md`, Step 1p).

When invoked:

1. Emit (VN default):
   ```
   Giờ chỉ cần `/taw` thôi nha — em tự hiểu anh muốn scaffold từ preset.
   Gợi ý lần sau: gõ  /taw preset:<tên>  hoặc  /taw làm cho tôi một <tên preset>
   ```
2. Forward to `/taw` via the Skill tool, passing the args unchanged but prefixed with `preset:`:
   ```
   Skill({ skill: "taw", args: "preset:<user-args>" })
   ```
3. Let `/taw` handle the rest (it will load `@branches/build.md` Step 1p for the preset flow).

## Sunset plan

This shim will be removed in a future version (targeted after v0.x → v1.0). Users should switch to `/taw <description>` or `/taw preset:<name>`.
