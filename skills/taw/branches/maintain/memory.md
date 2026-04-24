# maintain: memory

Generate and maintain `CLAUDE.md` (root + nested per-module) so Claude Code has persistent repo memory across sessions. Uses marker comments to preserve user hand-edits while auto-refreshing "facts" sections after every /taw change.

**Prereq:** router classified `tier2 = memory`.

**Philosophy:** large repos burn tokens re-discovering structure each session. CLAUDE.md is the native Claude Code mechanism for persistent context (auto-loaded at session start, nested ones merge when working in subdirs). taw-kit's job: keep it honest automatically so it never goes stale.

## Subcommands

Parse `$ARGS` — first word is subcommand:

| Subcommand | Purpose |
|---|---|
| `init` (default) | Create CLAUDE.md if missing. Scan repo, generate all auto sections. |
| `update` | Refresh only the `taw:auto:*` marker sections from current state. Preserve user edits. |
| `check` | Compare code state vs CLAUDE.md claims. Report drift. Read-only. |
| `refresh` | Destructive regen. Backup existing → regenerate from scratch. Ask twice. |
| `nest <path>` | Create nested CLAUDE.md for a specific module (e.g. `src/billing/`). |

Empty args = `init` if no CLAUDE.md, else `update`.

## Step 0 — Preflight

```bash
# Is this a git repo?
git rev-parse --show-toplevel 2>/dev/null || { echo "taw-kit: cần git repo để gen CLAUDE.md"; exit 1; }

# How big is this thing?
TOTAL_FILES=$(find . -type f -not -path './node_modules/*' -not -path './.git/*' -not -path './.next/*' -not -path './dist/*' 2>/dev/null | wc -l | tr -d ' ')
TOTAL_LOC=$(find . -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' -o -name '*.py' -o -name '*.go' -o -name '*.rb' \) -not -path './node_modules/*' -not -path './dist/*' 2>/dev/null | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')
echo "taw-kit: repo có $TOTAL_FILES files, $TOTAL_LOC LOC"
```

If TOTAL_LOC > 100,000 → emit "taw-kit: repo lớn ($TOTAL_LOC LOC) — CLAUDE.md sẽ tiết kiệm cực nhiều token mỗi session. Bắt đầu scan..."

## Step 1 — `init` flow (when no CLAUDE.md exists)

### Step 1a — Gather signals (smart sampling, not exhaustive read)

```bash
# 1. Stack from package.json
node -e "const p=require('./package.json'); console.log(JSON.stringify({name:p.name,version:p.version,scripts:p.scripts,deps:Object.keys({...p.dependencies,...p.devDependencies}).sort()},null,2))" 2>/dev/null > /tmp/taw-mem-stack.json

# 2. Top-level dirs (depth 2)
find . -maxdepth 2 -type d -not -path '.' -not -path './.git*' -not -path './node_modules*' -not -path './dist*' -not -path './.next*' -not -path './.taw*' -not -path './.claude*' 2>/dev/null | sort > /tmp/taw-mem-dirs.txt

# 3. Existing README + root docs
ls *.md 2>/dev/null > /tmp/taw-mem-docs.txt

# 4. Recent commit activity (what's being worked on)
git log --since='30 days ago' --pretty=format:'%s' 2>/dev/null | head -50 > /tmp/taw-mem-commits.txt

# 5. Hot folders (most edited in last 90 days)
git log --since='90 days ago' --name-only --pretty=format: 2>/dev/null | command grep -v '^$' | awk -F/ '{print $1"/"$2}' | sort | uniq -c | sort -rn | head -15 > /tmp/taw-mem-hot.txt

# 6. Schema / migrations (if DB-oriented)
ls supabase/migrations/*.sql prisma/schema.prisma prisma/migrations/ drizzle/ db/migrations/ 2>/dev/null | head -10 > /tmp/taw-mem-db.txt

# 7. Sample 10 route handlers for convention detection
find . -type f \( -name 'route.ts' -o -name 'controller.ts' -o -name '*.controller.ts' \) -not -path './node_modules/*' 2>/dev/null | head -10 > /tmp/taw-mem-routes.txt

# 8. CI / deployment hints
ls Dockerfile docker-compose.yml vercel.json .github/workflows/*.yml bitbucket-pipelines.yml .gitlab-ci.yml 2>/dev/null > /tmp/taw-mem-ci.txt
```

