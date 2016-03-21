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
  local -r time_color_escape="\e[33m"
  local -r whoami_color_escape=$(startup-utils-get-color -e "$(whoami)")
  local -r hostname_color_escape=$(startup-utils-get-color -e "$(hostname)")
  local -r shlvl_color_escape=$(startup-utils-get-color -e $SHLVL)

  # lazy evaluation to content of $PROMPT
  _bashrc-get-rprompt() {
    eval "printf \"$RPROMPT\""
  }

  # ANSI Escape Squences
  # \e[nn;nn;...;nnm  set styles as nn(s), nn=0 to reset
  # \e[nnnC           move cursor nnn right
  # \e[nnnD           move cursor nnn left
  # In prompt, we should surround non display characters with \[ and \]

  local -r reset="\\[\e[0m\\]"
  local -r rprompt="\\[\e[\$((COLUMNS - \$(printf \" \\w\$(_bashrc-get-rprompt)\"|wc -c)))C$shlvl_color_escape\\w$reset\$(_bashrc-get-rprompt)\e[\${COLUMNS}D\\]"

  PS1="$rprompt\\[$time_color_escape\\]\\A$reset \\[$whoami_color_escape\\]\\u$reset@\\[$hostname_color_escape\\]\h$reset:\\[$shlvl_color_escape\\]\W$reset \$ "
}
_bashrc-set-prompt
unset -f _bashrc-set-prompt

# History
# =======

# The number of commands to remember in the command history
# This is about for a year.
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
