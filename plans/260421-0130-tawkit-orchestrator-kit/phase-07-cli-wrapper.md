# Phase 07 — `tawkit` CLI Wrapper

## Context Links
- Phase 01 (`scripts/` directory), Phase 02 (skills to copy), Phase 06 (hooks to copy)
- Research: `research/researcher-02-vn-market-260421-0224.md` §4 #1 (zero-terminal-day-1), #7 (success metrics visible)

## Overview
- **Priority:** P2 (blocks 08, 10)
- **Status:** pending
- **Effort:** ~6h
- **Description:** Write the `tawkit` bash executable: `install`, `update`, `doctor`, `new <preset>`. Single file + helper lib.

## Key Insights
- Non-devs paste commands from video tutorials; command names must be short + memorable. `tawkit` not `taw-kit`.
- `update` is the difference between one-time sales + long-term value. Must be frictionless.
- `doctor` is the support deflection tool — if it runs green, 80% of "broken install" tickets disappear.

## Requirements
**Functional**
1. `tawkit install` — idempotent; copies skills/agents/hooks to `~/.claude/`, writes settings, symlinks binary.
2. `tawkit update` — `git pull` in `~/.taw-kit/` + rerun `copy-skills.sh` + compare `VERSION`, print changelog diff.
3. `tawkit doctor` — check: Claude Code installed, git ≥ 2.30, node ≥ 20, `~/.claude/` writable, hooks executable, Polar token set (warn not fail).
4. `tawkit new <preset>` — thin wrapper over `claude skill run taw-new <preset>`.
5. `tawkit --help` — bilingual usage, VN preferred.
6. `tawkit --version` — echoes `VERSION` file content.

**Non-functional**
- Main script ≤ 200 lines; helpers split into `scripts/lib/*.sh`.
- POSIX bash; tested on macOS (zsh+bash), Ubuntu, WSL2.
- Exit codes: 0 success, 1 user error, 2 system error, 3 missing dependency.
- All stdout in Vietnamese (errors include English dep name for searchability).

## Architecture

**File layout (from phase 01):**
```
scripts/
├── tawkit                      # main entry (chmod +x, symlinked to /usr/local/bin/tawkit)
├── install.sh                  # invoked by one-liner (phase 08)
├── doctor.sh                   # invoked by `tawkit doctor`
├── update.sh                   # invoked by `tawkit update`
└── lib/
    ├── log.sh                  # `info/warn/err` funcs with VN prefix + colors
    ├── detect-os.sh            # macos | linux | wsl | unsupported
    └── copy-skills.sh          # rsync skills/agents/hooks → ~/.claude/
```

**`tawkit` dispatcher:**
```
case "$1" in
  install) exec bash "$TAW_ROOT/scripts/install.sh" "$@" ;;
  update)  exec bash "$TAW_ROOT/scripts/update.sh"  "$@" ;;
  doctor)  exec bash "$TAW_ROOT/scripts/doctor.sh"  "$@" ;;
  new)     shift; exec claude skill run taw-new "$@" ;;
  --help|-h) show_help_vi ;;
  --version|-v) cat "$TAW_ROOT/VERSION" ;;
  *) err "Lệnh không hợp lệ: $1"; show_help_vi; exit 1 ;;
esac
```

**`copy-skills.sh` data flow:**
```
source: $TAW_ROOT/{skills,agents,hooks}/
target: ~/.claude/{skills,agents,hooks}/
strategy: rsync -a --exclude='.git' --exclude='*.md.bak'
conflict: only overwrite files matching taw-* prefix; skip others
```

**`doctor.sh` checks (each prints ✓ or ✗ in VN):**
1. `claude --version` → Claude Code installed
2. `git --version` → git ≥ 2.30
3. `node --version` → node ≥ 20
4. `test -w ~/.claude` → directory writable
5. `ls ~/.claude/skills/taw/SKILL.md` → install intact
6. `test -x ~/.claude/hooks/permission-classifier.sh` → hooks executable
7. `claude --print 'echo ok'` → API key works (skip if offline)
8. `command -v rtk` → RTK installed (warn only)
9. `echo $POLAR_TOKEN | grep .` → Polar token set (warn only)
10. OS encoding: `locale | grep UTF-8` → UTF-8 active (critical for VN)

