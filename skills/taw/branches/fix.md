# branch: FIX

Routed here when user reports a broken build, runtime error, or just says "it's broken / loi roi". Diagnose and auto-fix. Up to 3 attempts, then offer revert.

**Prereq:** router classified `tier1 = FIX`.

## Step 1 — Locate the error

Check in order:
1. If user pasted an error in args → use directly
2. Else read `.taw/checkpoint.json` → extract `last_error`
3. If both empty → run `npm run build 2>&1 | tail -60` and capture
4. Still nothing → "Em không thấy lỗi nào. Thử chạy lại, hoặc dán lỗi vào đây."

Write raw error to `.taw/fix-session.json`:
```json
{"error_raw":"<text>","attempt":1,"status":"diagnosing"}
```

## Step 2 — Classify the error

Assign exactly ONE category:

| Category | Signals |
|---|---|
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

**missing-dep:** Extract package name. `npm install <pkg>`. → "Đã cài package thiếu."

**type-error:** Grep flagged file+line. Read ±10 lines. Apply minimal type annotation or null-check. → "Đã fix type error."

**env-missing:** Check `.env.local`. If key missing, ask: "Cần key `<KEY>` trong `.env.local`. Lấy value ở đâu?" Wait, then write.

**port-busy:** `lsof -ti tcp:3000 | xargs kill -9 2>/dev/null`. → "Đã giải phóng port 3000."

**syntax-error:** Grep flagged file. Read ±10 lines. Apply fix. → "Đã fix syntax error."

**supabase:** "Check RLS settings in Supabase dashboard cho bảng `<table>`. Hoặc chạy lại migration." If table missing → guide to `npx supabase db push`.

**build-memory:** Add `NODE_OPTIONS=--max-old-space-size=4096` to `package.json` build script. → "Đã tăng memory limit."

**runtime-crash:** Add null-check at identified call site. → "Đã thêm null check."

**unknown:** `npm run build 2>&1 | tail -80`, show last 20 lines: "Em không nhận ra lỗi này. Chi tiết:"

## Step 4 — Re-run build

```bash
npm run build 2>&1 | tail -30
```

- Exit 0 → Step 6
- Fail → increment attempt in `.taw/fix-session.json`, loop back to Step 2 with new error
- Attempt reaches 3 with no green build → Step 5

## Step 5 — Revert fallback (attempt 3 failed)

1. `git log --oneline | head -10` — show to user
2. "Fix 3 lần không được. Lùi lại bản hoạt động gần nhất? (yes / no)"
3. `yes` → `git reset --hard <sha>` + `npm run build`
4. `no` → "OK em dừng. Dán thêm lỗi em thử tiếp."
5. Update `.taw/checkpoint.json`: `{"status":"fix-failed","last_error":"<error>"}`

## Step 6 — Done

```
taw-kit: xong! Build xanh lại rồi.
  Đã sửa: <1-line summary>
  Số lần thử: <N>/3

Gõ "deploy" để đẩy lên, hoặc tiếp tục làm việc.
```

Update `.taw/checkpoint.json`: `{"status":"running","last_fix":"<category>"}`.

## Constraints

- NEVER destructive changes (delete file, reset) without explicit user approval.
- NEVER log env values; redact before any write.
- Max 3 fix attempts before offering revert.
- When showing raw error, pair with Vietnamese hint via `error-to-vi` skill.
