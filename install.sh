#!/usr/bin/env bash

ln -sf "$XDG_CONFIG_HOME/zsh/.zshenv" $HOME/
ln -sf "$XDG_CONFIG_HOME/X11/xprofile" $HOME/.xprofile
ln -sf "$XDG_CONFIG_HOME/X11/xresources" $HOME/.Xresources
ln -sf "$XDG_CONFIG_HOME/.env" $HOME/
ln -sf "$XDG_CONFIG_HOME/bin" $HOME/bin
