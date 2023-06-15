zstyle ':omz:plugins:nvm' lazy yes

# notify after specified seconds
bgnotify_threshold=5
function bgnotify_formatted {
  # $1=exit_status, $2=command, $3=elapsed_time
  [ $1 -eq 0 ] && title="Zsh" || title="Zsh (fail)"
  bgnotify "$title (took $3 s)" "$2";
}

# use global history by default instead of local
HISTORY_START_WITH_GLOBAL=true

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

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_HIGHLIGHT_STYLES[comment]='fg=245'

source $ZSH/oh-my-zsh.sh

