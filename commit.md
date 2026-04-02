---
name: commit
description: Group changed files by feature, create PRs, and merge them
user-invocable: true
---

Run `git status`, `git diff`, `git diff --cached`, and `git log --oneline -10` in parallel.

Group changed files into semantic clusters (files implementing the same logical change). Each cluster becomes one PR with one commit. Stage specific files per group — never `git add -A`.

## Workflow per cluster

For each semantic cluster, do the following **sequentially** (finish one cluster before starting the next so merges into master stay clean):

1. **Start from current branch**: Make sure you're on the base branch (whatever branch was active when the skill was invoked). Store this as `BASE_BRANCH`.
2. **Create branch**: `git checkout -b feature/<short-concise-name>` — the name should be lowercase, hyphenated, and meaningful (e.g. `feature/add-user-auth`, `feature/fix-pipeline-timeout`, `feature/update-readme-badges`)
3. **Stage specific files**: `git add <file1> <file2> ...`
4. **Commit** using HEREDOC format:
```
git commit -m "$(cat <<'EOF'
<type>(<scope>): <imperative lowercase description under 60 chars>

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```
5. **Push**: `git push -u origin feature/<short-concise-name>`
6. **Create PR**: `gh pr create --title "<same as commit message first line>" --body "$(cat <<'EOF' ... EOF)"`
7. **Merge**: `gh pr merge --merge --delete-branch --admin`
9. **Return to base**: `git checkout $BASE_BRANCH`

Then proceed to the next cluster.

## Commit message format

Types: `feat` `fix` `refactor` `perf` `docs` `style` `test` `build` `ci` `chore`
Scope: short noun for the area (e.g. `pipeline`, `api`). Omit if cross-cutting.
Add body only if the "why" isn't obvious. Breaking changes: `feat(api)!: description`

## Rules

- This workflow is designed for personal/solo repos. The `--admin` merge flag skips branch protection and approval requirements. For team repos, add back `gh pr review --approve` (from a different account) and remove `--admin`.
- Never commit secrets
- Never amend — always new commits
- Each PR gets exactly 1 commit
- Process clusters sequentially so each branch is based on the latest master
- Use HEREDOC for commit messages and PR bodies
- Verify with `git log` and `git status` after all clusters are done
