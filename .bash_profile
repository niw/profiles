profiles=~/.profiles
source "$profiles/functions"

init_basic_environment_variables

if [ -f ~/.bashrc ]; then
	source ~/.bashrc
fi
