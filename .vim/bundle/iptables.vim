augroup MyIptables
  autocmd!
  autocmd BufNewFile,BufRead iptables* setlocal filetype=iptables
augroup END
