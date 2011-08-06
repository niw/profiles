" Disable if vim version is less than 7.0.
if v:version > 700
  let g:neocomplcache_enable_at_startup = 1
endif

let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_enable_underbar_completion = 1

" Disable on fuzzyfinder.
let g:neocomplcache_lock_buffer_name_pattern = 'fuzzyfinder'

" Enable omni completion on ruby (default is off.)
if !exists('g:neocomplcache_omni_patterns')
  let g:neocomplcache_omni_patterns = {}
endif
if has('ruby')
  let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
endif

" Auto select, <Tab> to point completion, <CR> to select then close popup.
"let g:neocomplcache_enable_auto_select = 1
"inoremap <expr> <Tab> pumvisible() ? "\<Down>" : "\<Tab>"
"inoremap <expr> <S-Tab> pumvisible() ? "\<Up>" : "\<S-Tab>"
"inoremap <expr> <CR> pumvisible() ? neocomplcache#close_popup() : "\<CR>"

" No auto select, <Tab> to select complete. <CR> works <CR> and close popup.
"inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
"inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
"inoremap <expr> <CR> neocomplcache#smart_close_popup() . "\<CR>"

" No auto select, <Tab> to select complete. <CR> close popup.
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR> pumvisible() ? neocomplcache#close_popup() : "\<CR>"

" Key Mappings
imap <C-k> <Plug>(neocomplcache_snippets_expand)
smap <C-k> <Plug>(neocomplcache_snippets_expand)

inoremap <expr> <C-g> neocomplcache#undo_completion()
inoremap <expr> <C-l> neocomplcache#complete_common_string()

" Rewrite default behaviors
inoremap <expr> <C-y> neocomplcache#close_popup()
inoremap <expr> <C-e> neocomplcache#cancel_popup()

" Use neocomplcache filename completion.
inoremap <expr> <C-x><C-f> neocomplcache#manual_filename_complete()

" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:nowrap:
