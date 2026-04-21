# taw-kit video scripts

Two ready-to-shoot scripts for YouTube / TikTok / Reels. Each scene lists: timing, on-screen visuals, narrator lines. Treat the lines as guidance — stick to the point, speak naturally.

Recommended style: real screen recording, calm narration, captions on. No flashy effects. Viewers want to see the real process.

---

## Script A: 5-minute onboarding

**Goal:** Someone just bought taw-kit. By the end they've installed it and run their first command.
**Target length:** 5–6 minutes.
**Platform:** YouTube 16:9; vertical cut for TikTok.

### [0:00–0:20] Hook
VISUAL: Before/after shot — left side: blank terminal; right side: a live coffee shop website in a browser. Overlay text: "5 minutes to a real website."
NARRATION: "If you just bought taw-kit and don't know where to start, this video is for you. In 5 minutes, I'll take you from zero to a real website running on the internet. No coding required. No prerequisites to learn."

### [0:20–0:50] Prerequisites
VISUAL: Highlight 3 icons — Claude Code app, a key icon (API key), Terminal app. Each turns green as it's mentioned.
NARRATION: "You need three things. One: Claude Code installed. Two: an Anthropic API key. Three: Terminal open. If Claude Code isn't installed, grab it from the homepage and install like any app."

### [0:50–1:30] Install taw-kit
VISUAL: Terminal close-up. Paste the curl command. Enter. "taw-kit installed successfully" appears.
NARRATION: "Step one: install taw-kit. Copy this line, paste into Terminal, press Enter. Wait about 30 seconds. When you see 'installed successfully', you're done. That simple."

### [1:30–2:10] Paste the API key
VISUAL: Open Claude Code with `claude`. Prompt asks for API key. Host pastes `sk-ant-...` (partially masked). Enter.
NARRATION: "Step two: type `claude` to open Claude Code. First time, it asks for your API key. Go to the Anthropic console, create a key, copy the `sk-ant-...` string, paste here. Done. It remembers next time."

### [2:10–3:00] Type /taw
VISUAL: Type `/taw build me a coffee shop website`. Enter. taw-kit lists 5 clarifying questions.
NARRATION: "Step three — the fun part. Type `/taw` then describe what you want. For example, 'build me a coffee shop website'. Enter. taw-kit asks 5 follow-ups — shop name, cart or no cart, color tone. Answer as you like. Any you don't know? Type 'up to you'."

### [3:00–3:40] Approve the plan
VISUAL: 5-line plan appears (stack, pages, deploy target, ETA). Cursor blinks waiting.
NARRATION: "After answering, taw-kit shows a short plan — usually 5 lines. Scan it. Looks good? Type `yes`. Want changes? Type `edit`. Want to abort? Type `cancel`. I'll type yes."

### [3:40–4:40] Let the AI workers run
VISUAL: Fast-forward 15 minutes into 40 seconds. Show each `✓ Done:` line.
NARRATION: "Now you wait. taw-kit has 5 AI workers running in sequence — plan, research, code, test, security review. Each reports a line when done. Total time: 15 to 20 minutes. Go make coffee."

### [4:40–5:20] Get the URL
VISUAL: Final "Done! Open: https://your-coffee-shop.vercel.app". Click the link. Browser shows the real site; scroll through pages.
NARRATION: "And there it is. Final line: 'Done' plus a URL. Click it. Boom — your site is on the real internet. Share the link with friends, post it on social. Hosting is free. Not as hard as you thought."

### [5:20–5:50] Recap + next
VISUAL: 3-bullet text overlay: "Install 30s — Type /taw — Get URL". End card with a link to the next video "Build a real online shop in 30 minutes".
NARRATION: "To recap: install in 30 seconds, type /taw, wait 15 minutes, get a URL. If something breaks, the troubleshooting file in docs covers the common errors. Next video I'll walk through a full online shop with cart and checkout in 30 minutes. See you."

---

## Script B: Build a real online shop in 30 minutes

**Goal:** Full demo from command zero to a shop with cart, checkout, and a live URL.
**Target length:** 12–15 minutes (fast-forward from 30 minutes of raw footage).
**Platform:** Long-form YouTube. Can cut two TikTok shorts.

### [0:00–0:30] Hook
VISUAL: Fast preview of the end state — live shop, cart, checkout with QR. Text overlay: "30 minutes. 1 command. No code."
NARRATION: "In this video I build a full handmade-goods shop from zero. Product list, cart, online payment, admin page to post products. All in 30 minutes with one natural-language command. Not fake, not edited tricks. If you haven't seen the 5-minute onboarding, watch that first."

