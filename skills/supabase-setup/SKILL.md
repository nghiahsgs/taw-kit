---
name: supabase-setup
description: >
  Spin up Supabase project schema, run migrations, and configure Row Level
  Security (RLS) for taw-kit projects. Activated when a new database table
  or auth flow is needed. Non-dev safe — generates SQL, does not require
  user to understand SQL syntax.
argument-hint: "[ten-bang hoac 'kiem tra ket noi']"
---

# supabase-setup — Database Bootstrap

## Purpose

Generate and apply Supabase schema, migrations, and RLS policies for taw-kit
projects. Reads project requirements and produces ready-to-run SQL.

## When to Activate

- First run: create initial tables for a new project
- Adding a new feature that needs a database table
- Setting up auth (always pairs with `auth-magic-link` skill)
- Debugging "permission denied" or "relation does not exist" errors

## Workflow

### 1. Verify Connection
```bash
# Check env vars exist
grep -E "SUPABASE_URL|SUPABASE_ANON_KEY" .env.local
```

### 2. Generate Migration SQL

For a typical e-commerce schema:
```sql
-- Create products table
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  price_vnd integer not null,
  description text,
  image_url text,
  created_at timestamptz default now()
);

-- Create orders table
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  status text default 'pending',
  total_vnd integer not null,
  created_at timestamptz default now()
);
```

### 3. Apply RLS Policies

```sql
-- Enable RLS
alter table public.products enable row level security;
alter table public.orders enable row level security;

-- Products: anyone can read, only service role can write
create policy "products_public_read" on public.products
  for select using (true);

-- Orders: users see only their own
create policy "orders_own" on public.orders
  for all using (auth.uid() = user_id);
```

### 4. Apply via Supabase CLI or Dashboard

```bash
# Via CLI (if installed)
npx supabase db push

# Via dashboard: paste SQL into SQL Editor at supabase.com/dashboard
```

## Common Patterns

| Use Case | Tables Needed |
|----------|--------------|
| Shop | `products`, `orders`, `order_items` |
| Booking | `services`, `bookings`, `time_slots` |
| Blog | `posts`, `categories`, `tags` |
| SaaS | `profiles`, `subscriptions`, `usage_logs` |

## RLS Quick Reference

- `for select using (true)` — public read
- `for all using (auth.uid() = user_id)` — owner only
- `for insert with check (auth.uid() is not null)` — any logged-in user
