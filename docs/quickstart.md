# Welcome! 5 minutes to your first product

You just bought taw-kit. Thank you! This guide walks you from "nothing installed" to "a real live website on the internet" in about 5 minutes of setup plus 15 minutes of waiting while the machine works.

Think of taw-kit as a developer on standby 24/7. You describe what you want, and the kit writes the code, tests it, and puts it on the internet for you. You just sip coffee.

---

## What you need first

Three things. Not many.

1. **Claude Code installed** — an AI app that runs in your terminal. If you don't have it yet, grab it from the Claude Code homepage (Mac / Windows / Linux), run the installer, then open Terminal and type `claude` to confirm it's there.
2. **An Anthropic API key** — essentially your account credential for Claude. Sign up at the Anthropic console, top up at least $5, copy the `sk-ant-...` string, and keep it in a notes app for a moment.
3. **A terminal open** — on Mac that's "Terminal", on Windows "PowerShell" or "Windows Terminal". Just open it; you don't need to learn anything fancy. taw-kit will only ask you to paste about 3 commands in the entire journey.

Worried "I can't code, will this work for me?" — relax. taw-kit is specifically for non-coders. All you need to do is copy-paste commands.

---

## Step 1: Install taw-kit

Open Terminal. Copy the line below, paste it, press Enter:

```bash
curl -fsSL https://install.tawkit.dev | bash
```

This downloads the installer and runs it automatically. You'll see some lines scrolling by — the script is copying files into the Claude Code folder. Wait about 30 seconds.

When it's done, you'll see:

```
taw-kit installed successfully. Type /taw in Claude Code to start.
```

That's the install done. Simple, right?

**Tiny note:** if Terminal says "curl: command not found", install curl first. On Mac: `brew install curl`. On Windows 10 and above curl is built in; double-check your spelling.

---

## Step 2: One-time configuration

Claude now needs your API key. Still in Terminal, type:

```bash
claude
```

Claude Code opens. The first time it'll ask for your API key — paste the `sk-ant-...` string and press Enter. Done. You won't need to type it again.

**(Optional)** If your product needs a database (for orders, customer lists, etc.), sign up for a free account at [supabase.com](https://supabase.com), create a project, copy the URL and anon key, keep them handy — taw-kit may ask.

If you're just making a simple landing page, you can skip Supabase.

---

## Step 3: Type /taw

Now the fun part. In the Claude Code window, type:

```
/taw build me a coffee shop website
```

(Feel free to replace "coffee shop website" with anything — "clothing store", "book review blog", "online course landing page", etc.)

taw-kit asks you 3–5 questions to narrow things down. For example:

```
1. What's the shop/brand name?
2. Do you want online cart + payment, or just menu display?
3. Color tone you like? (warm, cool, or neutral)
4. Want a reservation form?
5. Who's your target customer?
```

Answer each as you wish. You don't have to answer every question — type "up to you" for any you don't care about.

taw-kit then shows a short plan (about 5 lines):

```
Plan:
1. Set up Next.js + Tailwind + Supabase
2. Build 4 pages: home, menu, cart, thank-you
3. Connect Polar for payments
4. Deploy to Vercel via Shipkit
5. Estimated 15-20 minutes

Does this plan look good? (type: yes / edit / cancel)
```

Scan it. Looks good → type `yes`. Want tweaks → type `edit` and describe the change. Want to abort → type `cancel`.

---

## Step 4: Wait ~15 minutes and get the URL

After `yes`, focus on your coffee. taw-kit works quietly and reports progress:

```
✓ Done: plan ready
✓ Done: research
✓ Done: code written
✓ Done: build tested
✓ Done: security review
✓ Done: deployed
```

Each line is an AI "worker" doing one job. Total ~15-20 minutes. During this time you don't do anything. Don't close Terminal. Don't close Claude Code. Don't disconnect Wi-Fi. Just wait.

Occasionally a worker needs a decision (e.g. "round or square logo?") — Claude pauses and asks. Answer, it keeps going.

---

## Step 5: Done! Share your URL

At the end you'll see:

```
Done! 🎉 Open: https://your-product-name.vercel.app
Project files: /Users/you/tawkit-projects/coffee-shop
Want to add a feature? Type: /taw-add <description>
Something broken? Type: /taw-fix
```

Click the URL. Boom — your site is live on the internet. Share it with friends, clients, post it on social. Hosting is free forever (Vercel free tier).

Want to change the logo, text, add products? Type `/taw-add <description>` — taw-kit updates and redeploys.

Want to fix something? Type `/taw-fix` — it finds and fixes common issues.

---

## If something breaks

That's fine. About half of first-time users hit a small error. Try in order:

1. **Read the error on screen** — it usually suggests a fix.
2. **Type `/taw-fix`** — this auto-diagnoses and fixes most common errors.
3. **Still stuck?** Open [troubleshooting.md](./troubleshooting.md) and search by the error name.
4. **Last resort:** ask in the taw-kit community (link in your order email). Paste the error text; don't paste `.env.local` (it holds secrets).

---

## FAQ

**Do I pay extra for Claude/Anthropic?**
Yes. taw-kit runs on Claude. Each product costs ~$0.50–$2 in API usage. $10 buys dozens of runs.

**Do I pay for hosting the website I made?**
No. Vercel's free tier covers most small shops (100GB traffic/month). Upgrade when you get traffic.

**Can I edit the code manually?**
Yes. Project files live in `~/tawkit-projects/<name>`. Open them with any editor (VS Code, Sublime, even Notepad). If you can't code, stick with `/taw-add` and `/taw-fix` — safer.

**Can I build multiple sites?**
Yes. Each `/taw` creates a new project. No limit.

**I'm on Windows — does it work?**
Yes. taw-kit runs on Mac, Windows (via WSL2), and Linux. As long as Claude Code supports your OS, you're fine.

**Is my customer data safe?**
taw-kit never sends your data anywhere. Files live on your machine and the Vercel/Supabase accounts you own. Nothing flows through taw-kit servers.

**Can I resell the sites I build?**
Yes. You own the generated code 100%. The taw-kit license allows unlimited commercial use by the original purchaser.

**My company blocks installing software — can I still use this?**
Try Claude Code Web (claude.ai/code in a browser). Some features are limited but basic taw-kit still works.

**Does taw-kit update?**
Yes. Run `tawkit update` occasionally to grab the latest. See [CHANGELOG.md](../CHANGELOG.md) for what changed.

**I want to actually learn to code someday.**
Great. Reading the code taw-kit generates is a fast way to learn. Join the community to ask questions; many users went from "knew nothing" to junior dev in a few months.

---

Have fun building! If you get stuck, head to [troubleshooting.md](./troubleshooting.md) or ask in the community.
