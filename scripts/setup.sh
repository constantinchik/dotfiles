#!/bin/bash

# Legacy setup script - redirects to new install system
# This script is kept for backwards compatibility

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT="$SCRIPT_DIR/.."

echo "Note: This script has been replaced by the new install system."
echo "Running: ./install.sh"
echo ""

exec "$REPO_ROOT/install.sh"
