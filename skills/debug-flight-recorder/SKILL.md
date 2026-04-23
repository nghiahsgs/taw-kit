---
name: debug-flight-recorder
description: >
  Add contextual logging to the exact call sites a bug passes through, run the
  repro, collect the logs, then REMOVE the logs. Saves dev 20 min of manually
  adding/removing console.log statements. Uses a marker comment so cleanup is
  safe and fully reversible even if something fails mid-run.
  Trigger phrases (EN + VN): "debug with logs", "add console logs", "flight recorder",
  "bug khong tai hien", "khong biet loi o dau", "add log de debug",
  "trace bug", "dung console log debug".
allowed-tools: Read, Write, Edit, Bash, Grep
---

# debug-flight-recorder — Instrument, Repro, Collect, Revert

## Step 0 — Preflight

```bash
# clean working tree required — we'll add logs then remove them
git status --porcelain
```

If dirty → "Anh đang có thay đổi chưa commit. Stash hoặc commit trước rồi mới debug nha (để em revert log sau mà không đụng code anh đang viết)."

Capture snapshot SHA:
```bash
git rev-parse HEAD > .taw/debug-sha.txt
```

## Step 1 — Understand the bug

Ask the user:
```
Mô tả bug (ngắn thôi):
  1. Steps to reproduce (cách tái hiện)?
  2. What should happen (đáng lẽ gì xảy ra)?
  3. What actually happens (thực tế gì xảy ra)?
  4. Có error message không? (paste vào cũng được)
```

Store in `.taw/debug-session.json`:
```json
{
  "bug": "<short>",
  "repro_steps": "<list>",
  "expected": "...",
  "actual": "...",
  "error": "<if any>",
  "started_at": "<ISO>",
  "state": "planning"
}
```

## Step 2 — Identify instrument points

From the user's description, grep for relevant files:

```bash
# by keyword from bug description
git grep -n --files-with-matches 'checkout' app/ lib/ components/ 2>/dev/null
# by error message (if any)
git grep -n --files-with-matches '<error snippet>' 2>/dev/null
```

Pick 3-8 strategic points (never more — cognitive load):
- Entry: route handler or form submit
- Key branching: `if` that decides success vs error
- External calls: `fetch(`, `await supabase`, `stripe.`
- State mutations: `setState(`, `dispatch(`
- Right before/after the line that crashes

Present candidates to user:
```
Em sẽ thêm log ở 5 chỗ nghi ngờ:
  1. app/checkout/page.tsx:34     — form submit handler
  2. app/api/checkout/route.ts:12 — entry route handler
  3. lib/cart.ts:56               — calcTotal
  4. lib/stripe.ts:23             — session create
  5. lib/supabase.ts:89           — save order

Gõ:
  y        → thêm log và chạy repro
  skip 3   → bỏ chỗ số 3
  add <path>:<line> → thêm chỗ khác
  cancel   → huỷ
```

## Step 3 — Instrument (marker-based)

Every log uses this exact marker so cleanup is safe:

```ts
// [TAW-DEBUG-FR] marker — removed automatically by debug-flight-recorder
```

For each point, insert ONE log line with rich context. Pattern by site type:

### Function entry
```ts
export function calcTotal(items: Item[]) {
  console.log('[TAW-DEBUG-FR] lib/cart.ts:calcTotal entry', { items_count: items.length, items_sample: items.slice(0,2) }); // [TAW-DEBUG-FR] marker
  // ... existing body
}
```

### Before external call
```ts
console.log('[TAW-DEBUG-FR] app/api/checkout/route.ts:pre-supabase', { user_id: user?.id, cart: body }); // [TAW-DEBUG-FR] marker
const { data, error } = await supabase.from('orders').insert(body);
console.log('[TAW-DEBUG-FR] app/api/checkout/route.ts:post-supabase', { data, error }); // [TAW-DEBUG-FR] marker
```

### Inside conditional
```ts
if (session.status === 'complete') {
  console.log('[TAW-DEBUG-FR] route:branch=complete', { session_id: session.id }); // [TAW-DEBUG-FR] marker
  // ...
} else {
  console.log('[TAW-DEBUG-FR] route:branch=incomplete', { status: session.status, reason: session.last_error }); // [TAW-DEBUG-FR] marker
  // ...
}
```

### Before throw / return
```ts
console.log('[TAW-DEBUG-FR] pre-throw', { err, ctx }); // [TAW-DEBUG-FR] marker
throw err;
```

### Scrub sensitive values
**Never log**: passwords, full tokens, credit card, session secrets. Truncate: `token?.slice(0,8) + '...'`.

Track touched files in `.taw/debug-files.txt`:
```
app/checkout/page.tsx
app/api/checkout/route.ts
lib/cart.ts
lib/stripe.ts
```

Update session state:
```json
{"state": "instrumented", "points": 5}
```

