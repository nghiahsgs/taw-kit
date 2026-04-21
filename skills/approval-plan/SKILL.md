---
name: approval-plan
description: >
  Render a 3-5 bullet plan to the user in Vietnamese and wait for confirmation
  before proceeding. Accepts "OK", "co", "duoc", "chay di" as approval signals.
  Used by taw, taw-add, and taw-fix before any code changes are made.
argument-hint: "[plan bullets hoac context]"
---

# approval-plan — Plan Confirmation Gate

## Purpose

Present a clear, plain-Vietnamese plan to the user before writing any code.
Prevents surprises and builds trust with non-dev users who cannot read code diffs.

## When to Activate

- Before `/taw` begins orchestrating a full build
- Before `/taw-add` modifies existing files
- Before `/taw-fix` applies a multi-file fix
- Any time the scope of changes is more than 1 file

## Plan Format

Present as a numbered list in Vietnamese, 3-5 items, each ≤ 20 words:

```
Day la ke hoach toi se thuc hien:

1. Tao trang danh sach san pham tai /shop voi 12 san pham mau
2. Them gio hang luu trong localStorage (khong can dang nhap)
3. Tao trang thanh toan ket noi Polar Checkout
4. Cai dat giao dien Tailwind mau cam/trang

Ban co muon toi bat dau khong? (OK / co / duoc)
```

## Approval Detection

Accept as approval (case-insensitive):
- `ok`, `okay`, `OK`
- `co`, `có`, `co roi`, `có rồi`
- `duoc`, `được`, `duoc roi`, `được rồi`
- `chay di`, `chạy đi`, `lam di`, `làm đi`
- `yes`, `y`, `sure`, `go`

Reject / ask for changes:
- `khong`, `không`, `no`, `doi`, `đổi`, `sua`, `sửa`
- Any message describing a change → revise plan and re-present

## Rejection Handling

If user requests changes, update the plan bullets and re-present once.
If user rejects the revised plan, ask: "Ban muon thay doi gi? Mo ta cu the de toi chinh lai."

## Implementation Pattern

```
[Present plan as numbered list above]
[Wait for user response]
[If approved] → Proceed with implementation
[If rejected] → Ask what to change → revise → re-present
[If ambiguous] → Ask: "Ban co muon toi bat dau khong?"
```

## Tone Rules

- Use "toi" (I) and "ban" (you) — not formal pronouns
- Keep bullets action-oriented: verb first ("Tao...", "Them...", "Ket noi...")
- No technical jargon: "database" → "co so du lieu", "deploy" → "dua len mang"
- Maximum 5 bullets — if more steps needed, group related steps into one bullet
