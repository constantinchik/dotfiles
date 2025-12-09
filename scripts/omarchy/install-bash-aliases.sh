#!/bin/bash
# Add custom bash aliases to omarchy defaults
# Idempotent: safe to run multiple times

set -euo pipefail

OMARCHY_PATH="${OMARCHY_PATH:-$HOME/.local/share/omarchy}"
ALIASES_FILE="$OMARCHY_PATH/default/bash/aliases"

notify_error() {
    notify-send -u critical "install-bash-aliases" "$1" 2>/dev/null || echo "ERROR: $1" >&2
    return 1
}

notify_info() {
    notify-send "install-bash-aliases" "$1" 2>/dev/null || echo "INFO: $1"
}

echo "Adding custom bash aliases..."

# Check if aliases file exists
if [[ ! -f "$ALIASES_FILE" ]]; then
    echo "Omarchy aliases file not found at $ALIASES_FILE, skipping"
    exit 0
fi

# Custom aliases to add
declare -A CUSTOM_ALIASES=(
    ["lg"]="lazygit"
    ["gst"]="git status"
)

# Add aliases if not present
for alias_name in "${!CUSTOM_ALIASES[@]}"; do
    alias_value="${CUSTOM_ALIASES[$alias_name]}"
    if ! grep -q "^alias $alias_name=" "$ALIASES_FILE"; then
        echo "alias $alias_name='$alias_value'" >> "$ALIASES_FILE"
        echo "Added alias: $alias_name='$alias_value'"
    else
        echo "Alias $alias_name already exists"
    fi
done

# Fix docker alias conflict (d -> ld)
if grep -q "^alias d='docker'" "$ALIASES_FILE"; then
    sed -i "s/^alias d='docker'/alias ld='docker'/" "$ALIASES_FILE"
    echo "Changed docker alias from 'd' to 'ld'"
fi

notify_info "Bash aliases configured"
echo "Bash aliases configuration complete"
