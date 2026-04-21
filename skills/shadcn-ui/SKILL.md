---
name: shadcn-ui
description: >
  Install and use shadcn/ui components in taw-kit projects. Covers Button, Card,
  Form, Table, Dialog, Toast, and navigation patterns. Activated when building
  UI components in Next.js App Router with Tailwind.
argument-hint: "[component-name hoac 'list']"
---

# shadcn-ui — Component Scaffold

## Purpose

Install shadcn/ui components and apply correct usage patterns for the taw-kit
stack (Next.js 14 App Router + Tailwind CSS).

## Install a Component

```bash
npx shadcn@latest add button
npx shadcn@latest add card form table dialog toast
npx shadcn@latest add navigation-menu dropdown-menu sheet
```

## Common Component Patterns

### Button
```tsx
import { Button } from "@/components/ui/button"

<Button variant="default">Mua ngay</Button>
<Button variant="outline">Xem them</Button>
<Button variant="destructive">Xoa</Button>
<Button disabled>Dang xu ly...</Button>
```

### Card
```tsx
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"

<Card>
  <CardHeader>
    <CardTitle>San pham noi bat</CardTitle>
  </CardHeader>
  <CardContent>
    <p>Mo ta san pham</p>
  </CardContent>
</Card>
```

### Form (with react-hook-form + zod)
```tsx
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { Form, FormField, FormItem, FormLabel, FormControl, FormMessage } from "@/components/ui/form"
import { Input } from "@/components/ui/input"

const schema = z.object({ email: z.string().email("Email khong hop le") })

export function ContactForm() {
  const form = useForm({ resolver: zodResolver(schema) })
  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)}>
        <FormField name="email" control={form.control} render={({ field }) => (
          <FormItem>
            <FormLabel>Email</FormLabel>
            <FormControl><Input placeholder="ban@email.com" {...field} /></FormControl>
            <FormMessage />
          </FormItem>
        )} />
        <Button type="submit">Gui</Button>
      </form>
    </Form>
  )
}
```

### Table
```tsx
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"

<Table>
  <TableHeader>
    <TableRow><TableHead>San pham</TableHead><TableHead>Gia</TableHead></TableRow>
  </TableHeader>
  <TableBody>
    {items.map(item => (
      <TableRow key={item.id}>
        <TableCell>{item.name}</TableCell>
        <TableCell>{item.price_vnd.toLocaleString('vi-VN')}đ</TableCell>
      </TableRow>
    ))}
  </TableBody>
</Table>
```

### Toast (Sonner)
```bash
npx shadcn@latest add sonner
```
```tsx
import { toast } from "sonner"
toast.success("Da luu thanh cong!")
toast.error("Co loi xay ra, vui long thu lai.")
```

## Initial Setup (first time)

```bash
npx shadcn@latest init
# Choose: TypeScript, Default style, Slate base color, src/ directory: No
```

Adds `components/ui/` and updates `tailwind.config.ts` automatically.
