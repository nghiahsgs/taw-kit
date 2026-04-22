---
name: taw-new
description: >
  Scaffold a new taw-kit project from a named preset. Loads presets/<name>.md,
  injects pre-filled intent into /taw context, skips classification (Step 1),
  jumps straight to clarify (Step 2) with preset questions. User-visible strings
  match the user's input language (Vietnamese by default for VN users).
  Trigger phrases (EN + VN): "new project from preset",
  "scaffold a <preset>", "start with template", "tao du an moi tu mau".
argument-hint: "<preset-name>"
allowed-tools: Read, Write, Bash, Glob, Task
---

# taw-new — Scaffold from Preset

You are the taw-new skill. Load a named preset and hand off to the /taw orchestrator with pre-filled intent, bypassing classification.

**Language rule (MUST follow):** Detect the language of the user's input. If they wrote Vietnamese (or VN-style mixed text like "tao du an moi"), reply 100% in Vietnamese — friendly, conversational, Southern style. If English, reply in English. Default to Vietnamese for ambiguous/short input. Applies to ALL user-visible text. Keep sentences short, no jargon.

## Available presets (valid names)

| Preset name | Description |
|-------------|-------------|
| `landing-page` | Marketing page + email capture |
| `shop-online` | Online store + cart + checkout |
| `crm` | Customer list + CSV import |
| `blog` | Markdown blog + single author |
| `dashboard` | KPI dashboard + charts |

## Step 1 — Validate preset name

Parse `<preset-name>` from invocation args.

If the arg is empty:
```
Which preset do you want to use?
  1. landing-page — Marketing page + email capture
  2. shop-online  — Online store + cart + checkout
  3. crm          — Customer list + CSV import
  4. blog         — Markdown blog + single author
  5. dashboard    — KPI dashboard + charts
Type the preset name (e.g. shop-online):
```
Wait for reply, then continue with the chosen name.

If the name isn't in the valid list above:
1. Find the closest match (substring or edit distance ≤ 2).
2. Emit: "I couldn't find preset `<name>`. Did you mean `<closest>`?" — wait for yes/no.
3. On `no`: show the full list and wait.
4. On `yes`: proceed with `<closest>`.

## Step 2 — Load preset file

Read `presets/<preset-name>.md`. Extract:
- `Pre-filled intent` section → use as `intent` string
- `Pre-filled clarifications` YAML block → use as default answers
- `Stack overrides` section → merge into taw context (user overrides win)

If the file is missing: emit "Preset `<name>` isn't installed. Contact support." and stop.

## Step 3 — Write pre-filled intent to .taw/

Create `.taw/` if absent.

Write `.taw/intent.json`:
```json
{
  "category": "<preset-name>",
  "raw": "<Pre-filled intent text from preset>",
  "keywords": ["<from preset>"],
  "source": "preset",
  "preset_name": "<name>",
  "clarifications": { <Pre-filled clarifications from preset> },
  "stack_overrides": { <from preset Stack overrides section> }
}
```

Emit: "Using preset `<preset-name>`. Setting things up..."

## Step 4 — Hand off to /taw at Step 2

Invoke the /taw orchestrator with these instructions:

```
Skip Step 1 (classification is done — category = <preset-name>).
.taw/intent.json is already written with pre-filled clarifications.
Start at Step 2 (clarify). Use the clarify_questions from the preset as the
default question set. The user may have 0–2 additional Qs based on answers.
Then continue normally through Steps 3–8.
```

Use the Task tool to spawn /taw with the above context note prepended to its standard execution, passing `.taw/intent.json` as the starting state.

## Step 5 — Done (delegated to /taw)

/taw handles Steps 3–8 (plan, approval, agents, deploy). taw-new's job ends after the Step 4 handoff. The user will see /taw's standard output from that point onward.

## Constraints

- User overrides always win over preset `Stack overrides`. If the user says "no Supabase needed", honour that even if the preset has `db: supabase`.
- NEVER skip the approval gate in /taw Step 4 — preset pre-fills reduce Q count but the single plan-approval gate is mandatory.
- Preset name matching is case-insensitive and strips leading/trailing spaces.
- If `/taw-new` is called inside an existing taw-kit project (`.taw/` already exists), warn: "This folder already has a project. Do you want to scaffold a new one in a different folder?" — require explicit `yes` before overwriting `.taw/`.
