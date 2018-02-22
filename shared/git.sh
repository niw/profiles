if which git >/dev/null 2>&1; then
  # See also `.gitconfig`
  alias d="git diff"
  alias dc="git diff --cached"
  alias gpodh="git push origin :\$(git symbolic-ref HEAD|cut -d"/" -f3)"
  alias gpoh="git push origin HEAD"
  alias s="git status"
fi
