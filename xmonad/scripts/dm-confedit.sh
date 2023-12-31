#!/usr/bin/env bash

CONF_PROMPT='Edit config: '
CONF_TERM=kitty

# all this just because fzf can't read input from args smh
TMP_OUT=$(mktemp -t dm-confedit.XXXXXXXX) || exit 1
TMP_OUT2=$(mktemp -t dm-confedit.XXXXXXXX) || exit 1

DMENU="dmenu -i -l 20 -p"
FMENU="$CONF_TERM $XDG_CONFIG_HOME/xmonad/scripts/run-fzf.sh $TMP_OUT $TMP_OUT2"

CONF_MENU="$DMENU"

CONF_LIST=$(cat <<EOF
alacritty=$XDG_CONFIG_HOME/alacritty/alacritty.yml
kitty=$XDG_CONFIG_HOME/kitty/kitty.conf
xmonad=$XDG_CONFIG_HOME/xmonad/xmonad.hs
xmobar=$XDG_CONFIG_HOME/xmobar/.xmobarrc
ssh=$HOME/.ssh/config
sshd=/etc/ssh/sshd_config
zshrc=$XDG_CONFIG_HOME/zsh/.zshrc
zsh_history=$HOME/.zsh_history
xbindkeys=$XDG_CONFIG_HOME/xbindkeys/config
xinit=$HOME/.xinitrc
git=$XDG_CONFIG_HOME/git/config
nvim [init.vim]=$XDG_CONFIG_HOME/nvim/init.vim
picom=$XDG_CONFIG_HOME/picom/picom.conf
dunst=$XDG_CONFIG_HOME/dunst/dunstrc
dm-confedit=$XDG_CONFIG_HOME/xmonad/scripts/dm-confedit.sh
ranger=$XDG_CONFIG_HOME/ranger/rc.conf
tmux=$XDG_CONFIG_HOME/tmux/tmux.conf
EOF
)

declare -A conf_list_arr
while IFS='=' read -r NAME CONF_PATH; do
    [ -f "$CONF_PATH" ] && conf_list_arr["$NAME"]="$CONF_PATH"
done <<<"$CONF_LIST"

choice=$(printf '%s\n' "${!conf_list_arr[@]}" | sort | tee $TMP_OUT | $CONF_MENU "$CONF_PROMPT")

[ -s $TMP_OUT2 ] && choice="$(cat $TMP_OUT2)"

rm $TMP_OUT
rm $TMP_OUT2

if [ "$choice" ]; then
    cfg="${conf_list_arr["$choice"]}"
    $CONF_TERM "${EDITOR:-vim}" "$cfg"
else
    echo "terminated" && exit 0
fi
