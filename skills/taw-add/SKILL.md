---
name: taw-add
description: >
  Add a feature to an existing taw-kit project. Reads current project state
  from .taw/intent.json and git, clarifies scope (≤3 Qs), gates on approval,
  spawns fullstack-dev scoped to the new feature only. User-visible strings
  are simple English. Trigger phrases (EN + VN): "add a feature", "I want
  to add", "extend with", "them tinh nang", "toi muon them".
argument-hint: "<describe the feature>"
allowed-tools: Task, Read, Write, Edit, Bash, Glob, Grep
---

# taw-add — Add Feature to Existing Project

You are the taw-add skill. Safely extend a taw-kit project with a new feature. Scope is strictly additive — no rewrites of working code. All strings shown to the user MUST be simple English.

## Step 1 — Verify project context

Check that this is a taw-kit project:
1. Read `.taw/intent.json` — if missing, emit: "This folder doesn't have a taw-kit project yet. Run `/taw` first to create one." and stop.
2. Read `package.json` to get the project name and installed dependencies.
3. Run `git log --oneline -5` to see recent change history.

If args are empty, emit: "What feature do you want to add? Give me a short description." and wait.

Store context:
```json
{
  "project": "<name>",
  "category": "<from intent.json>",
  "feature_request": "<user args>",
  "recent_commits": ["..."]
}
```

## Step 2 — Clarify (≤3 questions, lighter than /taw)

Ask at most 3 focused questions. Choose only relevant ones:
- "Which page should this feature appear on?"
- "Does this need to save data to Supabase?"
- "Should this require user login?"

If the feature request is self-evident (e.g. "add dark mode"), skip clarify entirely.

Append answers to `.taw/intent.json` under `features[]`:
```json
{"feature": "<request>", "clarifications": {"page": "...", "auth_required": false}}
```

## Step 3 — Plan the addition

Render a mini-plan (3–4 bullets only):
```
Plan for this feature:
1. <what file/component will be created>
2. <any new dependency to install>
3. <any Supabase table or env var needed>
4. Estimated 5-10 minutes
```

Emit EXACTLY:
```
Does this plan look good? (type: yes / edit / cancel)
```

- `yes` / `ok` / `sure` / `go`: proceed.
- `edit`: re-ask the clarify Qs with the user's notes.
- `cancel`: emit "Cancelled. Type `/taw-add <description>` to try again." and stop.

Write mini-plan to `.taw/add-plan.md`.

## Step 4 — Implement (scoped fullstack-dev)

Spawn `fullstack-dev` via the Task tool:

```
Task: Add a feature to an existing Next.js project.
Feature: <feature_request> | Clarifications: <clarifications JSON>
Rules: Only NEW files or APPENDS to existing — no rewrites of working code.
Scope: <files/dirs from Step 3 plan only>
Stack: Next.js 14 App Router + Tailwind + shadcn/ui. Match existing style.
If new Supabase table: write migration SQL to supabase/migrations/.
If new dep: run `npm install <pkg>`.
End: run `npm run build`. Report pass/fail.
Context files: app/, components/, lib/, .taw/intent.json
```

Emit: "Adding the feature... (this takes a few minutes)"

## Step 5 — Verify build

After fullstack-dev completes, run:
```bash
npm run build 2>&1 | tail -20
```

- Exit 0: proceed to Step 6.
- Non-zero: emit "Build broke after adding the feature. Trying to fix..." and invoke `/taw-fix` automatically (pass error output as arg).

## Step 6 — Commit and done

```bash
Invoke `git-auto-commit` with:
  type=feat, scope=<inferred from feature_request>, subject=<feature slug in simple EN>
  (no [P<n>] tag — taw-add is out-of-phase)
```

Emit:
```
Added: <feature name>
Files changed: <git diff --stat HEAD~1>
Want to deploy? Type: /taw-deploy
Want to add more? Type: /taw-add <description>
```

Append to `.taw/intent.json` → `features[]`: `{"feature":"...","status":"done"}`.

## Constraints

- Scope: ONLY `app/`, `components/`, `lib/`, `supabase/migrations/`. No rewrites of working pages.
- NEVER change `next.config.js` or `tailwind.config.ts` without explicit user approval.
- If the feature requires auth changes: ask "This feature needs auth changes — are you sure?" and require `yes`.
- Max 3 clarify questions; accept defaults for unanswered ones.
- Single approval gate only (Step 3).
- If `.taw/intent.json` absent: redirect to `/taw` instead of proceeding.
