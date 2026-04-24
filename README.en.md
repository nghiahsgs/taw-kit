# taw-kit

> Opinionated Claude Code kit for non-developers — ship real products with `/taw <describe what you want>`.

**Website:** [theagents.work](https://www.theagents.work/)
**Discord:** [join the community](https://discord.gg/6nhMhhMV) — questions, bug reports, feature requests

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
| **git** | Clones the public repo | `brew install git` / `apt install git` |
| **Claude Pro/Max subscription** | Required so Claude Code can log in via `claude login` (browser OAuth) | [claude.ai](https://claude.ai) |

> taw-kit only supports Claude Code sign-in via a Claude Pro/Max subscription. Anthropic API key auth is **not** supported. taw-kit itself makes no API calls — it's just markdown + shell scripts; all AI usage goes through Claude Code.

**OS:** macOS, Linux, or Windows via WSL2. On Windows, follow the step-by-step guide in [docs/install-windows.md](./docs/install-windows.md) first, then come back here.

The repo is public on GitHub. Clone and run the installer:

```bash
git clone https://github.com/nghiahsgs/taw-kit.git ~/.taw-kit
bash ~/.taw-kit/scripts/install.sh
```

The installer will:

1. Detect your OS (macOS / Linux / WSL).
2. Check that prerequisites are installed (warn if missing).
3. Install skills, agents, hooks, and templates into `~/.claude/`.
4. Symlink `tawkit` into `/usr/local/bin/` (asks for sudo once).
5. Run `tawkit doctor` to confirm everything works.

About 30 seconds after the clone finishes.

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

The primary docs (quickstart, install-windows) are maintained in Vietnamese — this kit targets Vietnamese non-dev users first. For an English technical overview suitable for dev audit, see:

- **Architecture:** [docs/en/architecture.md](./docs/en/architecture.md) — how the orchestrator works

---

## License

Source-available — free during public beta. See [LICENSE](./LICENSE) for the full text.

- **You may:** clone it, use taw-kit to build as many products as you want. Products you build are 100% yours, no attribution required.
- **You may not:** redistribute this repo (mirror, rebranded fork, upload to package registries), or resell taw-kit or any derivative of it.

The author reserves the right to change the license in future versions (e.g. introduce a paid tier). Clones obtained today remain under the current terms.

## Support

Contact in your order email — or visit [theagents.work](https://www.theagents.work/).
