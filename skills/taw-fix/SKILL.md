---
name: taw-fix
description: >
  Diagnose and auto-fix broken builds or runtime errors in taw-kit projects.
  Reads .taw/checkpoint.json for last error, runs build, parses output, applies
  fix, re-runs build. Retries up to 3 times total. All user messages in Vietnamese.
  Trigger phrases: "loi roi", "bi loi", "khong chay duoc", "fix giup toi",
  "website bi hong", "co loi xuat hien", "build fail", "sua loi giup toi".
argument-hint: "[paste error] | auto"
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# taw-fix — Diagnose & Auto-Fix

You are the taw-fix skill. When invoked, diagnose and fix the broken project.
All strings shown to the user MUST be Vietnamese. Internal reasoning is English.

## Step 1 — Locate the error

Check sources in order:
1. If user pasted an error message in the invocation args, use that directly.
2. Else read `.taw/checkpoint.json`; extract `last_error` field.
3. If both are empty, run `npm run build 2>&1 | tail -60` and capture output.
4. If still no error found, emit: "Tôi không thấy lỗi nào. Bạn thử chạy lại thử xem, hoặc dán thông báo lỗi vào đây."

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

**missing-dep:** Extract package name from error. Run `npm install <package>`. Confirm with: "Đã cài gói còn thiếu."

**type-error:** Grep for the flagged file + line. Read that section. Apply minimal type annotation or null-check. Confirm with: "Đã sửa lỗi kiểu dữ liệu."

**env-missing:** Check `.env.local`. If key is missing, prompt: "Bạn cần thêm khóa `<KEY>` vào file `.env.local`. Giá trị lấy từ đâu?" — wait for reply, then write the key.

**port-busy:** Run `lsof -ti tcp:3000 | xargs kill -9 2>/dev/null`. Confirm: "Đã giải phóng cổng 3000."

**syntax-error:** Grep for the flagged file. Read ±10 lines around the error line. Apply the fix (close bracket, fix quote, etc.). Confirm: "Đã sửa lỗi cú pháp."

**supabase:** Remind user: "Kiểm tra cài đặt RLS trong Supabase dashboard cho bảng `<table>`. Hoặc chạy lại migration." If table missing, guide to run `npx supabase db push`.

**build-memory:** Add `NODE_OPTIONS=--max-old-space-size=4096` to the build script in `package.json`. Confirm: "Đã tăng giới hạn bộ nhớ build."

**runtime-crash:** Add null-check guard at the identified call site. Confirm: "Đã thêm kiểm tra null."

**unknown:** Run `npm run build 2>&1 | tail -80` and show last 20 lines to user with: "Tôi chưa nhận ra lỗi này. Đây là chi tiết:"

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
2. Emit: "Build vẫn lỗi sau 3 lần thử. Muốn quay lại phiên bản hoạt động trước không? (gõ: yes / không)"
3. On `yes`: run `git reset --hard <sha>` then `npm run build`.
4. On `không`: emit "OK, để tôi dừng ở đây. Bạn dán thêm lỗi vào thì tôi thử tiếp."
5. Update `.taw/checkpoint.json`: `{"status": "fix-failed", "last_error": "<error>"}`.

## Step 6 — Done

Emit:
```
Xong! Build đã xanh trở lại.
Thay đổi đã áp dụng: <1-line summary in VN>
Bạn muốn deploy không? Gõ: /taw-deploy
```

Update `.taw/checkpoint.json`: `{"status": "running", "last_fix": "<category>"}`.

## Constraints

- NEVER apply a destructive change (delete file, reset) without explicit user approval.
- NEVER log env var values; redact before writing to any file.
- Max 3 fix attempts total before offering revert.
- If `.taw/checkpoint.json` is absent, proceed with live build run (Step 1, branch 3).
