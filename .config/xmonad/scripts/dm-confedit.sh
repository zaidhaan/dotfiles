#!/usr/bin/env bash

CONF_PROMPT='Edit config: '
CONF_TERM=kitty

# all this just because fzf can't read input from args smh
TMP_OUT=$(mktemp -t dm-confedit.XXXXXXXX) || exit 1
TMP_OUT2=$(mktemp -t dm-confedit.XXXXXXXX) || exit 1

DMENU="dmenu -i -l 20 -p"
FMENU="$CONF_TERM $HOME/.xmonad/scripts/run-fzf.sh $TMP_OUT $TMP_OUT2"

CONF_MENU="$DMENU"

CONF_LIST=$(cat <<EOF
alacritty=$HOME/alacritty/alacritty.yml
kitty=$HOME/.config/kitty/kitty.conf
xmonad=$HOME/.xmonad/xmonad.hs
xmobar=$HOME/.xmobarrc
ssh=$HOME/.ssh/config
sshd=/etc/ssh/sshd_config
zshrc=$XDG_CONFIG_HOME/zsh/.zshrc
zsh_history=$HOME/.zsh_history
xbindkeys=$XDG_CONFIG_HOME/xbindkeys/config
xinit=$HOME/.xinitrc
vimrc [.vimrc]=$HOME/.vimrc
nvim [init.vim]=$HOME/.config/nvim/init.vim
picom=$HOME/.config/picom/picom.conf
dunst=$HOME/.config/dunst/dunstrc
dm-confedit=$HOME/.xmonad/scripts/dm-confedit.sh
ranger=$HOME/.config/ranger/rc.conf
tmux=$HOME/.tmux.conf
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
