# based on http://devel.aquahill.net/zsh/zshoptions

##
## local variables
##

arch=`uname`
profiles=~/.profiles

##
## configures
##

# editor
export EDITOR=vim
# default language
export LANG=ja_JP.UTF-8
# colors ls
alias ls='ls -p -h --show-control-chars --color=auto'

# major architectures depended on configrations
if [ $(uname | sed 's/\(.*\)_.*/\1/') = 'CYGWIN' ]; then
	arch='cygwin'
elif [ "${arch}" = 'Darwin' ]; then
	arch='darwin'
	unalias ls
	alias ls='ls -hG'
elif [ "${arch}" = 'FreeBSD' ]; then
	arch='freebsd'
	unalias ls
	alias ls='ls -hG'
fi

export PATH=${PATH}:${profiles}/bin

##
## zsh options
##

# viキーバインド
bindkey -v

# emacsキーバインド
#bindkey -e

# 色を使う
autoload -U colors
colors

# プロンプトに色付けする
setopt prompt_subst

# プロンプトにユーザー名、ホスト名、カレントディレクトリを表示
# ルートの場合は名前を色づけ
set -A color_table black red green yellow blue magenta cyan white
user_color=$color_table[$[$(whoami | sum | sed 's/\([0-9]*\) *\([0-9]*\)/\1/') % 7 + 1]]
host_color=$color_table[$[$(hostname | sum | sed 's/\([0-9]*\) *\([0-9]*\)/\1/') % 7 + 1]]
PROMPT='%{$fg[yellow]%}%T%{$reset_color%} [ %(!.%{$fg[red]%}root.%{$fg[${user_color}]%}%n)%{$reset_color%}@%{$fg[${host_color}]%}%m%{$reset_color%}(${arch}):%{$fg[blue]%}%2~%{$reset_color%} ] %(!.#.%%) '

# プロンプトにカレントディレクトリを指定
RPROMPT='[ %~ ]'

# 指定したコマンド名がなく、ディレクトリ名と一致した場合 cd する
setopt auto_cd

# サスペンド中のプロセスと同じコマンド名を実行した場合はリジュームする
setopt auto_resume

# ビープ音を鳴らさないようにする
#setopt no_beep

# {a-c} を a b c に展開する機能を使えるようにする
setopt brace_ccl

# コマンドのスペルチェックをする
setopt correct

# =command を command のパス名に展開する
setopt equals

# ファイル名で #, ~, ^ の 3 文字を正規表現として扱う
setopt extended_glob

# Ctrl+S/Ctrl+Q によるフロー制御を使わないようにする
setopt no_flow_control

# シェルが終了しても裏ジョブに HUP シグナルを送らないようにする
setopt no_hup

# Ctrl+D では終了しないようになる（exit, logout などを使う）
setopt ignore_eof

# 内部コマンド jobs の出力をデフォルトで jobs -l にする
setopt long_list_jobs

# コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる
setopt magic_equal_subst

# ファイル名の展開でディレクトリにマッチした場合末尾に / を付加する
setopt mark_dirs

# 補完候補が複数ある時、一覧表示 (auto_list) しない
setopt no_auto_menu

# 複数のリダイレクトやパイプなど、必要に応じて tee や cat の機能が使われる
setopt multios

# ファイル名の展開で、辞書順ではなく数値的にソートされるようになる
setopt numeric_glob_sort

# 8 ビット目を通すようになり、日本語のファイル名などを見れるようになる
setopt print_eightbit

# 戻り値が 0 以外の場合終了コードを表示する
#setopt print_exit_value

# ディレクトリスタックに同じディレクトリを追加しないようになる
setopt pushd_ignore_dups

# デフォルトの複数行コマンドライン編集ではなく、１行編集モードになる
#setopt single_line_zle

# コマンドラインがどのように展開され実行されたかを表示するようになる
#setopt xtrace

# 文字列末尾に改行コードが無い場合でも表示する
unsetopt promptcr

#コピペの時rpromptを非表示する
setopt transient_rprompt

# cd -[tab] でpushd
setopt auto_pushd

# 終了時に警告を出さないようにする
setopt no_check_jobs

# 先方予測機能
#autoload predict-on
#predict-on

##
## Completion System
##

# コマンドラインオプションを補完
autoload -U compinit
compinit

# 補完中の候補にも色をつける
zstyle ':completion:*' list-colors ''

