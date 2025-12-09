#!/bin/bash

# Install Omarchy overrides - applies personal dotfiles on top of Omarchy
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
OVERRIDE_SOURCE="source = ~/.config/hypr/omarchy-overrides.conf"

echo "Installing Omarchy overrides..."

# Check if stow is installed, install if missing
if ! command -v stow &> /dev/null; then
    echo "stow not found, installing..."
    sudo pacman -S --noconfirm stow
fi

# Check if Hyprland config exists
if [ ! -f "$HYPRLAND_CONF" ]; then
    echo "Hyprland config not found at $HYPRLAND_CONF"
    echo "Please install omarchy first"
    exit 1
fi

# Stow the omarchy-overrides package first
if [ -d "omarchy-overrides" ]; then
    echo "Stowing omarchy-overrides..."
    stow -t ~ --adopt omarchy-overrides 2>/dev/null || stow -t ~ omarchy-overrides
    git checkout omarchy-overrides 2>/dev/null || true
fi

# Add source line to hyprland.conf if it doesn't exist
  if ! grep -qF "omarchy-overrides.conf" "$HYPRLAND_CONF"; then
      echo "Adding source line to $HYPRLAND_CONF..."
      echo "" >> "$HYPRLAND_CONF"
      echo "# Personal overrides" >> "$HYPRLAND_CONF"
      echo "$OVERRIDE_SOURCE" >> "$HYPRLAND_CONF"
      echo "Source line added successfully."
  else
      echo "Source line already exists in $HYPRLAND_CONF"
  fi

echo "Omarchy overrides installation complete!"
