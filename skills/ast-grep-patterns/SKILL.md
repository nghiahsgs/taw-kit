---
name: ast-grep-patterns
description: >
  ast-grep (sg) pattern cookbook for safe structural refactors in TypeScript /
  TSX projects. Covers rename, extract, find-and-replace with code context.
  Used by branches/maintain/refactor.md when ast-grep is available.
  Trigger phrases (EN + VN): "ast-grep", "structural replace", "rename symbol",
  "codemod tsx", "tim cau truc", "thay the theo pattern".
allowed-tools: Read, Write, Edit, Bash, Grep
---

# ast-grep-patterns — Structural Refactor Recipes

## Step 0 — Check ast-grep is installed

```bash
command -v sg >/dev/null 2>&1 || command -v ast-grep >/dev/null 2>&1
```

If missing, ask user ONCE to install:
```bash
brew install ast-grep  # macOS
cargo install ast-grep --locked  # any OS with Rust
```

If user declines → fall back to Grep + per-file Edit (still works, slower).

Basic syntax:
```bash
sg run --lang tsx --pattern '<pattern>' --rewrite '<replacement>' --update-all
sg run -p '...' -r '...' --lang tsx    # shorter flags
sg scan --pattern '<pattern>'          # dry-run, just show matches
```

Meta-variables:
- `$VAR` — matches any single AST node (identifier, expression, etc.)
- `$$$` — matches ANY number of nodes (for spread / arg lists)
- `$$$ARGS` — named multi-node capture

## Pattern library

### Rename a function/variable (identifier)
```bash
sg run --lang tsx -p 'oldName' -r 'newName' --update-all
```
⚠️ This matches the identifier in ALL contexts: calls, imports, properties. For precise scoping, use kind filter:
```bash
sg run --lang tsx -p 'function oldName($$$PARAMS) { $$$BODY }' -r 'function newName($$$PARAMS) { $$$BODY }' --update-all
```

### Rename a React component + all JSX usages
```bash
# declaration
sg run --lang tsx -p 'function OldCard($$$P) { $$$B }' -r 'function NewCard($$$P) { $$$B }' --update-all
# JSX open tag
sg run --lang tsx -p '<OldCard $$$A />' -r '<NewCard $$$A />' --update-all
# JSX close tag
sg run --lang tsx -p '</OldCard>' -r '</NewCard>' --update-all
# imports
sg run --lang tsx -p 'OldCard' -r 'NewCard' --update-all
```

### Change default export to named export
```bash
sg run --lang tsx -p 'export default function $NAME($$$P) { $$$B }' -r 'export function $NAME($$$P) { $$$B }' --update-all
```

Then find all default imports and switch to named:
```bash
sg run --lang tsx -p 'import $NAME from "$PATH"' -r 'import { $NAME } from "$PATH"' --update-all
# WARN: this is too broad — it'll break legit default imports from 3rd-party libs
# Prefer scoping by path prefix:
sg run --lang tsx -p 'import $NAME from "@/$REST"' -r 'import { $NAME } from "@/$REST"' --update-all
```

### Replace `console.log` with a logger
```bash
sg run --lang ts -p 'console.log($$$ARGS)' -r 'logger.info($$$ARGS)' --update-all
```

### Remove all `console.log` in production code (scoped)
```bash
sg scan --lang ts -p 'console.log($$$A)' --filter "file_path_matches:^src/" > matches.txt
# review matches.txt, then:
sg run --lang ts -p 'console.log($$$A)' -r '' --update-all
```

### Wrap useState with a logger (for debugging)
```bash
sg run --lang tsx \
  -p 'const [$STATE, $SETTER] = useState($INIT)' \
  -r 'const [$STATE, $SETTER] = useState($INIT); console.log("$STATE:", $STATE)' \
  --update-all
```

### Convert class components to functional (partial — simple case)
```bash
# very narrow pattern; not a general converter, just a starter
sg run --lang tsx \
  -p 'class $NAME extends React.Component { render() { return $JSX } }' \
  -r 'function $NAME() { return $JSX }' \
  --update-all
```

### Swap library import path
```bash
sg run --lang tsx \
  -p 'import { $$$NAMES } from "@supabase/auth-helpers-nextjs"' \
  -r 'import { $$$NAMES } from "@supabase/ssr"' \
  --update-all
```

### Add `'use client'` directive to all files using useState
```bash
# step 1: find files
sg scan --lang tsx -p 'useState' --reporter files > client-files.txt
# step 2: for each, prepend 'use client' if not already there
while read f; do
  head -1 "$f" | grep -q "'use client'" || sed -i "1i 'use client'" "$f"
done < client-files.txt
```

### Extract a JSX block into a component (partial)
ast-grep can find the block:
```bash
sg scan --lang tsx -p '<div className="card">$$$CHILDREN</div>' --json
```
But the extraction (create new file + replace with component usage) is multi-step — combine with Write/Edit tools.

### Update import path (after moving file)
When you `mv components/Old.tsx components/new/Old.tsx`:
```bash
sg run --lang tsx -p '"@/components/Old"' -r '"@/components/new/Old"' --update-all
sg run --lang tsx -p "'@/components/Old'" -r "'@/components/new/Old'" --update-all
```

## Config file approach

For complex projects, put patterns in `sgconfig.yml`:
```yaml
ruleDirs:
  - sg-rules
```

Create `sg-rules/rename-user.yml`:
```yaml
id: rename-getUser-to-fetchUser
language: tsx
rule:
  pattern: getUser
fix: fetchUser
```

Run:
```bash
sg scan   # preview
sg scan --update-all  # apply
```

## Dry-run protocol

Always scan first:
```bash
sg scan --lang tsx -p '<pattern>' --reporter json | jq 'length'
```

Show user the count + a sample of 3 matches before running `--update-all`.

## Gotchas

- **Pattern matches too much** → narrow with node-kind specifier: `pattern: 'function $X() { $$ }'` is more specific than `$X`
- **String literals missed** — ast-grep matches AST, so `"oldName"` is a string node, not an identifier; rename pattern must target strings separately
- **Comments** — ast-grep generally ignores comments; use `grep` + manual Edit for those
- **Template literals with expressions** need separate patterns from plain strings
- **File encoding issues** on Windows — ensure UTF-8 LF

## Constraints

- Always `sg scan` first to count + preview before `sg run --update-all`
- Scope by language (`--lang ts` vs `tsx`) to avoid matching types in wrong context
- Commit state before any `--update-all` — easy revert path
- For >50 files affected, show count + confirm before executing
- Patterns with just `$X` (bare meta-var) are almost always too broad — resist
