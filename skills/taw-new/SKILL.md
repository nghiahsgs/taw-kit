---
name: taw-new
description: >
  Scaffold a new taw-kit project from a named preset. Loads presets/<name>.md,
  injects pre-filled intent into /taw context, skips classification (Step 1),
  jumps straight to clarify (Step 2) with preset questions. All user messages
  Vietnamese. Trigger phrases: "tao du an moi tu mau", "bat dau tu preset",
  "tao website moi", "new project", "scaffold tu", "dung mau co san".
argument-hint: "<ten-preset>"
allowed-tools: Read, Write, Bash, Glob, Task
---

# taw-new — Scaffold from Preset

You are the taw-new skill. Load a named preset and hand off to the /taw
orchestrator with pre-filled intent, bypassing classification. All strings
shown to the user MUST be Vietnamese.

## Available presets (valid names)

| Preset name | Mô tả |
|-------------|-------|
| `landing-page` | Trang giới thiệu + thu thập email |
| `shop-online` | Cửa hàng online + giỏ hàng + thanh toán |
| `crm` | Quản lý khách hàng + nhập CSV |
| `blog` | Blog markdown + một tác giả |
| `dashboard` | Bảng điều khiển KPI + biểu đồ |

## Step 1 — Validate preset name

Parse `<ten-preset>` from invocation args.

If arg is empty:
```
Bạn muốn dùng mẫu nào?
  1. landing-page — Trang giới thiệu + thu thập email
  2. shop-online  — Cửa hàng online + giỏ hàng + thanh toán
  3. crm          — Quản lý khách hàng + nhập CSV
  4. blog         — Blog markdown + một tác giả
  5. dashboard    — Bảng điều khiển KPI + biểu đồ
Gõ tên mẫu (vd: shop-online):
```
Wait for reply, then continue with the chosen name.

If name not in the valid list above:
1. Find closest match (substring or edit distance ≤ 2).
2. Emit: "Không tìm thấy mẫu `<name>`. Ý bạn là `<closest>`?" — wait for yes/no.
3. On `no`: show full list above and wait.
4. On `yes`: proceed with `<closest>`.

## Step 2 — Load preset file

Read `presets/<preset-name>.md`. Extract:
- `Pre-filled intent` section → use as `intent_vi` string
- `Pre-filled clarifications` YAML block → use as default answers
- `Stack overrides` section → merge into taw context (user overrides win)

If file is missing: emit "Mẫu `<name>` chưa được cài. Liên hệ hỗ trợ." and stop.

## Step 3 — Write pre-filled intent to .taw/

Create `.taw/` if absent.

Write `.taw/intent.json`:
```json
{
  "category": "<preset-name>",
  "raw": "<Pre-filled intent text from preset>",
  "keywords": ["<from preset>"],
  "source": "preset",
  "preset_name": "<name>",
  "clarifications": { <Pre-filled clarifications from preset> },
  "stack_overrides": { <from preset Stack overrides section> }
}
```

Emit: "Đang dùng mẫu `<preset-name>`. Chuẩn bị..."

## Step 4 — Hand off to /taw at Step 2

Invoke the /taw orchestrator with these instructions:

```
Skip Step 1 (classification is done — category = <preset-name>).
.taw/intent.json is already written with pre-filled clarifications.
Start at Step 2 (clarify). Use the clarify_questions from the preset as the
default question set. The user may have 0–2 additional Qs based on their answers.
Then continue normally through Steps 3–8.
```

Use the Task tool to spawn /taw with the above context note prepended to its
standard execution, passing `.taw/intent.json` as the starting state.

## Step 5 — Done (delegated to /taw)

/taw handles Steps 3–8 (plan, approval, agents, deploy). taw-new's job ends
after Step 4 handoff. The user will see /taw's standard Vietnamese output from
that point onward.

## Constraints

- User overrides always win over preset `Stack overrides`. If user says "không
  cần Supabase", honour that even if preset has `db: supabase`.
- NEVER skip the approval gate in /taw Step 4 — preset pre-fills reduce Q count
  but the single plan-approval gate is mandatory.
- Preset name matching is case-insensitive and strips leading/trailing spaces.
- If `/taw-new` is called inside an existing taw-kit project (`.taw/` already
  exists), warn: "Thư mục này đã có dự án. Bạn có muốn tạo dự án mới ở thư mục
  khác không?" — require explicit `yes` before overwriting `.taw/`.
