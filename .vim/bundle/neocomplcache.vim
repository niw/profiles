" Disable if vim version is less than 7.0
if v:version > 700
  let g:neocomplcache_enable_at_startup = 1
endif

let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_enable_underbar_completion = 1
"let g:neocomplcache_enable_auto_select = 1

" Disable on fuzzyfinder
let g:neocomplcache_lock_buffer_name_pattern = 'fuzzyfinder'

" Enable omni completion on ruby (default is off, see )
if !exists('g:neocomplcache_omni_patterns')
  let g:neocomplcache_omni_patterns = {}
endif
if has('ruby')
  let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
endif

" Key Mappgins
imap <C-k> <Plug>(neocomplcache_snippets_expand)
smap <C-k> <Plug>(neocomplcache_snippets_expand)
inoremap <expr> <C-g> neocomplcache#undo_completion()
inoremap <expr> <C-l> neocomplcache#complete_common_string()

" <CR> to close popup and save indent.
inoremap <expr> <CR> neocomplcache#smart_close_popup() . "\<CR>"

" <TAB> completion.
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
"imap <expr> <Tab> neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : pumvisible() ? "\<C-n>" : "\<Tab>"

" <C-h>, <BS> to close popup and delete backword char.
inoremap <expr> <C-h> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr> <BS> neocomplcache#smart_close_popup()."\<C-h>"

inoremap <expr> <C-y> neocomplcache#close_popup()
inoremap <expr> <C-e> neocomplcache#cancel_popup()

" Use neocomplcache filename completion.
inoremap <expr> <C-X><C-F> neocomplcache#manual_filename_complete()

" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:nowrap:
