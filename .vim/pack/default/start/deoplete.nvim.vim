" Enable deoplete only when it is NeoVim.
if has('nvim')
  call deoplete#enable()
endif
