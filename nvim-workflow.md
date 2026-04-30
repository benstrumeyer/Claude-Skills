# NeoVim + Claude Workflow

My day-to-day setup for running multiple Claude instances across projects using NeoVim inside Windows Terminal.

---

## Overview

- **Windows Terminal** — 3 tabs, each a separate PowerShell session
- **NeoVim terminal splits** — each split runs a Claude session or shell command
- **`Ctrl+Tab`** — switch between WT tabs (mouse thumb button also mapped to this)

---

## Flow Per Tab

1. `cd` into a project directory
2. Open NeoVim
3. Open terminal splits inside NeoVim (see keybindings below)
4. Use split navigation to move between Claude sessions without leaving NeoVim

Each WT tab = one project context. Each NeoVim split = one Claude session or task.

---

## NeoVim Keybindings (`init.lua`)

### Splits

| Key | Action |
|-----|--------|
| `Ctrl+\` | New vertical terminal split (right) |
| `Ctrl+N` | New horizontal terminal split (below) |
| `Alt+O` | New terminal split right |
| `Alt+Y` | New terminal split left |
| `Alt+U` | New terminal split below |
| `Alt+I` | New terminal split above |

### Navigation

| Key | Action |
|-----|--------|
| `Ctrl+H/L` | Move left/right between splits |
| `Ctrl+J/K` | Move up/down between splits (via WT passthrough) |
| `Alt+S / Alt+A` | Cycle forward/backward through all panes |
| `Alt+] / Alt+[` | Cycle through terminal panes only |

### Resize

| Key | Action |
|-----|--------|
| `Alt+H/L` | Resize pane left/right |
| `Alt+J/K` | Resize pane up/down |

### Zoom

| Key | Action |
|-----|--------|
| `Ctrl+B` | Toggle current pane fullscreen (restores exact layout on second press) |

### Misc

| Key | Action |
|-----|--------|
| `Ctrl+F` | Exit terminal insert mode → normal mode |
| `Alt+-` | Close current pane (preserves all other panes) |
| `Alt+0` | Reload `init.lua` |
| `Ctrl+C` | Copy selection to system clipboard |
| `Ctrl+V` | Paste from system clipboard (bracketed paste in terminal) |

---

## Windows Terminal Passthrough

Some `Ctrl+` keys are intercepted by WT before reaching NeoVim. Fixed via `sendInput` actions in WT `settings.json`:

| Key | Sends to NeoVim |
|-----|----------------|
| `Ctrl+J` | `\x1b[106;5u` |
| `Ctrl+K` | `\x1b[107;5u` |

These let `Ctrl+J/K` navigate horizontal splits without WT consuming them.

---

## Config Location

- NeoVim: `%LOCALAPPDATA%\nvim\init.lua`
- Windows Terminal: `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`
