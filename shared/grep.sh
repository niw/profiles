if which rg >/dev/null 2>&1; then
  alias gr=rg
elif which ag >/dev/null 2>&1; then
  alias gr=ag
elif which ack >/dev/null 2>&1; then
  alias gr=ack
elif which grep >/dev/null 2>&1; then
  if grep --help 2>&1|grep -e '--exclude-dir' >/dev/null 2>&1; then
    alias gr="grep -r -E -n --color=always --exclude='*.svn*' --exclude='*.log*' --exclude='*tmp*' --exclude-dir='**/tmp' --exclude-dir='CVS' --exclude-dir='.svn' --exclude-dir='.git' . -e "
  else
    alias gr="grep -r -E -n --color=always --exclude='*.svn*' --exclude='*.log*' --exclude='*tmp*' . -e "
  fi
fi
