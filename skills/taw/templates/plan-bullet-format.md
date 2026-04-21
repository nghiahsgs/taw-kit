# Plan Bullet Format

Load during Step 3 of `/taw`. Render exactly 3–5 bullets covering the dimensions below.

## Format

```
Plan:
1. <Stack> — <1-line description>
2. <Pages/Features> — <list of 3-5 items>
3. <Data/Integrations> — <DB tables + integrations>
4. <Deploy> — <target + URL pattern>
5. <Estimated time> — <minutes>
```

## Rules

- Bullets numbered 1–5 only. No `-` or `•`.
- Each line ≤ 90 characters.
- No emoji in bullets (save those for Step 8 "Done!").
- Simple English; keep framework names as-is (Next.js, Supabase, etc.).

## Examples

**Landing page for an online course:**
```
Plan:
1. Next.js + Tailwind + shadcn/ui (lean stack, easy to edit)
2. 3 sections: hero + features + email form
3. Supabase stores email leads (table: `leads`)
4. Deploy to Vercel via Shipkit, URL like <slug>.vercel.app
5. Estimated 10-15 minutes
```

**Online coffee shop:**
```
Plan:
1. Next.js + Tailwind + Supabase + Polar
2. 4 pages: home, menu, cart, thank-you
3. Tables: `products` (6 samples), `orders`, `customers`
4. Payments via Polar (cards) + COD, deploy to Vercel
5. Estimated 18-22 minutes
```

**CRM for a cosmetics shop:**
```
Plan:
1. Next.js + Tailwind + shadcn + Supabase auth
2. 2 pages: customer list, customer detail
3. Table: `customers` (name, phone, email, notes, tag, status)
4. CSV import + manual entry, deploy to Vercel
5. Estimated 12-15 minutes
```

## Anti-patterns (do NOT do)

- DO NOT list low-level tech (e.g. "using useState + useEffect...") — user doesn't need to know.
- DO NOT promise features the user didn't confirm (e.g. "dark mode" if not asked).
- DO NOT skip "Estimated time" — the user needs to know how long to wait.
