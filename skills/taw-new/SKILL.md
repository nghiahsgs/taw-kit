---
name: taw-new
description: >
  Scaffold a new taw-kit project from a named preset. Presets cover common
  Vietnamese business types: shop-online, dat-lich, landing-page, blog, saas-vn.
  Trigger phrases: "tao du an moi", "bat dau du an moi", "tao website moi",
  "scaffold moi", "new project", "tao tu preset".
argument-hint: "<ten-preset> [ten-du-an]"
---

# taw-new — Scaffold from Preset

## Purpose

Instantly scaffold a production-ready Next.js project from a named preset tailored
to common Vietnamese business types. Faster than `/taw` for known patterns — no
orchestration overhead, just clone-and-configure.

## Trigger Phrases (VN + EN)

Vietnamese: "tao du an moi", "bat dau website moi", "tao tu mau", "scaffold"
English: "/taw-new", "new project from preset", "start from template"

## Invocation Pattern

```
/taw-new shop-online
/taw-new dat-lich tiem-nail-my-phuong
/taw-new landing-page khoa-hoc-excel
/taw-new saas-vn quan-ly-kho
/taw-new blog am-thuc-sai-gon
```

## Available Presets

| Preset | Vietnamese use case | Includes |
|--------|---------------------|----------|
| `shop-online` | Ban hang truc tuyen | Product listing, cart, Polar + MoMo checkout |
| `dat-lich` | Dat lich dich vu | Booking form, calendar, Zalo notification |
| `landing-page` | Thu thap khach hang | Hero, CTA, email capture, SEO meta |
| `blog` | Viet bai chia se | MDX posts, tag filter, RSS, sitemap |
| `saas-vn` | Phan mem tra phi | Auth, dashboard, Polar subscription, usage limits |

## What This Skill Does

1. Validates the preset name against the table above; asks user to pick if invalid.
2. Copies the preset template from `presets/<preset-name>/` into a new project dir.
3. Runs `env-manager` to generate `.env.local` and `.env.example` from preset config.
4. Runs `npm install` and `npm run build` to verify scaffold is clean.
5. Initialises a git repo with an initial commit via `git-auto-commit`.
6. Shows user the project directory, live preview URL via `preview-tunnel`.
7. Prompts: "Ban muon them gi? Dung /taw-add de them tinh nang moi."

## Post-Scaffold Next Steps

- Customise copy and branding with `vietnamese-copy` skill.
- Set up Supabase tables with `supabase-setup` skill.
- Deploy with `/taw-deploy` when ready.

> Implementation: see phase-04
