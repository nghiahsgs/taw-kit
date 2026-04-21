# Phase 01 — Repo Architecture

## Context Links
- Research: `research/researcher-01-kit-patterns-260421-0130.md` §5.2, §5.3
- Research: `research/researcher-02-vn-market-260421-0224.md` §4 (UX expectations)
- Convention: `~/.claude/rules/documentation-management.md`

## Overview
- **Priority:** P1 (critical path — blocks 02, 06, 07)
- **Status:** pending
- **Effort:** ~4h
- **Description:** Lock the physical layout of the `taw-kit` private GitHub repo so every subsequent phase has a known target path.

## Key Insights
- Repos that try to double as "user's workspace" + "source of truth" confuse non-devs. Separate **shipped artifacts** (`skills/`, `agents/`, `hooks/`, `templates/`) from **installed locations** (`~/.claude/skills/...`).
- Layout mirrors `~/.claude/` so `cp -R` in install script is 1:1, no path rewriting.
- Top-level English README for SEO; VN docs under `docs/vi/`.

## Requirements
**Functional**
- Fresh clone builds nothing but copying files into `~/.claude/` yields working kit.
- `tawkit` CLI discoverable from `$PATH` via single symlink.
- Version tracked in `VERSION` file (semver, bumped per release) for `tawkit update` diff check.

**Non-functional**
- File count ≤ 150 at launch (readability + review speed).
- No binary assets in git; only text + shell + markdown.
- Windows compatible via WSL2 (LF line endings enforced via `.gitattributes`).

## Architecture

```
taw-kit/                               # repo root
├── README.md                          # English, SEO
├── VERSION                            # e.g. 0.1.0
├── LICENSE                            # commercial EULA (phase 10)
├── .gitattributes                     # * text=auto eol=lf
├── skills/                            # copied to ~/.claude/skills/
│   ├── taw/SKILL.md
│   ├── taw-fix/SKILL.md
│   ├── taw-deploy/SKILL.md
│   ├── taw-add/SKILL.md
│   └── taw-new/SKILL.md
├── agents/                            # copied to ~/.claude/agents/
│   ├── planner.md
│   ├── researcher.md
│   ├── fullstack-dev.md
│   ├── tester.md
│   └── reviewer.md
├── hooks/                             # copied to ~/.claude/hooks/
│   ├── session-start-context.sh
│   ├── post-tool-auto-commit.sh
│   ├── permission-classifier.sh
│   └── rtk-wrapper.sh
├── presets/                           # referenced by /taw-new
│   ├── landing-page.md
│   ├── shop-online.md
│   ├── crm.md
│   ├── blog.md
│   └── dashboard.md
├── templates/                         # per-project CLAUDE.md + settings.json templates
│   ├── CLAUDE.md.tmpl
│   └── settings.json.tmpl
├── scripts/                           # implementation of tawkit CLI
│   ├── tawkit                         # main bash entry (chmod +x)
│   ├── install.sh                     # one-liner target
│   ├── doctor.sh
│   ├── update.sh
│   └── lib/                           # shared bash helpers
│       ├── log.sh
│       ├── detect-os.sh
│       └── copy-skills.sh
└── docs/
    ├── vi/                            # Vietnamese (primary)
    │   ├── quickstart.md
    │   ├── troubleshooting.md
    │   └── video-script.md
    └── en/                            # English README supplements
        └── architecture.md
```

**Data flow for install:**
`install.sh` → clones repo to `~/.taw-kit/` → `scripts/lib/copy-skills.sh` rsyncs `skills/ agents/ hooks/` → `~/.claude/` → symlinks `scripts/tawkit` → `/usr/local/bin/tawkit`.

## Related Code Files
**Create:**
- `/Users/nguyennghia/Documents/GitHub/taw-kit/README.md`
- `/Users/nguyennghia/Documents/GitHub/taw-kit/VERSION` (content: `0.1.0`)
- `/Users/nguyennghia/Documents/GitHub/taw-kit/.gitattributes`
- `/Users/nguyennghia/Documents/GitHub/taw-kit/.gitignore` (ignore `.DS_Store`, `node_modules`, `.env*`)
- Empty placeholder dirs: `skills/ agents/ hooks/ presets/ templates/ scripts/lib/ docs/vi/ docs/en/` (each with `.gitkeep`)

**Modify:** none (greenfield).

**Delete:** none.

## Implementation Steps
1. Initialize git repo if not already (`git init`, verify `main` branch).
2. Write `README.md` stub (English, 1 paragraph + "Install" placeholder + "Docs: see `docs/vi/`").
3. Write `VERSION` file containing `0.1.0\n`.
4. Write `.gitattributes` with `* text=auto eol=lf`.
5. Write `.gitignore` (node_modules, .env, .DS_Store, dist/, .claude-local).
6. Create placeholder directory structure with `.gitkeep` in each empty dir.
7. Stub `LICENSE` file with "Commercial EULA — see phase 10" placeholder.
8. Commit: `chore: scaffold repo layout`.

## Todo List
- [ ] `git init` + confirm main branch
- [ ] Write `README.md` stub
- [ ] Write `VERSION` (`0.1.0`)
- [ ] Write `.gitattributes` (LF enforcement)
- [ ] Write `.gitignore`
- [ ] Create all placeholder directories with `.gitkeep`
- [ ] Stub `LICENSE` placeholder
- [ ] Initial commit `chore: scaffold repo layout`

## Success Criteria
- `tree -L 2` shows the architecture diagram exactly.
- `git status` is clean after commit.
- Directory structure reviewed against `~/.claude/` layout — names match 1:1 for `skills/ agents/ hooks/`.

## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| User's existing `~/.claude/` skills conflict with taw-kit names | Medium | High | Prefix all taw-kit skills with `taw-*`; never overwrite files not starting with `taw-` |
| Line-ending issues on Windows/WSL2 | Medium | Medium | `.gitattributes` eol=lf; doctor command checks CRLF |
| `~/.claude/` doesn't exist on fresh machine | Low | High | Install script creates it if missing |

## Security Considerations
- `.gitignore` must block `.env`, `*.key`, `license.key` from ever being committed.
- LICENSE file (phase 10) will restrict redistribution; linked here as placeholder.
- No secrets in templates — placeholders only (`{{POLAR_TOKEN}}`).

## Next Steps
- Feeds phase 02 (populates `skills/`, `agents/`).
- Feeds phase 06 (populates `hooks/`, `templates/`).
- Feeds phase 07 (populates `scripts/`).
