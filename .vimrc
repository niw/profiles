" There are vim doesn't have eval feature like `vim-tiny` on Debian.
" NOTE: this must be in a single line. See `:help no-eval-feature`.
if !1 | finish | endif

" Most of this `.vimrc` may work even on Vim 6 or prior,
" We disable everything to avoid unexpected behaviors.
if v:version < 700
  finish
endif

if !exists('s:loaded_vimrc')
  " Don't reset twice on reloading, changing `compatible` has many side effects.
  set nocompatible
endif

" Reset all `autocmd` defined in this file.
augroup MyAutoCommands
  autocmd!
augroup END

" Source site local configuration.
" Mostly for set dynamic link library paths.
" TODO: Find a better solution.
if filereadable($HOME . '/.vimrc.local')
  execute 'source ' . $HOME . '/.vimrc.local'
endif

"{{{ Encodings and Input Method

" Internal encoding. Always using UTF-8.
set encoding=utf-8

" Terminal encoding for Japanese.
"{{{
function! s:SetTermEncoding() abort
  if has('gui')
    return
  endif

  set termencoding&
  " If LANG shows EUC or Shift-JIS, use it for termencoding.
  if $LANG =~# 'eucJP'
    set termencoding=euc-jp
  elseif $LANG =~# 'SJIS'
    set termencoding=cp932
  endif
endfunction

call s:SetTermEncoding()
"}}}

" File encoding for Japanese.
"{{{
function! s:SetFileEncodings() abort
  if !has('iconv')
    return
  endif

  let enc_eucjp = 'euc-jp'
  let enc_iso2022jp = 'iso-2022-jp'

  " Check availability of iconv library.
  " Try converting the chars defined in EUC JIS X 0213 to CP932
  " to make sure iconv supports JIS X 0213 or not.
  if iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let enc_eucjp = 'euc-jisx0213,euc-jp'
    let enc_iso2022jp = 'iso-2022-jp-3'
  endif

  let value = 'ucs-bom'
  let value = value . ',' . enc_iso2022jp
  " There are the cases that we can't differentiate UTF-8 from EUC or Shift-JIS.
  " Assume that UTF-8 is common encoding now, it takes precedent than the others.
  let value = value . ',' . 'utf-8'
  let value = value . ',' . enc_eucjp . ',' . 'cp932'

  let &fileencodings = value
endfunction

function! s:SetFileEncoding() abort
  " Make sure the file is not including any Japanese in ISO-2022-JP, use UTF-8 for fileencoding.
  if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
    let &fileencoding = 'utf-8'
  endif
endfunction

call s:SetFileEncodings()
autocmd MyAutoCommands BufReadPost * call <SID>SetFileEncoding()
"}}}

" Multibyte format. See `:help fo-table`
set formatexpr&
set formatoptions&
set formatoptions+=mM

" File format. Use is Unix as default always.
set fileformat=unix
set fileformats=unix,dos,mac

"}}}

"{{{ Global Settings

" Search

" Ignore the case of normal letters
set ignorecase
" If the search pattern contains upper case characters, override the 'ignorecase' option.
set smartcase
" Use incremental search.
set incsearch
" Do not highlight search result.
set hlsearch
nohlsearch
" Searches wrap around the end of the file.
set wrapscan

" Tab and spaces

" Number of spaces that a <Tab> in the file counts for.
set tabstop=2
" Number of spaces to use for each step of indent.
set shiftwidth=2
" Expand tab to spaces.
set expandtab
" Smart autoindent.
set autoindent
set smartindent
" Round indent to multiple of 'shiftwidth'.
set shiftround
" Enable modeline.
set modeline
" Disable auto wrap.
autocmd MyAutoCommands FileType * setlocal textwidth=0

" Cursor and Backspace

" Allow backspacing over autoindent, line brakes and the start of insert.
set backspace=indent,eol,start
" Allow h, l, <Left> and <Right> to move to the previous/next line.
set whichwrap&
set whichwrap+=<,>,[,],h,l
" Use mouse in all modes.
"set mouse=a

" Displays

