# ─── History ───
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# ─── Completion ───
# TODO: home-manager's `programs.zsh.enable = true` runs compinit for you.
# Only keep this block if NOT using that module.
autoload -Uz compinit
compinit

# ─── Plugins ───
# TODO: path is Arch/CachyOS-specific — will silently no-op on NixOS.
# Use home-manager's programs.zsh.autosuggestion/syntaxHighlighting/historySubstringSearch instead.
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# ─── Prompt ───
eval "$(starship init zsh)"

# ─── Key Bindings ───
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ─── Aliases ───
alias ls='ls --color=auto'
alias ..='cd ..'
# TODO: pac='sudo pacman' invalid on NixOS — replace with nixos-rebuild/nix-env alias

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
