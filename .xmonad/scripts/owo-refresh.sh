#!/usr/bin/env bash

set -euo pipefail

PUBLIC_CDN_LISTING=https://whats-th.is/public-cdn-domains.txt
OWO_DOMAINS="$HOME/.owodomains"

curl -fsSL $PUBLIC_CDN_LISTING | grep -vE '^#' | grep -v ':' | grep '.' | LC_ALL=C sort > ${OWO_DOMAINS}.new

changes="$(git diff --shortstat "${OWO_DOMAINS}" "${OWO_DOMAINS}.new" ; exit 0)"

changes=${changes:-no changes}

mv "${OWO_DOMAINS}.new" "${OWO_DOMAINS}"

notify-send "Domains updated!" "$changes"
