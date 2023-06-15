
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

