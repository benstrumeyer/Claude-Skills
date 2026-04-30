-- Use PowerShell as the shell for :terminal
vim.opt.shell = "powershell"
vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
vim.opt.shellquote = ""
vim.opt.shellxquote = ""

-- Re-equalize splits on terminal resize (e.g. WT restored from minimized)
vim.api.nvim_create_autocmd("VimResized", {
  callback = function() vim.cmd("wincmd =") end
})

-- System clipboard integration
vim.opt.clipboard = 'unnamedplus'

-- Ctrl+C in visual mode: copy to system clipboard
vim.keymap.set('v', '<C-c>', '"+y', { noremap = true })

-- Ctrl+V in normal mode: paste from system clipboard
vim.keymap.set('n', '<C-v>', '"+p', { noremap = true })

-- Ctrl+V in terminal mode: bracketed paste (preserves syntax highlighting in claude)
vim.keymap.set('t', '<C-v>', function()
  local text = vim.fn.getreg('+')
  local chan = vim.b.terminal_job_id
  if chan and text ~= '' then
    vim.api.nvim_chan_send(chan, '\x1b[200~' .. text .. '\x1b[201~')
  end
end, { noremap = true })

-- Forward Shift+arrows in terminal mode (for selection in Claude)
local function term_send(seq)
  return function()
    local chan = vim.b.terminal_job_id
    if chan then vim.api.nvim_chan_send(chan, seq) end
  end
end
vim.keymap.set('t', '<S-Left>',    term_send('\x1b[1;2D'), { noremap = true })
vim.keymap.set('t', '<S-Right>',   term_send('\x1b[1;2C'), { noremap = true })
vim.keymap.set('t', '<S-Up>',      term_send('\x1b[1;2A'), { noremap = true })
vim.keymap.set('t', '<S-Down>',    term_send('\x1b[1;2B'), { noremap = true })
vim.keymap.set('t', '<S-A-Left>',  term_send('\x1b[1;4D'), { noremap = true })
vim.keymap.set('t', '<S-A-Right>', term_send('\x1b[1;4C'), { noremap = true })

-- Case-insensitive search
vim.opt.ignorecase = true
vim.opt.smartcase = true  -- case-sensitive if pattern has uppercase

-- Ctrl+\ : open new vertical terminal split to the right
vim.keymap.set('n', '<C-\\>', ':vsplit | wincmd l | term<CR>')
vim.keymap.set('t', '<C-\\>', '<C-\\><C-n>:vsplit | wincmd l | term<CR>')

-- Ctrl+f to enter normal mode in terminal
vim.keymap.set('t', '<C-f>', '<C-\\><C-n>02l')

