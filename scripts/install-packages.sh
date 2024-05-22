#!/bin/bash

# Determine the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Function to install Arch Linux packages
install_arch_packages() {
    xargs -a "$SCRIPT_DIR/packages/arch_packages.txt" sudo pacman -S
}

# Function to install macOS packages
install_mac_packages() {
    # Ensure homebrew is installed
    if [[ $(command -v brew) == "" ]]; then
        echo "Installing Hombrew"
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        echo "Updating Homebrew"
        brew update
    fi
    # Add brew taps
    xargs -a "$SCRIPT_DIR/packages/mac_brew_taps.txt" brew tap
    xargs -a "$SCRIPT_DIR/packages/mac_packages.txt" brew install
    xargs -a "$SCRIPT_DIR/packages/mac_cask_packages.txt" brew install --cask
}

# Detect the operating system and install packages
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Arch Linux"
    install_arch_packages
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS"
    install_mac_packages
    set_default_shell_to_brew_zsh
else
    echo "Unsupported OS"
    exit 1
fi

# Install other packages/tools required:
# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

