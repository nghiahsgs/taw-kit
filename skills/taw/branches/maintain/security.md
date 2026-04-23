# maintain: security

Stack-aware security audit. Non-destructive — reports P0/P1/P2 with file:line + VN fix hints. Also invoked by `@branches/ship.md` as a blocking gate (quick mode, P0 only).

**Prereq:** router classified `tier2 = security`, OR called internally by SHIP.

## Step 0 — Verify project

1. `package.json` exists? No → "Folder này không phải Next.js. Thoát." Stop.
2. Detect deps: `@supabase/supabase-js`, `@supabase/ssr`, `@polar-sh/sdk`, `next-auth`, `zod`. Skip checks for missing categories.
3. Args: `quick` → P0 only (≤30s). Path arg → scope to file/folder. Default `full` = P0+P1+P2 whole repo.

## Step 1 — Run checks

For each finding, capture: `priority`, `category`, `file:line`, `evidence` (1-line snippet), `vi_hint`.

### P0 — chặn deploy

| ID | Check | Detection |
|---|---|---|
| P0-1 | Hardcoded secrets | `git grep -nE 'sk-[A-Za-z0-9_-]{20,}\|ghp_[A-Za-z0-9]{30,}\|gho_[A-Za-z0-9]{30,}\|-----BEGIN (RSA \|EC \|OPENSSH )?PRIVATE KEY-----\|service_role.*ey[A-Za-z0-9._-]{40,}'` excluding `node_modules`, `.next`, `*.lock` |
| P0-2 | `.env*` committed | `git ls-files \| command grep -E '^\.env(\.\|$)' \| command grep -v '\.env\.example$'` — `command grep` bypasses Claude Code's `grep`→`ugrep` wrapper that has non-POSIX exit codes |
| P0-3 | `.env*` not in `.gitignore` | Read `.gitignore`, check `.env`/`.env*`/`.env.local` |
| P0-4 | `SUPABASE_SERVICE_ROLE_KEY` reachable from client | `grep -rn 'SUPABASE_SERVICE_ROLE_KEY' app/ components/ lib/` — flag any file lacking `'use server'` or not under `app/api/` |
| P0-5 | `NEXT_PUBLIC_*` holding secret-looking value | `grep -rnE 'NEXT_PUBLIC_[A-Z_]+_(KEY\|SECRET\|TOKEN)' .env*` — anything NEXT_PUBLIC with _SECRET/_KEY (except known-safe ANON_KEY, PUBLISHABLE_KEY) is a leak |
| P0-6 | Supabase tables without RLS | If `supabase/migrations/` exists: grep `CREATE TABLE` vs matching `ENABLE ROW LEVEL SECURITY` |
| P0-7 | Webhook without signature verify | Find `app/api/webhooks/**/route.ts`. Each file must contain one of `verifyWebhook`, `constructEvent`, `verify(`, HMAC compare. Absent → P0 |
| P0-8 | SQL injection via raw concat | `grep -rnE 'rpc\(\s*[\`"]\$\{' app/ lib/` |

### P1 — cảnh báo

| ID | Check | Detection |
|---|---|---|
| P1-1 | API route without auth | For each `app/api/**/route.ts` (exclude `webhooks/`, `auth/`, `public/`): grep for `getUser`, `getSession`, `auth(`. Absent → P1 |
| P1-2 | API route without validation | Same files: grep for `zod`, `parse(`, `.safeParse(`. Absent on POST/PUT/PATCH → P1 |
| P1-3 | Missing security headers | Read `next.config.{js,mjs}`. `headers()` must return `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`, `Content-Security-Policy`. All 4 missing → P1 |
| P1-4 | `dangerouslySetInnerHTML` with non-static | `grep -rn 'dangerouslySetInnerHTML' app/ components/` — flag if value is variable/prop |
| P1-5 | npm audit high/critical | `npm audit --json --audit-level=high 2>/dev/null | head -200`. Count `severity: high\|critical` |
| P1-6 | Cookies without httpOnly/secure | `grep -rnE 'cookies\(\)\.set\|setCookie' app/ lib/` — flag if lacks `httpOnly: true` or `secure: true` |
| P1-7 | No rate limit on public POST | Public POST exists + no `@upstash/ratelimit`/`express-rate-limit`/`next-rate-limit` in deps → P1 |

### P2 — gợi ý

| ID | Check |
|---|---|
| P2-1 | No CSRF token on form POST (inform only) |
| P2-2 | Password input without minLength (grep `type="password"` vs `minLength`) |
| P2-3 | Missing 2FA for admin (inform-only if `app/admin/` exists) |
| P2-4 | No `Permissions-Policy` header (soft suggestion if P1-3 triggered) |

## Step 2 — Render report (VN default)

```
## Báo cáo bảo mật — taw audit

**Phán quyết:** [✅ AN TOÀN | ⚠️ CẢNH BÁO | 🚨 CHẶN DEPLOY]
**Tổng quát:** {N0} P0 · {N1} P1 · {N2} P2 · quét {X} file trong {Y}s

---

### 🚨 P0 — Phải sửa ngay (chặn deploy)
1. **{category}** — `{file}:{line}`
   ```
   {evidence}
   ```
   👉 {vi_hint}

### ⚠️ P1 — Nên sửa sớm
1. **{category}** — `{file}:{line}` — {vi_hint}

### 💡 P2 — Cải thiện thêm
- Tóm tắt N P2 — gõ "xem chi tiết P2" để hiện đủ

---

**Bước tiếp theo:**
- Sửa tự động: gõ `fix tu dong` (chỉ P0 đơn giản: .gitignore, ENABLE RLS)
- Sửa tay: mở từng file:line
- Bỏ qua P1/P2 và deploy: gõ `deploy luon`
- Hỏi thêm: "P0-4 nghĩa là gì?"
```

If 0 findings:
```
✅ AN TOÀN — không phát hiện vấn đề.
Đã quét {X} file trong {Y}s. Sẵn sàng deploy.
```

## Step 3 — Optional auto-fix

Only on `fix tu dong` / `auto fix`. Apply ONLY these, everything else manual:

| Issue | Auto-fix |
|---|---|
| P0-3 (.env not gitignored) | Append `.env*\n!.env.example\n` to `.gitignore` |
| P0-6 (RLS missing) | Gen `supabase/migrations/{ts}_enable_rls.sql` with `ALTER TABLE x ENABLE ROW LEVEL SECURITY;` for each missing table — NO policies (user defines) |
| P1-3 (no security headers) | Add `headers()` block to `next.config.js` with 4 standard headers |

Anything else: "Vấn đề này cần sửa tay. Mở `{file}:{line}` rồi {hint}."

After auto-fix, re-scan affected files and report new state.

## Step 4 — Deploy gate integration (informational)

If user asks to deploy after audit:
- 0 P0 → "Sẵn sàng. Gõ `/taw deploy` để publish."
- ≥1 P0 → "Còn {N} P0. Sửa hết rồi mới deploy được. Gõ `fix tu dong` hoặc sửa tay."

## Constraints

- Static analysis only. No runtime, no external API hits during audit.
- No auto-modify without explicit `fix tu dong`.
- Skip `node_modules/`, `.next/`, `dist/`, `build/`, `*.lock`, `.git/`.
- Huge projects (>500 source files): P0 first, ask before P1/P2.
- Budget: quick <60s, full <3min. Otherwise summarize what was checked vs skipped.
- Reports only — never deploys/commits/pushes.
- File paths + code snippets verbatim (English). Prose in VN (or EN if user wrote EN).
- Never fabricate findings — missing tool/file → say so.