-- Ctrl+Backspace: Windows Terminal sends \x1b[127;5u, forward \x08 to shell for word delete
vim.keymap.set('t', '\x1b[127;5u', function()
  local chan = vim.b.terminal_job_id
  if chan then vim.api.nvim_chan_send(chan, '\x08') end
end)

-- Ctrl+n to open a new horizontal terminal split
vim.keymap.set('n', '<C-n>', ':new | term<CR>')
vim.keymap.set('t', '<C-n>', '<C-\\><C-n>:new | term<CR>')

-- Alt+numpad/ : vertical split, new terminal on the right, stay on left
vim.keymap.set('n', '<A-kDivide>', ':vsplit | wincmd l | term<CR>')
vim.keymap.set('t', '<A-kDivide>', '<C-\\><C-n>:vsplit | wincmd l | term<CR>')

-- Alt+0 : reload config
vim.keymap.set('n', '<A-0>', ':source $MYVIMRC<CR>')
vim.keymap.set('t', '<A-0>', '<C-\\><C-n>:source $MYVIMRC<CR>')

-- Shift+J/K : jump 20 lines up/down
vim.keymap.set('n', 'J', '20j')
vim.keymap.set('n', 'K', '20k')

-- Ctrl+h/j/k/l : navigate between panes (works from terminal too)
local function nav(dir)
  return function()
    vim.cmd('wincmd ' .. dir)
    vim.schedule(function()
      if vim.bo.buftype == 'terminal' then
        vim.cmd('startinsert')
      end
    end)
  end
end

vim.keymap.set('n', '<C-h>', nav('h'))
vim.keymap.set('n', '<C-j>', nav('j'))
vim.keymap.set('n', '\x1b[106;5u', nav('j'))  -- Windows Terminal Ctrl+J passthrough
vim.keymap.set('n', '<C-k>', nav('k'))
vim.keymap.set('n', '\x1b[107;5u', nav('k'))  -- Windows Terminal Ctrl+K passthrough
vim.keymap.set('n', '<C-l>', nav('l'))

local function term_nav(dir)
  return function()
    vim.cmd('stopinsert')
    vim.cmd('wincmd ' .. dir)
    vim.schedule(function()
      if vim.bo.buftype == 'terminal' then
        vim.cmd('startinsert')
      end
    end)
  end
end

vim.keymap.set('t', '<C-h>', term_nav('h'))
vim.keymap.set('t', '<C-j>', term_nav('j'))
vim.keymap.set('t', '\x1b[106;5u', term_nav('j'))  -- Windows Terminal Ctrl+J passthrough
vim.keymap.set('t', '<C-k>', term_nav('k'))
vim.keymap.set('t', '\x1b[107;5u', term_nav('k'))  -- Windows Terminal Ctrl+K passthrough
vim.keymap.set('t', '<C-l>', term_nav('l'))

-- Alt+] / Alt+[ : cycle through terminal windows
local function get_term_wins()
  return vim.tbl_filter(function(w)
    return vim.bo[vim.api.nvim_win_get_buf(w)].buftype == 'terminal'
  end, vim.api.nvim_list_wins())
end

local function next_terminal()
  local wins = get_term_wins()
  if #wins == 0 then return end
  local cur = vim.api.nvim_get_current_win()
  for i, w in ipairs(wins) do
    if w == cur then vim.api.nvim_set_current_win(wins[(i % #wins) + 1]); return end
  end
  vim.api.nvim_set_current_win(wins[1])
end

local function prev_terminal()
  local wins = get_term_wins()
  if #wins == 0 then return end
  local cur = vim.api.nvim_get_current_win()
  for i, w in ipairs(wins) do
    if w == cur then vim.api.nvim_set_current_win(wins[((i - 2) % #wins) + 1]); return end
  end
  vim.api.nvim_set_current_win(wins[#wins])
end

vim.keymap.set({'n','t'}, '<A-]>', function()
  if vim.fn.mode() == 't' then vim.cmd('stopinsert') end
  next_terminal()
end)
vim.keymap.set({'n','t'}, '<A-[>', function()
  if vim.fn.mode() == 't' then vim.cmd('stopinsert') end
  prev_terminal()
end)

-- Auto-enter insert mode when clicking into a terminal pane
local function on_click()
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes('<LeftMouse>', true, false, true), 'n', true
  )
  vim.schedule(function()
    if vim.bo.buftype == 'terminal' and vim.fn.mode() == 'n' then
      vim.cmd('startinsert')
    end
  end)
end

vim.keymap.set('n', '<LeftMouse>', on_click, { noremap = true })
vim.keymap.set('n', '<2-LeftMouse>', on_click, { noremap = true })

-- Alt+s / Alt+a : cycle through all panes
vim.keymap.set('n', '<A-s>', '<C-w>w')
vim.keymap.set('n', '<A-a>', '<C-w>W')
vim.keymap.set('t', '<A-s>', '<C-\\><C-n><C-w>w')
vim.keymap.set('t', '<A-a>', '<C-\\><C-n><C-w>W')

-- Alt+h/j/k/l : resize panes
vim.keymap.set('n', '<A-h>', ':vertical resize -10<CR>',  { noremap = true })
vim.keymap.set('n', '<A-l>', ':vertical resize +10<CR>',  { noremap = true })
vim.keymap.set('n', '<A-j>', ':resize +10<CR>',           { noremap = true })
vim.keymap.set('n', '<A-k>', ':resize -10<CR>',           { noremap = true })
vim.keymap.set('t', '<A-h>', '<C-\\><C-n>:vertical resize -10<CR>i', { noremap = true })
vim.keymap.set('t', '<A-l>', '<C-\\><C-n>:vertical resize +10<CR>i', { noremap = true })
vim.keymap.set('t', '<A-j>', '<C-\\><C-n>:resize +10<CR>i',          { noremap = true })
vim.keymap.set('t', '<A-k>', '<C-\\><C-n>:resize -10<CR>i',          { noremap = true })

-- Alt+Minus : close current pane
vim.keymap.set('n', '<A-->',  ':close<CR>',                      { noremap = true })
vim.keymap.set('t', '<A-->', '<C-\\><C-n>:close<CR>',           { noremap = true })

-- Zoom toggle: maximize current pane, restore on second press
local zoom_restore = nil
local function toggle_zoom()
  if zoom_restore then
    vim.cmd(zoom_restore)
    zoom_restore = nil
  else
    zoom_restore = vim.fn.winrestcmd()
    vim.cmd('wincmd _')
    vim.cmd('wincmd |')
  end
end
-- Ctrl+Space : zoom toggle (n + t modes via WT passthrough escape sequence)
local function do_zoom()
  toggle_zoom()
  vim.schedule(function()
    if vim.bo.buftype == 'terminal' then vim.cmd('startinsert') end
  end)
end
vim.keymap.set('n', '<C-b>', do_zoom, { noremap = true })
vim.keymap.set('t', '<C-b>', do_zoom, { noremap = true })

-- MysterySession: open terminal, cd to Mystery-Project, run js
vim.api.nvim_create_user_command('MysterySession', function()
  vim.cmd("terminal")
  vim.schedule(function()
    local chan = vim.b.terminal_job_id
    if chan then
      vim.api.nvim_chan_send(chan, "Set-Location C:\\Users\\ben\\repos\\Mystery-Project; js\r")
    end
  end)
end, {})

-- PetlordzSession: vertical split with Claude in petlordz (left) and mindex (right)
vim.api.nvim_create_user_command('PetlordzSession', function()
  local mcp = (vim.env.USERPROFILE or "C:/Users/ben") .. "/.claude/mcp-docs.json"
  local cmd = 'claude --dangerously-skip-permissions --mcp-config "' .. mcp .. '"'
  vim.cmd("cd C:/Users/ben/repos/petlordz")
  vim.cmd("terminal " .. cmd)
  vim.schedule(function()
    vim.cmd("stopinsert")
    vim.cmd("vsplit")
    vim.cmd("wincmd l")
    vim.cmd("lcd C:/Users/ben/repos/mindex")
    vim.cmd("terminal " .. cmd)
    vim.defer_fn(function()
      vim.cmd("stopinsert")
      vim.cmd("wincmd =")
      vim.cmd("wincmd h")
      vim.cmd("startinsert")
    end, 300)
  end)
end, {})

-- Alt+u/i/y/o : split panes with fresh terminal (below/above/left/right)
vim.keymap.set('n', '<A-u>', ':belowright split | term<CR>',               { noremap = true }) -- split below
vim.keymap.set('n', '<A-i>', ':leftabove split | term<CR>',                 { noremap = true }) -- split above
vim.keymap.set('n', '<A-y>', ':leftabove vsplit | term<CR>',                { noremap = true }) -- split left
vim.keymap.set('n', '<A-o>', ':vsplit | wincmd l | term<CR>',               { noremap = true }) -- split right
vim.keymap.set('t', '<A-u>', '<C-\\><C-n>:belowright split | term<CR>',   { noremap = true })
vim.keymap.set('t', '<A-i>', '<C-\\><C-n>:leftabove split | term<CR>',     { noremap = true })
vim.keymap.set('t', '<A-y>', '<C-\\><C-n>:leftabove vsplit | term<CR>',    { noremap = true })
vim.keymap.set('t', '<A-o>', '<C-\\><C-n>:vsplit | wincmd l | term<CR>',   { noremap = true })
