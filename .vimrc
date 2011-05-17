" .vimrc
" http://github.com/niw/profiles
" Some original code sniped was created by http://github.com/kana/config

"{{{ Initialize

if !exists('s:loaded_vimrc')
  " Don't reset twice on reloading, 'compatible' has many side effects.
  set nocompatible
endif

" We have now 64 bit Windows.
let s:has_win = has('win32') || has('win64')

" Reset all autocmd defined in this file.
augroup MyAutoCommands
  autocmd!
augroup END

"}}}

"{{{ Japanese Support

" Strings shows each Japanese encodings
" We can select the strings for the runtime environment by calling s:CheckIconvCapability
let s:enc_cp932 = 'cp932'
let s:enc_eucjp = 'euc-jp'
let s:enc_jisx = 'iso-2022-jp'
let s:enc_utf8 = 'utf-8'

" Select &encoding
" On Mac OS X with GUI, We use UTF-8. Otherwise prefer to use same as LANG environment variables
function! s:DetermineEncoding()
  " Use UTF-8 on Mac OS X GUI
  if has('gui_running') && has('mac')
    let &encoding = s:enc_utf8
  endif
  " LANG environment variable takes precedence to &encoding.
  if $LANG =~# 'euc'
    let &encoding = s:enc_eucjp
  elseif $LANG =~# 'SJIS'
    let &encoding = s:enc_cp932
  elseif $LANG =~# 'UTF-8'
    let &encoding = s:enc_utf8
  endif
endfunction

" Check availability of iconv library
" Try to convert the cahrs which is defined in EUC JIS X 0213 to CP932
" to check the iconv supprts JIS X 0213.
function! s:CheckIconvCapability()
  if !has('iconv') | return | endif
  if iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let s:enc_eucjp = 'euc-jisx0213,euc-jp'
    let s:enc_jisx = 'iso-2022-jp-3'
  else
    let s:enc_eucjp = 'euc-jp'
    let s:enc_jisx = 'iso-2022-jp'
  endif
endfunction

" Select fileencodings
" We should check iconv and encoding to determin how fill out fileencodings
function! s:DetermineFileencodings()
  if !has('iconv') | return | endif
  let value = ''
  if &encoding ==? 'utf-8'
    " For UTF-8 runtime environment
    let value = value. s:enc_jisx. ','. s:enc_cp932. ','. s:enc_eucjp
  elseif &encoding ==? 'cp932'
    " For CP932 runtime environment
    let value = value. s:enc_jisx. ','. s:enc_utf8. ','. s:enc_eucjp
  elseif &encoding ==? 'euc-jp' || &encoding ==? 'euc-jisx0213'
    " For EUC-JP runtime environment
    let value = value. s:enc_jisx. ','. s:enc_utf8. ','. s:enc_cp932
  else
    " NOTE if neede, we can place the settings for the other runtime environments
  endif
  if has('guess_encode')
    let value = 'guess,'. value
  endif
  " FIXME UTF-16 support
  "let value = value. ',ucs-bom,ucs-2le,ucs-2'
  let &fileencodings = value
endfunction

" Update encoding and fileencodings for current environment
set encoding=japan
call s:DetermineEncoding()
set fileencodings=japan
call s:CheckIconvCapability()
call s:DetermineFileencodings()

" Address the issue for using □ or ●.
" NOTE We also need to apply some patch for Mac OS X Terminal.app
set ambiwidth=double

" Settings for Japanese Input Methods
if has('keymap')
  "silent! set keymap=japanese
  set iminsert=0 imsearch=0
endif

" On Windows, set CP932 to termencoding
if !has('gui_running') && &encoding != 'cp932' && &term == 'win32'
  set termencoding=cp932
endif

" I don't want to see Japanese menu on MacVim
if has("gui_macvim")
  set langmenu=none
endif

"}}}

"{{{ Global Settings

" Search
set ignorecase
set smartcase
set incsearch
set hlsearch
set wrapscan

" Tab and spaces
set tabstop=4
set shiftwidth=4
set noexpandtab
set autoindent
set smartindent

