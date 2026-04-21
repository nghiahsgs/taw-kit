# Phase 03 — Core `/taw` Orchestrator Skill

## Context Links
- Phase 01, 02 (block this)
- Research: `research/researcher-01-kit-patterns-260421-0130.md` §2 (Pattern A+B hybrid), §4 (UX learnings), §5.2, §5.4
- Research: `research/researcher-02-vn-market-260421-0224.md` §4 (UX expectations #1–7)

## Overview
- **Priority:** P1 (critical path — demo-gating)
- **Status:** pending
- **Effort:** ~10h
- **Description:** Write the one skill that defines taw-kit. `/taw <Vietnamese prose>` → clarify → plan → research → code → test → deploy → live URL.

## Key Insights
- Hybrid: **Pattern B input** (question-driven clarify) + **Pattern A orchestration** (L0→L3 spawning via agents).
- Single approval gate (not per-step) per user spec — shown AFTER plan bullets, BEFORE execution. Avoids approval fatigue but keeps user in control.
- Vietnamese-first: the SKILL.md can be English (Claude reads it better), but every user-visible string `/taw` emits MUST be Vietnamese.
- Error recovery = 2 retry attempts max before escalating to user with Vietnamese-friendly explanation. Do NOT crash silently.

## Requirements
**Functional**
1. Parse arbitrary Vietnamese input after `/taw`.
2. Ask 3–5 clarifying questions in Vietnamese (e.g. "Bạn muốn dùng tên miền riêng hay subdomain miễn phí?").
3. Produce 3–5 bullet plan in Vietnamese.
4. Prompt: "Kế hoạch này OK? (yes/sửa/hủy)".
5. On `yes`: spawn agents in sequence: `planner` → `researcher` (parallel N=2) → `fullstack-dev` → `tester` → `reviewer` → `taw-deploy`.
6. On `sửa`: re-enter clarification loop.
7. On `hủy`: exit cleanly.
8. Report progress in Vietnamese after each agent: "✓ Đã xong: nghiên cứu framework".
9. End with live URL + "Xong! Truy cập: <url>" + Polar/MoMo payment block link.
10. On error: retry once; if retries exhausted, emit Vietnamese error + propose `/taw-fix`.

**Non-functional**
- End-to-end happy path < 20 min on claude opus.
- SKILL.md ≤ 200 lines (can be pushed to 250 if orchestration truly needs it).
- No network calls from SKILL.md itself — only via Task() subagent dispatch.

## Architecture

**Data flow:**
```
User: /taw "trang bán cà phê online"
  │
  ▼
[taw SKILL.md] loaded as system prompt
  │
  ▼
Step 1: Classify intent
  - landing page | shop | dashboard | blog | crm | other
  - If ambiguous → go Step 2
  │
  ▼
Step 2: Clarify (≤5 Qs in VN)
  - stack overrides? DB? auth? payment? domain?
  │
  ▼
Step 3: Render plan bullets (VN)
  - "1. Setup Next.js + Supabase"
  - "2. Build 4 pages: home, menu, checkout, thanks"
  - ...
  - Prompt: "OK? (yes/sửa/hủy)"
  │
  ▼ (yes)
Step 4: Spawn agents via Task tool
  - Task(planner)    → plans/plan.md + phase-*.md
  - Task(researcher) × 2 parallel → docs
  - Task(fullstack-dev) → write code, run npm install
  - Task(tester) → npm run build, npm run dev; report errors
  - Task(reviewer) → security quick-check
  │
  ▼ (on any failure)
  Retry once with error context; if still fails:
  - Save checkpoint to `.taw/checkpoint.json`
  - Emit VN error + "Chạy lệnh /taw-fix để thử sửa"
  │
  ▼ (success)
Step 5: Invoke /taw-deploy skill (phase 04)
  │
  ▼
Step 6: Echo "Xong! Truy cập: <url>"
```

**State files (written by `/taw`, read by `/taw-fix`, `/taw-add`):**
- `.taw/intent.json` — classified intent + clarifications
- `.taw/plan.md` — approved plan bullets
- `.taw/checkpoint.json` — {last_step, last_error, artifacts_written}

**Token efficiency:**
- Clarification Qs loaded as a static VN template in SKILL.md, not re-generated per call.
- Agent outputs compressed to "✓ done: <3-word summary>" before next agent spawn.

## Related Code Files
**Create:**
- `skills/taw/SKILL.md` (the core file; ~200 lines)
- `skills/taw/templates/clarify-questions.md` (VN question bank, loaded by SKILL.md)
- `skills/taw/templates/plan-bullet-format.md` (VN plan rendering template)
- `skills/taw/templates/error-messages.md` (VN error strings)

**Modify:** `skills/taw/SKILL.md` frontmatter (stubbed in phase 02).

**Delete:** none.

## Implementation Steps
1. Draft SKILL.md frontmatter:
   ```
   ---
   name: taw
   description: One-shot Vietnamese orchestrator — turn prose into a shipped product.
   allowed-tools: Task, Read, Write, Edit, Bash, Glob, Grep
   ---
   ```
2. Write "Invocation" section: when user types `/taw <text>`, parse text.
3. Write "Step 1: Intent classification" — 6 categories, fall back to `other`.
4. Write "Step 2: Clarify" — load `templates/clarify-questions.md`, pick 3–5 matching intent.
5. Write "Step 3: Plan bullets" — render 3–5 VN bullets using `templates/plan-bullet-format.md`.
6. Write "Step 4: Approval gate" — exact prompt string: `"Kế hoạch này có OK không? (gõ: yes / sửa / hủy)"`.
7. Write "Step 5: Execute" — pseudocode Task() dispatches with explicit agent names + inputs.
8. Write "Step 6: Error recovery" — single retry with error context; on 2nd fail → checkpoint + VN message.
9. Write "Step 7: Deploy handoff" — invoke `/taw-deploy` via skill reference.
10. Write "Step 8: Done" — echo live URL + Vietnamese celebration string.
11. Create `templates/` subfolder with 3 template files.
12. Dogfood test: run `/taw "landing page bán cà phê"` on a scratch dir. Iterate until green.
13. Commit: `feat(taw): core orchestrator skill`.

## Todo List
- [ ] Write SKILL.md frontmatter
- [ ] Write intent classification section (6 categories)
- [ ] Write clarify loop section referencing template
- [ ] Create `templates/clarify-questions.md` (≥15 VN questions tagged by intent)
- [ ] Create `templates/plan-bullet-format.md`
- [ ] Create `templates/error-messages.md` (≥10 VN error strings)
- [ ] Write approval-gate section with exact VN prompt
- [ ] Write agent dispatch section (Task calls with agent names from phase 02)
- [ ] Write error-recovery section (retry once, checkpoint on fail)
- [ ] Write deploy handoff section
- [ ] Dogfood: run end-to-end on throwaway project; measure time
- [ ] Commit

## Success Criteria
- `/taw "landing page bán cà phê"` in a clean directory produces a runnable Next.js app in <20 min.
- All user-visible strings are Vietnamese (grep test: `grep -v "^#" skills/taw/templates/*.md | rg "[a-zA-Z]{4,}"` returns only proper nouns/code keywords).
- Approval gate cannot be bypassed (test: answer "sửa" → loops back; answer "hủy" → exits).
- Error retry works: manually break a step, confirm one retry attempt, then checkpoint file appears at `.taw/checkpoint.json`.
- SKILL.md ≤ 250 lines.

## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| VN diacritics break Claude Code stdin (research-01 Q1) | Medium | Critical | Phase 07 CLI wraps stdin in `iconv -t UTF-8`; SKILL smoke test on all 3 OS |
| Agent chain exceeds context window on big features | High | High | Compact agent outputs to ≤200 tokens before next step; use per-phase artifacts on disk |
| Clarify questions feel robotic / not enough context | Medium | Medium | Preset-driven Qs (match intent → load preset clarify-set from phase 05) |
| User answers clarify Qs in mixed EN/VN | Low | Low | Accept both; orchestrator normalizes output language |
| Deploy step fails silently | Medium | High | `/taw-deploy` must return exit code + URL; checkpoint captures this |

## Security Considerations
- `.taw/` dir added to `.gitignore` (contains classified intents, possibly private business info).
- Never log API keys in checkpoint.json (orchestrator must redact before write).
- Approval gate is the ONLY user consent — all destructive ops downstream inherit that consent, but phase 06 permission-classifier still blocks `rm -rf /` or equivalent.

## Next Steps
- Phase 04 writes `/taw-deploy` which this skill calls.
- Phase 05 writes presets that clarify step references.
- Phase 09 documents the end-to-end flow for users (video + quickstart).
