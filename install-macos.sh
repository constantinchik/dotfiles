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

# Clean up broken symlinks that would conflict with stow
cleanup_broken_symlinks() {
    local pkg="$1"
    local pkg_dir="$SCRIPT_DIR/$pkg"

    if [ ! -d "$pkg_dir" ]; then
        return
    fi

    # Find all files/dirs in the package and check for broken symlinks at target
    find "$pkg_dir" -mindepth 1 | while read -r src; do
        # Get the relative path from package dir
        local rel_path="${src#$pkg_dir/}"
        local target="$HOME/$rel_path"

        # Check if target is a broken symlink
        if [ -L "$target" ] && [ ! -e "$target" ]; then
            echo -e "  ${YELLOW}Removing broken symlink:${NC} $target"
            rm "$target"
        fi
    done
}

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
    ghostty
)

# Stow shared packages
for pkg in "${SHARED_PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        cleanup_broken_symlinks "$pkg"
        echo "  Stowing $pkg..."
        stow -t ~ -R --adopt --override='.*' "$pkg"
    fi
done

# Stow macOS-specific packages
for pkg in "${MACOS_PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
        cleanup_broken_symlinks "$pkg"
        echo "  Stowing $pkg (macOS-specific)..."
        stow -t ~ -R --adopt --override='.*' "$pkg"
    fi
done

# Apply macOS settings
if [ "$MACOS_SETTINGS" = true ]; then
    echo "Applying macOS settings..."
    "$SCRIPT_DIR/scripts/macos/set-macos-settings.sh"
elif [ -z "$MACOS_SETTINGS" ]; then
    if confirm_prompt "Apply macOS settings (dock, key repeat, trackpad)?"; then
        "$SCRIPT_DIR/scripts/macos/set-macos-settings.sh"
    fi
fi

# Configure SSH connection to home-server (WSL machine)
configure_home_server_ssh() {
    local SSH_DIR="$HOME/.ssh"
    local SSH_CONFIG="$SSH_DIR/config"
    local WSL_KEY="$SSH_DIR/id_wsl"
    local HOME_SERVER_HOST="192.168.2.100"
    local HOME_SERVER_ALIAS="wsl"
    local HOME_SERVER_USER="const"

    echo ""
    echo "Configuring SSH connection to home-server (WSL)..."

    # Ensure .ssh directory exists
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"

    # Check if private key exists
    if [[ ! -f "$WSL_KEY" ]]; then
        echo ""
        echo "⚠ WSL private key not found at $WSL_KEY"
        echo ""
        echo "On your WSL machine, run: ./scripts/setup-ssh-keys.sh"
        echo "Then copy the displayed private key content to $WSL_KEY"
        echo ""
        read -p "Have you copied the private key to $WSL_KEY? (y/n): " -n 1 -r
        echo ""

        if [[ ! $REPLY =~ ^[Yy]$ ]] || [[ ! -f "$WSL_KEY" ]]; then
            echo "⚠ Skipping SSH configuration. Run this script again after copying the key."
            return 1
        fi
    fi

    # Set correct permissions on the key
    chmod 600 "$WSL_KEY"
    echo "✓ Private key found at $WSL_KEY"

    # Check if SSH config already has WSL entry
    if [[ -f "$SSH_CONFIG" ]] && grep -q "^Host $HOME_SERVER_ALIAS$" "$SSH_CONFIG" 2>/dev/null; then
        echo "✓ SSH config entry for '$HOME_SERVER_ALIAS' already exists"
    else
        # Add SSH config entry
        echo "" >> "$SSH_CONFIG"
        echo "Host $HOME_SERVER_ALIAS" >> "$SSH_CONFIG"
        echo "    HostName $HOME_SERVER_HOST" >> "$SSH_CONFIG"
        echo "    User $HOME_SERVER_USER" >> "$SSH_CONFIG"
        echo "    IdentityFile $WSL_KEY" >> "$SSH_CONFIG"
        echo "✓ Added SSH config entry for '$HOME_SERVER_ALIAS'"
    fi

    # Test connection
    echo ""
    echo "Testing SSH connection to WSL..."
    if ssh -o ConnectTimeout=5 -o BatchMode=yes "$HOME_SERVER_ALIAS" exit 2>/dev/null; then
        echo "✓ SSH connection to WSL works!"
        echo "  Connect with: ssh $HOME_SERVER_ALIAS"
    else
        echo "⚠ SSH connection test failed"
        echo "  Ensure WSL machine is running and SSH server is started"
        echo "  On WSL, run: sudo systemctl restart ssh"
    fi
    echo ""
}

configure_home_server_ssh

echo "macOS dotfiles installation complete!"
