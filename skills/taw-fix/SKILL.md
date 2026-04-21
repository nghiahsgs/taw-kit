---
name: taw-fix
description: >
  Auto-diagnose and fix broken builds, runtime errors, and TypeScript errors in
  taw-kit projects. Translates errors to Vietnamese for non-dev users.
  Trigger phrases: "loi roi", "bi loi", "khong chay duoc", "fix giup toi",
  "website bi hong", "co loi xuat hien".
argument-hint: "[error message or 'tu dong kiem tra']"
---

# taw-fix — Auto Diagnose & Fix

## Purpose

When the build breaks or an error appears, this skill reads the error output,
locates the root cause in project files, proposes a fix, applies it, and
re-runs the build to confirm resolution — all explained in Vietnamese.

## Trigger Phrases (VN + EN)

Vietnamese: "loi roi", "khong chay duoc", "bi loi", "fix giup toi", "website bi hong"
English: "/taw-fix", "fix the error", "something broke", "build failed"

## Invocation Pattern

```
/taw-fix
/taw-fix khong chay duoc tren Vercel
/taw-fix loi TypeScript o trang chu
```

## What This Skill Does

1. Captures last build/runtime error from terminal or Vercel logs.
2. Activates `debug` skill: read stack trace, grep relevant files, identify root cause.
3. Activates `sequential-thinking` skill for multi-step diagnosis on complex errors.
4. Proposes fix in ≤3 steps; shows plain-Vietnamese explanation to user.
5. Applies the fix to the relevant file(s).
6. Re-runs `npm run build` to verify resolution.
7. If error persists after 2 attempts: activates `approval-plan` to ask user for more context.
8. Translates final status to Vietnamese via `error-to-vi`.

## Fix Strategy Priority

1. Type errors → check TypeScript types, missing imports, null safety.
2. Module not found → check `package.json`, run `npm install`.
3. Supabase errors → check `.env.local` keys, RLS policy, table schema.
4. Build size / memory → check `next.config.js`, remove unused imports.
5. Runtime crashes → check `try/catch` coverage, undefined access.

## Non-Dev Guarantees

- All error messages shown to user are in Vietnamese.
- User sees a simple "Da sua xong!" or "Can them thong tin" — not a stack trace.
- No destructive file changes without showing the diff first.

> Implementation: see phase-04
