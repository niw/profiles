" Fuzzyfinder プラグイン
" http://vim.g.hatena.ne.jp/keyword/fuzzyfinder.vim

let g:FuzzyFinderOptions = {'Base':{}, 'Buffer':{}, 'File':{}, 'Dir':{}, 'MruFile':{}, 'MruCmd':{}, 'Bookmark':{}, 'Tag':{}, 'TaggedFile':{}}
let g:FuzzyFinderOptions.Base.ignore_case = 1

nnoremap <silent> <C-n> :FuzzyFinderBuffer<CR>
nnoremap <silent> <C-m> :FuzzyFinderFile <C-r>=expand('%:~:.')[:-1-len(expand('%:~:.:t'))]<CR><CR>
nnoremap <silent> <C-j> :FuzzyFinderMruFile<CR>
nnoremap <silent> <C-k> :FuzzyFinderMruCmd<CR>
nnoremap <silent> <C-p> :FuzzyFinderDir <C-r>=expand('%:p:~')[:-1-len(expand('%:p:~:t'))]<CR><CR>
