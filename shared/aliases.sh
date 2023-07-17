local i
local -r arch=$(uname)

if [[ $arch = "Darwin" || $arch = "FreeBSD" ]]; then
  alias ls='ls -hG'
else
  # Without `LC_COLLATE=C`, ls may sort files by `LC_ALL` or `LANG`, which is
  # not listing dot files first.
  alias ls='LC_COLLATE=C ls -p -h --show-control-chars --color=auto'
fi

alias now="date +%Y%m%d%H%M%S"
alias fn="find . -not -ipath '*/tmp/*' -not -ipath '*/.*/*' -name "
alias rand="ruby -ropenssl -e 'print OpenSSL::Digest::SHA1.hexdigest(rand().to_s)'"

for i in $(seq 1 9); do
  alias a$i="awk '{print \$$i}'"
done

if which nvim >/dev/null 2>&1; then
  alias vi=nvim
elif which vim >/dev/null 2>&1; then
  alias vi=vim
fi

if [[ -e /usr/libexec/PlistBuddy ]]; then
  alias pplist='/usr/libexec/PlistBuddy -c print'
fi
