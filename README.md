# taw-kit

> Bộ kit Claude Code cho người không biết code — ship sản phẩm thật chỉ bằng một câu `/taw <mô tả cái bạn muốn>`.

**Website:** [theagents.work](https://www.theagents.work/)

> English version: [README.en.md](./README.en.md)

```
/taw làm cho tôi một shop mỹ phẩm online
  → hỏi lại cho rõ (3–5 câu)
  → lên plan 5 gạch đầu dòng, bạn duyệt
  → code + test + review
  → deploy (Vercel, Docker, hoặc VPS)
  → trả về URL đã live
```

> Xem demo & mua bộ kit tại **[theagents.work](https://www.theagents.work/)** — ship sản phẩm thật trong 20 phút.

---

## Bạn nhận được gì

- **34 skills, 6 agents, 4 hooks** — cài sẵn vào `~/.claude/`
- **Design có gu** — skill `frontend-design` của Anthropic (Apache 2.0) được bundle sẵn, giúp giao diện không bị "AI slop". Xem chi tiết tại [THIRD-PARTY-NOTICES.md](./THIRD-PARTY-NOTICES.md)
- **CLI `tawkit`** — install, update, doctor, uninstall, scaffold từ preset
- **5 preset** — landing page, shop online, CRM, blog, dashboard
- **3 đích deploy** — Vercel (mặc định), Docker image, hoặc VPS qua SSH
- **License thương mại** — làm và bán bao nhiêu sản phẩm cũng được

---

## Cài đặt

### Trước khi bắt đầu

Máy bạn cần có:

| Thứ | Để làm gì | Cài ở đâu |
|-----|-----------|-----------|
| **Claude Code** | CLI để chạy skill | [docs.claude.com/claude-code](https://docs.claude.com/claude-code) |
| **Node.js ≥ 20** | Dự án bạn sinh ra chạy trên này | [nodejs.org](https://nodejs.org) |
| **git** | Installer cần dùng | `brew install git` / `apt install git` |
| **GitHub CLI (`gh`)** | Để clone repo private | `brew install gh` / `apt install gh` |
| **Tài khoản Claude đã login** | Để Claude Code chạy được — 1 trong 2: subscription Claude Pro/Max (login qua `claude login`) **hoặc** API key Anthropic (trả theo lượng dùng) | Subscription: [claude.ai](https://claude.ai) · API key: [console.anthropic.com](https://console.anthropic.com) |

> taw-kit bản thân không gọi API — chỉ là file markdown + script shell. Cái cần auth là **Claude Code** (CLI của Anthropic). Đã có Claude Pro/Max rồi thì không cần API key.

**Hệ điều hành:** macOS, Linux, hoặc Windows qua WSL2. Nếu dùng Windows, làm theo [docs/install-windows.md](./docs/install-windows.md) trước, xong quay lại đây.

### Cách A — One-liner (khuyên dùng)

```bash
curl -fsSL https://install.tawkit.dev | bash
```

Script này sẽ:

1. Nhận diện OS (macOS / Linux / WSL).
2. Check xem prerequisites đã cài đủ chưa (cảnh báo nếu thiếu).
3. Login GitHub cho bạn nếu chưa login.
4. Clone repo private taw-kit về `~/.taw-kit/`.
5. Cài skills, agents, hooks, templates vào `~/.claude/`.
6. Symlink `tawkit` vào `/usr/local/bin/` (xin sudo đúng 1 lần).
7. Chạy `tawkit doctor` để xác nhận mọi thứ hoạt động.

Tổng cộng mất tầm 30 giây.

### Cách B — Cài thủ công (nếu không tin `curl | bash`)

```bash
# 1. Clone repo private (bạn cần được invite vào taw-kit/taw-kit)
gh repo clone <your-org>/taw-kit ~/.taw-kit

# 2. Chạy installer
bash ~/.taw-kit/scripts/install.sh

# 3. Kiểm tra
tawkit doctor
```

### Cách C — Đọc script trước khi chạy

Muốn xem script kỹ trước khi chạy?

```bash
curl -fsSL https://install.tawkit.dev -o /tmp/taw-install.sh
less /tmp/taw-install.sh          # đọc trước
bash /tmp/taw-install.sh          # chạy khi bạn thấy yên tâm
```

---

## Chạy lần đầu

Mở Claude Code trong 1 folder trống:

```bash
mkdir my-first-product && cd my-first-product
claude
```

Trong Claude Code:

```
/taw làm cho tôi 1 landing page bán khoá học online
```

taw-kit sẽ hỏi bạn 3–5 câu cho rõ yêu cầu, render ra 1 plan, rồi đợi bạn duyệt. Gõ `yes` là nó chạy full pipeline: plan → research → code → test → security review → deploy. Tổng tầm 15–20 phút.

Hoặc bắt đầu từ preset có sẵn:

```bash
tawkit new shop-online
```

---

## Chọn đích deploy

Sau khi code xong, `/taw-deploy` sẽ hỏi bạn deploy ở đâu:

```
Deploy ở đâu?
  1. vercel  — Hosting cloud miễn phí, dễ nhất (khuyên dùng)
  2. docker  — Build Docker image, tự deploy lên host của bạn
  3. vps     — Deploy lên VPS riêng qua SSH (systemd + nginx)
```

| Đích | Công sức setup | Chi phí | Phù hợp với |
|------|----------------|---------|-------------|
| **Vercel** | Không cần gì | Free tier đủ cho shop nhỏ | Non-dev, prototype, landing page |
| **Docker** | Cần cài Docker | Free (bạn tự host) | Giao gói cho khách, không phụ thuộc cloud |
| **VPS** | Cần biết SSH + systemd | Tiền thuê VPS | Kiểm soát hoàn toàn, traffic lớn, yêu cầu về dữ liệu |

Đổi đích sau cũng được — `/taw-deploy --target=docker` trên 1 dự án đã deploy Vercel sẽ sinh Dockerfile mà không đụng gì tới Vercel deployment đang chạy.

---

## Cập nhật

```bash
tawkit update
```

Lệnh này kéo bản mới nhất của taw-kit từ GitHub về, cài lại, và in ra changelog.

## Kiểm tra cài đặt

```bash
tawkit doctor
```

Chạy 10 check: Claude Code đã cài, version git/node, `~/.claude/` có quyền ghi, hook chạy được, auth API, locale UTF-8, v.v.

## Gỡ cài đặt

```bash
tawkit uninstall          # xoá skill/agent/hook khỏi ~/.claude, giữ ~/.taw-kit/
tawkit uninstall --full   # xoá luôn repo đã clone ở ~/.taw-kit/
```

Uninstall chỉ đụng vào file do taw-kit cài (nhận diện qua marker `.taw-kit-owned` và tên agent/hook cố định). **Skill cá nhân của bạn trong `~/.claude/skills/` không bao giờ bị đụng.**

---

## Tài liệu

- **Quickstart:** [docs/quickstart.md](./docs/quickstart.md) — 5 phút từ số 0 tới URL live
- **Troubleshooting:** [docs/troubleshooting.md](./docs/troubleshooting.md) — 20 lỗi thường gặp + cách fix
- **Architecture (EN):** [docs/en/architecture.md](./docs/en/architecture.md) — cách orchestrator hoạt động (dành cho dev)
- **Script video:** [docs/video-script.md](./docs/video-script.md) — kịch bản onboarding sẵn để quay

---

## License

License thương mại — xem [LICENSE](./LICENSE). Sản phẩm bạn làm ra bằng taw-kit là của bạn 100%. Bản thân bộ kit thì không được phân phối lại hay bán lại.

## Hỗ trợ

Liên hệ trong email đơn hàng — hoặc vào [theagents.work](https://www.theagents.work/).
