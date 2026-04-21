---
name: sequential-thinking
description: >
  Break a multi-step task into numbered reasoning steps before acting. Used by
  taw-kit planner agent to decompose ambiguous Vietnamese prompts into
  executable phases. Vietnamese trigger phrases: "suy nghĩ từng bước",
  "phân tích kĩ", "chia nhỏ ra".
---

# sequential-thinking

Forces deliberate, numbered reasoning when a problem is too fuzzy to one-shot. Prevents plan holes.

## When to invoke

- Intent classification confidence is low (user text is ambiguous)
- Requirements conflict (user asks for auth + no login in the same sentence)
- Estimating effort for a feature the orchestrator has not built before
- Whenever the output would otherwise be "let me just try and see"

## Method

Produce a numbered list where each step satisfies:

1. **One action verb per step.** "Check", "Decide", "Write", "Invoke".
2. **Observable output.** What file/state changes after the step?
3. **Cheap before expensive.** Verify assumptions before spawning agents or running npm install.
4. **Stop condition.** Each step has a pass/fail check before the next step is considered.

## Rendering contract

Internal reasoning. The user does NOT see these steps unless they hit an error — then surface the last 3 steps as context for `/taw-fix`.

## Example

User prompt: "xây blog cá nhân, kiểu như medium, có login, dùng chung tài khoản Google"

Reasoning:
1. Check intent: `blog` with social login — multi-user or single-user?
2. Spot conflict: "cá nhân" (solo) vs "chung tài khoản Google" (multi). Decide: ask user.
3. If solo → skip Google OAuth, use Supabase magic-link for author only.
4. If multi → add Google provider, but this raises scope ≥ CRM level.
5. Default assumption: solo author + Google OAuth for SSO convenience only.
6. Load `taw` clarify template Q16 (blog storage) + custom Q (Google login for you or for readers?).

Only step 6 is visible — prior steps stay in the reasoning scratchpad.

## Anti-patterns

- Don't produce "plan of plan" loops. If the reasoning itself needs sequential-thinking, stop and ask the user.
- Don't fabricate deadlines ("Step 7 takes 5 minutes"). Time estimates belong in the plan bullets, not the reasoning trace.
- Never expose intermediate reasoning to the user unless debugging.
