# Windows Terminal Setup

## Startup Tabs

4 tabs open automatically on launch, each with its own color and project:

| # | Title | Color | PS Alias | Notes |
|---|-------|-------|----------|-------|
| 1 | Project 1 | green `#00CC44` | `project1` | Special session — starts backend + frontend before launching Claude |
| 2 | Project 2 | orange `#FF6600` | `project2` | Claude via nvim session command |
| 3 | Project 3 | red `#CC0000` | `project3` | Claude via `yolo` |
| 4 | Project 4 | blue `#1E90FF` | `project4` | Claude via `yolo` |

## Workflow (all tabs)

Every tab follows the same pattern:

```
PS alias → nvim -c "terminal claude --dangerously-skip-permissions --mcp-config ..."
```

Claude runs inside nvim's `:terminal`. No standalone terminal — nvim is always the host.

## `startupActions` (settings.json)

```
new-tab --title "Project 1" --tabColor "#00CC44" -p "Windows PowerShell" -- powershell -NoExit -Command "project1" ;
new-tab --title "Project 2" --tabColor "#FF6600" -p "Windows PowerShell" -- powershell -NoExit -Command "project2" ;
new-tab --title "Project 3" --tabColor "#CC0000" -p "Windows PowerShell" -- powershell -NoExit -Command "project3" ;
new-tab --title "Project 4" --tabColor "#1E90FF" -p "Windows PowerShell" -- powershell -NoExit -Command "project4"
```

Tab colors must be set in **two places**: the `actions` array entries AND the `startupActions` string.

## PowerShell Aliases

```powershell
# Core alias — opens nvim with Claude in a terminal
function yolo {
    $extraArgs = $args -join " "
    $claudeCmd = "claude --dangerously-skip-permissions --mcp-config `"$env:USERPROFILE\.claude\mcp-docs.json`" $extraArgs"
    nvim -c "terminal $claudeCmd"
}

# Per-project aliases
function project2 { Set-Location ~\repos\project2; yolo }
function project3 { Set-Location ~\repos\project3; yolo }
function project4 { Set-Location ~\repos\project4; yolo }

# Project 1 is special — starts services before launching Claude
function project1 {
    # starts backend + frontend, waits for backend ready, then:
    $claudeCmd = "claude --dangerously-skip-permissions --mcp-config `"$env:USERPROFILE\.claude\mcp-playwright-fleet.json`""
    nvim -c "terminal $claudeCmd"
}
```

## nvim Session Commands

For projects that need custom startup behavior, define a user command in `init.lua`:

```lua
vim.api.nvim_create_user_command('Project2Session', function()
  local mcp = (vim.env.USERPROFILE or "C:/Users/user") .. "/.claude/mcp-docs.json"
  local cmd = 'claude --dangerously-skip-permissions --mcp-config "' .. mcp .. '"'
  vim.cmd("cd C:/Users/user/repos/project2")
  vim.cmd("terminal " .. cmd)
end, {})
```

Then call it from the PS alias: `nvim -c "Project2Session"`

## WT Keybindings (settings.json)

Per-project tab shortcuts and on-demand tab openers:

```json
{ "id": "User.newTab.Project1", "keys": "alt+2" },
{ "id": "User.newTab.Project2", "keys": "alt+3" },
{ "id": "User.newTab.Project3", "keys": "alt+4" },
{ "id": "User.newTab.Project4", "keys": "alt+5" }
```
