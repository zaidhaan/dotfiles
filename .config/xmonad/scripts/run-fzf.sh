#!/usr/bin/env bash
INFILE="$1"
shift

OUTFILE="$1"
shift

cat $INFILE | fzf --border=rounded --margin=5% --color=dark --height 100% --reverse --info=hidden --header-first --prompt "$@" > $OUTFILE
