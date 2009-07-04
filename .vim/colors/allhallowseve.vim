" Maintainer: Toshitaka Miura<eric@dflatt.org>
" Last Change: 6 May 2007

set background=dark
hi clear
if exists("syntax_on")
    syntax reset
endif

let g:colors_name="allhallowseve"

hi Normal         guifg=#FFFFFF           guibg=#000000
hi Cursor         guifg=#FFFFFF           guibg=#999933
hi CursorIM       guifg=#FFFFFF           guibg=#5F5A60
hi Directory      guifg=#0000FF           guibg=#000000
hi ErrorMsg       guifg=#000000           guibg=#FFFF33
hi VertSplit      guifg=#AC885B           guibg=#FFFFFF
hi Folded         guifg=#F9EE98           guibg=#494949
hi IncSearch      guifg=#000000           guibg=#CF6A4C
hi LineNr         guifg=#FFD700           guibg=#000000
hi ModeMsg        guifg=#CF7D34           guibg=#E9C062
hi MoreMsg        guifg=#CF7D34           guibg=#E9C062
hi NonText        guifg=#D2A8A1           guibg=#000000
hi Question       guifg=#7587A6           guibg=#0E2231
hi Search         guifg=#420E09           guibg=#CF6A4C
hi SpecialKey     guifg=#CF7D34           guibg=#141414
hi StatusLine     guifg=#FFFFFF           guibg=#999933 gui=none
hi StatusLineNC   guifg=#696969           guibg=#ffffff
hi Title          guifg=#000000           guibg=#ffff33 gui=none
hi Visual         guifg=#f5f5f5           guibg=#996699
hi WarningMsg     guifg=#CF6A4C           guibg=#420E09
hi WildMenu       guifg=#AFC4DB           guibg=#0E2231

"Syntax hilight groups#####################################

" purple
hi Comment        guifg=#9933CC
" blue
hi Constant       guifg=#0099FF
" green
hi String         guifg=#66CC33
" white
hi Character      guifg=#FFFFFF
hi Number         guifg=#0099FF
hi Boolean        guifg=#0099FF
hi Float          guifg=#0099FF

" usui green Rubyのクラス名などがこの色
hi Identifier     guifg=#CCFF66
" white
hi Function       guifg=#FFFFFF
" ---- Statement Section
" 肌色, hiなどがこの色
"hi Statement      guifg=#ff9966
hi Statement      guifg=#CC6600
" unlessなど
" orange
hi Conditional    guifg=#CC6600
hi Repeat         guifg=#CC6600
hi Label          guifg=#CC6600
hi Operator       guifg=#CC6600
hi Keyword        guifg=#CC6600
hi Exception      guifg=#CC6600
" ---- PreProc Section
hi PreProc        guifg=#CC6600
hi Include        guifg=#CC6600
hi Define         guifg=#CC6600
hi Macro          guifg=#CC6600
hi PreCondit      guifg=#CC6600
" ---- Type Section
" class, endなど
hi Type           guifg=#FFFFFF gui=italic
hi StorageClass   guifg=#FFFFFF 
hi Structure      guifg=#FFFFFF gui=italic
hi Typedef        guifg=#FFFFFF gui=italic
" ---- Special Section
" sqlのtableとかDEFAULTとか
hi Special        guifg=#CC6600
hi SpecialChar    guifg=#FFFFFF
hi Tag            guifg=#FFFFFF
" "や'など = green
"hi Delimiter      guifg=#339999
hi Delimiter      guifg=#66CC33
hi SpecialComment guifg=#FFFFFF
hi Debug          guifg=#FFFFFF
" kokomade edited.#########################
hi Underlined     guifg=#Cf6A4C
hi Ignore         guifg=#FFFFFF
hi Error          guifg=#000000    guibg=#FFFF33
hi Todo           guifg=#7587A6    guibg=#0E2231
hi Pmenu          guifg=#141414    guibg=#CDA869
hi PmenuSel       guifg=#F8F8F8    guibg=#9B703F
hi PmenuSbar      guibg=#DAEFA3
hi PmenuThumb     guifg=#8F9D6A