" When a bracket is inserted, briefly jump to the matching one.
set showmatch
" Command-line completion operates in an enhanced mode.
set wildmenu
" Show line number.
set number
" Show the line and column number of the cursor position.
set ruler
" Lines longer than the width of the window will wrap.
set wrap
" Show status line always.
set laststatus=2
" Show command in the last line of the screen.
set showcmd
" Set title of the window to the value of 'titlesrting'.
set title
" If in Insert, Replace or Visual mode put a message on the last line.
set showmode
" Number of screen lines to use for the command-line.
set cmdheight=2
" Default height for a preview window.
set previewheight=40
" Highlight a pair of < and >.
set matchpairs&
set matchpairs+=<:>
" Use dark background by default.
set background=dark
" Use `highlight-guifg` and `highlight-guibg` attributes in the terminal. Using 24-bit color.
"set termguicolors
" Disable to translate menu.
set langmenu=none

" Status line

let &statusline = ''
let &statusline .= '%3n '     " Buffer number
let &statusline .= '%<%f '    " Filename
let &statusline .= '%m%r%h%w' " Modified flag, Readonly flag, Preview flag
let &statusline .= '%{"[" . (&fileencoding != "" ? &fileencoding : &encoding) . "][" . &fileformat . "][" . &filetype . "]"}'
let &statusline .= '%='       " Spaces
let &statusline .= '%l,%c%V'  " Line number, Column number, Virtual column number
let &statusline .= '%4P'      " Percentage through file of displayed window.

" Completion

" Complete longest common string, list all matches and complete the next full match.
set wildmode=longest,list,full
" Use the pop up menu even if it has only one match.
set completeopt=menuone

" Disable backup and undo files.
" These are default to `off` but some implementation may set these to `on`.
set nobackup
set noundofile
set noswapfile

" Hide buffer when it is abandoned.
set hidden

" Expand a history of ':' commands to 100.
set history=100

" Indicates a fast terminal connection.
set ttyfast

" Indicate tab, wrap, trailing spaces and eol or not.
set listchars=tab:»\ ,extends:»,precedes:«,trail:\

" Highlight Trailing Whitespaces
"{{{
function! s:HighlightTrailingWhitespaces() abort
  if getbufvar(bufnr('%'), '&buftype') == ""
    let w:trailing_whitespaces_match = matchadd('TrailingWhitespaces', '\v\s+$')
  endif
endfunction

function! s:ClearTrailingWhitespacesHighlights() abort
  if exists('w:trailing_whitespaces_match')
    call matchdelete(w:trailing_whitespaces_match)
    unlet w:trailing_whitespaces_match
  endif
endfunction

augroup MyAutoCommands
  autocmd VimEnter,ColorScheme * highlight TrailingWhitespaces ctermbg=red guibg=red
  autocmd InsertEnter * call <SID>ClearTrailingWhitespacesHighlights()
  autocmd InsertLeave * call <SID>HighlightTrailingWhitespaces()
augroup END
"}}}

" Restore cursor position
"{{{
function! s:RestoreCursorPosition() abort
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  if line("'\"") > 1 && line("'\"") <= line("$")
    execute "normal! g`\""
  endif
endfunction

autocmd MyAutoCommands BufReadPost * call <SID>RestoreCursorPosition()
"}}}

" Auto reload, check file when switch the window.
set autoread
autocmd MyAutoCommands WinEnter * checktime

" Support for the file system which ignore case
if filereadable($VIM . '/vimrc') && filereadable($VIM . '/ViMrC')
  " Default `tags` may have `./tags` and `./TAGS`.
  set tags=./tags,tags
endif

"}}}

"{{{ Syntax and File Types

" Enable syntax color.
syntax enable
filetype plugin on

" Enable indent.
filetype indent on

augroup MyAutoCommands
  " Disable automatically insert comment.
  " See `:help fo-table`.
  autocmd FileType * setlocal formatoptions-=ro | setlocal formatoptions+=mM

  " Use spell check always for `conf`.
  autocmd MyAutoCommands FileType conf setlocal spell

  " Editing binary file.
  " See :help hex-editing, Do not merge these two lines into one.
  autocmd BufReadPre   *.bin let &bin=1
  autocmd BufReadPost  *.bin if &bin | silent %!xxd -g 1
  autocmd BufReadPost  *.bin   setlocal filetype=xxd | endif
  autocmd BufWritePre  *.bin if &bin | %!xxd -r
  autocmd BufWritePre  *.bin   endif
  autocmd BufWritePost *.bin if &bin | silent %!xxd -g 1
  autocmd BufWritePost *.bin   setlocal nomod | endif
augroup END

"}}}

"{{{ Key Mappings

" Leaders
"{{{
" Define <Leader>, <LocalLeader>
let mapleader = ','
let maplocalleader = '.'

" Disable <Leader>, <LocalLeader> to avoid unexpected behavior.
noremap <Leader> <Nop>
noremap <LocalLeader> <Nop>
"}}}

" Reserved Prefixes
" {{{
" Reserve <Space>, s, t, T, q, K.
" See additional comments for q and K.
" Allow t and T in visual, operator-pending mode to give a motion.
noremap <Space> <Nop>
noremap s <Nop>
nnoremap t <Nop>
nnoremap T <Nop>
noremap q <Nop>
noremap K <Nop>
map <Space> [Space]
map s [s]
nmap t [t]
nmap T [T]
map q [q]
map K [K]

" q is reserved for prefix key, assign Q for the original action.
" Q is for Ex-mode which we don't need to use.
nnoremap Q q

" K is reserved for prefix to avoid run K mistakenly with C-k,
" assign qK for the original action.
nnoremap qK K
" }}}

function! s:NextNormalFileBuffer(...) abort "{{{
  let direction = get(a:000, 0, 1)
  if direction > 0
    let delta = 1
  elseif direction < 0
    let delta = -1
  else
    return 0
  end

  let buffer_num = bufnr('%')
  let last_buffer_num = bufnr('$')

  let next_buffer_num = buffer_num
  while 1
    let next_buffer_num = next_buffer_num + delta
    if next_buffer_num > last_buffer_num
      let next_buffer_num = 1
    elseif next_buffer_num < 1
      let next_buffer_num = last_buffer_num
    end

    if next_buffer_num == buffer_num
      break
    end

    " Only if the buffer is listed, normal, and its file name is not directory.
    let path = expand('#' . next_buffer_num . ':p')
    if buflisted(next_buffer_num) && getbufvar(next_buffer_num, '&buftype') == "" && !isdirectory(path)
      return next_buffer_num
      break
    endif
  endwhile

  return 0
endfunction "}}}

" Buffer manipulations
nmap [Space] [Buffer]
"{{{
function! s:OpenPrevNormalBuffer() abort
  if &buftype == ""
    let buffer_num = s:NextNormalFileBuffer(-1)
    if buffer_num
      execute "buffer" buffer_num
    endif
  endif
endfunction

function! s:OpenNextNormalBuffer() abort
  if &buftype == ""
    let buffer_num = s:NextNormalFileBuffer(1)
    if buffer_num
      execute "buffer" buffer_num
    endif
  endif
endfunction

noremap <silent> [Buffer]p :<C-u>call <SID>OpenPrevNormalBuffer()<CR>
noremap <silent> [Buffer]n :<C-u>call <SID>OpenNextNormalBuffer()<CR>
"}}}

" Window manipulations
nmap [s] [Window]
"{{{
nnoremap [Window]j <C-W>j
nnoremap [Window]k <C-W>k
nnoremap [Window]h <C-W>h
nnoremap [Window]l <C-W>l

nnoremap [Window]J <C-W>J
nnoremap [Window]K <C-W>K
nnoremap [Window]H <C-W>H
nnoremap [Window]L <C-W>L

nnoremap [Window]v <C-w>v
" Centering cursor after splitting window
nnoremap [Window]s <C-w>szz

nnoremap [Window]q :<C-u>quit<CR>
nnoremap [Window]d :<C-u>Bdelete<CR>

nnoremap [Window]= <C-w>=
nnoremap [Window], <C-w><
nnoremap [Window]. <C-w>>
nnoremap [Window]] <C-w>+
nnoremap [Window][ <C-w>-
"}}}

" Tab manipulations
nmap [t] [Tab]
"{{{
function! s:MapTabNextWithCount() abort
  let tab_count = 1
  while tab_count < 10
    execute printf("noremap <silent> [Tab]%s :tabnext %s<CR>", tab_count, tab_count)
    let tab_count = tab_count + 1
  endwhile
endfunction

nnoremap <silent> [Tab]c :<C-u>tabnew<CR>
nnoremap <silent> [Tab]q :<C-u>tabclose<CR>
nnoremap <silent> [Tab]n :<C-u>tabnext<CR>
nnoremap <silent> [Tab]p :<C-u>tabprev<CR>

call s:MapTabNextWithCount()
"}}}

function! s:SetSearchKeyword(keyword) abort "{{{
  if a:keyword == ""
    nohlsearch
    return
  endif
  " After \V, all magic characters must be escaped by \.
  " We escape all \ by escape(), then no magic characters can work.
  " See :help /magic
  let pattern = '\V' . escape(a:keyword, '\')
  let @/ = pattern
  " NOTE: Somehow, just using `silent set hlsearch` is not working without any prior search action.
  " It's hacky though, feedkeys() works without search action.
  call feedkeys(":silent set hlsearch\<CR>", "n")
endfunction "}}}

function! s:GetSelectedText() abort "{{{
  let reg = @a
  let regtype = getregtype('a')
  let pos = getpos('.')

  try
    silent normal! gv"ay
    return @a
  finally
    call setreg('a', reg, regtype)
    call setpos('.', pos)
  endtry
endfunction "}}}

" Reset syntax highlight
nnoremap <silent> [Space]r :<C-u>syntax sync clear<CR>

" Disable search highlight
nnoremap <silent> [Space]N :nohlsearch<CR>

" Highlight the word under the cursor
nnoremap <silent> [Space]<Space> :<C-u>call <SID>SetSearchKeyword(expand('<cword>'))<CR>

" Search by visual region
vnoremap <silent> [Space]<Space> :<C-u>call <SID>SetSearchKeyword(<SID>GetSelectedText())<CR>

" Move cursor by display line
noremap j gj
noremap k gk
noremap gj j
noremap gk k

" Centering search result and open fold.
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap * *zzzv
nnoremap # #zzzv
nnoremap g* g*zzzv
nnoremap g# g#zzzv

" Use command line window.
"{{{
" NOTE: Command line window doesn't work due to Vim bug since 8.0.152 prior to 8.0.172
" See https://github.com/vim/vim/commit/1d669c233c97486555a34f7d3f069068d9ebdb63
if !has("patch-8.0.152") || has("patch-8.0.172")
  nnoremap ; q:i
  nnoremap : q:i
endif

augroup MyAutoCommands
  autocmd CmdwinEnter * nnoremap <buffer> <ESC><ESC> :<C-u>quit<CR>
  autocmd CmdwinEnter * nnoremap <buffer> : <Nop>
  autocmd CmdwinEnter * nnoremap <buffer> ; <Nop>
augroup END
"}}}

" Select the last modified texts
nnoremap <silent> gm `[v`]
vnoremap <silent> gm :<C-u>normal gc<CR>
onoremap <silent> gm :<C-u>normal gc<CR>

" Grep
nnoremap <silent> gr :<C-u>call <SID>Grep(expand('<cword>'))<CR>
xnoremap <silent> gr :<C-u>call <SID>Grep(<SID>GetSelectedText())<CR>

" Make
noremap <silent> [Space], :<C-u>make<CR>

" Quick edit and reload .vimrc
map [Space]. [Vimrc]
nnoremap <silent> [Vimrc]e :<C-u>edit $MYVIMRC<CR>
nnoremap <silent> [Vimrc]s :<C-u>source $MYVIMRC<CR>

" Lookup help
nnoremap <silent> [Space]h :<C-u>help <C-r><C-w><CR>

" Wrap
nnoremap <silent> [Space]w :<C-u>setlocal wrap!<CR>

function! s:OpenQuickFixWithSyntex(syntax) abort "{{{
  let g:last_quick_fix_syntax = a:syntax
  copen
  " NOTE: quickfix window is using syntax match for highlight the selected file.
  " matchadd() always overrules syntax highlight, it results unexpected highlighting.
  " To avoid this, using syntax match to highlight the keyword here.
  " See help :matchadd
  execute "syntax match Underlined '\\v" . a:syntax . "' display containedin=ALL"
  wincmd J
endfunction "}}}

function! s:OpenQuickFix() abort "{{{
  if exists('g:last_quick_fix_syntax')
    call s:OpenQuickFixWithSyntex(g:last_quick_fix_syntax)
  else
    copen
  endif
endfunction "}}}

" QuickFix
nnoremap <silent> qq :call <SID>OpenQuickFix()<CR>
nnoremap <silent> qw :<C-u>cclose<CR>

" Spell check
"{{{
function! s:SpellCheckCompletion() abort
  if &spell
    call feedkeys("ea\<C-x>s", "n")
  endif
endfunction

" Toggle spell check
nnoremap <silent> gs :<C-u>setlocal spell!<CR>
" Show spell check candidates
nnoremap <silent> [Space]s :<C-u>call <SID>SpellCheckCompletion()<CR>
"}}}

"}}}

"{{{ Commands

" Reopen buffer as each encoding
command! -bang -bar -complete=file -nargs=? Utf8      edit<bang> ++enc=utf-8 <args>
command! -bang -bar -complete=file -nargs=? Cp932     edit<bang> ++enc=cp932 <args>
command! -bang -bar -complete=file -nargs=? Euc       edit<bang> ++enc=euc-jp <args>
command! -bang -bar -complete=file -nargs=? Iso2022jp edit<bang> ++enc=iso-2022-jp <args>
command! -bang -bar -complete=file -nargs=? Utf16     edit<bang> ++enc=ucs-2le <args>
command! -bang -bar -complete=file -nargs=? Utf16be   edit<bang> ++enc=ucs-2 <args>

" Recursive Grep and Highlight
"{{{
function! s:FlattenList(list) abort "{{{
  let flatten = []
  let i = 0
  while i < len(a:list)
    if type(a:list[i]) == type([])
      call extend(flatten, s:FlattenList(a:list[i]))
    else
      call add(flatten, a:list[i])
    endif
    let i = i + 1
  endwhile
  return flatten
endfunction "}}}

function! s:Grep(keyword, ...) abort "{{{
  if a:keyword == ""
    return
  endif

  let args = ['grep!', shellescape(a:keyword)]
  for arg in s:FlattenList(a:000)
    call add(args, shellescape(arg, 1))
  endfor

  execute join(args, ' ')

  call s:OpenQuickFixWithSyntex(a:keyword)
endfunction "}}}

function! s:HasCommand(cmd) abort "{{{
  execute system('type ' . a:cmd . ' >/dev/null 2>&1')
  return !v:shell_error
endfunction "}}}

function! s:GrepPrg() abort "{{{
  if exists('g:grepprg')
    return g:grepprg
  else
    let g:grepprg = &grepprg
  endif

  if s:HasCommand('ag')
    let g:grepprg = 'ag'
  elseif s:HasCommand('ack')
    let g:grepprg = 'ack'
  elseif s:HasCommand('grep')
    let opts = "-r -E -n --exclude='*.svn*' --exclude='*.log*' --exclude='*tmp*'"
    if system('grep --help') =~# '--exclude-dir'
      let opts .= " --exclude-dir='CVS' --exclude-dir='.svn' --exclude-dir='.git'"
    endif
    let g:grepprg = 'grep ' . opts . ' . -e '
  endif

  return g:grepprg
endfunction "}}}

" Remember default grepprg.
let &grepprg = <SID>GrepPrg()

command! -nargs=+ Grep call <SID>Grep(<f-args>)
"}}}

" Change file name editing
command! -nargs=1 -complete=file Rename file <args>|call delete(expand('#'))

" Preserve window splits when deleting the buffer
"{{{
function! s:DeleteBuffer(bang) abort
  if &mod && a:bang != '!'
    return
  endif

  let buffer_num = bufnr('%')
  let win_num = winnr()

  let next_buffer_num = s:NextNormalFileBuffer()
  if ! next_buffer_num
    enew
    let next_buffer_num = bufnr('%')
    if next_buffer_num == buffer_num
      return
    end
  endif

  " FIXME: We have to check the other tabs because bufwinnr doesn't care them
  while 1
    let n = bufwinnr(buffer_num)
    if n < 0
      break
    endif
    execute n "wincmd w"
    execute "buffer" next_buffer_num
  endwhile

  execute win_num "wincmd w"
  execute "silent bdelete" . a:bang buffer_num
endfunction

command! -bang Bdelete call <SID>DeleteBuffer("<bang>")
"}}}

" Change current directory to the one of current file.
command! -bar Cd cd %:p:h

" TabpageCD (Modified.)
" See https://gist.github.com/604543/
"{{{
function! s:StoreTabpageCD() abort
  let t:cwd = getcwd()
endfunction!

function! s:RestoreTabpageCD() abort
  if exists('t:cwd') && !isdirectory(t:cwd)
    unlet t:cwd
  endif
  if !exists('t:cwd')
    let t:cwd = getcwd()
  endif
  execute 'cd' fnameescape(expand(t:cwd))
endfunction

augroup MyAutoCommands
  autocmd TabLeave * call <SID>StoreTabpageCD()
  autocmd TabEnter * call <SID>RestoreTabpageCD()
augroup END
"}}}

" Keep no end of line
" See http://vim.wikia.com/wiki/Preserve_missing_end-of-line_at_end_of_text_files
"{{{
function! s:SetBinaryForNoeol() abort
  let g:save_binary_for_noeol = &binary
  if ! &endofline && ! &binary
    setlocal binary
    if &fileformat == "dos"
      silent 1,$-1s/$/\="\\".nr2char(13)
    endif
  endif
endfunction

function! s:RestoreBinaryForNoeol() abort
  if ! &endofline && ! g:save_binary_for_noeol
    if &fileformat == "dos"
      silent 1,$-1s/\r$/
    endif
    setlocal nobinary
  endif
endfunction

augroup MyAutoCommands
  autocmd BufWritePre  * call <SID>SetBinaryForNoeol()
  autocmd BufWritePost * call <SID>RestoreBinaryForNoeol()
augroup END
"}}}

" Remove tailing spaces.
"{{{
function! s:StripTrailingWhitespaces() abort
  silent execute "normal ma<CR>"
  let saved_search = @/
  %s/\s\+$//e
  silent execute "normal `a<CR>"
  let @/ = saved_search
endfunction

command! StripTrailingWhitespaces call <SID>StripTrailingWhitespaces()
"}}}

"}}}

"{{{ Runtime Path and Packages

" Initialize `runtimepath` and `packpath`.
if !exists('s:loaded_vimrc')
  set runtimepath&
  if has('packages')
    set packpath&
  endif

  " Add ~/.vim for Neovim
  if has('nvim')
    set runtimepath+=$HOME/.vim
    if has('packages')
      set packpath+=$HOME/.vim
    end
  endif
endif

" Load all packages.
if has('packages')
  " This will also load `vim-pathogen`.
  packloadall
else
  " Use `vim-pathogen` to load plugins.
  " `vim-pathogen` itself is in the package, add itself manually.
  runtime pack/default/start/vim-pathogen/autoload/pathogen.vim
  " Try to add plugin paths to `runtimepath`.
  try
    " This call may fail if we failed to load `vim-pathogen`.
    call pathogen#infect()
  catch
  endtry
endif

" Try to run `helptags` for each `runtimepath`.
try
  " This call may fail if we failed to load `vim-pathogen`.
  call pathogen#helptags()
catch
endtry

" Source each runtime path configuration script.
"{{{
function! s:SourceRuntimePathScripts() abort
  try
    " This call may fail if we failed to load `vim-pathogen`.
    let paths = pathogen#split(&runtimepath)
  catch
    return
  endtry

  for glob in paths
    for dir in split(glob(glob), "\n")
      if ! isdirectory(dir)
        continue
      end
      " Ignore directory that doesn't have anything.
      " git-submodule may create such directories until it initializes them.
      if empty(globpath(dir, "*"))
        continue
      endif
      let runtime_path_script = dir . '.vim'
      if filereadable(runtime_path_script)
        execute "source " . runtime_path_script
      endif
    endfor
  endfor
endfunction

call s:SourceRuntimePathScripts()
"}}}

"}}}

"{{{ Plugins

" Git Plugin
"{{{
function! s:PreviewGitDiffCached() abort
  " Open `git diff --cached` in a preview window.
  DiffGitCached
  resize 20
  " Back to original window, which is editing COMMIT_EDITMGS.
  wincmd p
  goto 1
endfunction

" Show `git diff --cached` when editing `COMMIT_EDITMSG`.
autocmd MyAutoCommands FileType gitcommit call <SID>PreviewGitDiffCached()

" Use spell check always for `gitcommit`.
autocmd MyAutoCommands FileType gitcommit setlocal spell
"}}}

"}}}

" Re-enable filetype plugin for `ftdetect` directory of each `runtimepath`.
filetype off
filetype on

if !exists('s:loaded_vimrc')
  let s:loaded_vimrc = 1
endif

" See `:help secure`
set secure

" vim: tabstop=2 shiftwidth=2 textwidth=0 expandtab foldmethod=marker nowrap
