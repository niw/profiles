if which perl >/dev/null 2>&1 &&
  [[ -s "$HOME/.perl5/lib/perl5/local/lib.pm" ]]; then
  eval $(perl -I"$HOME/.perl5/lib/perl5" -Mlocal::lib="$HOME/.perl5")
fi
