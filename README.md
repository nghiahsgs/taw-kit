# taw-kit

> Opinionated Claude Code kit for non-developers — ship real products with `/taw <describe what you want>`.

`/taw build me an online shop selling cosmetics` → clarify → plan → code → test → deploy → live URL.

## Install

```bash
curl -fsSL https://install.tawkit.vn | bash
```

This one-liner will: check prerequisites (git, node ≥20, claude, gh) → log into GitHub → clone your private repo into `~/.taw-kit/` → install skills and agents into `~/.claude/` → run `tawkit doctor`.

Step-by-step walkthrough: [`docs/quickstart.md`](./docs/quickstart.md)

## Try it

After install, open Claude Code in a new folder and type:

```
/taw build me a landing page for my online course
```

Or start from a built-in preset:

```
tawkit new shop-online
```

## Docs

- **Quickstart:** [`docs/quickstart.md`](./docs/quickstart.md)
- **Troubleshooting:** [`docs/troubleshooting.md`](./docs/troubleshooting.md)
- **Architecture:** [`docs/en/architecture.md`](./docs/en/architecture.md)

## Uninstall

```bash
tawkit uninstall          # remove skills/agents/hooks from ~/.claude, keep ~/.taw-kit/
tawkit uninstall --full   # also remove the cloned repo at ~/.taw-kit/
```

Uninstall only touches files installed by taw-kit (identified by the `.taw-kit-owned` marker and fixed agent/hook names). Your personal skills in `~/.claude/skills/` are **not affected**.

## System requirements

- macOS, Linux, or Windows (via WSL2)
- Node.js ≥ 20
- Claude Code CLI
- Git + GitHub CLI (`gh`)
- Anthropic API key (bring your own)

## License

Commercial — see [LICENSE](./LICENSE). Do not share the repo; do not upload to other marketplaces.
