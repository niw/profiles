" Fuzzyfinder プラグイン
" http://vim.g.hatena.ne.jp/keyword/fuzzyfinder.vim

" Max number of suggestion
let g:fuf_enumeratingLimit = 100
" Enable FufMruFile
let g:fuf_modesDisable = ['mrucmd']
" Make mru list larger
let g:fuf_mrufile_maxItem = 400
" The key to show the preview in the status lines
let g:fuf_keyPreview = '<Space>'
" Increase length of completion menu width
let g:fuf_maxMenuWidth = 120

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

nnoremap <silent> <CR>  :call <SID>ExecuteCommandOnCR("FufBuffer")<CR>
nnoremap <silent> <C-j> :FufCoverageFile<CR>
nnoremap <silent> <C-k> :FufFileWithCurrentBufferDir<CR>
nnoremap <silent> <C-l> :FufMruFile<CR>
