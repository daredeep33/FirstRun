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
    Version: 2.0
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
        Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile -File `"$PSCommandPath`""
        Exit
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
    
    # Format the package list for the winget command line
    $packageArgs = $packages | ForEach-Object { "--id $_ --accept-package-agreements --accept-source-agreements" }
    
    try {
        Write-Host "Starting Winget bulk install... (This may take a while)"
        winget install --exact $packageArgs
        Write-Host "[OK] All applications installed successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "An error occurred during application installation: $($_.Exception.Message)"
    }
}

# Activation.
function Show-ActivationInfo {
    Write-Host "`n--- System Activation ---" -ForegroundColor Cyan
    irm https://get.activated.win | iex
}

# --- MAIN EXECUTION ---
Start-Elevated

Clear-Host
Write-Host "===============================================" -ForegroundColor Magenta
Write-Host "     WINDOWS POST-INSTALLATION SCRIPT"
Write-Host "==============================================="

Write-Host "`nThis script will perform the following actions:"
Write-Host "1. Ensure Winget Package Manager is installed."
Write-Host "2. Apply safe system performance and privacy tweaks."
Write-Host "3. Install a standard set of useful applications."
Write-Host "4. Activating your system."

$confirmation = Read-Host "`nDo you want to continue? (y/n)"

if ($confirmation -ne 'y') {
    Write-Host "Operation cancelled by user." -ForegroundColor Red
    Exit
}

# Execute the core functions
Ensure-Winget
Apply-SystemTweaks
Install-Applications
Show-ActivationInfo

Write-Host "`n===============================================" -ForegroundColor Magenta
Write-Host "      Script execution completed!"
Write-Host "It is recommended to restart your computer."
Write-Host "==============================================="
Read-Host "Press Enter to exit."
