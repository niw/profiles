" .vimrc
" http://github.com/niw/profiles

"{{{ Initialize

" There are vim doesn't have eval feature like vim-tiny on Debian.
" NOTE this must be in a single line. See :help no-eval-feature.
if !1 | finish | endif

" Most of this .vimrc may work even on vim 6.x though,
" we disable everything to avoid unexpected behavior for now.
if v:version < 700
  finish
endif

if !exists('s:loaded_vimrc')
  " Don't reset twice on reloading, 'compatible' has many side effects.
  set nocompatible
endif

" Reset all autocmd defined in this file.
augroup MyAutoCommands
  autocmd!
augroup END

" We have now 64 bit Windows.
let s:has_win = has('win32') || has('win64')

"}}}

"{{{ Encodings and Japanese

function! s:SetEncoding() "{{{
  " As default, we're using UTF-8, of course.
  set encoding=utf-8

  " Done by here, if it's MacVim which can't change &termencoding.
  if has('gui_macvim')
    return
  endif

  " Using &encoding as default.
  set termencoding=
  " If LANG shows EUC or Shift-JIS, use it for termencoding.
  if $LANG =~# 'eucJP'
    set termencoding=euc-jp
  elseif $LANG =~# 'SJIS'
    set termencoding=cp932
  endif

  " On Windows, we need to set encoding=japan or force to use cp932.
  " Not tested yet because I'm not using Windows.
  if !has('gui_running') && (&term == 'win32' || &term == 'win64')
    set termencoding=cp932
    set encoding=japan
  elseif has('gui_running') && s:has_win
    set termencoding=cp932
  endif
endfunction "}}}

function! s:SetFileEncodings() "{{{
  if !has('iconv')
    return
  endif

  let enc_eucjp = 'euc-jp'
  let enc_jis = 'iso-2022-jp'

  " Check availability of iconv library.
  " Try converting the chars defined in EUC JIS X 0213 to CP932
  " to make sure iconv supports JIS X 0213 or not.
  if iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let enc_eucjp = 'euc-jisx0213,euc-jp'
    let enc_jis = 'iso-2022-jp-3'
  endif

  let value = 'ucs-bom'
  if &encoding !=# 'utf-8'
    let value = value . ',' . 'ucs-2le' . ',' . 'ucs-2'
  endif

  let value = value . ',' . enc_jis

  if &encoding ==# 'utf-8'
    let value = value . ',' . enc_eucjp . ',' . 'cp932'
  elseif &encoding ==# 'euc-jp' || &encoding ==# 'euc-jisx0213'
    " Reset existing values
    let value = enc_eucjp . ',' . 'utf-8' . ',' . 'cp932'
  else " assuming &encoding ==# 'cp932'
    let value = value . ',' . 'utf-8' . ',' . enc_eucjp
  endif
  let value = value . ',' . &encoding

  if has('guess_encode')
    let value = 'guess' . ',' . value
  endif

  let &fileencodings = value
endfunction "}}}

" Make sure the file is not including any Japanese in ISO-2022-JP, use encoding for fileencoding.
" https://github.com/Shougo/shougo-s-github/blob/master/vim/.vimrc
function! s:SetFileEncoding() "{{{
  if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
    let &fileencoding = &encoding
  endif
endfunction "}}}

call s:SetEncoding()
call s:SetFileEncodings()
autocmd MyAutoCommands BufReadPost * call <SID>SetFileEncoding()

" Address the issue for using □ or ●.
" NOTE We also need to apply a patch for Mac OS X Terminal.app
set ambiwidth=double

" Settings for Input Methods
if has('keymap')
  set iminsert=0 imsearch=0
endif

" Multibyte format, See :help fo-table
set formatexpr&
set formatoptions&
set formatoptions+=mM
"set formatoptions=tcroqnlM1

" Fileformat. Default is Unix.
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
" Highlight a pari of < and >.
set matchpairs+=<:>
" Use dark background by default.
set background=dark

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

" I don't want to use backup and undo files.
set nobackup
set noswapfile
set noundofile

" Hide buffer when it is abandoned.
set hidden

" Expand a history of ':' commands to 100.
set history=100

" Indicates a fast terminal connection.
set ttyfast

" Indicate tab, wrap, trailing spaces and eol or not.
"set list
set listchars=tab:»\ ,extends:»,precedes:«,trail:\

" Highlight Trailing Whitespaces
"{{{
function! s:HighlightTrailingWhitespaces()
  if getbufvar(bufnr('%'), '&buftype') == ""
    let w:trailing_whitespaces_match = matchadd('TrailingWhitespaces', '\v\s+$')
  endif
