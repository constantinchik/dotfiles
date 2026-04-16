#!/bin/bash
set -euo pipefail

# Determine the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
COMMON_DIR="$SCRIPT_DIR/../common"

# Source common scripts
source "$COMMON_DIR/colors.sh"
source "$COMMON_DIR/arguments.sh"

# Version pins — update these as needed
NVM_VERSION="v0.39.7"
NODE_VERSION="22"
PYTHON_VERSION="3.12.7"
RUBY_VERSION="3.3.1"

echo "Installing packages..."

# Function to install Linux packages
install_linux_packages() {
    if [ -x "$(command -v pacman)" ]; then
      xargs -a "$SCRIPT_DIR/arch_pacman_packages.txt" sudo pacman -S --needed --noconfirm
      xargs -a "$SCRIPT_DIR/arch_yay_packages.txt" yay -S --needed --noconfirm
    elif [ -x "$(command -v apt-get)" ]; then
      sudo add-apt-repository ppa:aos1/diff-so-fancy
      xargs -a "$SCRIPT_DIR/apt_packages.txt" sudo apt-get install -y
      # pyenv:
      curl https://pyenv.run | bash || { echo "Failed to install pyenv"; exit 1; }
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
    # Check if Homebrew is already installed (check directly — brew may not be in PATH on a fresh machine)
    if command -v brew &> /dev/null || [ -x /opt/homebrew/bin/brew ]; then
        # Ensure brew is in PATH for subsequent commands
        if ! command -v brew &> /dev/null; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
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

# Setup Python via pyenv (needed for Mason to install black, isort, pylint, debugpy)
if command -v pyenv &> /dev/null; then
    eval "$(pyenv init -)"
    echo "Installing Python ${PYTHON_VERSION} via pyenv..."
    pyenv install --skip-existing "$PYTHON_VERSION"
    pyenv global "$PYTHON_VERSION"
    pip install --upgrade pip
fi

# Install other packages/tools required:

# Install nvm if not exists
if ! command -v nvm &> /dev/null; then
    echo "Installing nvm:"
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash || { echo "Failed to install nvm"; exit 1; }
    # Source nvm so it's available in this session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    if confirm_prompt "Do you want to setup NodeJS ${NODE_VERSION} via NVM?"; then
        echo "Installing NodeJS ${NODE_VERSION} via NVM..."
        nvm install "$NODE_VERSION"
        nvm alias default "$NODE_VERSION"
        # Enable pnpm
        corepack enable pnpm
    else
        echo "Skipped. NodeJS was not installed."
    fi
else
    echo "nvm already exists. Skipping installation."
fi
echo ""

# Tmux Plugin Manager
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    echo "TPM (Tmux Plugin Manager) is not installed. Installing now..."
    # Command to install TPM
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || { echo "Failed to clone TPM"; exit 1; }
    echo "TPM installed successfully."
fi

# Install diff-so-fancy as a git pager
git config --global core.pager "diff-so-fancy | less --tabs=4 -RF"
git config --global interactive.diffFilter "diff-so-fancy --patch"
git config --global diff-so-fancy.rulerWidth 80

# Install RVM (Ruby Version Manager)
curl -sSL https://get.rvm.io | bash || { echo "Failed to install RVM"; exit 1; }
# Source rvm so it's available in this session (disable nounset — rvm scripts use unbound variables)
set +u
[ -s "$HOME/.rvm/scripts/rvm" ] && \. "$HOME/.rvm/scripts/rvm"
set -u

if confirm_prompt "Do you want to install Ruby ${RUBY_VERSION} via RVM?"; then
    echo "Installing Ruby ${RUBY_VERSION} via RVM..."
    set +u
    rvm install "ruby-${RUBY_VERSION}"
    rvm use "$RUBY_VERSION" --default
    set -u
else
    echo "Skipped. Ruby ${RUBY_VERSION} was not installed."
fi

echo "Installing zinit"
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
