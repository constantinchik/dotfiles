# SSH Port Forwarding Setup for WSL2
# Run this from PowerShell as Administrator
# This script is idempotent - safe to run multiple times

param(
    [switch]$SetupScheduledTask,
    [switch]$RemoveScheduledTask,
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"
$TaskName = "WSL2-SSH-PortForward"
$SSHPort = 22

function Write-Status($message, $color = "White") {
    if (-not $Quiet) {
        Write-Host $message -ForegroundColor $color
    }
}

function Get-WSLIPAddress {
    $wslOutput = wsl hostname -I 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($wslOutput)) {
        throw "Failed to get WSL IP address. Is WSL running?"
    }
    # Take the first IP (there may be multiple)
    return ($wslOutput -split '\s+')[0].Trim()
}

function Get-CurrentPortProxy {
    $output = netsh interface portproxy show v4tov4 2>$null
    if ($output -match "(\d+\.\d+\.\d+\.\d+)\s+$SSHPort\s+(\d+\.\d+\.\d+\.\d+)\s+$SSHPort") {
        return @{
            ListenAddress = $Matches[1]
            ConnectAddress = $Matches[2]
        }
    }
    return $null
}

function Remove-PortProxy {
    $current = Get-CurrentPortProxy
    if ($current) {
        Write-Status "Removing existing port proxy for port $SSHPort..." "Yellow"
        netsh interface portproxy delete v4tov4 listenport=$SSHPort listenaddress=0.0.0.0 2>$null | Out-Null
    }
}

function Set-PortProxy($wslIP) {
    Write-Status "Setting up port forwarding: 0.0.0.0:$SSHPort -> ${wslIP}:$SSHPort" "Cyan"
    netsh interface portproxy add v4tov4 listenport=$SSHPort listenaddress=0.0.0.0 connectport=$SSHPort connectaddress=$wslIP
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to set up port proxy. Are you running as Administrator?"
    }
}

function Add-FirewallRule {
    $ruleName = "WSL2 SSH Inbound"
    $existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue

    if (-not $existingRule) {
        Write-Status "Adding firewall rule for SSH..." "Cyan"
        New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -LocalPort $SSHPort -Protocol TCP -Action Allow | Out-Null
    } else {
        Write-Status "Firewall rule already exists" "Gray"
    }
}

function Update-PortForwarding {
    $wslIP = Get-WSLIPAddress
    Write-Status "WSL2 IP: $wslIP" "Gray"

    $current = Get-CurrentPortProxy

    if ($current -and $current.ConnectAddress -eq $wslIP) {
        Write-Status "Port forwarding already configured correctly" "Green"
        return $false
    }

    if ($current) {
        Write-Status "Current forwarding points to $($current.ConnectAddress), updating..." "Yellow"
    }

    Remove-PortProxy
    Set-PortProxy $wslIP
    Add-FirewallRule

    Write-Status "Port forwarding configured successfully!" "Green"
    return $true
}

function Install-ScheduledTask {
    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

    if ($existingTask) {
        Write-Status "Scheduled task already exists, updating..." "Yellow"
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    }

    # Get the path to this script
    $scriptPath = $MyInvocation.PSCommandPath
    if (-not $scriptPath) {
        $scriptPath = $PSCommandPath
    }

    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`" -Quiet"

    # Trigger on logon and also after network becomes available
    $triggerLogon = New-ScheduledTaskTrigger -AtLogon
    $triggerStartup = New-ScheduledTaskTrigger -AtStartup

    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger @($triggerLogon, $triggerStartup) -Principal $principal -Settings $settings | Out-Null

    Write-Status "Scheduled task '$TaskName' installed successfully!" "Green"
    Write-Status "Port forwarding will be updated automatically on login/startup" "Gray"
}

function Remove-ScheduledTask {
    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

    if ($existingTask) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Status "Scheduled task removed" "Green"
    } else {
        Write-Status "No scheduled task found" "Yellow"
    }
}

# Main execution
if (-not $Quiet) {
    Write-Host ""
    Write-Host "WSL2 SSH Port Forwarding Setup" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
    Write-Host ""
}

# Check for admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    throw "This script requires Administrator privileges. Please run PowerShell as Administrator."
}

if ($RemoveScheduledTask) {
    Remove-ScheduledTask
    Remove-PortProxy
    Write-Status "SSH port forwarding removed" "Green"
} else {
    Update-PortForwarding

    if ($SetupScheduledTask) {
        Write-Host ""
        Install-ScheduledTask
    }
}

if (-not $Quiet) {
    Write-Host ""
}
