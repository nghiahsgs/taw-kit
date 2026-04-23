# Chào mừng! 5 phút để có sản phẩm đầu tiên

Bạn vừa mua taw-kit. Cảm ơn bạn! Hướng dẫn này đưa bạn đi từ "chưa cài gì" tới "1 website thật đang live trên internet" trong tầm 5 phút setup + 15 phút ngồi chờ máy chạy.

Coi taw-kit như 1 anh dev trực 24/7. Bạn mô tả thứ bạn muốn, bộ kit tự code, test, rồi đẩy lên internet. Bạn chỉ việc nhâm nhi cà phê.

---

## Cần chuẩn bị gì

3 thứ. Không nhiều đâu.

1. **Claude Code đã cài** — 1 app AI chạy trong terminal. Nếu chưa có, lên trang chủ Claude Code tải về (Mac / Windows / Linux), chạy installer, rồi mở Terminal gõ `claude` để xác nhận.
2. **1 subscription Claude Pro hoặc Max** — để Claude Code login qua OAuth được. Đăng ký ở [claude.ai](https://claude.ai), sau đó trong terminal gõ `claude login`, trình duyệt mở ra cho bạn click Accept. Xong. (taw-kit **không** hỗ trợ login bằng API key Anthropic, chỉ subscription.)
3. **1 Terminal đang mở** — Mac thì là "Terminal", Windows thì "PowerShell" hoặc "Windows Terminal". Cứ mở lên, không cần học gì cao siêu. Cả hành trình taw-kit chỉ bắt bạn paste tầm 3 lệnh.

Lo "tôi không biết code, xài được không?" — yên tâm. taw-kit sinh ra cho người không biết code. Bạn chỉ cần copy-paste lệnh.

---

## Bước 1: Cài taw-kit

Mở Terminal. Copy đoạn dưới, paste, Enter:

```bash
git clone https://github.com/nghiahsgs/taw-kit.git ~/.taw-kit
bash ~/.taw-kit/scripts/install.sh
```

Lệnh đầu clone repo public về máy (~/.taw-kit/), lệnh sau chạy installer để copy skill vào folder Claude Code. Bạn sẽ thấy vài dòng log trôi qua. Chờ tầm 30 giây.

Xong sẽ hiện:

```
taw-kit installed successfully. Type /taw in Claude Code to start.
```

Vậy là cài xong. Dễ mà đúng không?

**Lưu ý nhỏ:** nếu Terminal báo "git: command not found" thì cài git trước. Mac: `brew install git`. Linux: `sudo apt install git`. Windows: WSL2 có sẵn khi làm theo [docs/install-windows.md](./install-windows.md).

---

## Bước 2: Login Claude Code 1 lần duy nhất

Vẫn trong Terminal, gõ:

```bash
claude
```

Claude Code mở lên. Lần đầu nó sẽ hỏi login — chọn nhánh đăng nhập bằng subscription (Claude Pro/Max). Trình duyệt mở ra, click Accept, quay lại terminal. Xong, lần sau không phải làm lại.

**(Tuỳ chọn)** Nếu sản phẩm cần database (để lưu đơn hàng, danh sách khách, v.v.), đăng ký 1 tài khoản free ở [supabase.com](https://supabase.com), tạo project, copy URL + anon key, để sẵn — taw-kit có thể sẽ hỏi.

Nếu bạn chỉ làm 1 landing page đơn giản thì bỏ qua Supabase cũng được.

---

## Bước 3: Gõ /taw

Giờ tới phần vui. Trong cửa sổ Claude Code, gõ:

```
/taw làm cho tôi 1 website quán cà phê
```

(Thay "quán cà phê" bằng thứ bạn muốn — "shop quần áo", "blog review sách", "landing page khoá học online", v.v.)

taw-kit hỏi bạn 3–5 câu để rõ yêu cầu. Ví dụ:

```
1. Tên shop/thương hiệu?
2. Muốn có giỏ hàng + thanh toán online, hay chỉ hiện menu?
3. Tông màu thích? (ấm, lạnh, hay trung tính)
4. Có cần form đặt bàn không?
5. Khách hàng mục tiêu là ai?
```

Trả lời theo ý bạn. Không cần trả lời hết — câu nào không quan tâm cứ gõ "tuỳ bạn".

Xong taw-kit show ra 1 plan ngắn (tầm 5 dòng):

```
Plan:
1. Setup Next.js + Tailwind + Supabase
2. Làm 4 trang: home, menu, cart, thank-you
3. Gắn Polar để thanh toán
4. Deploy lên Vercel (mặc định) — hoặc Docker / VPS nếu bạn muốn
5. Ước chừng 15–20 phút
  
Plan này ổn không? (gõ: yes / edit / cancel)
```

Đọc lướt qua. Ổn → gõ `yes`. Muốn sửa → gõ `edit` và tả thay đổi. Muốn huỷ → gõ `cancel`.

---

## Bước 4: Chờ ~15 phút rồi nhận URL

Sau khi gõ `yes`, tập trung vào ly cà phê đi. taw-kit làm âm thầm và báo cáo tiến độ:

```
✓ Done: plan ready
✓ Done: research
✓ Done: code written
✓ Done: build tested
✓ Done: security review
✓ Done: deployed
```

Mỗi dòng là 1 "nhân công" AI làm 1 việc. Tổng tầm 15–20 phút. Trong lúc này bạn không cần làm gì. Đừng đóng Terminal. Đừng đóng Claude Code. Đừng rút Wi-Fi. Chỉ cần chờ.

Đôi lúc 1 nhân công cần bạn quyết định (ví dụ "logo tròn hay vuông?") — Claude sẽ dừng và hỏi. Trả lời xong nó chạy tiếp.

---

## Bước 5: Xong! Share URL

Cuối cùng bạn sẽ thấy:

```
Done! 🎉 Open: https://your-product-name.vercel.app
Project files: /Users/you/tawkit-projects/coffee-shop
Want to add a feature? Type: /taw-add <description>
Something broken? Type: /taw-fix
```

Click URL. Bùm — web của bạn đang live trên internet. Share cho bạn bè, khách hàng, đăng mạng xã hội. Hosting free vĩnh viễn (Vercel free tier).

Muốn đổi logo, sửa chữ, thêm sản phẩm? Gõ `/taw-add <mô tả>` — taw-kit update và deploy lại.

Muốn fix gì đó? Gõ `/taw-fix` — nó tự tìm và fix các lỗi thường gặp.

---

## Nếu bị lỗi

Chuyện bình thường. Khoảng 50% user lần đầu gặp lỗi nhỏ. Thử theo thứ tự:

1. **Đọc error ngay trên màn hình** — thường nó gợi ý cách fix rồi.
2. **Gõ `/taw-fix`** — lệnh này tự chẩn đoán và fix phần lớn lỗi thường gặp.
3. **Vẫn tắc?** Hỏi trong cộng đồng taw-kit (link có trong email đơn hàng). Paste nguyên đoạn lỗi; đừng paste `.env.local` (chứa secret).

---

## FAQ

**Có phải trả thêm tiền cho Claude/Anthropic không?**
Có — bạn cần 1 subscription Claude Pro hoặc Max (trả thẳng cho Anthropic, không phải taw-kit). Gói cố định tháng, dùng thả ga trong hạn mức sử dụng.

**Có phải trả tiền hosting cho web tôi làm ra không?**
Không. Free tier của Vercel đủ cho shop nhỏ (100GB traffic/tháng). Khi nào traffic lớn thì mới nâng cấp.

**Tôi sửa code tay được không?**
Được. File dự án nằm ở `~/tawkit-projects/<tên>`. Mở bằng editor gì cũng được (VS Code, Sublime, kể cả Notepad). Nếu bạn không code được thì cứ xài `/taw-add` và `/taw-fix` — an toàn hơn.

**Làm được nhiều web không?**
Được. Mỗi lần `/taw` tạo 1 dự án mới. Không giới hạn.

**Tôi xài Windows — chạy được không?**
Được. taw-kit chạy trên Mac, Windows (qua WSL2), và Linux. Miễn Claude Code hỗ trợ OS của bạn là xong.

**Dữ liệu khách hàng của tôi có an toàn không?**
taw-kit không gửi dữ liệu của bạn đi đâu hết. File nằm trên máy bạn và tài khoản Vercel/Supabase mà bạn sở hữu. Không có gì chảy qua server taw-kit.

**Bán lại web tôi làm ra được không?**
Được. Code sinh ra là của bạn 100%. License taw-kit cho phép dùng thương mại không giới hạn (với người mua gốc).

**Công ty tôi cấm cài phần mềm — vẫn dùng được không?**
Thử Claude Code Web (claude.ai/code trên trình duyệt). Vài tính năng bị hạn chế nhưng taw-kit cơ bản vẫn chạy.

**taw-kit có update không?**
Có. Thi thoảng chạy `tawkit update` để lấy bản mới. Xem [CHANGELOG.md](../CHANGELOG.md) để biết có gì thay đổi.

**Tôi muốn học code thật sự sau này.**
Tốt. Đọc code taw-kit sinh ra là 1 cách học nhanh. Vào cộng đồng hỏi đáp; nhiều bạn đã đi từ "không biết gì" lên junior dev trong vài tháng.

---

Chúc build vui! Nếu kẹt, hỏi trong cộng đồng taw-kit (link có trong email đơn hàng).
