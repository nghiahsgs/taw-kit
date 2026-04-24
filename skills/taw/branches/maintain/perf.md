# maintain: perf

Performance audit — bundle size, Lighthouse score, slow DB queries. Report-first, suggest fixes, apply on approval.

**Prereq:** router classified `tier2 = perf`.

## Step 1 — Scope

Ask (if not given):
```
Check gì?
  1. bundle    — kích thước JS gửi xuống trình duyệt
  2. lighthouse — điểm Performance + Accessibility + SEO
  3. database  — N+1 queries trong code Supabase
  4. runtime   — slow function (cần app đang chạy)
  5. tất cả    — cả 4 (mất ~3 phút)
```

## Step 2 — Bundle analysis

```bash
npm run build
```

Parse `.next/analyze/` if exists, else:
```bash
npx @next/bundle-analyzer || \
  (echo "ANALYZE=true" && ANALYZE=true npm run build)
```

If `@next/bundle-analyzer` missing, add to `next.config.js` temporarily:
```js
const withBundleAnalyzer = require('@next/bundle-analyzer')({ enabled: process.env.ANALYZE === 'true' })
module.exports = withBundleAnalyzer({ /* existing config */ })
```

Extract top offenders (VN):
```
Bundle size report:
  Total First Load JS: 487 KB (⚠️ khuyến nghị <200 KB)

Top 5 package nặng nhất:
  1. moment.js         72 KB  → đổi sang date-fns tiết kiệm 60 KB
  2. lodash            54 KB  → import lẻ từng hàm ('lodash/debounce')
  3. recharts          48 KB  → xài chart nhẹ hơn (uPlot, visx) nếu chỉ line chart
  4. @supabase/...     38 KB  → OK, cần thiết
  5. ...

Trang nặng nhất:
  /dashboard    → 312 KB (có thể lazy-load chart)
  /admin        → 289 KB
```

## Step 3 — Lighthouse

Requires app running. Start dev server if not already:
```bash
# in bg, wait 3s for boot
(npm run start > /dev/null 2>&1 &)
sleep 3
```

Run:
```bash
npx lighthouse http://localhost:3000 \
  --only-categories=performance,accessibility,seo,best-practices \
  --output=json --output-path=.taw/lighthouse.json \
  --chrome-flags="--headless"
```

Parse top issues from report. Render (VN):
```
Lighthouse (localhost:3000):
  Performance:   67  ⚠️
  Accessibility: 91  ✓
  Best Practices: 83
  SEO:           95  ✓

Vấn đề chính:
  • LCP (Largest Contentful Paint): 4.2s — chậm (mục tiêu <2.5s)
    → Ảnh hero không dùng next/image
  • Total Blocking Time: 890ms — cao
    → JS bundle quá lớn (xem Bundle report)
  • Không có meta description trên / và /about
```

## Step 4 — N+1 query detection (Supabase)

```bash
grep -rn 'await supabase' app/ components/ lib/ 2>/dev/null | \
  awk -F: '{print $1}' | sort | uniq -c | awk '$1 > 3 {print}'
```

For each file with >3 supabase calls, read ±20 lines around each call. Look for patterns:
- `await supabase.from(X).select(...)` inside a `.map()` or `for` loop → N+1
- Sequential awaits that could be `Promise.all`

Render (VN):
```
Phát hiện N+1 tiềm năng:
  1. app/orders/page.tsx:34
     → Trong .map() có await supabase.from('users')
     → Sửa: dùng JOIN trong select — .select('*, user:users(*)')
  2. lib/cart.ts:56
     → 3 queries liên tiếp không có Promise.all
     → Sửa: await Promise.all([q1, q2, q3])
```

## Step 5 — Runtime (optional, skip if no app running)

If Lighthouse already running the app, also capture:
```bash
# profile 10s of dev traffic via chrome-devtools-frontend (manual)
```

For now, emit: "Runtime profiling cần user click qua app — skip trừ khi anh có kịch bản cụ thể."

## Step 6 — Ask which fixes to apply

```
Fix gì?
  1. tất cả gợi ý auto (bundle + images + headers)
  2. chỉ bundle (đổi moment → date-fns, lazy-load chart)
  3. chỉ N+1 queries (sửa .map + Promise.all)
  4. chỉ report — em tự sửa sau
```

## Step 7 — Apply on approval

For auto fixes, spawn `fullstack-dev`:
```
Task: Apply these perf fixes:
  - Replace moment with date-fns (keep same formatting)
  - Convert static <img> to next/image with width/height
  - Change sequential awaits in {file:line} to Promise.all
  - Convert lodash default import to named imports
Rules: One commit per category. Run `npm run build` after each. Roll back on fail.
```

## Step 8 — Verify + report

```bash
npm run build
```

Re-run bundle analyze, diff sizes:
```
✓ Bundle giảm: 487 KB → 321 KB (-34%)
✓ Không còn N+1 trong 2 file
(lighthouse cần chạy lại trên prod deploy để so chính xác)
```

`taw-commit` per category: `type=perf, scope=<area>, subject="..."`

## Constraints

- NEVER change the visual behaviour of a page during perf fix
- If fix fails build, revert immediately — perf is nice-to-have, never break the app
- Skip Lighthouse if no HTTP server available (e.g. Electron-only or RN app)
- Don't auto-install big tools (`lighthouse`, `bundle-analyzer`) permanently — use `npx` for one-shot
- Keep report under 80 lines — if many issues, show top 5 + "gõ 'full' để xem hết"
