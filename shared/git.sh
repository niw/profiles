if which git >/dev/null 2>&1; then
  alias d="git diff"
  alias dc="git diff --cached"
  alias s="git status"
  alias a="git add"
  alias grf="git remote -v|cut -f1|sort|uniq|xargs -n 1 git fetch"
  alias gb="git symbolic-ref HEAD|cut -d'/' -f3"
  alias gpoh="git push origin HEAD"
  alias gpodh="git push origin :\$(git symbolic-ref HEAD|cut -d"/" -f3)"
fi