### [0:30–1:30] Prep
VISUAL: Open Claude Code. Supabase dashboard in a side tab (URL + anon key ready to copy).
NARRATION: "Before starting, I set up Supabase — a free database service for products, orders, accounts. Sign up at supabase.com, create a project, copy the URL and anon key. Skip this if you're just making a landing page."

### [1:30–2:30] Type /taw with a detailed description
VISUAL: Type a long command: `/taw build me a handmade goods shop with a product list, cart, Polar checkout, and an admin page`. Enter.
NARRATION: "Now I type /taw and describe in detail. Notice I'm specific: handmade shop, product list, cart, Polar checkout, admin page. More specific input = more accurate output."

### [2:30–4:30] Clarify + answer
VISUAL: taw-kit asks 5 questions (shop name, logo, colors, initial product count, login yes/no). Answer each.
NARRATION: "taw-kit asks 5 follow-ups. Shop name: 'Handmade Linh'. Logo: 'pick any clean font and icon'. Color: beige and light brown. Sample products: 8. Google login for customers. Done, Enter."

### [4:30–5:30] Approve the plan
VISUAL: 5-bullet plan appears. Scroll each bullet. Type `yes`.
NARRATION: "The plan covers it: Next.js with Tailwind and Supabase, 4 main pages, Polar integration, deploy to Vercel, ETA 25 minutes. Looks right. yes."

### [5:30–7:00] Planner + Researcher
VISUAL: Fast-forward. `✓ Done: detailed plan ready`, then `✓ Done: Supabase + Polar docs fetched` (two researchers in parallel).
NARRATION: "First worker is the planner, splitting the overall plan into 6 smaller phases. Next, two researchers run in parallel — one fetches Supabase docs, one fetches Polar docs, to get API calls right. Takes about 3 minutes."

### [7:00–10:00] Fullstack-dev writes the code
VISUAL: Left pane shows files being generated fast (auto-scroll). Right pane shows progress %. Fast-forward 4x.
NARRATION: "Next is fullstack-dev, the most important worker. It scaffolds Next.js, creates 4 pages, writes the cart component, wires Supabase for the database, integrates Polar for checkout. Meanwhile it runs npm install and logs each step. About 8-12 minutes. I'll fast-forward."

### [10:00–11:30] Tester + Reviewer
VISUAL: `✓ Done: build tested`, then `✓ Done: security reviewed`. Green checklist on the side.
NARRATION: "The last two workers run fast. Tester runs the build and a smoke test to make sure nothing crashes. Reviewer scans for security issues — any exposed keys, any risky patterns. About 2 minutes total."

### [11:30–13:00] Deploy
VISUAL: "Deploying to Vercel..." then "Done! https://handmade-linh.vercel.app". Click the link. Browser opens.
NARRATION: "Final step: deploy. taw-kit pushes to Vercel via the official CLI. 1 to 2 minutes, and it hands back a real URL. I click. Here it is — Handmade Linh is live on the internet."

### [13:00–14:30] Walkthrough of the real shop
VISUAL: Scroll the homepage; see 8 sample products; click one; add to cart; open cart; click checkout; QR appears. Switch to admin tab, log in with Google, post one more product.
NARRATION: "Here's the homepage — banner, menu, 8 products taw-kit seeded. Click a product, detail page shows. Add to cart. Open cart, click checkout. Real Polar checkout flow — scanning would actually charge (I won't). Switch to the admin tab, sign in with Google, add a new product. Frontend updates immediately."

### [14:30–15:00] Recap + next
VISUAL: 30:00 timer overlay. 3 bullets: "1 command — 30 minutes — Real live shop." Link to next video "When things break: using /taw-fix".
NARRATION: "Recap: one command, 30 minutes, real live shop. Want more features? `/taw-add`. Want to fix something? `/taw-fix`. Next video covers taw-fix — because eventually you'll need it. Subscribe so you don't miss it."

---

## Production notes

- **Voice:** Speak slowly, clearly, like teaching a younger sibling. Avoid hype-bro energy. New users panic when it's fast.
- **Typing speed:** Don't fast-forward the first commands — viewers need to follow. Only fast-forward while the workers are running.
- **Captions:** Required. Black text on white, readable when muted.
- **Branding:** taw-kit logo bottom-left throughout. End with a CTA card linking to the buy page.
- **Thumbnail:** Bold text like "In 5 minutes" or "30-minute real shop". Skip the red arrows and shocked-face template — it's played out.
