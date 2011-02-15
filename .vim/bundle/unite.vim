let g:unite_source_file_mru_limit = 200
let g:unite_source_file_mru_filename_format = ""

nnoremap [unite] <Nop>
nmap f [unite]

nnoremap <silent> [unite]j :<C-u>UniteWithCurrentDir -buffer-name=files buffer file_mru bookmark file<CR>
nnoremap <silent> [unite]k :<C-u>UniteWithBufferDir -buffer-name=files buffer file_mru bookmark file<CR>
"nnoremap <silent> [unite]r :<C-u>Unite -buffer-name=register register<CR>
"nnoremap <silent> [unite]o :<C-u>Unite outline<CR>
nnoremap [unite]f :<C-u>Unite source<CR>

function! s:unite_settings()
  nmap <buffer> <ESC> <Plug>(unite_exit)

  " <C-l> manual neocomplcache completion.
  inoremap <buffer> <C-l> <C-x><C-u><C-p><Down>

  " Start insert.
  "let g:unite_enable_start_insert = 1
endfunction

autocmd FileType unite call s:unite_settings()

" Backward compatibility to fuzzyfinder configuration
function! s:ExecuteCommandOnCR(command)
  if &buftype == ''
    execute a:command
  else
    call feedkeys("\r", 'n')
  endif
endfunction

nnoremap <silent> <CR>  :<C-u>call <SID>ExecuteCommandOnCR('Unite -buffer-name=files buffer')<CR>
nnoremap <silent> <C-j> :<C-u>Unite -buffer-name=files file_rec<CR>
nnoremap <silent> <C-k> :<C-u>UniteWithBufferDir -buffer-name=files buffer file_mru bookmark file<CR>
nnoremap <silent> <C-l> :<C-u>Unite -buffer-name=files file_mru<CR>

" Disable dicwin.vim plugin provied by kaoriya patch which is using <C-k>
let g:plugin_dicwin_disable = 1