" Disable dicwin.vim plugin provied by kaoriya patch which is using <C-k>
let g:plugin_dicwin_disable = 1

function! s:ExecuteCommandOnCR(command)
  if &buftype == ''
    execute a:command
  else
    call feedkeys("\r", 'n')
  endif
endfunction

nnoremap <silent> <CR>  :<C-u>call <SID>ExecuteCommandOnCR('Unite buffer')<CR>
nnoremap <silent> <C-j> :<C-u>Unite file_rec<CR>
nnoremap <silent> <C-k> :<C-u>Unite file<CR>
nnoremap <silent> <C-l> :<C-u>Unite file_mru<CR>