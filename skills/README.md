---
# taw-kit Skills Catalog (v0.1)

25 skills bundled with taw-kit — 5 user-facing `/taw*` commands and 20 internal
skills invoked automatically by the orchestrator. Non-dev users only ever type
`/taw`, `/taw-fix`, `/taw-deploy`, `/taw-add`, or `/taw-new`.

## Skills Table

| Skill | Purpose | Invoked by |
|-------|---------|------------|
| `taw` | Main orchestrator — converts VN prose to full-stack product | User directly |
| `taw-fix` | Auto-diagnose and fix broken builds in Vietnamese | User directly |
| `taw-deploy` | One-command Vercel deploy via Shipkit MCP | User directly |
| `taw-add` | Add a feature to an existing taw-kit project | User directly |
| `taw-new` | Scaffold from preset (shop-online, dat-lich, landing-page, blog, saas-vn) | User directly |
| `docs-seeker` | Fetch official docs via context7 (Next.js, Supabase, Polar, shadcn) | researcher agent |
| `sequential-thinking` | Step-by-step structured reasoning with revision capability | planner, debug |
| `mermaidjs-v11` | Generate Mermaid v11 diagrams in plan files and docs | planner agent |
| `supabase-setup` | Create tables, run migrations, configure RLS policies | fullstack-dev, taw |
| `shadcn-ui` | Install and use shadcn/ui components (Button, Card, Form, Table) | fullstack-dev |
| `nextjs-app-router` | App Router file conventions, Server/Client Components, API routes | fullstack-dev |
| `tailwind-design` | Tailwind patterns for hero, grid, nav, card, CTA, dark mode | fullstack-dev |
| `shipkit-deploy` | Shipkit MCP command sequence: ensure-key, deploy, poll-status | taw-deploy |
| `vietnamese-copy` | Vietnamese marketing copy, CTAs, error messages, email templates | taw, taw-add |
| `tiktok-shop-embed` | Embed TikTok Shop product cards and affiliate links | fullstack-dev, taw-add |
| `seo-basic` | Meta tags, Open Graph, sitemap.xml, robots.txt, JSON-LD | fullstack-dev, taw |
| `form-builder` | Contact/lead/booking forms with zod validation → Supabase | fullstack-dev, taw-add |
| `auth-magic-link` | Supabase passwordless email auth + middleware route protection | fullstack-dev, taw |
| `env-manager` | Generate .env.local, .env.example, validate required keys | taw, taw-deploy |
| `git-auto-commit` | Stage files + conventional commit message, security pre-check | taw, taw-add, taw-fix |
| `preview-tunnel` | Run dev server + localtunnel for shareable preview URL | taw, taw-new |
| `error-to-vi` | Translate build/runtime/Supabase errors to Vietnamese with fix hints | taw-fix, taw-deploy |
| `approval-plan` | Render 3-5 bullet plan in Vietnamese, wait for user confirmation | taw, taw-add, taw-fix |
| `payment-integration` | Polar checkout + webhook + VietQR bank transfer for VN market | fullstack-dev, taw |
| `debug` | Read stack trace, grep files, hypothesize root cause, propose fix | taw-fix |
