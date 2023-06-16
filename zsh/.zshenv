export PATH=$HOME/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export VISUAL=nvim
export EDITOR="$VISUAL"

export $(envsubst < $HOME/.env)

# zsh
export ZDOTDIR=$XDG_CONFIG_HOME/zsh
export ZSH="$XDG_CONFIG_HOME/.oh-my-zsh"
