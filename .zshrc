# Zsh by default executes this file after .zprofile when it is an interactive
# shell.

# Pre configuration
# =================

# Add `~/.profiles/function` to fpath for `autoload`.
fpath=(~/.profiles/functions $fpath)

# Remove duplications from `PATH` and `MANPATH`.
typeset -U path PATH
typeset -U manpath MANPATH

# Load all shared `startup-utils` functions.
autoload -Uz startup-utils
startup-utils

startup-utils-set-paths ~/.profiles ~/.profiles/local ~/.local

# Options
# =======
# Option name can be `lowercase` and `under_scored`. In this file, following
# next style.
# * Use `UPPERCASE_UNDER_SCORED`, that format is used in zsh manual.
# * Don't use `setopt NO_OPTION_NAME` instead, use `unsetopt OPTION_NAME`.
# See `zshoptions(1)`.

# Changing Directories
# --------------------

# If a command is issued that can't be executed as a normal command, and the
# command is the name of a directory, perform the cd command to that directory.
setopt AUTO_CD

# Make cd push the old directory onto the directory stack.
setopt AUTO_PUSHD

# Don't print a carriage return just before printing a prompt
# in the line editor.
unsetopt PROMPT_CR

# Expansion and Globbing
# ----------------------

# Perform = filename expansion.
# For example, `=command` to the path of the command.
setopt EQUALS

# When the current word has a glob pattern, do not insert all the words
# resulting from the expansion but generate matches as for completion and cycle
# through them like MENU_COMPLETE.
setopt GLOB_COMPLETE

# All unquoted arguments of the form `anything=expression` appearing after the
# command name have filename expansion performed on expression as if it were a
# parameter assignment.
# For example, `--prefix=/usr...`.
setopt MAGIC_EQUAL_SUBST

# Append a trailing `/` to all directory names resulting from filename
# generation (globbing).
setopt MARK_DIRS

# If a pattern for filename generation has no matches, delete the pattern from
# the argument list instead of reporting an error.
setopt NULL_GLOB

# If numeric filenames are matched by a filename generation pattern, sort the
# filenames numerically rather than lexicographically.
setopt NUMERIC_GLOB_SORT

# History
# -------

# If this is set, zsh sessions will append their history list to the history
# file, rather than replace it.
setopt APPEND_HISTORY

# Save each command's beginning timestamp.
setopt EXTENDED_HISTORY

# Remove command lines from the history list when the first character on the
# line is a space.
setopt HIST_IGNORE_SPACE

# Do not enter command lines into the history list if they are duplicates of
# the previous event.
setopt HIST_IGNORE_DUPS

# Remove the history (fc -l) command from the history list when invoked.
setopt HIST_NO_STORE

# Whenever the user enters a line with history expansion, don't execute the
# line directly
setopt HIST_VERIFY

# This option both imports new commands from the history file, and also causes
# your typed commands to be appended to the history file
setopt SHARE_HISTORY

# Input/Output
# ------------

# Try to correct the spelling of commands.
setopt CORRECT

# If this option is unset, output flow control via start/stop characters
# (usually assigned to ^S/^Q) is disabled in the shell's editor.
unsetopt FLOW_CONTROL

# Print eight bit characters literally in completion lists, etc.
setopt PRINT_EIGHT_BIT

# Job Control
# -----------

# Treat single word simple commands without redirection as candidates for
# resumption of an existing job.
setopt AUTO_RESUME

# Don't report the status of background and suspended jobs before exiting a
# shell with job control
unsetopt CHECK_JOBS

# Don't send the HUP signal to running jobs when the shell exits.
unsetopt HUP

# List jobs in the long format by default.
setopt LONG_LIST_JOBS

# Prompt
# ------

# If set, parameter expansion, command substitution and arithmetic expansion
# are performed in prompts.
setopt PROMPT_SUBST

# Remove any right prompt from display when accepting a command line.
setopt TRANSIENT_RPROMPT

# ZLE
# ---

# No beep on error in ZLE.
unsetopt BEEP

# Prompt
# ======
# See `zshparam(1)` and `zshmisc(1)`.

() {
  local -r whoami_color_name=$(startup-utils-get-color -n "$(whoami)")
  local -r hostname_color_name=$(startup-utils-get-color -n "$(hostname)")
  local -r shlvl_color_name=$(startup-utils-get-color -n $SHLVL)

  PROMPT="%F{yellow}%T%f %F{$whoami_color_name}%n%f@%F{$hostname_color_name}%m%f:%F{$shlvl_color_name}%2~%f %(!.#.$) "
  RPROMPT="%F{$shlvl_color_name}%~%f"
}

