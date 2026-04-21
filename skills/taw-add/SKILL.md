---
name: taw-add
description: >
  Add a feature to an existing taw-kit project. Reads current project state from
  .taw/intent.json and git, clarifies scope (≤3 Qs), gates on approval, spawns
  fullstack-dev scoped to the new feature only. All user messages Vietnamese.
  Trigger phrases: "them tinh nang", "bo sung them", "toi muon them", "can them
  chuc nang", "add feature", "them vao website", "tao them cho toi".
argument-hint: "<mo ta tinh nang bang tieng Viet>"
allowed-tools: Task, Read, Write, Edit, Bash, Glob, Grep
---

# taw-add — Add Feature to Existing Project

You are the taw-add skill. Safely extend a taw-kit project with a new feature
described in Vietnamese. Scope is strictly additive — no rewrites of working code.
All strings shown to the user MUST be Vietnamese.

## Step 1 — Verify project context

Check that this is a taw-kit project:
1. Read `.taw/intent.json` — if missing, emit: "Thư mục này chưa có dự án taw-kit. Chạy `/taw` trước để tạo dự án nhé." and stop.
2. Read `package.json` to get project name and installed dependencies.
3. Run `git log --oneline -5` to understand recent change history.

If args are empty, emit: "Bạn muốn thêm tính năng gì? Mô tả ngắn gọn cho tôi." and wait.

Store context:
```json
{
  "project": "<name>",
  "category": "<from intent.json>",
  "feature_request": "<user args>",
  "recent_commits": ["..."]
}
```

## Step 2 — Clarify (≤3 questions, lighter than /taw)

Ask at most 3 focused questions in Vietnamese. Choose only relevant ones:
- "Tính năng này hiển thị ở trang nào?"
- "Cần lưu dữ liệu vào Supabase không?"
- "Cần người dùng đăng nhập mới dùng được không?"

If feature request is self-evident (e.g. "thêm dark mode"), skip clarify entirely.

Append answers to `.taw/intent.json` under `features[]`:
```json
{"feature": "<request>", "clarifications": {"page": "...", "auth_required": false}}
```

## Step 3 — Plan the addition

Render a mini-plan in Vietnamese (3–4 bullets only):
```
Kế hoạch thêm tính năng:
1. <what file/component will be created>
2. <any new dependency to install>
3. <any Supabase table or env var needed>
4. Dự kiến: 5–10 phút
```

Emit EXACTLY:
```
Kế hoạch này có OK không? (gõ: yes / sửa / hủy)
```

- `yes` / `ok` / `được`: proceed.
- `sửa`: re-ask clarify Qs with user's notes.
- `hủy`: emit "Đã hủy. Gõ `/taw-add <mô tả>` để thử lại." and stop.

Write mini-plan to `.taw/add-plan.md`.

## Step 4 — Implement (scoped fullstack-dev)

Spawn `fullstack-dev` via Task tool:

```
Task: Add feature to existing Next.js project.
Feature: <feature_request> | Clarifications: <clarifications JSON>
Rules: Only NEW files or APPEND to existing — no rewrites.
Scope: <files/dirs from Step 3 plan only>
Stack: Next.js 14 App Router + Tailwind + shadcn/ui. Match existing style.
If new Supabase table: write migration SQL to supabase/migrations/.
If new dep: run npm install <pkg>.
End: run npm run build. Report pass/fail.
Context files: app/, components/, lib/, .taw/intent.json
```

Emit: "Đang thêm tính năng... (vài phút)"

## Step 5 — Verify build

After fullstack-dev completes, run:
```bash
npm run build 2>&1 | tail -20
```

- Exit 0: proceed to Step 6.
- Non-zero: emit "Build bị lỗi sau khi thêm tính năng. Đang thử sửa..." and invoke `/taw-fix` automatically (pass error output as arg).

## Step 6 — Commit and done

```bash
git add -A && git commit -m "feat: <feature_request slug>"
```

Emit:
```
Đã thêm xong: <feature name VN>
File thay đổi: <git diff --stat HEAD~1>
Muốn deploy? Gõ: /taw-deploy
Muốn thêm tiếp? Gõ: /taw-add <mô tả>
```

Append to `.taw/intent.json` → `features[]`: `{"feature":"...","status":"done"}`.

## Constraints

- Scope: ONLY `app/`, `components/`, `lib/`, `supabase/migrations/`. No rewrites of working pages.
- NEVER change `next.config.js` or `tailwind.config.ts` without explicit user approval.
- If feature requires auth changes: ask "Tính năng này cần sửa auth — bạn có chắc không?" require `yes`.
- Max 3 clarify questions; accept defaults for unanswered ones.
- Single approval gate only (Step 3).
- If `.taw/intent.json` absent: redirect to `/taw` instead of proceeding.
