#!/usr/bin/env bash

set -euo pipefail

export OWO_DOMAIN="REPLACE_ME"

domains=(
    'owo.whats-th.is'
    'awau.moe'
    'bad-me.me'
    'chito.ge'
    'cumz.one'
    'discord.coffee'
    'fk.ci'
    'i-hate.dabbot.org'
    'i-make-memes-with.photobox.pw'
    'i-was-scammed-by.dabbot.org'
    'is-fi.re'
    'o.lol-sa.me'
    'owo.foundation'
    'pantsu.review'
    'pls-fuck.me'
    'quak.ovh'
    'ram-ranch-really.rocks'
    'totally-not.a-sketchy.site'
    'uwu.foundation'
    'uwu.whats-th.is'
    'wolfgirl.party'
    '*.are-la.me'
    '*.are-pretty.sexy'
    '*.are-really.cool'
    '*.bad-me.me'
    '*.banned.today'
    '*.cumz.one'
    '*.get-some.help'
    '*.girlsare.life'
    '*.is-a-bad-waifu.com'
    '*.is-a-good-waifu.com'
    '*.is-a-professional-domain.com'
    '*.is-bad.com'
    '*.is-fi.re'
    '*.is-into.men'
    '*.is-la.me'
    '*.is-pretty.cool'
    '*.is-pretty.sexy'
    '*.is-serious.business'
    '*.is-very.moe'
    '*.might-be-super.fun'
    '*.my-ey.es'
    '*.needs-to-s.top'
    '*.owo.foundation'
    '*.pls-fuck.me'
    '*.ratelimited.today'
    '*.should-be.legal'
    '*.uwu.foundation'
    '*.work-for-an.agency'
)

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