" Cursor and Backspace
set backspace=indent,eol,start
set whichwrap&
set whichwrap+=<,>,[,],h,l

" Japanese support
set formatoptions&
set formatoptions+=mM

" Displays
set showmatch
set wildmenu
set number
set ruler
set nolist
set listchars=tab:>-,extends:<,trail:-,eol:<
set wrap
set laststatus=2
set cmdheight=2
set previewheight=40
set showcmd
set title
set showmode
set statusline=%3n\ %<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']['.&ft.']'}%=%l,%c%V%8P

" Backup files
set nobackup
set noswapfile

" Hide buffer when it is abandoned.
set hidden

set history=50
set ttyfast
set wildmode=longest,list,full
set completeopt=menuone
set fileformats=unix,dos,mac
syntax enable
filetype plugin on

"}}}

"{{{ Key Mappings

" Define <Leader>, <LocalLeader>
let mapleader = ','
let maplocalleader = '.'

" Disable <Leader>, <LocalLeader> to avoid unexpected behavior.
noremap <Leader> <Nop>
noremap <LocalLeader> <Nop>

" Disable dicwin.vim plugin provied by kaoriya patch which is using <C-k>
let g:plugin_dicwin_disable = 1

" Reserve q for prefix key then assign Q for original actions.
" Q is for Ex-mode which we don't need to use.
nnoremap q <Nop>
nnoremap Q q

" Window Switching
noremap <C-Down>  <C-W>j
noremap <C-Up>    <C-W>k
noremap <C-Left>  <C-W>h
noremap <C-Right> <C-W>l

" Buffer Switching
function! s:NextNormalBuffer(loop)
  let buffer_num = bufnr('%')
  let last_buffer_num = bufnr('$')

  let next_buffer_num = buffer_num
  while 1
    if next_buffer_num == last_buffer_num
      if a:loop
        let next_buffer_num = 1
      else
        break
      endif
    else
      let next_buffer_num = next_buffer_num + 1
    endif
    if next_buffer_num == buffer_num
      break
    endif
    if ! buflisted(next_buffer_num)
      continue
    endif
    if getbufvar(next_buffer_num, '&buftype') == ""
      return next_buffer_num
      break
    endif
  endwhile
  return 0
endfunction

function! s:OpenNextNormalBuffer(loop)
  if &buftype == ""
    let buffer_num = s:NextNormalBuffer(a:loop)
    if buffer_num
      execute "buffer" buffer_num
    endif
  endif
endfunction

function! s:PrevNormalBuffer(loop)
  let buffer_num = bufnr('%')
  let last_buffer_num = bufnr('$')

  let prev_buffer_num = buffer_num
  while 1
    if prev_buffer_num == 1
      if a:loop
        let prev_buffer_num = last_buffer_num
      else
        break
      endif
    else
      let prev_buffer_num = prev_buffer_num - 1
    endif
    if prev_buffer_num == buffer_num
      break
    endif
    if ! buflisted(prev_buffer_num)
      continue
    endif
    if getbufvar(prev_buffer_num, '&buftype') == ""
      return prev_buffer_num
      break
    endif
  endwhile
  return 0
endfunction

function! s:OpenPrevNormalBuffer(loop)
  if &buftype == ""
    let buffer_num = s:PrevNormalBuffer(a:loop)
    if buffer_num
      execute "buffer" buffer_num
    endif
  endif
endfunction

noremap <silent> <F1> :<C-u>call <SID>OpenPrevNormalBuffer(0)<CR>
noremap <silent> <F2> :<C-u>call <SID>OpenPrevNormalBuffer(1)<CR>
noremap <silent> <F3> :<C-u>call <SID>OpenNextNormalBuffer(1)<CR>
noremap <silent> <F4> :<C-u>call <SID>OpenNextNormalBuffer(0)<CR>

" Tab
function! s:MapTabNextWithCount()
  let tab_count = 1
  while tab_count < 10
    execute printf("noremap <silent> t%s :tabnext %s<CR>", tab_count, tab_count)
    let tab_count = tab_count + 1
  endwhile
