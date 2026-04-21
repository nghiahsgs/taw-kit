# Phase 02 — Curate Skills & Agents

## Context Links
- Phase 01 (blocks this)
- Research: `research/researcher-01-kit-patterns-260421-0130.md` §1, §5.2
- User's existing skills: `~/.claude/skills/*` (100+)
- User's existing agents: `~/.claude/agents/*`

## Overview
- **Priority:** P1 (critical path — blocks 03, 04)
- **Status:** pending
- **Effort:** ~8h
- **Description:** Select ≤25 skills + 5 agents from user's library, adapt each for non-dev use, bundle into `skills/` and `agents/`.

## Key Insights
- rohitg00's 135-agent kit is overwhelming for non-devs. Ruthless cut to 25 skills + 5 agents is the differentiator.
- Non-dev never invokes skills by name — only `/taw*` does. So skills are "internal library" not "user-facing commands." Names can stay English.
- Keep SKILL.md bodies lean (≤120 lines). Long skills cause Claude to compress poorly.

## Requirements
**Functional**
- ≤25 skills total in `skills/` dir (user-facing `/taw*` count toward 25).
- Exactly 5 agents: `planner`, `researcher`, `fullstack-dev`, `tester`, `reviewer`.
- Every skill has a one-line purpose tag in frontmatter (searchable by Claude).
- No skill references paths outside `~/.claude/` or current project (portability).

**Non-functional**
- Each skill loads independently (no cross-references that break if one is removed).
- Token budget: full skill catalog loads in <5k tokens (enables Claude to discover them).

## Architecture

**Selection criteria (apply in order):**
1. Does a `/taw*` flow invoke it? → KEEP
2. Is it domain-specific to Vietnamese market (MoMo, VietQR, Shopee)? → KEEP
3. Is it a dev-only tool (unit testing, refactoring)? → DROP for MVP
4. Does it duplicate another? → pick ONE, drop rest (DRY)

**Proposed 5 user-facing skills (from `/taw*` family):**
| Skill | Purpose |
|-------|---------|
| `taw` | Main orchestrator (phase 03) |
| `taw-fix` | Auto-diagnose+patch broken build (phase 04) |
| `taw-deploy` | One-command Shipkit/Vercel deploy (phase 04) |
| `taw-add` | Add feature to existing project (phase 04) |
| `taw-new` | Scaffold from preset (phase 04) |

