# maintain: status (dashboard)

Project health panel at a glance. Gathers state from git, package.json, build cache, deploy URL, test results, security quick-scan, bundle size, and `.taw/` checkpoints. Non-destructive — read only.

**Prereq:** router classified `tier2 = status`.

## Step 0 — Detect kit-repo vs product folder

Before running the dashboard, check if the user is running `/taw status` **inside the taw-kit repo itself** (not a built product). Heuristic:

```bash
if [ -d skills/taw ] && [ -d agents ] && [ -f VERSION ] && ! [ -f package.json ]; then
  echo "You're inside the taw-kit source repo — /taw status dashboards work on projects BUILT with the kit, not on the kit itself."
  echo "Cd into a folder where you ran /taw, or run /taw in an empty folder to create a new project."
  exit 0
fi
```

Emit in VN if user is Vietnamese. Skip the rest of the branch when this fires.

## Step 1 — Gather signals in parallel

Run all checks simultaneously (bash `&` + `wait`), capture to `.taw/dashboard/*.txt`.

**CRITICAL — shell compatibility**: Inside Claude Code, the `grep` command is a shell function that wraps `ugrep` (faster, but different exit-code semantics in pipelines). Any `grep` call used for boolean decisions MUST use `command grep` (or absolute path `/usr/bin/grep`) to bypass the wrapper and get POSIX-standard exit codes. Bare `grep` can silently return the wrong exit code and break our P0 counters.

```bash
mkdir -p .taw/dashboard

(
  # project identity
  echo "name: $(node -p "require('./package.json').name" 2>/dev/null || basename $(pwd))"
  echo "version: $(node -p "require('./package.json').version" 2>/dev/null || 'n/a')"
) > .taw/dashboard/project.txt &

(
  # git state
  echo "branch: $(git branch --show-current 2>/dev/null || echo 'not a repo')"
  echo "commits: $(git rev-list --count HEAD 2>/dev/null || echo 0)"
  echo "dirty: $(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
  echo "unpushed: $(git log @{u}..HEAD --oneline 2>/dev/null | wc -l | tr -d ' ')"
  echo "last_commit: $(git log -1 --pretty=format:'%h %s (%cr)' 2>/dev/null || echo 'none')"
) > .taw/dashboard/git.txt &

(
  # build state (cached)
  if [ -d .next ] || [ -d dist ]; then
    echo "last_build: $(stat -f '%Sm' -t '%Y-%m-%d %H:%M' .next 2>/dev/null || stat -c '%y' .next 2>/dev/null | cut -d. -f1)"
    echo "status: fresh (cached)"
  else
    echo "status: no recent build"
  fi
) > .taw/dashboard/build.txt &

(
  # deploy state
  if [ -f .taw/deploy-url.txt ]; then
    echo "url: $(cat .taw/deploy-url.txt)"
    echo "target: $(cat .taw/deploy-target.txt 2>/dev/null || echo '?')"
    if [ -f .taw/checkpoint.json ]; then
      echo "deployed_at: $(node -p "require('./.taw/checkpoint.json').deployed_at || 'unknown'" 2>/dev/null)"
    fi
  else
    echo "status: never deployed"
  fi
) > .taw/dashboard/deploy.txt &

(
  # security quick-scan (P0 only — fast)
  p0_count=0
  # .env committed check
  if git ls-files 2>/dev/null | command grep -E '^\.env(\.|$)' | command grep -v '\.env\.example$' >/dev/null; then
    p0_count=$((p0_count+1))
  fi
  # secret pattern scan — use `command grep` to bypass Claude Code's ugrep wrapper
  if git grep -qE 'sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9]{30,}' 2>/dev/null; then
    p0_count=$((p0_count+1))
  fi
  echo "p0_findings: $p0_count"
) > .taw/dashboard/security.txt &

(
  # test state (look for last run)
  if [ -f .taw/last-test.json ]; then
    cat .taw/last-test.json
  else
    # try quick count
    test_files=$(find . -name '*.test.ts' -o -name '*.test.tsx' -o -name '*.spec.ts' 2>/dev/null | command grep -v node_modules | wc -l | tr -d ' ')
    echo "test_files: $test_files"
    echo "last_run: never"
  fi
) > .taw/dashboard/tests.txt &

(
  # bundle size (read from .next/ if present)
  if [ -d .next ] && [ -f .next/build-manifest.json ]; then
    total=$(du -sk .next/static 2>/dev/null | cut -f1)
    echo "static_kb: $total"
  else
    echo "static_kb: unknown (run npm run build first)"
  fi
) > .taw/dashboard/bundle.txt &

(
  # features tracked in intent.json
  if [ -f .taw/intent.json ]; then
    features=$(node -p "JSON.stringify((require('./.taw/intent.json').features||[]).map(f=>f.feature||f))" 2>/dev/null || echo '[]')
    echo "features: $features"
    echo "category: $(node -p "require('./.taw/intent.json').category || 'n/a'" 2>/dev/null)"
  fi
) > .taw/dashboard/intent.txt &

wait
```

