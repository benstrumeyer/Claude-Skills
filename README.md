# Claude Code Setup Configuration

My personal Claude Code configuration for reference and reproducibility.

---

## Settings (`~/.claude/settings.json`)

```json
{
  "permissions": {
    "defaultMode": "default"
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
  "voiceEnabled": true
}
```

## /config Settings (set via `/config` UI)

- **Enable Remote Control for all sessions**: `true` — every interactive session is automatically available via [claude.ai/code](https://claude.ai/code) and the Claude mobile app without needing to run `/remote-control` each time.

## Plugins

| Plugin | Source | Purpose |
|--------|--------|---------|
| Playwright | claude-plugins-official | Browser automation via MCP (1 instance for general web tasks) |

## MCP Servers (`.mcp.json`)

Base project config includes a single Playwright instance for general browser automation. Additional MCP servers (e.g., custom game tools) are added per-project.

## Multi-Playwright Orchestration

For tasks requiring parallel browser automation (e.g., scraping multiple sites simultaneously), a fleet of 20 additional Playwright MCP servers can be loaded on demand via a separate config file and a shell alias.

**How it works:**

1. A fleet config (`~/.claude/mcp-playwright-fleet.json`) defines 20 Playwright servers, each with an isolated `--user-data-dir` to prevent cookie/session conflicts:
   ```json
   {
     "mcpServers": {
       "playwright-1": {
         "command": "npx",
         "args": ["@playwright/mcp@latest", "--user-data-dir", "C:\\...\\pw-profile-1"]
       },
       "playwright-2": { "..." : "..." }
     }
   }
   ```

2. A PowerShell function loads the fleet only when needed:
   ```powershell
   function scrape {
     claude --dangerously-skip-permissions --mcp-config "$env:USERPROFILE\.claude\mcp-playwright-fleet.json" @args
   }
   ```

3. Normal `claude` instances get just 1 Playwright server (from the base `.mcp.json`). The `scrape` alias adds 20 more, giving 21 total for parallel browser work.

**Why this pattern:**
- Avoids spinning up 21 browser processes for every Claude session
- Keeps startup fast for general-purpose instances
- Uses `--mcp-config` to additively load servers without `--strict-mcp-config`, so all other MCP servers (Gmail, Notion, etc.) remain available

## Custom Skills (`~/.claude/skills/`)

| Skill | Command | Description |
|-------|---------|-------------|
| [branch](branch.md) | `/branch` | Spawns a background Claude instance on a new feature branch worktree |
| [commit](commit.md) | `/commit` | Groups changed files by feature, creates feature branches, PRs, and auto-merges |
| git-init | `/git-init` | Initializes a git repo with a punny first commit |
| scrape | `/scrape` | Orchestrates parallel browser automation via multi-Playwright MCP |

## Mouse (UtechSmart Venus 16400DPI)

12-button thumb grid + DPI controls. Profile saved in [`mouse-profiles/RSProfile1.pfd`](mouse-profiles/RSProfile1.pfd).

**Thumb Button Grid** (left side, holding mouse, top = closest to scroll wheel):

```
Row 1 (top):     [ 7 ]  [ 8 ]  [ 9 ]
Row 2:           [10 ]  [11 ]  [12 ]
Row 3:           [13 ]  [14 ]  [15 ]
Row 4 (bottom):  [16 ]  [17 ]  [18 ]
```

**Thumb Button Mappings:**

| Button | Mapping | Purpose |
|--------|---------|---------|
| 7 | `Ctrl+Shift+Tab` | Previous tab |
| 8 | `Alt+Right` | Navigate forward |
| 9 | `Alt+Tab` | App switcher |
| 10 | `Ctrl+Tab` | Next tab |
| 11 | `Alt+Left` | Navigate back |
| 12 | DPI switch | Cycle DPI on-the-fly |
| 13 | `Win+Ctrl+Left` | Previous virtual desktop |
| 14 | `Win+Alt+Left` | — |
| 15 | `Win+Shift+Right` | Move window to right monitor |
| 16 | `Win+Ctrl+Right` | Next virtual desktop |
| 17 | `Win+Alt+Right` | — |
| 18 | `Ctrl+W` | Close tab |

**Other Buttons:**

| Button | Mapping |
|--------|---------|
| 1–3 | Left click, Right click, Middle click (defaults) |
| 4 | Scroll wheel tilt |
| 5–6 | DPI up / DPI down |
| 19–20 | Built-in functions |

**Settings:** Sensitivity 10, Polling Rate 2, DPI stage 5 levels, Acceleration on.

## Keybindings

### System-Level Key Remaps (AutoHotKey / PowerToys)

These remaps enable left-hand-only terminal navigation + mouse while using Wispr Flow for voice input:

| Physical Key | Sends | Purpose |
|---|---|---|
| CapsLock | Esc | Quick escape without reaching |
| Esc | CapsLock | Swap with CapsLock |
| Windows Left | Ins | Free up Win key |
| Numpad Dot | ~ | Tilde access from numpad |
| F23 | WinRight | Remap for window management |
| AltRight | WinLeft | Remap for window management |
| ~ (tilde) | Enter | Submit from left hand / near mouse |

### Claude Code Keybindings (`~/.claude/keybindings.json`)

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "$docs": "https://code.claude.com/docs/en/keybindings",
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "alt+w": "chat:submit"
      }
    }
  ]
}
```

> **Note:** `alt+` combos may be intercepted by VS Code's integrated terminal. If running Claude Code inside VS Code, consider `ctrl+` or chord bindings instead.

### VS Code Keybindings (`%APPDATA%\Code\User\keybindings.json`)

**Panel & Sidebar:**

| Key | Command | Notes |
|---|---|---|
| `ctrl+e` | Toggle auxiliary bar (right panel) | Replaces `ctrl+alt+b` |
| `ctrl+g` | Toggle maximized auxiliary bar | |
| `ctrl+b` | Toggle sidebar visibility | |
| `ctrl+e` | Toggle terminal | When `terminal.active` |

**Claude Code Integration:**

| Key | Command | Notes |
|---|---|---|
| `ctrl+y` | Open Claude terminal | Replaces redo |
| `ctrl+d` | Reject proposed diff | |
| `ctrl+space` | Focus Claude sidebar (secondary) | |

**Editor Group Navigation (Vim-style):**

| Key | Command |
|---|---|
| `ctrl+k` | Focus above group |
| `ctrl+j` | Focus below group |
| `ctrl+h` | Focus left group |
| `ctrl+l` | Focus right group |

**Terminal Management:**

| Key | Command |
|---|---|
| `alt+]` | Focus next terminal |
| `alt+[` | Focus previous terminal |
| `alt+s` | Focus next pane |
| `alt+a` | Focus previous pane |
| `alt+j` | Resize pane down |
| `alt+k` | Resize pane up |
| `alt+h` | Resize pane left |
| `alt+l` | Resize pane right |
| `alt+=` | New terminal |
| `ctrl+f10` | Kill terminal |
| `alt+numpad_divide` | Split terminal |
| `shift+enter` | Send escape sequence (in terminal) |

**Vim Overrides Disabled:** `ctrl+w`, `ctrl+p`, `ctrl+b`, `ctrl+y` — freed for VS Code use.

<details>
<summary>Full keybindings.json (copy verbatim)</summary>

```json
[
  {
    "key": "ctrl+e",
    "command": "workbench.action.toggleAuxiliaryBar"
  },
  {
    "key": "ctrl+alt+b",
    "command": "-workbench.action.toggleAuxiliaryBar"
  },
  {
    "key": "ctrl+g",
    "command": "workbench.action.toggleMaximizedAuxiliaryBar"
  },
  {
    "key": "ctrl+e",
    "command": "workbench.action.terminal.toggleTerminal",
    "when": "terminal.active"
  },
  {
    "key": "ctrl+`",
    "command": "-workbench.action.terminal.toggleTerminal",
    "when": "terminal.active"
  },
  {
    "key": "ctrl+d",
    "command": "claude-code.rejectProposedDiff"
  },
  {
    "key": "ctrl+escape",
    "command": "-claude-vscode.focus",
    "when": "editorTextFocus && !config.claudeCode.useTerminal"
  },
  {
    "key": "ctrl+space",
    "command": "claudeVSCodeSidebarSecondary.focus"
  },
  {
    "key": "alt+a",
    "command": "-editor.action.accessibilityHelpConfigureAssignedKeybindings",
    "when": "accessibilityHelpIsShown && accessibleViewHasAssignedKeybindings"
  },
  {
    "key": "ctrl+b",
    "command": "workbench.action.toggleSidebarVisibility"
  },
  {
    "key": "ctrl+b",
    "command": "-workbench.action.toggleSidebarVisibility"
  },
  {
    "key": "ctrl+y",
    "command": "-chatEditor.action.acceptHunk",
    "when": "chatEdits.cursorInChangeRange && chatEdits.hasEditorModifications && editorFocus && !chatEdits.isCurrentlyBeingModified || chatEdits.cursorInChangeRange && chatEdits.hasEditorModifications && notebookCellListFocused && !chatEdits.isCurrentlyBeingModified"
  },
  {
    "key": "ctrl+k",
    "command": "workbench.action.focusAboveGroup"
  },
  {
    "key": "ctrl+k ctrl+up",
    "command": "-workbench.action.focusAboveGroup"
  },
  {
    "key": "ctrl+j",
    "command": "workbench.action.focusBelowGroup"
  },
  {
    "key": "ctrl+k ctrl+down",
    "command": "-workbench.action.focusBelowGroup"
  },
  {
    "key": "ctrl+h",
    "command": "workbench.action.focusLeftGroup"
  },
  {
    "key": "ctrl+k ctrl+left",
    "command": "-workbench.action.focusLeftGroup"
  },
  {
    "key": "ctrl+l",
    "command": "workbench.action.focusRightGroup"
  },
  {
    "key": "ctrl+k ctrl+right",
    "command": "-workbench.action.focusRightGroup"
  },
  {
    "key": "ctrl+w",
    "command": "-extension.vim_ctrl+w",
    "when": "editorTextFocus && vim.active && vim.use<C-w> && !inDebugRepl"
  },
  {
    "key": "ctrl+p",
    "command": "-extension.vim_ctrl+p",
    "when": "editorTextFocus && vim.active && vim.use<C-p> && !inDebugRepl || vim.active && vim.use<C-p> && !inDebugRepl && vim.mode == 'CommandlineInProgress' || vim.active && vim.use<C-p> && !inDebugRepl && vim.mode == 'SearchInProgressMode'"
  },
  {
    "key": "ctrl+y",
    "command": "claude-vscode.terminal.open"
  },
  {
    "key": "ctrl+y",
    "command": "-redo"
  },
  {
    "key": "ctrl+y",
    "command": "-extension.vim_ctrl+y",
    "when": "editorTextFocus && vim.active && vim.use<C-y> && !inDebugRepl"
  },
  {
    "key": "shift+enter",
    "command": "workbench.action.terminal.sendSequence",
    "args": {
      "text": "\u001b\r"
    },
    "when": "terminalFocus"
  },
  {
    "key": "alt+]",
    "command": "-editor.action.accessibleViewNext",
    "when": "accessibleViewIsShown && accessibleViewSupportsNavigation"
  },
  {
    "key": "alt+]",
    "command": "-editor.action.inlineSuggest.showNext",
    "when": "inlineSuggestionVisible && !editorReadonly"
  },
  {
    "key": "alt+]",
    "command": "workbench.action.terminal.focusNext",
    "when": "terminalFocus && terminalHasBeenCreated && !terminalEditorFocus || terminalFocus && terminalProcessSupported && !terminalEditorFocus"
  },
  {
    "key": "ctrl+pagedown",
    "command": "-workbench.action.terminal.focusNext",
    "when": "terminalFocus && terminalHasBeenCreated && !terminalEditorFocus || terminalFocus && terminalProcessSupported && !terminalEditorFocus"
  },
  {
    "key": "alt+[",
    "command": "workbench.action.terminal.focusPrevious",
    "when": "terminalFocus && terminalHasBeenCreated && !terminalEditorFocus || terminalFocus && terminalProcessSupported && !terminalEditorFocus"
  },
  {
    "key": "ctrl+pageup",
    "command": "-workbench.action.terminal.focusPrevious",
    "when": "terminalFocus && terminalHasBeenCreated && !terminalEditorFocus || terminalFocus && terminalProcessSupported && !terminalEditorFocus"
  },
  {
    "key": "alt+=",
    "command": "workbench.action.terminal.new",
    "when": "terminalProcessSupported || terminalWebExtensionContributedProfile"
  },
  {
    "key": "ctrl+shift+`",
    "command": "-workbench.action.terminal.new",
    "when": "terminalProcessSupported || terminalWebExtensionContributedProfile"
  },
  {
    "key": "alt+=",
    "command": "-increaseSearchEditorContextLines",
    "when": "inSearchEditor"
  },
  {
    "key": "ctrl+f10",
    "command": "workbench.action.terminal.kill"
  },
  {
    "key": "ctrl+shift+5",
    "command": "-workbench.action.terminal.split",
    "when": "terminalFocus && terminalProcessSupported || terminalFocus && terminalWebExtensionContributedProfile"
  },
  {
    "key": "alt+-",
    "command": "-decreaseSearchEditorContextLines",
    "when": "inSearchEditor"
  },
  {
    "key": "alt+numpad_divide",
    "command": "workbench.action.terminal.split"
  },
  {
    "key": "alt+j",
    "command": "workbench.action.terminal.resizePaneDown"
  },
  {
    "key": "alt+k",
    "command": "workbench.action.terminal.resizePaneUp"
  },
  {
    "key": "alt+k",
    "command": "-claude-vscode.insertAtMention",
    "when": "editorTextFocus"
  },
  {
    "key": "alt+k",
    "command": "-editor.action.accessibilityHelpConfigureKeybindings",
    "when": "accessibilityHelpIsShown && accessibleViewHasUnassignedKeybindings"
  },
  {
    "key": "alt+k",
    "command": "-keybindings.editor.recordSearchKeys",
    "when": "inKeybindings && inKeybindingsSearch"
  },
  {
    "key": "alt+h",
    "command": "workbench.action.terminal.resizePaneLeft"
  },
  {
    "key": "alt+l",
    "command": "workbench.action.terminal.resizePaneRight"
  },
  {
    "key": "ctrl+b",
    "command": "-extension.vim_ctrl+b",
    "when": "editorTextFocus && vim.active && vim.use<C-b> && !inDebugRepl && vim.mode != 'Insert'"
  },
  {
    "key": "alt+s",
    "command": "workbench.action.terminal.focusNextPane",
    "when": "terminalFocus && terminalHasBeenCreated && terminalSplitPaneActive || terminalFocus && terminalProcessSupported && terminalSplitPaneActive"
  },
  {
    "key": "alt+down",
    "command": "-workbench.action.terminal.focusNextPane",
    "when": "terminalFocus && terminalHasBeenCreated && terminalSplitPaneActive || terminalFocus && terminalProcessSupported && terminalSplitPaneActive"
  },
  {
    "key": "alt+[",
    "command": "-editor.action.inlineSuggest.showPrevious",
    "when": "inlineSuggestionVisible && !editorReadonly"
  },
  {
    "key": "alt+[",
    "command": "-editor.action.accessibleViewPrevious",
    "when": "accessibleViewIsShown && accessibleViewSupportsNavigation"
  },
  {
    "key": "alt+a",
    "command": "workbench.action.terminal.focusPreviousPane",
    "when": "terminalFocus && terminalHasBeenCreated && terminalSplitPaneActive || terminalFocus && terminalProcessSupported && terminalSplitPaneActive"
  },
  {
    "key": "alt+up",
    "command": "-workbench.action.terminal.focusPreviousPane",
    "when": "terminalFocus && terminalHasBeenCreated && terminalSplitPaneActive || terminalFocus && terminalProcessSupported && terminalSplitPaneActive"
  }
]
```

</details>

## WisprFlow Pair Programming Setup

Voice-driven pair programming using VoiceMeeter Banana to route both your mic and call audio (Discord, Google Meet, Zoom, etc.) into WisprFlow for transcription — while still hearing everything through your headphones normally.

See the full step-by-step guide: [**wisprflow-pair-programming.md**](wisprflow-pair-programming.md)

**Quick summary:**

```
Mic ─────────────► VoiceMeeter Strip 1 ──► B1 (WisprFlow) + A1 (Headphones)
Discord/Meet/etc ► VoiceMeeter Virtual Input ──► B1 (WisprFlow) + A1 (Headphones)
```

| Setting | Value |
|---------|-------|
| VoiceMeeter A1 | Headphones (Realtek) |
| WisprFlow Input | Voicemeeter Out B1 |
| App Speaker Output | VoiceMeeter Input (VAIO) |
| Windows Output | VoiceMeeter Input (VAIO) |

## Key Behaviors

- **Default permissions mode**: Standard permission prompts (public-facing recommendation)
- **Voice enabled**: Hold-to-talk dictation active
- **Auto-updates**: On `latest` channel
- **Remote Control**: Always on — every session is accessible from phone/browser
- **Commit workflow**: Feature branch → PR → auto-merge (uses `--admin`)

## How to Reproduce

1. Install Claude Code: `npm install -g @anthropic-ai/claude-code`
2. Copy `settings.json` to `~/.claude/settings.json`
3. Copy skills from this repo to `~/.claude/skills/<skill-name>/skill.md`
4. Run `/config` → Enable Remote Control for all sessions → `true`
5. Install Playwright plugin: `/plugins` → search "playwright" → install
6. (Optional) Copy `mcp-playwright-fleet.json` to `~/.claude/` and add the `scrape` function to your shell profile for multi-Playwright orchestration