**Proposed 20 internal skills to bundle** (adapt from user's `~/.claude/skills/`):
| # | Skill | Why |
|---|-------|-----|
| 1 | `docs-seeker` | Fetch latest framework docs (context7) |
| 2 | `sequential-thinking` | Planner reasoning |
| 3 | `debug` | Error analysis for `taw-fix` |
| 4 | `payment-integration` | Polar + MoMo/ZaloPay wiring |
| 5 | `supabase-setup` | DB schema + auth bootstrap |
| 6 | `shadcn-ui` | Component scaffold |
| 7 | `nextjs-app-router` | Routing patterns |
| 8 | `tailwind-design` | Styling helpers |
| 9 | `shipkit-deploy` | Deploy via Shipkit MCP |
| 10 | `vietnamese-copy` | VN marketing copy + UX strings |
| 11 | `tiktok-shop-embed` | TikTok Shop product cards |
| 12 | `seo-basic` | Meta tags + sitemap |
| 13 | `form-builder` | Contact/lead forms → Supabase |
| 14 | `auth-magic-link` | Supabase magic-link auth |
| 15 | `env-manager` | `.env.local` safe handling |
| 16 | `git-auto-commit` | Wraps post-tool hook logic |
| 17 | `mermaidjs-v11` | Diagrams (user mentioned) |
| 18 | `preview-tunnel` | Local preview via `npx localtunnel` |
| 19 | `error-to-vi` | Translate error messages to Vietnamese |
| 20 | `approval-plan` | Render 3-5 bullet plan + wait for "OK?" |

**Final count:** 5 user-facing + 20 internal = 25. Meets cap.

**5 agents (copied from user's `~/.claude/agents/`, trimmed):**
- `planner.md` — creates plan.md + phase files (used by `/taw` step 2)
- `researcher.md` — parallel web/doc research (used by `/taw` step 3)
- `fullstack-dev.md` — writes code, runs compiles (used by `/taw` step 4)
- `tester.md` — runs `npm test` / `npm run build`, reports (used by `/taw` step 5)
- `reviewer.md` — security/quality review before deploy (used by `/taw` step 6)

## Related Code Files
**Create:**
- `skills/taw/SKILL.md` (stubbed; filled in phase 03)
- `skills/taw-fix/SKILL.md`, `skills/taw-deploy/SKILL.md`, `skills/taw-add/SKILL.md`, `skills/taw-new/SKILL.md` (stubbed; filled in phase 04)
- `skills/{docs-seeker, sequential-thinking, debug, payment-integration, supabase-setup, shadcn-ui, nextjs-app-router, tailwind-design, shipkit-deploy, vietnamese-copy, tiktok-shop-embed, seo-basic, form-builder, auth-magic-link, env-manager, git-auto-commit, mermaidjs-v11, preview-tunnel, error-to-vi, approval-plan}/SKILL.md` (20 files)
- `agents/{planner,researcher,fullstack-dev,tester,reviewer}.md` (5 files)

**Modify:** none.

**Delete:** none.

## Implementation Steps
1. List `~/.claude/skills/` to confirm each of the 20 target skills exists; record actual filenames.
2. For each of 20 internal skills, `cp -R ~/.claude/skills/<name>/ skills/<name>/`.
3. For each copy, trim SKILL.md: remove lines >120, delete references outside `~/.claude/`, ensure frontmatter has `description` field.
4. For each of 5 agents, `cp ~/.claude/agents/<name>.md agents/<name>.md` (rename if user's name differs, e.g. `code-reviewer` → `reviewer`).
5. Trim agent prompts: remove project-specific mentions; keep generic instructions.
6. Stub 5 user-facing skills with empty SKILL.md + frontmatter (real content in phases 03, 04).
7. Write `skills/README.md` with the 25-skill table for buyers who want to understand what they bought.
8. Commit: `feat: curate skills and agents for v0.1`.

## Todo List
- [ ] Audit `~/.claude/skills/` — confirm 20 target skills available; substitute if missing
- [ ] Copy 20 internal skills to `skills/`
- [ ] Trim each SKILL.md (≤120 lines, generic paths)
- [ ] Copy 5 agents, rename to canonical names, trim
- [ ] Stub 5 `taw*` skills (frontmatter only)
- [ ] Write `skills/README.md` catalog
- [ ] Verify file count: `ls skills/ | wc -l` = 25
- [ ] Commit `feat: curate skills and agents for v0.1`

## Success Criteria
- `ls skills/` returns exactly 25 entries.
- `ls agents/` returns exactly 5 entries.
- `grep -r "~/Documents" skills/ agents/` returns empty (no user-specific paths).
- Each SKILL.md has valid YAML frontmatter with `name` and `description`.
- Token count of all SKILL.md combined < 5000 (check: `wc -w skills/*/SKILL.md | tail -1` < 3500 words).

## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| User's private skills contain API keys or personal notes | Medium | High | Manual review of each copied file before commit; grep for `sk-`, `ghp_`, email |
| Some target skills don't exist in user's library | Medium | Medium | Fallback: write minimal stub (≤30 lines) from scratch for missing ones |
| Skill dependencies not portable (e.g. reference to deleted file) | Medium | Medium | Run `grep -r "\.claude" skills/` and fix broken refs |
| 25-skill cap too tight once /taw is built | Low | Medium | Version bump policy: remove least-used before adding new (not in MVP) |

## Security Considerations
- **Secret leakage:** audit every copied file for credentials before commit. Add grep check to pre-commit hook in phase 06.
- **License of copied code:** user's own skills; confirm no third-party prompts with restrictive licenses.
- **Attack surface:** internal skills accept LLM-generated prompts — do not auto-execute arbitrary bash. Rely on phase 06 permission classifier.

## Next Steps
- Phase 03 populates `skills/taw/SKILL.md` (depends on this phase).
- Phase 04 populates `skills/taw-{fix,deploy,add,new}/SKILL.md`.
- Phase 06 uses agent list to configure hooks.
