profiles=~/.profiles
source "${profiles}/functions"

## Pre Configurations {{{

# Add PATH and MAN_PATH
init_paths

## }}}

## Aliases {{{

init_aliases

# pipe aliasa
alias -g V="| vi -v -"
alias -g G="| grep"
alias -g T="| tail"
alias -g H="| head"
alias -g L="| less -r"

## }}}

## Zsh Basic Configurations {{{
## based on http://devel.aquahill.net/zsh/zshoptions

# initialize hook functions array
typeset -ga preexec_functions
typeset -ga precmd_functions

# viキーバインド
#bindkey -v

# emacsキーバインド
bindkey -e

# 色を使う
autoload -Uz colors
colors

# プロンプトに色付けする
setopt prompt_subst

# プロンプトにユーザー名、ホスト名、カレントディレクトリを表示
# ルートの場合は名前を色づけ
get_prompt() {
	local color_table
	color_table=(red green yellow blue magenta cyan white)

	get_prompt_color_indexes
	local user_color=${color_table[${result[1]}]}
	local host_color=${color_table[${result[2]}]}
	local shlvl_color=${color_table[${result[3]}]}

	# NOTE preserve backward compatibility, here we're not using %F and  %f
	# see RPROMPT for vcs_info
	result="%{$fg[yellow]%}%T%{$reset_color%} %{$fg[${user_color}]%}%n%{$reset_color%}@%{$fg[${host_color}]%}%m%{$reset_color%}:%{$fg[${shlvl_color}]%}%2~%{$reset_color%} %(!.#.$) "
}
get_prompt
PROMPT=$result

# プロンプトにカレントディレクトリを指定
RPROMPT="%{$fg[blue]%}%~%{$reset_color%}"

# 指定したコマンド名がなく、ディレクトリ名と一致した場合 cd する
setopt auto_cd

# サスペンド中のプロセスと同じコマンド名を実行した場合はリジュームする
setopt auto_resume

# ビープ音を鳴らさないようにする
setopt no_beep

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
#setopt ignore_eof

# 内部コマンド jobs の出力をデフォルトで jobs -l にする
setopt long_list_jobs

# コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる
setopt magic_equal_subst

# ファイル名の展開でディレクトリにマッチした場合末尾に / を付加する
setopt mark_dirs

# 補完候補が複数ある時、一覧表示 (auto_list) しない
#setopt no_auto_menu

# *で全候補を表示しない
setopt glob_complete

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

# Avoid 'no matches found' error
setopt nullglob

# 先方予測機能
#autoload -Uz predict-on
#predict-on

# C-wでディレクトリごとに消せるようにする
autoload -Uz select-word-style
select-word-style bash

# }}}

## Zsh VCS Info and RPROMPT {{{

if autoload +X vcs_info 2> /dev/null; then
	autoload -Uz vcs_info
	zstyle ':vcs_info:*' enable git cvs svn # hg - slow, it scans all parent directories.
	zstyle ':vcs_info:*' formats '%s:%b'
	zstyle ':vcs_info:*' actionformats '%s:%b (%a)'
	precmd_vcs_info() {
		psvar[1]=""
		LANG=en_US.UTF-8 vcs_info
		[[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
	}
	precmd_functions+=precmd_vcs_info
	RPROMPT="${RPROMPT}%1(V. %F{green}%1v%f.)"
fi

# }}}

## Zsh Completion System {{{

# コマンドラインオプションを補完
autoload -Uz compinit
compinit

# 補完中の候補にも色をつける
zstyle ':completion:*' list-colors ''

# add colors to processes for kill completion
zstyle ':completion:*:*:kill:*:processes' command 'ps -axco pid,user,command'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([%0-9]#)*=0=01;31'

# ignore case
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

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

## }}}

## Zsh History {{{

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
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

## }}}

## Zsh Keybinds {{{
## based on http://github.com/kana/config/

# to delete characters beyond the starting point of the current insertion.
bindkey -M viins '\C-h' backward-delete-char
bindkey -M viins '\C-w' backward-kill-word
bindkey -M viins '\C-u' backward-kill-line

# undo/redo more than once.
bindkey -M vicmd 'u' undo
bindkey -M vicmd '\C-r' redo

# history
# see also 'autoload history-search-end'
bindkey -M vicmd '/' history-incremental-search-backward
bindkey -M vicmd '?' history-incremental-search-forward
bindkey -M viins '^p' history-beginning-search-backward-end
bindkey -M viins '^n' history-beginning-search-forward-end

bindkey -M emacs '^p' history-beginning-search-backward-end
bindkey -M emacs '^n' history-beginning-search-forward-end

# transpose
bindkey -M vicmd '\C-t' transpose-words
bindkey -M viins '\C-t' transpose-words

# }}}

## Zsh Terminal Title Changes {{{

case "${TERM}" in
screen*|ansi*)
	preexec_term_title() {
		print -n "\ek$1\e\\"
	}
	preexec_functions+=preexec_term_title
	precmd_term_title() {
		print -n "\ek$(whoami)@$(hostname -s):$(basename "${PWD}")\e\\"
	}
	precmd_functions+=precmd_term_title
	;;
xterm*)
	preexec_term_title() {
		print -n "\e]0;$1\a"
	}
	preexec_functions+=preexec_term_title
	precmd_term_title() {
		print -n "\e]0;$(basename "${PWD}")\a"
	}
	precmd_functions+=precmd_term_title
	;;
esac

# }}}

## Scan Additonal Configurations {{{

setopt no_nomatch
init_additionl_configration "*.zsh"

# }}}

## Post Configurations {{{

# Load rvm if it exists
# rvm requires 4.3.5
autoload -Uz is-at-least
if is-at-least 4.3.5; then
	if init_rvm; then
		RPROMPT="${RPROMPT} %{$fg[red]%}\${RUBY_VERSION}%{$reset_color%}"
	fi
fi

# Load Perl local::lib
init_locallib

# Cleanup PATH, MANPATH
clean_paths

# }}}

# vim:ts=4:sw=4:noexpandtab:foldmethod=marker:nowrap:
