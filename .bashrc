profiles=~/.profiles
source "${profiles}/functions"

## Pre Configurations {{{

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# }}}

## Aliases {{{

init_aliases

# }}}

## Bash Basic Configurations {{{

get_prompt() {
	# Set arch variable
	get_arch
	local arch=$result

	# ANSI Colors: 30 black 31 red 32 green 33 yellow 34 blue 35 magenta 36 cyan 37 white
	local color_table
	color_table=(30 31 32 33 34 35 36 37)

	get_prompt_color_indexes
	local user_color=${color_table[${result[0]}]}
	local host_color=${color_table[${result[1]}]}
	local shlvl_color=${color_table[${result[2]}]}

	# based on http://d.hatena.ne.jp/mrkn/20090121/the_prompt_of_bash
  	local rprompt='\[\e[$[COLUMNS-$(echo -n " \w" | wc -c)]C\e[35m\w\e[0m\e[$[COLUMNS]D\]'
	result="$rprompt\e[33m\\A\e[0m \e[${user_color}m\\u\e[0m@\e[${host_color}m\\h\e[0m(${arch}):\e[${shlvl_color}m\\W\e[0m \$ "
}
get_prompt
PS1=$result

# }}}

## Bash History {{{

HISTSIZE=100000

# }}}

## Scan Additonal Configurations {{{

init_additionl_configration "*.bash"

# }}}

## Post Configurations {{{

init_rvm

# }}}

# vim:ts=4:sw=4:noexpandtab:foldmethod=marker:nowrap:
