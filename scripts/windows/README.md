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
3. Configure SSH port forwarding from Windows to WSL2

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

### Setup SSH Port Forwarding Only

```powershell
.\setup-ssh.ps1 -SetupScheduledTask
```

This configures port forwarding so external devices can SSH into WSL2 via the Windows IP.

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

## SSH Port Forwarding

### Setup

```powershell
.\setup-ssh.ps1 -SetupScheduledTask
```

This configures SSH access to WSL2 from external devices via the Windows IP address.

### How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│  External Device (e.g., phone on VPN)                           │
│  ssh const@192.168.2.100                                        │
└─────────────────────┬───────────────────────────────────────────┘
                      │ Port 22
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│  Windows Host (192.168.2.100)                                   │
│                                                                 │
│  netsh portproxy: 0.0.0.0:22 ──────► 172.20.91.98:22           │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  WSL2 VM (172.20.91.98)                                   │  │
│  │                                                           │  │
│  │  SSH Server (sshd) listening on port 22                   │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

1. **External device** connects to Windows IP (192.168.2.100) on port 22
2. **Windows `netsh portproxy`** forwards the connection to WSL2's internal IP
3. **WSL2's SSH server** handles the connection

The challenge: WSL2's IP address changes on every Windows reboot. The scheduled task runs on startup to update the port forwarding with the new IP.

### Monitoring & Troubleshooting

#### View current port forwarding rules

```powershell
netsh interface portproxy show v4tov4
```

Expected output:
```
Listen on ipv4:             Connect to ipv4:
Address         Port        Address         Port
--------------- ----------  --------------- ----------
0.0.0.0         22          172.20.91.98    22
```

#### Check if the scheduled task exists

```powershell
Get-ScheduledTask -TaskName "WSL2-SSH-PortForward"
```

#### Manually run the scheduled task

```powershell
Start-ScheduledTask -TaskName "WSL2-SSH-PortForward"
```

#### View scheduled task history

```powershell
Get-WinEvent -LogName Microsoft-Windows-TaskScheduler/Operational |
  Where-Object { $_.Message -like "*WSL2-SSH*" } |
  Select-Object -First 10 TimeCreated, Message
```

#### Check Windows firewall rule

```powershell
Get-NetFirewallRule -DisplayName "WSL2 SSH Inbound"
```

#### Get current WSL2 IP

```powershell
wsl hostname -I
```

#### Test SSH connectivity locally

```powershell
# From Windows, test if SSH is reachable
Test-NetConnection -ComputerName localhost -Port 22
```

#### Check if SSH is running in WSL

```bash
# In WSL
sudo systemctl status ssh
```

### Remove SSH Forwarding

```powershell
.\setup-ssh.ps1 -RemoveScheduledTask
```

This removes:
- The port forwarding rule
- The scheduled task

Note: It does not remove the firewall rule (harmless to leave).

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
