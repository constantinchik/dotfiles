#!/bin/bash
# Helper script to run Windows Terminal setup from WSL

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo "========================================="
echo "  Windows Terminal Setup (from WSL)"
echo "========================================="
echo ""

# Convert WSL path to Windows path
WIN_SCRIPT_PATH=$(wslpath -w "$SCRIPT_DIR/setup-wsl.ps1")

echo "This will configure your Windows Terminal with:"
echo "  - JetBrainsMono Nerd Font"
echo "  - Rosé Pine color theme"
echo "  - Optimized settings"
echo ""
echo "Running PowerShell script: $WIN_SCRIPT_PATH"
echo ""

# Run PowerShell script from WSL
powershell.exe -ExecutionPolicy Bypass -File "$WIN_SCRIPT_PATH"

echo ""
echo "Done! Please restart Windows Terminal."
