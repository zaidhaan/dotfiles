# list only .{7z,zip} files for 7z and sort by date (newest first)
zstyle ':completion:*:7z:*' file-patterns '*.(7z|zip)(.)'
zstyle ':completion:*:*:7z:*' file-sort date

# group options
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*' group-name ''
# zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands

# man
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':completion:*:*:cdr:*:*' menu selection

compdef _pids vmrss

