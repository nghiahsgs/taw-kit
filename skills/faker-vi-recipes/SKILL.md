---
name: faker-vi-recipes
description: >
  Generators for realistic Vietnamese seed data with @faker-js/faker + custom
  VN-specific data pools. Used by branches/maintain/seed.md. Covers names,
  addresses, phone numbers, VND amounts, common Vietnamese product categories.
  Trigger phrases (EN + VN): "faker vi", "seed tieng viet", "data gia vn",
  "ten viet nam", "dia chi viet nam", "vnd fake".
allowed-tools: Read, Write, Edit, Bash
---

# faker-vi-recipes — VN-Realistic Seed Data

## Step 0 — Detect

Check if faker is installed:
```bash
node -e "try{require('@faker-js/faker')}catch(e){process.exit(1)}" 2>/dev/null && echo installed || echo missing
```

Missing → `npm install -D @faker-js/faker`. Ask user first.

## Import the VI locale
```ts
import { faker } from '@faker-js/faker/locale/vi'
// or — more flexibility, can mix locales:
import { Faker, vi, en } from '@faker-js/faker'
const fakerVI = new Faker({ locale: [vi, en] })  // fall back to en when vi missing a key
```

## Pattern library

### Vietnamese names
```ts
// person
faker.person.fullName()         // "Trần Hoàng Nam"
faker.person.firstName('male')  // "Minh"
faker.person.firstName('female')// "Hoa"
faker.person.lastName()         // "Nguyễn"

// gendered with middle name — manual blend:
const lastNames = ['Nguyễn','Trần','Lê','Phạm','Hoàng','Huỳnh','Phan','Vũ','Võ','Đặng','Bùi','Đỗ','Hồ','Ngô','Dương']
const middleMale = ['Văn','Hữu','Đức','Quang','Anh','Minh','Tuấn']
const middleFemale = ['Thị','Thanh','Thu','Minh','Ngọc','Kim','Mỹ']
const firstMale = ['Nam','Hùng','Tuấn','Phúc','Đạt','Huy','Khoa','Long','Quân','Thành']
const firstFemale = ['Hương','Lan','Thảo','Trang','My','Ngân','Ngọc','Phương','Quỳnh','Yến']

function vnFullName(gender: 'male'|'female') {
  const last = faker.helpers.arrayElement(lastNames)
  const middle = faker.helpers.arrayElement(gender === 'male' ? middleMale : middleFemale)
  const first = faker.helpers.arrayElement(gender === 'male' ? firstMale : firstFemale)
  return `${last} ${middle} ${first}`
}
```

### Vietnamese phone numbers
```ts
// mobile (starts with 03/05/07/08/09, 10 digits)
const carriers = ['032','033','034','035','036','037','038','039', // Viettel
                  '056','058',                                       // Vinaphone
                  '070','076','077','078','079','089','090','093','094',
                  '081','082','083','084','085','088'] // Mobi + others
function vnPhone() {
  const prefix = faker.helpers.arrayElement(carriers)
  const suffix = faker.string.numeric(7)
  return prefix + suffix    // e.g. "0909123456"
}

// international format
function vnPhoneIntl() {
  return '+84' + vnPhone().slice(1)   // "+84909123456"
}
```

### Vietnamese addresses

faker's `location.*` in VI locale is thin. Use custom pools:
```ts
const wards_hcm = ['P. Bến Nghé','P. Bến Thành','P. Đa Kao','P. Nguyễn Thái Bình','P. Phạm Ngũ Lão','P. Cầu Kho','P. Cầu Ông Lãnh','P. Cô Giang','P. Tân Định']
const districts_hcm = ['Q.1','Q.3','Q.5','Q.7','Q.10','Q. Bình Thạnh','Q. Phú Nhuận','Q. Gò Vấp','Q. Tân Bình','TP. Thủ Đức']
const streets = ['Nguyễn Du','Lê Lợi','Hai Bà Trưng','Đồng Khởi','Nguyễn Huệ','Pasteur','Võ Văn Tần','Điện Biên Phủ','Cách Mạng Tháng 8','Lý Tự Trọng','Nguyễn Thị Minh Khai']

function vnAddressHCM() {
  const number = faker.number.int({ min: 1, max: 500 })
  const street = faker.helpers.arrayElement(streets)
  const ward = faker.helpers.arrayElement(wards_hcm)
  const district = faker.helpers.arrayElement(districts_hcm)
  return `${number} ${street}, ${ward}, ${district}, TP. HCM`
}
```

Provinces fallback: `faker.location.state()` → may return EN — fine for many cases, but for VN-only seeds build a small pool of top 10 cities.

