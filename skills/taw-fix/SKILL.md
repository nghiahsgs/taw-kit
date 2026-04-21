---
name: taw-fix
description: >
  Diagnose and auto-fix broken builds or runtime errors in taw-kit projects.
  Reads .taw/checkpoint.json for last error, runs build, parses output, applies
  fix, re-runs build. Retries up to 3 times total. User-visible messages are
  simple English. Trigger phrases (EN + VN):
  "fix it", "build fail", "it's broken", "something's wrong",
  "loi roi", "bi loi", "khong chay duoc", "fix giup toi",
  "website bi hong", "co loi xuat hien", "sua loi giup toi".
argument-hint: "[paste error] | auto"
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# taw-fix — Diagnose & Auto-Fix

You are the taw-fix skill. When invoked, diagnose and fix the broken project.
User-visible strings are simple English. Internal reasoning is English.

## Step 1 — Locate the error

Check sources in order:
1. If user pasted an error message in the invocation args, use that directly.
2. Else read `.taw/checkpoint.json`; extract `last_error` field.
3. If both are empty, run `npm run build 2>&1 | tail -60` and capture output.
4. If still no error found, emit: "I don't see an error. Try running it again, or paste the error message here."

Write the raw error text to `.taw/fix-session.json`:
```json
{"error_raw": "<captured text>", "attempt": 1, "status": "diagnosing"}
```

## Step 2 — Classify the error

Read the error text and assign exactly ONE category:

| Category | Signals |
|----------|---------|
| `missing-dep` | "Cannot find module", "Module not found", "ERR_MODULE_NOT_FOUND" |
| `type-error` | "Type error", "TS", "is not assignable", "Property does not exist" |
| `env-missing` | "undefined", "process.env", "NEXT_PUBLIC_" missing, Supabase 401 |
| `port-busy` | "EADDRINUSE", "address already in use" |
| `syntax-error` | "SyntaxError", "Unexpected token", "Expected ')'", "Unexpected identifier" |
| `supabase` | "relation does not exist", "JWT", "RLS", "permission denied for table" |
| `build-memory` | "JavaScript heap out of memory", "ENOMEM" |
| `runtime-crash` | "TypeError: Cannot read", "undefined is not a function", "null reference" |
| `unknown` | anything else |

## Step 3 — Apply known fix

Execute the fix for the classified category:

**missing-dep:** Extract package name from error. Run `npm install <package>`. Confirm with: "Installed the missing package."

**type-error:** Grep for the flagged file + line. Read that section. Apply minimal type annotation or null-check. Confirm with: "Fixed the type error."

**env-missing:** Check `.env.local`. If key is missing, prompt: "You need to add the key `<KEY>` to `.env.local`. Where do I get this value?" — wait for reply, then write the key.

**port-busy:** Run `lsof -ti tcp:3000 | xargs kill -9 2>/dev/null`. Confirm: "Freed up port 3000."

**syntax-error:** Grep for the flagged file. Read ±10 lines around the error line. Apply the fix (close bracket, fix quote, etc.). Confirm: "Fixed the syntax error."

**supabase:** Remind user: "Check the RLS settings in your Supabase dashboard for the `<table>` table. Or re-run the migration." If table missing, guide to run `npx supabase db push`.

**build-memory:** Add `NODE_OPTIONS=--max-old-space-size=4096` to the build script in `package.json`. Confirm: "Raised the build memory limit."

**runtime-crash:** Add null-check guard at the identified call site. Confirm: "Added a null check."

**unknown:** Run `npm run build 2>&1 | tail -80` and show last 20 lines to user with: "I don't recognize this error. Here are the details:"

## Step 4 — Re-run build

After applying fix, run:
```bash
npm run build 2>&1 | tail -30
```

- If exit code 0: emit success message and go to Step 6.
- If still failing: increment attempt counter in `.taw/fix-session.json` and loop back to Step 2 with new error output.
- If attempt reaches 3 with no green build: go to Step 5.

## Step 5 — Revert fallback (attempt 3 failed)

1. Find last green git SHA: `git log --oneline | head -10` — show to user.
2. Emit: "Build still failing after 3 tries. Want to roll back to the last working version? (type: yes / no)"
3. On `yes`: run `git reset --hard <sha>` then `npm run build`.
4. On `no`: emit "OK, I'll stop here. Paste more of the error and I'll try again."
5. Update `.taw/checkpoint.json`: `{"status": "fix-failed", "last_error": "<error>"}`.

## Step 6 — Done

Emit:
```
Done! Build is green again.
Applied change: <1-line summary>
Want to deploy? Type: /taw-deploy
```

Update `.taw/checkpoint.json`: `{"status": "running", "last_fix": "<category>"}`.

## Constraints

- NEVER apply a destructive change (delete file, reset) without explicit user approval.
- NEVER log env var values; redact before writing to any file.
- Max 3 fix attempts total before offering revert.
- If `.taw/checkpoint.json` is absent, proceed with live build run (Step 1, branch 3).
