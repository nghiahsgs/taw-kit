# Clarify Questions Bank

Load this file during Step 2 of `/taw`. Pick 3–5 questions matching the classified intent. Skip any question the user already answered in their initial prompt.

Every question has a sensible DEFAULT — if the user says "skip" or gives a non-answer, apply the default.

---

## For all intents (pick 1–2)

**Q1. What's the project name?**
- Default: slug it from the description (English kebab-case, e.g. "coffee-shop-hanoi")

**Q2. Do you have your own domain?**
- Default: use the free Vercel subdomain (`<slug>.vercel.app`)

**Q3. Do you need user login?**
- Default: no. If yes → use Supabase magic-link (sent via email)

---

## landing-page (pick 2–3)

**Q4. What's the main goal of the page?**
- Options: collect email leads / sell a course / promote a service / launch a product
- Default: collect email leads

**Q5. Do you want a lead form? Where should it send submissions?**
- Default: yes, save to Supabase + send a confirmation email

**Q6. Do you want a checkout section (price + buy button)?**
- Default: no

---

## shop-online (pick 3–4)

**Q7. What do you sell? Roughly how many products?**
- Default: seed 6 sample products; user adds more later

**Q8. How do customers pay?**
- Options: Polar (international cards) / MoMo / bank transfer / COD
- Default: Polar + COD fallback

**Q9. Do you need inventory tracking?**
- Default: no for MVP; keep a `stock` column in the DB but don't surface warnings in the UI

**Q10. Do you ship orders? How is shipping priced?**
- Default: flat fee; user can tweak later

---

## crm (pick 3–4)

**Q11. Who uses this (just you / a team)?**
- Default: single owner, no role-based permissions

**Q12. Where do customers come from?**
- Options: manual entry / CSV import / auto-capture from a web form
- Default: manual entry + CSV import

**Q13. What do you track per customer?**
- Default: name, phone, email, notes, tag, status (new/qualified/won/lost)

**Q14. Do you need follow-up reminders?**
- Default: no for MVP; only show a `next_contact_date` field

---

## blog (pick 2–3)

**Q15. How many authors will post?**
- Default: 1 author

**Q16. Where are posts stored?**
- Options: Markdown in the repo / Supabase / Notion API
- Default: Markdown in the repo (simplest)

**Q17. Do you want comments?**
- Default: no (reduces spam); can enable Giscus later

---

## dashboard (pick 3)

**Q18. What metrics should the dashboard show?**
- Default: revenue today / orders today / new customers / top products

**Q19. Where does the data come from?**
- Options: Supabase / Google Sheets / manual import
- Default: Supabase

**Q20. Do you need to export reports (PDF/Excel)?**
- Default: no for MVP

---

## Deploy (all intents, 1 question)

**Q21. Where should we deploy when it's ready?**
- Options: Vercel (default) / Shipkit MCP / skip deploy for now
- Default: Vercel via Shipkit MCP if available, else fallback `vercel --prod`
