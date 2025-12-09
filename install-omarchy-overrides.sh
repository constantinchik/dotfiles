#!/bin/bash

# Install Omarchy overrides - applies personal dotfiles on top of Omarchy
# Idempotent: safe to run multiple times
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
OVERRIDE_SOURCE="source = ~/.config/hypr/omarchy-overrides.conf"
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

# Check if Hyprland config exists
if [[ ! -f "$HYPRLAND_CONF" ]]; then
    notify_error "Hyprland config not found at $HYPRLAND_CONF. Please install omarchy first."
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
# ║                    ADD HYPRLAND SOURCE LINE                          ║
# ╚══════════════════════════════════════════════════════════════════════╝

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Configuring Hyprland to source overrides"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! grep -qF "omarchy-overrides.conf" "$HYPRLAND_CONF"; then
    echo "Adding source line to $HYPRLAND_CONF..."
    {
        echo ""
        echo "# Personal overrides (added by install-omarchy-overrides.sh)"
        echo "$OVERRIDE_SOURCE"
    } >> "$HYPRLAND_CONF"
    echo "Source line added successfully"
else
    echo "Source line already exists in $HYPRLAND_CONF"
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

    # 3. Install waybar indicator scripts
    run_script "$SCRIPTS_DIR/install-waybar-indicators.sh" || true

    # 4. Patch waybar config (depends on indicators)
    run_script "$SCRIPTS_DIR/install-waybar-overrides.sh" || true

    # 5. Add bash aliases
    run_script "$SCRIPTS_DIR/install-bash-aliases.sh" || true

    # 6. Enable Xbox controller support
    run_script "$SCRIPTS_DIR/install-xbox-support.sh" || true

    # 7. Hide LSP plugin entries
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

# Restart waybar using omarchy's script (handles uwsm properly)
if pgrep -x waybar &>/dev/null; then
    echo "Restarting waybar..."
    omarchy-restart-waybar
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
echo "  • Hyprland overrides (monitors, input, bindings, animations)"
echo "  • Custom utility scripts (~/.local/bin/)"
echo "  • Pyprland configuration"
echo "  • Waybar indicators (NordVPN, Wiremix)"
echo "  • Bash aliases (lg, gst)"
echo "  • Xbox USB controller support"
echo "  • LSP plugin entries hidden"
echo ""

notify_success "Omarchy overrides installation complete!"
