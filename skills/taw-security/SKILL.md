---
name: taw-security
description: >
  On-demand security audit for taw-kit projects. Stack-aware checks for Next.js
  App Router + Supabase + Polar: secrets leak, RLS gaps, service-role key in
  client bundle, missing webhook signature verification, unprotected API
  routes, weak headers, dependency vulns. Outputs a Vietnamese P0/P1/P2 report
  with file:line + fix hints. User-visible strings match the user's input
  language (Vietnamese by default for VN users).
  Trigger phrases (EN + VN): "check security", "audit it", "security scan",
  "is this safe to launch", "kiem tra bao mat", "quet bao mat", "audit du an",
  "co an toan khong", "scan bao mat truoc khi deploy".
argument-hint: "[full | quick | path/to/file] (mặc định: full / default: full)"
allowed-tools: Read, Bash, Grep, Glob, Edit, Write
---

# taw-security — Stack-Aware Security Audit

You are the taw-security skill. Run a focused security audit on the current taw-kit project and return a Vietnamese report the non-dev owner can act on.

**Language rule (MUST follow):** Detect the language of the user's input. If they wrote Vietnamese (or VN-style mixed text like "kiem tra bao mat"), reply 100% in Vietnamese — friendly, conversational, Southern style. If English, reply in English. Default to Vietnamese for ambiguous/short input. Applies to ALL user-visible text: progress lines, the report, fix prompts. File paths, code snippets, and shell commands stay verbatim (English).

**Difference from `reviewer` agent:** `reviewer` runs automatically inside `/taw` step 5 as a fast 2-minute deploy gate (5 P0 checks only). This skill is a **deeper on-demand audit** the user invokes when they want full coverage, before launch, after a feature add, or whenever they ask "an toàn chưa?".

## Step 0 — Verify project context

1. Confirm `package.json` exists. If not, emit "Folder này không phải dự án Next.js. Thoát." and stop.
2. Detect deps: read `package.json`. Note which of these are present: `@supabase/supabase-js`, `@supabase/ssr`, `@polar-sh/sdk`, `next-auth`, `zod`. Skip checks for missing categories.
3. If args = `quick`, run only P0 checks (≤30 seconds). If args = a path, scope checks to that file/folder. Default `full` = P0+P1+P2 across whole repo.

## Step 1 — Run checks

Run checks below in order. For each finding, capture: `priority` (P0/P1/P2), `category`, `file:line`, `evidence` (1-line code snippet), `vi_hint` (Vietnamese fix suggestion).

### P0 — Chặn deploy / blocks deploy

| ID | Check | Detection |
|----|-------|-----------|
| P0-1 | Hardcoded secrets in tracked files | `git grep -nE 'sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9]{30,}|gho_[A-Za-z0-9]{30,}|-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----|service_role.*ey[A-Za-z0-9._-]{40,}'` excluding `node_modules`, `.next`, `*.lock` |
| P0-2 | `.env*` files committed | `git ls-files \| grep -E '^\.env(\.|$)' \| grep -v '\.env\.example$'` — anything returned is P0 |
| P0-3 | `.env*` not in `.gitignore` (except `.env.example`) | Read `.gitignore`, check for `.env` or `.env*` or `.env.local` patterns |
| P0-4 | `SUPABASE_SERVICE_ROLE_KEY` reachable from client | `grep -rn 'SUPABASE_SERVICE_ROLE_KEY' app/ components/ lib/` — flag any file that does NOT have `'use server'` directive at top OR is not inside `app/api/` |
| P0-5 | `NEXT_PUBLIC_*` env var holding a secret-looking value | `grep -rnE 'NEXT_PUBLIC_[A-Z_]+_(KEY\|SECRET\|TOKEN)' .env*` — `NEXT_PUBLIC_` is bundled to client; any *_SECRET or *_KEY (other than known-safe like SUPABASE_ANON_KEY, STRIPE_PUBLISHABLE_KEY) is a leak |
| P0-6 | Supabase tables without RLS | If `supabase/migrations/` exists: grep for `CREATE TABLE` and verify a matching `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` exists. List any table missing RLS. |
| P0-7 | Polar/Stripe/SePay webhook without signature verification | Find `app/api/webhooks/**/route.ts` files. For each: check the file body contains one of `verifyWebhook`, `constructEvent`, `verify(`, or HMAC comparison. If absent → P0. |
| P0-8 | SQL injection via raw concat in Supabase RPC | `grep -rnE 'rpc\(\s*[`"]\$\{' app/ lib/` — template literals inside `.rpc()` with user input |

### P1 — Cảnh báo / warnings (không chặn)

