# Manual Font Installation (Alternative)

If the automatic script is stuck or fails, follow these steps:

## Quick Manual Installation

1. **Download the font**
   - Go to: https://github.com/ryanoasis/nerd-fonts/releases/latest
   - Find and download `JetBrainsMono.zip` (around 30-50 MB)

2. **Extract the ZIP file**
   - Right-click the downloaded file
   - Select "Extract All..."

3. **Install the fonts**
   - Open the extracted folder
   - Select all `.ttf` files (you can skip "Windows Compatible" variants)
   - Right-click → "Install for all users" (or just "Install")

4. **Verify installation**
   - Open Windows Settings → Personalization → Fonts
   - Search for "JetBrainsMono Nerd Font"
   - You should see multiple variants listed

5. **Continue with terminal configuration**
   ```powershell
   cd C:\path\to\dotfiles\scripts\windows
   .\configure-terminal.ps1
   ```

## Even Faster: Use winget (Windows Package Manager)

If you have winget installed (Windows 11 or updated Windows 10):

```powershell
winget install --id=DEVCOM.JetBrainsMonoNerdFont -e
```

Then run the terminal configuration:

```powershell
.\configure-terminal.ps1
```

## Alternative Fonts

If you prefer a different Nerd Font:

- **CascadiaCode**: `winget install Microsoft.CascadiaCode.Nerd`
- **FiraCode**: Download from https://www.nerdfonts.com/
- **Hack**: Download from https://www.nerdfonts.com/

Just update the font name in `configure-terminal.ps1` line 53:
```powershell
face = "YourChosenFont Nerd Font"
```
