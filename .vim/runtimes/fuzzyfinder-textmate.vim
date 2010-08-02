" Make mru list larger
let g:FuzzyFinderOptions = {'MruCmd': {}}
let g:FuzzyFinderOptions.MruCmd.max_item = 200

" Disable dicwin.vim plugin provied by kaoriya patch which is using <C-k>
let g:plugin_dicwin_disable = 1

" Keymapping
function! s:ExecuteCommandOnCR(command)
  if &buftype == ""
    execute(a:command)
  else
    call feedkeys("\r", 'n')
  endif
endfunction

nnoremap <silent> <CR>  :call <SID>ExecuteCommandOnCR("FuzzyFinderBuffer")<CR>
nnoremap <silent> <C-j> :FuzzyFinderTextMate<CR>
nnoremap <silent> <C-k> :FuzzyFinderFileWithCurrentBufferDir<CR>
nnoremap <silent> <C-l> :FuzzyFinderMruFile<CR>