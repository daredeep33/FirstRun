<#
.SYNOPSIS
    A script to automatically remove default Windows "bloatware" apps.
.DESCRIPTION
    This script removes many of the pre-installed UWP (Universal Windows Platform)
    apps that come with Windows 10 and 11, such as Cortana, Xbox apps, Your Phone,
    and more.
#>

# Self-Elevation: Ensure the script is run as an Administrator.
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script requires Administrator privileges. Attempting to re-launch as Administrator..."
    Start-Process "$PSHOME\powershell.exe" -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Exit
}

Clear-Host
Write-Host "===============================================" -ForegroundColor Magenta
Write-Host "          WINDOWS DEBLOATER SCRIPT"
Write-Host "==============================================="

$appsToRemove = @(
    "*3DBuilder*",
    "*WindowsAlarms*",
    "*Appconnector*",
    "*BingFinance*",
    "*BingNews*",
    "*BingSports*",
    "*BingWeather*",
    "*GetHelp*",
    "*Getstarted*",
    "*Microsoft3DViewer*",
    "*MicrosoftOfficeHub*",
    "*MicrosoftSolitaireCollection*",
    "*MixedReality.Portal*",
    "*NetworkSpeedTest*",
    "*News*",
    "*Office.OneNote*",
    "*Office.Sway*",
    "*OneConnect*",
    "*People*",
    "*SkypeApp*",
    "*SoundRecorder*",
    "*Twitter*",
    "*Wallet*",
    "*Whiteboard*",
    "*WindowsFeedbackHub*",
    "*WindowsMaps*",
    "*WindowsPhone*",
    "*XboxApp*",
    "*XboxGamingOverlay*",
    "*XboxIdentityProvider*",
    "*XboxSpeechToTextOverlay*",
    "*YourPhone*",
    "*ZuneMusic*",
    "*ZuneVideo*"
)

Write-Host "`nWARNING: This will permanently uninstall the listed default Windows Apps." -ForegroundColor Yellow
$confirmation = Read-Host "Do you want to continue? (y/n)"

if ($confirmation -ne 'y') {
    Write-Host "Operation cancelled by user." -ForegroundColor Red
    Exit
}

Write-Host "`n[TASK] Removing Bloatware Apps..." -ForegroundColor Cyan

foreach ($app in $appsToRemove) {
    # Suppressing output because some apps might not be installed, we don't need errors flooding
    Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue 
    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like $app } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    Write-Host " - Processed: $app"
}

Write-Host "`n[OK] Debloat process completed successfully." -ForegroundColor Green
Write-Host "`n===============================================" -ForegroundColor Magenta
Read-Host "Press Enter to exit."
