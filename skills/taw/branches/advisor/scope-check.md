# advisor: scope-check

Compare branch diff against stated intent (`.taw/intent.json`, PR description, commit messages). Detects **scope creep** (built more than asked) and **missing requirements** (built less than asked). Informational — does not block.

**Prereq:** router classified `tier1 = ADVISOR`, `tier2 = scope-check`.

**Philosophy:** dev often "while I was in there..." — changes balloon, reviews get hard. Kit's job is to surface the gap between intent and reality in 30 seconds, so user decides consciously.

## Step 1 — Gather intent (what was SUPPOSED to be built)

Check all sources:

```bash
# 1. taw intent (if project was built/extended via /taw)
cat .taw/intent.json 2>/dev/null

# 2. Recent feature entries
node -e "const i=require('./.taw/intent.json'); console.log(JSON.stringify(i.features?.slice(-3)||[],null,2))" 2>/dev/null

# 3. PR description (if PR exists)
gh pr view --json body --jq .body 2>/dev/null

# 4. Commit messages for unpushed commits
git log origin/main..HEAD --pretty=format:'%s%n%b' 2>/dev/null

# 5. TODOS.md / plan.md in repo root
cat TODOS.md 2>/dev/null; cat plan.md 2>/dev/null
```

Combine sources into a **stated intent** — 1-3 bullets of what was supposed to happen.

If NO sources found:
```
Không có intent rõ ràng (không có PR, không có .taw/intent.json, không có commit mô tả).
Em không check được scope — cần ít nhất 1 trong: PR mô tả, commit message có body, hoặc file TODOS.md.
```
Stop.

## Step 2 — Gather delivery (what ACTUALLY changed)

```bash
BASE=${BASE:-origin/main}
git diff $BASE --stat
git diff $BASE --name-only
git log $BASE..HEAD --pretty=format:'%h %s'
```

Classify files touched by area:
- `app/api/**` → API routes
- `app/**/page.tsx` → pages
- `components/**` → UI components  
- `lib/**` → business logic
- `supabase/migrations/**` → DB schema
- `*.test.*` / `*.spec.*` → tests
- `package.json` → deps
- `*.md` → docs
- `.github/**` → CI

## Step 3 — Map intent → delivery

For each stated intent bullet, check if diff contains evidence of that work:

```
INTENT: "add Stripe checkout to /products/:id"
DELIVERY: touched app/api/checkout/route.ts, lib/stripe.ts, components/CheckoutButton.tsx
VERDICT: ✓ matches
```

```
INTENT: "fix magic-link expired token bug"
DELIVERY: touched app/api/auth/callback, components/LoginForm.tsx, lib/email.ts (!!), package.json (!!)
VERDICT: ⚠ scope creep — why email.ts + package.json?
```

For each delivered area, check if it's justified by some intent bullet:

```
DELIVERED: components/Navbar.tsx
INTENT CHECK: no bullet mentions navbar
VERDICT: ⚠ scope creep
```

## Step 4 — Detect specific patterns

### Scope creep — "while I was in there"

Flag these patterns in diff WITHOUT matching intent:
- New deps in `package.json` (unless intent mentions dep)
- Config file changes (`next.config.js`, `tsconfig.json`) (unless explicitly asked)
- Rename/reformat of files untouched by the feature
- New UI components outside the feature area
- "Fix typo" / "reformat" commits bundled with feature work

### Missing requirements

Flag intent items NOT visible in delivery:
- "add test for X" in intent, no `*.test.*` file touched
- "update docs" in intent, no `*.md` touched
- "handle error case Y" in intent, no try/catch or guard added
- "migrate to Z" in intent, still using old approach in diff

### Ambiguous (needs user confirm)

- Intent says "improve onboarding" — too vague to verify, ask:
  > Intent "improve onboarding" quá mơ hồ. Cụ thể là: shortening flow, thêm tooltips, hay fix bug? Em không check được nếu không biết.

## Step 5 — Render report (VN)

```
## Scope check: branch {branch}

**Intent** (từ {sources}):
  - {bullet 1}
  - {bullet 2}

**Delivered** (diff {N} files, {M} lines):
  - {area 1}: {files touched}
  - {area 2}: {files touched}

---

### ✓ Matching ({count})
  1. Intent "{X}" ↔ delivery: app/api/checkout, lib/stripe — hợp lý

### ⚠ Scope creep ({count}) — xây thêm không yêu cầu
  1. `components/Navbar.tsx` rewrite — không có intent nào đề cập
     → Nếu refactor cần, nên tách commit/PR riêng
  2. `package.json` thêm `lodash` — intent không cần
     → Có thật sự cần? Project đã có date-fns.

### ⚠ Missing ({count}) — intent có nhưng diff không thấy
  1. Intent "add Playwright test cho checkout flow" — không có file `*.spec.*` mới
     → Gõ `/taw test` để gen trước khi merge
  2. Intent "update README với env vars mới" — README không thay đổi
     → 1 commit docs là đủ

### 📝 Notes
  - 3 commits có message "fix typo" bundled với feature work → split commit sẽ clean hơn

---

### Verdict
{CLEAN | DRIFT | MISSING_REQS | BOTH}

### Next action
{1 concrete thing user should do}
```

Verdicts:
- **CLEAN** — 0 creep, 0 missing → "PR scope sạch. Ship được."
- **DRIFT** — creep only → "Anh xây thêm {N} thứ ngoài scope. OK nếu anh chấp nhận PR lớn hơn dự kiến."
- **MISSING_REQS** — missing only → "Còn {N} requirement chưa làm. Làm nốt hay giảm scope intent?"
- **BOTH** — "Vừa thiếu requirement, vừa có creep. Re-scope PR trước khi merge."

## Step 6 — Suggest split (when creep is large)

If scope creep touches >3 unrelated areas, suggest split:

```
💡 Em đề xuất split PR:
  PR A (feature chính):  app/api/checkout, lib/stripe, components/CheckoutButton
  PR B (navbar rewrite): components/Navbar.tsx  — 1 PR riêng
  PR C (deps + typos):   package.json + typo fixes  — gộp vào chore PR

Lý do: reviewer sẽ review nhanh hơn, rollback an toàn hơn.

Gõ `/taw review` cho workflow split branches, hoặc `ignore` để giữ PR này nguyên.
```

## Constraints

- **Informational only** — never block the user
- **No fabricated intent** — if no sources found, stop cleanly, don't guess
- **Don't flag cosmetic changes alone** — whitespace fix bundled w/ feature is fine if small
- **Budget**: <30 seconds — scope check should be the fast pre-check before deeper reviews
- **Intent can be multi-source** — combine `.taw/intent.json` + PR body + TODOS.md, not just one
- Ambiguous intent ("improve UX") → ask for clarification, don't pretend to verify
- Git-managed files only — `.gitignore`d changes don't count either way
- Don't critique the quality of delivered code (that's `/taw analyze`) — only scope fit