### Step 1b — Infer conventions (read sampled routes)

For up to 5 files from `/tmp/taw-mem-routes.txt`, read and look for patterns:
- Response shape: `return { ok: true, data }` vs `return { success, payload }` vs `res.json(...)`
- Error handling: try/catch + return error, throw, next(err), custom Error class
- Input validation: Zod, Joi, Yup, class-validator, manual
- Auth check: middleware `requireAuth()`, guard decorator, inline `getUser()`
- Logging: console.log, pino, winston, custom logger

Capture as short facts (≤1 sentence each).

### Step 1c — Write CLAUDE.md

Template (use marker comments so future `update` only touches auto sections):

```markdown
# {Project name}

> {1-sentence description from package.json or inferred from top-level folders}

<!-- User-editable intro section. taw-kit only updates content between taw:auto:* markers below. -->

## Stack

<!-- taw:auto:stack -->
- Runtime: Node.js {version from engines} / {TypeScript | JavaScript}
- Framework: {Next.js 14 App Router | Express | Fastify | ...}  (inferred from deps)
- DB: {Postgres (Supabase) | Prisma | Drizzle | MongoDB | ...}
- Auth: {Supabase Auth | Clerk | NextAuth | custom JWT | ...}
- Payment: {Stripe | Polar | ...}  (if applicable)
- Deploy: {Vercel | GCP | Docker | ...}
<!-- /taw:auto:stack -->

## Commands

<!-- taw:auto:scripts -->
{One line per relevant script from package.json, in priority order: dev, build, start, test, lint, migrate, seed, deploy}
<!-- /taw:auto:scripts -->

## Architecture

<!-- taw:auto:architecture -->
Top-level folders (updated after every /taw run):

{tree-style list of top 15 folders, each with 1-line description inferred from:
 - folder name itself
 - first file in folder (often a README or index)
 - git commit patterns touching it}

Hot areas (most-edited last 90 days):
1. {folder} — {N commits}
2. ...
<!-- /taw:auto:architecture -->

## Conventions (MUST follow)

<!-- taw:auto:conventions -->
{Inferred from sampled routes — 3-6 bullets, high-confidence only}

Example:
- Route handlers return `{ ok: true, data }` on success, `{ ok: false, error: { code, message } }` on failure
- Input validation via Zod in `src/schemas/`
- Error codes use enum in `src/errors/codes.ts`
- Soft-delete pattern: `deleted_at` timestamp, never `DELETE FROM`
<!-- /taw:auto:conventions -->

<!-- User-owned section below. taw-kit will NEVER modify this. Add your own rules here. -->

### Additional conventions (user-maintained)

<!-- Add project-specific rules taw-kit can't infer -->

## Gotchas

<!-- User-owned. taw-kit appends to "Known issues (taw)" section below — never touches this section. -->

<!-- User adds: subtle bugs, historical decisions, "why we did X the weird way" -->

## Known issues (taw)

<!-- taw:auto:fix-gotchas -->
_Auto-updated after each `/taw fix`. Each entry = root cause + prevention hint._

{Empty at init. Populated over time.}
<!-- /taw:auto:fix-gotchas -->

## Related docs

<!-- taw:auto:docs -->
{One line per *.md file at root that looks like documentation — link + 1-line inferred summary}

Example:
- [DEPLOYMENT.md](./DEPLOYMENT.md) — production deploy to GCP
- [CORRELATION_ID_COMPLETE.md](./CORRELATION_ID_COMPLETE.md) — request tracing system
<!-- /taw:auto:docs -->

## Features added via taw-kit

<!-- taw:auto:features -->
_Auto-updated after each `/taw add-feature`. Append-only log._

{Empty at init. Each entry: date + feature name + affected files.}
<!-- /taw:auto:features -->

---

<!-- taw:auto:footer -->
_taw-maintained. Last update: {ISO timestamp}. Sections between `<!-- taw:auto:* -->` markers are auto-generated — edit freely outside markers._
_Generated by taw-kit v{VERSION}_
<!-- /taw:auto:footer -->
```

Write this to `CLAUDE.md` at repo root.

### Step 1d — Auto-commit + 1-line result

Init is SAFE (new file, no code change) → **auto-commit immediately, don't ask**.

```bash
git add CLAUDE.md
```

Invoke `taw-commit`:
```
type=docs, scope=memory, subject="init CLAUDE.md (stack+architecture+conventions)"
```

Emit 1-line result:
```
taw: CLAUDE.md tạo xong — {N} dòng, {M} auto sections. Committed.
```

DO NOT propose next-steps. User sẽ ask nếu cần.

## Step 2 — `update` flow (CLAUDE.md already exists)

### Step 2a — Read current CLAUDE.md

```bash
cat CLAUDE.md > /tmp/taw-mem-current.md
```

Parse marker sections: find all `<!-- taw:auto:X -->` ... `<!-- /taw:auto:X -->` blocks.

### Step 2b — Regenerate ONLY marker blocks

For each marker block found, regenerate its content from current state:
- `taw:auto:stack` — re-read `package.json`
- `taw:auto:scripts` — re-read `package.json` scripts
- `taw:auto:architecture` — re-scan dirs + hot-folders git log
- `taw:auto:conventions` — re-sample routes (only if >90 days since last update OR user forces)
- `taw:auto:fix-gotchas` — append new entries since last update
- `taw:auto:docs` — re-scan `*.md` at root
- `taw:auto:features` — append new entries from `.taw/intent.json` `features[]`
- `taw:auto:footer` — update timestamp

### Step 2c — Auto-commit + show 1-line diff summary

Docs updates are SAFE (no code change, markers-only) → **auto-commit immediately, don't ask**. Per Autonomy principle in `skills/taw/SKILL.md`.

```bash
# only stage CLAUDE.md (not user's working dir)
git add CLAUDE.md
```

Invoke `taw-commit`:
```
type=docs, scope=memory, subject="update CLAUDE.md ({N} sections)"
```

Emit EXACTLY 1-line result:
```
taw: CLAUDE.md updated — {N} sections ({list}). Committed.
```

DO NOT propose "bước tiếp" / "commit không?" / "nest chatbot?" — user didn't ask. If they want next action, they'll say.

Diff details: `git diff HEAD~1 CLAUDE.md` — user can check themselves.

## Step 3 — `check` flow (drift detection, read-only)

Compare code state vs CLAUDE.md claims:

1. **Stack drift**: CLAUDE.md claims Next 14, package.json shows 15 → flag
2. **Folder drift**: CLAUDE.md architecture mentions `src/payments/`, folder doesn't exist → flag
3. **Scripts drift**: `npm run migrate` in CLAUDE.md, not in package.json → flag
4. **Convention drift**: CLAUDE.md says "Zod validation", recent routes use Yup → flag (lower confidence)

Render:
```
taw-kit: CLAUDE.md drift check

⚠️ 3 drifts phát hiện:
  1. Stack: "Next 14" → thực tế 15.0.1
  2. Folder: "src/payments/" trong architecture nhưng folder không tồn tại
  3. Script: "npm run migrate" doc nhưng package.json không có

✓ 8 sections đồng bộ

Gõ `/taw memory update` để auto-fix drift ở các section có marker.
```

## Step 4 — `refresh` flow (destructive)

```
taw-kit: REFRESH sẽ ghi đè TOÀN BỘ CLAUDE.md hiện tại.
  User edits ngoài marker cũng sẽ MẤT.
  Đã backup → CLAUDE.md.bak.{timestamp}

Anh chắc chưa? Gõ `yes, refresh` (đúng chữ) để tiếp tục.
```

Require exact text. On confirm:
```bash
cp CLAUDE.md CLAUDE.md.bak.$(date +%Y%m%d-%H%M%S)
```

Then run Step 1 as if init.

## Step 5 — `nest <path>` flow (per-module CLAUDE.md)

```bash
TARGET="${1:?taw-kit: cần path vd: /taw memory nest src/billing}"
[ -d "$TARGET" ] || { echo "taw-kit: folder $TARGET không tồn tại"; exit 1; }
```

Check if module deserves nested CLAUDE.md:
- Has ≥10 files AND ≥3 commits in last 90 days?
- Or user explicitly asked

Gather module-specific signals:
```bash
# Module files (depth 2)
find "$TARGET" -maxdepth 2 -type f \( -name '*.ts' -o -name '*.tsx' \) 2>/dev/null | head -20

# Module commits
git log --since='90 days ago' --pretty=format:'- %s' -- "$TARGET" | head -20

# Exported symbols (quick sample)
command grep -l 'export ' "$TARGET"/*.{ts,tsx} 2>/dev/null | head -5
```

Write `{TARGET}/CLAUDE.md`:
```markdown
# {Module name} module

> {1-line purpose inferred from folder name + file names}

<!-- taw-kit nested memory for {path}. Main context is repo root CLAUDE.md. -->

## Key files
<!-- taw:auto:files -->
- `{file}` — {1-line inferred purpose}
- ...
<!-- /taw:auto:files -->

## Business rules

<!-- User-owned. Add module-specific invariants here. -->

## Recent activity
<!-- taw:auto:activity -->
Last 20 commits touching this module:
- {commits list}
<!-- /taw:auto:activity -->

## Edge cases
<!-- User-owned -->

---
<!-- taw:auto:footer -->
_nested CLAUDE.md, taw-maintained. Last update: {ISO}_
<!-- /taw:auto:footer -->
```

## Step 6 — Auto-hook into other branches (opt-in, default on)

Other /taw branches call memory update at their Done step:

| Calling branch | When to call | Which section to update |
|---|---|---|
| `branches/build.md` | After Step A6 (add-feature done) | `taw:auto:features` (append), `taw:auto:architecture` |
| `branches/fix.md` | After Step 6 (fix done) | `taw:auto:fix-gotchas` (append root cause) |
| `branches/maintain/upgrade.md` | After commit | `taw:auto:stack` |
| `branches/maintain/stack-swap.md` | After commit | `taw:auto:stack`, `taw:auto:conventions` |
| `branches/maintain/refactor.md` | After commit (if paths changed) | `taw:auto:architecture` |

Invocation pattern (inside calling branch):
```
Skill({ skill: "taw", args: "memory update" })
```

Controlled by `.taw/config.json`:
```json
{ "auto_update_memory": true }
```

User can disable: `/taw memory off`, re-enable: `/taw memory on`.

## Step 7 — Auto-commit (already done in Step 1d / 2c / 5)

All memory subcommands (init / update / nest) auto-commit at their own Done step. This step is kept as reference — DO NOT ask for commit approval separately. Docs changes are safe by default.

`refresh` (destructive regen) is the ONLY exception — it creates a `.bak` but the user already confirmed the destructive action at Step 4, so commit the new CLAUDE.md without re-asking.

## Constraints

- **NEVER touch content outside `<!-- taw:auto:X -->` markers** — user owns everything else
- **Marker comments are sacred** — deleting one strands the content (future updates skip it)
- **Smart sampling for large repos** — NEVER read all files. Cap: 10 routes + 15 folders + 50 commits
- **Budget**: init <60s, update <10s, check <5s, nest <20s per module
- **Don't create nested CLAUDE.md speculatively** — only for modules meeting the "hot + large" bar
- **Respect `.gitignore`** — never reference ignored paths
- **Treat `.taw/`, `.claude/`, `node_modules/`, `.next/`, `dist/`, `build/` as invisible** — never in architecture section
- **Backup before refresh** — `CLAUDE.md.bak.{ts}` preserved for 7 days, then `/taw clean` removes
- **Don't leak secrets** — scan generated content for .env keys or token patterns before write
- **AUTONOMY — do NOT ask "commit không?" / "bước tiếp?"** — auto-commit safe docs changes per Autonomy principle in SKILL.md. Output 1-line done, no menu of suggestions.
- **Suggestions only at user request** — never proactively propose `nest X` / `refresh` / `check` at end of a run. User asks, user gets.
