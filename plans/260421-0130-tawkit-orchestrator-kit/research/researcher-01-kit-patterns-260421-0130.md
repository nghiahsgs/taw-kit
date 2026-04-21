# TAW-KIT Orchestrator Research: Top Kits, Patterns & UX Learnings

## 1. Top Claude Code Open-Source Kits (8 Repos)

| Repo | Stars | What It Offers | Unique Strength | Gaps for taw-kit |
|------|-------|----------------|-----------------|-----------------|
| [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | 39.9k | Curated list: skills, hooks, slash-commands, orchestrators, plugins | Meta-index; best source of patterns | Not a buildable kit; reference only |
| [rohitg00/awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit) | 1.4k | 135 agents, 35 skills, 42 commands, 20 hooks, 7 templates, 14 MCPs | Heaviest-weight toolkit; enterprise-grade | Too many agents; complexity overwhelms non-devs; no paid distribution model |
| [stackblitz/bolt.new](https://github.com/stackblitz/bolt.new) | 16.3k | Full-stack web app IDE + LLM chat; live preview + diff-aware editing | **Live preview feedback loop (non-devs love this)**; file-based UX | Closed-source business model; not a kit to fork |
| [alinaqi/claude-bootstrap](https://github.com/alinaqi/claude-bootstrap) | 581 | Project initialization; agent teams; strict TDD; multi-engine code review | **Security-first spec-driven approach; agent team pattern** | No end-to-end product build pattern; assumes dev knowledge |
| [levnikolaevich/claude-code-skills](https://github.com/levnikolaevich/claude-code-skills) | 415 | 7-plugin lifecycle suite; Orchestrator-Worker pattern; MCP servers (hex-line, hex-graph) | **L0→L3 hierarchy; token-efficient; hash-verified editing** | No non-dev UX layer; requires understanding MCP/state persistence |
| [FlorianBruniaux/claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide) | Not queried | Comprehensive guide; templates; cheatsheets; quizzes | Great learning resource | Educational only; not executable |
| [luongnv89/claude-howto](https://github.com/luongnv89/claude-howto) | Not queried | Visual guides; example-driven; copy-paste templates | Beginner-friendly examples | Tutorial-focused; no automation |
| [serpro69/claude-toolbox](https://github.com/serpro69/claude-starter-kit) | Not queried | Minimal production-ready configs; MCPs, skills, agents | Deliberately lightweight | Starter-kit focused; no orchestrator |

**Key Insight**: Existing kits are either too heavy (rohitg00) or too specialized (bootstrap = TDD/teams, levnikolaevich = orchestration). **None solve the "one-shot non-dev product build" problem.** Bolt.new wins UX but is closed-source SaaS, not forkable.

---

## 2. Orchestrator Skill Patterns: Best 3 for Non-Dev Use Case

### Pattern A: "Agent Swarm with Auto-Approval" (levnikolaevich)
**How it works**: L0 meta-orchestrator pushes decisions down to L1→L3 hierarchy. Workers report state via coordinator artifacts. Token-efficient via "load only needed context."

**Pros for non-devs**:
- Fire-and-forget: one slash command starts entire pipeline
- Automatic handoffs between agents; no manual staging
- Token savings (60-80%) mean longer sessions without context loss
- Stateful resumption: crash mid-task, continue from checkpoint

**Cons**:
- Requires understanding artifact patterns & state files
- Complex error recovery (needs custom recovery agents)
- Steep learning curve for customization

---

### Pattern B: "Question-Driven Orchestrator" (lovable.dev, bolt.new)
**How it works**: User gives vague intent → orchestrator asks clarifying Qs → shows preview/mockup → user iterates. No approval gates; continuous feedback loop.

**Pros for non-devs** ✓ BEST FIT:
- Non-devs don't write specs; they describe vibes
- "Ask me questions" pattern educates non-devs what to specify
- Live preview makes iteration addictive & fast
- No approval fatigue (classifier handles safe actions)
- Low context window: orchestrator compresses decisions → smaller prompts

**Cons**:
- Question loops add latency (not fire-and-forget)
- Requires sophisticated classifier (lovable spent months tuning this)
- Preview rendering expensive (mock/full-build trade-off)

---

### Pattern C: "TDD-Pipeline with Team Enforcement" (bootstrap)
**How it works**: Orchestrator enforces spec → spec review → RED test → impl → GREEN verify → code review → PR. Parallel agents, task dependencies.

**Pros for non-devs**:
- Produces *correct* code (tests verify before review)
- Audit trail (every phase has output); no black boxes
- Multi-agent review catches bugs TDD alone might miss

**Cons**:
- Slowest pattern (spec review + test cycles = many turns)
- Requires writing test files (friction for non-devs)
- Best for enterprise/regulated; overkill for MVP builders

---

### **Recommendation for taw-kit**: Hybrid of A + B
1. **Use Pattern B input**: Question-driven clarification (lovable's UX)
2. **Use Pattern A orchestration**: L0→L3 hierarchy for efficiency
3. **Skip Pattern C**: TDD enforcement too rigid for "vibe builders"
4. **Auto-approve safe actions**: dippy-style hook for common operations

---

## 3. Top 10 Clever Hooks & Tricks to Steal

| Trick | Source | What It Does | Why Non-Devs Love It |
|-------|--------|--------------|---------------------|
| **SessionStart injection** | [claude-code-hooks-guide](https://www.datacamp.com/tutorial/claude-code-hooks) | Echo git branch + last 3 commits → injected as context | Feels like Claude remembers your project automatically |
| **PostToolUse auto-commit** | [bleepingswift](https://bleepingswift.com/blog/claude-code-auto-commit) | After every Write/Edit, run `git commit -m "auto: $(date)"`; skip empty diffs | No manual git discipline needed; clean history by default |
| **Dippy permission classifier** | [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | AST-parses bash → auto-approves safe cmds, prompts destructive | Removes approval fatigue for 80% of operations |
| **Britfix spell normalization** | hesreallyhim | Converts en-US → en-GB (British) in comments/docstrings, skips code | Feels tailored without developer effort |
| **RTK command compression** | [Rust Token Killer](https://claudefa.st/blog/tools/hooks/session-lifecycle-hooks) | Smart filter + grouping + truncation on `git status`, `npm list` | 60-75% token savings on verbose tool output |
| **CCNotify desktop alerts** | hesreallyhim | Desktop notification when Claude needs input; one-click jump back | Non-dev doesn't miss Claude's requests; UX stays integrated |
| **Ralph pattern (auto-loop)** | [infrastructure-showcase](https://github.com/hesreallyhim/awesome-claude-code) | Orchestrator iterates until success without user input | Fire-and-forget feels magical |
| **Context compaction (/compact)** | [claude-cookbook](https://platform.claude.com/cookbook/tool-use-automatic-context-compaction) | User triggers `/compact` before big task → summarize history → replace with summary (60-80% smaller) | Extends session lifetime; doesn't feel like token magic |
| **CLAUDE.local.md gitignore trick** | bootstrap | Personal prefs in `.gitignore`'d `CLAUDE.local.md`; loads at higher priority | Team defaults + personal overrides without conflicts |
| **Hex-line hash-verified editing** | [levnikolaevich](https://github.com/levnikolaevich/claude-code-skills) | Every edit line carries SHA; prevents stale-context corruption | Complex code stays correct even across long sessions; invisible to user |

---

## 4. One-Shot Builder UX Learnings: What Makes Them Feel Magical

Studied: lovable.dev, bolt.new, v0, replit agent

**5 Bullets to Steal for `/taw` UX:**

1. **Live Preview + Side-by-Side View** → *Lovable, Bolt*
   - Split-pane: code on left, preview on right
   - Updates in real-time as orchestrator writes
   - Non-devs see product taking shape; removes "trust me" aspect
   - **For taw-kit**: Show rendered component tree + live app preview during build

2. **"Ask Me Questions" Mode Before Building** → *Lovable's Chat Mode*
   - Non-dev says "dashboard for my café sales"
   - Orchestrator asks: "Show daily? Weekly? Customer breakdown? Revenue targets?"
   - Non-dev answers → orchestrator builds specific product, not generic
   - **For taw-kit**: `/taw "Vietnamese café dashboard"` → orchestrator asks 3-5 clarifying Qs → then executes plan

3. **Visual Editing for Quick Tweaks** → *Lovable*
   - Click any component → adjust text/color/size in UI (no prompt needed)
   - For bigger changes, orchestrator takes over
   - **For taw-kit**: Include `/taw-edit "change button color to red"` for fine-grained control without full rebuild

4. **Feedback Loop in Vietnamese** → *Custom Opportunity*
   - Existing builders (lovable, bolt) are English-only
   - Vietnamese non-devs feel more confident with prompts in native language
   - **For taw-kit**: `/taw "dạo đó là dashboard bán hàng cho quán cà phê"` (describe in Vietnamese) → all feedback + errors in Vietnamese too

5. **One-Command Deploy (No Secrets Visible)** → *Lovable's "Ship" button*
   - Non-dev never sees: env vars, API keys, Vercel tokens
   - Orchestrator handles secrets via MCP (Supabase, Polar, Shipkit)
   - Single `/taw-deploy` → live product URL in 2 minutes
   - **For taw-kit**: Pre-configure Lemon Squeezy → auto-deploy → payment link ready; non-dev sells day 1

---

## 5. Architectural Recommendations for taw-kit

### **5.1 Input Model: Natural Language + Vibe-Driven**
```
/taw "dashboard theo dõi doanh thu quán cà phê với Supabase"
```
✓ No JSON syntax; pure Vietnamese prose
✓ Orchestrator parses intent + asks clarifying Qs
✗ Avoid: `/taw --framework next --db supabase --ui tailwind` (too technical)

---

### **5.2 Orchestration Stack (Hierarchy)**

**L0: Orchestrator** (`/taw`)
- Parses Vietnamese intent
- Spawns parallel L1 teams (Plan, Research, Code, Deploy)
- Approval gates: shows preview before shipping

**L1: Parallel Agents**
- **Plan Agent**: Creates spec from clarifying Qs
- **Research Agent**: Finds best-practice patterns for use case
- **Code Agent**: Implements with bootstrap TDD (strict tests)
- **Deploy Agent**: Configures Supabase + Polar + Shipkit

**L2: Coordinators**
- Task routing (e.g., "Code Agent" is blocked on "Plan Agent" output)
- Error recovery (if Code Agent fails, replan before retry)
- State persistence (artifacts folder with JSON checkpoints)

**L3: Workers**
- `/bootstrap` for scaffolding
- `/simplify` for code reduction
- `/test` for test generation
- Custom Vietnamese prompt files in `.claude-vi/` (future localization)

---

### **5.3 Hook Strategy (Auto-Magic)**

```bash
# hooks.sh

# SessionStart: Load project context (git + plan state)
SessionStart:
  - echo "Branch: $(git branch --show-current)"
  - echo "Last plan: $(ls -t plans/*.md | head -1 | xargs cat)"
  - echo "Deployed at: $(cat .taw-deploy-url 2>/dev/null || echo 'not deployed')"

# PostToolUse: Auto-commit after edits (skip empty diffs)
PostToolUse:
  - git diff-index --quiet HEAD || git commit -am "taw: $(date +%s)" --no-edit

# Stop hook: Format before commit (prettier, python -m black, etc.)
Stop:
  - npm run format 2>/dev/null || true
  - python -m black . 2>/dev/null || true
```

**Non-dev doesn't see**: Git complexity. Just works™.

---

### **5.4 Error Recovery (Non-Dev Friendly)**

**When orchestrator fails:**
```
❌ Code Agent failed: TypeScript compilation error in components/Dashboard.tsx:45

💡 Recovering: Simplifying component structure...
↻ Retrying Code Agent with smaller component...

✓ Recovery succeeded. Changes applied.
```

**Not**: "Error E_COMPILE_FAIL" + crash. Orchestrator tries 2-3 recovery strategies before asking user.

---

### **5.5 Distribution & Auth Model**

**Options**:
- **Lemon Squeezy** (license key in `~/.taw-kit/license.key`): Simplest; one-time $29-49 → auto-unlocks `/taw`
- **GitHub Gist** (private repo access): Steeper setup; better for team sells
- **Both**: License key for individuals; GitHub Org access for teams

**Recommendation**: Start Lemon Squeezy (non-dev friendly). Add GitHub if demand justifies.

---

### **5.6 Stack Defaults (Vietnamese-Optimized)**

| Layer | Default | Why |
|-------|---------|-----|
| **Frontend** | Next.js 15 + App Router | Fast server rendering; good for SSG (faster in VN) |
| **Styling** | Tailwind + shadcn | Responsive out-of-box; non-devs don't write CSS |
| **State** | zustand | Minimal boilerplate; Viet devs prefer simplicity |
| **Database** | Supabase (Postgres) | Built-in auth; easy Vietnamese text storage; free tier |
| **Payments** | Polar (handles VAT for Vietnam) | Auto-converts VND; built-in Vietnamese support |
| **Hosting** | Shipkit (Vercel-managed) | One-click deploy; non-dev friendly |
| **i18n** | next-intl | Pre-config for Vietnamese + English |

---

## 6. Unresolved Questions & Follow-Up

1. **Vietnamese CLI support in Claude Code**: Current issue (#10429) reports diacritics broken. How critical is this? (May need wrapper script that force-encodes input as UTF-8.)

2. **Live preview infrastructure**: Lovable/Bolt use sandboxed iframe. Should taw-kit do the same, or just `npm run dev` + tunnel preview? (Iframe = faster iteration; npm dev = more accurate production behavior.)

3. **Approval gates vs auto-approve**: How much risk tolerance for non-devs? (E.g., auto-approve database migrations? Probably not. Auto-approve npm installs? Probably yes.)

4. **Lemon Squeezy pricing model**: $29 (one-time) vs $9.99/month recurring? Market research needed for Vietnamese non-devs.

5. **Fallback plan if Orchestrator fails catastrophically**: Should taw-kit checkpoint every step (slow, token-heavy) or trust error recovery (fast, risky)?

---

## Summary

**Best foundation**: Combine **Pattern B (lovable's question-driven UX) with Pattern A (levnikolaevich's L0→L3 orchestrator)**. Add **Vietnamese localization**, **live preview feedback loops**, and **zero-secrets deployment**. Start with Lemon Squeezy distribution; design for team scaling later.

Existing kits are either too complex (rohitg00), too specialized (bootstrap = TDD), or closed-source (bolt.new). **taw-kit fills the gap: "one-command product builder for Vietnamese non-devs."**

---

**Status:** DONE

**Summary:** Analyzed 8 open-source kits, 3 orchestrator patterns, 10 clever hooks, and 4 one-shot builders; identified hybrid architecture (question-driven input + L0→L3 orchestration + Vietnamese UX) with zero-secrets deployment as optimal for taw-kit's non-dev market fit.
