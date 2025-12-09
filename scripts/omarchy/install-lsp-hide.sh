#!/bin/bash
# Hide LSP audio plugin entries from application launchers
# Idempotent: safe to run multiple times

set -euo pipefail

OVERRIDE_DIR="$HOME/.local/share/applications"

notify_error() {
    notify-send -u critical "install-lsp-hide" "$1" 2>/dev/null || echo "ERROR: $1" >&2
    return 1
}

notify_info() {
    notify-send "install-lsp-hide" "$1" 2>/dev/null || echo "INFO: $1"
}

echo "Hiding LSP audio plugin entries from launchers..."

# Create override directory if it doesn't exist
mkdir -p "$OVERRIDE_DIR"

# Count hidden entries
hidden_count=0

# Hide all lsp-plugins desktop entries
for desktop_file in /usr/share/applications/in.lsp_plug.*.desktop; do
    if [[ -f "$desktop_file" ]]; then
        basename=$(basename "$desktop_file")
        override_file="$OVERRIDE_DIR/$basename"

        # Only create if not already hidden
        if [[ ! -f "$override_file" ]] || ! grep -q "NoDisplay=true" "$override_file" 2>/dev/null; then
            cat > "$override_file" << EOF
[Desktop Entry]
NoDisplay=true
EOF
            ((hidden_count++))
        fi
    fi
done

if [[ $hidden_count -gt 0 ]]; then
    echo "Hidden $hidden_count LSP plugin entries from launchers"
    notify_info "Hidden $hidden_count LSP plugin entries"
else
    echo "No new LSP plugin entries to hide"
fi

echo "LSP plugin hiding complete"
