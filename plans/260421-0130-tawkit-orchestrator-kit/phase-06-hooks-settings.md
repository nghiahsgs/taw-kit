# Phase 06 — Hooks & settings.json

## Context Links
- Phase 01 (directory `hooks/`, `templates/`)
- Phase 02 (agent names referenced)
- Research: `research/researcher-01-kit-patterns-260421-0130.md` §3 (top 10 hooks), §5.3
- Research: `research/researcher-02-vn-market-260421-0224.md` §4 #6 (hot reload UX)

## Overview
- **Priority:** P2
- **Status:** pending
- **Effort:** ~5h
- **Description:** Four hooks + one settings template + one per-project CLAUDE.md template. Makes non-dev sessions feel "magical" (context-aware, auto-committing, permission-smart).

## Key Insights
- RTK wrapper = biggest token saver (60-75% per research-01). Install unconditionally.
- Auto-commit after every Write/Edit = critical safety net for non-devs who never `git commit`.
- Session-start injection gives Claude "memory" of project without the user typing context.
- Permission classifier = 80/20: auto-approve safe commands, prompt only on destructive.

## Requirements
**Functional**
1. `session-start-context.sh` — on session start, echo: current branch, last 3 commits, last plan file path, deploy URL if present.
2. `post-tool-auto-commit.sh` — after Write/Edit, `git add -A && git commit -m "taw: auto-save $(date +%s)"` if diff non-empty.
3. `permission-classifier.sh` — input: bash command; output: `allow` / `deny` / `ask`. Hardcoded allow-list (npm install, git status, vercel deploy) + deny-list (rm -rf /, curl | sh outside install).
4. `rtk-wrapper.sh` — passthrough to `rtk` binary if installed, else no-op.
5. `templates/settings.json.tmpl` — Claude Code per-user settings: default model, VN language hint, hooks enabled, approved tools list.
6. `templates/CLAUDE.md.tmpl` — per-project system prompt: "You are building a product for a Vietnamese non-dev. Always respond in Vietnamese. Default stack: Next.js+Tailwind+Supabase+Polar+Shipkit."

