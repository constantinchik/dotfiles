#!/bin/bash

if ! command -v claude &> /dev/null; then
    echo "Claude Code CLI ('claude') not found. Skipping plugin installation."
    exit 0
fi

echo "Installing Claude Code plugins..."
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

while IFS= read -r PLUGIN || [ -n "$PLUGIN" ]; do
    # Skip empty lines and comments
    [[ -z "$PLUGIN" || "$PLUGIN" == \#* ]] && continue
    echo "  Installing $PLUGIN..."
    claude plugin install "$PLUGIN" 2>/dev/null || echo "  Already installed: $PLUGIN"
done < "$SCRIPT_DIR/plugins.txt"

# TO EXPORT INSTALLED PLUGINS RUN:
# claude plugin list
