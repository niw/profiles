let g:rails_statusline = 1

augroup MyVimRails
  autocmd!
  autocmd User Rails* map <buffer> <LocalLeader>ra <Plug>RailsAlternate
  autocmd User Rails* Rlcd
augroup END
