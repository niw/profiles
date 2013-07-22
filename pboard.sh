# This is related with .CFUserTextEncoding file located in same directory
# See http://developer.apple.com/documentation/CoreFoundation/Reference/CFStringRef/Reference/reference.html
local uid=`printf '0x%X' \`id -u\``
for i in pbcopy pbpaste; do
  if which $i >/dev/null 2>&1; then
    alias $i="__CF_USER_TEXT_ENCODING=${uid}:0x8000100:14 $i"
  fi
done
