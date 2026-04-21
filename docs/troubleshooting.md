# Troubleshooting

20 common errors people hit in the first week, with step-by-step fixes. If your error isn't here, try `/taw-fix --deep` to let taw-kit auto-diagnose.

**Convention:** All commands are typed in Terminal. Replace `<...>` with your actual value.

---

## A. Install errors

### "curl: command not found"
**Symptom:** Running the install line prints `curl: command not found`.
**Cause:** Your machine doesn't have `curl`. Rare on modern Mac/Windows; usually minimal Linux images.
**Fix:**
1. Mac: `brew install curl`. Install Homebrew first from brew.sh if you don't have it.
2. Windows 10+: curl is built in — double-check spelling.
3. Try `wget` instead: `wget -qO- https://install.tawkit.dev | bash`.

**Still stuck?** Download `install-oneliner.sh` manually from the taw-kit page and run `bash install-oneliner.sh`.

---

### /taw does nothing after install
**Symptom:** Inside Claude Code you type `/taw` but nothing happens.
**Cause:** Claude Code hasn't picked up the skill yet. Usually a path mismatch or needs a restart.
**Fix:**
1. Quit Claude Code (Ctrl+D or type `/exit`).
2. Open again: `claude`.
3. Type `/taw` again. If still nothing, check `~/.claude/skills/taw/SKILL.md` exists.
4. If the file is missing: re-run the install one-liner.

**Still stuck?** Type `/taw-fix --deep` — it checks the install and self-heals.

---

### Permission denied during install
**Symptom:** `Permission denied` or `bash: /install.sh: Permission denied`.
**Cause:** Script isn't executable or you're in a folder without write access.
**Fix:**
1. Go home: `cd ~`.
2. Re-run the install one-liner.
3. Never use `sudo` for install. taw-kit doesn't need admin rights.

**Still stuck?** Remove any old `~/.claude/skills/taw` and re-install.

---

### "claude: command not found"
**Symptom:** Typing `claude` says command not found.
**Cause:** Claude Code isn't installed or isn't on your PATH.
**Fix:**
1. Install Claude Code from the Anthropic site.
2. Quit and reopen Terminal (to reload PATH).
3. If still missing, locate the binary (usually `/usr/local/bin/claude` on Mac) and add its folder to PATH.

**Still stuck?** Uninstall Claude Code and reinstall from the official package.

---

## B. API key errors

### "Invalid API key"
**Symptom:** `Error: invalid_api_key` or `401 Unauthorized`.
**Cause:** Typo, missing characters, or a revoked key.
**Fix:**
1. Open the Anthropic console and confirm the key is active.
2. Re-copy the full `sk-ant-...` string — watch out for stray spaces.
3. In Claude Code: `/logout`, then `claude` again, paste the fresh key.

**Still stuck?** Create a new key, delete the old one, use the new one.

---

### Rate limit / "Too many requests"
**Symptom:** `/taw` runs for a while then hits `429 Too Many Requests`.
**Cause:** You've exceeded your minute-level rate limit on Anthropic.
**Fix:**
1. Wait 60 seconds, type `/taw-fix` to resume from the last step.
2. Top up your account in the Anthropic console — higher tiers have higher rate limits.
3. If multiple people share a key, create one key per person.

**Still stuck?** Pause big builds, wait an hour, or upgrade your tier.

---

### "Insufficient credits"
**Symptom:** `credits exhausted` or `billing_error`.
**Cause:** Your Anthropic balance hit zero.
**Fix:**
1. Open the Anthropic console → Billing.
2. Add at least $5. A taw-kit project typically costs $0.50–$2.
3. Back to Terminal: `/taw-fix` to resume.

**Still stuck?** Check whether your card is blocked for international charges; use an international Visa/MasterCard.

---

### "I don't know what an API key is"
**Symptom:** Claude Code asks for an API key but you don't have one.
**Cause:** You haven't signed up for Anthropic yet.
**Fix:**
1. Go to console.anthropic.com → Sign up.
2. Verify your email.
3. In Billing, add $5 minimum.
4. Go to API Keys → Create key. Copy the `sk-ant-...` string.
5. Paste into Claude Code when prompted.

---

## C. Build errors

### "Module not found"
**Symptom:** `Error: Cannot find module 'xyz'`.
**Cause:** A dependency wasn't installed, or `node_modules` is broken.
**Fix:**
1. In the project folder: `npm install`.
2. If that fails: `rm -rf node_modules package-lock.json && npm install`.
3. If still failing: `/taw-fix --deep`.

---

### TypeScript type error
**Symptom:** `Type 'X' is not assignable to type 'Y'` during `npm run build`.
**Cause:** A generated component has a type mismatch, often after a `/taw-add` call.
**Fix:**
1. Type `/taw-fix` — it handles most type errors automatically.
2. If you want to fix manually, open the file mentioned in the error and align the types.

---

### Missing environment variable
**Symptom:** `Missing environment variable: NEXT_PUBLIC_SUPABASE_URL`.
**Cause:** `.env.local` is missing or missing a required key.
**Fix:**
1. Open `.env.local` in the project folder (create if absent).
2. Add the missing line, e.g. `NEXT_PUBLIC_SUPABASE_URL=https://xyz.supabase.co`.
3. Get the value from Supabase → Project → Settings → API.
4. `/taw-fix` to rebuild.

---

### Out of disk space
**Symptom:** `ENOSPC: no space left on device`.
**Cause:** Your drive is full. A Next.js project needs ~500MB for node_modules.
**Fix:**
1. Free up space: empty Trash, delete unused files.
2. Delete old `node_modules`: `find ~/tawkit-projects -name node_modules -exec rm -rf {} +`.
3. Move the project to another drive.

---

## D. Deploy errors

### Vercel auth failed
**Symptom:** `Vercel authentication required` during `/taw-deploy`.
**Cause:** Vercel CLI not logged in.
**Fix:**
1. Run `npx vercel login` and follow the browser prompt.
2. `/taw-deploy` again.

---

### Domain already taken
**Symptom:** `The requested domain is already in use`.
**Cause:** Another project on Vercel owns the slug.
**Fix:**
1. Edit `.taw/intent.json`, change `project_name` to something unique.
2. `/taw-deploy` again.

---

### Docker build fails
**Symptom:** `docker build` exits with a step failure.
**Cause:** Usually a missing package, outdated base image, or BuildKit cache issue.
**Fix:**
1. Run with clean cache: `docker build --no-cache -t <name>:latest .`.
2. Confirm `.dockerignore` excludes `node_modules` and `.env*`.
3. `/taw-fix` handles common Dockerfile issues automatically.

### VPS deploy: "Permission denied (publickey)"
**Symptom:** SSH rejects the connection during `/taw-deploy --target=vps`.
**Cause:** Your VPS doesn't have your public key, or `.taw/vps.env` has the wrong user.
**Fix:**
1. Copy your key: `ssh-copy-id $VPS_USER@$VPS_HOST`.
2. Double-check `VPS_USER` and `VPS_HOST` in `.taw/vps.env`.
3. Test the raw connection: `ssh $VPS_USER@$VPS_HOST echo ok`.

---

### Build works locally but fails on Vercel
**Symptom:** `npm run build` passes on your machine but fails during deploy.
**Cause:** Usually missing env vars on Vercel, or a case-sensitive filename on Linux.
**Fix:**
1. In the Vercel dashboard → Settings → Environment Variables — add the same keys as your `.env.local`.
2. Check filename casing in imports (Mac is case-insensitive, Linux is not).
3. `/taw-fix` to try an auto-fix.

---

## E. General confusion

### /taw doesn't respond
**Symptom:** Typed `/taw`, nothing happens.
**Cause:** You may not be inside Claude Code, or the skill isn't loaded.
**Fix:**
1. Confirm prompt shows `claude >` (not `$` or `%`).
2. Type `/taw --help` — if help text appears, the skill is loaded.
3. If not, quit and restart Claude Code.

---

### Output looks weird (blank, partial text, broken characters)
**Symptom:** Answers come back empty or truncated.
**Cause:** Network interruption or context limit.
**Fix:**
1. Check your internet.
2. Type `/taw-fix` to resume.
3. If context is full, start a new Claude Code session — taw-kit state lives on disk.

---

### Answers in the wrong language
**Symptom:** Replies mix English and Vietnamese randomly.
**Cause:** Language hint is ambiguous.
**Fix:**
1. Put a clear request at the start: "Please reply in English." (or Vietnamese).
2. taw-kit's `error-to-vi` skill can translate errors on demand.

---

### Confused about generated code
**Symptom:** You open the project folder and don't understand anything.
**Cause:** That's normal if you don't code yet.
**Fix:**
1. Don't touch code manually. Use `/taw-add` for changes.
2. Want to learn? Read a Next.js quickstart — 2 hours and you'll recognize the structure.
3. Community channel has friendly people; ask questions with the exact filename you're looking at.

---

If your error isn't listed here, open the taw-kit community link in your order email, paste the error text (redact any API keys), and someone will help.
