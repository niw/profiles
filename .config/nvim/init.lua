local autocommands = {
  _group = vim.api.nvim_create_augroup('init', { clear = true }),

  create = function (self, event, options)
    if type(options) == 'function' then
      options = {
        callback = options
      }
    end
    local options_with_group = {
      pattern = '*',
      group = self._group
    }
    for k, v in pairs(options) do
      options_with_group[k] = v
    end
    vim.api.nvim_create_autocmd(event, options_with_group)
  end
}

-- {{{ Encodings

local function set_file_encodings()
  local fileencodings = {
    'ucs-bom'
  }

  local eucjp = 'euc-jp'
  local iso2022jp = 'iso-2022-jp'

  -- Check availability of JIS X 0213 on `iconv()`.
  -- Try converting the chars defined in EUC JIS X 0213 to CP932
  -- to make sure iconv supports JIS X 0213 or not.
  if vim.fn.iconv(string.char(0x87, 0x64, 0x87, 0x6a), 'cp932', 'euc-jisx0213') == string.char(0xad, 0xc5, 0xad, 0xcb) then
    eucjp = 'euc-jisx0213,euc-jp'
    iso2022jp = 'iso-2022-jp-3'
  end

  -- Check if `iconv()` can handle ISO-2022-JP properly with UTF-8.
  -- Some `iconv()` such as the one in macOS wrongly converts invalid ISO-2022-JP bytes to UTF-8.
  -- This may open UTF-8 files as ISO-2022-JP, because `readfile()` always try to convert file
  -- to UTF-8 and see if it success or not.
  -- See `src/nvim/fileio.c`.
  -- Thus, try convert ' 🐱', which heading a space may cause this issue, to see if it fails.
  -- If it converts to '?' that means it properly failed to convert UTF-8 bytes.
  if vim.fn.iconv(string.char(0x20, 0xf0, 0x9f, 0x90, 0xb1), 'iso-2022-jp', 'utf-8') == ' ??' then
    table.insert(fileencodings, iso2022jp)
  end

  -- There are the cases that we can't differentiate UTF-8 from EUC-JP or CP932.
  -- Assume that UTF-8 is common encoding now, it takes precedent than the others.
  table.insert(fileencodings, 'utf-8')
  table.insert(fileencodings, eucjp)
  table.insert(fileencodings, 'cp932')
  table.insert(fileencodings, 'default')

  vim.opt.fileencodings = fileencodings
end

set_file_encodings()

-- }}}

-- {{{ Global Options

local function reset_option(option)
  -- See `runtime/lua/vim/_options.lua`.
  -- It's a bit difficult to extend each `Option`.
  option = option._info.default
end

local function enable_option_flags(option, ...)
  local value = {}
  for _, flag in pairs({ ... }) do
    value[flag] = true
  end
  option:append(value)
end

local function disable_option_flags(option, ...)
  local value = {}
  for _, flag in pairs({ ... }) do
    value[flag] = false
  end
  option:append(value)
end

-- Search configuration

-- Ignore the case of normal letters
vim.o.ignorecase = true
-- If the search pattern contains upper case characters, override the 'ignorecase' option.
vim.o.smartcase = true

-- Tab and spaces

-- Number of spaces that a <Tab> in the file counts for.
vim.o.tabstop = 2
-- Number of spaces to use for each step of indent.
vim.o.shiftwidth = 2
-- Expand tab to spaces.
vim.o.expandtab = true
-- Smart autoindent.
vim.o.smartindent = true
-- Round indent to multiple of 'shiftwidth'.
vim.o.shiftround = true

-- Cursor and Backspace

-- Allow h, l, <Left> and <Right> to move to the previous/next line.
reset_option(vim.opt.whichwrap)
enable_option_flags(vim.opt.whichwrap, '<', '>', '[', ']', 'h', 'l')
-- Disable mouse if it is not 'gui'.
if vim.fn.has('gui') == 0 then
  vim.o.mouse = ''
end

-- Displays

-- When a bracket is inserted, briefly jump to the matching one.
vim.o.showmatch = true
-- Show line number.
vim.o.number = true
-- Show the line and column number of the cursor position.
vim.o.ruler = true
-- Set title of the window to the value of 'titlesrting'.
vim.o.title = true
-- Number of screen lines to use for the command-line.
vim.o.cmdheight = 2
-- Default height for a preview window.
vim.o.previewheight = 40
-- Highlight a pair of < and >.
reset_option(vim.opt.matchpairs)
vim.opt.matchpairs:append({ '<:>' })
-- Disable to translate menu.
vim.o.langmenu = 'none'
-- Enable 24-bit colors if `COLORTERM` is `truecolor`.
if vim.env.COLORTERM == 'truecolor' then
  vim.o.termguicolors = true
end

-- Status line

vim.o.statusline = (
  ''
  .. '%3n '     -- Buffer number
  .. '%<%f '    -- Filename
  .. '%m%r%h%w' -- Modified flag, Readonly flag, Preview flag
  .. '[%{&fileencoding != "" ? &fileencoding : &encoding}][%{&fileformat}][%{&filetype}]'
  .. '%='       -- Spaces
  .. '%l,%c%V'  -- Line number, Column number, Virtual column number
  .. '%4P'      -- Percentage through file of displayed window.
)

-- Completion

-- Command-line completion behavior.
-- See `:help wildmode`.
vim.opt.wildmode = { 'longest', 'list', 'full' }
-- Completion behavior.
-- See `:help completeopt`
vim.opt.completeopt = { 'menuone', 'noinsert' }
-- Extend popup menu width.
vim.o.pumwidth = 20

-- Use multibyte aware format.
-- See `:help fo-table`.
reset_option(vim.opt.formatoptions)
enable_option_flags(vim.opt.formatoptions, 'm', 'M')

-- Disable swap file.
vim.o.swapfile = false

-- }}}

