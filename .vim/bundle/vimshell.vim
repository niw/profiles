" Stop configuration when we can't use vimshell.
if v:version < 702 || $SUDO_USER != ''
  finish
endif

let g:vimshell_user_prompt = 'hostname() . ":" . fnamemodify(getcwd(), ":~")'
let g:vimshell_right_prompt = 'vimshell#vcs#info("%s:%b", "%s:%b - %a") . " " . $RUBY_VERSION'
let g:vimshell_enable_smart_case = 1
let g:vimshell_enable_auto_slash = 1
