---
# taw-kit Skills Catalog (v0.1)

27 skills bundled with taw-kit — 5 user-facing `/taw*` commands and 22 internal
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
| `frontend-design` | Anti-AI-slop design (Anthropic, Apache 2.0): bold aesthetics, distinctive typography, refined visual POV | planner, fullstack-dev, reviewer |
| `expo-tailwind-setup` | Tailwind v4 + NativeWind v5 setup for Expo (mobile equivalent of `shadcn-ui` styling) (Expo, MIT) | fullstack-dev (mobile) |
| `expo-deployment` | EAS Build + Submit to App Store / Play Store (mobile equivalent of `taw-deploy`) (Expo, MIT) | fullstack-dev (mobile) |
| `expo-dev-client` | Custom Expo Go for native modules (Expo, MIT) | fullstack-dev (mobile) |
| `building-native-ui` | Expo Router + native UI patterns (mobile equivalent of `nextjs-app-router`) (Expo, MIT) | fullstack-dev (mobile) |
| `taw-rn-supabase` | Supabase JS in React Native: AsyncStorage session, deep-link magic-link auth, Realtime | fullstack-dev (mobile) |
| `vietnamese-copy` | Vietnamese marketing copy, CTAs, email templates (on demand) | taw, taw-add |
| `tiktok-shop-embed` | Embed TikTok Shop product cards and affiliate links | fullstack-dev, taw-add |
| `seo-basic` | Meta tags, Open Graph, sitemap.xml, robots.txt, JSON-LD | fullstack-dev, taw |
| `form-builder` | Contact/lead/booking forms with zod validation → Supabase | fullstack-dev, taw-add |
| `auth-magic-link` | Supabase passwordless email auth + middleware route protection | fullstack-dev, taw |
| `env-manager` | Generate .env.local, .env.example, validate required keys | taw, taw-deploy |
| `taw-commit` | Stage files + `type(scope): subject [P<n>]` commit with phase tracing, security pre-check | taw, taw-add, taw-fix |
| `taw-trace` | Look up commit history by scope, phase, file, or feature — read-only | taw-fix, taw-deploy, user directly |
| `taw-git` | Branch creation, PR via `gh`, fast-forward merge, safe undo/revert | user directly |
| `preview-tunnel` | Run dev server + localtunnel for shareable preview URL | taw, taw-new |
| `error-to-vi` | Translate build/runtime errors to plain language (EN default; VN on demand) | taw-fix, taw-deploy |
| `approval-plan` | Render a 3-5 bullet plan and wait for user confirmation | taw, taw-add, taw-fix |
| `payment-integration` | Polar checkout + webhook + VietQR bank transfer fallback | fullstack-dev, taw |
| `debug` | Read stack trace, grep files, hypothesize root cause, propose fix | taw-fix |
| `terse-internal` | Caveman-style terse output for agent-internal work (cuts ~60-70% tokens). Never activates for user-facing VN text | planner, researcher, fullstack-dev, tester, reviewer, debug |
