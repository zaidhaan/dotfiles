# Hashes

# NOTE: careful, since with CDABLE_VARS, this means simply typing a hashed dir name alone
# makes these take effect. so these cannot conflict with command names
hash -d dev="$HOME/dev"
hash -d repos="$HOME/dev/repos"
hash -d omzplugins="$ZSH/custom/plugins"

# Autoloads
autoload zmv

