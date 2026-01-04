#!/bin/bash

# macOS-specific dotfiles installation
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

# Source common scripts
source "$SCRIPT_DIR/scripts/common/colors.sh"
source "$SCRIPT_DIR/scripts/common/arguments.sh"
source "$SCRIPT_DIR/scripts/clean/nvim.sh"

# Parse arguments
parse_args "$@"

echo "Installing macOS dotfiles..."

# Clean if requested
if [ "$CLEAN_RUN" = true ]; then
    clean_nvim
fi

# Backup existing configs
echo "Backing up existing configs..."
"$SCRIPT_DIR/scripts/backup-configs.sh"

# Install packages
echo "Installing packages..."
"$SCRIPT_DIR/scripts/packages/install-packages.sh"

# Set Homebrew's zsh as default shell
set_default_shell_to_brew_zsh() {
    BREW_ZSH=$(brew --prefix)/bin/zsh
    CURRENT_SHELL=$(dscl . -read ~/ UserShell | awk '{print $2}')

    if [ "$CURRENT_SHELL" != "$BREW_ZSH" ]; then
        echo "Setting Homebrew's zsh as default shell..."
        if ! grep -Fxq "$BREW_ZSH" /etc/shells; then
            echo "$BREW_ZSH" | sudo tee -a /etc/shells
        fi
        chsh -s "$BREW_ZSH"
    fi
}

set_default_shell_to_brew_zsh

# Create required subfolders
"$SCRIPT_DIR/scripts/create-subfolders.sh"

# Install VS Code extensions
"$SCRIPT_DIR/scripts/vscode/install-extensions.sh"

echo "Stowing dotfiles packages..."

# Shared packages (cross-platform)
SHARED_PACKAGES=(
    zsh
    nvim
    kitty
    lazygit
    tmux
    vscode
    misc
)

# macOS-specific packages
MACOS_PACKAGES=(
    zsh-macos
    yabai
    claude
)

# Stow shared packages
for pkg in "${SHARED_PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        echo "  Stowing $pkg..."
        stow -t ~ -R --adopt --override='.*' "$pkg"
    fi
done

# Stow macOS-specific packages
for pkg in "${MACOS_PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        echo "  Stowing $pkg (macOS-specific)..."
        stow -t ~ -R --adopt --override='.*' "$pkg"
    fi
done

# Restore any adopted files
git checkout .

# Check SSH connection to home-server (WSL machine)
check_home_server_ssh() {
    local SSH_CONFIG="$HOME/.ssh/config"
    local HOME_SERVER_HOST="192.168.2.100"
    local HOME_SERVER_ALIAS="home"

    echo ""
    echo "Checking SSH connection to home-server..."

    # Check if SSH config has home-server entry
    if [[ -f "$SSH_CONFIG" ]] && grep -q "$HOME_SERVER_ALIAS\|$HOME_SERVER_HOST" "$SSH_CONFIG" 2>/dev/null; then
        echo "✓ SSH config entry for home-server found"

        # Test connection (with timeout)
        if ssh -o ConnectTimeout=5 -o BatchMode=yes "$HOME_SERVER_ALIAS" exit 2>/dev/null || \
           ssh -o ConnectTimeout=5 -o BatchMode=yes "$HOME_SERVER_HOST" exit 2>/dev/null; then
            echo "✓ SSH connection to home-server works"
            return 0
        else
            echo "⚠ SSH config exists but connection failed"
            echo "  Ensure home-server is running and keys are configured"
        fi
    else
        echo "⚠ No SSH config entry for home-server"
    fi

    echo ""
    echo "To configure SSH access to home-server (WSL machine):"
    echo ""
    echo "1. Generate an SSH key (if you don't have one):"
    echo "   ssh-keygen -t ed25519 -C \"macbook\""
    echo ""
    echo "2. Add your public key to home-server's authorized_keys:"
    echo "   ssh-copy-id const@$HOME_SERVER_HOST"
    echo ""
    echo "3. Add to ~/.ssh/config:"
    echo "   Host $HOME_SERVER_ALIAS"
    echo "       HostName $HOME_SERVER_HOST"
    echo "       User const"
    echo "       IdentityFile ~/.ssh/id_ed25519"
    echo ""
}

check_home_server_ssh

echo "macOS dotfiles installation complete!"
