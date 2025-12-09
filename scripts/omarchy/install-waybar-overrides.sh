#!/bin/bash
# Patch waybar config to add custom modules (NordVPN, Wiremix indicators)
# Idempotent: safe to run multiple times

set -euo pipefail

WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
OMARCHY_PATH="${OMARCHY_PATH:-$HOME/.local/share/omarchy}"

notify_error() {
    notify-send -u critical "install-waybar-overrides" "$1" 2>/dev/null || echo "ERROR: $1" >&2
    return 1
}

notify_info() {
    notify-send "install-waybar-overrides" "$1" 2>/dev/null || echo "INFO: $1"
}

echo "Patching waybar configuration..."

# Check if waybar config exists
if [[ ! -f "$WAYBAR_CONFIG" ]]; then
    notify_error "Waybar config not found at $WAYBAR_CONFIG"
    exit 1
fi

# Backup original config if not already backed up
if [[ ! -f "$WAYBAR_CONFIG.original" ]]; then
    cp "$WAYBAR_CONFIG" "$WAYBAR_CONFIG.original"
    echo "Backed up original waybar config"
fi

# Check if custom modules already added
if grep -q "custom/nordvpn" "$WAYBAR_CONFIG"; then
    echo "Waybar custom modules already configured"
else
    # Add custom modules to modules-right (after bluetooth)
    # Using sed to insert after "bluetooth",
    if grep -q '"bluetooth"' "$WAYBAR_CONFIG"; then
        sed -i 's/"bluetooth",/"bluetooth",\n    "custom\/wiremix",\n    "custom\/nordvpn",/' "$WAYBAR_CONFIG"
        echo "Added wiremix and nordvpn to modules-right"
    else
        echo "Warning: Could not find bluetooth module to insert after"
    fi

    # Replace group/tray-expander with tray if present
    if grep -q '"group/tray-expander"' "$WAYBAR_CONFIG"; then
        sed -i 's/"group\/tray-expander"/"tray"/' "$WAYBAR_CONFIG"
        echo "Replaced tray-expander with tray"
    fi

    # Add custom module definitions before the closing brace
    # First check if they don't already exist
    if ! grep -q '"custom/wiremix"' "$WAYBAR_CONFIG"; then
        # Find the last closing brace and insert before it
        # Using a temp file approach for complex insertion
        cat >> "$WAYBAR_CONFIG.tmp" << EOF
  "custom/wiremix": {
    "on-click": "omarchy-launch-wiremix",
    "exec": "\$OMARCHY_PATH/default/waybar/indicators/wiremix.sh",
    "signal": 9,
    "interval": 5,
    "return-type": "json"
  },
  "custom/nordvpn": {
    "on-click": "nordvpn-gui",
    "exec": "\$OMARCHY_PATH/default/waybar/indicators/nordvpn.sh",
    "signal": 10,
    "interval": 10,
    "return-type": "json"
  },
EOF
        # Insert the modules before the last closing brace
        # This is tricky with jsonc, so we'll use a Python one-liner if available
        if command -v python3 &>/dev/null; then
            python3 << PYTHON
import re
with open("$WAYBAR_CONFIG", 'r') as f:
    content = f.read()

# Check if modules already exist
if '"custom/wiremix"' not in content:
    modules = '''  "custom/wiremix": {
    "on-click": "omarchy-launch-wiremix",
    "exec": "\$OMARCHY_PATH/default/waybar/indicators/wiremix.sh",
    "signal": 9,
    "interval": 5,
    "return-type": "json"
  },
  "custom/nordvpn": {
    "on-click": "nordvpn-gui",
    "exec": "\$OMARCHY_PATH/default/waybar/indicators/nordvpn.sh",
    "signal": 10,
    "interval": 10,
    "return-type": "json"
  },'''

    # Find the last module definition and add after it
    # Look for pattern like "module": { ... },
    last_brace = content.rfind('}')
    if last_brace > 0:
        # Insert before the final closing brace
        content = content[:last_brace] + modules + '\n' + content[last_brace:]

    with open("$WAYBAR_CONFIG", 'w') as f:
        f.write(content)
    print("Added custom module definitions")
PYTHON
        else
            echo "Warning: Python3 not available, skipping module definition insertion"
        fi
        rm -f "$WAYBAR_CONFIG.tmp"
    fi
fi

# Add custom styles if not present
if [[ -f "$WAYBAR_STYLE" ]]; then
    if ! grep -q "#custom-nordvpn" "$WAYBAR_STYLE"; then
        cat >> "$WAYBAR_STYLE" << 'EOF'

/* Custom indicator styles */
#custom-wiremix {
  margin-right: 17px;
}

#custom-nordvpn {
  margin-right: 17px;
}

#custom-nordvpn.connected {
  color: @green;
}

#custom-nordvpn.disconnected {
  color: @foreground;
  opacity: 0.5;
}
EOF
        echo "Added custom styles to waybar"
    else
        echo "Waybar custom styles already present"
    fi
fi

notify_info "Waybar configuration patched"
echo "Waybar configuration complete"
