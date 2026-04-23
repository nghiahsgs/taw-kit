# maintain: seed

Generate realistic seed data for dev/staging. Reads Supabase schema, creates typed fake data, inserts via Supabase client. Respects foreign keys and RLS.

**Prereq:** router classified `tier2 = seed`.

## Step 1 — Detect schema

Read `types/supabase.ts` if exists (from `@branches/maintain/types.md`).
Else read `supabase/migrations/*.sql` to find tables + columns.
Else: "Chưa có schema Supabase rõ ràng. Chạy `/taw types` trước." Stop.

List tables found to user:
```
Tìm thấy {N} bảng:
  users      (5 cột)
  products   (8 cột)
  orders     (6 cột, FK → users, products)
  ...

Seed cho bảng nào?
  1. tất cả
  2. chọn tay (gõ tên, cách nhau dấu phẩy)
  3. chỉ demo data (users + 2 bảng chính)
```

## Step 2 — Decide row counts

Ask:
```
Bao nhiêu row mỗi bảng?
  1. ít (10 mỗi bảng) — thử nhanh
  2. vừa (100 mỗi bảng) — giống thật
  3. nhiều (1000 mỗi bảng) — test perf
  4. tuỳ chỉnh — gõ số cho từng bảng
```

## Step 3 — Connection choice

```
Seed vào đâu?
  1. local    — supabase local dev (localhost:54321)
  2. remote   — cloud Supabase (NGUY HIỂM nếu là prod)
```

If user picks remote:
```
⚠️ Sẽ insert vào Supabase cloud (NEXT_PUBLIC_SUPABASE_URL).
   Đây có phải môi trường prod không? Nhầm là xoá data khách thật.
   Gõ "co, staging": tiếp tục | "khong": huỷ
```

Require exact confirmation text.

## Step 4 — Check for existing data

For each target table:
```bash
# via supabase client
select count(*) from <table>
```

If >0 rows:
```
Bảng {table} đã có {N} row.
  1. thêm vào (insert mới, giữ data cũ)
  2. xoá sạch rồi seed (DELETE + INSERT) — nguy hiểm
  3. skip bảng này
```

## Step 5 — Generate

Tool: `@faker-js/faker` for VN locale. Install if missing:
```bash
npm install -D @faker-js/faker
```

Create `scripts/seed.ts`:
```ts
import { createClient } from '@supabase/supabase-js'
import { faker } from '@faker-js/faker/locale/vi'
import type { Database } from '@/types/supabase'

const url = process.env.NEXT_PUBLIC_SUPABASE_URL!
const key = process.env.SUPABASE_SERVICE_ROLE_KEY!  // service role to bypass RLS
const supabase = createClient<Database>(url, key)

async function seedUsers(n: number) {
  const rows = Array.from({ length: n }, () => ({
    email: faker.internet.email(),
    full_name: faker.person.fullName(),
    // ... each column
  }))
  const { data, error } = await supabase.from('users').insert(rows).select()
  if (error) throw error
  return data
}

// ... similar for each table, respecting FK order

async function main() {
  const users = await seedUsers(100)
  const products = await seedProducts(100)
  await seedOrders(100, users, products)  // FK-aware
  console.log('Done')
}
main().catch(console.error)
```

Order by FK dependency: tables with no FK first, dependent tables after.

For each column, pick a generator:
| Column name pattern | Faker |
|---|---|
| `email` | `faker.internet.email()` |
| `full_name` / `name` | `faker.person.fullName()` |
| `phone` | `faker.phone.number({style:'international'})` |
| `address` | `faker.location.streetAddress()` |
| `price` / `amount` | `faker.number.int({min:10000,max:500000})` (VND-ish) |
| `created_at` / `*_at` | `faker.date.recent({days:30}).toISOString()` |
| `image_url` / `avatar` | `faker.image.urlPicsumPhotos({width:400,height:400})` |
| `title` / `name` | `faker.commerce.productName()` (VN: custom list) |
| `description` | `faker.lorem.sentences(2)` |
| `uuid` / `*_id` FK | FK → pick from parent's seeded rows |
| `jsonb` | `{}` (safe default) |
| boolean | `faker.datatype.boolean()` |
| enum | random pick from enum values in schema |

## Step 6 — Run

```bash
npx tsx scripts/seed.ts
```

(If `tsx` missing: `npm install -D tsx` — ask user first.)

Stream stdout/stderr. If any insert fails:
- Constraint violation → show the row + the constraint, ask: "Skip row này hay sửa generator?"
- Auth error (401) → "Service role key sai. Check `.env.local`."

## Step 7 — Verify

For each seeded table:
```ts
select count(*) from <table>
```

Render (VN):
```
✓ Seed xong:
  users:     100 rows
  products:  100 rows
  orders:    100 rows (all FK valid)
  
Chạy app: npm run dev → data đã sẵn.
```

## Step 8 — Commit (optional)

If user wants the seed script committed:
```
git add scripts/seed.ts
git-auto-commit: type=chore, scope=seed, subject="add seed script"
```

Data itself is NOT committed (it's in DB, not repo).

## Constraints

- ALWAYS use `SUPABASE_SERVICE_ROLE_KEY` for seeding (bypass RLS) — warn user this key is server-only
- NEVER seed prod data accidentally — require explicit "staging" confirmation for remote
- Respect FK: seed parents before children
- Don't seed auth.users table directly — it has triggers/hashing; use `supabase.auth.admin.createUser()` for user accounts
- Keep seed script checked in but with hardcoded counts at top user can edit
- Faker VI locale can be thin — fallback to en for some generators (address formats)
