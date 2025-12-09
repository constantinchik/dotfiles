#!/bin/bash
# Install required packages for omarchy overrides
# Idempotent: safe to run multiple times

set -euo pipefail

notify_error() {
    notify-send -u critical "install-packages" "$1" 2>/dev/null || echo "ERROR: $1" >&2
    return 1
}

notify_info() {
    notify-send "install-packages" "$1" 2>/dev/null || echo "INFO: $1"
}

echo "Installing required packages..."

# Packages to install
PACKAGES=(
    "pyprland"      # Hyprland plugin manager
    "nordvpn-bin"   # NordVPN CLI (AUR)
)

# Optional packages (won't fail if not available)
OPTIONAL_PACKAGES=(
    "nordvpn-gui"   # NordVPN GUI (AUR)
)

# Check if yay or paru is available for AUR packages
if command -v yay &>/dev/null; then
    AUR_HELPER="yay"
elif command -v paru &>/dev/null; then
    AUR_HELPER="paru"
else
    notify_error "No AUR helper found (yay or paru required)"
    exit 1
fi

# Install packages
for pkg in "${PACKAGES[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
        echo "Installing $pkg..."
        $AUR_HELPER -S --noconfirm --needed "$pkg" || notify_error "Failed to install $pkg"
    else
        echo "$pkg is already installed"
    fi
done

# Install optional packages (don't fail if unavailable)
for pkg in "${OPTIONAL_PACKAGES[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
        echo "Installing optional package $pkg..."
        $AUR_HELPER -S --noconfirm --needed "$pkg" 2>/dev/null || echo "Optional package $pkg not available, skipping"
    else
        echo "$pkg is already installed"
    fi
done

notify_info "Package installation complete"
echo "Package installation complete"
