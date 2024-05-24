#!/bin/bash

echo "Installing Visual Studio Code extensions..."
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cat "$SCRIPT_DIR/extensions.txt" | xargs codium --install-extension