endfunction

function! s:ClearTrailingWhitespacesHighlights()
  if exists('w:trailing_whitespaces_match')
    call matchdelete(w:trailing_whitespaces_match)
    unlet w:trailing_whitespaces_match
  endif
endfunction

augroup MyAutoCommands
  "autocmd VimEnter,ColorScheme * highlight SpecialKey ctermbg=red guibg=#F92672
  autocmd VimEnter,ColorScheme * highlight TrailingWhitespaces ctermbg=red guibg=#F92672
  "autocmd VimEnter,WinEnter * call <SID>HighlightTrailingWhitespaces()
  autocmd InsertEnter * call <SID>ClearTrailingWhitespacesHighlights()
  autocmd InsertLeave * call <SID>HighlightTrailingWhitespaces()
augroup END
"}}}

" Highlight Cursor Line
"autocmd MyAutoCommands WinEnter,BufEnter * setlocal cursorline
"autocmd MyAutoCommands WinLeave,BufLeave * setlocal nocursorline

" Change current directory by switching the buffers, See :help cmdline-special.
"autocmd MyAutoCommands BufRead,BufEnter * execute ":lcd " . expand("%:p:h:gs? ?\\\\ ?")

" Open QuickFix after vimgrep
"autocmd MyAutoCommands QuickFixCmdPost grep,grepadd,vimgrep,vimgrepadd copen

" Restore cursor position
"{{{
function! s:RestoreCursorPosition()
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

" Always enable spell check if using GUI.
if has('gui_macvim')
  autocmd MyAutoCommands BufNewFile,BufRead * setlocal spell
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
  " See :help fo-table
  autocmd FileType * setlocal formatoptions-=ro | setlocal formatoptions+=mM

  " File type settings
  autocmd FileType actionscript setlocal fileencoding=utf-8 tabstop=4 shiftwidth=4 noexpandtab nowrap
  autocmd FileType objc setlocal fileencoding=utf-8 tabstop=4 shiftwidth=4 expandtab
  autocmd FileType css setlocal iskeyword+=-
  autocmd FileType scss setlocal iskeyword+=-

  " Mapping file types
  autocmd BufNewFile,BufRead *.as setlocal filetype=actionscript
  autocmd BufNewFile,BufRead *.gradle setlocal filetype=groovy
  autocmd BufNewFile,BufRead *.json setlocal filetype=json
  autocmd BufNewFile,BufRead *.mm setlocal filetype=cpp
  autocmd BufNewFile,BufRead *.module setlocal filetype=php
  autocmd BufNewFile,BufRead *.mustache setlocal syntax=mustache
  autocmd BufNewFile,BufRead *.pig setlocal filetype=pig
  autocmd BufNewFile,BufRead *.pom setlocal filetype=xml
  autocmd BufNewFile,BufRead *.pp setlocal filetype=puppet
  autocmd BufNewFile,BufRead *.rl setlocal filetype=ragel
  autocmd BufNewFile,BufRead *.srt setlocal filetype=srt
  autocmd BufNewFile,BufRead *.thrift setlocal filetype=thrift
  autocmd BufNewFile,BufRead *.vcf setlocal filetype=vcard
  autocmd BufNewFile,BufRead Portfile setlocal filetype=macports
  autocmd BufNewFile,BufRead nginx.* setlocal filetype=nginx
  autocmd BufNewFile,BufRead SConstruct setlocal filetype=python
  autocmd BufNewFile,BufRead SConscript setlocal filetype=python
  autocmd BufNewFile,BufRead *.aurora setlocal filetype=python

  " Support grepedit command. See ~/.profiles/bin/grepedit
  autocmd BufRead grepedit.tmp.* setlocal filetype=grepedit

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

" Buffer manipulations
nmap [Space] [Buffer]
"{{{
function! s:NextNormalBuffer(loop) "{{{
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
endfunction "}}}

function! s:OpenNextNormalBuffer(loop) "{{{
  if &buftype == ""
    let buffer_num = s:NextNormalBuffer(a:loop)
    if buffer_num
      execute "buffer" buffer_num
    endif
  endif
endfunction "}}}

function! s:PrevNormalBuffer(loop) "{{{
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
endfunction "}}}

function! s:OpenPrevNormalBuffer(loop) "{{{
  if &buftype == ""
    let buffer_num = s:PrevNormalBuffer(a:loop)
    if buffer_num
      execute "buffer" buffer_num
    endif
  endif