| ID | Check | Detection |
|----|-------|-----------|
| P1-1 | API route without auth check | For each `app/api/**/route.ts` (excluding `webhooks/`, `auth/`, `public/`): grep for `getUser()`, `getSession()`, or `auth()`. Absence → P1. |
| P1-2 | API route without input validation | Same files: check for `zod`, `parse(`, or `.safeParse(`. Absence on POST/PUT/PATCH handlers → P1. |
| P1-3 | Missing security headers | Read `next.config.js` / `next.config.mjs`. Look for `headers()` returning `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`, `Content-Security-Policy`. Missing all four → P1. |
| P1-4 | `dangerouslySetInnerHTML` with non-static input | `grep -rn 'dangerouslySetInnerHTML' app/ components/` — flag if the value is a variable/prop, not a static string literal. |
| P1-5 | npm audit high/critical | Run `npm audit --json --audit-level=high 2>/dev/null \| head -200`. Count findings with `severity: high` or `critical`. |
| P1-6 | Cookies set without `httpOnly` or `secure` | `grep -rnE 'cookies\(\)\.set\|setCookie' app/ lib/` — flag if set call lacks `httpOnly: true` or `secure: true` |
| P1-7 | No rate limit on public POST | If a public POST route (no auth check) exists AND no rate-limit lib (`@upstash/ratelimit`, `express-rate-limit`, `next-rate-limit`) in deps → P1 generic warning. |

### P2 — Gợi ý / suggestions (optional hardening)

| ID | Check | Detection |
|----|-------|-----------|
| P2-1 | No CSRF token on form POST | If forms POST to same-origin and no `csrf` middleware. Inform-only. |
| P2-2 | Password input without min length | `grep -rn 'type="password"' app/ components/` — check matching `minLength` attribute. |
| P2-3 | Missing 2FA option for admin | Inform-only if `app/admin/` exists. |
| P2-4 | No `Permissions-Policy` header | Soft suggestion if P1-3 already triggered. |

## Step 2 — Render report (Vietnamese by default)

Output format:

```
## Báo cáo bảo mật — taw-security

**Phán quyết:** [✅ AN TOÀN | ⚠️ CẢNH BÁO | 🚨 CHẶN DEPLOY]
**Tổng quát:** {N0} P0 · {N1} P1 · {N2} P2 · quét {X} file trong {Y}s

---

### 🚨 P0 — Phải sửa ngay (chặn deploy)
1. **{category}** — `{file}:{line}`
   ```
   {evidence_snippet}
   ```
   👉 {vi_hint}

(... lặp lại cho từng P0)

### ⚠️ P1 — Nên sửa sớm
1. **{category}** — `{file}:{line}` — {vi_hint}
(...)

### 💡 P2 — Cải thiện thêm (không bắt buộc)
- Tóm tắt N P2 — gõ "xem chi tiết P2" để hiện full

---

**Bước tiếp theo:**
- Sửa tự động: gõ `fix tu dong` (chỉ áp dụng cho P0 đơn giản: thêm .gitignore, ENABLE RLS)
- Sửa tay: mở từng file:line trong báo cáo
- Bỏ qua P1/P2 và deploy: gõ `deploy luon`
- Hỏi thêm: "P0-4 nghĩa là gì?", "tại sao webhook cần verify?"
```

If 0 findings:
```
✅ AN TOÀN — không có vấn đề bảo mật phát hiện.
Đã quét {X} file trong {Y}s. Sẵn sàng deploy.
```

## Step 3 — Optional auto-fix (only on user request)

If user types `fix tu dong` / `auto fix`, apply ONLY these fixes (everything else stays manual):

| Issue | Auto-fix |
|-------|---------|
| P0-3 (`.env` not gitignored) | Append `.env*\n!.env.example\n` to `.gitignore` |
| P0-6 (RLS missing) | Generate `supabase/migrations/{ts}_enable_rls.sql` with `ALTER TABLE x ENABLE ROW LEVEL SECURITY;` for each missing table — DO NOT add policies (user must define), only enable RLS so default-deny is active |
| P1-3 (no security headers) | Add `headers()` block to `next.config.js` with the 4 standard headers |

For everything else, emit: "Vấn đề này cần sửa tay. Mở `{file}:{line}` rồi {1-line specific guidance}."

After auto-fix runs, re-scan only the affected files and report new state.

## Step 4 — Deploy gate integration (informational)

If user says they want to deploy after audit:
- 0 P0 → "Sẵn sàng. Gõ `/taw-deploy` để publish."
- ≥1 P0 → "Còn {N} lỗi P0. Sửa hết rồi mới deploy được. Gõ `fix tu dong` hoặc sửa tay."

## Output style

- Open with one-line verdict (verdict + counts).
- Use the report template above verbatim.
- File paths and code snippets ALWAYS in original (English).
- Prose around them in Vietnamese (or English if user wrote English).
- Never fabricate findings — if a check can't run (missing tool, missing file), say so explicitly.
- Never flag P0/P1/P2 without evidence (file:line + snippet).

## Constraints

- Static analysis only. Do NOT run the app or hit Supabase/Polar APIs during audit.
- Do NOT auto-modify code without explicit `fix tu dong` confirmation from user.
- Skip `node_modules/`, `.next/`, `dist/`, `build/`, `*.lock`, `.git/` in all greps.
- If the project is huge (>500 source files), do P0 first and ask user before continuing P1/P2.
- Audit must complete in <60s for `quick` mode, <3min for `full`. Otherwise summarize what was checked vs skipped.
- This skill REPORTS — it never deploys, never commits, never pushes.
