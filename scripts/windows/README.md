# Windows Terminal Setup for WSL

This directory contains PowerShell scripts to configure Windows Terminal with your WSL dotfiles.

## Quick Start

Run this command in PowerShell (as Administrator):

```powershell
cd /path/to/dotfiles/scripts/windows
.\setup-wsl.ps1
```

This will:
1. Install JetBrainsMono Nerd Font
2. Configure Windows Terminal with Rosé Pine theme
3. Set the font to JetBrainsMono Nerd Font

## Individual Scripts

You can also run the scripts individually:

### Install Font Only

```powershell
.\install-font.ps1
```

This downloads and installs the JetBrainsMono Nerd Font from the official Nerd Fonts repository.

### Configure Terminal Only

```powershell
.\configure-terminal.ps1
```

This updates your Windows Terminal settings with:
- Rosé Pine color scheme
- JetBrainsMono Nerd Font
- Optimized cursor and opacity settings

## Running from WSL

You can also run these scripts from WSL using PowerShell:

```bash
cd ~/Projects/dotfiles/scripts/windows
powershell.exe -ExecutionPolicy Bypass -File setup-wsl.ps1
```

## What Gets Configured

### Windows Terminal Settings

- **Theme**: Rosé Pine (beautiful dark theme with purple/pink accents)
- **Font**: JetBrainsMono Nerd Font (includes all the icons and ligatures)
- **Cursor**: Bar cursor
- **Opacity**: 95% with acrylic effect
- **Backup**: Automatic backup of your existing settings

### Font Installation

The JetBrainsMono Nerd Font includes:
- All standard glyphs
- Powerline symbols
- Font Awesome icons
- Material Design icons
- And many more...

## Troubleshooting

### Font not showing up

1. Close all Windows Terminal windows
2. Re-run the font installation script
3. Restart Windows Terminal

### Permission errors

Make sure to run PowerShell as Administrator for font installation.

### Settings not applying

1. Check the backup file created in LocalState
2. Manually restart Windows Terminal
3. Verify the font name is exactly "JetBrainsMono Nerd Font"

## Manual Installation

If the scripts don't work, you can manually:

1. Download JetBrainsMono Nerd Font from: https://www.nerdfonts.com/
2. Extract and install the .ttf files
3. Open Windows Terminal settings (Ctrl+,)
4. Add the Rosé Pine color scheme from `configure-terminal.ps1`
5. Set the font face to "JetBrainsMono Nerd Font"

## Color Palette Reference

Rosé Pine colors used:
- Background: `#191724`
- Foreground: `#e0def4`
- Cursor: `#524f67`
- Red: `#eb6f92`
- Green: `#31748f`
- Yellow: `#f6c177`
- Blue: `#9ccfd8`
- Purple: `#c4a7e7`
- Cyan: `#ebbcba`
