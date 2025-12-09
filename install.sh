#!/bin/bash

# Main install script - detects OS and runs appropriate installer
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

echo "==================================="
echo "       Dotfiles Installation       "
echo "==================================="

# Check if running on Omarchy
is_omarchy() {
    [ -d "$HOME/.config/omarchy" ]
}

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if is_omarchy; then
        echo "Detected: Omarchy (Linux)"
        "$SCRIPT_DIR/install-omarchy-overrides.sh"
    else
        echo "Detected: Linux"
        "$SCRIPT_DIR/install-linux.sh"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected: macOS"
    "$SCRIPT_DIR/install-macos.sh"
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

echo "==================================="
echo "    Installation Complete!         "
echo "==================================="
echo "Please restart your terminal or run: source ~/.zshrc"