## Step 4 — Run repro

```bash
# detect dev server
pgrep -f 'next dev' >/dev/null && echo "dev server running" || echo "start dev server: npm run dev"
```

Emit (VN):
```
Đã thêm log vào 5 chỗ. Giờ:
  1. Mở terminal khác, chạy `npm run dev` nếu chưa
  2. Tái hiện bug (theo steps anh mô tả)
  3. Copy output console trong terminal dev server + browser console (nếu có)
  4. Paste vào đây, hoặc gõ `dev-log` để em tail dev.log

Xong gõ: `done`
```

Option: if user has `npm run dev` piped to `dev.log`:
```bash
tail -f dev.log | command grep '\[TAW-DEBUG-FR\]' &
```

## Step 5 — Analyze logs

User pastes log output (or points to file). Parse:

1. Group by site ID (`[TAW-DEBUG-FR] <file>:<marker>`)
2. Build timeline: which sites fired, in what order
3. Compare to expected flow (from Step 1 user description)

Render (VN):
```
Phân tích logs:

Timeline:
  1. ✓ app/checkout/page.tsx:submit      (13:42:01)
  2. ✓ app/api/checkout/route.ts:entry   (13:42:01)
  3. ✓ lib/cart.ts:calcTotal entry        (13:42:01) — items_count: 3
  4. ✓ route:pre-supabase                 (13:42:02)
  5. ✗ route:post-supabase                 — không thấy log này
  6. ✗ route:branch=complete              — không vào nhánh success

Kết luận nghi vấn:
  Supabase insert không return → có thể hang, timeout, hoặc throw.
  Kiểm tra:
    - RLS policy có cho user insert không?
    - Supabase URL + anon key đúng không?
    - Network tab browser có thấy request 401/500 không?
```

## Step 6 — Propose fix

Based on timeline, emit specific next step:
- Last site that fired + didn't reach next → root cause lives between them
- Propose: re-run with MORE logs at suspected point, OR apply fix directly

If user wants to fix now, hand off to `@branches/fix.md` with the diagnostic in context.

## Step 7 — Cleanup (ALWAYS runs, even on error)

```bash
# find all files with the marker
command grep -rl '\[TAW-DEBUG-FR\]' app/ components/ lib/ 2>/dev/null > .taw/debug-mark-files.txt

# remove every line containing the marker
while read f; do
  # preserve original
  cp "$f" "$f.bak"
  # strip lines containing the marker
  command grep -v '\[TAW-DEBUG-FR\]' "$f.bak" > "$f"
  rm "$f.bak"
done < .taw/debug-mark-files.txt
```

Verify clean:
```bash
command grep -rn '\[TAW-DEBUG-FR\]' . 2>/dev/null | command grep -v '.taw/'
# should be empty
```

If any remain → emit paths + ask user to manually confirm cleanup before committing.

Run `npm run build` to confirm cleanup didn't break anything:
```bash
npm run build 2>&1 | tail -5
```

If build broke (rare — usually syntax from a misplaced comma): revert:
```bash
git reset --hard $(cat .taw/debug-sha.txt)
```

## Step 8 — Summary + done

```
Debug session xong.

Điểm nghi vấn: <file:line> — <reason>
Gợi ý sửa: <1 sentence>

Cleanup:
  ✓ Xoá 5 log marker
  ✓ Build vẫn xanh
  ✓ Working tree sạch như trước

Gõ:
  /taw fix     → em fix chỗ tìm ra luôn
  thoat        → để anh tự sửa
```

Clean up:
```bash
rm -f .taw/debug-session.json .taw/debug-sha.txt .taw/debug-files.txt .taw/debug-mark-files.txt
```

## Gotchas

- **Marker collision** — cực hiếm nhưng nếu user đã có `TAW-DEBUG-FR` trong code (why?) → refuse, ask to rename
- **Minified builds** — logs go to server console (for route handlers) or browser console (for client components). Make sure user knows where to look
- **Async race conditions** — order of log lines may not match code order for Promise.all / concurrent awaits. Use timestamps
- **Logging inside loops** — adds thousands of lines. Sample: `if (i < 3 || i % 100 === 0) console.log(...)`
- **Sensitive data leaked into logs** — always truncate tokens, hash emails, never full passwords. If bug IS about auth, extra careful

## Constraints

- NEVER leave marker comments in committed code — Step 7 cleanup is MANDATORY
- Max 8 instrument points per session — more = cognitive overload, worse signal
- Require clean working tree at start — revert path must stay safe
- Never log: passwords, full tokens (>8 chars), CC, session secrets, PII
- Cleanup MUST run even if user Ctrl-C — write cleanup as `trap` or always-final step
- If build breaks after cleanup (rare) → hard reset to snapshot SHA
- All logs use `console.log('[TAW-DEBUG-FR] ...')` format — non-negotiable (cleanup depends on it)
