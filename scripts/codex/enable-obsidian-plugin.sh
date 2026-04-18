#!/bin/bash

set -euo pipefail

CODEX_CONFIG="${CODEX_CONFIG:-$HOME/.codex/config.toml}"
PLUGIN_SECTION='[plugins."obsidian-vault@constantinchik-dotfiles"]'

mkdir -p "$(dirname "$CODEX_CONFIG")"
touch "$CODEX_CONFIG"

tmp_file=$(mktemp)

awk -v section="$PLUGIN_SECTION" '
    $0 == section {
        in_section = 1
        saw_section = 1
        saw_enabled = 0
        print
        next
    }

    in_section && /^\[/ {
        if (!saw_enabled) {
            print "enabled = true"
        }
        in_section = 0
        saw_enabled = 0
    }

    in_section && /^enabled[[:space:]]*=/ {
        print "enabled = true"
        saw_enabled = 1
        next
    }

    { print }

    END {
        if (in_section && !saw_enabled) {
            print "enabled = true"
        }
        if (!saw_section) {
            print ""
            print section
            print "enabled = true"
        }
    }
' "$CODEX_CONFIG" > "$tmp_file"

mv "$tmp_file" "$CODEX_CONFIG"

echo "Enabled Codex plugin: obsidian-vault@constantinchik-dotfiles"
