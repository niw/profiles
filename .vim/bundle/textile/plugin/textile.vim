" textile.vim
"
" Tim Harper (tim.theenchanter.com)

augroup Textile
  autocmd!
  autocmd BufRead,BufNewFile *.textile setf textile
augroup END
