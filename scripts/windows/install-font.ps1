# PowerShell script to install JetBrainsMono Nerd Font on Windows
# Run this from PowerShell as Administrator

param(
    [string]$FontName = "JetBrainsMono"
)

$ErrorActionPreference = "Stop"

Write-Host "Installing $FontName Nerd Font..." -ForegroundColor Cyan

# Create temp directory
$tempDir = Join-Path $env:TEMP "nerd-fonts"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

# Download the font
$fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FontName.zip"
$zipPath = Join-Path $tempDir "$FontName.zip"

Write-Host "Downloading $FontName Nerd Font (this may take a minute)..." -ForegroundColor Yellow
Write-Host "URL: $fontUrl" -ForegroundColor Gray
try {
    # Use WebClient for better progress feedback
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($fontUrl, $zipPath)
    Write-Host "Download complete! Size: $([math]::Round((Get-Item $zipPath).Length / 1MB, 2)) MB" -ForegroundColor Green
} catch {
    Write-Host "Failed to download font: $_" -ForegroundColor Red
    Write-Host "You can manually download from: https://www.nerdfonts.com/font-downloads" -ForegroundColor Yellow
    exit 1
}

# Extract the font
$extractPath = Join-Path $tempDir $FontName
Write-Host "Extracting font files..." -ForegroundColor Yellow
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

# Install fonts
$fonts = Get-ChildItem -Path $extractPath -Include "*.ttf","*.otf" -Recurse
$fontsFolder = (New-Object -ComObject Shell.Application).Namespace(0x14)

Write-Host "Installing fonts..." -ForegroundColor Yellow
$installed = 0
foreach ($font in $fonts) {
    # Skip certain variants if desired
    if ($font.Name -match "Windows Compatible") {
        continue
    }

    try {
        $fontsFolder.CopyHere($font.FullName, 0x10)
        $installed++
        Write-Host "  Installed: $($font.Name)" -ForegroundColor Gray
    } catch {
        Write-Host "  Skipped (may already exist): $($font.Name)" -ForegroundColor DarkGray
    }
}

# Cleanup
Write-Host "Cleaning up..." -ForegroundColor Yellow
Remove-Item -Path $tempDir -Recurse -Force

Write-Host "`nFont installation complete! Installed $installed font files." -ForegroundColor Green
Write-Host "Please restart Windows Terminal for changes to take effect." -ForegroundColor Cyan
