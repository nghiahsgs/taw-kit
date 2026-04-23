# branch: BUILD

Routed here when user wants to create something — a new project, a new feature on an existing project, or scaffold from a preset. This branch handles all three cases in one flow.

**Prereq:** router has classified `tier1 = BUILD` and written `.taw/intent.json`.

## Step 0 — Sub-classify the BUILD ask

Look at user prose + current folder state:

| Case | Signals | Next step |
|---|---|---|
| `new-from-prose` | No `.taw/intent.json` exists yet AND user described a product ("làm cho tôi một shop...") | Step 1 — classify category, then Steps 2-9 full flow |
| `new-from-preset` | User mentioned a preset name (landing-page, shop-online, crm, blog, dashboard) OR typed `preset:<name>` | Step 1p — load preset, skip category classify, go to Step 2 |
| `add-feature` | `.taw/intent.json` ALREADY exists (project is alive) AND user says "thêm X / add X" | Jump to Step A1 (scoped feature add, lighter flow) |

If unsure, ask: "Anh muốn tạo dự án mới hay thêm tính năng vào dự án hiện tại?"

---

## NEW PROJECT FLOW (Steps 1–9)

### Step 1 — Classify category

Parse user prose. Assign exactly ONE:

- `landing-page` — single-page marketing (landing, promote, sell course, collect leads)
- `shop-online` — e-commerce (shop, sell, cart, checkout)
- `crm` — customer/lead management (CRM, manage customers, contact list)
- `blog` — content site (blog, posts, news)
- `dashboard` — admin/analytics (dashboard, admin, reports)
- `other` — fallback; ask more clarify Qs

### Step 1p — (Preset variant) Load preset instead

Valid preset names: `landing-page`, `shop-online`, `crm`, `blog`, `dashboard`.

If arg is empty, show the 5-item list and wait.
If name doesn't match, find closest (edit distance ≤2) and ask "Did you mean X?"
Read `presets/<name>.md`. Extract `Pre-filled intent`, `Pre-filled clarifications`, `Stack overrides`.
Write those into `.taw/intent.json` as `{category, raw, clarifications, stack_overrides, source: "preset"}`.
Skip Step 2 (clarify) — preset already answered — go to Step 3.

### Step 2 — Clarify (≤5 questions)

**If `mode == "yolo"`:** skip entirely. Emit `⚡ YOLO mode — dùng smart defaults.` Generate sensible defaults (project name, all sections on, deploy = vercel, contact form = email-only). Go to Step 3.

**If `mode == "safe"`:** Load `skills/taw/templates/clarify-questions.md`. Pick 3–5 Qs matching category. Ask in ONE message, numbered. WAIT for reply — even if user pasted images/URLs, user must explicitly answer (or say "default" / "mặc định").

Append answers to `.taw/intent.json` under `clarifications`.

### Step 3 — Render plan bullets

Load `skills/taw/templates/plan-bullet-format.md`. Generate 3–5 bullets covering: stack, pages/features, data model, deploy target, est. time.

**ALWAYS echo the plan as a code block** — both modes. User must SEE what's about to be built.

Write plan to `.taw/plan.md`.

### Step 4 — Approval gate

**If `mode == "yolo"`:** skip. Emit `⚡ YOLO — auto-approved, đang chạy...` Go to Step 5.

**If `mode == "safe"`:** emit EXACTLY:
```
Does this plan look good? (type: yes / edit / cancel)
```
WAIT. Do NOT spawn any agent until reply.

- `yes` / `ok` / `có` / `được` / `ừ` / `chạy đi` / `lam di` → Step 5
- `edit` / `sửa` → back to Step 2 with user edits
- `cancel` / `hủy` → write `{"status":"cancelled"}` to `.taw/checkpoint.json`, emit "Cancelled. Type /taw again when ready.", exit

**HARD RULE:** Even with rich context, safe mode MUST emit the prompt and wait. User trades 1 message for the right to course-correct before 5 minutes of work.

### Step 5 — Spawn agent chain

Use Task tool. Order FIXED. Each step waits for previous EXCEPT 5.2 (parallel researchers).

1. `planner` — input: `.taw/intent.json` + `.taw/plan.md`. Output: `plans/<timestamp>-<slug>/plan.md` + phase files. Before finalizing, planner MUST consult `frontend-design` skill to pick a BOLD aesthetic, distinctive typography, memorable visual point-of-view. Write chosen design tokens to `.taw/design.json`.
2. `researcher` × 2 IN PARALLEL — input: plan phase files. Output: research reports.

   **HOW to spawn parallel (CRITICAL — wrong way costs ~30s):** In ONE assistant message, emit TWO Task tool_use blocks back-to-back in the same `<function_calls>` parent. Harness fans both out concurrently. Spawning researcher #1, waiting, then #2 is sequential — FAILED requirement.

3. Dev agent — read `target` from `plans/<dir>/plan.md` frontmatter:
   - `target: web` → `fullstack-dev` (Next.js + Tailwind + shadcn + Supabase + Polar)
   - `target: mobile` → `mobile-dev` (Expo + Expo Router + NativeWind + Supabase RN + EAS)
   - `target: hybrid` → `fullstack-dev` first, then `mobile-dev` sequentially

   Input: research reports + plan + `.taw/design.json`. Output: scaffolded + implemented code, deps installed.
