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

# ─── PATH ───
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.spicetify:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# ─── Editor ───
export EDITOR="code-oss"
export VISUAL="code-oss"

# ─── Bun ───
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
