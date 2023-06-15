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
    GIT_PAGER="less -p $1" git log --grep="$1" --pretty=sexy
}

gdd() {
    git diff "$@" | delta
}
_git &>/dev/null # initiate to expose _git-* completions
compdef _git-diff gdd

