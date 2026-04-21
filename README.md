# taw-kit

> Opinionated Claude Code kit for Vietnamese non-developers — ship real products with `/taw <mô tả bằng tiếng Việt>`.

`/taw làm cho tôi 1 shop online bán mỹ phẩm` → clarify → plan → code → test → deploy → live URL.

## Install (sau khi mua)

```bash
curl -fsSL https://install.tawkit.vn | bash
```

One-liner này sẽ: kiểm tra prerequisites (git, node ≥20, claude, gh) → login GitHub → clone repo riêng của bạn vào `~/.taw-kit/` → cài skills và agents vào `~/.claude/` → chạy `tawkit doctor`.

Chi tiết từng bước (tiếng Việt): [`docs/vi/quickstart.md`](./docs/vi/quickstart.md)

## Dùng thử

Sau khi cài, mở Claude Code trong một thư mục mới và gõ:

```
/taw lam cho toi landing page ban khoa hoc online
```

Hoặc bắt đầu từ preset sẵn có:

```
tawkit new shop-online
```

## Docs

- **Vietnamese (primary):** [`docs/vi/quickstart.md`](./docs/vi/quickstart.md), [`docs/vi/troubleshooting.md`](./docs/vi/troubleshooting.md)
- **English (architecture):** [`docs/en/architecture.md`](./docs/en/architecture.md)

## Yêu cầu hệ thống

- macOS, Linux, hoặc Windows (qua WSL2)
- Node.js ≥ 20
- Claude Code CLI
- Git + GitHub CLI (`gh`)
- API key Anthropic (user tự có)

## License

Commercial — xem [LICENSE](./LICENSE). Không chia sẻ repo; không upload lên marketplace khác.
