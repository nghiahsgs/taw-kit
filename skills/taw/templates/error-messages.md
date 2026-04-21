# Error Messages

Load during Step 6 (error recovery) of `/taw`. Pick the template matching the failure mode.

## Principles

- Simple English, friendly tone. No unexplained jargon.
- Always propose ONE concrete next action — don't leave the user stuck.
- DO NOT print raw stack traces to user-visible output — save them to `.taw/checkpoint.json` instead.

---

## Template: Build failed (npm run build error)

```
Build failed after 2 attempts. Error details saved.
You can:
  1. Type `/taw-fix` to let me analyze and auto-fix
  2. Open `.taw/checkpoint.json` to see the details
  3. Cancel and restart with a different description: `/taw <new description>`
```

## Template: Install failed (npm install error)

```
Package install failed. Usually a network or version conflict.
Try:
  1. Check your internet
  2. Run `npm cache clean --force`, then `/taw-fix`
  3. If that still fails, type `/taw-fix --deep` (I'll wipe node_modules and reinstall)
```

## Template: Deploy failed

```
Build succeeded, but deploy failed.
Your project still runs locally (type `npm run dev`).
Retry deploy: `/taw-deploy`
Or deploy manually: `vercel --prod`
```

## Template: Missing env var

```
Missing environment variable: <VAR_NAME>.
You need to create `.env.local` with this line:
  <VAR_NAME>=<value>
How to get <VAR_NAME>: <docs-link>
Then type `/taw-fix` again.
```

## Template: API key invalid (Claude rate limit or bad key)

```
Your Claude API key is invalid or out of quota.
Check:
  1. `ANTHROPIC_API_KEY` in your environment
  2. Your balance at console.anthropic.com
  3. Wait a few minutes if you've been rate-limited
```

## Template: Disk space

```
Your machine is out of disk space. A Next.js project needs ~500MB for node_modules.
Try:
  1. Remove old node_modules: `find . -name node_modules -exec rm -rf {} +`
  2. Move the project to a different drive
```

## Template: Git conflict

```
Git has uncommitted changes. I don't want to overwrite your work.
Type `git status` to see them.
To continue, commit first or stash: `git stash`
```

## Template: Unknown error (catchall)

```
Something unexpected went wrong: <1-line summary>
Details saved to `.taw/checkpoint.json`.
Try `/taw-fix`, or send the checkpoint file to support.
```

## Template: Clarification timeout

```
You've been quiet for a while. Want to continue?
  - Type `yes` to proceed with defaults
  - Type `/taw <new description>` to start over
```

## Template: User interrupted (Ctrl+C mid-run)

```
I was interrupted mid-step: <step name>
Checkpoint saved. Type `/taw-fix` to pick up from where we stopped.
```
