#!/bin/bash
# Install custom waybar indicator scripts to omarchy path
# Idempotent: safe to run multiple times

set -euo pipefail

OMARCHY_PATH="${OMARCHY_PATH:-$HOME/.local/share/omarchy}"
INDICATORS_DIR="$OMARCHY_PATH/default/waybar/indicators"

notify_error() {
    notify-send -u critical "install-waybar-indicators" "$1" 2>/dev/null || echo "ERROR: $1" >&2
    return 1
}

notify_info() {
    notify-send "install-waybar-indicators" "$1" 2>/dev/null || echo "INFO: $1"
}

echo "Installing waybar indicator scripts..."

# Create indicators directory
mkdir -p "$INDICATORS_DIR"

# Create NordVPN indicator
cat > "$INDICATORS_DIR/nordvpn.sh" << 'EOF'
#!/bin/bash

# Check if nordvpn is installed
if ! command -v nordvpn &> /dev/null; then
  echo '{"text": "", "tooltip": "NordVPN not installed"}'
  exit 0
fi

# Get NordVPN status
status=$(nordvpn status 2>/dev/null)

if echo "$status" | grep -q "Status: Connected"; then
  # Extract country name
  country=$(echo "$status" | grep "Country:" | awk '{print $2}')
  city=$(echo "$status" | grep "City:" | awk '{print $2}')

  if [ -n "$country" ]; then
    echo "{\"text\": \"󰖂 $country\", \"tooltip\": \"Connected to $city, $country\", \"class\": \"connected\"}"
  else
    echo '{"text": "󰖂", "tooltip": "Connected", "class": "connected"}'
  fi
else
  echo '{"text": "󰖂", "tooltip": "Disconnected", "class": "disconnected"}'
fi
EOF

chmod +x "$INDICATORS_DIR/nordvpn.sh"
echo "Created nordvpn.sh indicator"

# Create Wiremix indicator
cat > "$INDICATORS_DIR/wiremix.sh" << 'EOF'
#!/bin/bash

if pgrep -x "wiremix" >/dev/null; then
  echo '{"text": "", "tooltip": "Wiremix (click to focus)", "class": "active"}'
else
  echo '{"text": "", "tooltip": "Click to open Wiremix"}'
fi
EOF

chmod +x "$INDICATORS_DIR/wiremix.sh"
echo "Created wiremix.sh indicator"

notify_info "Waybar indicators installed"
echo "Waybar indicator scripts installed to $INDICATORS_DIR"
