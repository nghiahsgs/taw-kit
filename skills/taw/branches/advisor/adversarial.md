# advisor: adversarial

Red-team the current branch's diff. Actively tries to BREAK the code — find security holes, race conditions, resource leaks, silent data corruption, hidden assumptions. Scope-gated: skip for tiny diffs, scale depth with size.

**Prereq:** router classified `tier1 = ADVISOR`, `tier2 = adversarial`.

**Philosophy:** `/taw review` does **defensive** checks (lint/type/test). This does **offensive** checks — "how would an attacker / chaos engineer break this?". Very different mindset.

## Step 0 — Scope gate (MANDATORY)

Count diff size:
```bash
BASE=${BASE:-origin/main}
DIFF_INS=$(git diff $BASE --stat | tail -1 | command grep -oE '[0-9]+ insertion' | command grep -oE '[0-9]+' || echo "0")
DIFF_DEL=$(git diff $BASE --stat | tail -1 | command grep -oE '[0-9]+ deletion' | command grep -oE '[0-9]+' || echo "0")
DIFF_TOTAL=$((DIFF_INS + DIFF_DEL))
```

Tier selection:
- `< 50` lines → **SKIP** entirely. Emit: "Diff quá nhỏ ({N} dòng) — không đáng adversarial. Xong." Stop.
- `50-199` → **MEDIUM tier** (1 pass)
- `200+` → **LARGE tier** (2 passes)

User can override: `/taw adversarial --full` always runs LARGE regardless of size.

## Step 1 — Gather diff

```bash
git diff $BASE --name-only
git diff $BASE
```

If no diff (or on base branch): "Không có thay đổi để attack. Xong."

## Step 2 — Attack vectors (MEDIUM tier, 1 pass)

Apply each vector. For each finding: `file:line` + evidence + why it breaks + fix direction.

### Vector 1: Trust boundary violations

- Unauthenticated route touching user data?
- Public POST without rate limit → spam/DoS?
- User-provided input flowing into SQL/HTML/shell without sanitize?
- Webhook route without signature verify → forged events?
- `SUPABASE_SERVICE_ROLE_KEY` touched from client or non-`'use server'` file?
- `NEXT_PUBLIC_*` variable holding a secret that shouldn't ship?

### Vector 2: Race conditions / concurrency

- 2 requests can arrive simultaneously — does order matter?
- Update-then-read without transaction → read stale value?
- `setState` based on prev state using direct assignment instead of callback?
- File write without atomic move → partial write visible?
- Concurrent form submission → duplicate DB rows?

### Vector 3: Silent data corruption

- `JSON.parse` without try/catch → crash on bad input?
- `parseInt` without radix → `0x...` becomes hex?
- `Date.parse` on user-provided string → NaN silently?
- `.split(' ')` on name → fails for single-name users?
- Currency math using float (should be bigint / decimal)?
- String concatenation building SQL / HTML?

### Vector 4: Resource exhaustion

- Unbounded loop / recursion on user input?
- `fetch` without timeout → hang indefinitely?
- DB query without LIMIT clause on user-filterable input?
- File upload without size cap?
- Regex with catastrophic backtracking (`(a+)+b`)?
- Memory leak from unremoved event listener / interval?

### Vector 5: Failure modes

- What happens when DB is down?
- What happens when external API returns 503?
- What happens when user closes tab mid-request?
- What happens on slow network (3G)?
- What happens when `window.localStorage` is disabled?
- What happens when user has `prefers-reduced-motion: reduce`?

### Vector 6: Hidden assumptions

- Code assumes `process.env.X` is always set — what if not?
- Code assumes array has ≥1 element — `items[0]` crash?
- Code assumes user.id exists — anonymous user edge?
- Code assumes locale is `vi` — English user breaks?
- Code assumes timezone — user in different TZ?
- Code assumes BigInt vs Number — 2^53 overflow?

### Vector 7: Supply chain / deps

- New dependency added in `package.json`? Check npm downloads + last release date.
- `.env.example` updated but no new env documented in README?
- Breaking change upstream — are we pinned to a safe version?

## Step 3 — LARGE tier additional pass

For 200+ line diffs, also run:

### Vector 8: Cross-file invariants

- Does changed code VIOLATE an invariant set elsewhere?
  - Example: middleware sets `user.role`, new code reads `user.roleId` — mismatch
  - Example: DB column is `nullable`, new code treats it as non-null
- Grep for shared types/interfaces touched — any caller not updated?

