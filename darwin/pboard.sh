# This is related with .CFUserTextEncoding file located in same directory
# See http://developer.apple.com/documentation/CoreFoundation/Reference/CFStringRef/Reference/reference.html
uid=`printf '0x%X' \`id -u\``
alias pbcopy="__CF_USER_TEXT_ENCODING=${uid}:0x8000100:14 pbcopy"
alias pbpaste="__CF_USER_TEXT_ENCODING=${uid}:0x8000100:14 pbpaste"
