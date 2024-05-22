#!/bin/bash

# Install Tmux Plugin Manager
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    echo "TPM (Tmux Plugin Manager) is not installed. Installing now..."
    # Command to install TPM
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "TPM installed successfully."
fi
