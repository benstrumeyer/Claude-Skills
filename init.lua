-- Use PowerShell as the shell for :terminal
vim.opt.shell = "powershell"
vim.opt.shellcmdflag = "-NoLogo -ExecutionPolicy RemoteSigned -Command"
vim.opt.shellquote = ""
vim.opt.shellxquote = ""

-- Re-equalize splits on terminal resize (e.g. WT restored from minimized)
vim.api.nvim_create_autocmd("VimResized", {
  callback = function() vim.cmd("wincmd =") end
})


-- Multi-yank state (must be before Ctrl+V mappings)
local yank_collecting = false
local function yank_append(cmd)
  return function()
    if not yank_collecting then
      vim.fn.setreg('a', '')
      yank_collecting = true
    end
    vim.cmd('normal! ' .. cmd)
    vim.fn.setreg('+', vim.fn.getreg('a'))
  end
end
local function yank_reset()
  vim.fn.setreg('a', '')
  yank_collecting = false
end

-- Reset yank collection when leaving terminal mode (covers WT intercepting Ctrl+V)
-- Terminal → terminal-normal is 't:nt', not 't:n'
vim.api.nvim_create_autocmd('ModeChanged', {
  pattern = 't:nt',
  callback = yank_reset,
})

-- System clipboard integration
vim.opt.clipboard = 'unnamedplus'

-- Ctrl+C in visual mode: copy to system clipboard
vim.keymap.set('v', '<C-c>', '"+y', { noremap = true })

-- Ctrl+V in normal mode: paste from system clipboard
vim.keymap.set('n', '<C-v>', function()
  vim.cmd('normal! "+p')
  yank_reset()
end, { noremap = true })

-- Ctrl+V in insert mode: paste from system clipboard, reset yank collection
vim.keymap.set('i', '<C-v>', function()
  local keys = vim.api.nvim_replace_termcodes('<C-r>+', true, false, true)
  vim.api.nvim_feedkeys(keys, 'n', false)
  yank_reset()
end, { noremap = true })

