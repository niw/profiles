" Reset all `autocmd` defined in this file.
augroup MyAutoCommands
  autocmd!
augroup END

"{{{ Encodings

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
  let value = value . ',' . 'default'

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

"}}}

"{{{ Global Options

" Search

" Ignore the case of normal letters
set ignorecase
" If the search pattern contains upper case characters, override the 'ignorecase' option.
set smartcase
" Do not highlight search result.
nohlsearch

" Tab and spaces

" Number of spaces that a <Tab> in the file counts for.
set tabstop=2
" Number of spaces to use for each step of indent.
set shiftwidth=2
" Expand tab to spaces.
set expandtab
" Smart autoindent.
set smartindent
" Round indent to multiple of 'shiftwidth'.
set shiftround

" Cursor and Backspace

" Allow h, l, <Left> and <Right> to move to the previous/next line.
set whichwrap&
set whichwrap+=<,>,[,],h,l

" Displays

" When a bracket is inserted, briefly jump to the matching one.
set showmatch
" Show line number.
set number
" Show the line and column number of the cursor position.
set ruler
" Set title of the window to the value of 'titlesrting'.
set title
" Number of screen lines to use for the command-line.
set cmdheight=2
" Default height for a preview window.
set previewheight=40
" Highlight a pair of < and >.
set matchpairs&
set matchpairs+=<:>
" Disable to translate menu.
set langmenu=none

" Status line

let &statusline = ''
let &statusline .= '%3n '     " Buffer number
let &statusline .= '%<%f '    " Filename
let &statusline .= '%m%r%h%w' " Modified flag, Readonly flag, Preview flag
let &statusline .= '[%{&fileencoding != "" ? &fileencoding : &encoding}][%{&fileformat}][%{&filetype}]'
let &statusline .= '%='       " Spaces
let &statusline .= '%l,%c%V'  " Line number, Column number, Virtual column number
let &statusline .= '%4P'      " Percentage through file of displayed window.

" Completion

" Complete longest common string, list all matches and complete the next full match.
set wildmode=longest,list,full
" Use the pop up menu even if it has only one match.
set completeopt=menuone,preview

" Use multibyte aware format. See `:help fo-table`
set formatoptions&
set formatoptions+=mM

" Disable backup and undo files.
" These are default to `off` but some implementation may set these to `on`.
set nobackup
set noundofile
set noswapfile

"}}}

"{{{ Behaviors

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

" Check file when switch the window.
autocmd MyAutoCommands WinEnter * checktime

" Keep current working directory on each tab page.
" See <https://gist.github.com/604543/>
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

" Keep no end of line.
" See <http://vim.wikia.com/wiki/Preserve_missing_end-of-line_at_end_of_text_files>
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

" Disable automatically insert comment by default.
" These options are set locally by filetypes, thus remove them for each type filetype.
" See `:help fo-table`.
autocmd MyAutoCommands FileType * setlocal formatoptions-=ro

"}}}

"{{{ File Types

" conf
augroup MyAutoCommands
  " Use spell check always for `conf`.
  autocmd MyAutoCommands FileType conf setlocal spell
augroup END

" *.bin
augroup MyAutoCommands
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
let g:mapleader = ','
let g:maplocalleader = '.'

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
nnoremap ; q:i
nnoremap : q:i

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

" Quick edit and reload vimrc
map [Space]. [Vimrc]
nnoremap <silent> [Vimrc]e :<C-u>edit $MYVIMRC<CR>
nnoremap <silent> [Vimrc]s :<C-u>source $MYVIMRC<CR>

" Lookup help
nnoremap <silent> [Space]h :<C-u>help <C-r><C-w><CR>

" Wrap
nnoremap <silent> [Space]w :<C-u>setlocal wrap!<CR>

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

"{{{ Plugins

function! s:CallScriptFunction(name) abort
  return printf('call %s%s()', expand('<SID>'), a:name)
endfunction

" See `autoload/jetpack.vim`.
call jetpack#begin()

function! s:ConfigureJellybeans() abort
  colorscheme jellybeans
endfunction
call jetpack#add('nanotech/jellybeans.vim', {'hook_post_source': s:CallScriptFunction('ConfigureJellybeans')})

call jetpack#add('tpope/vim-surround')

function! s:ConfigureVimCommentary() abort
  " Kind of backward compatibility with removed 'commentout.vim' plugin.
  " See <http://nanasi.jp/articles/vim/commentout_source.html>.
  xmap , <Plug>Commentary
endfunction
call jetpack#add('tpope/vim-commentary', {'hook_post_source': s:CallScriptFunction('ConfigureVimCommentary')})

call jetpack#end()

"}}}

" vim: tabstop=2 shiftwidth=2 textwidth=0 expandtab foldmethod=marker nowrap
