# This is related with `~/.CFUserTextEncoding` file.
# See http://developer.apple.com/documentation/CoreFoundation/Reference/CFStringRef/Reference/reference.html

local -r uid=$(printf '0x%X' $(id -u))
local command

for command in pbcopy pbpaste; do
  if which $command >/dev/null 2>&1; then
    alias $command="__CF_USER_TEXT_ENCODING=${uid}:0x8000100:14 $command"
  fi
done
