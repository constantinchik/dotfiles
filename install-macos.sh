#!/bin/bash

# macOS-specific dotfiles installation
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

echo "Installing macOS dotfiles..."

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
)

# Stow shared packages
for pkg in "${SHARED_PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        echo "  Stowing $pkg..."
        stow -t ~ --adopt "$pkg" 2>/dev/null || stow -t ~ "$pkg"
    fi
done

# Stow macOS-specific packages
for pkg in "${MACOS_PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        echo "  Stowing $pkg (macOS-specific)..."
        stow -t ~ --adopt "$pkg" 2>/dev/null || stow -t ~ "$pkg"
    fi
done

# Restore any adopted files
git checkout .

echo "macOS dotfiles installation complete!"
