" Deoplete requires Neovim or Vim 8.0, and +python3 and +timers.
if (has('nvim') || v:version < 800) && has('python3') && has('timers')
  call deoplete#enable()
endif
