<#
.SYNOPSIS
    A post-installation script to configure and set up a new Windows system.
.DESCRIPTION
    This "FirstRun" script streamlines the setup of a fresh Windows installation. It performs
    sensible system tweaks, installs a suite of common applications using winget, and provides
    guidance for system activation.

    Key Features:
    - Self-elevates to ensure Administrator privileges.
    - Checks for and installs winget if it's missing.
    - Asks for user confirmation before making any changes.
    - Installs all applications in a single, efficient command.
    - Focuses on safe, reversible, and beneficial tweaks.
.NOTES
    Author: daredeep33
    Version: 2.1
    Disclaimer: Run this script at your own risk. Review the code to understand the changes it will make.
#>

# --- SCRIPT CONFIGURATION ---

# Add or remove winget package IDs in this list to customize the applications to be installed.
# Find more package IDs by running 'winget search <program_name>' in your terminal.
$packages = @(
    "Microsoft.Office",
    "7zip.7zip",
    "Google.Chrome",
    "Notepad++.Notepad++",
    "VideoLAN.VLC"
)

# --- SCRIPT ENGINE ---

# Self-Elevation: Ensure the script is run as an Administrator.
function Start-Elevated {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "This script requires Administrator privileges. Attempting to re-launch as Administrator..."
        Start-Process "$PSHOME\powershell.exe" -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        Exit
    }
}

# Check for internet connectivity.
function Test-InternetConnection {
    Write-Host "`n--- Network Check ---" -ForegroundColor Cyan
    Write-Host "[TASK] Checking for internet connectivity..."
    try {
        $response = Invoke-WebRequest -Uri "https://www.google.com" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "[OK] Internet connection confirmed." -ForegroundColor Green
        }
        else {
            throw "Status code: $($response.StatusCode)"
        }
    }
    catch {
        Write-Error "No internet connection detected. This script requires an active internet connection to download packages."
        Write-Error "Error: $($_.Exception.Message)"
        Exit
    }
}

# Create a System Restore Point.
function Create-RestorePoint {
    Write-Host "`n--- System Protections ---" -ForegroundColor Cyan
    Write-Host "[TASK] Creating System Restore Point..."
    try {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "Before FirstRun Setup" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-Host "[OK] System Restore Point created successfully." -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to create System Restore Point. You may want to create one manually. Error: $($_.Exception.Message)"
    }
}

# Check for and install Winget if it's not present.
function Ensure-Winget {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "[OK] Winget is already installed." -ForegroundColor Green
        return
    }
    
    Write-Host "[!] Winget not found. Attempting to install it now..." -ForegroundColor Yellow
    $wingetUrl = "https://aka.ms/getwinget"
    $msixPath = Join-Path $env:TEMP "winget.msixbundle"
    
    try {
        Invoke-WebRequest -Uri $wingetUrl -OutFile $msixPath -UseBasicParsing
        Add-AppxPackage -Path $msixPath
        Write-Host "[SUCCESS] Winget has been installed." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to install Winget. Please install it manually from the Microsoft Store or GitHub. Error: $($_.Exception.Message)"
        Exit
    }
    finally {
        if (Test-Path $msixPath) { Remove-Item $msixPath -Force }
    }
}

# Apply safe and reversible system tweaks.
function Apply-SystemTweaks {
    Write-Host "`n--- Applying System Tweaks ---" -ForegroundColor Cyan
    
    try {
        # Optimize Visual Effects for "Best Performance". This is a safe and easily reversible tweak.
        Write-Host "[TASK] Optimizing Visual Effects for performance..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Force
        
        # Disable Telemetry Services. This is safe and enhances privacy.
        # Note: Disabling Windows Update (wuauserv) is NOT recommended and has been removed.
        Write-Host "[TASK] Disabling telemetry services..."
        $services = @("DiagTrack", "lfsvc") # Diagnostic Tracking and Geolocation service
        Get-Service -Name $services -ErrorAction SilentlyContinue | Stop-Service -Force -PassThru | Set-Service -StartupType Disabled
        
        Write-Host "[OK] System tweaks applied successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "An error occurred while applying system tweaks: $($_.Exception.Message)"
    }
}

# Install all configured applications via Winget.
function Install-Applications {
    Write-Host "`n--- Installing Applications ---" -ForegroundColor Cyan
    Write-Host "The following applications will be installed:"
    $packages | ForEach-Object { Write-Host " - $_" }
    
    try {
        Write-Host "Starting Winget install... (This may take a while)"
        foreach ($pkg in $packages) {
            Write-Host "Installing $pkg..." -ForegroundColor Cyan
            winget install --id $pkg --exact --accept-package-agreements --accept-source-agreements --silent
        }
        Write-Host "[OK] All applications installed successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "An error occurred during application installation: $($_.Exception.Message)"
    }
}

# Activation (OPTIONAL - requires explicit user confirmation).
function Invoke-SystemActivation {
    Write-Host "`n--- System Activation ---" -ForegroundColor Cyan
    Write-Host "WARNING: This will download and execute a script from a third-party source." -ForegroundColor Yellow
    Write-Host "This is an optional step. Use a genuine product key for best results." -ForegroundColor Yellow
    
    $activationConfirm = Read-Host "Do you want to attempt system activation? (y/n)"
    
    if ($activationConfirm -ne 'y') {
        Write-Host "Activation skipped by user." -ForegroundColor Green
        return
    }
    
    Write-Host "Proceeding with activation..." -ForegroundColor Yellow
    irm https://get.activated.win | iex
}

# --- MAIN EXECUTION ---
Start-Elevated

Clear-Host
Write-Host "===============================================" -ForegroundColor Magenta
Write-Host "     WINDOWS POST-INSTALLATION SCRIPT"
Write-Host "==============================================="

Write-Host "`nThis script will perform the following actions:"
Write-Host "1. Check for internet connectivity."
Write-Host "2. Create a System Restore Point."
Write-Host "3. Ensure Winget Package Manager is installed."
Write-Host "4. Apply safe system performance and privacy tweaks."
Write-Host "5. Install a standard set of useful applications."
Write-Host "6. Create a transcript log on your Desktop."
Write-Host "7. (OPTIONAL) Activate your system."

$confirmation = Read-Host "`nDo you want to continue? (y/n)"

if ($confirmation -ne 'y') {
    Write-Host "Operation cancelled by user." -ForegroundColor Red
    Exit
}

# Execute the core functions
Test-InternetConnection
Create-RestorePoint

# Start Transcript Logging
$logFile = Join-Path $env:USERPROFILE "Desktop\FirstRun-Log.txt"
Write-Host "`n--- Starting Transcript ---" -ForegroundColor Cyan
Write-Host "Logging execution to: $logFile"
Start-Transcript -Path $logFile -Force

Ensure-Winget
Apply-SystemTweaks
Install-Applications
Invoke-SystemActivation

Stop-Transcript

Write-Host "`n===============================================" -ForegroundColor Magenta
Write-Host "      Script execution completed!"
Write-Host "A log file has been saved to: $logFile"
Write-Host "===============================================" -ForegroundColor Magenta

$restartConfirm = Read-Host "`nDo you want to restart your computer now to apply all tweaks? (y/n)"
if ($restartConfirm -eq 'y') {
    Write-Host "Restarting computer in 5 seconds..." -ForegroundColor Cyan
    Start-Sleep -Seconds 5
    Restart-Computer -Force
}
else {
    Read-Host "Press Enter to exit."
}
