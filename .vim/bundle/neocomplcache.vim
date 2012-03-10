" Stop configuration when we can't use neocomplecache.
if v:version < 702 || $SUDO_USER != ''
  finish
endif

let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_enable_underbar_completion = 1

" Disable neocomplcache on special cases.
let g:neocomplcache_lock_buffer_name_pattern = '\[Command Line\]'

" Enable keyword completion on ruby (default is off.)
if !exists('g:neocomplcache_keyword_patterns')
  let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns.ruby =
   \ '\h\w*\|:\h\w*\|^=\%(b\%[egin]\|e\%[nd]\)\|\%(@@\|[:$@]\)\h\w*\|\h\w*\%(::\w*\)*[!?]\?'
  "\ '^=\%(b\%[egin]\|e\%[nd]\)\|\%(@@\|[:$@]\)\h\w*\|\h\w*\%(::\w*\)*[!?]\?')

" Enable omni completion on ruby (default is off.)
if !exists('g:neocomplcache_omni_patterns')
  let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.ruby =
  \ '[^. *\t]\.\w*\|:\h\w*\|\h\w*::'

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

inoremap <expr> <C-g> neocomplcache#undo_completion()
inoremap <expr> <C-l> neocomplcache#complete_common_string()

" Rewrite default behaviors
inoremap <expr> <C-y> neocomplcache#close_popup()
inoremap <expr> <C-e> neocomplcache#cancel_popup()

" Use neocomplcache filename completion.
inoremap <expr> <C-x><C-f> neocomplcache#manual_filename_complete()

" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:nowrap:
