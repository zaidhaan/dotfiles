#!/usr/bin/env bash

running=$(pidof spotify)
if [ "$running" != "" ]; then
    artist="$(playerctl -p spotify metadata artist)"
    song=$(playerctl -p spotify metadata title | cut -c 1-60)

    if [ ${#song} -eq 60 ]; then
        song="${song}..."
    fi

    echo -n "$artist · $song"
fi
