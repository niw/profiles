" Fuzzyfinder プラグイン
" http://vim.g.hatena.ne.jp/keyword/fuzzyfinder.vim

" Enable FufMruFile
let g:fuf_modesDisable = ['mrucmd']
" Make mru list larger
let g:fuf_mrufile_maxItem = 400
" Keymapping
nnoremap <silent> <C-m> :FufBuffer<CR>
nnoremap <silent> <C-k> :FufFile<CR>
nnoremap <silent> <C-l> :FufFileWithCurrentBufferDir<CR>
nnoremap <silent> <C-j> :FufMruFile<CR>
