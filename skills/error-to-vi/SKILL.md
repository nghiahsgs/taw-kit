---
name: error-to-vi
description: >
  Translate common Next.js, TypeScript, Supabase, and npm build errors into
  plain Vietnamese with actionable fix hints. Used by taw-fix and taw-deploy
  so non-dev users never see raw English error messages.
argument-hint: "[error message text]"
---

# error-to-vi — Error Translation to Vietnamese

## Purpose

Take raw English error output and return a plain Vietnamese explanation with
a simple fix instruction. Non-dev users see "Bi loi X, lam Y de sua" — not
a stack trace.

## Translation Table

### Next.js Build Errors

| English error | Vietnamese | Fix hint |
|--------------|-----------|----------|
| `Module not found: Can't resolve '...'` | "Khong tim thay module [...]. Co the chua cai dat." | `npm install <ten-package>` |
| `Type error: Type 'X' is not assignable to type 'Y'` | "Loi kieu du lieu: [...] khong phu hop." | "Kiem tra kieu du lieu tai dong loi, sua cho dung kieu." |
| `Error: NEXT_PUBLIC_ env var is missing` | "Thieu bien moi truong [...] trong .env.local" | "Mo .env.local va them bien nay." |
| `SyntaxError: Unexpected token` | "Loi cu phap tai dong [...]. Co the thieu dau ngoac hoac dau phay." | "Kiem tra dong loi, sua dau cu phap." |
| `Build failed because of webpack errors` | "Build bi loi do Webpack. Xem loi cu the ben duoi." | "Doc thong bao loi va sua theo huong dan." |
| `ENOSPC: no space left on device` | "May tinh het dung luong dia." | "Xoa thu muc .next/ va node_modules/, roi chay npm install lai." |

### Supabase Errors

| English error | Vietnamese | Fix hint |
|--------------|-----------|----------|
| `Invalid API key` | "API key Supabase sai hoac het han." | "Kiem tra NEXT_PUBLIC_SUPABASE_ANON_KEY trong .env.local" |
| `relation does not exist` | "Bang du lieu [...] chua duoc tao." | "Chay migration SQL trong Supabase dashboard." |
| `new row violates row-level security policy` | "Khong co quyen ghi vao bang [...] (RLS)." | "Kiem tra policy RLS trong Supabase dashboard." |
| `JWT expired` | "Phien dang nhap het han." | "Dang xuat va dang nhap lai." |
| `Email not confirmed` | "Email chua duoc xac nhan." | "Kiem tra hop thu va bam vao link xac nhan." |

### npm / Node Errors

| English error | Vietnamese | Fix hint |
|--------------|-----------|----------|
| `EACCES: permission denied` | "Khong co quyen truy cap. Khong dung sudo voi npm." | "Chay: `npm config set prefix ~/.npm-global`" |
| `npm ERR! peer dep missing` | "Thieu thu vien phu thuoc." | "Chay: `npm install --legacy-peer-deps`" |
| `Cannot find module 'next'` | "Chua cai Next.js. Chay: `npm install`" | `npm install` |
| `Error: listen EADDRINUSE :::3000` | "Cong 3000 dang duoc su dung boi chuong trinh khac." | "Chay: `npx kill-port 3000` roi thu lai." |

### Vercel Deploy Errors

| English error | Vietnamese | Fix hint |
|--------------|-----------|----------|
| `Build failed` | "Build that bai tren Vercel. Kiem tra logs." | "Vao Vercel dashboard > Deployments > xem logs chi tiet." |
| `Environment variable not found` | "Thieu bien moi truong tren Vercel." | "Vao Project Settings > Environment Variables va them bien." |
| `Function execution timeout` | "Ham chay qua lau (>10 giay)." | "Kiem tra cac API route co ket noi database cham khong." |

## Usage Pattern

When an error is encountered:
1. Match error text against table above (partial match OK)
2. Return: Vietnamese explanation + fix instruction
3. If no match: show generic message: "Co loi xay ra: [nguyen nhan co the]. Thu khoi dong lai voi `npm run dev`."
4. Log original English error to file `taw-error.log` for debugging
