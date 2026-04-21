---
# taw-kit Skills Catalog (v0.1)

25 skills bundled with taw-kit — 5 user-facing `/taw*` commands and 20 internal
skills invoked automatically by the orchestrator. Non-dev users only ever type
`/taw`, `/taw-fix`, `/taw-deploy`, `/taw-add`, or `/taw-new`.

## Skills Table

| Skill | Purpose | Invoked by |
|-------|---------|------------|
| `taw` | Main orchestrator — converts natural-language prose to a full-stack product | User directly |
| `taw-fix` | Auto-diagnose and fix broken builds | User directly |
| `taw-deploy` | One-command deploy to Vercel, Docker, or VPS | User directly |
| `taw-add` | Add a feature to an existing taw-kit project | User directly |
| `taw-new` | Scaffold from preset (landing-page, shop-online, crm, blog, dashboard) | User directly |
| `docs-seeker` | Fetch official docs (Next.js, Supabase, Polar, shadcn) | researcher agent |
| `sequential-thinking` | Step-by-step structured reasoning with revision capability | planner, debug |
| `mermaidjs-v11` | Generate Mermaid v11 diagrams in plan files and docs | planner agent |
| `supabase-setup` | Create tables, run migrations, configure RLS policies | fullstack-dev, taw |
| `shadcn-ui` | Install and use shadcn/ui components (Button, Card, Form, Table) | fullstack-dev |
| `nextjs-app-router` | App Router file conventions, Server/Client Components, API routes | fullstack-dev |
| `ui-ux-pro-max` | Design intelligence: 50 styles, 21 palettes, 50 font pairs, UX rules, stack guides | planner, fullstack-dev, reviewer |
| `vietnamese-copy` | Vietnamese marketing copy, CTAs, email templates (on demand) | taw, taw-add |
| `tiktok-shop-embed` | Embed TikTok Shop product cards and affiliate links | fullstack-dev, taw-add |
| `seo-basic` | Meta tags, Open Graph, sitemap.xml, robots.txt, JSON-LD | fullstack-dev, taw |
| `form-builder` | Contact/lead/booking forms with zod validation → Supabase | fullstack-dev, taw-add |
| `auth-magic-link` | Supabase passwordless email auth + middleware route protection | fullstack-dev, taw |
| `env-manager` | Generate .env.local, .env.example, validate required keys | taw, taw-deploy |
| `git-auto-commit` | Stage files + conventional commit message, security pre-check | taw, taw-add, taw-fix |
| `preview-tunnel` | Run dev server + localtunnel for shareable preview URL | taw, taw-new |
| `error-to-vi` | Translate build/runtime errors to plain language (EN default; VN on demand) | taw-fix, taw-deploy |
| `approval-plan` | Render a 3-5 bullet plan and wait for user confirmation | taw, taw-add, taw-fix |
| `payment-integration` | Polar checkout + webhook + VietQR bank transfer fallback | fullstack-dev, taw |
| `debug` | Read stack trace, grep files, hypothesize root cause, propose fix | taw-fix |
| `terse-internal` | Caveman-style terse output for agent-internal work (cuts ~60-70% tokens). Never activates for user-facing VN text | planner, researcher, fullstack-dev, tester, reviewer, debug |
