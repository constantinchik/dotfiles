#!/bin/bash

# Function to install Arch Linux packages
install_arch_packages() {
    xargs -a packages/arch_pacman_packages.txt sudo pacman -S --noconfirm
    xargs -a packages/arch_yay_packages.txt sudo yay -S --noconfirm
}

# Function to install macOS packages
install_mac_packages() {
    xargs -a packages/mac_packages.txt brew install
    xargs -a packages/mac_cask_packages.txt brew install --cask
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

