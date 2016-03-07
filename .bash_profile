# Bash by default executes only this file when it is a login shell, either an
# interactive or a non-interactive shell.
# The other files like .bashrc are not executed.

# Source ~/.bashrc only when it is interactive shell and the file exists.
case "$-" in
  *i*)
    if [[ -f ~/.bashrc ]]; then
      source ~/.bashrc
    fi
    ;;
esac
