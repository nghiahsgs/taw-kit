---
name: crm
description: Simple customer-list CRM with CSV import, manual entry, and detail pages.
---

## Pre-filled intent

I need a simple CRM to manage my customer list and leads. It needs a customer list
page with search and filter, a detail page per customer, manual entry via form, and
bulk import from CSV. Data lives in Supabase, behind authentication.

## Pre-filled clarifications

```yaml
fields:
  - name
  - email
  - phone
  - company
  - status
  - notes
  - created_at
auth_needed: true
auth_method: magic-link
csv_import: true
export_needed: true
notes_per_customer: true
language: en
```

## Stack overrides

```yaml
supabase_auth: magic-link
supabase_tables:
  - name: customers
    columns: [id, name, email, phone, company, status, notes, owner_id, created_at]
    rls: true
    rls_policy: "owner_id = auth.uid()"
  - name: activities
    columns: [id, customer_id, note, created_by, created_at]
    rls: true
skip_polar: true
```

## Expected phases

- Auth with Supabase magic link (email OTP, no password)
- Customer list page: table + search + filter by status
- Customer detail page: info + activity history + notes
- Manual add form with email/phone validation
- CSV import: upload, parse, preview, confirm before saving

## Success criteria

- Magic-link login works; each user only sees their own customers (RLS)
- Import a 50-row CSV without errors
- Search by name/email responds in under 300ms
- Export the customer list to CSV
- `npm run build` exits 0 cleanly
