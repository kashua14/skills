---
name: git-guardrails-codex
description: Set up Codex-oriented git guardrails by installing a git wrapper that blocks dangerous commands such as push, reset --hard, clean, branch -D, and restore or checkout of the whole tree. Use when user wants to prevent destructive git operations in Codex or local shells.
---

# Setup Git Guardrails For Codex

Codex does not expose pre-command git hooks in the same style as some other coding assistants. For Codex, install a `git` wrapper earlier on `PATH` so dangerous commands are rejected before the real `git` binary runs.

## What Gets Blocked

- `git push` (all variants including `--force`)
- `git reset --hard`
- `git clean -f` / `git clean -fd`
- `git branch -D`
- `git checkout .` / `git restore .`

When blocked, the shell sees a message explaining that the command is intentionally denied.

## Steps

### 1. Choose scope

Prefer **global** install for Codex because login shells will reliably see `~/.codex/bin` on `PATH`.

If the user wants narrower scope, install **project-only** and explain that repo-local shell setup must be sourced before launching Codex.

### 2. Copy the wrapper script

The bundled script is at: [scripts/git-wrapper.sh](scripts/git-wrapper.sh)

Copy it to the target location based on scope:

- **Project**: `.codex/bin/git`
- **Global**: `~/.codex/bin/git`

Make it executable with `chmod +x`.

### 3. Put the wrapper first on `PATH`

Add the wrapper directory to `PATH` without overwriting existing entries.

**Project** (`.codex/env.zsh`):

```bash
export PATH="$PWD/.codex/bin:$PATH"
```

**Global** (`~/.zprofile`):

```bash
export PATH="$HOME/.codex/bin:$PATH"
```

If the target shell config already exists, merge the export cleanly and do not overwrite unrelated settings.

### 4. Ask about customization

Ask if user wants to add or remove any patterns from the blocked list. Edit the copied script accordingly.

### 5. Verify

Run a quick test:

```bash
git status
git push origin main
```

`git status` should succeed. `git push origin main` should exit with code 2 and print a BLOCKED message to stderr.
