# ─── History ───
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# ─── Completion ───
# Home Manager handles zsh completion.

# ─── Key Bindings ───
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ─── Aliases ───
alias ls='ls --color=auto'
alias ..='cd ..'
