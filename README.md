# Dotfiles repository for [@constantinchik](https://github.com/constantinchik)

This repository contains my dotfiles, so that it is easy to configure a new
machine for my needs. The goal of this repository is to achieve single place
of configuration for both MacOS machines and Arch-Linux machines.

This repository is highly inspired by
[Dreams of Autonomy](https://youtu.be/y6XCebnB9gs) way of managing dotfiles.

Note that this repository has submodules for nvim configuration. In order for
it to copy the nvim config you should clone this repo with
`--recursive-submodules` flag.

```bash
git clone --recursive-submodules https://github.com/constantinchik/dotfiles
```

## Installation

### Automatic installation

Simply run the following code from the root of this repository:

```bash
./scripts/setup.sh
```

Script and it will install all the required packages as well as apply all the
dotfile configurations on your machine.

Note that if some of your files from this repository already existed on your
system, then after running this command they will override the ones that are
located in this repository, but the symlinks will be created. To undo the
changes made simply run the following command:

```bash
git checkout .
```

The automatic installaction covers almost everything, except for the plugins
installation in tmux (this cannot be done with the shell command). To install
those packages in tmux click `Ctrl+s I`.

### Manual installation

In order to work with these dotfiles you can either copy them to your $HOME (~)
location, or you can use [GNU Stow](https://www.gnu.org/software/stow/) to
symlink them in place.

In order for the configuration to work you need to have the right packages
installed. For that there is a `./scripts/install-packages.sh` script, by running
which you will ensure that all of the required packages are installed and in
place.

#### Install packages

To install all packages simply run:

```bash
./scripts/install_packages.sh
```

This script will detect your system and install the right packages from the
right package manager.

#### Apply dotfiles using GNU Stow

To apply all of the configuration files to your local machine you need to first
remove the old ones that are configured in this repository from `~/.config`
repository and then run GNU Stow.

```bash
stow . -t ~
```

If you want to override the current configuration files, but apply them to this
repository (after that you can either undo changes and run again or leave
them) you should run:

```bash
stow . -t ~ --adopt
```

## Updating

Updating should be the same process as installing packages.

## Theme

This config contains the theme files from
[Catppuccin](https://github.com/catppuccin/catppuccin) Mocha as I find it an
amazing and beautiful theme that supports so much tools.

## Font

[JetBrains Mono](https://www.jetbrains.com/lp/mono/) is used in this
configuration, but it can be changed to the alternative
[CaskaydiaCove Nerd Font Mono](https://github.com/eliheuer/caskaydia-cove?tab=readme-ov-file)
or any other. Please note that in order for some of the termial tools to work
propperly the code

## Tools and application configured

- [kitty](https://sw.kovidgoyal.net/kitty/) as a terminal application as it is
  minimalistic and supports graphics protocol to display images in the terminal.
- [tmux](https://github.com/tmux/tmux/wiki) as a terminal multiplexer to work
  with multiple sessions and windows from the same terminal instance. Tmux is
  configured with the following plugins:
  - [tpm](https://github.com/tmux-plugins/tpm) as Plugin Manager
  - [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) for
    additional options
  - [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) for
    navigating between widows and splits in neovim and tmux.
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

## Troubleshooting

- If you have a problem with icons overlapping or showing wrong in your ZSH
  prompt - try to delete the .p10k.zsh file, and reopen the terminal. You will
  be greeted with p10k instialization wizard, after completing which you will
  get a new .p10k.zsh file
- If you used the script to install the packages and dotfiles and something
  went wrong - your configuration files are located in the
  `~/.config/backup/backup_DATE/` folder. To restore them you can use the
  automatic script located in `./scripts/restore-backup.sh` and you need to
  provide the backup folder. Example of usage:
  ```bash
  ./scripts/restore-backup.sh bakcup_20240522_213916
  ```
  This will replace all the files under `~/` that are the same relatively to
  the backup folder.

## TODOs:

- Tiling window manager for Mac OS (amethyst or swish or yabai)
