"{{{ 日本語化とファイルエンコードの自動判別

" 日本語対応のための設定
" 各エンコードを示す文字列のデフォルト値。s:CheckIconvCapabilityを()呼ぶことで
" 実環境に合わせた値に修正される。
let s:enc_cp932 = 'cp932'
let s:enc_eucjp = 'euc-jp'
let s:enc_jisx = 'iso-2022-jp'
let s:enc_utf8 = 'utf-8'

" encodingを決定する
" OSX GUIの場合はUTF-8でを基本とする。
" 環境変数LANGにエンコード指定がある場合、LANGを優先する。
function! s:DetermineEncoding()
  " OSX GUIはUTF-8を基本にする
  if has('gui_running') && has('mac')
    let &encoding = s:enc_utf8
  endif
  " LANG設定があったら上書き
  if $LANG =~# 'euc'
    let &encoding = s:enc_eucjp
  elseif $LANG =~# 'SJIS'
    let &encoding = s:enc_cp932
  elseif $LANG =~# 'UTF-8'
    let &encoding = s:enc_utf8
  endif
endfunction

" 利用しているiconvライブラリの性能を調べる。
" 比較的新しいJISX0213をサポートしているか検査する。euc-jisx0213が定義してい
" る範囲の文字をcp932からeuc-jisx0213へ変換できるかどうかで判断する。
function! s:CheckIconvCapability()
  if !has('iconv') | return | endif
  if iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let s:enc_eucjp = 'euc-jisx0213,euc-jp'
    let s:enc_jisx = 'iso-2022-jp-3'
  else
    let s:enc_eucjp = 'euc-jp'
    let s:enc_jisx = 'iso-2022-jp'
  endif
endfunction

" 'fileencodings'を決定する。
" 利用しているiconvライブラリの性能及び、現在利用している'encoding'の値に応じ
" て、日本語で利用するのに最適な'fileencodings'を設定する。
function! s:DetermineFileencodings()
  if !has('iconv') | return | endif
  let value = ''
  if &encoding ==? 'utf-8'
    " UTF-8環境向けにfileencodingsを設定する
    let value = value. s:enc_jisx. ','. s:enc_cp932. ','. s:enc_eucjp
  elseif &encoding ==? 'cp932'
    " CP932環境向けにfileencodingsを設定する
    let value = value. s:enc_jisx. ','. s:enc_utf8. ','. s:enc_eucjp
  elseif &encoding ==? 'euc-jp' || &encoding ==? 'euc-jisx0213'
    " EUC-JP環境向けにfileencodingsを設定する
    let value = value. s:enc_jisx. ','. s:enc_utf8. ','. s:enc_cp932
  else
    " TODO: 必要ならばその他のエンコード向けの設定をココに追加する
  endif
  if has('guess_encode')
    let value = 'guess,'. value
  endif
  "let value = value. ',ucs-bom,ucs-2le,ucs-2'
  let &fileencodings = value
endfunction

" ファイルを読込む時にトライする文字エンコードの順序を確定する。漢字コード自
" 動判別機能を利用する場合には別途iconv.dllが必要。iconv.dllについては
" README_j.txtを参照。ユーティリティスクリプトを読み込むことで設定される。
set encoding=japan
call s:DetermineEncoding()
set fileencodings=japan
call s:CheckIconvCapability()
call s:DetermineFileencodings()

" □とか○の文字があってもカーソル位置がずれないようにする
set ambiwidth=double

" メッセージを日本語にする (Windowsでは自動的に判断・設定されている)
if !(has('win32') || has('mac')) && has('multi_lang')
  if !exists('$LANG') || $LANG.'X' ==# 'X'
    if !exists('$LC_CTYPE') || $LC_CTYPE.'X' ==# 'X'
      language ctype ja_JP.eucJP
    endif
    if !exists('$LC_MESSAGES') || $LC_MESSAGES.'X' ==# 'X'
      language messages ja_JP.eucJP
    endif
  endif
endif
" 日本語入力用のkeymapの設定例 (コメントアウト)
if has('keymap')
  " ローマ字仮名のkeymap
  "silent! set keymap=japanese
  set iminsert=0 imsearch=0
endif
" 非GUI日本語コンソールを使っている場合の設定
if !has('gui_running') && &encoding != 'cp932' && &term == 'win32'
  set termencoding=cp932
endif
" メニューファイルが存在しない場合は予め'guioptions'を調整しておく
if 1 && !filereadable($VIMRUNTIME . '/menu.vim') && has('gui_running')
  set guioptions&
  set guioptions+=M
endif

"}}}

"{{{ 各種設定