-- {{{ Behaviors

-- Restore cursor position
-- See `:help last-position-jump`.
autocommands:create('BufReadPost', function ()
  -- Don't do it when the position is invalid or when inside an event handler
  -- (happens when dropping a file on gvim).
  -- Also don't do it when the mark is in the first line, that is the default
  -- position when opening a file.
  if vim.fn.line('\'"') > 1 and vim.fn.line('\'"') <= vim.fn.line('$') then
    vim.cmd('normal! g`"')
  end
end)

-- Highlight Trailing Whitespaces
autocommands:create({ 'VimEnter', 'ColorScheme' }, function ()
  vim.api.nvim_set_hl(0, 'TrailingWhitespace', {
    ctermbg = 'red'
  })
end)
autocommands:create('InsertLeave', function ()
  if vim.bo.buftype == '' then
    -- The ID is bound to the window.
    vim.w.trailing_whitespace_match_id = vim.fn.matchadd('TrailingWhitespace', '\\v\\s+$')
  end
end)
autocommands:create('InsertEnter', function ()
  if vim.w.trailing_whitespace_match_id then
    vim.fn.matchdelete(vim.w.trailing_whitespace_match_id)
    vim.w.trailing_whitespace_match_id = nil
  end
end)

-- Check file when switch the window.
autocommands:create('WinEnter', function ()
  vim.cmd.checktime()
end)

-- TODO: Looks like this is not working. file type plugin may take a precedence.
-- Disable automatically insert comment by default.
-- These options are set locally by filetypes, thus remove them for each filetype.
-- See `:help fo-table`.
autocommands:create('FileType', function ()
  disable_option_flags(vim.opt_local.formatoptions, 'r', 'o')
end)

-- }}}