### VND amounts
```ts
// product price — typical range
const priceVND = () => faker.number.int({ min: 10_000, max: 5_000_000 })

// rounded to thousand (realistic for shopping)
const priceVNDnice = () => Math.round(faker.number.int({ min: 10, max: 5000 })) * 1000

// order total — multi-item
const orderTotalVND = () => faker.number.int({ min: 100_000, max: 20_000_000 })

// format for display
function fmtVND(n: number) {
  return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(n)
}
// fmtVND(250000) → "250.000 ₫"
```

### VN product categories
```ts
const vnProducts = {
  'thời trang': ['Áo thun unisex','Quần jean nam','Váy công sở','Giày sneaker','Túi tote canvas'],
  'điện tử':    ['Tai nghe bluetooth','Sạc dự phòng 10000mAh','Ốp lưng iPhone','Đồng hồ thông minh','Loa mini'],
  'mỹ phẩm':    ['Son lì lâu trôi','Kem chống nắng SPF50','Serum vitamin C','Mặt nạ dưỡng ẩm','Nước tẩy trang'],
  'đồ gia dụng':['Nồi cơm điện','Máy xay sinh tố','Bàn ủi hơi nước','Chảo chống dính','Bộ dao inox'],
  'thực phẩm':  ['Trà sữa nhãn','Cà phê hạt nguyên chất','Bánh trung thu','Kẹo dừa Bến Tre','Mắm nêm'],
}
function vnProduct() {
  const cat = faker.helpers.arrayElement(Object.keys(vnProducts))
  const name = faker.helpers.arrayElement(vnProducts[cat as keyof typeof vnProducts])
  return { category: cat, name, price: priceVNDnice() }
}
```

### Emails (VN-style pseudo-domain for seed safety)
```ts
// Use @test or @example pseudo-domains — never real ones that could spam real people
function vnEmail(name: string) {
  const slug = name.toLowerCase().replace(/\s+/g,'').normalize('NFD').replace(/[̀-ͯ]/g,'')
  return `${slug}${faker.number.int(999)}@test`
}
```

### Dates (recent, business hours)
```ts
// recent order (last 30 days)
faker.date.recent({ days: 30 })

// business hour timestamp
function vnBusinessHourDate() {
  const d = faker.date.recent({ days: 30 })
  d.setHours(faker.number.int({ min: 9, max: 21 }))
  d.setMinutes(faker.number.int({ min: 0, max: 59 }))
  return d
}
```

### Vietnamese lorem / product descriptions
faker's lorem in VI locale may not exist — use a custom pool:
```ts
const vnPhrases = [
  'Chất lượng cao, giá phải chăng.',
  'Giao hàng toàn quốc trong 2-3 ngày.',
  'Bảo hành chính hãng 12 tháng.',
  'Đổi trả miễn phí trong 7 ngày.',
  'Được yêu thích bởi khách hàng trẻ.',
  'Thiết kế tối giản, dễ phối đồ.',
  'Nguyên liệu nhập khẩu từ Nhật Bản.',
  'Hỗ trợ thanh toán khi nhận hàng (COD).',
]
function vnDescription(n = 2) {
  return faker.helpers.arrayElements(vnPhrases, n).join(' ')
}
```

### Images (Picsum, 400×400 deterministic)
```ts
faker.image.urlPicsumPhotos({ width: 400, height: 400 })
// or with seed for stability across re-runs:
faker.image.urlPicsumPhotos({ width: 400, height: 400, grayscale: false, blur: 0 })
```

## Full example: 100 realistic orders
```ts
import { faker } from '@faker-js/faker/locale/vi'
// ... import pools + helpers from above

const users = Array.from({ length: 50 }, () => {
  const gender = faker.helpers.arrayElement(['male','female'] as const)
  const name = vnFullName(gender)
  return {
    id: faker.string.uuid(),
    full_name: name,
    email: vnEmail(name),
    phone: vnPhone(),
    address: vnAddressHCM(),
    created_at: vnBusinessHourDate().toISOString(),
  }
})

const products = Array.from({ length: 30 }, () => {
  const p = vnProduct()
  return {
    id: faker.string.uuid(),
    name: p.name,
    category: p.category,
    price: p.price,
    description: vnDescription(),
    image_url: faker.image.urlPicsumPhotos({ width: 400, height: 400 }),
  }
})

const orders = Array.from({ length: 100 }, () => ({
  id: faker.string.uuid(),
  user_id: faker.helpers.arrayElement(users).id,
  product_id: faker.helpers.arrayElement(products).id,
  total: orderTotalVND(),
  status: faker.helpers.arrayElement(['pending','paid','shipped','delivered','cancelled']),
  created_at: vnBusinessHourDate().toISOString(),
}))
```

## Constraints

- Never seed real PII — always `@test` emails, fictional addresses
- Keep FK integrity: seed users before orders, products before order_items
- Use `faker.seed(123)` at top of script for reproducible data between runs
- VN locale in faker is thin — fall back to custom pools for domain-specific terms
- Don't use emoji in names — some DBs mishandle 4-byte UTF-8 without mb4 charset
