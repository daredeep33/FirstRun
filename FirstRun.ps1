# Check if script is run with elevated privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run the script as an administrator. Right-click the script and select 'Run as administrator'."
    Exit
}

# Optimize Visual Effects for Better Performance
Write-Host "Optimizing Visual Effects for Better Performance..."
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f

# Disable Location and Telemetry Services
Write-Host "Disabling Location and Telemetry Services..."
Get-Service -Name "lfsvc", "DiagTrack", "wuauserv" | Stop-Service -Force -PassThru | Set-Service -StartupType Disabled

# Adjust UAC to Never Notify
Write-Host "Adjusting UAC to Never Notify..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value 0

# Install applications using Winget
Write-Host "Installing applications using Winget..."
winget install --id=Microsoft.Office -e
winget install --id=7zip.7zip -e
winget install --id=Google.Chrome -e
winget install --id=Notepad++.Notepad++ -e
winget install --id=VideoLAN.VLC -e
winget install --id=voidtools.Everything -e
winget install --id=stnkl.EverythingToolbar -e

# Activate Office and Windows
Write-Host "Activating Office and Windows..."
& (Invoke-RestMethod -Uri 'https://massgrave.dev/get').ScriptBlock /HWID /Ohook

Write-Host "Script execution completed."