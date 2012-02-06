" git-diff
nnoremap Gd :<C-u>Gdiff<CR>
" git-add
nnoremap Ga :<C-u>Gwrite<CR>
" git-checkout, r for read or reset
nnoremap Gr :<C-u>Gread<CR>
" git-blame
nnoremap Gb :<C-u>Gblame<CR>
" Open GitHub
nnoremap Gh :<C-u>Gbrowse<CR>

" Substitute a:from to a:to only once.
" NOTE: substitute(expr, pat) replaces all pat in expr.
function! s:replace_once(str, from, to)
  let idx = stridx(a:str, a:from)
  if idx ==# -1
    return a:str
  else
    let left  = idx ==# 0 ? '' : a:str[: idx - 1]
    let right = a:str[idx + strlen(a:from) :]
    return left . a:to . right
  endif
endfunction

" Show current branch on the status line.
if &statusline !~# '^%!' && &statusline !~# 'fugitive#statusline' && &statusline =~# '%='
  " Git repository status, require vim-fugitive plugin.
  let &statusline = s:replace_once(&statusline, '%=', '%{fugitive#statusline()} ' . '%=')
endif
