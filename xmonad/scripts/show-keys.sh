#!/usr/bin/env bash

# TODO: this is ugly, needs to be made better
# TODO: reconcile with ezconfig changes

# from on https://wiki.haskell.org/Xmonad/General_xmonad.hs_config_tips
fgCol=green4
bgCol=black
titleCol=green4
commentCol=slateblue
keyCol=green2
XCol=orange3
( echo "   ^fg($titleCol) ----------- keys -----------^fg()";
  sed -n '/^myKeys/,/^--/p' $XDG_CONFIG_HOME/xmonad/xmonad.hs \
    | grep -E 'xK_|eys' \
    | sed -e 's/\( *--\)\(.*eys*\)/\1^fg('$commentCol')\2^fg()/' \
          -e 's/((\(.*xK_.*\)), *\(.*\))/^fg('$keyCol')\1^fg(), ^fg('$XCol')\2^fg()/'
  echo '^togglecollapse()';
  echo '^scrollhome()' ) | dzen2 -fg $fgCol -bg $bgCol -x 700 -y 36 -l 22 -ta l -w 900 -p
