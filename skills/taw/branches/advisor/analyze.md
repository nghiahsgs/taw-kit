# advisor: analyze

Deep-read 1 feature/folder/file and produce an **opinionated** review: code quality, architecture smells, security gaps, UX flaws. Read-only — never modifies code. Output is a written opinion, not a task.

**Prereq:** router classified `tier1 = ADVISOR`, `tier2 = analyze`.

**Philosophy:** unlike `/taw review` (lint/type/test — objective), `analyze` gives **subjective expert opinion**. Direct, evidence-based, no hedging. Dev wants honesty, not politeness.

## Step 0 — Ground rules (CRITICAL — follow strictly)

**Anti-sycophancy rules** — NEVER say during analysis:
- ❌ "That's an interesting approach" → take a position
- ❌ "You might want to consider..." → say "This is wrong because..." OR "This works because..."
- ❌ "Could work" → say WILL work or WON'T work + evidence
- ❌ "I can see why you'd think that" → if wrong, say wrong and why
- ❌ "Overall the code looks good" — vague praise has zero information

**Always do:**
- Take a position on every finding. State position AND what evidence would change it.
- Name specific `file:line` for every claim.
- Challenge the strongest version of the code's intent, not a strawman.
- Finish with ONE concrete next step, not a menu.

## Step 1 — Identify target

Parse user args:

| Pattern | Target |
|---|---|
| `/taw analyze auth` | Feature by name — grep `app/`, `lib/`, `components/` for matching folder/file |
| `/taw analyze app/checkout` | Path — read everything under |
| `/taw analyze components/Cart.tsx` | Single file + its imports |
| `/taw analyze architecture` | Whole-project structural review |
| empty | Ask: "Phân tích phần nào? Feature name hoặc path." |

Resolve path:
```bash
# feature name → folder
find app/ lib/ components/ -type d -name "*<arg>*" 2>/dev/null | head -5
find app/ lib/ components/ -type f -name "*<arg>*.ts*" 2>/dev/null | head -10
```

If multiple matches → ask user to pick. Never analyze speculatively.

## Step 2 — Stack detection (detection-first)

Before reading code, map stack from `package.json`:
```
Framework:  Next.js 14 App Router
Auth:       @supabase/supabase-js (SSR)
UI:         shadcn/ui + @radix-ui/*
State:      @tanstack/react-query
Types:      TypeScript strict mode
```

Analysis lens must match the stack. Don't critique Next 14 code using Next 13 rules.

## Step 3 — Read target fully

Read every `.ts` / `.tsx` file in the target:
```bash
find <target-path> -type f \( -name '*.ts' -o -name '*.tsx' \) | head -20
```

Also read:
- Direct parent folder (context)
- Files importing the target (blast radius)
- Related test files (coverage signal)
- Migrations if target touches DB (`supabase/migrations/`)

## Step 4 — 5-dimension analysis

Apply each dimension. For each, either PASS or SPECIFIC FINDING with file:line.

### Dimension 1 — Correctness

- Does it handle null/undefined inputs?
- Are error paths actually handled or silently swallowed?
- Do conditionals cover ALL branches or leak edge cases?
- Is async/await composed correctly (no orphan promises, no unhandled rejections)?
- Is there any off-by-one, fence-post, or comparison-operator confusion?

### Dimension 2 — Security (for this feature's scope)

- Input validation at trust boundaries (API routes, form handlers)?
- Auth check on server operations (`getUser()` before DB write)?
- SQL/NoSQL injection via template literals in `.rpc()` or raw queries?
- `NEXT_PUBLIC_*` or `'use client'` files exposing secrets?
- Missing webhook signature verify?
- XSS via `dangerouslySetInnerHTML` with non-static input?

### Dimension 3 — Architecture

- Does this feature own its concerns, or is logic scattered?
- Abstractions premature (wrapping 1 caller) or appropriate (wrapping 3+)?
- Coupling with unrelated modules (importing from too far)?
- RSC vs Client Component boundary correct? `'use client'` only where needed?
- Server Action vs Route Handler — right tool for the job?

