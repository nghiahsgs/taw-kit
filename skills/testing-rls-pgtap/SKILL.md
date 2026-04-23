---
name: testing-rls-pgtap
description: >
  Write and run pgTAP tests that validate Supabase Row Level Security (RLS)
  policies. Ensures tenants can only see their own rows, admins see all, etc.
  Detection-first — reads supabase/migrations/ to auto-infer tables and policies.
  Trigger phrases (EN + VN): "rls test", "pgtap", "supabase rls",
  "test policy", "kiem tra rls", "test bao mat database".
allowed-tools: Read, Write, Edit, Bash, Grep
---

# testing-rls-pgtap — Supabase RLS Policy Tests

## Step 0 — Detect existing setup

Read `supabase/config.toml`:
```bash
grep -E 'enabled.*=.*true' supabase/config.toml | grep -i 'test\|pgtap' || echo "pgTAP not enabled yet"
```

Scan `supabase/migrations/` for tables with RLS:
```bash
grep -l 'ENABLE ROW LEVEL SECURITY' supabase/migrations/*.sql
grep -l 'CREATE POLICY' supabase/migrations/*.sql
```

For each table found, verify at least 1 policy exists. Tables with RLS enabled but NO policies = "default-deny, everything denied" — flag before writing tests.

## Step 1 — Enable pgTAP (one-time per project)

In `supabase/config.toml` ensure:
```toml
[db]
major_version = 15

[db.seed]
enabled = true

[experimental]
# pgTAP comes built-in with Supabase CLI ≥ 1.100
```

Create `supabase/tests/` directory. Each test file = one `.sql` ending with `.test.sql`.

## Step 2 — Test file anatomy

```sql
-- supabase/tests/rls_orders.test.sql
begin;
select plan(5);  -- 5 assertions below

-- Set up 2 users in auth.users (or use existing seed)
insert into auth.users (id, email)
values
  ('00000000-0000-0000-0000-000000000001', 'alice@test'),
  ('00000000-0000-0000-0000-000000000002', 'bob@test');

-- Seed orders owned by each
insert into public.orders (id, user_id, total)
values
  ('ord_alice', '00000000-0000-0000-0000-000000000001', 100),
  ('ord_bob',   '00000000-0000-0000-0000-000000000002', 200);

-- Impersonate alice
set local role authenticated;
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-000000000001","role":"authenticated"}';

select is(
  (select count(*) from public.orders)::int, 1,
  'alice sees only her order'
);

select results_eq(
  $$ select id from public.orders $$,
  $$ values ('ord_alice'::text) $$,
  'alice sees her order id only'
);

-- Switch to bob
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-000000000002","role":"authenticated"}';

select is(
  (select count(*) from public.orders)::int, 1,
  'bob sees only his order'
);

-- Unauthenticated
set local request.jwt.claims to '{"role":"anon"}';

select is(
  (select count(*) from public.orders)::int, 0,
  'anon sees zero orders'
);

-- Write denied for non-owner
set local request.jwt.claims to
  '{"sub":"00000000-0000-0000-0000-000000000001","role":"authenticated"}';

select throws_ok(
  $$ update public.orders set total = 999 where id = 'ord_bob' $$,
  '42501',
  null,
  'alice cannot update bob''s order'
);

select * from finish();
rollback;
```

## Step 3 — Useful pgTAP assertions

| Assertion | Use for |
|---|---|
| `is(x, y, 'desc')` | equality |
| `isnt(x, y, 'desc')` | inequality |
| `ok(boolean, 'desc')` | any truthy |
| `results_eq($$ q $$, $$ values (...) $$, 'desc')` | whole result set |
| `throws_ok($$ q $$, sqlstate, msg, 'desc')` | expect error |
| `lives_ok($$ q $$, 'desc')` | no error |
| `has_table('schema', 'table', 'desc')` | DDL assertion |
| `col_not_null('t', 'col', 'desc')` | constraint |
| `policies_are('schema', 'table', ARRAY['p1','p2'])` | exact policy set |

## Step 4 — Run tests

Local Supabase running:
```bash
supabase db reset            # wipes + reapplies migrations + runs seed
supabase test db             # runs all .test.sql in supabase/tests/
```

Expected output:
```
# Tests 5
# Pass 5
ok
```

## Step 5 — Common policy patterns to cover

For each policy type, at minimum:

**Own-rows-only SELECT** (`user_id = auth.uid()`):
- Owner sees own rows → 1 row returned
- Other user sees nothing → 0 rows
- Anon sees nothing → 0 rows

**Insert with owner auto-fill** (default `auth.uid()` in INSERT policy):
- Authenticated can insert
- `user_id` field cannot be forged (server rewrites to auth.uid())
- Anon cannot insert → throws 42501

**Role-based** (`auth.jwt() ->> 'role' = 'admin'`):
- Admin sees all
- Regular user sees only own
- Anon sees nothing

**Soft-delete visibility** (`deleted_at is null`):
- Soft-deleted rows hidden from normal query
- Admin can still see via `include_deleted` flag

## Step 6 — CI integration

In `.github/workflows/test.yml`:
```yaml
- uses: supabase/setup-cli@v1
  with: { version: latest }
- run: supabase start
- run: supabase test db
```

## Constraints

- Tests run against the LOCAL Supabase instance — never against cloud prod
- Every test wraps in `begin; ... rollback;` so state doesn't leak between files
- `set local` is crucial — `set` without `local` persists across the rollback boundary
- If RLS is declared but no policy exists, it's "default deny" — test should assert 0 rows returned, not skip the table
- Don't use real emails or PII in seed — use `@test` pseudo-domain
