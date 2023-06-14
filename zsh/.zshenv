export PATH=$PATH:$HOME/.local/bin
export VISUAL=nvim
export EDITOR="$VISUAL"

export $(envsubst < $HOME/.env)

# zsh
export ZDOTDIR=$XDG_CONFIG_HOME/zsh
export ZSH="$XDG_CONFIG_HOME/.oh-my-zsh"
