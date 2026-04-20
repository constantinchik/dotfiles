#!/bin/bash

set -euo pipefail

CODEX_CONFIG="${CODEX_CONFIG:-$HOME/.codex/config.toml}"
PLUGIN_SECTION='[plugins."obsidian-vault@constantinchik-dotfiles"]'
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)
PLUGIN_SOURCE="$REPO_ROOT/codex/.codex/plugins/obsidian-vault"
PLUGIN_CACHE="$HOME/.codex/plugins/cache/constantinchik-dotfiles/obsidian-vault/0.1.0"
COMMAND_SOURCE="$REPO_ROOT/codex/.codex/commands"
COMMAND_DEST="$HOME/.codex/commands"
SKILL_SOURCE="$REPO_ROOT/codex/.codex/skills/obsidian-note-taker"
SKILL_DEST="$HOME/.codex/skills/obsidian-note-taker"

copy_tree_following_links() {
    local source_dir="$1"
    local dest_dir="$2"

    rm -rf "$dest_dir"
    mkdir -p "$dest_dir"

    if command -v rsync >/dev/null 2>&1; then
        rsync -aL --delete "$source_dir/" "$dest_dir/"
    else
        cp -R -L "$source_dir/." "$dest_dir/"
    fi
}

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

if [ -d "$PLUGIN_SOURCE" ]; then
    copy_tree_following_links "$PLUGIN_SOURCE" "$PLUGIN_CACHE"
    echo "Materialized Codex plugin cache: $PLUGIN_CACHE"
fi

if [ -d "$COMMAND_SOURCE" ]; then
    mkdir -p "$COMMAND_DEST"

    for source_file in "$COMMAND_SOURCE"/*.md; do
        [ -e "$source_file" ] || continue
        dest_file="$COMMAND_DEST/$(basename "$source_file")"
        rm -f "$dest_file"
        cp -L "$source_file" "$dest_file"
    done

    echo "Materialized Codex commands: $COMMAND_DEST"
fi

if [ -d "$SKILL_SOURCE" ]; then
    copy_tree_following_links "$SKILL_SOURCE" "$SKILL_DEST"
    echo "Materialized Codex skill: $SKILL_DEST"
fi