## Related Code Files
**Create:**
- `scripts/tawkit`
- `scripts/install.sh`
- `scripts/update.sh`
- `scripts/doctor.sh`
- `scripts/lib/log.sh`
- `scripts/lib/detect-os.sh`
- `scripts/lib/copy-skills.sh`

**Modify:** none.

**Delete:** none.

## Implementation Steps
1. Write `scripts/lib/log.sh`: `info/warn/err/ok` functions with ANSI colors + VN prefix (`ℹ️ `, `⚠️ `, `❌ `, `✓ `).
2. Write `scripts/lib/detect-os.sh`: returns `macos|linux|wsl|unsupported` based on `uname -a`.
3. Write `scripts/lib/copy-skills.sh`: rsync source→target with `taw-*` overwrite guard; chmod +x on hooks.
4. Write `scripts/tawkit` dispatcher.
5. Write `scripts/install.sh`:
   - Detect OS; abort if unsupported.
   - Call `copy-skills.sh`.
   - Merge `templates/settings.json.tmpl` into `~/.claude/settings.json` (preserve existing keys).
   - Symlink `scripts/tawkit` → `/usr/local/bin/tawkit` (sudo if needed, warn-not-fail).
   - Run `doctor.sh` at end; print celebration in VN.
6. Write `scripts/update.sh`:
   - `cd ~/.taw-kit && git pull --ff-only`.
   - Read OLD_VERSION vs new `VERSION`; bail if same.
   - Re-run `copy-skills.sh`.
   - Print changelog since OLD_VERSION (phase 09 provides `CHANGELOG.md`).
7. Write `scripts/doctor.sh`: 10 checks per above, colored output, exit code = count of failures.
8. Chmod +x on all scripts.
9. Test on macOS + Ubuntu + WSL2. Fix OS-specific issues.
10. Commit: `feat(cli): tawkit wrapper with install/update/doctor/new`.

## Todo List
- [ ] Write `scripts/lib/log.sh` (VN prefixed helpers)
- [ ] Write `scripts/lib/detect-os.sh`
- [ ] Write `scripts/lib/copy-skills.sh` (rsync + taw-* guard)
- [ ] Write `scripts/tawkit` dispatcher
- [ ] Write `scripts/install.sh`
- [ ] Write `scripts/update.sh`
- [ ] Write `scripts/doctor.sh` (10 checks)
- [ ] `chmod +x` all scripts
- [ ] Test on macOS
- [ ] Test on Ubuntu
- [ ] Test on WSL2
- [ ] Commit

## Success Criteria
- `tawkit install` on clean machine completes in <60s; doctor exits 0.
- `tawkit update` shows changelog diff between versions.
- `tawkit doctor` identifies 3-of-3 injected problems (remove SKILL.md, chmod -x hook, unset locale) with clear VN messages.
- `tawkit new landing-page` invokes `/taw-new`.
- `tawkit --help` fits in 20 lines, all Vietnamese (except command names).

## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Symlink to `/usr/local/bin` fails without sudo | High | Medium | Fallback: suggest adding `~/.taw-kit/scripts` to PATH; warn-not-fail |
| `git pull` in `update` hits conflicts (user edited clone) | Medium | High | Abort with "chạy `tawkit doctor --reset`" message; don't auto-fix |
| Doctor false positive on enterprise proxy (blocks API check) | Medium | Low | Check is warn-only; doctor passes if other 9 green |
| Path spaces on macOS break rsync | Low | Medium | Quote all paths; test with `~/Documents and Stuff/` |
| WSL2 symlink semantics differ from Linux | Medium | Medium | Use `cp` fallback on WSL; documented in troubleshooting |

## Security Considerations
- Install script NEVER runs arbitrary `curl | bash` beyond our own verified one-liner (phase 08).
- `sudo` usage limited to symlink creation; always prompt user first.
- `git pull --ff-only` prevents silent merge of attacker-modified history.
- No secret writes to `/tmp`; use `mktemp -d` if needed.

## Next Steps
- Phase 08 install.sh one-liner invokes `scripts/install.sh`.
- Phase 10 manual-invite SOP triggers once buyer runs `tawkit install`.
