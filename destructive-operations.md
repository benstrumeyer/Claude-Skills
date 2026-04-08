# Destructive Operations — NEVER DO

Operations that are irreversible, kill active sessions, or destroy work. Never run these without explicit user confirmation, and some should never be run at all.

## Always Forbidden

- `taskkill //f //im "node.exe"` — Kills ALL Node processes including Claude Code itself. Use PID-specific kills instead: `taskkill //f //pid <pid>` or `kill <pid>`
- `git reset --hard` — Destroys uncommitted work with no recovery
- `git push --force` to main/master — Overwrites shared history
- `git clean -fd` — Deletes untracked files permanently
- `git commit` / `git push` without explicit user request — Ben controls when code is committed
- `rm -rf` on project directories — No undo
- `rm -rf data/chrome-profile/` — Deletes stored browser login cookies, forces manual re-login. Rate limiting is NOT fixed by deleting the profile.
- `DROP TABLE` / `DELETE FROM` without WHERE — Wipes entire tables

## Require Explicit Confirmation

- `git push --force` to any branch — Can overwrite upstream work
- `git checkout -- .` / `git restore .` — Discards all uncommitted changes
- `git branch -D` — Force-deletes a branch even if unmerged
- Deleting files that may contain user work in progress
- Overwriting `.env`, credentials, or config files
- Killing processes by image name (affects all matching processes)

## Safe Alternatives

| Instead of | Do this |
|---|---|
| `taskkill //f //im "node.exe"` | `taskkill //f //pid <specific_pid>` |
| `git reset --hard` | `git stash` then review |
| `git push --force` | `git push --force-with-lease` |
| `rm -rf directory/` | Move to trash or confirm contents first |
| `git clean -fd` | `git clean -fdn` (dry run) first |
