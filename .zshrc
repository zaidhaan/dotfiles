# vim:fileencoding=utf-8:foldmethod=marker:foldlevel=0

# Profiling .zshrc with `zprof`
# zmodload zsh/zprof

#: Prompt {{{

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#: }}}

#: Environment variables {{{

export PATH=$PATH:$HOME/.local/bin
export VISUAL=nvim
export EDITOR="$VISUAL"
# omz template: https://github.com/ohmyzsh/ohmyzsh/blob/master/templates/zshrc.zsh-template
export ZSH="$HOME/.oh-my-zsh"

#: }}}

#: Oh-my-zsh {{{

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

#: }}}

#: Key bindings {{{

# vi {c,d,y}s
autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -a cs change-surround
bindkey -a ds delete-surround
bindkey -a ys add-surround
bindkey -M visual S add-surround

# history navigation
bindkey '^P' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search
bindkey '^R' history-incremental-pattern-search-backward # originally: history-incremental-search-backward

# buffer navigation
bindkey '^]' vi-find-next-char
bindkey '^[^]' vi-find-prev-char

# file navigation
bindkey '^Xm' _most_recent_file

# reverse menu complete (shift+tab equivalent)
# ctrl+shift+I, from `showkey -a`. probably not portable
bindkey -M menuselect '^[[105;6u' reverse-menu-complete

# jump to nth arg
after-nth-word() {
    [[ -z $1 ]] && return
    declare -i n
    n="$1"

    zle beginning-of-line
    repeat $n; do
        zle forward-word
    done
}
# this looks terrible
after-first-word() { after-nth-word 1 }
after-second-word() { after-nth-word 2 }
after-third-word() { after-nth-word 3 }
after-fourth-word() { after-nth-word 4 }
zle -N after-first-word
zle -N after-second-word
zle -N after-third-word
zle -N after-fourth-word
bindkey "^X1" after-first-word
bindkey "^X1" after-first-word
bindkey "^X2" after-second-word
bindkey "^X3" after-third-word
bindkey "^X4" after-fourth-word

# {c,d}{a,i}{\',\",\`}
autoload -U select-quoted
zle -N select-quoted
for m in visual viopp; do
    for c in {a,i}{\',\",\`}; do
        bindkey -M $m $c select-quoted
    done
done

# above, for brackets
autoload -U select-bracketed
zle -N select-bracketed
for m in visual viopp; do
    for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
        bindkey -M $m $c select-bracketed
    done
done

# more of these found in /usr/share/zsh/functions/Zle/
autoload -Uz incarg
autoload -Uz insert-files
zle -N incarg
zle -N insert-files
bindkey -M vicmd '^A' incarg
# not used much but occasionally you want to force insert a file
bindkey "^[^F" insert-files

# similar to above, but completion rather than insertion
zle -C complete-files complete-word _generic
zstyle ':completion:complete-files:*' completer _files
bindkey '^X^F' complete-files

zmodload -i zsh/parameter
insert-last-command-output() {
  LBUFFER+="$(eval $history[$((HISTCMD-1))])"
}
zle -N insert-last-command-output
bindkey "^[p" insert-last-command-output

bindkey -s "^[el" '!!^Xa | less'
bindkey -s "^[eh" '!!^Xa | head'
bindkey -s "^[es" 'sudo !!^Xa'
bindkey -s "^[r" ' ranger .^M'

glob-menu-complete() {
  local revert
  revert=0
  if [[ $options[(k)globcomplete] = off ]]; then
    setopt globcomplete
    revert=1
  fi
  zle menu-expand-or-complete
  if [[ $revert -eq 1 ]]; then
    unsetopt globcomplete
  fi
}
zle -N glob-menu-complete
bindkey "^X^I" glob-menu-complete

delete-horizontal-space() {
  emulate -L zsh
  set -o extendedglob
  LBUFFER=${LBUFFER%%[[:blank:]]##}
  RBUFFER=${RBUFFER##[[:blank:]]##}
}

zle -N delete-horizontal-space
bindkey '\e\\' delete-horizontal-space
bindkey -s "^[i" "^Qincognito^J"
bindkey -s "^[ l" "| less"
bindkey -s "^[l" "^Qls^M"
bindkey -s '^[-' '^Qcd -^M'
bindkey -s '^[eg' '| grep '
bindkey -s '^[eeg' '| grep -E '
bindkey -s '^[epg' '| grep -P '
bindkey -s '^[er' '| rg '
# others: awk,tail,sort,wc,xargs,sort

# note: useful with numeric arguments (i.e. ^[1)
autoload -U copy-earlier-word
zle -N copy-earlier-word
bindkey "^[m" copy-earlier-word

zstyle ':completion:history-words:*' list no
zstyle ':completion:history-words:*' menu yes
zstyle ':completion:history-words:*' remove-all-dups yes
bindkey "^[/" _history-complete-older
bindkey "^[," _history-complete-newer
# allow menu completion for history word completion
compdef -K _history_complete_word _history-complete-older menu-select '\e/'
compdef -K _history_complete_word _history-complete-newer menu-select '\e,'

bindkey '^\' accept-and-hold

_sort-by-modified() {
    zstyle ':completion:*' file-sort date
    zle glob-menu-complete
    zstyle -d ':completion:*' file-sort
}
zle -N _sort-by-modified
bindkey '^[^I' _sort-by-modified

_sort-by-size() {
    zstyle ':completion:*' file-sort size reverse
    zstyle ':completion:*' file-list all
    zle glob-menu-complete
    zstyle -d ':completion:*' file-sort
    zstyle -d ':completion:*' file-list
}
zle -N _sort-by-size
bindkey '^[e^Is' _sort-by-size

#: }}}

#: Options {{{

unsetopt promptsp # i forgot what this does lol
unsetopt histverify # no verification after history expansion
setopt histignorespace # dont add to history if beginning with space
setopt cdablevars # if cd arg is not a dir, try to expand with tile

#: }}}

#: Aliases {{{
# https://wiki.archlinux.org/title/Java#Silence_'Picked_up_JDK_JAVA_OPTIONS'_message_on_command_line
SILENT_JAVA_OPTIONS="$JDK_JAVA_OPTIONS"
unset JDK_JAVA_OPTIONS
alias java='java "$SILENT_JAVA_OPTIONS"'

alias vim='nvim'
alias incognito=" unset HISTFILE"
alias ip='ip -color=auto'
alias gswp='git switch -'
alias ghcs="sr -browser=firefox github -type=code"
alias gddp="git diff HEAD^! | delta"
alias config="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
# config config status.showUntrackedFiles no

[ "$TERM" = "xterm-kitty" ] && {
    alias icat="kitty +kitten icat --align left"
    alias hg="kitty +kitten hyperlinked_grep"
    alias ssh="kitty +kitten ssh"
    alias neofetch='neofetch --kitty ~/Downloads/twitterpic.jpg --size 580px'
    function iplot {
        cat <<EOF | gnuplot
        set terminal pngcairo enhanced font 'Fira Sans,10'
        set autoscale
        set samples 1000
        set output '|kitty +kitten icat --align left --stdin yes'
        set object 1 rectangle from screen 0,0 to screen 1,1 fillcolor rgb"#fdf6e3" behind
        plot $@
        set output '/dev/null'
EOF
    }

}

# image viewing in vscode version 1.79+
if ! alias icat 2>&1 >/dev/null; then
    alias icat="img2sixel"
fi

#: }}}

#: Functions {{{

sbb() {
    sudo $SHELL -i -c "$(fc -ln -1)"
}

cheat() {
    curl cheat.sh/tldr:$1
}

wrun() {
    [[ -f $1 && -x $1 ]] || break
    "./$1"
    while inotifywait -e close_write "$1" &> /dev/null; do clear ; "./$1" ; done
}

lsbin () {
    pacman -Ql "$1" | awk '/bin.*[^\/]$/ {print $2}' | xargs -n1 basename | while read file
    do
        which "$file" > /dev/null && echo "$file" || :
    done
}

_lsbin(){
     local -a subcmds
     subcmds=( $(pacman -Q | awk '{print $1}') )
     compadd "${subcmds[@]}"
 }
compdef _lsbin lsbin

gi() {
    curl -sLw "\n" "https://www.toptal.com/developers/gitignore/api/$@"
}

hgrep() {
    history | grep "$@"
}

gls() {
    local DEFAULT_PRETTY_FORMAT="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset"
    PAGER="less -p $1" git log --grep="$1" --pretty="$DEFAULT_PRETTY_FORMAT"
}

gdd() {
    git diff "$@" | delta
}
_git &>/dev/null # initiate to expose _git-* completions
compdef _git-diff gdd

#: }}}

#: Autoloading {{{

autoload zmv

#: }}}

#: Completion {{{

# list only .{7z,zip} files for 7z and sort by date (newest first)
zstyle ':completion:*:7z:*' file-patterns '*.(7z|zip)(.)'
zstyle ':completion:*:*:7z:*' file-sort date

# group options
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*' group-name ''
# zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands

# man
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':completion:*:*:cdr:*:*' menu selection

#: }}}

#: Hashing {{{

# NOTE: careful, since with CDABLE_VARS, this means simply typing a hashed dir name alone
# makes these take effect. so these cannot conflict with command names
hash -d dev="$HOME/dev"
hash -d repos="$HOME/dev/repos"
hash -d omzplugins="$ZSH/custom/plugins"

#: }}}

#: Sourcing {{{

#: Fzf {{{
source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh

# Restore normal backward history search overriden by fzf
bindkey '^R' history-incremental-pattern-search-backward

# Re-bind fzf backward history search (overrides _read_comp)
bindkey '^X^R' fzf-history-widget
#: }}}

# no 'builtin' in `builtin cd -- foo/bar` for aesthetic purposes
source <(which fzf-cd-widget | sed 's/builtin //')

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

eval "$(github-copilot-cli alias -- "$0")"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#: }}}

# zprof
