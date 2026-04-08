---
name: branch
description: Spin up a new feature branch from master in a worktree with a background Claude instance working on your prompt
user-invocable: true
---

Spawn a background Claude Code instance on a new feature branch without leaving your current branch.

## How it works

This skill wraps `git worktree` + `claude -p` to give you parallel feature development. It's similar to Claude Code's built-in `claude --worktree` but with key differences:

| | Built-in `claude -w` | `/branch` |
|---|---|---|
| Branch naming | `worktree-<name>` | `feature/<name>` (PR-ready) |
| Base branch | Always `origin/HEAD` | `master` by default, configurable per invocation |
| Location | `.claude/worktrees/<name>/` | `.worktrees/<name>/` at repo root |
| Execution | Interactive or blocking (`-p`) | Background — you keep working |
| Auto-commit | No | Yes — baked into the prompt |
| Cleanup | Auto if no changes on exit | Manual (`git worktree remove`) |

Use `/branch` when you want to fire-and-forget a task while you keep working. Use `claude -w` when you want to interactively work in a separate branch yourself.

## Arguments

Everything after `/branch` is the prompt for the new Claude instance.

Optional prefix: `--base <branch>` to branch from something other than `master`.

Examples:
- `/branch add dark mode toggle to the settings page`
- `/branch --base develop fix the flaky auth tests`

## Steps

1. **Parse arguments**: Extract optional `--base <branch>` (default: `master`). Everything else is the task prompt.

2. **Generate branch name**: Derive a short, descriptive `feature/<name>` from the prompt. Lowercase, hyphenated, max 4 words (e.g. `feature/add-dark-mode`, `feature/fix-auth-tests`).

3. **Get repo root and fetch latest**:
```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
git fetch origin master
```

4. **Create the worktree**:
```bash
git worktree add "$REPO_ROOT/.worktrees/<name>" -b feature/<name> origin/master
```

5. **Launch Claude in background**:
```bash
cd "$REPO_ROOT/.worktrees/<name>" && nohup claude -p "<assembled prompt>" \
  --dangerously-skip-permissions \
  > claude-task.log 2>&1 &
```

The assembled prompt should be:
```
You are working in a git worktree on branch `feature/<name>`, branched from master.

Your task: <user's original prompt>

When you are done:
1. Stage and commit your changes with a clear conventional commit message.
2. Push the branch: git push -u origin feature/<name>
```

6. **Report to user**:
```
Branch: feature/<name>
Worktree: .worktrees/<name>/
Log: .worktrees/<name>/claude-task.log

Claude is working on it in the background. When it's done:
  - Review: cd .worktrees/<name>/
  - Check log: cat .worktrees/<name>/claude-task.log
  - Test: start a dev server on a different port from the worktree
  - PR: use /commit from the worktree, or gh pr create
  - Cleanup: git worktree remove .worktrees/<name>
```

## Rules

- NEVER switch the user's current branch. The whole point is isolation.
- Always fetch the base branch before creating the worktree.
- If the worktree directory or branch already exists, tell the user and ask what to do.
- Use `--dangerously-skip-permissions` since the user runs in bypass mode.
- If the project has a dev server, remind the user they can `cd` into the worktree and start it on a different port to test side-by-side.
