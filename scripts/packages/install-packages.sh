#!/bin/bash

echo "Installing packages..."
# Determine the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Function to install Arch Linux packages
install_arch_packages() {
    xargs -a "$SCRIPT_DIR/arch_pacman_packages.txt" sudo pacman -Syu
    xargs -a "$SCRIPT_DIR/arch_yay_packages.txt" yay -Syu
}

# Function to install macOS packages
install_mac_packages() {
    # Ensure homebrew is installed
    if [[ $(command -v brew) == "" ]]; then
        echo "Installing Hombrew"
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        brew update
    fi
    # Add brew taps
    cat "$SCRIPT_DIR/mac_packages.txt" | xargs brew install
    cat "$SCRIPT_DIR/mac_cask_packages.txt" | xargs brew install --cask

    # Other hacks for MacOS
    # install magick via luarocks
    luarocks --lua-version=5.1 install magick
}

# Detect the operating system and install packages
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Arch Linux"
    install_arch_packages
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS"
    install_mac_packages
else
    echo "Unsupported OS"
    exit 1
fi

# Install other packages/tools required:
# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
# Prompt for input
read -p "Do you want to setup NodeJS 20 via NVM? (Y/N): " answer
answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')
if [[ "$answer" == "Y" || "$answer" == "YES" ]]; then
    echo "Installing NodeJS 20 via NVM..."
    nvm install 20
    nvm alias default 20
    # Enable pnpm
    corepack enable pnpm
else
    echo "Skipped. NodeJS 20 not installed."
fi

# Tmux Plugin Manager
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    echo "TPM (Tmux Plugin Manager) is not installed. Installing now..."
    # Command to install TPM
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "TPM installed successfully."
fi

# Install diff-so-fancy as a git pager
git config --global core.pager "diff-so-fancy | less --tabs=4 -RF"
git config --global interactive.diffFilter "diff-so-fancy --patch"
git config --global diff-so-fancy.rulerWidth 80

# Install RVM (Ruby Version Manager)
curl -sSL https://get.rvm.io | bash

read -p "Do you want to install Ruby 3.3.1 via RVM? (Y/N): " answer
answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')
if [[ "$answer" == "Y" || "$answer" == "YES" ]]; then
    echo "Installing Ruby 3.3.1 via RVM..."
    rvm install ruby-3.3.1
    rvm use 3.3.1 --default
else
    echo "Skipped. NodeJS 20 not installed."
fi
