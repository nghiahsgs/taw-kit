---
name: vietnamese-copy
description: >
  Generate Vietnamese marketing copy, UI strings, CTAs, error messages, and
  email templates for taw-kit projects. Tone: friendly, conversational, Southern
  Vietnamese style. Activated for any user-visible text generation.
argument-hint: "[loai-noi-dung: hero|cta|error|email|product]"
---

# vietnamese-copy — Vietnamese Content Generation

## Purpose

Generate natural, conversion-optimised Vietnamese copy for taw-kit web projects.
Tone is friendly and direct — Southern Vietnamese everyday speech, not formal.

## Copy Types

### Hero Section
```
Headline options:
- "Mua [san pham] chat luong, giao hang tan nha"
- "Dat [dich vu] de dang — chi 2 phut la xong"
- "[San pham] chinh hang, gia tot nhat thi truong"

Sub-headline:
- "Hang nghin khach hang tin tuong — ban la nguoi tiep theo"
- "Mien phi van chuyen toan quoc don tren 300.000d"
```

### Call-to-Action Buttons
| Context | Vietnamese CTA |
|---------|---------------|
| Purchase | "Mua ngay", "Them vao gio", "Dat hang" |
| Booking | "Dat lich ngay", "Chon gio hen", "Xac nhan dat lich" |
| Lead gen | "Nhan tu van mien phi", "Dang ky ngay", "Xem thu mien phi" |
| Learn more | "Xem chi tiet", "Tim hieu them", "Kham pha ngay" |
| Auth | "Dang nhap", "Tao tai khoan mien phi", "Tiep tuc" |

### Error Messages (user-friendly)
```
Network error: "Ket noi bi gian doan. Vui long thu lai sau it phut."
Form validation: "Ban quen dien [field] roi. Dien day du de tiep tuc nhe."
Payment failed: "Thanh toan chua thanh cong. Kiem tra lai the hoac thu phuong thuc khac."
Not found: "Khong tim thay trang nay. Ve trang chu?"
Server error: "Co loi xay ra tu phia chung toi. Chung toi dang xu ly, ban thu lai sau nhe."
```

### Email Templates

**Order confirmation:**
```
Chao [ten khach],
Don hang #[id] cua ban da duoc xac nhan!
San pham: [ten]
Tong tien: [gia]
Chung toi se giao trong 2-4 ngay lam viec.
Cam on ban da tin tuong! — Doi ngu [ten cua hang]
```

**Magic link auth:**
```
Chao ban,
Bam vao nut duoi day de dang nhap (het han sau 10 phut):
[Dang nhap ngay]
Neu ban khong yeu cau dang nhap, bo qua email nay.
```

### Product Description Template
```
[Ten san pham] — [Tinh nang noi bat nhat]

Chat lieu / Thanh phan: ...
Phu hop cho: ...
Bao gom: ...
Bao hanh: ...

[CTA: Them vao gio hang]
```

## Tone Rules

- Use "ban" (you) not "quy khach" — friendlier
- Short sentences: ≤15 words each
- Use "nhe" at end of soft instructions
- Avoid jargon; if technical term needed, explain in parentheses
- Prices always formatted: `1.250.000d` or `1,250,000 VND`
