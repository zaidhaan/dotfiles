# vim:fileencoding=utf-8:foldmethod=marker:foldlevel=0

#: Fzf {{{
source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh

# Restore normal backward history search overriden by fzf
bindkey '^R' history-incremental-pattern-search-backward

# Re-bind fzf backward history search (overrides _read_comp)
bindkey '^X^R' fzf-history-widget

# no 'builtin' in `builtin cd -- foo/bar` for aesthetic purposes
source <(which fzf-cd-widget | sed 's/builtin //')

fzf-git-files() {
    FZF_CTRL_T_COMMAND="git ls-files"
    zle fzf-file-widget
}
zle -N fzf-git-files
bindkey '^X^T' fzf-git-files
#: }}}

eval "$(github-copilot-cli alias -- "$0")"

