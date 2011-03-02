" フォントの設定
if has('win32')
  set guifont=MeiryoKe_Console:h9:cSHIFTJIS
  "set guifont=MS_Gothic:h9:cSHIFTJIS
  if has('printer')
    set printfont=MS_Mincho:h9:cSHIFTJIS
  endif
elseif has('mac')
  "set guifont=Monaco:h10
  set guifont=Menlo:h12
else
  set guifont=Monospace\ 8
endif
" ウインドウの幅
set columns=120
" ウインドウの高さ
set lines=65
" コマンドラインの高さ(GUI使用時)
set cmdheight=2
" 画面を黒地に白にする
colorscheme twilight
" ツールバーなし、メニューバーなし、スクロールバーなし
set guioptions-=T
set guioptions-=m
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R
" 背景透明
if(exists('&transparency'))
  set transparency=5
endif
" MacVim用
if has("gui_macvim")
  set fuoptions=maxvert,maxhorz
endif

" vim:ts=2:sw=2:expandtab
