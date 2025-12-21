#!/bin/bash

# Linux-specific dotfiles installation
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

# Source common scripts
source "$SCRIPT_DIR/scripts/common/colors.sh"
source "$SCRIPT_DIR/scripts/common/arguments.sh"
source "$SCRIPT_DIR/scripts/clean/nvim.sh"

# Parse arguments
parse_args "$@"

echo "Installing Linux dotfiles..."

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

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
fi

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

# Linux-specific packages
LINUX_PACKAGES=(
    zsh-linux
)

# Stow shared packages
for pkg in "${SHARED_PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        echo "  Stowing $pkg..."
        stow -t ~ -R --adopt --override='.*' "$pkg"
    fi
done

# Stow Linux-specific packages
for pkg in "${LINUX_PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        echo "  Stowing $pkg (Linux-specific)..."
        stow -t ~ -R --adopt --override='.*' "$pkg"
    fi
done

# Restore any adopted files
git checkout .

echo "Linux dotfiles installation complete!"
