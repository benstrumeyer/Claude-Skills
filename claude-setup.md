# Claude Code Setup Configuration

My personal Claude Code configuration for reference and reproducibility.

---

## Settings (`~/.claude/settings.json`)

```json
{
  "permissions": {
    "defaultMode": "bypassPermissions"
  },
  "extraKnownMarketplaces": {
    "claude-plugins-official": {
      "source": {
        "source": "github",
        "repo": "anthropics/claude-plugins-official"
      }
    }
  },
  "enabledPlugins": {
    "playwright@claude-plugins-official": true
  },
  "autoUpdatesChannel": "latest",
  "voiceEnabled": true,
  "skipDangerousModePermissionPrompt": true
}
```

## /config Settings (set via `/config` UI)

- **Enable Remote Control for all sessions**: `true` — every interactive session is automatically available via [claude.ai/code](https://claude.ai/code) and the Claude mobile app without needing to run `/remote-control` each time.

## Plugins

| Plugin | Source | Purpose |
|--------|--------|---------|
| Playwright | claude-plugins-official | Browser automation via MCP (used by /job-search and general web tasks) |

## Custom Skills (`~/.claude/skills/`)

| Skill | Command | Description |
|-------|---------|-------------|
| [commit](commit.md) | `/commit` | Groups changed files by feature, creates feature branches, PRs, and auto-merges |
| [git-init](../git-init not tracked) | `/git-init` | Initializes a git repo with a punny first commit |
| [job-search](../Mystery-Project) | `/job-search` | Orchestrates parallel job application filling via Playwright MCP |

## Key Behaviors

- **Bypass permissions mode**: All tool calls are auto-approved (personal machine, solo dev)
- **Voice enabled**: Hold-to-talk dictation active
- **Auto-updates**: On `latest` channel
- **Remote Control**: Always on — every session is accessible from phone/browser
- **Commit workflow**: Feature branch → PR → auto-merge (no self-approval, uses `--admin`)

## How to Reproduce

1. Install Claude Code: `npm install -g @anthropic-ai/claude-code`
2. Copy `settings.json` to `~/.claude/settings.json`
3. Copy skills from this repo to `~/.claude/skills/<skill-name>/skill.md`
4. Run `/config` → Enable Remote Control for all sessions → `true`
5. Install Playwright plugin: `/plugins` → search "playwright" → install
