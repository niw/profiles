local command

for command in nvim vim vi nano; do
  if which $command >/dev/null 2>&1; then
    export EDITOR=$command
    return
  fi
done
