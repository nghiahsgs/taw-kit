---
name: landing-page
description: Marketing page with a hero, feature grid, and email-capture form.
---

## Pre-filled intent

I want a professional landing page to promote my product or service and collect leads
via email. The page has 3 main sections: a strong hero with a call-to-action, a
features/benefits section, and a signup form.

## Pre-filled clarifications

```yaml
product_name: "My product"
hero_cta: "Sign up"
sections:
  - hero
  - features
  - email-capture-form
email_storage: supabase
payment_needed: false
auth_needed: false
language: en
seo_needed: true
```

## Stack overrides

```yaml
skip_supabase_auth: true
skip_polar: true
supabase_tables:
  - name: leads
    columns: [email, name, created_at]
    rls: true
```

## Expected phases

- Build the Next.js App Router home page with a full-width hero
- Add a 3-column feature grid with icons + descriptions
- Wire the email-capture form to Supabase table `leads`
- Set SEO meta tags, Open Graph, sitemap.xml
- Deploy to Vercel (default) or Docker / VPS on request

## Success criteria

- Page loads in under 2s (Lighthouse ≥ 90)
- Form submissions save to Supabase successfully
- Renders correctly on mobile and desktop
- `npm run build` exits 0 cleanly
- Live URL returned after deploy
