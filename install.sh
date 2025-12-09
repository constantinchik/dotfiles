#!/bin/bash

# Main install script - detects OS and runs appropriate installer
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

echo "==================================="
echo "       Dotfiles Installation       "
echo "==================================="

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected: Linux"
    "$SCRIPT_DIR/install-linux.sh"
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