**Non-functional**
- Every hook script ≤ 60 lines, POSIX-compliant bash (works on macOS default sh + Linux + WSL2).
- Hooks must exit 0 even on internal failure (never break the user's session).
- Hooks log to `~/.taw-kit/logs/hooks.log` (rotated at 10MB, phase 07 doctor cleans).

## Architecture

**Hook wiring (in `settings.json.tmpl`):**
```
"hooks": {
  "SessionStart": "bash ~/.claude/hooks/session-start-context.sh",
  "PostToolUse": {
    "matcher": "Write|Edit",
    "cmd": "bash ~/.claude/hooks/post-tool-auto-commit.sh"
  },
  "PreToolUse": {
    "matcher": "Bash",
    "cmd": "bash ~/.claude/hooks/permission-classifier.sh"
  }
}
```

**Permission classifier decision:**
```
cmd = $1  (bash command string)

allow_patterns = ["^npm (install|run|test)", "^git (status|diff|log|add|commit)", "^node ", "^vercel", "^next "]
deny_patterns  = ["rm -rf /", "rm -rf \\*", "curl.*\\| *(sh|bash)", ":\\(\\)\\{.*fork"]

if any deny match: exit 2 ("deny")
if any allow match: exit 0 ("allow")
else: exit 1 ("ask")
```

**Auto-commit guard:**
- Only in git repos (`git rev-parse` check).
- Only if diff non-empty.
- Skips if commit message would match existing HEAD (no empty commits).
- Configurable off via `TAW_AUTO_COMMIT=0` env var.

**CLAUDE.md.tmpl content (per-project, copied to each user project):**
```
# Project: {{PROJECT_NAME}}

You are building a product for a Vietnamese non-developer using taw-kit.

## Response language
- All user-facing strings: Vietnamese.
- Code comments: English (framework convention).
- Error messages: Vietnamese summary + English technical detail.

## Default stack
- Next.js 15 (App Router)
- Tailwind + shadcn
- Supabase (DB + auth)
- Polar (payments)
- Shipkit (deploy)

## Rules
- KISS/YAGNI/DRY.
- No new test frameworks. Use `npm run build` as the smoke test.
- Auto-commit hook is active; don't create tiny manual commits.
- Read `.taw/intent.json` for project history before making decisions.
```

## Related Code Files
**Create:**
- `hooks/session-start-context.sh`
- `hooks/post-tool-auto-commit.sh`
- `hooks/permission-classifier.sh`
- `hooks/rtk-wrapper.sh`
- `templates/settings.json.tmpl`
- `templates/CLAUDE.md.tmpl`

**Modify:** `scripts/lib/copy-skills.sh` (phase 07) — add hooks copy step.

**Delete:** none.

## Implementation Steps
1. Write `session-start-context.sh`:
   - `git branch --show-current` + `git log -3 --oneline`.
   - `ls -t plans/*.md 2>/dev/null | head -1`.
   - `cat .taw/deploy-url.txt 2>/dev/null`.
   - All output to stdout (Claude reads).
2. Write `post-tool-auto-commit.sh`:
   - Guard: `git rev-parse --is-inside-work-tree` or exit 0.
   - `git diff --cached --quiet && git diff --quiet` or `git add -A && git commit -m "taw: auto-save"`.
3. Write `permission-classifier.sh`:
   - Parse `$1` as command string.
   - Match against allow/deny regex arrays above.
   - Exit 0/1/2 per Claude Code hook spec.
4. Write `rtk-wrapper.sh` — check `command -v rtk`; if exists, exec it; else passthrough args.
5. Write `settings.json.tmpl` — hook wiring + `"model": "claude-opus-4-7"` + `"approvedTools": [...]`.
6. Write `CLAUDE.md.tmpl` per schema above.
7. Test each hook in isolation (`bash hooks/<name>.sh` with sample args).
8. Integrate: install hooks in a test `~/.claude/`, run `/taw` end-to-end, verify auto-commit fires + context injection works.
9. Commit: `feat: hooks and templates for Vietnamese non-dev UX`.

## Todo List
- [ ] Write `hooks/session-start-context.sh`
- [ ] Write `hooks/post-tool-auto-commit.sh` (with repo guard + empty-diff skip)
- [ ] Write `hooks/permission-classifier.sh` (allow/deny regex tables)
- [ ] Write `hooks/rtk-wrapper.sh`
- [ ] Write `templates/settings.json.tmpl`
- [ ] Write `templates/CLAUDE.md.tmpl`
- [ ] Test each hook in isolation
- [ ] Integration test via `/taw` in a scratch repo
- [ ] Commit

## Success Criteria
- Fresh `/taw` session prints git context at start (verify via Claude's first response mentioning branch).
- After running `/taw`, `git log --oneline` shows ≥3 `taw: auto-save` commits.
- `permission-classifier.sh "rm -rf /"` exits 2; `"npm install"` exits 0; `"rm file.txt"` exits 1.
- Settings JSON validates (`jq '.' templates/settings.json.tmpl`).
- CLAUDE.md.tmpl renders cleanly with `{{PROJECT_NAME}}` placeholder.

## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Auto-commit pollutes git history with noisy commits | High | Low | Document squash recipe in troubleshooting; env var to disable |
| Permission classifier false-negatives (misses destructive cmd) | Medium | High | Conservative allow-list (deny-by-default); audit quarterly |
| Session-start injection too verbose, bloats context | Low | Medium | Cap output to 20 lines; truncate commit list |
| RTK not installed, wrapper silently fails | Low | Low | Doctor command reports RTK status; wrapper exits 0 either way |
| Hook fires on WSL2 with CRLF line endings | Medium | Medium | `.gitattributes` enforces LF (phase 01); shebang `#!/usr/bin/env bash` |

## Security Considerations
- Permission classifier is DEFENSE-IN-DEPTH, not the only gate. Claude Code's native approval still runs.
- Auto-commit must NEVER commit `.env*` or `*.key` — add explicit grep block before commit.
- Hooks log path `~/.taw-kit/logs/` is user-owned (0700); no shared-tmp.
- `curl | sh` detection in classifier catches supply-chain risk.

## Next Steps
- Phase 07 CLI install step copies these hooks into `~/.claude/hooks/`.
- Phase 08 install.sh verifies hooks execute after install.
- Phase 09 docs explain auto-commit behavior to non-dev buyers.
