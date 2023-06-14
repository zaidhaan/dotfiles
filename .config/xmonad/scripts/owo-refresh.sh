#!/usr/bin/env bash

set -euo pipefail

# TODO: move to a verification-based mechanism that way we don't need to hold onto backups
# in case something goes wrong

PUBLIC_CDN_LISTING=https://whats-th.is/public-cdn-domains.txt
OWO_DOMAINS="$HOME/.owodomains"

cp "${OWO_DOMAINS}" "${OWO_DOMAINS}.old"

curl -fsSL $PUBLIC_CDN_LISTING | grep -vE '^#' | grep -v ':' | grep '.' | LC_ALL=C sort > ${OWO_DOMAINS}

changes="$(git diff --shortstat "${OWO_DOMAINS}.old" "${OWO_DOMAINS}" ; exit 0)"

changes=${changes:-no changes}

notify-send "Domains updated!" "$changes"