" <CR>だけのファイルを読むように
set fileformats=unix,dos,mac
" 検索時に大文字小文字を無視 (noignorecase:無視しない)
set ignorecase
" 大文字小文字の両方が含まれている場合は大文字小文字を区別
set smartcase
" インクリメンタル検索
set incsearch
" 検索結果はハイライト
set hlsearch
" タブの画面上での幅
set tabstop=4
set shiftwidth=4
" タブをスペースに展開しない (expandtab:展開する)
set noexpandtab
" 自動的にインデントする (noautoindent:インデントしない)
set autoindent
set smartindent
" バックスペースでインデントや改行を削除できるようにする
set backspace=2
" 検索時にファイルの最後まで行ったら最初に戻る (nowrapscan:戻らない)
set wrapscan
" 括弧入力時に対応する括弧を表示 (noshowmatch:表示しない)
set showmatch
" コマンドライン補完するときに強化されたものを使う(参照 :help wildmenu)
set wildmenu
" テキスト挿入中の自動折り返しを日本語に対応させる
set formatoptions&
set formatoptions+=mM
" 日本語整形スクリプト(by. 西岡拓洋さん)用の設定
let format_allow_over_tw = 1  " ぶら下り可能幅
" 行番号を非表示 (number:表示)
set number
" ルーラーを表示 (noruler:非表示)
set ruler
" タブや改行を表示 (list:表示)
set nolist
" どの文字でタブや改行を表示するかを設定
set listchars=tab:>-,extends:<,trail:-,eol:<
" 長い行を折り返して表示 (nowrap:折り返さない)
set wrap
" 常にステータス行を表示 (詳細は:he laststatus)
set laststatus=2
" コマンドラインの高さ (Windows用gvim使用時はgvimrcを編集すること)
set cmdheight=2
" コマンドをステータス行に表示
set showcmd
" タイトルを表示
set title
" モード表示
set showmode
" シンタックスを有効に
syntax on
" 画面を黒地に白にする (次行の先頭の " を削除すれば有効になる)
"colorscheme evening " (Windows用gvim使用時はgvimrcを編集すること)
" ステータスラインを変更、文字コードと改行文字を表示する
set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']['.&ft.']'}%=%l,%c%V%8P
" 編集中の内容を保ったまま別の画面に切替えられるようにする(デフォルトだと一度保存しないと切り替えられない)
set hid
" バックアップファイルを作成しない (次行の先頭の " を削除すれば有効になる)
set nobackup
set noswapfile
" その他の設定
set history=50
" 端末で高速
set ttyfast
" ワイルドカード補完の設定
set wildmode=longest,list,full
" omni保管をシンタックス保管に
"setlocal omnifunc=syntaxcomplete#Complete
" ファイルタイプを有効に
filetype plugin on
"filetype indent on
" プレビューウィンドウの高さを大きめに
set previewheight=40
" カーソルキーとバックスペースで前後の行に移動
set backspace=indent,eol,start
set whichwrap&
set whichwrap+=<,>,[,],h,l

"}}}

"{{{ キーマッピング

" ウィンドウ移動
noremap <C-Down>  <C-W>j
noremap <C-Up>    <C-W>k
noremap <C-Left>  <C-W>h
noremap <C-Right> <C-W>l

" バッファ切り替え
noremap <silent> <F2> :bp<CR>
noremap <silent> <F3> :bn<CR>
noremap <silent> <F5> :make<CR>

" ;でもExコマンド
noremap ; :

" 表示行で移動
noremap j gj
noremap k gk
noremap gj j
noremap gk k

" ハイライト削除
noremap <C-h><C-n> :<C-u>nohlsearch<Enter>

" 最後の変更のあったテキストを選択する
nnoremap gm `[v`]
vnoremap gm :<C-u>normal gc<Enter>
onoremap gm :<C-u>normal gc<Enter>

" .vimrcの即時編集と再読み込み
nnoremap vimrc  :<C-u>edit $MYVIMRC<Enter>
nnoremap source :<C-u>source $MYVIMRC<Enter>

" カーソルの下のキーワードでヘルプを開く
nnoremap help :<C-u>help<Space><C-r><C-w><Enter>
" カーソルの下をGrep -rする (コマンドを参照)
nnoremap gr :<C-u>Gr<Space><C-r><C-w><Enter>

"}}}

" {{{ オートコマンド

