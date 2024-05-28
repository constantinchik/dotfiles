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
"$SCRIPT_DIR/packages/install-packages.sh"

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

# Install vscode extensions
"$SCRIPT_DIR/vscode/install-extensions.sh"

# Backup configurations
"$SCRIPT_DIR/backup-configs.sh"

# Create required subfolders before STOW
"$SCRIPT_DIR/create-subfolders.sh"

echo "Symlinking dotfiles..."
cd "$SCRIPT_DIR/.."
stow . -t ~ --adopt

echo "Done!"
echo "The config files were symlinked and your files overriden the ones in this repository."
echo "Please check these file changes. If you do not need some of them just run 'git checkout -- <file>' to revert the change in file."
echo "Or 'git checkout .' to revert all changes."
echo "After that do restart your terminal to apply the changes."
