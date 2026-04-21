# Phase 05 — Preset Library

## Context Links
- Phase 04 (`/taw-new` consumer)
- Research: `research/researcher-02-vn-market-260421-0224.md` §1 (personas A/B/C use cases), §4 #7

## Overview
- **Priority:** P2
- **Status:** pending
- **Effort:** ~6h (≈1.2h per preset)
- **Description:** Ship 5 curated presets that match Persona A/B/C's top-5 use cases. Each preset = a *prompt* (not a static template) — the orchestrator builds fresh every time.

## Key Insights
- Static templates rot; AI-generated outputs stay current. So each preset is a rich prompt + clarifying-Q set, NOT pre-written code.
- Presets derived from research-02 personas: TikTok Shop seller → `shop-online` / `landing-page`; freelancer → `blog` / `dashboard`; consultant → `crm`.
- Each preset must include: VN prose intent, 3 default clarify Qs, recommended stack overrides (if any), success screenshot description.

## Requirements
**Functional**
- 5 preset files: `landing-page.md`, `shop-online.md`, `crm.md`, `blog.md`, `dashboard.md`.
- Each preset loadable by `/taw-new <name>` (phase 04).
- Each preset states 3–5 bullet VN "what you'll get" for buyer-facing docs.

**Non-functional**
- Each preset file ≤ 80 lines.
- No code snippets inline — only instructions for orchestrator.

## Architecture

**Preset file schema (YAML frontmatter + body):**
```
---
name: shop-online
intent_vi: "Cửa hàng online bán sản phẩm vật lý với giỏ hàng và thanh toán"
stack_overrides:
  payment: polar
  db: supabase
  extras: [product-gallery, cart, checkout]
clarify_questions_vi:
  - "Bao nhiêu sản phẩm? (1-10, 10-100, nhiều hơn)"
  - "Thanh toán: Polar, MoMo, hay cả hai?"
  - "Cần quản trị viên để thêm sản phẩm không?"
what_you_get_vi:
  - "Trang chủ + trang sản phẩm"
  - "Giỏ hàng + thanh toán"
  - "Dashboard admin (nếu chọn)"
---

# shop-online

Brief description, example use cases (TikTok shop seller, Shopee cross-list).
```

**Load flow:**
```
/taw-new shop-online
  → read presets/shop-online.md
  → inject intent_vi + stack_overrides into /taw context
  → skip /taw step 1 (classification), go to step 2 with preset clarify_questions_vi
```

## Related Code Files
**Create:**
- `presets/landing-page.md` — single page + CTA + MoMo/Polar checkout link
- `presets/shop-online.md` — multi-product + cart + checkout
- `presets/crm.md` — lead capture form + Supabase table + admin view
- `presets/blog.md` — MDX posts + tag filter + RSS
- `presets/dashboard.md` — charts + Supabase data + auth-gated access

**Modify:** `skills/taw-new/SKILL.md` — add preset enum validation (references these 5 names).

**Delete:** none.

## Implementation Steps
1. Draft preset schema (finalize YAML keys above); write as comment header in each file.
2. Write `landing-page.md` — simplest, use as template for others.
3. Write `shop-online.md` — targets Persona A (TikTok Shop seller). Include TikTok Shop embed option.
4. Write `crm.md` — targets Persona C (consultant). Include lead capture + export to Sheets option.
5. Write `blog.md` — targets Persona B (creator). Include SEO + newsletter signup.
6. Write `dashboard.md` — targets Persona C (client deliverable). Include auth gate + chart library choice.
7. For each: write `what_you_get_vi` bullets for marketing page (phase 10).
8. Update `/taw-new` skill's preset-name enum.
9. Dogfood: run `/taw-new <each>` in a throwaway dir; verify orchestrator builds correct shape.
10. Commit: `feat(presets): 5 curated starting points`.

## Todo List
- [ ] Finalize preset YAML schema (comment header)
- [ ] Write `presets/landing-page.md`
- [ ] Write `presets/shop-online.md`
- [ ] Write `presets/crm.md`
- [ ] Write `presets/blog.md`
- [ ] Write `presets/dashboard.md`
- [ ] Update `skills/taw-new/SKILL.md` with enum
- [ ] Dogfood all 5 presets
- [ ] Commit

## Success Criteria
- `/taw-new landing-page` in clean dir produces Next.js page with hero + CTA + checkout CTA in <10 min.
- All 5 presets complete at least to `npm run build` green without manual intervention.
- Each preset file ≤ 80 lines.
- `grep -c "^---$" presets/*.md` returns `2` for every file (valid frontmatter).

## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Preset outputs drift from real user needs | Medium | Medium | Review personas quarterly; update YAML only (not code) |
| `/taw-new dashboard` too broad, orchestrator struggles | Medium | Medium | Clarify_questions narrow the scope before building |
| TikTok Shop embed API changes | High | Low | Wrap in `tiktok-shop-embed` skill (phase 02) — update in one place |
| Preset stack_overrides conflict with user overrides | Low | Low | User overrides win; document precedence in `skills/taw-new/SKILL.md` |

## Security Considerations
- Presets never hardcode API keys or URLs.
- `dashboard.md` auth gate must use Supabase magic link (no plaintext passwords).
- `crm.md` lead data → Supabase table with RLS enabled by default.

## Next Steps
- Phase 09 writes marketing copy using `what_you_get_vi` from each preset.
- Post-launch: add 5 more presets based on user requests.