### Vector 9: Time-based failures

- Hardcoded year? (hits Y2038 or Jan 1 rollover)
- Timezone assumed UTC but server in local?
- Date math with `new Date()` without considering DST?

### Vector 10: Observability gaps

- Error caught and logged? (NOT swallowed silently)
- Logs contain PII / secrets? (should be scrubbed)
- Metric / Sentry breadcrumb added for new critical path?
- If prod fails on this code, how will we find out — Sentry, logs, user report?

## Step 4 — Classify findings

Each finding gets:

| Verdict | Meaning |
|---|---|
| 🚨 **CRITICAL** | Real exploit or silent-corrupt path. Must fix before merge. |
| ⚠️ **HIGH** | Very likely to hit in prod. Fix soon. |
| 💡 **MEDIUM** | Could happen under edge conditions. Consider fix. |
| 📝 **NOTE** | Style/observation, not a defect. |

**Rule:** if after attack analysis you have 0 CRITICAL and 0 HIGH findings, say so honestly. Don't manufacture severity to look thorough.

## Step 5 — Render report (VN)

```
## Adversarial Review: branch {branch}

**Diff**: {N} dòng · tier {MEDIUM|LARGE} · {M} vectors tested
**Verdict**: {BLOCK MERGE | CAUTION | SHIP IT}

---

### 🚨 CRITICAL ({count})

1. **Trust boundary** — `app/api/checkout/route.ts:12`
   ```ts
   const { amount } = await req.json()
   await stripe.paymentIntents.create({ amount, currency: 'vnd' })
   ```
   **Attack**: client có thể gửi `amount: -10000` → Stripe refund. Hoặc `amount: 1` cho order 1M VND.
   **Fix**: lấy amount từ server-side (tra cart/product từ DB), bỏ qua body.

(... lặp)

### ⚠️ HIGH ({count})

1. **Race condition** — `lib/inventory.ts:45` — 2 orders cùng lúc có thể trừ tồn 2 lần trong khi stock thực còn 1. Dùng SELECT FOR UPDATE hoặc atomic SQL.

### 💡 MEDIUM ({count})

1. **Failure mode** — `lib/email.ts:23` — Resend API timeout không catch → user thấy spinner mãi. Thêm 10s timeout + retry hoặc fallback message.

### 📝 NOTES ({count})

- `app/page.tsx:89` — `console.log` trong prod code
- Missing rate limit on `/api/contact`

---

### Verdict breakdown

- **BLOCK MERGE**: ≥1 CRITICAL
- **CAUTION**: 0 CRITICAL, ≥2 HIGH — cân nhắc fix trước deploy
- **SHIP IT**: 0 CRITICAL, 0-1 HIGH — OK ship, fix HIGH sau

### Next

{If BLOCK MERGE:}
  /taw fix — em xử lý CRITICAL theo thứ tự

{If CAUTION:}
  Fix HIGH hoặc gõ "deploy luon" nếu anh chấp nhận rủi ro

{If SHIP IT:}
  /taw deploy — sẵn sàng
```

## Step 6 — Cross-model second opinion (OPTIONAL, only if `codex` CLI available)

```bash
command -v codex >/dev/null 2>&1 && echo AVAILABLE || echo MISSING
```

If AVAILABLE and user added `--codex` flag: spawn codex in parallel with same diff + adversarial prompt. Present both outputs side-by-side under headers.

If MISSING: skip silently. Do not prompt user to install.

## Step 7 — Persist findings

Append to `.taw/adversarial-sessions.jsonl`:
```jsonl
{"ts":"{ISO}","branch":"{name}","diff_lines":{N},"critical":{C},"high":{H},"verdict":"{verdict}"}
```

For future pattern recognition — if same repo keeps producing CRITICAL in same area, surface it later.

## Constraints

- **BE ADVERSARIAL** — job is to find problems, not to praise
- **Evidence-first** — every CRITICAL has file:line + attack scenario + fix direction
- **No false positives** — if unsure something IS an attack, rank as MEDIUM or NOTE, not CRITICAL
- **Scope gate is mandatory** — don't waste tokens red-teaming 20-line diffs
- **Don't duplicate `/taw review`** — lint/type/test issues belong there, not here
- **No fluff verdicts** — "overall code is OK" is not a finding. Either list specifics or declare 0 findings cleanly.
- Budget: MEDIUM tier <2 min, LARGE tier <5 min
- Never auto-fix — this branch REPORTS, user decides + fixes manually or via `/taw fix`
