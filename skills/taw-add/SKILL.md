---
name: taw-add
description: >
  Add a new feature to an existing taw-kit project without breaking what already works.
  Understands Vietnamese feature requests and integrates them into the current codebase.
  Trigger phrases: "them tinh nang", "bo sung them", "toi muon them", "can them chuc nang",
  "add feature", "them vao website".
argument-hint: "<mo ta tinh nang bang tieng Viet>"
---

# taw-add — Add Feature to Existing Project

## Purpose

When a user wants to extend their existing taw-kit project with a new feature,
this skill reads the current codebase, understands its structure, plans the
minimal change needed, and implements it safely — in Vietnamese communication.

## Trigger Phrases (VN + EN)

Vietnamese: "them tinh nang", "bo sung", "toi muon them", "can them", "add them vao"
English: "/taw-add", "add a feature", "extend with", "I want to add"

## Invocation Pattern

```
/taw-add them form lien he co gui email tu dong
/taw-add bo sung trang blog voi markdown
/taw-add them gio hang don gian khong can dang nhap
/taw-add tich hop Zalo OA de nhan don hang
```

## What This Skill Does

1. Reads current project structure: `app/`, `components/`, `lib/`, `package.json`.
2. Parses the Vietnamese feature request to extract: feature type, data needed, UI location.
3. Activates `approval-plan` to confirm the implementation approach with user.
4. Checks if new dependencies are needed; runs `npm install` if so.
5. Spawns `fullstack-dev` agent scoped to the new feature files only (no refactoring).
6. Runs `npm run build` after implementation; routes failures to `taw-fix`.
7. Shows user a diff summary in Vietnamese before any files are modified.
8. Commits via `git-auto-commit` with a conventional commit message.

## Scope Rules

- Only adds new files or appends to existing ones — no rewrites of working code.
- Database migrations go through `supabase-setup` skill patterns.
- New payment flows use `payment-integration` skill.
- Any new form uses `form-builder` skill patterns.

## Non-Dev Guarantees

- User sees a plain-language plan in Vietnamese before code is written.
- "Da them xong!" confirmation with a list of what was added.
- Rollback instruction provided if user dislikes the result.

> Implementation: see phase-04
