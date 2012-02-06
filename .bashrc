profiles=~/.profiles
source "${profiles}/functions"

## Pre Configurations {{{

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Add PATH and MAN_PATH
init_paths

# Initialize EDITOR
init_editor

# }}}

## Aliases {{{

init_aliases

# }}}

## Bash Basic Configurations {{{

get_prompt() {
	# ANSI Colors
	#            Black Red Green Yellow Blue Magenta Cyan White
	# Foreground    30  31    32     33   34      35   36    37
	# Background    40  41    42     43   44      45   46    47
	local color_table
	color_table=(30 31 32 33 34 35 36 37)

	get_prompt_color_indexes
	local user_color=${color_table[${result[0]}]}
	local host_color=${color_table[${result[1]}]}
	local shlvl_color=${color_table[${result[2]}]}

	# ANSI Escape Squences
	# \e[nn;nn;...;nnm  set styles as nn(s), nn=0 to reset
	# \e[nnnC           move cursor nnn right
	# \e[nnnD           move cursor nnn left
	# In prompt, we should surround non display characters with \[ and \]
	local c="\\[\e[0m\\]"
  	local rprompt="\\[\e[\$((COLUMNS - \$(echo -n \" \\w\$(get_rprompt)\"|wc -c)))C\e[34m\\w\e[0m\$(get_rprompt)\e[\${COLUMNS}D\\]"
	result="$rprompt\\[\e[33m\\]\\A$c \\[\e[${user_color}m\\]\\u$c@\\[\e[${host_color}m\\]\h$c:\\[\e[${shlvl_color}m\\]\W$c \$ "
}

get_rprompt() {
	# lazy evalutaion to content of $PROMPT
	# FIXME any good code?
	eval "echo -n \"$RPROMPT\""
}

get_prompt
PS1=$result

# }}}

## Bash History {{{

HISTSIZE=100000

# ignore duplicates
HISTCONTROL=ignoredups

# ignore fg, bg and history command
HISTIGNORE="fg*:bg*:history*"

# Do not overwrite history file
shopt -u histappend

# }}}

## Scan Additonal Configurations {{{

init_additionl_configration "*.bash"

# }}}

## Post Configurations {{{

if init_rubies; then
	RPROMPT="$RPROMPT \$RUBIES_RUBY_NAME"
fi

# Load Perl local::lib
init_locallib

# Cleanup PATH, MANPATH
clean_paths

# }}}

# vim:ts=4:sw=4:noexpandtab:foldmethod=marker:nowrap:
