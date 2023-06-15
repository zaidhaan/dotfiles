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
alias config="git --git-dir=$HOME/.dotfiles --work-tree=$XDG_CONFIG_HOME"
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

