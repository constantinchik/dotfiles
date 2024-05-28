#!/bin/bash

echo "Installing Visual Studio Code extensions..."
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
EXTENSIONS=$(cat "$SCRIPT_DIR/extensions.txt")
for EXT in $EXTENSIONS
do
    codium --install-extension $EXT
done

# TO EXPORT THE EXTENSIONS RUN:
# codium --list-extensions
