#!/usr/bin/env bash

set -euo pipefail

PUBLIC_CDN_LISTING=https://whats-th.is/public-cdn-domains.txt
OWO_DOMAINS="$HOME/.owodomains"

curl -fsSL $PUBLIC_CDN_LISTING | grep -vE '^#' | grep -v ':' | grep '.' | LC_ALL=C sort > ${OWO_DOMAINS}.new

changes="$(git diff --shortstat "${OWO_DOMAINS}" "${OWO_DOMAINS}.new" ; exit 0)"

changes=${changes:-no changes}

if [ "$changes" != "no changes" ]; then
    LINE_CHANGES="$( { git diff -U0 "${OWO_DOMAINS}" "${OWO_DOMAINS}.new"; exit 0; } | grep '^[+-]' | grep -Ev '^(--- a/|\+\+\+ b/)')"
    cat <<EOF | xmessage -file - -buttons yes:0,no:1
Changes detected!

Below are the changes:
$LINE_CHANGES

Do you wish to proceed?
EOF
    if [ $? -eq 0 ]; then
        mv "${OWO_DOMAINS}.new" "${OWO_DOMAINS}"
        notify-send "Domains updated!" "$changes"
        exit 0
    fi
fi

notify-send "No changes made"
