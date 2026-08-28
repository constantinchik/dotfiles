#!/bin/bash

# Install Omarchy overrides - applies personal dotfiles on top of Omarchy
# Idempotent: safe to run multiple times
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

HYPR_DIR="$HOME/.config/hypr"
HYPRLAND_LUA="$HYPR_DIR/hyprland.lua"
# Omarchy ships (and rewrites) these four. Each is reduced to a one-line
# require pointing at hypr/personal/, which Omarchy never touches.
PERSONAL_MODULES=(monitors input bindings looknfeel)
SHELL_JSON_SRC="$SCRIPT_DIR/omarchy-shell/shell.json"
SHELL_JSON_DST="$HOME/.config/omarchy/shell.json"
SCRIPTS_DIR="$SCRIPT_DIR/scripts/omarchy"

# ╔══════════════════════════════════════════════════════════════════════╗
# ║                           HELPER FUNCTIONS                           ║
# ╚══════════════════════════════════════════════════════════════════════╝

notify_error() {
    notify-send -u critical "install-omarchy-overrides" "$1" 2>/dev/null || true
    echo "ERROR: $1" >&2
}

notify_info() {
    notify-send "install-omarchy-overrides" "$1" 2>/dev/null || true
    echo "INFO: $1"
}

notify_success() {
    notify-send -u low "install-omarchy-overrides" "$1" 2>/dev/null || true
    echo "SUCCESS: $1"
}

run_script() {
    local script="$1"
    local name=$(basename "$script" .sh)

    if [[ -x "$script" ]]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Running: $name"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        if ! "$script"; then
            notify_error "Script failed: $name"
            return 1
        fi
    else
        echo "Skipping $name (not executable or not found)"
    fi
}

# ╔══════════════════════════════════════════════════════════════════════╗
# ║                           PREFLIGHT CHECKS                           ║
# ╚══════════════════════════════════════════════════════════════════════╝

echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║              Installing Omarchy Personal Overrides                   ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""

# Check if stow is installed, install if missing
if ! command -v stow &>/dev/null; then
    echo "stow not found, installing..."
    sudo pacman -S --noconfirm stow || { notify_error "Failed to install stow"; exit 1; }
fi

# Check if Hyprland config exists (Omarchy 4 "Quattro" and later use Lua)
if [[ ! -f "$HYPRLAND_LUA" ]]; then
    notify_error "Hyprland config not found at $HYPRLAND_LUA. Omarchy 4+ required."
    exit 1
fi

# ╔══════════════════════════════════════════════════════════════════════╗
# ║                      STOW OMARCHY-OVERRIDES                          ║
# ╚══════════════════════════════════════════════════════════════════════╝

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Stowing omarchy-overrides package"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ -d "omarchy-overrides" ]]; then
    echo "Stowing omarchy-overrides..."
    # Use --adopt to handle existing files, then restore from git
    stow -t ~ --adopt omarchy-overrides 2>/dev/null || stow -t ~ omarchy-overrides
    git checkout omarchy-overrides 2>/dev/null || true
    echo "omarchy-overrides stowed successfully"
else
    notify_error "omarchy-overrides directory not found"
    exit 1
fi

# ╔══════════════════════════════════════════════════════════════════════╗
# ║                     STOW PERSONAL CONFIGS                            ║
# ╚══════════════════════════════════════════════════════════════════════╝

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Stowing personal configs (with --adopt for review)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Personal config packages to stow (order matters for dependencies)
PERSONAL_CONFIGS=(nvim tmux)

for pkg in "${PERSONAL_CONFIGS[@]}"; do
    if [[ -d "$SCRIPT_DIR/$pkg" ]]; then
        echo "Stowing $pkg with --adopt..."
        if stow -t ~ --adopt "$pkg" 2>/dev/null; then
            echo "  ✓ $pkg stowed (check git diff to review adopted changes)"
        else
            echo "  ✗ $pkg failed to stow"
        fi
    else
        echo "  - $pkg directory not found, skipping"
    fi
done

echo ""
echo "NOTE: Run 'git diff' to review any adopted changes from your system."
echo "      Use 'git checkout <package>' to restore repo versions if needed."

