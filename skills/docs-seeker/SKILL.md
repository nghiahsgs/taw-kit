---
name: docs-seeker
description: >
  Search framework and library documentation via context7 (llms.txt standard).
  Use for Next.js, Supabase, Tailwind, shadcn/ui, Polar API reference lookups.
  Activated internally by researcher and fullstack-dev agents.
argument-hint: "[library-name] [topic]"
---

# docs-seeker — Documentation Discovery

## Overview

Fetches authoritative documentation for libraries used in taw-kit projects.
Uses context7.com llms.txt standard for zero-hallucination API references.

## When to Activate

- Looking up a specific API method (e.g. `supabase.auth.signInWithOtp`)
- Checking component props for shadcn/ui Button, Form, Table
- Verifying Next.js App Router file conventions (`layout.tsx`, `page.tsx`, `route.ts`)
- Confirming Polar checkout session parameters
- Any "how do I use X in Y" question about the taw-kit stack

## Primary Workflow

```bash
# 1. Detect query type
node scripts/detect-topic.js "<user query>"

# 2. Fetch documentation
node scripts/fetch-docs.js "<user query>"

# 3. Analyze if multiple URLs returned
cat llms.txt | node scripts/analyze-llms-txt.js -
```

Scripts handle URL construction, fallbacks, and error chains automatically.

## Quick Start Examples

**Specific API lookup:**
```bash
node scripts/detect-topic.js "supabase magic link auth"
node scripts/fetch-docs.js "supabase magic link auth"
# Read returned URLs with WebFetch
```

**General library docs:**
```bash
node scripts/detect-topic.js "shadcn ui components"
node scripts/fetch-docs.js "shadcn ui components"
cat llms.txt | node scripts/analyze-llms-txt.js -
# Deploy parallel agents per recommendation
```

## Supported Libraries (taw-kit stack)

- `nextjs` — App Router, Server Components, API routes
- `supabase` — Auth, database, storage, RLS
- `shadcn-ui` — Component props and variants
- `tailwindcss` — Utility classes, responsive prefixes
- `polar` — Checkout, webhooks, subscriptions
- `react` — Hooks, patterns

## Script Descriptions

- `detect-topic.js` — classifies query, extracts library + topic keyword
- `fetch-docs.js` — constructs context7 URLs, handles fallback chains
- `analyze-llms-txt.js` — categorises URLs, recommends agent distribution

## Environment

Scripts load config from `.env` in project root or skill directory.
See `.env.example` for `CONTEXT7_API_KEY` if rate limiting is hit.
