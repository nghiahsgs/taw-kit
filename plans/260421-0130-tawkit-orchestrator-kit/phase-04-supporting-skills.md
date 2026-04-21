# Phase 04 — Supporting Skills: `/taw-fix`, `/taw-deploy`, `/taw-add`, `/taw-new`

## Context Links
- Phase 02 (stub files), Phase 03 (core `/taw` calls `/taw-deploy`)
- Research: `research/researcher-01-kit-patterns-260421-0130.md` §5.4 (error recovery), §5.5, §5.6
- Research: `research/researcher-02-vn-market-260421-0224.md` §4 #5 (one-click deploy), #7 (success metrics visible)

## Overview
- **Priority:** P2 (ship-blocking for full UX, but `/taw` can demo without)
- **Status:** pending
- **Effort:** ~8h (2h per skill)
- **Description:** Four narrower skills that complete the UX. Each standalone + composable.

## Key Insights
- `/taw-deploy` is the only supporting skill `/taw` hard-depends on (phase 03 step 7). Others are user-initiated.
- `/taw-fix` is the "panic button" — non-devs WILL break their app. Must be idiot-proof.
- `/taw-add` is where post-launch value compounds (users extend their products). Invest in clarity.
- `/taw-new <preset>` is a thin wrapper over `/taw` with pre-filled intent — keep it tiny.

## Requirements
**Functional**

**`/taw-fix`** — "sửa lỗi"
- Read last error from `.taw/checkpoint.json` OR from user's pasted stacktrace.
- Read recent git diff (last 3 commits) for context.
- Propose fix in VN, apply on approval.
- If build still broken, offer to revert via `git reset --hard <last-green>`.

**`/taw-deploy`** — "triển khai"
- Check for `vercel.json` or Shipkit config; auto-scaffold if missing.
- Run `npm run build` → if green, `vercel --prod` (or `shipkit deploy`).
- Capture URL, write to `.taw/deploy-url.txt`.
- Print VN success + URL + "Mở trong trình duyệt?" prompt.

**`/taw-add <feature description VN>`** — "thêm tính năng"
- Load current project via `.taw/intent.json` + git state.
- Clarify 2–3 Qs max (lighter than `/taw` since project exists).
- Single approval gate → code → test → commit → offer deploy.

**`/taw-new <preset>`** — "tạo mới"
- Validate `<preset>` against `presets/*.md` (phase 05).
- Load preset prompt, inject as if user typed `/taw <preset-prompt>`.
- Invoke `/taw` with pre-filled intent + skip classification step.

**Non-functional**
- Each skill ≤ 150 lines.
- All user-visible strings in Vietnamese.
- Shared VN strings live in `skills/error-to-vi/` (DRY).

## Architecture

**Shared helpers (loaded by all 4 skills):**
- Checkpoint reader: parses `.taw/checkpoint.json` safely (missing file → empty intent).
- VN message formatter: `→ emoji + VN phrase` for progress.
- Git state helper: `last-green-sha`, `uncommitted-changes?`.

**Dependency graph:**
```
/taw ──calls──> /taw-deploy
/taw-fix ──reads──> .taw/checkpoint.json (written by /taw)
/taw-add ──reads──> .taw/intent.json (written by /taw)
/taw-new <preset> ──invokes──> /taw with preset text
```

**`/taw-fix` decision tree:**
```
error exists?
  yes → read stacktrace → classify (compile | runtime | deps | env)
         → apply known-fix template OR ask Claude to diagnose
         → run `npm run build`
         → green? done : offer revert
  no  → ask user: "Lỗi gì? Dán ở đây:"
```

## Related Code Files
**Create:**
- `skills/taw-fix/SKILL.md` + `templates/fix-patterns.md` (VN known fixes: missing dep, env var, typo imports)
- `skills/taw-deploy/SKILL.md` + `templates/deploy-checks.md` (pre-flight: build green, no secrets in code, env vars set)
- `skills/taw-add/SKILL.md`
- `skills/taw-new/SKILL.md`

**Modify:** `skills/taw/SKILL.md` — add explicit invocation of `/taw-deploy` at step 7.

**Delete:** none.

## Implementation Steps
1. Write `skills/taw-deploy/SKILL.md` first (required by `/taw`):
   - Frontmatter, pre-flight checks, build, deploy via Shipkit MCP OR `vercel --prod` fallback, URL capture, VN success msg.
2. Create `templates/deploy-checks.md` listing 5 pre-flight checks.
3. Smoke test `/taw-deploy` on a dummy Next.js app.
4. Write `skills/taw-fix/SKILL.md`:
   - Error source selection, classification, known-fix lookup, revert fallback.
5. Create `templates/fix-patterns.md` with 10 common fixes:
   - "Module not found" → `npm install <pkg>`
   - "EADDRINUSE" → kill port
   - "Missing env var" → prompt user + write `.env.local`
   - (etc.)
6. Write `skills/taw-add/SKILL.md` (lighter clarify loop, reuse approval-plan skill).
7. Write `skills/taw-new/SKILL.md` (thin preset loader).
8. Update `skills/taw/SKILL.md` to invoke `/taw-deploy` at step 7.
9. Dogfood: build app via `/taw`, break it, `/taw-fix`, `/taw-add "dark mode"`, `/taw-deploy` again.
10. Commit: `feat: supporting skills (fix/deploy/add/new)`.

## Todo List
- [ ] Write `skills/taw-deploy/SKILL.md` + `templates/deploy-checks.md`
- [ ] Smoke test deploy on Next.js dummy
- [ ] Write `skills/taw-fix/SKILL.md` + `templates/fix-patterns.md` (≥10 patterns)
- [ ] Write `skills/taw-add/SKILL.md`
- [ ] Write `skills/taw-new/SKILL.md`
- [ ] Update `skills/taw/SKILL.md` to call `/taw-deploy`
- [ ] Full dogfood round-trip
- [ ] Commit

## Success Criteria
- `/taw-deploy` on a clean Next.js produces live URL in <5 min.
- `/taw-fix` resolves 7 of 10 template patterns without user intervention in a broken-on-purpose project.
- `/taw-add "dark mode"` modifies layout + toggle + theme without breaking existing pages.
- `/taw-new landing-page` short-circuits clarify step (confirmed: only 0–2 Qs asked vs 3–5 for `/taw`).
- Each SKILL.md ≤ 150 lines.

## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Shipkit MCP unavailable or breaks | Medium | High | Fallback path: `vercel --prod` via bash; doctor command warns if MCP missing |
| `/taw-fix` applies wrong fix, worsens state | Medium | High | Auto-commit before every fix attempt → `git reset` fallback always available |
| Deploy leaks secrets (e.g. `.env` pushed) | Low | Critical | Pre-flight check greps for `*.key`, `API_KEY=`, blocks deploy on hit |
| User runs `/taw-add` on non-taw project | Medium | Low | Check `.taw/intent.json` exists; if not, run full `/taw` clarify instead |
| Preset name typo in `/taw-new` | Medium | Low | List available presets in VN + fuzzy match suggestion |

## Security Considerations
- `/taw-deploy` pre-flight must grep for secrets before pushing. Block commit on match.
- `/taw-fix` revert uses `git reset --hard` — warn user in VN first, require `yes`.
- Never log deploy tokens (Shipkit/Vercel) to checkpoint or console.
- MCP credentials stay in `~/.config/claude-code/` — skills never read them directly.

## Next Steps
- Phase 05 fills presets that `/taw-new` depends on.
- Phase 09 documents each command in quickstart + video.
