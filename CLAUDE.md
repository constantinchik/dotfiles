# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

GNU Stow-based dotfiles repo targeting macOS and Linux (Arch/Debian/Ubuntu). Each top-level directory is a stow package that symlinks into `$HOME`. The `nvim/` package is a git submodule pointing to a separate repo.

## Key Commands

```bash
# Full install (auto-detects OS)
./install.sh

# OS-specific install
./install-macos.sh
./install-linux.sh

# Stow a single package (e.g. zsh)
stow -t ~ -R --adopt --override='.*' zsh

# Unstow a package
stow -t ~ -D zsh

# After using --adopt, restore repo state
git checkout .
```

## Architecture

- **Stow packages** map 1:1 to top-level directories. Each package mirrors the home directory structure (e.g., `zsh/.zshrc` becomes `~/.zshrc`, `bin/.local/bin/` becomes `~/.local/bin/`).
- **OS-specific packages** use a `-linux` or `-macos` suffix (e.g., `zsh-linux`, `bin-macos`). The install scripts stow shared packages plus the appropriate OS-specific ones.
- **`nvim/`** is a git submodule (`nvim/.config/nvim` -> `constantinchik/nvim-config`). Clone with `--recurse-submodules`. Edit nvim config in its own repo.
- **`scripts/`** contains installation helpers (backup, restore, package installation, SSH setup) — these are NOT stow packages and are not symlinked.
- **`bin/`, `bin-macos/`, `bin-linux/`** contain personal scripts that get symlinked to `~/.local/bin/`.

## Server-Specific Overrides

The `opencode-server/` package overlays `opencode/` on the Home Assistant server (mac mini at 192.168.30.10).

When modifying skills or agents in `opencode/`, check if `opencode-server/` needs parallel updates.
Currently only `skills/home-assistant/` differs between environments:
- **Client machines** (`opencode/`): Uses SSH to access Home Assistant remotely
- **Server** (`opencode-server/`): Uses local Docker commands (no SSH)

The `install-macos.sh` script auto-detects the server environment by:
1. Checking if the machine has IP 192.168.30.10
2. Fallback: Checking if `homeassistant` Docker container is running locally


## Conventions

- Theme: Catppuccin Mocha across all tools.
- Font: JetBrains Mono (Nerd Font variant required).
- Shell: zsh with zinit plugin manager, powerlevel10k prompt.
- `ls` is aliased to `eza`, `cd` to zoxide's `z`.
- Tmux prefix is `Ctrl+s`. Plugins managed by tpm.
- `.zshrc.secrets` is gitignored and holds sensitive env vars.

## Obsidian Vault

Vault path: `/Users/cost/Library/Mobile Documents/iCloud~md~obsidian/Documents/Personal notes`

When conversation produces vault-worthy content — guides, hardware/software configs, ideas, project docs, research, recipes, or learning — mention it and offer `/wrapup`. To save a single item on the spot, spawn the `note-taker` agent directly. The agent has all vault rules baked in; do not duplicate them here.
