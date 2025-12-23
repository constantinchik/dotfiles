# Master setup script for WSL dotfiles
# Run this from PowerShell (Administrator recommended)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  WSL Dotfiles Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get the script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Step 1: Install Nerd Font
Write-Host "[1/2] Installing JetBrainsMono Nerd Font..." -ForegroundColor Yellow
& "$scriptDir\install-font.ps1"

Write-Host ""
Write-Host "Press any key to continue to Windows Terminal configuration..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Step 2: Configure Windows Terminal
Write-Host ""
Write-Host "[2/2] Configuring Windows Terminal..." -ForegroundColor Yellow
& "$scriptDir\configure-terminal.ps1"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Restart Windows Terminal" -ForegroundColor White
Write-Host "2. Open a new WSL/Ubuntu tab" -ForegroundColor White
Write-Host "3. Enjoy your configured terminal with:" -ForegroundColor White
Write-Host "   - Rosé Pine color theme" -ForegroundColor Gray
Write-Host "   - JetBrainsMono Nerd Font" -ForegroundColor Gray
Write-Host "   - ZSH with autosuggestions" -ForegroundColor Gray
Write-Host "   - Ctrl+Y to accept suggestions" -ForegroundColor Gray
Write-Host "   - Ctrl+R for fuzzy history search" -ForegroundColor Gray
Write-Host ""
