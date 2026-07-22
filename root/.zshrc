HISTDUP=erase
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt appendhistory
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_save_no_dups
setopt sharehistory

bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

zstyle ':completion:*' complete-options true
zstyle ':completion:*' file-list all
zstyle ':completion:*' file-sort dummyvalue
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' use-cache true
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'

export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR="nvim"
export FORCE_HYPERLINK=1

alias gdw=./gradlew
alias ls='ls -la --color'
alias mvw=./mvnw
alias pip=pip3
alias py=python3
alias python=python3
alias vim=nvim
alias v=nvim

export XDG_CONFIG_HOME=$HOME/.config

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust
### End of Zinit's installer chunk
zinit ice depth=1
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# path
typeset -U path
path=(
    $HOME/.local/bin
    $HOME/go/bin
    $HOME/Library/Python/3.13/bin
    $HOME/Library/pnpm
    ${ASDF_DATA_DIR:-$HOME/.asdf}/shims
    $path
)

autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi
zinit cdreplay -q

# fzf
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -l -g ""'
export FZF_CTRL_R_OPTS="--no-preview --height=40%"
export FZF_DEFAULT_OPTS=" \
    --layout=reverse --bind=ctrl-k:up,ctrl-j:down \
    --preview 'bat --style=numbers --color=always {}'"
eval "$(fzf --zsh)"
bindkey '^R' fzf-history-widget

# zoxide
eval "$(zoxide init --cmd c zsh)"

# prompt
setopt prompt_subst
autoload -Uz add-zsh-hook

source "$HOME/scripts/git-prompt.zsh"

PROMPT='%F{blue}%~%f${GIT_PROMPT} %F{green}❯%f '

# ssh
if [[ "$(uname)" == "Darwin" ]]; then
    () {
        if [[ "$(sw_vers -productVersion)" > "12.0" ]]; then
            ssh-add --apple-load-keychain 2>/dev/null
        else
            ssh-add -A 2>/dev/null
        fi
    } &|
fi

# sdkman
export SDKMAN_DIR="$HOME/.sdkman"
sdk() {
    unset -f sdk
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk "$@"
}
sdk version > /dev/null 2>&1 # comment to lazy load sdkman

# nvm
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

function _tab_history_or_complete() {
    if zle autosuggest-accept; then
        return
    fi
    zle history-search-backward
}
zle -N _tab_history_or_complete

bindkey '^O' _tab_history_or_complete
bindkey '^I' expand-or-complete
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward

if [[ -f "$HOME/.env" ]]; then
    export $(cat "$HOME/.env")
fi

# asdf completions
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"

# opencode
export PATH=/home/bdogabriel/.opencode/bin:$PATH
