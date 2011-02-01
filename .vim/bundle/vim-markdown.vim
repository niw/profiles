augroup FileTypeRelated
  autocmd!
  autocmd BufNewFile,BufRead *.{md,mkd,mkdn,mark*} set filetype=markdown fileencoding=utf-8
augroup END
