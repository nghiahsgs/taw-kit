# Chào mừng! 5 phút để chạy sản phẩm đầu tiên

Bạn vừa mua taw-kit. Cảm ơn bạn! Bài này sẽ dắt bạn đi từ "chưa cài gì" đến "có một web thật chạy trên internet" trong khoảng 5 phút thiết lập + 15 phút đợi máy làm việc.

Hãy hình dung taw-kit như một bạn lập trình viên luôn trực 24/7. Bạn mô tả bằng tiếng Việt muốn làm cái gì, bạn ấy sẽ tự viết code, tự kiểm tra, tự đưa lên internet cho bạn. Bạn chỉ cần ngồi uống cà phê đợi.

---

## Bạn cần gì trước khi bắt đầu

Ba thứ. Không nhiều.

1. **Claude Code đã cài trên máy** — đây là ứng dụng AI chạy trong cửa sổ dòng lệnh (terminal). Nếu chưa có, vào trang chủ Claude Code tải bản dành cho máy của bạn (Mac / Windows / Linux) và chạy file cài. Sau đó mở Terminal và gõ `claude` xem có phản hồi không.
2. **API key của Anthropic** — coi như mã tài khoản để Claude biết bạn là ai. Vào console của Anthropic, đăng ký, nạp tối thiểu 5 đô, rồi copy cái chuỗi bắt đầu bằng `sk-ant-...`. Cất vào file ghi chú tạm, lát dùng.
3. **Terminal mở sẵn** — trên Mac là ứng dụng "Terminal", trên Windows là "PowerShell" hoặc "Windows Terminal". Chỉ cần mở ra, không phải học gì cả. taw-kit chỉ bắt bạn gõ khoảng 3 câu lệnh trong toàn bộ hành trình.

Nếu bạn đang lo "tôi không biết lập trình, có làm được không?" — yên tâm. Mục tiêu của taw-kit là đúng dành cho người không biết code. Bạn chỉ cần biết copy lệnh và paste vào terminal.

---

## Bước 1: Cài taw-kit

Mở Terminal. Copy nguyên dòng bên dưới, paste vào, rồi nhấn Enter:

```bash
curl -fsSL https://tawkit.dev/install.sh | bash
```

Dòng này sẽ tải bộ cài về và chạy tự động. Bạn sẽ thấy vài dòng chữ hiện ra — đó là script đang sao chép file vào thư mục của Claude Code. Đợi khoảng 30 giây.

Khi xong, bạn thấy dòng:

```
taw-kit installed successfully. Type /taw in Claude Code to start.
```

Vậy là xong bước cài. Đơn giản phải không?

**Ghi chú nhỏ:** nếu dòng lệnh báo "curl: command not found", bạn cần cài curl trước. Trên Mac: `brew install curl`. Trên Windows: curl đã có sẵn trong Windows 10 trở lên, kiểm tra lại chính tả.

---

## Bước 2: Cấu hình 1 lần

Bây giờ Claude cần biết API key của bạn. Vẫn ở Terminal, gõ:

```bash
claude
```

Claude Code sẽ mở lên. Lần đầu tiên, nó hỏi bạn dán API key. Paste cái chuỗi `sk-ant-...` bạn lấy ở trên vào, nhấn Enter. Xong. Lần sau khỏi phải nhập lại.

**(Không bắt buộc)** Nếu bạn muốn sản phẩm có cơ sở dữ liệu (ví dụ lưu đơn hàng, lưu danh sách khách), vào [supabase.com](https://supabase.com) đăng ký tài khoản miễn phí. Tạo một dự án mới, lấy URL và anon key, cất sẵn để lát taw-kit hỏi tới.

Nếu bạn chỉ định làm landing page đơn giản thì bỏ qua Supabase cũng được.

---

## Bước 3: Gõ /taw

Đây là phần vui. Trong cửa sổ Claude Code, gõ:

```
/taw làm cho tôi một trang bán cà phê
```

(Bạn có thể thay "trang bán cà phê" bằng bất cứ thứ gì bạn muốn — "shop quần áo", "blog review sách", "trang giới thiệu khóa học", v.v.)

taw-kit sẽ hỏi lại bạn 3–5 câu để hiểu rõ hơn. Ví dụ:

```
1. Tên quán/thương hiệu là gì?
2. Muốn có giỏ hàng và thanh toán online không, hay chỉ giới thiệu menu?
3. Tông màu chủ đạo bạn thích? (ấm, lạnh, hay trung tính)
4. Có muốn tích hợp form đặt bàn không?
5. Dự kiến khách hàng mục tiêu là ai?
```

Trả lời từng câu theo ý bạn. Không cần trả lời hết — cứ cái nào không rõ thì ghi "tùy bạn" là được.

Sau đó taw-kit hiện một kế hoạch ngắn khoảng 5 dòng:

```
Kế hoạch:
1. Setup Next.js + Tailwind + Supabase
2. Xây 4 trang: trang chủ, menu, giỏ hàng, cảm ơn
3. Kết nối Polar để thanh toán
4. Deploy lên Vercel qua Shipkit
5. Dự kiến: 15–20 phút

Kế hoạch này có OK không? (gõ: yes / sửa / hủy)
```

Đọc qua. Thấy ổn thì gõ `yes`. Muốn điều chỉnh thì gõ `sửa` rồi nói ra thay đổi. Muốn bỏ thì gõ `hủy`.

---

## Bước 4: Chờ 15 phút + nhận URL

Gõ `yes` xong, tập trung vào ly cà phê đi. taw-kit sẽ âm thầm làm việc, thỉnh thoảng báo tiến độ:

```
✓ Đã xong: lập kế hoạch
✓ Đã xong: tra tài liệu
✓ Đã xong: viết code
✓ Đã xong: kiểm thử build
✓ Đã xong: review an toàn
✓ Đã xong: triển khai
```

Mỗi dòng ứng với một "công nhân AI" làm một việc. Tổng cộng khoảng 15–20 phút. Trong thời gian này, bạn không phải làm gì hết. Đừng tắt Terminal. Đừng đóng Claude Code. Đừng ngắt WiFi. Chỉ đợi.

Thỉnh thoảng một "công nhân" cần hỏi quyết định quan trọng (ví dụ "muốn logo tròn hay vuông") — Claude sẽ tạm dừng và hỏi bạn. Trả lời xong nó chạy tiếp.

---

## Bước 5: Xong! Chia sẻ URL

Khi tất cả xong, bạn sẽ thấy dòng cuối:

```
Xong! 🎉 Truy cập: https://tên-san-pham-của-bạn.vercel.app
File dự án ở: /Users/bạn/tawkit-projects/shop-ca-phe
Muốn thêm tính năng? Gõ: /taw-add <mô tả tính năng>
Muốn sửa lỗi? Gõ: /taw-fix
```

Click vào cái URL đó. Boom — web của bạn đang chạy trên internet. Gửi cho bạn bè, gửi cho khách, post Facebook. Miễn phí hosting vĩnh viễn luôn (Vercel free tier).

Muốn đổi logo, sửa chữ, thêm sản phẩm? Gõ thêm `/taw-add <mô tả>`, taw-kit sẽ cập nhật thêm và tự deploy lại.

Muốn sửa lỗi gì đó? Gõ `/taw-fix`, nó tự tìm và sửa.

---

## Nếu bị lỗi

Không sao cả. 50% người dùng lần đầu sẽ gặp ít nhất một lỗi nhỏ. Hãy thử theo thứ tự:

1. **Đọc thông báo lỗi trên màn hình** — thường đã có gợi ý cách sửa.
2. **Gõ `/taw-fix`** — lệnh này sẽ tự chẩn đoán và sửa phần lớn lỗi thường gặp.
3. **Vẫn không được?** Mở file [docs/vi/troubleshooting.md](./troubleshooting.md) tra theo tên lỗi.
4. **Cuối cùng:** hỏi trong cộng đồng taw-kit (link trong email đơn hàng). Gửi kèm đoạn text lỗi, đừng dán file `.env.local` (có chứa mật khẩu).

---

## Câu hỏi thường gặp

**Tôi có phải trả thêm tiền cho Claude/Anthropic không?**
Có. taw-kit dùng Claude để chạy. Mỗi sản phẩm bạn build tốn khoảng 0,5–2 đô tiền API. Nạp 10 đô dùng được vài chục lần.

**Web tôi làm ra có phải trả phí hosting không?**
Không. Vercel free tier đủ cho hầu hết shop nhỏ (100GB lưu lượng/tháng). Khi nào đông khách hãy nghĩ tới gói trả phí.

**Tôi có thể sửa code tay không?**
Được. File dự án nằm trong `~/tawkit-projects/<tên>`. Bạn mở bằng bất cứ trình soạn thảo nào (VS Code, Sublime, thậm chí Notepad). Nhưng nếu không biết code, khuyên dùng `/taw-add` và `/taw-fix` cho an toàn.

**Tôi có thể làm nhiều web cùng lúc không?**
Có. Mỗi lần gõ `/taw` tạo một dự án mới. Không giới hạn số lượng.

**Tôi dùng Windows, có được không?**
Được. taw-kit chạy trên cả Mac, Windows, Linux. Chỉ cần Claude Code hỗ trợ hệ của bạn là ok.

**Dữ liệu khách hàng của tôi có an toàn không?**
taw-kit không gửi dữ liệu của bạn đi đâu. File chỉ nằm trên máy bạn và server Vercel/Supabase mà bạn sở hữu. Không qua máy chủ của taw-kit.

**Tôi có thể bán lại web mình làm không?**
Được. Code thuộc về bạn 100%. Giấy phép taw-kit cho phép dùng vô thời hạn cho mục đích thương mại cá nhân.

**Không dùng được vì công ty cấm cài phần mềm?**
Thử Claude Code bản web (claude.ai/code trên trình duyệt). Một số tính năng bị giới hạn nhưng vẫn chạy được taw-kit cơ bản.

**taw-kit có update không?**
Có. Thỉnh thoảng chạy `tawkit update` để lấy bản mới nhất. Xem lịch sử thay đổi trong [CHANGELOG.md](../../CHANGELOG.md).

**Tôi muốn học code thật để tự làm sau?**
Tốt quá. Đọc code do taw-kit sinh ra là cách học cực nhanh. Tham gia cộng đồng hỏi thêm, nhiều bạn từ "không biết gì" đã thành dev junior sau vài tháng.

---

Chúc bạn xây được nhiều sản phẩm vui vẻ! Nếu bí, quay lại [troubleshooting.md](./troubleshooting.md) hoặc vào cộng đồng.
