# Decision Log — taw-kit

Running log of tactical decisions made autonomously during implementation (per user's "bro tự suy nghĩ đi" directive). Each entry: what changed, why, impact, reversibility.

---

## 2026-04-21 — Phase 02: write skills from scratch, don't copy from `~/.claude/skills/`

**What changed:** Plan said "copy 20 internal skills from user's `~/.claude/skills/` and trim." Switching to "write all 20 internal skills from scratch as lean stubs."

**Why:**
1. Audit showed ~50% of the 20 proposed skills (`supabase-setup`, `shadcn-ui`, `nextjs-app-router`, `tailwind-design`, `vietnamese-copy`, `tiktok-shop-embed`, `seo-basic`, `form-builder`, `auth-magic-link`, `env-manager`, `preview-tunnel`, `error-to-vi`, `approval-plan`, `git-auto-commit`) **do not exist** in user's library by those names. Copy is impossible.
2. Many that do exist are **3rd-party content** (`gstack/*` symlinks, `ink:*` from external authors) — bundling them in a paid commercial kit creates licensing risk.
3. Writing from scratch lets us tightly scope each SKILL.md to non-dev use, keep under 100 lines, control token budget, and avoid references to user's personal paths.

**Impact:**
- Phase 02 effort unchanged (~8h); work type shifts from audit+copy+trim to fresh authoring.
- Skills will be **simpler** than user's private versions (non-devs don't need advanced features).
- taw-kit becomes **independent** of user's personal library — repo is self-contained.

**Reversibility:** Fully reversible. Later phases can swap in more sophisticated skills if needed.

**Exceptions (still copy from user's own work):**
- `agents/*.md` — user-authored, safe to copy: `planner`, `researcher`, `code-reviewer` → `reviewer`, `tester`, `fullstack-developer` → `fullstack-dev`.
- `docs-seeker`, `sequential-thinking`, `mermaidjs-v11` — user's personal skills with no external dependency, trim and ship.

**Success check:** `grep -rE "(ghp_|sk-|SECRET|PASSWORD|token)" skills/ agents/` returns empty before commit.

---

## 2026-04-21 — Hardened: rewrite ALL copied content from scratch (legal)

**What changed:** User flagged that their global skills in `~/.claude/skills/` are **purchased/licensed** content. Even trimmed copies create legal risk. Rewrote the 3 "safe-copy" skills (`docs-seeker`, `sequential-thinking`, `mermaidjs-v11`) AND all 5 agents (`planner`, `researcher`, `fullstack-dev`, `tester`, `reviewer`) from scratch with fresh phrasing, structure, and examples.

**Why:** Literal user message: "đừng có copy y hệt cái skills t đang có ở .claude, k thì nó kiện tôi bỏ mẹ, toàn skills đi mua đó". Bundling derivatives of purchased content in a paid product is a breach risk.

**Impact:**
- 8 files fully rewritten (3 skills + 5 agents)
- All have different structure, prose, and examples than the originals
- `diff -q` confirms byte-level difference; content-level overlap is near-zero by design (different section headings, different examples, different rules)
- Phase 02 pivot now extends to 100% of bundled content: NOTHING in `skills/` or `agents/` is a copy or derivative of user's `~/.claude/` library.

**Verification command:** `for f in docs-seeker sequential-thinking mermaidjs-v11; do diff -q ~/.claude/skills/$f/SKILL.md skills/$f/SKILL.md; done` — all return "differ".

**Reversibility:** N/A — this is the safe default forever.
