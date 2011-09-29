let g:unite_source_file_mru_limit = 200
let g:unite_source_file_mru_filename_format = ""

function! s:UniteSettings()
  nmap <buffer> <ESC> <Plug>(unite_exit)
  imap <buffer> <C-w> <Plug>(unite_delete_backward_path)
  imap <buffer> jj <Plug>(unite_insert_leave)
"  nmap <buffer> <Tab> <Nop>
"  imap <buffer> <Tab> <Nop>
endfunction

augroup MyUnite
  autocmd!
  autocmd FileType unite call s:UniteSettings()
augroup END

nmap f [Unite]
nnoremap [Unite] <Nop>

nnoremap <silent> [Unite]f :<C-u>Unite -buffer-name=files -start-insert buffer_tab file_mru file file_rec<CR>
nnoremap <silent> [Unite]j :<C-u>Unite -buffer-name=files -start-insert file file_rec<CR>
nnoremap <silent> [Unite]k :<C-u>UniteWithBufferDir -buffer-name=files -start-insert file file_rec<CR>
nnoremap <silent> [Unite]l :<C-u>Unite -buffer-name=files file_mru<CR>
nnoremap <silent> [Unite]p :<C-u>Unite poslist<CR>

function! s:ExecuteCommandOnCR(command)
  if &buftype == ''
    execute a:command
  else
    call feedkeys("\r", 'n')
  endif
endfunction

nnoremap <silent> <CR> :<C-u>call <SID>ExecuteCommandOnCR('Unite -buffer-name=files buffer_tab')<CR>

" unite-grep
let g:unite_source_grep_max_candidates = 200
let g:unite_source_grep_default_opts = "-HnEi"
  \ . " --exclude='*.svn*'"
  \ . " --exclude='*.log*'"
  \ . " --exclude='*tmp*'"
  \ . " --exclude-dir='**/tmp'"
  \ . " --exclude-dir='CVS'"
  \ . " --exclude-dir='.svn'"
  \ . " --exclude-dir='.git'"

nnoremap <silent> <expr> [Unite]g printf(':<C-u>Unite grep:%s:-R:%s -no-quit<CR>', expand(getcwd()), expand("<cword>"))