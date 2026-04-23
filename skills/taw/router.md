# Intent router — /taw single-entrypoint

You are inside `/taw`. This file maps free-form user prose (EN or VN) to exactly ONE branch. Load the matching branch file and follow it. If the user's intent is ambiguous, ask ONE short clarifying question instead of guessing.

## Tier 1 — 4 top-level intents

Pick exactly one. Keyword lists below are inclusive, not exhaustive — use judgement, but never invent a 5th tier-1 branch.

| Intent | Load | Signals (VN + EN) |
|---|---|---|
| `BUILD` | `@branches/build.md` | tạo, làm, lam, xây, xay, build, create, make, scaffold, "cho tôi một", "tao cho toi", "làm cho tui", new project, landing page, shop, blog, crm, dashboard, preset:, thêm tính năng, them tinh nang, add feature, extend with, "thêm trang", "thêm form" |
| `FIX` | `@branches/fix.md` | lỗi, loi, hỏng, hong, không chạy, khong chay, bể, be, vỡ, vo, sửa, sua, fix, broken, error, crash, doesn't work, build fail, website lỗi |
| `SHIP` | `@branches/ship.md` | deploy, đẩy lên, day len, publish, go live, live, vercel, docker, vps, lên mạng, len mang, production, prod |
| `MAINTAIN` | Tier-2 menu below | everything else: test, upgrade, clean, perf, rollback, refactor, types, seed, review, security, audit, swap, migrate |

## Tier 2 — sub-intents inside MAINTAIN

Only reached when Tier 1 resolved to `MAINTAIN`. Try keyword match first. If keyword hits exactly one row, load that branch directly. If ambiguous, show the menu below (Vietnamese if user wrote VN, else English) and wait for the user to pick A/B/C/... or type the keyword.

| Sub-intent | Load | Signals |
|---|---|---|
| `test` | `@branches/maintain/test.md` | test, kiểm thử, unit test, e2e, playwright, vitest, jest, "viết test", "gen test", "check test" |
| `upgrade` | `@branches/maintain/upgrade.md` | upgrade, nâng cấp, nang cap, bump, update deps, cập nhật, cap nhat, next 15, react 19, "phiên bản mới" |
| `clean` | `@branches/maintain/clean.md` | clean, dọn, don, unused, dead code, xoá rác, xoa rac, "dọn code", tidy, prune |
| `perf` | `@branches/maintain/perf.md` | perf, tốc độ, toc do, chậm, cham, slow, bundle, lighthouse, N+1, "tối ưu", toi uu, optimize |
| `rollback` | `@branches/maintain/rollback.md` | rollback, lùi, lui, undo, revert, "bản trước", ban truoc, "quay lại" |
| `refactor` | `@branches/maintain/refactor.md` | refactor, rename, đổi tên, doi ten, extract, tách file, tach file, split, "tách component" |
| `types` | `@branches/maintain/types.md` | types, type sync, supabase types, gen types, "đồng bộ type", api types |
| `seed` | `@branches/maintain/seed.md` | seed, data giả, data gia, fake data, dummy, sample data, "tạo data test" |
| `review` | `@branches/maintain/review.md` | review, pr review, "tự review", tu review, "kiểm tra trước khi push", lint+type+test |
| `security` | `@branches/maintain/security.md` | bảo mật, bao mat, security, audit, safe, an toàn, an toan, scan, vuln |
| `stack-swap` | `@branches/maintain/stack-swap.md` | swap, đổi stack, doi stack, thay, replace, "đổi supabase sang", migrate from X to Y |
| `status` | `@branches/maintain/status.md` | status, dashboard, "trạng thái", "tong quan", "xem tổng quan", health, "du an the nao", "project status", "check status" |

## Disambiguation — when keywords clash

Common overlaps and how to resolve:

- "sửa giùm" (fix/refactor) — prefer FIX if there's a current error; else ask: "Anh bị lỗi cụ thể hay muốn dọn/đổi tên code?"
- "thêm test" (build/test) — always → `maintain/test` (adding tests, not a product feature)
- "đẩy code lên github" → this is NOT SHIP (which means deploy). Ask: "Anh muốn deploy lên hosting hay chỉ push code lên git?" → if git-only, load `@branches/maintain/review.md` (git-pro skill flow)
- "tối ưu" (perf/clean) — prefer PERF if user mentions speed/size; CLEAN if they mention unused/dead
- "nâng cấp" (upgrade/stack-swap) — UPGRADE = bump versions of same deps; STACK-SWAP = replace one lib with another
- no match at all → ask: "Anh muốn em làm gì? Ví dụ: tạo mới / thêm tính năng / sửa lỗi / deploy / test / nâng cấp / dọn code."

## Empty args

If `/taw` is invoked with empty args, emit (VN default):

```
Anh muốn làm gì? Ví dụ:
  /taw làm cho tôi một shop bán cà phê
  /taw thêm trang liên hệ
  /taw website lỗi, fix giùm
  /taw deploy lên vercel
  /taw test cái login
  /taw nâng cấp next lên 15
```

Then wait for reply and re-run classification.

## Mode detection (applies to BUILD and MAINTAIN only)

Scan user text for YOLO triggers — same list as before:
- EN: `yolo`, `--yolo`, `--fast`, `auto`
- VN: `nhanh nha`, `nhanh đi`, `lam luon`, `làm luôn`, `khoi hoi`, `khỏi hỏi`, `không cần hỏi`, `chạy luôn`, `chay luon`
- Args literally starting with `yolo`

Any match → `mode = "yolo"` (branch will skip its clarify + approval gate where applicable). Else `mode = "safe"`.

FIX and SHIP branches ignore mode — FIX always asks before destructive reverts, SHIP always runs the security gate.

## What to write after routing

Record the routing decision in `.taw/intent.json`:
```json
{
  "tier1": "MAINTAIN",
  "tier2": "test",
  "raw": "<user text>",
  "mode": "safe",
  "branch_loaded": "branches/maintain/test.md"
}
```

Then stop executing this file and follow the loaded branch from its Step 1.
