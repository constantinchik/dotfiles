#!/bin/bash

echo "Installing packages..."
# Determine the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Function to install Linux packages
install_linux_packages() {
    if [ -x "$(command -v pacman)" ]; then
      xargs -a "$SCRIPT_DIR/arch_pacman_packages.txt" sudo pacman -Syu
      xargs -a "$SCRIPT_DIR/arch_yay_packages.txt" yay -Syu
    elif [ -x "$(command -v apt-get)" ]; then
      sudo add-apt-repository ppa:aos1/diff-so-fancy
      xargs -a "$SCRIPT_DIR/apt_packages.txt" sudo apt-get install
      # pyenv:
      curl https://pyenv.run | bash
      # Lazy Git
      LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
      curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
      tar xf lazygit.tar.gz lazygit
      sudo install lazygit -D -t /usr/local/bin/
      rm lazygit.tar.gz
      rm lazygit
    else
      echo "Unsupported package manager..."
      exit 1
    fi
}

# Function to install macOS packages
install_mac_packages() {
    # Check if Homebrew is already installed
    if command -v brew &> /dev/null; then
        echo "Homebrew is already installed."
    else
        echo "Homebrew is not installed. Installing..."
        # Install Homebrew using the official installation script
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Check if the installation was successful
        if [ $? -eq 0 ]; then
            echo "Homebrew installation successful."
            # Add Homebrew to PATH
            echo >> ~/.zprofile
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
            echo "Homebrew environment set."
        else
            echo "Homebrew installation failed."
            exit 1
        fi
    fi
    # Add brew taps
    cat "$SCRIPT_DIR/mac_packages.txt" | xargs brew install
    cat "$SCRIPT_DIR/mac_cask_packages.txt" | xargs brew install --cask
}

# Detect the operating system and install packages
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Linux"
    install_linux_packages
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS"
    install_mac_packages
    # Other hacks for MacOS
    # install magick via luarocks
    luarocks --lua-version=5.1 install magick
else
    echo "Unsupported OS"
    exit 1
fi

# Install other packages/tools required:

# Install nvm if not exists
if ! command -v nvm &> /dev/null; then
then
    echo "Installing nvm:"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    # TODO: Source nvm somehow
    # Prompt for input
    read -p "Do you want to setup NodeJS 22 via NVM? (y/N): " answer
    answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')
    if [[ "$answer" == "Y" || "$answer" == "YES" ]]; then
        echo "Installing NodeJS 22 via NVM..."
        nvm install 22
        nvm alias default 22
        # Enable pnpm
        corepack enable pnpm
    else
        echo "Skipped. NodeJS was not installed."
    fi
else
    echo "nvm already exists. Skipp installing"
fi
echo ""

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
# TODO: Source rvm

read -p "Do you want to install Ruby 3.3.1 via RVM? (y/N): " answer
answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')
if [[ "$answer" == "Y" || "$answer" == "YES" ]]; then
    echo "Installing Ruby 3.3.1 via RVM..."
    rvm install ruby-3.3.1
    rvm use 3.3.1 --default
else
    echo "Skipped. NodeJS 20 not installed."
fi

echo "Installing zinit"
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