-- {{{ Key Mappings

-- Leaders

-- Define <Leader>, <LocalLeader>
vim.g.mapleader = ','
vim.g.maplocalleader = '.'

-- Disable <Leader>, <LocalLeader> to avoid unexpected behavior.
vim.keymap.set('', '<Leader>', '<Nop>')
vim.keymap.set('', '<LocalLeader>', '<Nop>')

-- Prefixes

-- Reserve <Space>, s, t, T, q, K.
-- TODO: Consider to simplify this and repalce it with Leader.

local function keymap_prefix(mode, key)
  -- Strip '<...>' from key if it exists.
  local name = string.match(key, '<(.+)>') or key
  vim.keymap.set(mode, key, '<Nop>')
  vim.keymap.set(mode, key, '[' .. name .. ']', { remap = true })
end

keymap_prefix('', '<Space>')
keymap_prefix('', 's')

-- Allow t and T in visual, operator-pending mode to give a motion.
keymap_prefix('n', 't')
keymap_prefix('n', 'T')

-- q is reserved for prefix key, assign Q for the original action.
-- Q is for Ex-mode which we don't need to use.
keymap_prefix('', 'q')
vim.keymap.set('', 'Q', 'q')

-- K is reserved for prefix to avoid run K mistakenly with C-k,
-- assign qK for the original action.
keymap_prefix('', 'K')
vim.keymap.set('', 'qk', 'k')

-- Buffer

vim.keymap.set('n', '[Space]', '[Buffer]', { remap = true })

local function next_normal_file_buffer(backward)
  local delta = 1
  if backward then
    delta = -1
  end

  local current_buffer_handle = vim.api.nvim_get_current_buf()
  local buffer_handles = vim.api.nvim_list_bufs()

  local current_buffer_index = 0
  for index, handle in pairs(buffer_handles) do
    if handle == current_buffer_handle then
      current_buffer_index = index
    end
  end
  if current_buffer_index == 0 then
    return 0
  end

  local buffer_index = current_buffer_index
  while true do
    buffer_index = buffer_index + delta
    -- Lua's array table index starts with 1.
    if buffer_index > #buffer_handles then
      buffer_index = 1
    elseif buffer_index < 1 then
      buffer_index = #buffer_handles
    end
    if buffer_index == current_buffer_index then
      return 0
    end

    local handle = buffer_handles[buffer_index]
    if vim.api.nvim_buf_is_valid(handle) and
        vim.api.nvim_buf_get_option(handle, 'buftype') == '' and
        vim.fn.isdirectory(vim.api.nvim_buf_get_name(handle)) == 0 then
      return handle
    end
  end
end

vim.keymap.set('n', '[Buffer]n', function ()
  if vim.bo.buftype == '' then
    local buffer = next_normal_file_buffer()
    vim.api.nvim_win_set_buf(0, buffer)
  end
end)

vim.keymap.set('n', '[Buffer]p', function ()
  if vim.bo.buftype == '' then
    local buffer = next_normal_file_buffer(true)
    vim.api.nvim_win_set_buf(0, buffer)
  end
end)

-- Window

vim.keymap.set('n', '[s]', '[Window]', { remap = true })

vim.keymap.set('n', '[Window]j', '<C-w>j')
vim.keymap.set('n', '[Window]k', '<C-w>k')
vim.keymap.set('n', '[Window]h', '<C-w>h')
vim.keymap.set('n', '[Window]l', '<C-w>l')

vim.keymap.set('n', '[Window]J', '<C-w>J')
vim.keymap.set('n', '[Window]K', '<C-w>K')
vim.keymap.set('n', '[Window]H', '<C-w>H')
vim.keymap.set('n', '[Window]L', '<C-w>L')

vim.keymap.set('n', '[Window]v', '<C-w>v')

-- Centering cursor after splitting window
vim.keymap.set('n', '[Window]s', '<C-w>szz')

vim.keymap.set('n', '[Window]q', ':<C-u>quit<CR>')
vim.keymap.set('n', '[Window]d', ':<C-u>Bdelete<CR>')

vim.keymap.set('n', '[Window]=', '<C-w>=')
vim.keymap.set('n', '[Window],', '<C-w><')
vim.keymap.set('n', '[Window].', '<C-w>>')
vim.keymap.set('n', '[Window]]', '<C-w>+')
vim.keymap.set('n', '[Window][', '<C-w>-')

-- Tab

vim.keymap.set('n', '[t]', '[Tab]', { remap = true })

vim.keymap.set('n', '[Tab]c', function ()
  vim.cmd.tabnew()
end)
vim.keymap.set('n', '[Tab]q', function ()
  vim.cmd.tabclose()
end)
vim.keymap.set('n', '[Tab]p', function ()
  vim.cmd.tabprev()
end)
vim.keymap.set('n', '[Tab]n', function ()
  vim.cmd.tabnext()
end)
for count = 1, 9 do
  vim.keymap.set('n', '[Tab]' .. count, function ()
    vim.cmd('tabnext ' .. count)
  end)
end

-- Highlight

-- Reset syntax highlight
vim.keymap.set('n', '[Space]r', function ()
  vim.cmd('syntax sync clear')
end)

-- Disable search highlight
vim.keymap.set('n', '[Space]N', function ()
  vim.cmd.nohlsearch()
end)

local function highlight_search_keyword(keyword)
  if keyword == nil or keyword == '' then
    vim.cmd.nohlsearch()
    return
  end
  -- After `\V`, all magic characters must be escaped by `\`.
  -- if it escapes all `\` by `escape()`, no magic characters can work.
  -- See `:help /magic`.
  local pattern = '\\V' .. vim.fn.escape(keyword, '\\')
  vim.fn.setreg('/', pattern)
  -- This call has expected side effect to set `vim.v.hlsearch` to `true`.
  -- See `:help hlsearch`, `:help v:hlsearch`, and `:help function-search-undo`.
  vim.o.hlsearch = true
end

-- Search the word under the cursor
vim.keymap.set('n', '[Space]<Space>', function ()
  local word = vim.fn.expand('<cword>')
  highlight_search_keyword(word)
end)

-- Search by visual region
vim.keymap.set('v', '[Space]<Space>', function ()
  local reg = vim.fn.getreginfo('a')
  local pos = vim.fn.getpos('.')
  local word
  -- Ignore errors
  pcall(function ()
    -- Somehow, `gv` is not needed before `"ay` to yank visual region to a register.
    vim.cmd('normal! "ay')
    word = vim.fn.getreg('a')
  end)
  vim.fn.setreg('a', reg)
  vim.fn.setpos('.', pos)
  highlight_search_keyword(word)
end)

-- Completion

-- Not inserting candidate when <C-n> and <C-p>.
vim.keymap.set('i', '<C-n>', function ()
  if vim.fn.pumvisible() == 1 then
    return '<Down>'
  else
    return '<C-n>'
  end
end, { expr = true })
vim.keymap.set('i', '<C-p>', function ()
  if vim.fn.pumvisible() == 1 then
    return '<Up>'
  else
    return '<C-n>'
  end
end, { expr = true })

-- Trigger omni completion with <Tab> if there is a character
-- in front of current cursor position.
vim.keymap.set('i', '<Tab>', function ()
  -- This `cols` is in byte offset.
  local rows, cols = unpack(vim.api.nvim_win_get_cursor(0))
  if cols > 0 then
    local line = vim.api.nvim_buf_get_lines(0, rows - 1, rows, false)[1]
    -- This will not return a single Unicode code point but a byte.
    -- however, it's enough for this use case.
    local char = string.sub(line, cols, cols)
    -- Check if it's an alphanumetic character or '.'.
    if (string.match(char, '[%w.]')) then
      return '<C-x><C-o>'
    end
  end
  return '<Tab>'
end, { expr = true })

-- Command-line Window

vim.keymap.set('n', ';', 'q:i')
vim.keymap.set('n', ':', 'q:i')

autocommands:create('CmdwinEnter', function ()
  vim.keymap.set('n', '<ESC><ESC>', function ()
    vim.cmd.quit()
  end, { buffer = true })
  vim.keymap.set('n', ':', '<Nop>', { buffer = true })
  vim.keymap.set('n', ';', '<Nop>', { buffer = true })
end)

-- Miscellaneous

-- Move cursor by display line
vim.keymap.set('', 'j', 'gj')
vim.keymap.set('', 'k', 'gk')
vim.keymap.set('', 'gj', 'j')
vim.keymap.set('', 'gk', 'k')

-- Centering search result and open fold.
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')
vim.keymap.set('n', '*', '*zzzv')
vim.keymap.set('n', '#', '#zzzv')
vim.keymap.set('n', 'g*', 'g*zzzv')
vim.keymap.set('n', 'g#', '#zzzv')

-- Select the last modified texts.
vim.keymap.set('n', 'gm', '`[v`]', { silent = true })

-- Lookup help
vim.keymap.set('n', '[Space]h', ':<C-u>help <C-r><C-w><CR>', { silent = true })

-- Toggle text wrap
vim.keymap.set('n', '[Space]w', function ()
  vim.wo.wrap = not vim.wo.wrap
end)

-- }}}

-- {{{ Commands

-- Reopen buffer as each encoding
for command, encoding in pairs({
  Utf8 = 'utf-8',
  Cp932 = 'cp932',
  Eucjp = 'euc-jp',
  Iso2022jp = 'ios-2022-jp',
  Utf16 = 'ucs-2le',
  Utf16be = 'ucs-2'
}) do
  vim.api.nvim_create_user_command(command, function (arg)
    vim.cmd('edit! ++enc=' .. encoding .. ' ' .. arg.args)
  end, { bang = true, bar = true, complete = 'file', nargs = '?' })
end

-- Change current directory to the one of current file.
vim.api.nvim_create_user_command('Cd', function ()
  local path = vim.api.nvim_buf_get_name(0)
  if vim.fn.isdirectory(path) == 0 then
    path = vim.fs.dirname(path)
  end
  vim.api.nvim_set_current_dir(path)
end, { bar = true })

-- }}}

-- {{{ Plugins

local plugins = require('plugins')

plugins.setup({
  {
    'nanotech/jellybeans.vim',
    config = function ()
      vim.cmd.colorscheme('jellybeans')
    end
  },

  'tpope/vim-surround',
})

plugins.sync()

-- }}}

-- vim: tabstop=2 shiftwidth=2 textwidth=0 expandtab foldmethod=marker nowrap
