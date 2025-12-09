# Dotfiles repository for [@constantinchik](https://github.com/constantinchik)

This repository contains my dotfiles, so that it is easy to configure a new
machine for my needs. The goal of this repository is to achieve single place
of configuration for both macOS machines and Arch-Linux machines.

This repository is highly inspired by
[Dreams of Autonomy](https://youtu.be/y6XCebnB9gs) and
[typecraft](https://github.com/typecraft-dev/dotfiles) way of managing dotfiles.

Note that this repository has submodules for nvim configuration. In order for
it to copy the nvim config you should clone this repo with
`--recursive-submodules` flag.

```bash
git clone --recurse-submodules git@github.com:constantinchik/dotfiles.git
```

## Repository Structure

This repository uses [GNU Stow](https://www.gnu.org/software/stow/) with separate
packages for each application. OS-specific configurations are separated into
their own packages.

```
dotfiles/
├── zsh/              # Shared zsh config (.zshrc, .p10k.zsh)
├── zsh-linux/        # Linux-specific zsh additions
├── zsh-macos/        # macOS-specific zsh additions
├── nvim/             # Neovim configuration (submodule)
├── kitty/            # Kitty terminal emulator
├── lazygit/          # Lazygit configuration
├── tmux/             # Tmux configuration
├── vscode/           # VS Code settings
├── yabai/            # macOS-only (tiling wm)
├── scripts/          # Installation and utility scripts
├── install.sh        # Main install script (auto-detects OS)
├── install-linux.sh  # Linux-specific installation
└── install-macos.sh  # macOS-specific installation
```

### Stow Packages

**Shared (cross-platform):**
- `zsh` - Zsh shell configuration
- `nvim` - Neovim editor
- `kitty` - Terminal emulator
- `lazygit` - Git TUI
- `tmux` - Terminal multiplexer
- `vscode` - VS Code settings

**Linux-specific:**
- `zsh-linux` - Arch Linux aliases and AUR helper config

**macOS-specific:**
- `zsh-macos` - Homebrew aliases
- `yabai` - Tiling window manager

## Installation

### Automatic Installation

Simply run the main install script which auto-detects your OS:

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
stow zsh zsh-linux nvim kitty lazygit tmux vscode
```

On macOS:
```bash
stow zsh zsh-macos nvim kitty lazygit tmux vscode yabai
```

#### Using --adopt

To adopt existing files (then restore from git):
```bash
stow -t ~ --adopt zsh nvim kitty lazygit tmux
git checkout .
```

## Post-Installation

The automatic installation covers almost everything except tmux plugins.
To install tmux plugins, press `Ctrl+s I` inside tmux.

## Theme

This config contains the theme files from
[Catppuccin](https://github.com/catppuccin/catppuccin) Mocha as I find it an
amazing and beautiful theme that supports so much tools.

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

## Useful Tools

- `ncdu /` runs the disk scan for large files.
