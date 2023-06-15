# vim:fileencoding=utf-8:foldmethod=marker:foldlevel=0

# Profiling .zshrc with `zprof`
# zmodload zsh/zprof

# powerlevel10k instant prompt (should be high up for speed)
test -r "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh" && source $_

# oh-my-zsh config, separate from third party
# since this specifically needs to be loaded earlier
source $ZDOTDIR/omz.zsh

# options
source $ZDOTDIR/options.zsh

# key bindings
source $ZDOTDIR/bindings.zsh

# aliases
source $ZDOTDIR/aliases.zsh

# interactive session functions
source $ZDOTDIR/functions.zsh

# functions potentially loadable by scripts
source $ZDOTDIR/scripts.zsh

# completion configuration
source $ZDOTDIR/completion.zsh

# miscellaneous zsh configuration (hashes, etc.)
source $ZDOTDIR/misc.zsh

# external or third party tools (fzf, etc.)
source $ZDOTDIR/thirdparty.zsh

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

test -r ~/.p10k.zsh && source $_

# zprof
