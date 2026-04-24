# advisor: suggest

Propose 2-3 features for an existing project based on **demand evidence**, not guessing. Forces user to answer 3 hard questions before kit commits to a suggestion. Output is a recommendation, not a task — user must approve before any BUILD.

**Prereq:** router classified `tier1 = ADVISOR`, `tier2 = suggest`.

**Philosophy:** most "what should I add next?" sessions end with features nobody uses. Kit's job is to push back on vague answers until demand is specific. Emotional tone = **friendly but direct**. No "interesting idea!" fluff.

## Step 0 — Rules for this branch

**Never:**
- Propose features user didn't get evidence for
- Agree with the first vague answer
- Skip the 3 questions to "save time"

**Always:**
- Push once for specificity before accepting an answer
- End with ONE recommended feature + why, not a 10-item wishlist
- Link recommendation to a specific user pain, not a trend

## Step 1 — Context pass

Read project state (detection-first):
```bash
cat package.json | grep -E 'name|version'
ls app/ 2>/dev/null | head
cat .taw/intent.json 2>/dev/null
git log --oneline -20
```

Summarize in 1 line: "Anh có project `<name>` — category `<shop-online>`, đã có X/Y/Z features, built N ngày trước."

If project has no `.taw/intent.json` (not taw-built) — still works, scan folder structure to infer category.

## Step 2 — Three forcing questions (ask ONE AT A TIME)

Do NOT batch. Ask one, wait for answer, push if vague, then next.

### Q1 — Real demand

**Ask:**
> Có ai cụ thể đã NÓI THẲNG là họ cần feature gì chưa? Không phải "em nghĩ sẽ cool" — mà "khách A đã complaint rằng chưa có X", "user B đã hỏi khi nào có Y", hoặc "3 người đã rời app vì thiếu Z".

**If answer is vague** ("em nghĩ nên có X", "thấy competitor có Y"):
> Đó là ý tưởng của anh, không phải nhu cầu của user. Có ai đã THẬT SỰ yêu cầu chưa? Hoặc anh đã xem user dùng app và thấy họ kẹt chỗ nào chưa?

**Accept when:** user names a specific person/complaint/behaviour OR admits "chưa có ai yêu cầu cả, em đang đoán". Honesty is fine — chưa có demand means **suggestion phải thận trọng hơn**.

### Q2 — Status quo

**Ask:**
> Hiện user của anh đang xử lý nhu cầu này BẰNG CÁCH NÀO? (Dùng công cụ khác? Tự làm tay? Bỏ qua không làm?)

**Why:** nếu user đang workaround bằng cách tệ → feature sẽ được dùng. Nếu user không làm gì → feature có thể sẽ "lạnh".

**If vague:** "Anh hỏi thử 2-3 user xem họ giải quyết thế nào, rồi quay lại."

### Q3 — Narrowest wedge

**Ask:**
> Phiên bản NHỎ NHẤT của feature này mà user sẽ chấp nhận là gì? Không phải full platform — chỉ 1 nút, 1 form, 1 email tự động. Cái gì ship được trong 1-2 tiếng?

**If user says "cần phải có cả A, B, C mới dùng được"**:
> Đó là dấu hiệu giá trị chưa rõ. Nếu nhỏ hơn không work → có khả năng lớn hơn cũng không work. Một cái nhỏ nhất thử nghiệm được là gì?

## Step 3 — Synthesize evidence

After 3 answers, summarize what you actually have:

```
Em tổng hợp:

DEMAND:   {specific person/complaint OR "chưa có demand rõ"}
STATUS QUO: {current workaround}
WEDGE:    {smallest testable feature}

Độ tự tin recommend: {HIGH / MEDIUM / LOW}
  HIGH   = có người cụ thể yêu cầu + workaround tệ + wedge nhỏ
  MEDIUM = có signal nhẹ, nhưng chưa test
  LOW    = chưa có demand rõ, suggestion sẽ là phỏng đoán
```

## Step 4 — Propose 2-3 features

Based on evidence + project category, propose:

```
FEATURE A: {name} — {effort: S/M/L}
  Demand signal: {what evidence supports this}
  Wedge: {smallest shippable version}
  Stack fit: {1 sentence — fits project's existing Stripe/Supabase/etc}
  Risk: {1 sentence — what could go wrong}

FEATURE B: {name} — {effort}
  ...

FEATURE C: {name} — {effort} (optional — creative/lateral)
  ...
```

**Quality rules:**
- FEATURE A always the **safest bet** given evidence
- FEATURE B a **different angle** on same need
- FEATURE C (optional) — unexpected reframe. Ví dụ: thay vì "thêm X", "bỏ Y để X không cần nữa"

**Never propose:**
- Features requiring new stack (if project uses Supabase, don't propose "add Firebase auth")
- Features copying a competitor without reason
- Vague things like "improve UX"

## Step 5 — Recommend ONE (commit to position)

Pick exactly ONE. State reason in 1 sentence.

```
💡 EM ĐỀ XUẤT: FEATURE A vì {1-line: matches strongest demand signal}.

Rủi ro nếu sai: {1 sentence}.
Evidence có thể đổi ý em: {1 sentence on what would make B/C better choice}.
```

If confidence is LOW (Q1 turned up no real demand):
```
⚠️ Độ tự tin LOW — chưa có demand rõ.

Em khuyên: đừng build feature nào hết. Anh dành 1-2 ngày hỏi 5 user
"anh/chị thấy app thiếu gì nhất?" rồi quay lại. Build khi không có
demand = lãng phí thời gian.
```

Kit được quyền **từ chối đề xuất** khi không đủ signal. Đó là value thật của advisor.

## Step 6 — Handoff

```
Gõ:
  build A    → em gọi /taw <feature A description> để build
  build B    → build feature B
  cancel     → không làm gì, để anh suy nghĩ thêm
```

If user picks `build X` → route sang `@branches/build.md` add-feature flow với scope = Feature X's wedge (không phải full vision).

## Step 7 — Write decision to memory

Append to `.taw/suggestions.jsonl`:
```jsonl
{"ts":"{ISO}","target_project":"{name}","demand_evidence":"{from Q1}","chosen":"{A|B|C|none}","confidence":"{HIGH|MEDIUM|LOW}"}
```

Future `/taw suggest` sessions can skim this — if last 3 suggestions all had LOW confidence, emit warning: "3 session gần nhất đều chưa có demand. Anh đang đoán thay vì hỏi user?"

## Constraints

- **3 questions are MANDATORY** — do NOT skip even if user insists. They are the value.
- **Max ONE escape** — if user says "just suggest already" after Q1, ask 1 more (Q3), then proceed.
- Never propose >3 features — choice paralysis kills action.
- Never propose features that require a stack swap (that's `/taw stack-swap` territory).
- LOW confidence is not a failure — it's a useful honest signal.
- If project has 0 features built yet → this branch wrong fit. Redirect: "Anh chưa có app — bắt đầu bằng `/taw build` trước."
