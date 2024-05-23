#!/bin/bash

# Determine the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Function to set the default shell to Homebrew's Zsh if it's not already set
set_default_shell_to_brew_zsh() {
    echo "Checking if default shell needs to be set to Homebrew's Zsh..."
    BREW_ZSH=$(brew --prefix)/bin/zsh
    CURRENT_SHELL=$(dscl . -read ~/ UserShell | awk '{print $2}')

    if [ "$CURRENT_SHELL" != "$BREW_ZSH" ]; then
        echo "Default shell is not Homebrew's Zsh. Setting it now..."

        # Add Homebrew's Zsh to the list of allowed shells if it's not already there
        if ! grep -Fxq "$BREW_ZSH" /etc/shells; then
            echo "$BREW_ZSH" | sudo tee -a /etc/shells
        fi

        # Change the default shell to Homebrew's Zsh
        chsh -s "$BREW_ZSH"

        echo "Default shell set to Homebrew's Zsh."
    else
        echo "Default shell is already Homebrew's Zsh. No changes needed."
    fi
}

# Install packages
"$SCRIPT_DIR/install-packages.sh"

# Detect the operating system and 
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Arch Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # MacOS
    set_default_shell_to_brew_zsh
else
    echo "Unsupported OS"
    exit 1
fi

# Backup configurations
"$SCRIPT_DIR/backup-configs.sh"

echo "Symlinking dotfiles..."
stow . -t ~ --adopt

echo "Done."