endfunction "}}}

noremap <silent> [Buffer]P :<C-u>call <SID>OpenPrevNormalBuffer(0)<CR>
noremap <silent> [Buffer]p :<C-u>call <SID>OpenPrevNormalBuffer(1)<CR>
noremap <silent> [Buffer]N :<C-u>call <SID>OpenNextNormalBuffer(0)<CR>
noremap <silent> [Buffer]n :<C-u>call <SID>OpenNextNormalBuffer(1)<CR>
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
function! s:MapTabNextWithCount()
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

function! s:SetSearchKeyword(keyword) "{{{
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

function! s:GetSelectedText() "{{{
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
nnoremap <silent> [Space]n :nohlsearch<CR>

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
" NOTE: Command line window doesn't work due to Vim bug since 8.0.152 prior to 8.0.172
" See https://github.com/vim/vim/commit/1d669c233c97486555a34f7d3f069068d9ebdb63
if !has("patch-8.0.152") || has("patch-8.0.172")
  nnoremap ; q:i
  nnoremap : q:i
endif
"{{{
"autocmd MyAutoCommands CmdwinEnter * nnoremap <buffer> <ESC> :<C-u>quit<CR>

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

" Open shell on console or GUI application.
"{{{
function! s:OpenShell()
  if has('gui_macvim')
    " Open Terminal.app, then active it.
"    let l:script = "tell application \"Terminal\"" . "\n"
"               \ . "activate" . "\n"
"               \ . "end tell"
"    call system("env -i osascript", l:script)
    call system("env -i open -b com.apple.Terminal")
  else
    shell
  end
endfunction

nnoremap <silent> [Space]; :<C-u>call <SID>OpenShell()<CR>
"}}}

" Lookup help
nnoremap <silent> [Space]h :<C-u>help <C-r><C-w><CR>

" Wrap
nnoremap <silent> [Space]w :<C-u>setlocal wrap!<CR>

function! s:OpenQuickFixWithSyntex(syntax) "{{{
  let g:last_quick_fix_syntax = a:syntax
  copen
  " NOTE: quickfix window is using syntax match for highlight the selected file.
  " matchadd() always overrules syntax highlighs, it results unexpected highlighting.
  " To avoid this, using syntax match to highlight the keyword here.
  " See help :matchadd
  execute "syntax match Underlined '\\v" . a:syntax . "' display containedin=ALL"
  wincmd J
endfunction "}}}

function! s:OpenQuickFix() "{{{
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
function! s:SpellCheckCompletion()
  if &spell
    call feedkeys("ea\<C-x>s", "n")
  endif
endfunction

nnoremap <silent> gs :<C-u>setlocal spell!<CR>
nnoremap <silent> [Space]s :<C-u>call <SID>SpellCheckCompletion()<CR>
"}}}

"}}}

"{{{ Commands

" Reopen as each encodings
command! -bang -bar -complete=file -nargs=? Utf8      edit<bang> ++enc=utf-8 <args>
command! -bang -bar -complete=file -nargs=? Cp932     edit<bang> ++enc=cp932 <args>
command! -bang -bar -complete=file -nargs=? Euc       edit<bang> ++enc=euc-jp <args>
command! -bang -bar -complete=file -nargs=? Iso2022jp edit<bang> ++enc=iso-2022-jp <args>
command! -bang -bar -complete=file -nargs=? Utf16     edit<bang> ++enc=ucs-2le <args>
command! -bang -bar -complete=file -nargs=? Utf16be   edit<bang> ++enc=ucs-2 <args>

" Recursive Grep and Highlight
"{{{
function! s:FlattenList(list) "{{{
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

function! s:Grep(keyword, ...) "{{{
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

function! s:HasCommand(cmd) "{{{
  execute system('type ' . a:cmd . ' >/dev/null 2>&1')
  return !v:shell_error
endfunction "}}}

function! s:GrepPrg() "{{{
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
function! s:DeleteBuffer(bang) "{{{
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
endfunction "}}}

command! -bang Bdelete call <SID>DeleteBuffer("<bang>")
"}}}

" Vars, require vim-prettyprint
" See http://d.hatena.ne.jp/thinca/20100711/1278849707
command! -nargs=+ Vars PP filter(copy(g:), 'v:key =~# "^<args>"')

" Large font (MacVim only.)
if has('gui_macvim')
  command! GuiLargeFont set guifont=Marker\ Felt:h48 cmdheight=1
endif

