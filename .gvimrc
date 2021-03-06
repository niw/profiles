" Reset all `autocmd` defined in this file.
augroup MyGvimAutoCommands
  autocmd!
augroup END

" Font
if has('gui_macvim')
  set guifont=Menlo:h14
endif

" Window size
set columns=120
set lines=65

" Transparency if we can use.
if exists('&transparency')
  set transparency=3
  augroup MyGvimAutoCommands
    autocmd FocusGained * set transparency=3
    autocmd FocusLost * set transparency=8
  augroup END
endif

" Use visualbell, stop beeping.
set visualbell t_vb=

" Command line height
set cmdheight=2

" No toolbar, No menubar, No scrollbars.
set guioptions-=T
set guioptions-=m
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R

" Full screen.
if has('gui_macvim')
  set fuoptions=maxvert,maxhorz
endif
