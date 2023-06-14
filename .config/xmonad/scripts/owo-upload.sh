#!/usr/bin/env bash

set -euo pipefail

export OWO_DOMAIN="REPLACE_ME"
export OWO_DOMAINS="$HOME/.owodomains"

if [[ -f $OWO_DOMAINS ]]; then
    # need to do a Schwartzian transform to put wildcards at the end
    readarray -t domains < <(cat $OWO_DOMAINS | sed 's/^*/zzz/' | LC_ALL=C sort | sed 's/^zzz/*/')
else
    domains=('owo.whats-th.is' 'awau.moe')
fi

SELECTION_PROMPT='Select a URL: '
INPUT_PROMPT='Enter a subdomain: '

DMENU="dmenu -i -l 20 -p"
DMENU_INPUT="dmenu -i -p"

SELECTION_MENU="$DMENU"
INPUT_MENU="$DMENU_INPUT"

owo_url=$(maim -s -u | owo -t image/png -n _.png -u -)

# Display domain options
domain=$(printf '%s\n' "${domains[@]}" | $SELECTION_MENU "$SELECTION_PROMPT")

# Prompt for custom subdomain if applicable
if [[ $domain == *'*'* ]]; then
    subdomain=$(: | $INPUT_MENU "$INPUT_PROMPT")
    domain="${domain/'*'/"$subdomain"}"
fi

owo_url="${owo_url/"$OWO_DOMAIN"/"$domain"}"

notify-send "Copied $owo_url!"

echo "$owo_url" | xclip -sel c
