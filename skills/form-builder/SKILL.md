---
name: form-builder
description: >
  Build contact, lead capture, and booking forms that save submissions to Supabase.
  Uses react-hook-form + zod validation. Vietnamese field labels and error messages.
  Activated by taw and taw-add for any form feature request.
argument-hint: "[loai-form: contact|lead|booking|order]"
---

# form-builder — Forms to Supabase

## Purpose

Generate production-ready forms with client-side validation, server-side submission
to Supabase, and Vietnamese error messages. No third-party form services needed.

## Dependencies

```bash
npm install react-hook-form @hookform/resolvers zod
```
shadcn/ui Form components required (see `shadcn-ui` skill).

## Contact Form (full example)

```tsx
// components/contact-form.tsx
"use client"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { useState } from "react"
import { createClient } from "@/lib/supabase/client"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { toast } from "sonner"

const schema = z.object({
  name: z.string().min(2, "Ten phai co it nhat 2 ky tu"),
  phone: z.string().regex(/^(0|\+84)[0-9]{9}$/, "So dien thoai khong hop le"),
  email: z.string().email("Email khong dung dinh dang").optional().or(z.literal("")),
  message: z.string().min(10, "Tin nhan qua ngan, viet them nhe"),
})

type FormData = z.infer<typeof schema>

export function ContactForm() {
  const [loading, setLoading] = useState(false)
  const form = useForm<FormData>({ resolver: zodResolver(schema) })

  async function onSubmit(data: FormData) {
    setLoading(true)
    const supabase = createClient()
    const { error } = await supabase.from("contact_submissions").insert([data])
    if (error) {
      toast.error("Co loi xay ra. Vui long thu lai sau.")
    } else {
      toast.success("Da gui thanh cong! Chung toi se lien he ban som.")
      form.reset()
    }
    setLoading(false)
  }

  return (
    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4 max-w-md">
      <div>
        <label className="text-sm font-medium">Ho ten *</label>
        <Input {...form.register("name")} placeholder="Nguyen Van A" />
        {form.formState.errors.name && (
          <p className="text-sm text-red-500 mt-1">{form.formState.errors.name.message}</p>
        )}
      </div>
      <div>
        <label className="text-sm font-medium">So dien thoai *</label>
        <Input {...form.register("phone")} placeholder="0901234567" />
        {form.formState.errors.phone && (
          <p className="text-sm text-red-500 mt-1">{form.formState.errors.phone.message}</p>
        )}
      </div>
      <div>
        <label className="text-sm font-medium">Tin nhan *</label>
        <Textarea {...form.register("message")} placeholder="Ban muon hoi gi?" rows={4} />
        {form.formState.errors.message && (
          <p className="text-sm text-red-500 mt-1">{form.formState.errors.message.message}</p>
        )}
      </div>
      <Button type="submit" disabled={loading} className="w-full">
        {loading ? "Dang gui..." : "Gui tin nhan"}
      </Button>
    </form>
  )
}
```

## Supabase Table Migration

```sql
create table if not exists public.contact_submissions (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text not null,
  email text,
  message text not null,
  created_at timestamptz default now()
);
alter table public.contact_submissions enable row level security;
-- Allow inserts from anyone (public contact form)
create policy "contact_insert" on public.contact_submissions
  for insert with check (true);
-- Only service role / admin can read
create policy "contact_admin_read" on public.contact_submissions
  for select using (false);
```

## Form Variants

| Form type | Fields | Table |
|-----------|--------|-------|
| Lead capture | email, name | `leads` |
| Booking | name, phone, date, service | `bookings` |
| Order | name, phone, address, items | `orders` |
| Survey | dynamic fields | `survey_responses` |
