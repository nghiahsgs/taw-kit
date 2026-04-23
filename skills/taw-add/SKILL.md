---
name: taw-add
description: >
  DEPRECATED — use `/taw` instead. This shim forwards to `/taw` with the BUILD branch
  (add-feature path). Kept for backward compatibility with earlier taw-kit versions.
argument-hint: "<feature description> — use /taw from next version"
allowed-tools: Skill, Read, Write, Edit, Bash, Glob, Grep, Task
---

# taw-add — compat shim

This command was merged into `/taw` (see `skills/taw/branches/build.md`, Steps A1–A6).

When invoked:

1. Emit (VN default):
   ```
   Giờ chỉ cần `/taw` thôi nha — em tự hiểu anh muốn thêm tính năng.
   Gợi ý lần sau: gõ  /taw thêm <mô tả>
   ```
2. Forward to `/taw` via the Skill tool:
   ```
   Skill({ skill: "taw", args: "thêm <user-args>" })
   ```
3. `/taw` routes to `@branches/build.md` and detects `.taw/intent.json` already exists → runs add-feature sub-flow (A1–A6).

## Sunset plan

Removed in a future version. Users should switch to `/taw thêm <feature>` or `/taw add <feature>`.
