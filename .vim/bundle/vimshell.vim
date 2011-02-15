let g:vimshell_user_prompt = 'hostname() . ":" . fnamemodify(getcwd(), ":~")'
let g:vimshell_right_prompt = 'vimshell#vcs#info("%s:%b", "%s:%b - %a") . " " . $RUBY_VERSION'
let g:vimshell_enable_smart_case = 1
let g:vimshell_enable_auto_slash = 1

nnoremap <Space>i :<C-u>VimShellInteractive<CR>
nnoremap <Space>\ :<C-u>VimShellPop<CR>
