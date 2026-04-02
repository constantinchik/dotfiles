#!/bin/bash

if ! command -v code &> /dev/null; then
    echo "VS Code CLI ('code') not found. Skipping extension installation."
    exit 0
fi

echo "Installing Visual Studio Code extensions..."
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
EXTENSIONS=$(cat "$SCRIPT_DIR/extensions.txt")
for EXT in $EXTENSIONS
do
    code --install-extension "$EXT"
done

# TO EXPORT THE EXTENSIONS RUN:
# code --list-extensions