" Change current directory to the one of current file.
command! -bar Cd cd %:p:h

" TabpageCD (Modified.)
" See https://gist.github.com/604543/
"{{{
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

" Keep no end of line
" See http://vim.wikia.com/wiki/Preserve_missing_end-of-line_at_end_of_text_files
"{{{
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
  autocmd BufWritePre  * call <SID>SetBinaryForNoeol()
  autocmd BufWritePost * call <SID>RestoreBinaryForNoeol()
augroup END
"}}}

" Remove tailing spaces.
"{{{
function! s:StripTrailingWhitespaces()
  silent execute "normal ma<CR>"
  let saved_search = @/
  %s/\s\+$//e
  silent execute "normal `a<CR>"
  let @/ = saved_search
endfunction

command! StripTrailingWhitespaces call <SID>StripTrailingWhitespaces()
"}}}

"}}}

"{{{ Platform Dependents

" Support for the file system which ignore case
if filereadable($VIM . '/vimrc') && filereadable($VIM . '/ViMrC')
  " Do not duplicate tags file
  set tags=./tags,tags
endif

" On Windows, if $PATH doesn't includes $VIM, it can not find out the exe file
if s:has_win && $PATH !~? '\(^\|;\)' . escape($VIM, '\\') . '\(;\|$\)'
  let $PATH = $VIM . ';' . $PATH
endif

" I don't want to use Japanese menu on MacVim
if has("gui_macvim")
  set langmenu=none
endif

" MacVim-KaoriYa 20101102 requires this setting to enable Ruby.
if has('gui_macvim') && has('kaoriya')
  let $RUBY_DLL = "/usr/lib/libruby.dylib"
endif

" Disable features coming with Kaoriya patch.
if has('kaoriya')
  " Disable dicwin.vim plugin provided by Kaoriya patch which is using <C-k>
  let g:plugin_dicwin_disable = 1

  " Do not use useless example.
  let g:no_vimrc_example = 1
  let g:no_gvimrc_example = 1
endif

" If terminal supports 256 colors or GUI, set colorscheme.
if $TERM =~? '256' || has('gui_running')
  colorscheme molokai
endif

"}}}

"{{{ Runtime Paths

" Add runtime paths (Using pathogen.vim)
if !exists('s:loaded_vimrc')
  set runtimepath&

  " Add ~/.vim to &runtimepath for Windows
  if s:has_win
    set runtimepath+=$HOME/.vim
  endif

  call pathogen#runtime_append_all_bundles()
  call pathogen#helptags()
endif

function! s:SourceRuntimeBundleScripts() "{{{
  for dir in pathogen#split(&runtimepath)
    " Ignore all blank paths in runtimepath, which may be paths created by
    " git-submodule but not updated yet.
    if empty(globpath(dir, "*"))
      continue
    endif
    for vimfile in [dir . '.vim', dir . '/.vimrc']
      if filereadable(vimfile)
        execute "source " . vimfile
      endif
    endfor
  endfor
endfunction "}}}

call s:SourceRuntimeBundleScripts()

"}}}

"{{{ Plugins

" Git Plugin
" Show `git diff --cached` when editing COMMIT_EDITMSG.
"{{{
function! s:PreviewGitDiffCached()
  " Open `git diff --cached` in a preview window.
  DiffGitCached
  resize 20
  " Back to original window, which is editing COMMIT_EDITMGS.
  wincmd p
  goto 1
endfunction

autocmd MyAutoCommands FileType gitcommit call <SID>PreviewGitDiffCached()
"}}}

" Go Plugin
" golang provides vim plugin in $GOROOT/misc/vim, if we have that path, add it to runtimepath.
" {{{
function! s:UseGoPlugin()
  " Use pathogen to manage runtimepath.
  if !empty($GOROOT)
    let sep = pathogen#separator()
    let before = pathogen#glob_directories($GOROOT . sep . "misc" . sep . "vim")
    let after = pathogen#glob_directories($GOROOT . sep . "misc" . sep . "vim" . sep . "after")
    let &runtimepath = pathogen#join(before, &runtimepath, after)
  endif
endfunction

call s:UseGoPlugin()
" }}}

"}}}

"{{{ Finalize

" Re-enable filetype plugin for ftdetect directory of each runtimepath
filetype off
filetype on

if !exists('s:loaded_vimrc')
  let s:loaded_vimrc = 1
endif

" See :help secure
set secure

"}}}

" vim: tabstop=2 shiftwidth=2 textwidth=0 expandtab foldmethod=marker nowrap
