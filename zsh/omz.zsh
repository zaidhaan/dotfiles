zstyle ':omz:plugins:nvm' lazy yes

bgnotify_threshold=5 # notify after specified seconds
bgnotify_formatted() { # $1=exit_status, $2=command, $3=elapsed_time
  [ $1 -eq 0 ] && title="Zsh" || title="Zsh (fail)"
  bgnotify "$title (took `mtohs $3`)" "$2";
}

# use global history by default instead of local
HISTORY_START_WITH_GLOBAL=true

# annoying that this has to be done
# TODO: remove the tmux plugin and replace with aliases?
ZSH_TMUX_CONFIG="$XDG_CONFIG_HOME/tmux/tmux.conf"

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_HIGHLIGHT_STYLES[comment]='fg=245'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=blue'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=blue'

plugins=(
    git
    zsh-completions
    zsh-syntax-highlighting
    zsh-autosuggestions
    autojump
    archlinux
    nvm
    bgnotify
    per-directory-history
    tmux
)

source $ZSH/oh-my-zsh.sh

