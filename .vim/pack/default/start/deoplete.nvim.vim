" Deoplete requires Neovim or Vim 8.0, and +python3 and +timers.
if !((has('nvim') || v:version >= 800) && has('python3') && has('timers'))
  finish
endif

" Deoplete requires `pynvim` Python 3 module.
try
  python3 import pynvim
catch
  finish
endtry

call deoplete#enable()
