# maintain: rollback

Revert recent changes — in source (git) or in deploy (hosting provider), or both. Non-destructive by default: uses `git revert` unless user explicitly asks for `reset`.

**Prereq:** router classified `tier2 = rollback`.

## Step 1 — Figure out what to roll back

Ask (if not given):
```
Lùi cái gì?
  1. code      — quay commit cũ (giữ lịch sử)
  2. deploy    — deploy lại bản production trước
  3. cả hai    — lùi code VÀ deploy lại
```

If user mentioned a specific target ("deploy bản hôm qua"), skip menu.

## Step 2 — CODE rollback

### Step 2a — Show recent commits

```bash
git log --oneline --decorate -15
```

Render (VN):
```
Commit gần nhất:
  a3f2b1c  (HEAD -> main) feat: add dark mode
  7e4d9a2  chore(deps): upgrade next to 15
  5c1e8f3  fix: login redirect loop
  b9d2a7e  feat: checkout page
  ...

Chọn cách lùi:
  1. revert 1 commit   — huỷ commit mới nhất, giữ lịch sử
  2. revert N commit   — gõ số (vd: 3 để huỷ 3 commit mới nhất)
  3. về commit cụ thể  — gõ SHA (vd: 5c1e8f3)
  4. huỷ
```

### Step 2b — Safety check

Before touching history:
```bash
git status --porcelain
```
Dirty → "Anh đang có thay đổi chưa commit. Commit hoặc stash trước." Stop.

Check if commits to be reverted are already pushed:
```bash
git log origin/main..HEAD --oneline 2>/dev/null | wc -l
```

If reverting a pushed commit, warn:
```
⚠️ Commit này đã push lên remote.
Dùng `git revert` (tạo commit mới huỷ) thay vì `git reset` (xoá lịch sử — nguy hiểm nếu có người khác pull).
OK không?
```

### Step 2c — Execute

Default to `git revert` (safe):
```bash
# revert 1 commit
git revert --no-edit HEAD

# revert N commits (oldest → newest)
git revert --no-edit HEAD~N..HEAD

# back to specific SHA (non-destructive)
git revert --no-edit <SHA>..HEAD
```

Only if user explicitly says "xoá lịch sử / hard reset" AND the commits are NOT pushed:
```bash
git reset --hard <SHA>
```

After revert, run `npm run build` to verify:
- Green → Step 3 (if deploy rollback also requested) or done
- Red → "Revert xong nhưng build vỡ. Có thể commit cũ thiếu thay đổi phụ thuộc. Quay lại thêm 1 commit nữa?"

## Step 3 — DEPLOY rollback

Read `.taw/deploy-target.txt`.

### Target: vercel

```bash
# list recent deployments
npx vercel ls --prod 2>&1 | head -10
```

Parse the list (deployment URLs + timestamps). Ask:
```
Chọn deploy để rollback:
  1. https://project-abc.vercel.app     (2h ago)
  2. https://project-xyz.vercel.app     (6h ago, PROD hiện tại)
  3. https://project-def.vercel.app     (1d ago)
Gõ số:
```

Execute promote:
```bash
npx vercel promote <deployment-url> --yes
```

### Target: docker

Docker rollback is manual — list last 3 tagged images:
```bash
docker images $PROJECT_NAME --format "{{.Repository}}:{{.Tag}}  {{.CreatedSince}}"
```

Emit:
```
Image cũ còn lại:
  $PROJECT_NAME:v23  (2h ago)
  $PROJECT_NAME:v22  (1d ago)

Chạy lại image cũ:
  docker run --env-file .env.local -p 3000:3000 $PROJECT_NAME:v22

Docker rollback là manual — em không tự restart container của anh được.
```

### Target: vps

Require SSH config from `.taw/vps.env`. Keep last 3 build dirs on remote:
```bash
ssh $VPS_USER@$VPS_HOST "ls -dt $VPS_PATH.backup.* 2>/dev/null | head -3"
```

If backup dirs exist, ask which to restore:
```bash
ssh $VPS_USER@$VPS_HOST "
  cd $(dirname $VPS_PATH) &&
  mv $VPS_PATH $VPS_PATH.broken &&
  mv $VPS_PATH.backup.<chosen> $VPS_PATH &&
  sudo systemctl restart $PROJECT_NAME
"
```

If no backups exist, emit: "Chưa có backup trên VPS. Lần deploy sau em sẽ lưu backup trước khi rsync."

## Step 4 — Verify deploy

For Vercel: `curl -fsI <url>` — expect 200.
For VPS: `ssh $VPS_USER@$VPS_HOST "curl -fsI http://localhost:3000"` — expect 200.
For Docker: skip (manual).

## Step 5 — Record + done

Update `.taw/checkpoint.json`:
```json
{"status":"rolled-back","target":"<vercel/vps/docker>","from":"<new>","to":"<old>","at":"<ISO>"}
```

`taw-commit` if code was reverted:
```
type=revert, scope=<inferred>, subject="revert to <short-SHA>"
```

Emit:
```
✓ Rollback xong.
  Code:   HEAD hiện tại là <SHA>
  Deploy: bản <timestamp> đã là prod
Build vẫn xanh.
```

## Constraints

- Default to `git revert` (safe), `git reset --hard` only on explicit user request + unpushed
- NEVER reset pushed commits without triple confirm + user understanding force-push risk
- Always dry-run the target selection first — show user what will change before doing it
- Vercel auth may prompt for login — tell user before running `npx vercel`
- If no `.taw/deploy-target.txt`, ask user which hosting was used
