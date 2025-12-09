#!/bin/bash
# Install and configure pyprland for Hyprland
# Idempotent: safe to run multiple times

set -euo pipefail

PYPRLAND_CONFIG="$HOME/.config/hypr/pyprland.toml"

notify_error() {
    notify-send -u critical "install-pyprland" "$1" 2>/dev/null || echo "ERROR: $1" >&2
    return 1
}

notify_info() {
    notify-send "install-pyprland" "$1" 2>/dev/null || echo "INFO: $1"
}

echo "Configuring pyprland..."

# Check if pyprland is installed
if ! command -v pypr &>/dev/null; then
    echo "pyprland not installed, skipping configuration"
    exit 0
fi

# Create pyprland config
mkdir -p "$(dirname "$PYPRLAND_CONFIG")"

cat > "$PYPRLAND_CONFIG" << 'EOF'
[pyprland]
plugins = [
  "workspaces_follow_focus",
  "lost_windows",
]

# Enable workspace focus following
[workspaces_follow_focus]

# Enable lost windows recovery
[lost_windows]
EOF

echo "Created pyprland config at $PYPRLAND_CONFIG"

# Add pyprland autostart to hyprland if not already present
HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
AUTOSTART_LINE="exec-once = sh -c 'command -v pypr >/dev/null && uwsm-app -- pypr'"

if [[ -f "$HYPRLAND_CONF" ]]; then
    if ! grep -qF "pypr" "$HYPRLAND_CONF"; then
        echo "" >> "$HYPRLAND_CONF"
        echo "# Pyprland autostart" >> "$HYPRLAND_CONF"
        echo "$AUTOSTART_LINE" >> "$HYPRLAND_CONF"
        echo "Added pyprland autostart to hyprland.conf"
    else
        echo "pyprland autostart already configured"
    fi
fi

notify_info "pyprland configuration complete"
echo "pyprland configuration complete"
