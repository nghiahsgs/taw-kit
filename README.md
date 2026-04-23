# taw-kit

> Bộ kit Claude Code cho người không biết code — ra mắt sản phẩm thật chỉ bằng một câu `/taw <mô tả cái bạn muốn>`.

**Website:** [theagents.work](https://www.theagents.work/)

> English version: [README.en.md](./README.en.md)

```
/taw làm cho tôi một shop mỹ phẩm online
  → hỏi lại cho rõ (3–5 câu)
  → lập kế hoạch 5 ý, bạn duyệt
  → code + test + review
  → deploy (Vercel, Docker, hoặc VPS)
  → trả về URL đã chạy
```

> Xem demo & mua bộ kit tại **[theagents.work](https://www.theagents.work/)** — ra mắt sản phẩm thật trong 20 phút.

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
| **Node.js ≥ 20** | Dự án taw-kit tạo ra sẽ chạy trên đây | [nodejs.org](https://nodejs.org) |
| **git** | Để clone repo | `brew install git` / `apt install git` |
| **Gói Claude Pro/Max** | Để Claude Code đăng nhập được (gõ `claude login`, OAuth qua trình duyệt) | [claude.ai](https://claude.ai) |

> taw-kit chỉ hỗ trợ đăng nhập Claude Code bằng gói Claude Pro/Max. Chưa hỗ trợ API key Anthropic. Bản thân taw-kit không gọi API trực tiếp — chỉ là file markdown + script shell, phần AI do Claude Code đảm nhiệm.

**Hệ điều hành:** macOS, Linux, hoặc Windows qua WSL2. Nếu dùng Windows, làm theo [docs/install-windows.md](./docs/install-windows.md) trước rồi quay lại đây.

Repo công khai trên GitHub. Clone và chạy trình cài đặt:

```bash
git clone https://github.com/nghiahsgs/taw-kit.git ~/.taw-kit
bash ~/.taw-kit/scripts/install.sh
```

Trình cài đặt sẽ:

1. Phát hiện hệ điều hành (macOS / Linux / WSL).
2. Kiểm tra điều kiện cần (cảnh báo nếu thiếu).
3. Cài skills, agents, hooks, templates vào `~/.claude/`.
4. Tạo symlink `tawkit` vào `/usr/local/bin/` (xin quyền sudo đúng 1 lần).
5. Chạy `tawkit doctor` để xác nhận mọi thứ hoạt động.

Mất tầm 30 giây sau khi clone xong.

---

## Chạy lần đầu

Mở Claude Code trong một thư mục trống:

```bash
mkdir my-first-product && cd my-first-product
claude
```

Trong Claude Code:

```
/taw làm cho tôi 1 landing page bán khoá học online
```

taw-kit sẽ hỏi bạn 3–5 câu cho rõ yêu cầu, hiển thị một kế hoạch, rồi đợi bạn duyệt. Gõ `yes` là nó chạy toàn bộ quy trình: plan → research → code → test → security review → deploy. Tổng tầm 15–20 phút.

Hoặc bắt đầu từ preset có sẵn:

```bash
tawkit new shop-online
```

---

## Chọn nơi deploy

Sau khi code xong, `/taw-deploy` sẽ hỏi bạn deploy ở đâu:

```
Deploy ở đâu?
  1. vercel  — Dịch vụ cloud miễn phí, dễ nhất (khuyên dùng)
  2. docker  — Build Docker image, tự deploy lên host của bạn
  3. vps     — Deploy lên VPS riêng qua SSH (systemd + nginx)
```

| Nơi deploy | Công sức cài đặt | Chi phí | Phù hợp với |
|------------|------------------|---------|-------------|
| **Vercel** | Không cần gì | Free tier đủ cho shop nhỏ | Non-dev, prototype, landing page |
| **Docker** | Cần cài Docker | Miễn phí (bạn tự host) | Đóng gói giao khách, không phụ thuộc cloud |
| **VPS** | Cần biết SSH + systemd | Tiền thuê VPS | Kiểm soát hoàn toàn, traffic lớn, có yêu cầu về dữ liệu |

Đổi nơi deploy sau cũng được — `/taw-deploy --target=docker` trên một dự án đã deploy Vercel sẽ sinh Dockerfile mà không ảnh hưởng tới bản Vercel đang chạy.

---

## Cập nhật

```bash
tawkit update
```

Lệnh này tải bản mới nhất của taw-kit từ GitHub về, cài lại, và hiển thị changelog.

## Kiểm tra cài đặt

```bash
tawkit doctor
```

Chạy 10 mục kiểm tra: Claude Code đã cài, phiên bản git/node, `~/.claude/` có quyền ghi, hook chạy được, auth API, locale UTF-8, v.v.

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

Source-available — free dùng trong public beta. Xem [LICENSE](./LICENSE) cho đầy đủ.

- **Được:** clone, dùng taw-kit làm bao nhiêu sản phẩm cũng được. Sản phẩm bạn làm ra là của bạn 100%, không cần trích dẫn.
- **Không được:** phân phối lại repo này (mirror, fork đăng chỗ khác, đẩy lên registry), bán lại taw-kit hay bản rebrand của nó.

Tác giả giữ quyền đổi license ở version tương lai (ví dụ mở gói trả phí). Bản anh clone hôm nay vẫn theo điều khoản hiện tại.

## Hỗ trợ

Liên hệ trong email đơn hàng — hoặc vào [theagents.work](https://www.theagents.work/).
