# WSL/Ubuntu Installation Guide

This guide will help you set up your dotfiles on WSL (Windows Subsystem for Linux) with Ubuntu.

## Prerequisites

- WSL2 with Ubuntu installed
- Git installed in WSL
- PowerShell on Windows

## Installation Steps

### 1. Install WSL Dependencies (WSL Terminal)

Open your WSL/Ubuntu terminal and run:

```bash
cd ~/Projects/dotfiles  # or wherever you cloned this repo
./install-linux.sh
```

This will install all required packages:
- ZSH shell with plugins
- Development tools (git, neovim, tmux, etc.)
- Modern CLI tools (eza, fzf, zoxide, lazygit)
- Version managers (nvm, pyenv, rvm)
- Terminal multiplexer (tmux)

**Note**: You'll need to enter your sudo password when prompted.

### 2. Configure Windows Terminal (Windows PowerShell)

Open PowerShell as **Administrator** and run:

```powershell
cd C:\path\to\your\dotfiles\scripts\windows
.\setup-wsl.ps1
```

Or from WSL:

```bash
cd ~/Projects/dotfiles/scripts/windows
powershell.exe -ExecutionPolicy Bypass -File setup-wsl.ps1
```

This will:
- Install JetBrainsMono Nerd Font
- Configure Windows Terminal with Rosé Pine theme
- Set up proper font rendering
- Configure SSH port forwarding from Windows to WSL2
- Create a scheduled task to update port forwarding on startup (WSL2 IP changes on reboot)

### 3. Restart Windows Terminal

Close and reopen Windows Terminal for all changes to take effect.

### 4. Verify Installation

Open a new WSL/Ubuntu tab in Windows Terminal and test:

```bash
# Test autosuggestions - start typing a command you've used before
# Press Ctrl+Y to accept the suggestion

# Test fuzzy history search
# Press Ctrl+R and start typing

# Test zoxide (smart cd)
z <directory-name>

# Test eza (modern ls)
ll

# Test lazygit
lg
```

## Keyboard Shortcuts

### ZSH Hotkeys
- `Ctrl+Y` - Accept autosuggestion
- `Ctrl+P` - Previous command in history (matching current input)
- `Ctrl+N` - Next command in history (matching current input)
- `Ctrl+R` - Fuzzy history search with FZF

### Vi Mode
Your shell uses Vi mode. Press `Esc` to enter normal mode for Vi-style navigation.

## Troubleshooting

### "command not found" errors in ZSH

The shell needs to be fully reloaded. Try:

```bash
exec zsh
```

Or close and reopen your terminal.

### Font looks wrong

1. Verify the font is installed on Windows (check Windows Settings > Fonts)
2. Run the Windows Terminal configuration script again
3. Restart Windows Terminal completely

### zoxide/eza/other commands not found

Make sure `~/.local/bin` is in your PATH. Check with:

```bash
echo $PATH | grep ".local/bin"
```

If missing, try reloading your shell:

```bash
source ~/.zshrc
```

### Missing packages

If any packages failed to install, you can manually install them:

```bash
# For Ubuntu/Debian
sudo apt-get update
sudo apt-get install <package-name>
```

## What You Get

### Shell Configuration
- **ZSH** as default shell
- **Powerlevel10k** prompt theme
- **Zinit** plugin manager
- **Syntax highlighting** in real-time
- **Auto-suggestions** based on history
- **Vi mode** for power users

### Modern CLI Tools
- `eza` - Modern replacement for `ls`
- `zoxide` - Smart `cd` that learns your habits
- `fzf` - Fuzzy finder for everything
- `lazygit` - Beautiful git TUI
- `tmux` - Terminal multiplexer

### Development Tools
- **pyenv** - Python version management
- **nvm** - Node.js version management
- **rvm** - Ruby version management
- **neovim** - Modern Vim
- **Git** with diff-so-fancy

### Visual Theme
- **Rosé Pine** color scheme in Windows Terminal
- **JetBrainsMono Nerd Font** with icons
- Consistent theming across all tools

## SSH Access

After installation, you can SSH into your WSL2 instance from other devices on your network:

```bash
ssh username@<windows-ip>
```

The setup automatically:
1. Enables SSH server in WSL2
2. Configures Windows port forwarding (port 22) to WSL2
3. Adds a firewall rule to allow SSH traffic
4. Creates a scheduled task to update forwarding on startup (since WSL2 IP changes)

### Manual SSH Setup

If you need to set up SSH separately:

```powershell
# From PowerShell (Administrator)
cd C:\path\to\dotfiles\scripts\windows
.\setup-ssh.ps1 -SetupScheduledTask
```

To remove SSH forwarding:
```powershell
.\setup-ssh.ps1 -RemoveScheduledTask
```

### Adding SSH Keys

To allow key-based authentication, add your public key to `~/.ssh/authorized_keys` in WSL:

```bash
# On the remote machine, copy your public key
cat ~/.ssh/id_ed25519.pub

# In WSL, add it to authorized_keys
echo "your-public-key-here" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

## Optional: Install Node.js

If you want to install Node.js via nvm:

```bash
nvm install 22
nvm alias default 22
corepack enable pnpm
```

## Optional: Install Ruby

If you want to install Ruby via rvm:

```bash
rvm install ruby-3.3.1
rvm use 3.3.1 --default
```

## Customization

All configuration files are symlinked from the dotfiles repository, so you can customize:

- Shell: Edit `~/Projects/dotfiles/zsh/.zshrc`
- Prompt: Edit `~/Projects/dotfiles/zsh/.p10k.zsh` or run `p10k configure`
- Tmux: Edit `~/Projects/dotfiles/tmux/.config/tmux/tmux.conf`
- Git: Edit `~/.gitconfig`

After editing, changes take effect immediately (or run `source ~/.zshrc` for shell changes).

## Uninstallation

To remove the dotfiles:

```bash
cd ~/Projects/dotfiles

# Unstow all packages
stow -D zsh zsh-linux nvim kitty lazygit tmux vscode misc

# Change shell back to bash
chsh -s /bin/bash
```
