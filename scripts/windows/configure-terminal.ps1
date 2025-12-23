# PowerShell script to configure Windows Terminal with Rosé Pine theme
# Run this from PowerShell (no admin required)

$ErrorActionPreference = "Stop"

Write-Host "Configuring Windows Terminal..." -ForegroundColor Cyan

# Find Windows Terminal settings file
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (-not (Test-Path $settingsPath)) {
    Write-Host "Windows Terminal settings file not found at: $settingsPath" -ForegroundColor Red
    exit 1
}

Write-Host "Found settings file: $settingsPath" -ForegroundColor Green

# Backup existing settings
$backupPath = "$settingsPath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Copy-Item -Path $settingsPath -Destination $backupPath
Write-Host "Created backup: $backupPath" -ForegroundColor Yellow

# Read current settings
$settings = Get-Content -Path $settingsPath -Raw | ConvertFrom-Json

# Rosé Pine color scheme
$rosePine = @{
    name = "Rosé Pine"
    background = "#191724"
    foreground = "#e0def4"
    cursorColor = "#524f67"
    selectionBackground = "#2a273f"

    black = "#26233a"
    red = "#eb6f92"
    green = "#31748f"
    yellow = "#f6c177"
    blue = "#9ccfd8"
    purple = "#c4a7e7"
    cyan = "#ebbcba"
    white = "#e0def4"

    brightBlack = "#6e6a86"
    brightRed = "#eb6f92"
    brightGreen = "#31748f"
    brightYellow = "#f6c177"
    brightBlue = "#9ccfd8"
    brightPurple = "#c4a7e7"
    brightCyan = "#ebbcba"
    brightWhite = "#e0def4"
}

# Add or update the Rosé Pine scheme
if (-not $settings.schemes) {
    $settings | Add-Member -MemberType NoteProperty -Name "schemes" -Value @()
}

$existingScheme = $settings.schemes | Where-Object { $_.name -eq "Rosé Pine" }
if ($existingScheme) {
    Write-Host "Updating existing Rosé Pine scheme..." -ForegroundColor Yellow
    $index = $settings.schemes.IndexOf($existingScheme)
    $settings.schemes[$index] = $rosePine
} else {
    Write-Host "Adding Rosé Pine scheme..." -ForegroundColor Yellow
    $settings.schemes += $rosePine
}

# Configure defaults for all profiles
$defaultSettings = @{
    colorScheme = "Rosé Pine"
    font = @{
        face = "JetBrainsMono Nerd Font"
        size = 11
    }
    cursorShape = "bar"
    opacity = 95
    useAcrylic = $true
}

# Update profile defaults
if (-not $settings.profiles.defaults) {
    $settings.profiles | Add-Member -MemberType NoteProperty -Name "defaults" -Value $defaultSettings
} else {
    foreach ($key in $defaultSettings.Keys) {
        if ($settings.profiles.defaults.PSObject.Properties.Name -contains $key) {
            $settings.profiles.defaults.$key = $defaultSettings[$key]
        } else {
            $settings.profiles.defaults | Add-Member -MemberType NoteProperty -Name $key -Value $defaultSettings[$key]
        }
    }
}

Write-Host "Applied theme and font to profile defaults" -ForegroundColor Green

# Save updated settings
$settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -Encoding UTF8

Write-Host "`nWindows Terminal configuration complete!" -ForegroundColor Green
Write-Host "Theme: Rosé Pine" -ForegroundColor Cyan
Write-Host "Font: JetBrainsMono Nerd Font" -ForegroundColor Cyan
Write-Host "`nPlease restart Windows Terminal for changes to take effect." -ForegroundColor Yellow
