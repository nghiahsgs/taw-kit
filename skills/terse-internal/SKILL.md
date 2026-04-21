---
name: terse-internal
description: >
  Caveman-style terse output rules for AGENT-INTERNAL work only (planner,
  researcher, fullstack-dev, tester, reviewer, debug). Cuts ~60-70% of output
  tokens by killing preamble, postamble, tool narration, and filler. Never
  activates for user-facing Vietnamese output (taw, taw-add, taw-new,
  approval-plan, vietnamese-copy, error-to-vi hints shown to user). Inspired
  by JuliusBrussee/caveman but scoped so non-dev VN users still get friendly
  hand-holding in their language.
---

# terse-internal

Strip filler from Claude's English output when it's talking to itself or
between agents. Keep full technical substance. Never touch user-facing
Vietnamese.

## When to activate

Active in these contexts:

- `planner` agent decomposing intent into phases
- `researcher` agent fetching docs
- `fullstack-dev` agent implementing code
- `tester` agent running builds (English error traces only)
- `reviewer` agent running security/quality pass
- `debug` skill internal reasoning
- Hook logs and agent-to-agent messages

## When NOT to activate

Leave these fully friendly and verbose as designed:

- `taw`, `taw-add`, `taw-new`, `taw-fix`, `taw-deploy` status messages to user
- `approval-plan` bullets rendered to user
- `vietnamese-copy` generated content
- `error-to-vi` hints shown to user (the VN translation stays friendly)
- Any message where the audience is the non-dev user

Rule of thumb: if the text ends up in the terminal for the user, it's NOT
terse-internal territory.

## Rules (when active)

1. **No preamble.** Do not announce what you are about to do. Just do it.
2. **No postamble.** Do not summarize what you just did. The diff speaks.
3. **No tool narration.** Do not say "I'll use Read to…". The tool call is
   visible.
4. **No filler.** Drop "I think", "It seems", "Basically", "Essentially",
   "Let me", "I'll go ahead and", "As you can see".
5. **Execute before explain.** Run the tool, then state the result in one
   line. Do not theorize first.
6. **Code and errors verbatim.** Never paraphrase code blocks or error
   messages. Quote exactly.
7. **One-line status.** "Build pass.", "3 files changed.", "Migration
   applied." — not paragraphs.
8. **Errors are fixable facts, not narration.** "Missing env SUPABASE_URL.
   Added to .env.example." — not "It seems there might be an issue with…".
9. **Drop articles sparingly.** OK to say "build fail, retrying" but keep
   articles when ambiguity would result. Readable > minimal.
10. **Technical terms stay intact.** `supabase.auth.signInWithOtp`,
    `NEXT_PUBLIC_SITE_URL`, exit codes — never compressed.

## Anti-patterns

- Do NOT caveman-ify output going to the user. Breaks trust with non-dev VN
  users who need hand-holding.
- Do NOT strip context from error messages handed to `error-to-vi` — that
  skill needs the full English error to translate accurately.
- Do NOT omit file paths or line numbers to save tokens. Those are navigation
  anchors, not filler.
- Do NOT mistake brevity for rudeness — the rules apply to internal comms,
  not user interaction.

## Example — planner internal output

Before:
> Great! I'll now analyze the user's intent. Based on my understanding, it
> looks like they want to build a landing page with a contact form. Let me
> go ahead and create the phase files for this. I'll start by…

After:
> Intent: landing + contact form. Phases: 01-scaffold, 02-hero, 03-form,
> 04-deploy. Writing phase files.

## Example — fullstack-dev internal output

Before:
> Perfect! I've successfully created the login page. The file is located at
> app/login/page.tsx and contains a form with email input. I've also added
> the necessary Supabase client. Let me know if you'd like me to continue!

After:
> app/login/page.tsx written. Supabase client wired. Next: middleware.

## Credit

Inspired by [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman).
Scope narrowed to internal agents so taw-kit's user-facing Vietnamese tone
stays warm.
