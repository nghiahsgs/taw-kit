---
name: debug
description: >
  Systematic error analysis for taw-kit projects. Reads stack traces, greps
  relevant source files, identifies root cause, and proposes a targeted fix.
  Activated by taw-fix. Uses sequential-thinking for multi-cause errors.
argument-hint: "[error text hoac 'tu dong phan tich']"
---

# debug — Systematic Error Analysis

## Purpose

Diagnose build, runtime, and Supabase errors in taw-kit projects using a
structured read-grep-hypothesize-fix loop. Called by `taw-fix`; not invoked
directly by users.

## Diagnostic Process

### Step 1: Capture Error Context

```bash
# Last build error
npm run build 2>&1 | tail -50

# Last dev server error
# Read from terminal output provided by user or taw-fix
```

### Step 2: Parse the Error

Extract from error output:
- **Error type**: TypeError, SyntaxError, ModuleNotFoundError, SupabaseError, etc.
- **File path**: e.g. `app/shop/page.tsx:34`
- **Line number**: for targeted file read
- **Error message**: the actual message text

### Step 3: Read the Failing File

```bash
# Read specific lines around the error
# Use Read tool with offset=(line-10) and limit=30
```

### Step 4: Grep for Related Code

```bash
# Find all usages of the failing function/import
grep -rn "functionName\|ImportName" --include="*.tsx" --include="*.ts" app/ lib/ components/

# Find where a type is defined
grep -rn "interface TypeName\|type TypeName" --include="*.ts" .
```

### Step 5: Hypothesize Root Cause

Apply `sequential-thinking` for errors with multiple possible causes:

```
Thought 1/3: Error message says X. Most likely cause: Y.
Thought 2/3: Checked file at line N. Confirmed: [null access / wrong type / missing import].
Thought 3/3 [FINAL]: Root cause is Z. Fix: [specific change].
```

### Step 6: Propose and Apply Fix

State fix clearly before applying:
```
Nguyen nhan: [root cause in 1 sentence]
Sua: [what to change, where]
```

Apply the minimal change — do not refactor surrounding code.

### Step 7: Verify

```bash
npm run build
# or for runtime errors:
npm run dev
```

If build passes: report success to `taw-fix`.
If build still fails: repeat from Step 1 with new error output (max 3 iterations).

## Error Category Quick Reference

| Category | First grep target |
|----------|------------------|
| Import error | `grep -rn "from.*<module>"` to find all import sites |
| Type error | Read the file at the reported line; check type annotations |
| Supabase error | Check `.env.local` keys; check table/column name spelling |
| `undefined` access | Look for missing `?.` optional chaining or null checks |
| Async error | Check for missing `await` before async calls |
| CSS/Tailwind | Check class name spelling; verify `tailwind.config.ts` content paths |

## Escalation

After 3 failed fix attempts:
- Activate `approval-plan` to ask user for more context
- Ask: "Ban co the chup man hinh loi va gui cho toi khong?"
- If Supabase-related: guide user to Supabase dashboard logs
