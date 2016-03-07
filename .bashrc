# Bash by default executes only this file when it is an interactive shell and
# not login shell.
# The other files like .bash_profile are not executed.

# Pre configuration
# =================

# Source global configuration, if it exists.
if [[ -f /etc/bashrc ]]; then
  source /etc/bashrc
fi

source ~/.profiles/functions/startup-utils

startup-utils-set-paths

# Options
# =======

# If set, bash allows patterns which match no files.
shopt -s nullglob

# If set, the history list is appended to the file named by the value of the
# `HISTFILE` variable when the shell exits, rather than overwriting the file.
shopt -u histappend

# Prompting
# =========

_bashrc-set-prompt() {
  # ANSI Colors
  #            Black Red Green Yellow Blue Magenta Cyan White
  # Foreground    30  31    32     33   34      35   36    37
  # Background    40  41    42     43   44      45   46    47
  #
  # ANSI Escape Squences
  # \e[nn;nn;...;nnm  set styles as nn(s), nn=0 to reset
  # \e[nnnC           move cursor nnn right
  # \e[nnnD           move cursor nnn left
  #
  # In prompt, we should surround non display characters with \[ and \]

  local -a colors
  colors=(30 31 32 33 34 35 36 37)
  readonly colors

  # FIXME: Shuffle colors depends on $HOST, $USER and $SHLV
  local user_color=${colors[1]}
  local host_color=${colors[2]}
  local shlvl_color=${colors[4]}

  # lazy evaluation to content of $PROMPT
  _bashrc-get-rprompt() {
    eval "printf \"$RPROMPT\""
  }

  local -r c="\\[\e[0m\\]"
  local -r rprompt="\\[\e[\$((COLUMNS - \$(echo -n \" \\w\$(_bashrc-get-rprompt)\"|wc -c)))C\e[34m\\w\e[0m\$(_bashrc-get-rprompt)\e[\${COLUMNS}D\\]"

  PS1="$rprompt\\[\e[33m\\]\\A$c \\[\e[${user_color}m\\]\\u$c@\\[\e[${host_color}m\\]\h$c:\\[\e[${shlvl_color}m\\]\W$c \$ "
}
_bashrc-set-prompt
unset -f _bashrc-set-prompt

# History
# =======

# The number of commands to remember in the command history
HISTSIZE=100000

# A colon-separated list of values controlling how commands are saved on the
# history list.
# A value of ignoredups causes lines matching the previous history entry to
# not be saved.
HISTCONTROL=ignoredups

# A colon-separated list of patterns used to decide which command lines should
# be saved on the history list.
HISTIGNORE="fg*:bg*:history*"

# Post configuration
# ==================

if startup-utils-use-rubies; then
  RPROMPT="$RPROMPT \$RUBIES_RUBY_NAME"
fi

if startup-utils-use-javas; then
  RPROMPT="$RPROMPT \$JAVAS_JAVA_VERSION"
fi

startup-utils-source-scripts ~/.profiles/shared ~/.profiles/local

startup-utils-clean-paths