endfunction

noremap <silent> tc :<C-u>tabnew<CR>
"noremap <silent> tt :tabnew<CR>
noremap <silent> tq :<C-u>tabclose<CR>
noremap <silent> tn :<C-u>tabnext<CR>
noremap <silent> tp :<C-u>tabprev<CR>

call s:MapTabNextWithCount()

" Make
noremap <silent> <F5> :<C-u>make<CR>

" Run EX commands by ; for US Keyboard
noremap ; :

" Move cursor by display line
noremap j gj
noremap k gk
noremap gj j
noremap gk k

" Disable highlight
noremap <C-h><C-h> :<C-u>nohlsearch<CR>

" Reset syntax highlight
noremap <C-h><C-j> :<C-u>syntax sync clear<CR>

" Select the last modified texts
nnoremap gm `[v`]
vnoremap gm :<C-u>normal gc<CR>
onoremap gm :<C-u>normal gc<CR>

" Quick edit and reload .vimrc
nnoremap <Space>.  :<C-u>edit $MYVIMRC<CR>
nnoremap <Space>s. :<C-u>source $MYVIMRC<CR>

" Run shell
nnoremap <Space>: :<C-u>shell<CR>
nnoremap <Space>; :<C-u>shell<CR>

" Operation for the words under the cursor or the visual region
function! s:CommandWithVisualRegionString(cmd)
	let reg = getreg('a')
	let regtype = getregtype('a')
	silent normal! gv"ay
	let selected = @a
	call setreg('a', reg, regtype)
  execute a:cmd . ' ' . selected
endfunction

nnoremap <Space>h :<C-u>help<Space><C-r><C-w><CR>
xnoremap <Space>h :<C-u>call <SID>CommandWithVisualRegionString('help')<CR>

nnoremap gr :<C-u>Grep<Space><C-r><C-w><CR>
xnoremap gr :<C-u>call <SID>CommandWithVisualRegionString('Grep')<CR>
"nnoremap ak :<C-u>Aak<Space><C-r><C-w><CR>
"xnoremap ak :<C-u>call <SID>CommandWithVisualRegionString('Ack')<CR>

" Centering search result
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

" Centering cursor after splitting window
nnoremap <C-w>s <C-w>szz

" QuickFix
function! s:OpenQuickFixWithSyntex(syntax)
  let g:last_quick_fix_syntax = a:syntax
  execute "copen"
  execute "syntax match Underlined '\\v" . a:syntax . "' display containedin=ALL"
  call feedkeys("\<C-w>J", "n")
endfunction

function! s:OpenQuickFix()
  if exists('g:last_quick_fix_syntax')
    call s:OpenQuickFixWithSyntex(g:last_quick_fix_syntax)
  else
    execute "copen"
  endif
endfunction

nnoremap <silent> <space>q :call <SID>OpenQuickFix()<CR>
nnoremap <silent> <space>w :<C-u>cclose<CR>

" Easy to quit.
nnoremap <silent> qq :<C-u>quit<CR>
nnoremap <silent> qd :<C-u>Bdelete<CR>

" Avoid run K mistakenly with C-k, remap K to <space>k
nnoremap K <Nop>
nnoremap <Space>k K

"}}}

" {{{ Auto Commands

" File Types
augroup MyAutoCommands
  autocmd FileType ruby,eruby,haml setlocal tabstop=2 shiftwidth=2 expandtab nowrap
  autocmd FileType vim setlocal tabstop=2 shiftwidth=2 expandtab nowrap
  autocmd FileType php setlocal tabstop=2 shiftwidth=2 expandtab nowrap
  autocmd FileType actionscript setlocal fileencoding=utf-8 tabstop=4 shiftwidth=4 noexpandtab nowrap
  autocmd BufNewFile,BufRead *.as setlocal filetype=actionscript tabstop=2 shiftwidth=2 expandtab nowrap
  autocmd BufNewFile,BufRead *.rl setlocal filetype=ragel
  autocmd BufNewFile,BufRead *.srt setlocal filetype=srt
  autocmd BufNewFile,BufRead nginx.* setlocal filetype=nginx
  autocmd BufNewFile,BufRead Portfile setlocal filetype=macports
  autocmd BufNewFile,BufRead *.vcf setlocal filetype=vcard
  autocmd BufNewFile,BufRead *.module setlocal filetype=php
  autocmd BufNewFile,BufRead *.mustache set syntax=mustache
  autocmd BufRead grepedit.tmp.* setlocal filetype=grepedit
  autocmd BufNewFile,BufRead *.json setlocal filetype=json
  autocmd BufNewFile,BufRead *.pp setlocal filetype=puppet
  autocmd BufNewFile,BufRead *.mm setlocal filetype=cpp
augroup END

" Editing Binary File
augroup MyAutoCommands
  autocmd BufReadPre *.bin let &bin=1
  autocmd BufReadPost *.bin if &bin | silent %!xxd -g 1
  autocmd BufReadPost *.bin setlocal ft=xxd | endif
  autocmd BufWritePre *.bin if &bin | %!xxd -r
  autocmd BufWritePre *.bin endif
  autocmd BufWritePost *.bin if &bin | silent %!xxd -g 1
  autocmd BufWritePost *.bin setlocal nomod | endif
augroup END

augroup MyAutoCommands
  " Highlight Cursour Line
  "autocmd WinEnter,BufEnter * setlocal cursorline
  "autocmd WinLeave,BufLeave * setlocal nocursorline

  " Change current directory by switching the buffers
  " :help cmdline-special
  "autocmd BufRead,BufEnter * execute ":lcd " . expand("%:p:h:gs? ?\\\\ ?")

  " Open QuickFix after vimgrep
  "autocmd QuickFixCmdPost grep,grepadd,vimgrep,vimgrepadd copen
augroup END

" Keep No End Of Line
" See http://vim.wikia.com/wiki/Preserve_missing_end-of-line_at_end_of_text_files
function! s:SetBinaryForNoeol()
  let g:save_binary_for_noeol = &binary
  if ! &endofline && ! &binary
    setlocal binary
    if &fileformat == "dos"
      silent 1,$-1s/$/\="\\".nr2char(13)
    endif
  endif
endfunction

function! s:RestoreBinaryForNoeol()
  if ! &endofline && ! g:save_binary_for_noeol
    if &fileformat == "dos"
      silent 1,$-1s/\r$/
    endif
    setlocal nobinary
  endif
endfunction

augroup MyAutoCommands
  autocmd BufWritePre  * :call <SID>SetBinaryForNoeol()
  autocmd BufWritePost * :call <SID>RestoreBinaryForNoeol()
augroup END

"}}}

"{{{ Commands

" Open as UTF-8
command! Utf8 edit ++enc=utf-8

" Recursive Grep and Highlight
function! s:FlattenList(list)
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
endfunction

function! s:Grep(grepprg, keyword, ...)
  let args = ['grep!', shellescape(a:keyword)]
  for arg in s:FlattenList(a:000)
    call add(args, shellescape(arg, 1))
  endfor

  let grepprg = &grepprg
  let &grepprg = a:grepprg
  execute join(args, ' ')
  let &grepprg = grepprg

  call s:OpenQuickFixWithSyntex(a:keyword)
endfunction

function! s:HasCommand(cmd)
  execute system('which ' . a:cmd . ' 2>&1 >/dev/null')
  return !v:shell_error
endfunction

function! s:GrepPrg()
  if exists('g:grepprg')
    return g:grepprg
  else
    let g:grepprg = &grepprg
  endif

  if s:HasCommand('ack')
    let g:grepprg = 'ack'
  elseif s:HasCommand('grep')
    let opts = "-r -E -n --exclude='*.svn*' --exclude='*.log*' --exclude='*tmp*'"
    if system('grep --help') =~# '--exclude-dir'
      let opts .= " --exclude-dir='CVS' --exclude-dir='.svn' --exclude-dir='.git'"
    endif
    let g:grepprg = 'grep ' . opts . ' . -e '
  endif

  return g:grepprg
endfunction

command! -nargs=+ Grep call <SID>Grep(<SID>GrepPrg(), <f-args>)
"command! -nargs=+ Ack call <SID>Grep('ack', <f-args>)

" Change file name editing
command! -nargs=1 -complete=file Rename file <args>|call delete(expand('#'))

" Preserve window splits when deleting the buffer
function! s:DeleteBuffer(bang)
  if &mod && a:bang != '!'
    return
  endif

  let buffer_num = bufnr('%')
  let win_num = winnr()

  let next_buffer_num = s:NextNormalBuffer(1)
  if ! next_buffer_num
    enew
    let next_buffer_num = bufnr('%')
    if next_buffer_num == buffer_num
      return
    end
  endif

  " FIXME we have to check the other tabs because bufwinnr doesn't care them
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

" Vars, require vim-prettyprint
" See http://d.hatena.ne.jp/thinca/20100711/1278849707
command! -nargs=+ Vars PP filter(copy(g:), 'v:key =~# "^<args>"')

" Large font
if has('mac') && has('gui_running')
  command! GuiLargeFont set guifont=Marker\ Felt:h48 cmdheight=1
endif

" Change current directory to the one of current file.
command! -bar Cd cd %:p:h

" TabpageCD, modified. I'm not sure it works good or not.
" See https://gist.github.com/604543/

function! s:StoreTabpageCD()
  let t:cwd = getcwd()
endfunction!

function! s:RestoreTabpageCD()
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

"{{{ Platform Dependents

" Support for the file system which ignore case
if filereadable($VIM . '/vimrc') && filereadable($VIM . '/ViMrC')
  " Do not duplicate tags file
  set tags=./tags,tags
endif

" If $DISPLAY environment variable is defined, vim works slow
if !has('gui_running') && has('xterm_clipboard')
  set clipboard=exclude:cons\\\|linux\\\|cygwin\\\|rxvt\\\|screen
endif

" On Windows, if $PATH doesn't includes $VIM, it can not find out the exe file
if s:has_win && $PATH !~? '\(^\|;\)' . escape($VIM, '\\') . '\(;\|$\)'
  let $PATH = $VIM . ';' . $PATH
endif

" On Mac, default 'iskeyword' doesn't support for cp932
if has('mac')
  set iskeyword=@,48-57,_,128-167,224-235
endif

" MacVim-KaoriYa 20101102 requires this setting to enable Ruby.
if has('mac') && has('gui_running') && has('kaoriya')
  let $RUBY_DLL = "/usr/lib/libruby.dylib"
endif

" Disable dicwin.vim plugin provied by kaoriya patch which is using <C-k>
if has('kaoriya')
  let g:plugin_dicwin_disable = 1
endif

" Do not use useless example.
let g:no_gvimrc_example = 1

" If terminal supports 256 colors or GUI, set colorscheme.
if $TERM =~? '256' || has('gui_running')
  colorscheme molokai
  "colorscheme twilight
endif

"}}}

"{{{ Runtime Paths

set runtimepath&

" Add ~/.vim to &runtimepath for Windows
if s:has_win
  set runtimepath+=$HOME/.vim
endif

" Add runtime paths (Using pathogen.vim)
function! s:SourceRuntimeBundleScripts()
  for dir in pathogen#split(&runtimepath)
    for vimfile in [dir . '.vim', dir . '/.vimrc']
      if filereadable(vimfile)
        execute "source " . vimfile
      endif
    endfor
  endfor
endfunction

call pathogen#runtime_append_all_bundles()
call s:SourceRuntimeBundleScripts()
call pathogen#helptags()

" Re-enable filetype plugin for ftdetect directory of each runtimepath
filetype off
filetype on

"}}}

"{{{ Plugins

" Git Plugin (Standard Plugin)
autocmd MyAutoCommands FileType gitcommit DiffGitCached

"}}}

"{{{ Finalize

if !exists('s:loaded_vimrc')
  let s:loaded_vimrc = 1
endif

" See :help secure
set secure

"}}}

" vim:set tabstop=2 shiftwidth=2 expandtab foldmethod=marker nowrap:
