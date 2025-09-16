# Windows Post-Installation Script (FirstRun)

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)  ![License](https://img.shields.io/badge/License-MIT-yellow.svg)

This PowerShell script is designed to streamline and automate the setup of a fresh Windows installation. It handles tedious initial configuration tasks and installs a core set of applications, saving you time and ensuring consistency on every new machine.

## Key Features

-   ✅ **Automatic Administrator Privileges**: The script automatically checks if it's running as an administrator and will re-launch itself with elevated privileges if needed.
-   ✅ **Automated Winget Installation**: It detects if the Windows Package Manager (`winget`) is installed. If not, it will download and install it before proceeding.
-   ✅ **System Performance & Privacy Tweaks**:
    -   Optimizes visual effects for better performance.
    -   Disables common telemetry and diagnostic services to enhance user privacy.
-   ✅ **Batch Application Installation**: Installs a customizable list of essential applications in a single, silent operation using `winget`.
-   ✅ **Automated System Activation**: Includes a function to attempt system activation.

## ⚠️ Security and Activation Disclaimer

This script includes a function that attempts to activate Windows by downloading and executing a script from an unofficial, third-party source (`get.activated.win`). Please be aware of the following:

-   **Significant Security Risk**: Running scripts from untrusted sources using `irm | iex` is extremely dangerous and can expose your system to malware, ransomware, or other security vulnerabilities.
-   **Software Licensing**: These methods are designed to bypass legitimate Microsoft software licensing.
-   **System Stability**: Unofficial activation tools can modify critical system files, potentially leading to system instability or future update failures.

**Use this feature entirely at your own risk. It is recommended to use a genuine product key for activation.**

## Prerequisites

-   **Operating System**: Windows 10, Windows 11, Windows Server 2019/2022.
-   **PowerShell**: Version 5.1 or later.
-   **Internet Connection**: Required to download `winget`, applications, and the activation script.

## Usage

This script is best run immediately after a clean Windows installation.

1.  Open **PowerShell as an Administrator**.
2.  Copy and run the following command. This will download and execute the script in one step.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/daredeep33/YOUR_REPOSITORY/main/FirstRun.ps1'))
```
> **Important:** Replace `daredeep33/YOUR_REPOSITORY` with your actual GitHub username and repository name.

The script will display a summary of its actions and ask for your confirmation before proceeding.

## Customization

You can easily customize the list of applications to be installed by editing the `$packages` array at the top of the script file.

1.  **Find Package IDs**: To find the ID for a program you want to add, use the command:
    ```powershell
    winget search "program name"
    ```
2.  **Edit the Script**: Add or remove the package IDs from the `$packages` list.

**Example:**

```powershell
# --- SCRIPT CONFIGURATION ---

# Add or remove winget package IDs in this list.
$packages = @(
    "Microsoft.Office",
    "7zip.7zip",
    "Google.Chrome",
    "Notepad++.Notepad++",
    "VideoLAN.VLC",
    "Microsoft.PowerToys",          # Example: Adding PowerToys
    "Microsoft.VisualStudioCode"    # Example: Adding VS Code
)

# ... rest of the script
```

## License

This project is licensed under the MIT License.