# ╔══════════════════════════════════════════════════════════════════════╗
# ║                    ADD HYPRLAND SOURCE LINE                          ║
# ╚══════════════════════════════════════════════════════════════════════╝

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Wiring Hyprland to personal modules"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for mod in "${PERSONAL_MODULES[@]}"; do
    target="$HYPR_DIR/$mod.lua"
    require_line="require(\"hypr.personal.$mod\")"

    if [[ -f "$target" ]] && grep -qF "$require_line" "$target"; then
        echo "  - $mod.lua already wired"
        continue
    fi

    [[ -f "$target" ]] && cp "$target" "$target.bak.$(date +%s)"
    cat > "$target" <<EOF
-- Personal configuration lives in hypr/personal/, a path Omarchy does not
-- manage, so \`omarchy refresh\` and future migrations cannot overwrite it.
-- hypr/personal/ is a stow symlink into this dotfiles repo.
$require_line
EOF
    echo "  + wired $mod.lua -> hypr/personal/$mod.lua"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installing Omarchy shell config"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Deliberately a copy, not a stow symlink: `omarchy bar ...` and tray pinning
# rewrite shell.json with `mv $tmp shell.json`, which would silently replace a
# symlink with a regular file and detach it from this repo.
if [[ -f "$SHELL_JSON_SRC" ]]; then
    mkdir -p "$(dirname "$SHELL_JSON_DST")"
    if [[ -f "$SHELL_JSON_DST" ]] && ! cmp -s "$SHELL_JSON_SRC" "$SHELL_JSON_DST"; then
        cp "$SHELL_JSON_DST" "$SHELL_JSON_DST.bak.$(date +%s)"
        echo "  backed up existing shell.json"
    fi
    cp "$SHELL_JSON_SRC" "$SHELL_JSON_DST"
    echo "  + shell.json installed (copy)"
    echo "    NOTE: local edits do not flow back; re-copy into the repo to keep them."
else
    echo "  - $SHELL_JSON_SRC not found, skipping"
fi

# ╔══════════════════════════════════════════════════════════════════════╗
# ║                     RUN INSTALLATION SCRIPTS                         ║
# ╚══════════════════════════════════════════════════════════════════════╝

if [[ -d "$SCRIPTS_DIR" ]]; then
    # Run scripts in specific order for proper dependencies

    # 1. Install required packages first
    run_script "$SCRIPTS_DIR/install-packages.sh" || true

    # 2. Install pyprland (depends on packages)
    run_script "$SCRIPTS_DIR/install-pyprland.sh" || true

    # 3. Add bash aliases
    run_script "$SCRIPTS_DIR/install-bash-aliases.sh" || true

    # 4. Enable Xbox controller support
    run_script "$SCRIPTS_DIR/install-xbox-support.sh" || true

    # 5. Hide LSP plugin entries
    run_script "$SCRIPTS_DIR/install-lsp-hide.sh" || true
else
    echo "Scripts directory not found at $SCRIPTS_DIR, skipping additional installations"
fi

# ╔══════════════════════════════════════════════════════════════════════╗
# ║                        RELOAD CONFIGURATIONS                         ║
# ╚══════════════════════════════════════════════════════════════════════╝

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Reloading configurations"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Reload Hyprland if running
if command -v hyprctl &>/dev/null && hyprctl version &>/dev/null; then
    echo "Reloading Hyprland configuration..."
    hyprctl reload || echo "Warning: Could not reload Hyprland"
fi

# Restart the Omarchy shell (bar, notifications, OSD all live in one process)
if command -v omarchy &>/dev/null; then
    echo "Restarting Omarchy shell..."
    omarchy restart shell || echo "Warning: Could not restart the Omarchy shell"
fi

# ╔══════════════════════════════════════════════════════════════════════╗
# ║                              COMPLETE                                ║
# ╚══════════════════════════════════════════════════════════════════════╝

echo ""
echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║           Omarchy overrides installation complete!                   ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Installed components:"
echo "  • Hyprland overrides via hypr/personal/ (monitors, input, bindings, looknfeel)"
echo "  • Omarchy shell config (bar layout, floating pills, NordVPN widget)"
echo "  • Shell plugins: cost.bar (pill bar), cost.tray (inline tray)"
echo "  • Personal configs (nvim, tmux) - with --adopt"
echo "  • Custom utility scripts (~/.local/bin/)"
echo "  • Pyprland configuration"
echo "  • Bash aliases (lg, gst)"
echo "  • Xbox USB controller support"
echo "  • LSP plugin entries hidden"
echo ""
echo "⚠  Review adopted changes: git diff"
echo "   Restore repo versions:  git checkout <package>"
echo ""

notify_success "Omarchy overrides installation complete!"
