#!/bin/bash
# Fix Xbox controller USB support by removing xpad blacklist
# Allows xpad (USB) and xpadneo (Bluetooth) to coexist
# Idempotent: safe to run multiple times

set -euo pipefail

notify_error() {
    notify-send -u critical "install-xbox-support" "$1" 2>/dev/null || echo "ERROR: $1" >&2
    return 1
}

notify_info() {
    notify-send "install-xbox-support" "$1" 2>/dev/null || echo "INFO: $1"
}

echo "Configuring Xbox controller USB support..."

# Remove xpad blacklist created by xpadneo package
if [[ -f /etc/modprobe.d/blacklist-xpad.conf ]]; then
    echo "Removing xpad blacklist to enable USB Xbox controllers..."
    sudo rm /etc/modprobe.d/blacklist-xpad.conf || notify_error "Failed to remove xpad blacklist"
else
    echo "xpad blacklist not present"
fi

# Ensure xpad module loads on boot
if [[ ! -f /etc/modules-load.d/xpad.conf ]]; then
    echo "Creating xpad module load configuration..."
    echo "xpad" | sudo tee /etc/modules-load.d/xpad.conf > /dev/null || notify_error "Failed to create xpad load config"
else
    echo "xpad module load config already exists"
fi

# Load xpad module immediately if not loaded
if ! lsmod | grep -q "^xpad "; then
    echo "Loading xpad module..."
    sudo modprobe xpad 2>/dev/null || echo "Could not load xpad module (may not be needed)"
else
    echo "xpad module already loaded"
fi

notify_info "Xbox USB controller support enabled"
echo "Xbox USB controller support configured"
