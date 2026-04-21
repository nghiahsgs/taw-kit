---
name: dashboard
description: KPI dashboard with stat cards, charts, and Supabase data. Auth required.
---

## Pre-filled intent

I need an admin dashboard to track key business metrics. It needs KPI cards
(revenue, orders, new customers), line and bar charts over time, a detail table,
all pulled from Supabase. Only authenticated users can see it.

## Pre-filled clarifications

```yaml
kpi_cards:
  - total_revenue
  - order_count
  - new_customers
  - conversion_rate
chart_types:
  - line (revenue per day)
  - bar (orders per week)
date_filter: last-30-days
auth_needed: true
auth_method: magic-link
data_source: supabase
refresh_interval: manual
language: en
```

## Stack overrides

```yaml
supabase_auth: magic-link
chart_library: recharts
supabase_tables:
  - name: metrics_daily
    columns: [date, revenue, orders, new_customers]
    rls: true
  - name: events
    columns: [id, type, value, metadata, created_at]
    rls: true
skip_polar: true
```

## Expected phases

- Auth gate: Supabase magic link, redirect unauthenticated users to /login
- Layout: sidebar navigation + header with user info + logout
- KPI cards: 4 stat cards with period-over-period comparison (% change)
- Charts: line chart for revenue + bar chart for orders, via Recharts
- Detail table: 20 most recent events with pagination

## Success criteria

- `/dashboard` redirects to `/login` when unauthenticated
- KPI cards load real Supabase data in under 1s
- Charts render correctly with seeded sample data
- Date filter changes all charts + cards simultaneously
- `npm run build` exits 0 cleanly
