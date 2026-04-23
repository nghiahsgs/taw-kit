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
| **git** | Để clone repo | `brew install git` / `apt install git` |
| **Subscription Claude Pro/Max** | Để Claude Code login được (gõ `claude login`, OAuth qua trình duyệt) | [claude.ai](https://claude.ai) |

> taw-kit chỉ hỗ trợ đăng nhập Claude Code bằng subscription Claude Pro/Max. Chưa hỗ trợ API key Anthropic. Bản thân taw-kit không gọi API trực tiếp — chỉ là file markdown + script shell, phần AI là do Claude Code chạy.

**Hệ điều hành:** macOS, Linux, hoặc Windows qua WSL2. Nếu dùng Windows, làm theo [docs/install-windows.md](./docs/install-windows.md) trước, xong quay lại đây.

Repo public trên GitHub. Clone và chạy installer:

```bash
git clone https://github.com/nghiahsgs/taw-kit.git ~/.taw-kit
bash ~/.taw-kit/scripts/install.sh
```

Installer sẽ:

1. Nhận diện OS (macOS / Linux / WSL).
2. Check prerequisites (cảnh báo nếu thiếu).
3. Cài skills, agents, hooks, templates vào `~/.claude/`.
4. Symlink `tawkit` vào `/usr/local/bin/` (xin sudo đúng 1 lần).
5. Chạy `tawkit doctor` để xác nhận mọi thứ hoạt động.

Mất tầm 30 giây sau khi clone xong.

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
- **Cài trên Windows:** [docs/install-windows.md](./docs/install-windows.md) — hướng dẫn WSL2 chi tiết
- **Architecture (EN):** [docs/en/architecture.md](./docs/en/architecture.md) — cách orchestrator hoạt động (dành cho dev)

---

## License

License thương mại — xem [LICENSE](./LICENSE). Sản phẩm bạn làm ra bằng taw-kit là của bạn 100%. Bản thân bộ kit thì không được phân phối lại hay bán lại.

## Hỗ trợ

Liên hệ trong email đơn hàng — hoặc vào [theagents.work](https://www.theagents.work/).
