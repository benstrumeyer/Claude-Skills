---
name: commit
description: Group changed files by feature and create conventional commits
user-invocable: true
---

Run `git status`, `git diff`, `git diff --cached`, and `git log --oneline -10` in parallel.

Group changed files into semantic clusters (files implementing the same logical change). Each cluster becomes one commit. Stage specific files per group — never `git add -A`.

Commit message format:
```
<type>(<scope>): <imperative lowercase description under 60 chars>

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
```

Types: `feat` `fix` `refactor` `perf` `docs` `style` `test` `build` `ci` `chore`
Scope: short noun for the area (e.g. `pipeline`, `api`). Omit if cross-cutting.
Add body only if the "why" isn't obvious. Breaking changes: `feat(api)!: description`

Never commit secrets. Never push unless asked. Never amend — always new commits.
Use HEREDOC for commit messages. Verify with `git log` and `git status` after.