## Step 2 — Read all files, render dashboard (VN default)

```
📊 Trạng thái dự án — {name} v{version}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Git
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Branch:        {branch}
  Total commits: {commits}
  Working tree:  {dirty=0 ? '✓ clean' : '⚠️ {dirty} file chưa commit'}
  Unpushed:      {unpushed=0 ? '✓ đồng bộ remote' : '⚠️ {unpushed} commit chưa push'}
  Last commit:   {last_commit}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Build & Deploy
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Build cache:   {last_build ? '✓ ' + last_build : 'chưa build'}
  Deploy URL:    {url ? url : 'chưa deploy'}
  Target:        {target}
  Bundle size:   {static_kb} KB

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Chất lượng
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Tests:         {test_files} file · last run: {last_run}
  Security:      {p0_findings=0 ? '✓ 0 P0' : '🚨 ' + p0_findings + ' P0'}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Tính năng đã thêm
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Category:      {category}
  Features:      {features.length > 0 ? features.join(', ') : 'chưa thêm gì'}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Gợi ý tiếp theo
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  {suggestion}
```

## Step 3 — Generate suggestion

Pick the most relevant next action based on state:

| Condition | Suggestion |
|---|---|
| `dirty > 0` | `/taw review` — có {dirty} file chưa commit, review trước khi push |
| `unpushed > 0` && `dirty == 0` | `/taw review` — có {unpushed} commit chưa push lên remote |
| `p0_findings > 0` | `/taw audit` — có {N} lỗi bảo mật P0, fix trước khi deploy |
| `test_files == 0` | `/taw test` — chưa có test nào, nên gen cơ bản |
| `last_build > 7 ngày` | `/taw fix` hoặc `npm run build` — kiểm tra build còn xanh không |
| `url == null` && `p0 == 0` && `dirty == 0` | `/taw deploy` — sẵn sàng deploy |
| `static_kb > 500` | `/taw perf` — bundle hơi to, check giùm |
| tất cả OK | `/taw <tính năng mới>` — mọi thứ xanh, thêm gì mới không? |

Emit exactly ONE suggestion — the highest-priority one from the table above.

## Step 4 — Cleanup

Keep `.taw/dashboard/` for next run (can cache some values). Or delete if user asks "dọn sạch":
```bash
rm -rf .taw/dashboard/
```

## Optional flags

- `--deep` → also run `npm test`, `npm run build`, `npx tsc --noEmit` and update counts (takes ~60s)
- `--json` → emit as machine-readable JSON instead of text panel (for scripts)
- `--quiet` → one-line summary only: `coffee-shop · ✓ clean · ✓ 24 tests · ⚠️ 2 P1 · https://...`

## Constraints

- Read-only — NEVER modify code, never install packages
- Parallel signal gathering — must complete in <10 seconds (without `--deep`)
- Signals that fail (e.g. `git` not a repo) should degrade gracefully, not error the whole dashboard
- If `.taw/` doesn't exist at all AND folder is NOT the kit source (Step 0 checks that) → emit: "Chưa phải dự án taw-kit. Gõ `/taw` để tạo mới, hoặc mở folder đã có dự án."
- Don't cache the security scan — it must re-run each invocation
- Suggestion logic is deterministic (same state → same suggestion)
- Use `command grep` (not bare `grep`) for boolean pipeline checks — Claude Code's `grep` function wrapper returns non-POSIX exit codes that will corrupt the P0 counter
