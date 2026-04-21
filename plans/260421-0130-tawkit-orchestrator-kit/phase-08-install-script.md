# Phase 08 — Install Script (one-liner)

## Context Links
- Phase 07 (`scripts/install.sh` — this phase provides the public-facing one-liner that invokes it)
- Phase 10 (buyer flow starts here)
- Research: `research/researcher-02-vn-market-260421-0224.md` §4 #1 (zero-terminal-day-1)

## Overview
- **Priority:** P2 (blocks 10)
- **Status:** pending
- **Effort:** ~4h
- **Description:** Public `curl | bash` one-liner that clones the private repo (via token) and hands off to `scripts/install.sh`.

## Key Insights
- Non-devs trust one-liners they see in video tutorials. Must be copy-pasteable with no placeholders.
- Private repo clone needs auth. Two paths: (a) personal access token baked in short-lived install URL, or (b) `gh auth login` prompt.
- Option (b) simpler + safer: user logs into GitHub once via device flow, `gh` handles the rest.

## Requirements
**Functional**
1. Public URL hosting the one-liner (e.g., `https://install.tawkit.vn` redirecting to GitHub Gist raw).
2. One-liner format: `curl -fsSL https://install.tawkit.vn | bash`.
3. Script detects OS; aborts Windows (non-WSL) with VN message pointing to WSL2 setup doc.
4. Script checks + installs prerequisites:
   - `git` (fail with install instructions if missing)
   - `claude` (Claude Code CLI — install via npm if missing)
   - `gh` (GitHub CLI — install via brew/apt if missing)
5. Runs `gh auth login` if not authenticated.
6. Clones private repo to `~/.taw-kit/`.
7. Calls `~/.taw-kit/scripts/install.sh`.
8. Prints next-step VN message + link to first-app video.

**Non-functional**
- One-liner reads from a stable URL; repo relocation shouldn't break it (redirect layer).
- Install script itself ≤ 120 lines; delegates heavy lifting to phase 07 script.
- Exits 0 only on full success. Any prereq failure exits early with Vietnamese remediation.

## Architecture

**Execution flow:**
```
User (from video) → pastes one-liner into Terminal
  │
  ▼
curl fetches `install.sh` from Gist/redirect
  │
  ▼
bash runs the fetched script:
  1. detect OS (macos/linux/wsl — or abort)
  2. check+install: git, node≥20, claude-code, gh
  3. gh auth status → if not authed, `gh auth login --web`
  4. git clone git@github.com:USER/taw-kit.git ~/.taw-kit (via gh cli)
  5. bash ~/.taw-kit/scripts/install.sh  (phase 07)
  6. echo VN success + video URL
```

**Prereq install table:**
| Tool | macOS | Ubuntu | WSL2 |
|------|-------|--------|------|
| git | `brew install git` | `apt install git` | `apt install git` |
| node≥20 | `brew install node` | nvm install 20 | nvm install 20 |
| claude-code | `npm i -g @anthropic-ai/claude-code` | same | same |
| gh | `brew install gh` | `apt install gh` (or GitHub repo) | same as Ubuntu |

**One-liner URL strategy:**
- `install.tawkit.vn` → CNAME → GitHub Pages (static file) serving a 302 to raw Gist URL.
- If no domain yet, publish raw Gist URL directly; switch to domain later without breaking installs.

## Related Code Files
**Create:**
- `scripts/install-oneliner.sh` — the script hosted publicly (phase 08 output).
- `docs/vi/install.md` — VN install walkthrough + troubleshooting.
- `docs/en/install.md` — English equivalent.

**Modify:** `README.md` — add one-liner prominently near top.

**Delete:** none.

## Implementation Steps
1. Write `scripts/install-oneliner.sh`:
   - `set -euo pipefail`
   - VN colored log helper inline (can't import lib before clone).
   - OS detection + abort on unsupported.
   - Prereq checks with VN remediation strings.
   - `gh auth status` → login if needed.
   - `gh repo clone <user>/taw-kit ~/.taw-kit` (fails cleanly if user lacks access — guides to buy link).
   - `bash ~/.taw-kit/scripts/install.sh`.
   - Final celebration + video URL.
2. Test in fresh Docker container (Ubuntu) + VM snapshot (macOS).
3. Create GitHub Gist (public) hosting the script. Record raw URL.
4. Configure DNS: `install.tawkit.vn` CNAME → GitHub Pages or Cloudflare Worker redirect to Gist raw.
5. Write `docs/vi/install.md`: step-by-step with screenshots.
6. Update `README.md` with prominent one-liner block.
7. Test end-to-end: fresh WSL2 → paste one-liner → verify `/taw` works.
8. Commit: `feat(install): public one-liner installer`.

## Todo List
- [ ] Write `scripts/install-oneliner.sh`
- [ ] Test in clean Ubuntu Docker container
- [ ] Test on fresh macOS VM
- [ ] Test on fresh WSL2
- [ ] Create public Gist hosting the script
- [ ] Configure `install.tawkit.vn` redirect (or document Gist URL)
- [ ] Write `docs/vi/install.md`
- [ ] Write `docs/en/install.md`
- [ ] Update `README.md` one-liner block
- [ ] End-to-end dry run with test buyer
- [ ] Commit

## Success Criteria
- `curl -fsSL <url> | bash` on a vanilla Ubuntu Docker image completes in <3 min and `tawkit doctor` exits 0.
- Non-buyer (no repo access) sees clear VN message: "Bạn chưa mua taw-kit. Mua tại: <polar-url>".
- All errors emit Vietnamese remediation + link to `docs/vi/install.md` troubleshooting anchor.
- One-liner is under 100 chars (video-pasteable).

## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| GitHub rate-limits `gh clone` during launch spike | Low | High | Use GitHub token with higher quota; cache install.sh at CDN |
| User's shell is `fish` / non-bash — `bash -c` fails | Medium | Medium | One-liner explicitly invokes `bash`; doc includes `zsh` variant |
| `gh auth login --web` fails in headless SSH session | Low | Low | Fallback: `gh auth login` device flow; documented |
| Public Gist URL rotates if we edit | Low | High | Use Gist commit hash URL once stable; or self-host |
| Supply-chain attack on hosted script | Low | Critical | Subresource integrity not possible with curl|bash; publish SHA256 in README for power users to verify |

## Security Considerations
- **curl | bash is inherently trust-based.** Publish script SHA256 in README. Advanced users can verify.
- `gh auth login` flow keeps credentials in `gh`'s credential store — never in our script.
- Never write tokens to logs or files.
- Install script runs with user privileges only; `sudo` prompts only for optional symlink (phase 07).
- Private repo access is THE gate that enforces payment. If someone forks public script, they still can't clone without GitHub invite.

## Next Steps
- Phase 09 video references this one-liner as first step.
- Phase 10 buyer invite workflow ends with "run this one-liner".