# History
# =======
# See `zshparam(1)`.

# Save history on the file.
HISTFILE=$HOME/.zsh_history

# Max history in the memory.
# This is about for a month.
HISTSIZE=100000

# Max history.
# This is about for a year.
SAVEHIST=100000

# ZLE
# ===
# See `zshzle(1)`.

# Use emacs key bindings.
bindkey -e

# Remove directory word by C-w.
autoload -Uz select-word-style
select-word-style bash

# Search history.
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey -M emacs '^p' history-beginning-search-backward-end
bindkey -M emacs '^n' history-beginning-search-forward-end

# Completion
# ==========
# See `zshcompsys(1)`.

autoload -Uz compinit
# Give -C to ignore compinit security check.
# Homebrew creates /usr/local/share/zsh, /usr/local/share/zsh/site-functions/ with g+w,
# which are somehow detected by compinit as insecure directory.
compinit -C

# Colors completions.
zstyle ':completion:*' list-colors ''

# Colors processes for kill completion.
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([%0-9]#)*=0=01;31'

# Ignore case.
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Formatting and messages.
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format $'%{\e[0;31m%}%d%{\e[0m%}'
zstyle ':completion:*:messages' format $'%{\e[0;31m%}%d%{\e[0m%}'
zstyle ':completion:*:warnings' format $'%{\e[0;31m%}No matches for: %d%{\e[0m%}'
zstyle ':completion:*:corrections' format $'%{\e[0;31m%}%d (errors: %e)%{\e[0m%}'
zstyle ':completion:*' group-name ''

# Make the completion menu selectable.
zstyle ':completion:*:default' menu select=1

# Fuzzy match.
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' '+m:{A-Z}={a-z}'

# Hostname completion
() {
  if [[ -f "$HOME/.ssh/known_hosts" ]]; then
    local -a knownhosts
    knownhosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*})
    readonly known_hosts
    zstyle ':completion:*:(ssh|scp|sftp):*' hosts $knownhosts
  fi
}

# Conditional Prompt
# ==================

() {
  _zshrc-precmd-conditional-prompt() {
    psvar[1]="${AWS_PROFILE+ ${AWS_PROFILE}}"
  }
  typeset -gaU precmd_functions
  precmd_functions+=_zshrc-precmd-conditional-prompt
  RPROMPT="${RPROMPT}%F{blue}%1v%f"
}

# Version control systems
# =======================
# See `zshcontrib(1)`.

# Runs only when we have `vcs_info` in `fpath`.
# This is the only way to ensure we can `autoload` function without calling it.
() {
  local -a files
  # Lookup `fpath` to find a readable file named `$1`.
  # See `zshexpn(1)` to understand why this works.
  files=(${^fpath}/vcs_info(Nr))
  readonly files
  # (( expr )) returns 0 if expr is non zero, otherwise 1.
  (( ${#files} ))
} && {
  autoload -Uz vcs_info

  # A list of backends you want to use.
  # Not giving `hg` here, because it scans all parent directories and slow.
  zstyle ':vcs_info:*' enable git cvs svn

  # A list of formats, used when actionformats is not used (which is most of
  # the time).
  zstyle ':vcs_info:*' formats '%s %b'

  # A list of formats, used if there is a special action going on in your
  # current repository.
  zstyle ':vcs_info:*' actionformats '%s %b (%a)'

  # Add `precmd` function to update `RPROMPT`.
  _zshrc-precmd-vcs-info() {
    psvar[2]=""
    LANG=en_US.UTF-8 vcs_info
    [[ -n "$vcs_info_msg_0_" ]] && psvar[2]="$vcs_info_msg_0_"
  }
  typeset -gaU precmd_functions
  precmd_functions+=_zshrc-precmd-vcs-info
  RPROMPT="${RPROMPT}%2(V. %F{green}%2v%f.)"
}

# Post configuration
# ==================

if startup-utils-use-rubies; then
  # `RUBIES_RUBY_NAME` is always non-empty.
  RPROMPT="${RPROMPT} %F{red}\${RUBIES_RUBY_NAME}%f"
fi

startup-utils-source-scripts ~/.profiles/shared ~/.profiles/local

# Clean up `PATH` and `MANPATH` instead of using `startup-utils-clean-paths`.
# * `N` to filter only existence paths.
# * `-/` to filter only directories following by symbolic links.
# * `W` followed to '^', to remove world writable paths.
# * `M` followed to '^', to remove trailing `/`.
# See `typset -U` in Pre Configuration section.
# See `zshexpn(1)` to understand why this works.
path=(${^path}(N-/^WM))
manpath=(${^manpath}(N-/^M))
