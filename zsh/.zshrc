# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab
zinit light chrissicool/zsh-256color

# Add plugins from oh-my-zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Vim mode
zinit light softmoth/zsh-vim-mode

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Helpful aliases
alias  l='eza -lh  --icons=auto' # long list
alias ls='eza -1   --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias lg='lazygit'

# Keybindings
bindkey -v
bindkey '^y' autosuggest-accept
bindkey '^p' history-search-backward # only show result that match the current input as prefix
bindkey '^n' history-search-forward  # only show result that match the current input as prefix

# History
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase # erase duplicates in history
setopt appendhistory # append history to the history file
setopt sharehistory # share history between all sessions
setopt hist_ignore_space # ignore commands that start with a space
setopt hist_ignore_all_dups # ignore all duplicates in history
setopt hist_save_no_dups # do not save duplicates in history
setopt hist_ignore_dups # ignore duplicates in history
setopt hist_find_no_dups # do not display duplicates when searching history

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # case-insensitive completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # color completion TODO: Does not work
zstyle ':completion:*' menu no # no menu selection, use fzf instead
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons=auto $realpath'

# Shell integrations
# FZF - fuzzy finder (Ctrl+R for history, Ctrl+T for files)
if [ -f ~/.fzf.zsh ]; then
    # Use git-installed fzf (newer version) - add to PATH first
    export PATH="$HOME/.fzf/bin:$PATH"
    source ~/.fzf.zsh
elif command -v fzf &> /dev/null; then
    # Try modern fzf --zsh flag (macOS Homebrew)
    if fzf --help 2>/dev/null | grep -q -- '--zsh'; then
        eval "$(fzf --zsh)"
    fi
else
    echo "Warning: fzf not installed. Install with: brew install fzf (macOS) or apt install fzf (Debian/Ubuntu)"
fi

# Zoxide - smart cd replacement
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init --cmd cd zsh)"
else
    echo "Warning: zoxide not installed. Install with: brew install zoxide (macOS) or apt install zoxide (Debian/Ubuntu)"
fi

# --- setup fzf theme ---
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Source OS-specific configuration
[[ -f ~/.zshrc.os ]] && source ~/.zshrc.os

# Import secrets and local overrides
for file in ~/.zshrc.{secrets,local}; do
    [[ -f "$file" ]] && source "$file"
done

# Verify critical environment variables
check_env_vars() {
    local missing=()
    local vars=("GITHUB_PERSONAL_ACCESS_TOKEN")

    for var in "${vars[@]}"; do
        [[ -z "${(P)var}" ]] && missing+=("$var")
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Warning: Missing environment variables claude desktop might not work: ${missing[*]}"
        echo "   Create ~/.zshrc.secrets from ~/.zshrc.secrets.template"
    fi
}

# Run check on shell startup (optional)
check_env_vars