# add colors to processes for kill completion
zstyle ':completion:*:*:kill:*:processes' command 'ps -axco pid,user,command'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([%0-9]#)*=0=01;31'

# formatting and messages
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format $'%{\e[0;31m%}%d%{\e[0m%}'
zstyle ':completion:*:messages' format $'%{\e[0;31m%}%d%{\e[0m%}'
zstyle ':completion:*:warnings' format $'%{\e[0;31m%}No matches for: %d%{\e[0m%}'
zstyle ':completion:*:corrections' format $'%{\e[0;31m%}%d (errors: %e)%{\e[0m%}'
zstyle ':completion:*' group-name ''

# 補完リストの中を選択可能にする
zstyle ':completion:*:default' menu select=1

# hostname completion
local knownhosts
if [ -f $HOME/.ssh/known_hosts ]; then
	knownhosts=( ${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*} ) 
	zstyle ':completion:*:(ssh|scp|sftp):*' hosts $knownhosts
fi

##
## Alias
##

alias -g V="| vi -v -"
alias -g G="| grep"
alias -g T="| tail"
alias -g H="| head"
alias -g L="| less -r"

alias now="date +%Y%m%d%H%M%S"

alias svndiff="svn diff -x --ignore-all-space -x --ignore-eol-style | vi -v -"
alias svndiffd="svn diff -x --ignore-all-space -x --ignore-eol-style -r \"{\`date -v-1d +%Y%m%d\`}\" | vi -v -"
alias svnst="svn st | grep -v '^[X?]'"

alias grepr="grep -r -E -n --color --exclude='*.svn*' --exclude='*.log*' --exclude='*tmp*' . -e "
alias gr="grep -r -E -n --color --exclude='*.svn*' --exclude='*.log*' --exclude='*tmp*' --exclude-dir='CVS' --exclude-dir='.svn' --exclude-dir='.git' . -e "
alias ge="grepedit"

alias wget="wget -U Mozilla --no-check-certificate"

##
## 履歴
##

# 履歴をファイルに保存する
HISTFILE="${HOME}"/.zsh-history

# メモリ内の履歴の数
HISTSIZE=100000

# 保存される履歴の数
SAVEHIST=1000000

# zsh の開始・終了時刻をヒストリファイルに書き込む
#setopt extended_history

# 複数の zsh を同時に使う時など history ファイルに上書きせず追加する
setopt append_history

# コマンドラインの先頭がスペースで始まる場合ヒストリに追加しない
setopt hist_ignore_space

# ヒストリを呼び出してから実行する間に一旦編集できる状態になる
setopt hist_verify

# history (fc -l) コマンドをヒストリリストから取り除く。
setopt hist_no_store

# シェルのプロセスごとに履歴を共有
setopt share_history

# 履歴ファイルに時刻を記録
setopt extended_history

# 直前と同じコマンドラインはヒストリに追加しない
setopt hist_ignore_dups

# 履歴を直接実行
unsetopt HISTVERIFY

# 履歴検索
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

##
## Keybinds based on http://github.com/kana/config/
##

# to delete characters beyond the starting point of the current insertion.
bindkey -M viins '\C-h' backward-delete-char
bindkey -M viins '\C-w' backward-kill-word
bindkey -M viins '\C-u' backward-kill-line

# undo/redo more than once.
bindkey -M vicmd 'u' undo
bindkey -M vicmd '\C-r' redo

# history
bindkey -M vicmd '/' history-incremental-search-backward
bindkey -M vicmd '?' history-incremental-search-forward
bindkey -M viins '^p' history-beginning-search-backward-end
bindkey -M viins '^n' history-beginning-search-forward-end

# transpose
bindkey -M vicmd '\C-t' transpose-words
bindkey -M viins '\C-t' transpose-words

##
## Scan additonal configurations
##

setopt no_nomatch
for i in "${profiles}" "${profiles}/${arch}"
do
	# Additional PATH enviroment variables
	for f in "${i}"/*.path
	do
		if [ -f "${f}" ]; then
			p=$(sed -e ':a' -e '$!N' -e '$!b a' -e 's/\n/:/g' < "${f}")
			export PATH="${p}:${PATH}"
		fi
	done

	# Additional initialize scripts
	for f in "${i}"/*.zsh
	do
		if [ -f "${f}" ]; then
			source "${f}"
		fi
	done
done

##
## Post configurations
##

# vimがあったらviはvim
if type 'vim' > /dev/null 2>&1; then
	alias vi='vim'
fi

# vim:ts=4:sw=4:noexpandtab:foldmethod=marker:
