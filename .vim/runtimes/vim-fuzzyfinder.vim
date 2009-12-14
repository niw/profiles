" Fuzzyfinder プラグイン
" http://vim.g.hatena.ne.jp/keyword/fuzzyfinder.vim

" Enable FufMruFile
let g:fuf_modesDisable = ['mrucmd']
" Make mru list larger
let g:fuf_mrufile_maxItem = 400
" The key to show the preview in the status lines
let g:fuf_keyPreview = '<Space>'

" Keymapping
nnoremap <silent> <CR> :if !(&buftype ==? 'quickfix')<CR>execute('FufBuffer')<CR>else<CR>call feedkeys("\r", 'n')<CR>endif<CR>
nnoremap <silent> <C-k> :FufFile<CR>
nnoremap <silent> <C-l> :FufFileWithCurrentBufferDir<CR>
nnoremap <silent> <C-j> :FufMruFile<CR>
