---
name: docs-seeker
description: >
  Fetch up-to-date documentation for a framework, library, or API that taw-kit
  uses. Invoke when the orchestrator hits an unfamiliar feature (new Next.js
  version, Supabase RLS syntax, Polar webhook shape). Vietnamese trigger phrases:
  "tra tài liệu", "xem docs mới nhất", "tìm hướng dẫn <tên lib>".
---

# docs-seeker

Returns the freshest official documentation snippet for a targeted topic so the orchestrator does not reason from stale training data.

## When to invoke

- New release of a framework listed in the taw-kit default stack (Next.js, Tailwind, shadcn/ui, Supabase, Polar, Shipkit)
- Error message points to an API shape that may have changed
- Orchestrator needs a concrete code example, not a paraphrase
- User asks in VN: "có version mới chưa?" / "còn syntax cũ không?"

## Output contract

Return 3 blocks, in this order:

1. **Summary (2 lines, Vietnamese)** — what the topic is + why it changed
2. **Primary snippet (code block, English)** — canonical code from current docs
3. **Source** — URL + retrieved date

## How to run

1. Pick the narrowest query term possible. "Supabase auth magic link" beats "Supabase auth".
2. Prefer official docs (`supabase.com/docs`, `nextjs.org/docs`, `polar.sh/docs`, `tailwindcss.com/docs`, `ui.shadcn.com`).
3. If official docs are ambiguous, check the library's GitHub `README.md` for the pinned version in `package.json`.
4. If the topic is framework version-specific, always include the version number in the summary.
5. Never quote a blog post or Medium article as primary source — only as tiebreaker when official docs are silent.

## Limits

- One topic per invocation. If caller passes two topics, split into two calls.
- Return ≤ 400 words total. Skip marketing copy, keep code.
- If no authoritative source is found within 2 tries, return `{"status":"not-found","suggestion":"<VN message>"}` and stop.

## Example

Input: "Supabase magic link gửi email từ server action Next.js 14"

Output:
```
Supabase cung cấp `supabase.auth.signInWithOtp({ email })` trả về token gửi
qua email. Trong Next.js 14 App Router, gọi hàm này bên trong Server Action.

import { createClient } from '@/lib/supabase/server';
export async function sendMagicLink(email: string) {
  const supabase = createClient();
  await supabase.auth.signInWithOtp({ email });
}

Source: https://supabase.com/docs/guides/auth/auth-email-passwordless
Retrieved: 2026-04-21
```