4. `tester` — runs `npm run build` + `npm run dev` smoke. Reports pass/fail.
5. `reviewer` — quick security/quality pass + UI check against `frontend-design` "anti-AI-slop" guidelines.

Between steps emit `✓ Done: <3-word summary>` (e.g. `✓ Done: plan ready`).

### Step 6 — Error recovery

On agent failure:
1. Compact error to ≤100 tokens
2. Retry SAME agent ONCE with error as extra input
3. If retry fails: write `.taw/checkpoint.json` with `{last_step, last_error, next_action: "run /taw with 'fix' request"}`, emit error template from `skills/taw/templates/error-messages.md`, stop

Never retry >1. Never silently skip.

### Step 7 — Deploy handoff

On Step 5 success, load `@branches/ship.md` (same `/taw` skill, internal branch switch). It returns a live URL.

If SHIP branch fails, emit: "Build xong rồi nhưng deploy lỗi. Gõ `/taw deploy` để thử lại." Stop — code still usable locally.

### Step 8 — Done

Emit EXACTLY:
```
Done! 🎉 Open: <live-url>
Project files: <project-path>
Want to add a feature? Type: /taw <feature description>
Something broken? Type: /taw fix
```

---

## ADD-FEATURE FLOW (Steps A1–A6) — lighter path

When `.taw/intent.json` already exists and user says "thêm X / add X", run this instead of the full Steps 1–9.

### Step A1 — Verify project context

- Read `.taw/intent.json` for category & existing state
- Read `package.json` for name + installed deps
- `git log --oneline -5` for recent history

If user args are empty: "Anh muốn thêm tính năng gì? Mô tả ngắn giúp em."

Store:
```json
{"project":"<name>","category":"<from intent>","feature_request":"<args>","recent_commits":["..."]}
```

### Step A2 — Clarify (≤3 Qs, lighter than new-project)

Ask at most 3 focused Qs. Skip entirely if self-evident (e.g. "add dark mode"). Examples:
- "Tính năng này nằm ở trang nào?"
- "Có cần lưu dữ liệu vào Supabase không?"
- "Có yêu cầu user phải đăng nhập không?"

Append to `.taw/intent.json` under `features[]`: `{"feature":"<req>","clarifications":{...}}`

### Step A3 — Mini-plan

Render 3–4 bullets:
```
Plan for this feature:
1. <file/component to create>
2. <any new dep to install>
3. <any Supabase table / env var>
4. Est. 5–10 minutes
```

Emit EXACTLY `Does this plan look good? (type: yes / edit / cancel)` and WAIT.

- `yes` → Step A4
- `edit` → back to A2 with edits
- `cancel` → "Cancelled. Type /taw <description> to try again." Stop.

Write to `.taw/add-plan.md`.

### Step A4 — Implement (scoped dev agent)

Spawn `fullstack-dev` (or `mobile-dev` if project target is mobile) via Task:
```
Task: Add a feature to an existing project.
Feature: <feature_request> | Clarifications: <JSON>
Rules: Only NEW files or APPENDS — NO rewrites of working code.
Scope: <files/dirs from Step A3 only>
Stack: <match project — Next.js App Router OR Expo Router>
If new Supabase table: write migration to supabase/migrations/
If new dep: run `npm install <pkg>`
End: run `npm run build`. Report pass/fail.
Context: app/, components/, lib/, .taw/intent.json
```

Emit: "Đang thêm tính năng... (chờ vài phút)"

### Step A5 — Verify build

```bash
npm run build 2>&1 | tail -20
```

- Exit 0 → Step A6
- Non-zero → "Build bị vỡ sau khi thêm. Đang thử fix..." and load `@branches/fix.md` automatically with error output

### Step A6 — Commit and done

Invoke `git-auto-commit` skill:
```
type=feat, scope=<inferred>, subject=<feature slug in simple EN>
(no [P<n>] tag — add-feature is out-of-phase)
```

Emit:
```
Đã thêm: <feature name>
Files changed: <git diff --stat HEAD~1>
Want to deploy? Type: /taw deploy
Want to add more? Type: /taw <description>
```

Append to `.taw/intent.json` → `features[]`: `{"feature":"...","status":"done"}`.

---

## Constraints (both flows)

- User-visible strings: match user's input language (VN default for VN users). Internal reasoning: English.
- Single approval gate per flow (Step 4 for new / Step A3 for add). Do NOT add more user prompts mid-agent-chain unless blocking.
- Default stack: Next.js 14 App Router + Tailwind + shadcn/ui + Supabase + Polar. Deploy = Vercel default.
- If context grows past 150k tokens during agent chain: compact via `.taw/artifacts/` on disk and summarize.
- State files in `.taw/` (gitignored). NEVER write API keys/tokens/secrets into `.taw/`.
- Add-feature scope: ONLY `app/`, `components/`, `lib/`, `supabase/migrations/`. Never touch `next.config.js` / `tailwind.config.ts` without explicit approval.
- If add-feature touches auth: ask "Tính năng này cần đụng auth — anh chắc không?" require `yes`.
