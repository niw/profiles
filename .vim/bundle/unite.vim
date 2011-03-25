let g:unite_source_file_mru_limit = 200
let g:unite_source_file_mru_filename_format = ""

nnoremap [unite] <Nop>
nmap f [unite]

nnoremap <silent> [unite]f :<C-u>Unite -buffer-name=files -start-insert buffer file_mru file bookmark<CR>
nnoremap <silent> [unite]j :<C-u>UniteWithBufferDir -buffer-name=files -start-insert buffer file_mru file bookmark<CR>
nnoremap <silent> [unite]k :<C-u>Unite -buffer-name=files -start-insert file file_rec<CR>
nnoremap <silent> [unite]l :<C-u>Unite -buffer-name=files file_mru<CR>

function! s:unite_settings()
  nmap <buffer> <ESC> <Plug>(unite_exit)
  imap <buffer> <C-w> <Plug>(unite_delete_backward_path)
  imap <buffer> jj <Plug>(unite_insert_leave)

  nmap <buffer> <Tab> <Nop>
  imap <buffer> <Tab> <Nop>
endfunction

autocmd FileType unite call s:unite_settings()

function! s:ExecuteCommandOnCR(command)
  if &buftype == ''
    execute a:command
  else
    call feedkeys("\r", 'n')
  endif
endfunction

nnoremap <silent> <CR> :<C-u>call <SID>ExecuteCommandOnCR('Unite -buffer-name=files buffer_tab')<CR>