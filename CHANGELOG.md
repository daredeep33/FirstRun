# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
### Added
- `Debloat.ps1`: An optional standalone utility script to permanently remove pre-installed Windows Universal Apps (bloatware).
- Network Connectivity Check in `FirstRun.ps1` to ensure internet access before attempting application downloads.
- System Restore Point Creation in `FirstRun.ps1` for safer execution and rollbacks.
- Transcript Logging in `FirstRun.ps1` that automatically saves an execution log to the user's Desktop.
- Automatic System Restart prompt at the end of `FirstRun.ps1`.

### Fixed
- Replaced the self-elevation command to use standard `powershell.exe` instead of `pwsh` for better compatibility with completely fresh Windows installations missing PowerShell 7.
- Addressed `winget` installation problems by changing bulk install strings to a dedicated installation loop with the `--silent` flag.
