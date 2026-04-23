# taw-kit

> Opinionated Claude Code kit for non-developers — ship real products with `/taw <describe what you want>`.

**Website:** [theagents.work](https://www.theagents.work/)

> Bản tiếng Việt: [README.md](./README.md)

```
/taw build me an online shop selling cosmetics
  → clarify (3-5 questions)
  → plan (5 bullets, you approve)
  → code + test + review
  → deploy (Vercel, Docker, or VPS)
  → live URL
```

---

## What you get

- **34 skills, 6 agents, 4 hooks** — installed into `~/.claude/`
- **Design intelligence** — Anthropic's `frontend-design` skill bundled under Apache 2.0 to keep generated UIs out of "AI slop" territory. See [THIRD-PARTY-NOTICES.md](./THIRD-PARTY-NOTICES.md) for full attribution.
- **`tawkit` CLI** — install, update, doctor, uninstall, scaffold from preset
- **5 presets** — landing page, online shop, CRM, blog, dashboard
- **3 deploy targets** — Vercel (default), Docker image, or VPS over SSH
- **Commercial license** — build and sell as many products as you want

---

## Install

### Before you start

You need these on your machine:

| Tool | Why | Install |
|------|-----|---------|
| **Claude Code** | The CLI that runs the skills | [docs.claude.com/claude-code](https://docs.claude.com/claude-code) |
| **Node.js ≥ 20** | Your generated projects run on it | [nodejs.org](https://nodejs.org) |
| **git** | Used by the installer | `brew install git` / `apt install git` |
| **GitHub CLI (`gh`)** | Used to clone the private repo | `brew install gh` / `apt install gh` |
| **Authenticated Claude Code** | One of two options: a Claude Pro/Max subscription (login via `claude login`) **or** an Anthropic API key (pay per token) | Subscription: [claude.ai](https://claude.ai) · API key: [console.anthropic.com](https://console.anthropic.com) |

> taw-kit itself makes no API calls — it's just markdown + shell scripts. Auth is required by **Claude Code** (Anthropic's CLI). If you already have a Claude Pro/Max subscription, you do not need a separate API key.

**OS:** macOS, Linux, or Windows via WSL2. On Windows, follow the step-by-step guide in [docs/install-windows.md](./docs/install-windows.md) first, then come back here.

### Option A — One-liner (recommended)

```bash
curl -fsSL https://install.tawkit.dev | bash
```

This will:

1. Detect your OS (macOS / Linux / WSL).
2. Check that prerequisites are installed (warn if missing).
3. Log you into GitHub if you're not already.
4. Clone the private taw-kit repo to `~/.taw-kit/`.
5. Install skills, agents, hooks, and templates into `~/.claude/`.
6. Symlink `tawkit` into `/usr/local/bin/` (asks for sudo once).
7. Run `tawkit doctor` to confirm everything works.

The whole thing takes about 30 seconds.

### Option B — Manual (if you don't trust `curl | bash`)

```bash
# 1. Clone the private repo (you need an invite to taw-kit/taw-kit)
gh repo clone <your-org>/taw-kit ~/.taw-kit

# 2. Run the installer
bash ~/.taw-kit/scripts/install.sh

# 3. Verify
tawkit doctor
```

### Option C — Verify without installing

Prefer to read the script before running it?

```bash
curl -fsSL https://install.tawkit.dev -o /tmp/taw-install.sh
less /tmp/taw-install.sh          # review
bash /tmp/taw-install.sh          # run if you're satisfied
```

---

## First run

Open Claude Code in a fresh folder:

```bash
mkdir my-first-product && cd my-first-product
claude
```

Inside Claude Code:

```
/taw build me a landing page for my online course
```

taw-kit will ask you 3–5 clarifying questions, render a plan, and wait for your approval. Type `yes` and it runs the full pipeline: plan → research → code → test → security review → deploy. About 15–20 minutes end-to-end.

Or start from a preset:

```bash
tawkit new shop-online
```

---

## Deploy choices

After the code is written, `/taw-deploy` asks where to ship:

```
Where do you want to deploy?
  1. vercel  — Free cloud hosting, fastest to set up (recommended)
  2. docker  — Build a Docker image; run it on any host you own
  3. vps     — Deploy to your own VPS over SSH (systemd + nginx)
```

| Target | Setup effort | Cost | Best for |
|--------|--------------|------|----------|
| **Vercel** | Zero | Free tier fits small shops | Non-devs, prototypes, landing pages |
| **Docker** | Need Docker installed | Free (you host it) | Portable delivery to clients, cloud-agnostic |
| **VPS** | Need SSH + systemd comfort | Cost of your VPS | Full control, heavy traffic, data residency needs |

You can change targets later — `/taw-deploy --target=docker` on an already-deployed project generates a Dockerfile without touching your Vercel deployment.

---

## Keep it updated

```bash
tawkit update
```

This pulls the latest taw-kit from GitHub, re-runs install, and prints a changelog.

## Verify installation

```bash
tawkit doctor
```

Runs 10 checks: Claude Code installed, git/node versions, `~/.claude/` writable, hooks executable, API auth, UTF-8 locale, etc.

## Uninstall

```bash
tawkit uninstall          # remove skills/agents/hooks from ~/.claude, keep ~/.taw-kit/
tawkit uninstall --full   # also remove the cloned repo at ~/.taw-kit/
```

Uninstall only touches files installed by taw-kit (identified by the `.taw-kit-owned` marker and fixed agent/hook names). **Your personal skills in `~/.claude/skills/` are never touched.**

---

## Docs

The primary docs (quickstart, troubleshooting, install-windows, video-script) are maintained in Vietnamese — this kit targets Vietnamese non-dev users first. For an English technical overview suitable for dev audit, see:

- **Architecture:** [docs/en/architecture.md](./docs/en/architecture.md) — how the orchestrator works

---

## License

Commercial — see [LICENSE](./LICENSE). You own the products you build with taw-kit 100%. The kit itself cannot be redistributed or resold.

## Support

Contact in your order email — or visit [theagents.work](https://www.theagents.work/).