### Dimension 4 — Code quality

- Naming: do identifiers describe intent or implementation?
- Cyclomatic complexity: any function >50 lines or 4+ nested conditionals?
- DRY violations: same pattern 3+ times uncopied?
- Dead code / commented-out code left behind?
- Magic numbers/strings not named?
- TypeScript `any` leaks?

### Dimension 5 — UX (if feature has UI)

- Loading state on every async action?
- Error state visible to user (not just thrown)?
- Empty state designed (0 items, first-use)?
- Success feedback (toast, redirect, optimistic update)?
- Form: validation messages inline + a11y labels?
- Mobile touch targets ≥44×44px?
- VN text: accent correctness, no Google-Translate feel?

## Step 5 — Prioritize findings

Classify every finding:

| Priority | Meaning | Action |
|---|---|---|
| 🚨 **P0** | Bug / security / broken behaviour | Fix NOW |
| ⚠️ **P1** | Architecture smell / UX gap / future bug risk | Fix before scaling |
| 💡 **P2** | Style / naming / consistency | Nice to have |

P0 findings MUST have: file:line, evidence (1-line code), fix direction (1 sentence).

## Step 6 — Render report (VN default)

```
## Phân tích: {target}

**Scope**: {N} file · {M} dòng · stack {detected}
**Thời gian đọc**: {secs}s

---

### 🚨 P0 — Phải sửa ngay ({count})

1. **{dimension}** — `app/checkout/page.tsx:47`
   ```tsx
   const user = await supabase.auth.getUser()
   await db.from('orders').insert({ user_id: user.id, ... })
   ```
   👉 Nếu `getUser()` return null (session hết hạn), insert vẫn chạy với `user_id: undefined` — data rác vào DB. Thêm guard: `if (!user) return NextResponse.json({error:'unauthorized'}, {status:401})`.

(... lặp cho mỗi P0)

### ⚠️ P1 — Nên sửa trước khi scale ({count})

1. **{dimension}** — `lib/cart.ts:23` — calcTotal() 78 dòng, 5 nested if. Tách thành calcSubtotal + applyDiscount + addShipping.

### 💡 P2 — Style / consistency ({count})

- 3 chỗ dùng `any` type (file danh sách)
- Naming: `fn1`, `helper2` → không describe intent

---

### Kết luận 1 dòng

"{Tên feature} có xương sống đúng nhưng {1-2 P0 nghiêm trọng} — sửa trước khi deploy lần tiếp."

### Bước tiếp theo

**Ưu tiên fix P0 #1** (`app/checkout/page.tsx:47`) — lỗi silent này sẽ ghi data rác vào DB production. Gõ `/taw fix` để em xử lý, hoặc sửa tay 3 dòng.
```

### If nothing critical found:

```
## Phân tích: {target}

✓ Không tìm thấy P0.
⚠ 2 P1 (architecture smell), 4 P2 (style)

**Kết luận**: code OK, có thể deploy. Các P1 nên fix khi rảnh — không khẩn cấp.
```

## Step 7 — Don't offer, commit to ONE recommendation

NEVER end with "anh muốn em fix cái nào?". Instead commit:

```
Em đề xuất: sửa P0 #1 + P0 #2 trước khi làm gì khác.
Gõ /taw fix để em xử lý, hoặc /taw analyze tiếp phần khác.
```

## Constraints

- Read-only — NEVER edit / install / run destructive commands
- Max 3-4 P0 per report — if >4, flag "feature này cần refactor" instead of listing 20 bugs
- Evidence MANDATORY — no finding without file:line + snippet
- Stack-aware — if project uses Drizzle, don't critique Supabase patterns
- Don't flag patterns that are stylistic preferences (tabs vs spaces, `function` vs `const`)
- Budget: ≤2 min for features <10 files, ≤5 min for whole-project architecture review
- If target folder is empty or not found: emit "Không thấy `{target}`. Gõ `ls` folder nào có."
- If analyzing your own generated code (built by `/taw build` recently): apply SAME rigor — don't grade on curve
