" Make mru list larger
let g:FuzzyFinderOptions = {'MruCmd': {}}
let g:FuzzyFinderOptions.MruCmd.max_item = 200

" Ignore temporary files
let g:fuzzy_ignore = "*.log,tmp/*,.svn/*,.git/*"
let g:fuzzy_ceiling = 20000

" Disable dicwin.vim plugin provied by kaoriya patch which is using <C-k>
let g:plugin_dicwin_disable = 1

" I'm not sure why but we can't use <SID>ExecuteCommandOnCR with FuzzyFinderBuffer
nnoremap <silent> <CR>  :if &buftype == ''<CR>execute('FuzzyFinderBuffer')<CR>else<CR>call feedkeys("\r", 'n')<CR>endif<CR>
nnoremap <silent> <C-j> :FuzzyFinderTextMate<CR>
nnoremap <silent> <C-k> :FuzzyFinderFileWithCurrentBufferDir<CR>
nnoremap <silent> <C-l> :FuzzyFinderMruFile<CR>