-- Ctrl+V in terminal mode: bracketed paste (preserves syntax highlighting in claude)
vim.keymap.set('t', '<C-v>', function()
  local text = vim.fn.getreg('+')
  local chan = vim.b.terminal_job_id
  if chan and text ~= '' then
    vim.api.nvim_chan_send(chan, '\x1b[200~' .. text .. '\x1b[201~')
  end
  yank_reset()
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

-- Keep cursor away from screen edges when scrolling
vim.opt.scrolloff = 8

-- Large terminal scrollback for search
vim.opt.scrollback = 100000

-- Case-insensitive search
vim.opt.ignorecase = true
vim.opt.smartcase = true  -- case-sensitive if pattern has uppercase

-- Ctrl+\ : open new vertical terminal split to the right
vim.keymap.set('n', '<C-\\>', ':vsplit | wincmd l | term<CR>')
vim.keymap.set('t', '<C-\\>', '<C-\\><C-n>:vsplit | wincmd l | term<CR>')

-- Ctrl+f : search upward with ?
-- From terminal: exit to read mode, open ?
-- From normal: open ?
-- From command-line: cancel search, re-enter terminal insert
vim.keymap.set('t', '<C-f>', '<C-\\><C-n>?', { noremap = true })
vim.keymap.set('n', '<C-f>', '?', { noremap = true })
vim.keymap.set('c', '<C-f>', function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-c>', true, false, true), 'n', false)
  vim.schedule(function()
    if vim.bo.buftype == 'terminal' then
      vim.cmd('startinsert')
    end
  end)
end, { noremap = true })

-- Ctrl+Backspace in terminal: send Alt+Backspace for word delete
vim.keymap.set('t', '<C-BS>', function()
  local chan = vim.b.terminal_job_id
  if chan then vim.api.nvim_chan_send(chan, '\x1b\x7f') end
end)
-- Insert mode: delete word behind cursor
vim.keymap.set('i', '\x1b[127;5u', '<C-w>', { noremap = true })

-- Ctrl+n to open a new horizontal terminal split (within current column)
vim.keymap.set('n', '<C-n>', ':belowright split | term<CR>')
vim.keymap.set('t', '<C-n>', '<C-\\><C-n>:belowright split | term<CR>')

-- Alt+numpad/ : vertical split, new terminal on the right, stay on left
vim.keymap.set('n', '<A-kDivide>', ':vsplit | wincmd l | term<CR>')
vim.keymap.set('t', '<A-kDivide>', '<C-\\><C-n>:vsplit | wincmd l | term<CR>')

-- Alt+0 : reload config
vim.keymap.set('n', '<A-0>', ':source $MYVIMRC<CR>')
vim.keymap.set('t', '<A-0>', '<C-\\><C-n>:source $MYVIMRC<CR>')

-- Shift+J/K : jump 20 lines up/down (normal + visual), zz centers view
vim.keymap.set('n', 'J', '20jzz')
vim.keymap.set('n', 'K', '20kzz')
vim.keymap.set('v', 'J', '20j')
vim.keymap.set('v', 'K', '20k')

-- Multi-yank: y/yy collect lines, any paste resets for next collection
vim.keymap.set('v', 'y', yank_append('"Ay'), { noremap = true })
vim.keymap.set('n', 'yy', yank_append('"Ayy'), { noremap = true })
vim.keymap.set('n', 'p', function()
  vim.cmd('normal! "ap')
  yank_reset()
end, { noremap = true })

-- Swap [ ↔ { and ] ↔ } at input level (normal/visual/operator-pending only)
vim.opt.langmap = '\\[{,\\]},\\{[,\\}]'

-- [ and ] from terminal mode: exit to read mode and jump paragraph
vim.keymap.set('t', '[', '<C-\\><C-n>{', { noremap = true })
vim.keymap.set('t', ']', '<C-\\><C-n>}', { noremap = true })

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

-- Disable scrolloff in terminal buffers so mouse scroll isn't locked
vim.api.nvim_create_autocmd('TermOpen', {
  callback = function() vim.wo.scrolloff = 0 end,
})

-- Scroll-up in terminal exits insert mode so scrollback is browsable
-- Moves cursor up with viewport so it doesn't anchor to bottom
vim.keymap.set('t', '<ScrollWheelUp>', function()
  vim.cmd('stopinsert')
  local win = vim.api.nvim_get_current_win()
  local top = vim.fn.line('w0')
  local new_top = math.max(1, top - 3)
  vim.api.nvim_win_set_cursor(win, { new_top, 0 })
end, { noremap = true })

vim.keymap.set('n', '<ScrollWheelUp>', function()
  if vim.bo.buftype == 'terminal' then
    local win = vim.api.nvim_get_current_win()
    local cursor = vim.fn.line('.')
    local new_pos = math.max(1, cursor - 3)
    vim.api.nvim_win_set_cursor(win, { new_pos, 0 })
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<ScrollWheelUp>', true, false, true), 'n', true)
  end
end, { noremap = true })

-- Scroll-down near bottom re-enters insert mode
vim.keymap.set('n', '<ScrollWheelDown>', function()
  vim.cmd('normal! 3\5')
  if vim.bo.buftype == 'terminal' then
    local cur_line = vim.fn.line('w$')
    local last_line = vim.fn.line('$')
    if last_line - cur_line < 5 then
      vim.cmd('startinsert')
    end
  end
end, { noremap = true })


-- Click in terminal: switch to clicked window and enter insert mode
local function on_click()
  local pos = vim.fn.getmousepos()
  if pos.winid ~= 0 and pos.winid ~= vim.api.nvim_get_current_win() then
    vim.api.nvim_set_current_win(pos.winid)
  end
  if vim.bo.buftype == 'terminal' then
    vim.cmd('startinsert')
  end
end

vim.keymap.set('n', '<LeftMouse>', on_click, { noremap = true })
vim.keymap.set('n', '<2-LeftMouse>', on_click, { noremap = true })

-- Ctrl+Click / Alt+Click: add clicked line to multi-yank collection, move cursor there
local function yank_click()
  local pos = vim.fn.getmousepos()
  local buf = vim.api.nvim_win_get_buf(pos.winid)
  local line = vim.api.nvim_buf_get_lines(buf, pos.line - 1, pos.line, false)[1] or ''
  if not yank_collecting then
    vim.fn.setreg('a', '')
    yank_collecting = true
  end
  local cur = vim.fn.getreg('a')
  vim.fn.setreg('a', cur == '' and line or (cur .. '\n' .. line))
  vim.fn.setreg('+', vim.fn.getreg('a'))
  vim.api.nvim_win_set_cursor(pos.winid, { pos.line, 0 })
end
vim.keymap.set('n', '<A-LeftMouse>', yank_click, { noremap = true })
vim.keymap.set('n', '<A-LeftRelease>', '<Nop>', { noremap = true })
vim.keymap.set('n', '<C-LeftMouse>', yank_click, { noremap = true })
vim.keymap.set('n', '<C-LeftRelease>', '<Nop>', { noremap = true })

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

-- Alt+Minus : close current pane (smart: closes window, kills terminal, re-enters insert)
local function close_pane()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  -- Filter out floating windows
  local real_wins = vim.tbl_filter(function(w)
    return vim.api.nvim_win_get_config(w).relative == ''
  end, wins)
  if #real_wins <= 1 then return end
  local buf = vim.api.nvim_get_current_buf()
  vim.cmd('close')
  -- Kill the terminal buffer if it's no longer displayed
  if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == 'terminal' then
    local still_shown = false
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(w) == buf then still_shown = true; break end
    end
    if not still_shown then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
  vim.schedule(function()
    if vim.bo.buftype == 'terminal' then vim.cmd('startinsert') end
  end)
end
vim.keymap.set('n', '<A-->',  close_pane, { noremap = true })
vim.keymap.set('t', '<A-->', function()
  vim.cmd('stopinsert')
  close_pane()
end, { noremap = true })

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

-- PetlordzSession: Claude in petlordz
vim.api.nvim_create_user_command('PetlordzSession', function()
  local mcp = (vim.env.USERPROFILE or "C:/Users/ben") .. "/.claude/mcp-docs.json"
  local cmd = 'claude --dangerously-skip-permissions --mcp-config "' .. mcp .. '"'
  vim.cmd("cd C:/Users/ben/repos/petlordz")
  vim.cmd("terminal " .. cmd)
end, {})

-- Alt+u/i/y/o : split panes with fresh terminal (below/above/left/right)
vim.keymap.set('n', '<A-u>', ':belowright split | term<CR>',               { noremap = true }) -- split below
vim.keymap.set('n', '<A-i>', ':leftabove split | term<CR>',                 { noremap = true }) -- split above
vim.keymap.set('n', '<A-y>', ':leftabove vsplit | term<CR>',                { noremap = true }) -- split left
vim.keymap.set('n', '<A-o>', function()
  local mcp = (vim.env.USERPROFILE or "C:/Users/ben") .. "/.claude/mcp-docs.json"
  local cmd = 'claude --dangerously-skip-permissions --mcp-config "' .. mcp .. '"'
  vim.cmd('vsplit | wincmd l | terminal ' .. cmd)
end, { noremap = true }) -- split right with claude
vim.keymap.set('t', '<A-u>', '<C-\\><C-n>:belowright split | term<CR>',   { noremap = true })
vim.keymap.set('t', '<A-i>', '<C-\\><C-n>:leftabove split | term<CR>',     { noremap = true })
vim.keymap.set('t', '<A-y>', '<C-\\><C-n>:leftabove vsplit | term<CR>',    { noremap = true })
vim.keymap.set('t', '<A-o>', function()
  vim.cmd('stopinsert')
  local mcp = (vim.env.USERPROFILE or "C:/Users/ben") .. "/.claude/mcp-docs.json"
  local cmd = 'claude --dangerously-skip-permissions --mcp-config "' .. mcp .. '"'
  vim.cmd('vsplit | wincmd l | terminal ' .. cmd)
end, { noremap = true })

