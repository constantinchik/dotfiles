# Dotfiles repository for [@constantinchik](https://github.com/constantinchik)

This repository contains my dotfiles, so that it is easy to configure a new
machine for my needs. The goal of this repository is to achieve single place
of configuration for both macOS machines and Linux machines (Arch and Debian/Ubuntu).

This repository is highly inspired by
[Dreams of Autonomy](https://youtu.be/y6XCebnB9gs) and
[typecraft](https://github.com/typecraft-dev/dotfiles) way of managing dotfiles.

Note that this repository has submodules for nvim configuration. In order for
it to copy the nvim config you should clone this repo with
`--recurse-submodules` flag.

```bash
git clone --recurse-submodules git@github.com:constantinchik/dotfiles.git
```

## Repository Structure

This repository uses [GNU Stow](https://www.gnu.org/software/stow/) with separate
packages for each application. OS-specific configurations are separated into
their own packages.

```
dotfiles/
├── bin/              # Shared personal scripts (~/.local/bin)
├── bin-linux/        # Linux-only personal scripts
├── bin-macos/        # macOS-only personal scripts
├── zsh/              # Shared zsh config (.zshrc, .p10k.zsh)
├── zsh-linux/        # Linux-specific zsh additions (Arch & Debian/Ubuntu)
├── zsh-macos/        # macOS-specific zsh additions
├── nvim/             # Neovim configuration (submodule)
├── kitty/            # Kitty terminal emulator
├── lazygit/          # Lazygit configuration
├── tmux/             # Tmux configuration
├── vscode/           # VS Code settings
├── yazi/             # Yazi file manager
├── opencode/         # OpenCode agents, commands, skills, MCP config
├── misc/             # Misc cross-platform configs
├── yabai/            # macOS-only (tiling wm)
├── claude/           # macOS-only (Claude app config)
├── ghostty/          # macOS-only (Ghostty terminal)
├── scripts/          # Installation and utility scripts
├── install.sh        # Main install script (auto-detects OS)
├── install-linux.sh  # Linux-specific installation
└── install-macos.sh  # macOS-specific installation
```

### Stow Packages

**Shared (cross-platform):**
- `bin` - Personal scripts (`~/.local/bin`)
- `zsh` - Zsh shell configuration
- `nvim` - Neovim editor
- `kitty` - Terminal emulator
- `lazygit` - Git TUI
- `tmux` - Terminal multiplexer
- `vscode` - VS Code settings
- `yazi` - Terminal file manager
- `opencode` - OpenCode agents, commands, skills, and MCP servers
- `misc` - Misc cross-platform configs

**Linux-specific:**
- `bin-linux` - Linux-only personal scripts
- `zsh-linux` - Arch Linux aliases and AUR helper config

**macOS-specific:**
- `bin-macos` - macOS-only personal scripts
- `zsh-macos` - Homebrew aliases
- `yabai` - Tiling window manager
- `claude` - Claude app config
- `ghostty` - Ghostty terminal config

## Contributing

Repository navigation is in [AGENTS.md](AGENTS.md); change boundaries and offline
checks are in [CONTRIBUTING.md](CONTRIBUTING.md).

## Installation

Installation changes the host. Review the selected scripts before running them.
The current Linux and macOS installers use `stow --adopt`, overrides and a blanket
Git checkout that can discard tracked local edits, including adopted content.
They also install software and change host settings; they are unsuitable as
checks or as a way to update an existing dirty checkout. The documentation below
does not change that script behavior. For a bounded update, use the manual
inspection and reconciliation steps instead.

### Automatic Installation

For an explicitly approved full installation on a prepared checkout, the main
script auto-detects your OS:

```bash
./install.sh
```

Or run the OS-specific script directly:

```bash
# On Linux
./install-linux.sh

# On macOS
./install-macos.sh
```

The install script will:
1. Backup your existing configs
2. Install required packages
3. Stow all relevant packages for your OS
4. Set zsh as default shell

### Manual Installation

#### Install packages

```bash
./scripts/packages/install-packages.sh
```

#### Stow packages manually

On Linux:
```bash
stow zsh zsh-linux nvim kitty lazygit tmux vscode yazi opencode misc bin bin-linux
```

On macOS:
```bash
stow zsh zsh-macos nvim kitty lazygit tmux vscode yazi opencode misc yabai claude ghostty bin bin-macos
```

#### Inspect and reconcile existing files

From the repository root, inspect changes and simulate one intended package:

```bash
git status --short
git diff -- zsh/
stow -n -v -t ~ zsh
```

The Stow dry run reports planned links and conflicts without applying them.
Before an approved apply, back up each conflicting target and each affected
repository file to a private location outside the checkout; preserve symlinks
and their targets as appropriate. Record the exact original paths. Compare the
backup, local edits and committed version, then explicitly reconcile each file.
Move only reviewed conflicting targets aside and repeat the dry run. Once its
plan is approved, `stow -v -t ~ zsh` applies that single package.

Avoid blanket adoption, overrides and checkout/reset recipes. If adoption is
specifically required, review and approve its exact package/file scope first:
`--adopt` moves existing target content into the repository and can overwrite
package files. Inspect the resulting per-file diff and reconcile deliberately
from the targeted backups; do not discard the whole working tree afterward.

## Post-Installation

Tmux plugins require a separate installation step after the host setup.
To install tmux plugins, press `Ctrl+s I` inside tmux.

## Tmux Highlights

This tmux setup is tuned around fast keyboard navigation and a compact status
line:

- `Ctrl+s` is used as the tmux prefix instead of `Ctrl+b`
- pane and window numbering starts at `1`
- mouse support is enabled
- window names are sticky and only change when renamed explicitly
- active tabs use a Rosé Pine pink slanted index chip
- panes running `ssh` or `mosh-client` get a remote indicator in the pane
  border and next to the window number

### Copy Mode

Copy mode uses vi keys:

- `prefix + [` enters copy mode
- `v` starts a selection
- `y` copies the selection
- `Ctrl+v` toggles rectangle selection
- `/` searches forward and `?` searches backward
- `n` and `N` repeat the last search
- `u` opens the first URL on the current line
- `U` opens the first URL in the current selection

## Theme

Committed configurations use [Rosé Pine](https://rosepinetheme.com/) with
per-tool variants: [Ghostty](ghostty/.config/ghostty/config),
[tmux](tmux/.config/tmux/tmux.conf) and [Yazi](yazi/.config/yazi/theme.toml)
select Moon; [Kitty's included theme](kitty/.config/kitty/theme.conf) and
[btop](btop/.config/btop/btop.conf) use base Rosé Pine. The stored Kitty
`themes/mocha.conf` is an alternative, not the theme selected by
[kitty.conf](kitty/.config/kitty/kitty.conf). These describe repository defaults,
not a claim about a running terminal or an initialized Neovim submodule.

## Font

[JetBrains Mono](https://www.jetbrains.com/lp/mono/) is used in this
configuration, but it can be changed to the alternative
[CaskaydiaCove Nerd Font Mono](https://github.com/eliheuer/caskaydia-cove?tab=readme-ov-file)
or any other. Please note that in order for some of the terminal tools to work
properly you need a Nerd Font installed.

## Tools and Applications Configured

- [kitty](https://sw.kovidgoyal.net/kitty/) as a terminal application as it is
  minimalistic and supports graphics protocol to display images in the terminal.
- [tmux](https://github.com/tmux/tmux/wiki) as a terminal multiplexer to work
  with multiple sessions and windows from the same terminal instance. Tmux is
  configured with the following plugins:
  - [tpm](https://github.com/tmux-plugins/tpm) as Plugin Manager
  - [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) for
    additional options
  - [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) for
    navigating between windows and splits in neovim and tmux.
  - [tmux-which-key](https://github.com/alexwforsythe/tmux-which-key) for
    showing the tmux hotkeys configured.
  - [tmuxifier](https://github.com/jimeh/tmuxifier) to easily configure and use
    tmux session/window presets.
- [zsh](https://www.zsh.org/) as a primary shell. Note that `ls` command is
  replaced in this configuration with `eza` and `cd` with zoxide's `z` command
  - [p10k](https://github.com/romkatv/powerlevel10k) as a theme for zsh inputs
  - [zinit](https://github.com/zdharma-continuum/zinit) as zsh package manager
  - [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
    for syntax highlighting in the shell session
  - [zsh-completions](https://github.com/zsh-users/zsh-completions) for auto
    completions
  - [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) for
    auto suggestions
  - [fzf-tab](https://github.com/Aloxaf/fzf-tab) for showing tab completion with
    fzf menu
  - [zsh-256color](https://github.com/chrissicool/zsh-256color) for wider color
    support in zsh
- [yabai](https://github.com/koekeishiya/yabai) tiling window manager (macOS only).
  Configured but not recommended to use, as it has strict security requirements
  that usually are not allowed on work machines.

## Troubleshooting

- If you have a problem with icons overlapping or showing wrong in your ZSH
  prompt - try to delete the .p10k.zsh file, and reopen the terminal. You will
  be greeted with p10k initialization wizard, after completing which you will
  get a new .p10k.zsh file
- If you used the script to install the packages and dotfiles and something
  went wrong - your configuration files are located in the
  `~/.config/backup/backup_DATE/` folder. To restore them you can use the
  automatic script located in `./scripts/restore-backup.sh` and you need to
  provide the backup folder. Example of usage:
  ```bash
  ./scripts/restore-backup.sh backup_20240522_213916
  ```
  This will replace all the files under `~/` that are the same relatively to
  the backup folder.

## Shared agent skills

Portable skills live in `agents/.agents/skills/` and are linked into local agent discovery locations, not copied between agents. See [installation, drift checks and maintenance](scripts/agents/README.md). The bounded installer preserves unmanaged skills and refuses conflicts unless their exact managed paths are explicitly approved for backup/replacement. Do not run the full dotfiles installer merely to update shared skills.

## Useful Tools

- `ncdu /` runs the disk scan for large files.