" ファイルタイプ
augroup FileTypeRelated
  autocmd!
  autocmd FileType ruby,eruby setlocal tabstop=2 shiftwidth=2 expandtab nowrap
  autocmd BufNewFile,BufRead *.md setlocal filetype=markdown fileencoding=utf-8
  autocmd BufNewFile,BufRead *.as setlocal filetype=actionscript fileencoding=utf-8 tabstop=4 shiftwidth=4 noexpandtab nowrap
  autocmd BufNewFile,BufRead *.rl setlocal filetype=ragel
  autocmd BufNewFile,BufRead *.srt setlocal filetype=srt
  autocmd BufNewFile,BufRead *.haml setlocal filetype=haml
  autocmd BufNewFile,BufRead nginx.conf* setlocal filetype=nginx
  autocmd BufNewFile,BufRead Portfile setlocal filetype=macports
  autocmd BufNewFile,BufRead *.vcf setlocal filetype=vcard
  autocmd BufNewFile,BufRead *.module setlocal filetype=php tabstop=2 shiftwidth=2 expandtab nowrap
  autocmd BufRead grepedit.tmp.* setlocal filetype=grepedit
augroup END

" バイナリ編集
augroup Binary
  autocmd!
  autocmd BufReadPre *.bin let &bin=1
  autocmd BufReadPost *.bin if &bin | silent %!xxd -g 1
  autocmd BufReadPost *.bin setlocal ft=xxd | endif
  autocmd BufWritePre *.bin if &bin | %!xxd -r
  autocmd BufWritePre *.bin endif
  autocmd BufWritePost *.bin if &bin | silent %!xxd -g 1
  autocmd BufWritePost *.bin setlocal nomod | endif
augroup END

augroup Misc
  autocmd!

  " カーソル行をハイライト
  "autocmd WinEnter,BufEnter * setlocal cursorline
  "autocmd WinLeave,BufLeave * setlocal nocursorline

  " ウィンドウのカレントディレクトリをバッファ切り替えで変更
  " :help cmdline-special
  "autocmd BufRead,BufEnter * execute ":lcd " . expand("%:p:h:gs? ?\\\\ ?")

  " vimgrep後にQuickFixを自動で開く
  "autocmd QuickFixCmdPost grep,grepadd,vimgrep,vimgrepadd copen
augroup END

"}}}

"{{{ コマンド

" UTF-8で開き直す
command! Utf8 edit ++enc=utf-8

function! s:GrepWithHilight(cmd, syntax, ...)
  execute a:cmd . " " . a:syntax . join(a:000, " ")
  execute "copen"
  execute "syntax match Underlined '\\v" . a:syntax . "' display containedin=ALL"
endfunction

" Grep -rとハイライト
command! -nargs=* -bang GrepRecursive grep<bang> -r -E -n --exclude='*.svn*' --exclude='*.log*' --exclude='*tmp*' --exclude-dir='CVS' --exclude-dir='.svn' --exclude-dir='.git' . -e <args>
command! -nargs=* Gr call <SID>GrepWithHilight("GrepRecursive!", <f-args>)

"}}}

"{{{ プラグインの設定

" git プラグイン(標準添付)
autocmd FileType gitcommit DiffGitCached

"}}}

"{{{ プラットフォーム依存の設定

" ファイル名に大文字小文字の区別がないシステム用の設定:
" (例: DOS/Windows/MacOS)
if filereadable($VIM . '/vimrc') && filereadable($VIM . '/ViMrC')
  " tagsファイルの重複防止
  set tags=./tags,tags
endif

" コンソール版で環境変数$DISPLAYが設定されていると起動が遅くなる件へ対応
if !has('gui_running') && has('xterm_clipboard')
  set clipboard=exclude:cons\\\|linux\\\|cygwin\\\|rxvt\\\|screen
endif

" プラットホーム依存の特別な設定
" WinではPATHに$VIMが含まれていないときにexeを見つけ出せないので修正
if has('win32') && $PATH !~? '\(^\|;\)' . escape($VIM, '\\') . '\(;\|$\)'
  let $PATH = $VIM . ';' . $PATH
endif

" Macではデフォルトの'iskeyword'がcp932に対応しきれていないので修正
if has('mac')
  set iskeyword=@,48-57,_,128-167,224-235
endif

"}}}

"{{{ ランタイムパス

set runtimepath&

" ~/.vimをランタイムパスに加える (Windows/Cygwin互換用)
if has('win32')
  set runtimepath+=$HOME/.vim
endif

" 追加のラインタイムパス
for s:dir in split(glob($HOME . "/.vim/runtimes/*"))
  if isdirectory(s:dir)
    let &runtimepath = s:dir . "," . &runtimepath
    if isdirectory(s:dir . "/after")
      let &runtimepath = s:dir . "/after" . "," . &runtimepath
    endif

    " 追加の設定ファイルを読み込む
    for s:vimfile in [s:dir . "/.vimrc", s:dir . ".vim"]
      if filereadable(s:vimfile)
        execute "source " . s:vimfile
      endif
    endfor
  endif
endfor

"}}}

" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:nowrap:
