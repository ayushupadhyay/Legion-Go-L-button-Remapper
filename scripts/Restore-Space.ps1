# Run as administrator using the same Windows account used for Block-LegionL-SpaceLaunch.ps1.
$ErrorActionPreference = 'Stop'
$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (!$admin) { throw 'Run this script in PowerShell as administrator using the same Windows account.' }
$record = Join-Path $env:LOCALAPPDATA 'LegionLGameBar\space-button-launch.json'
if (!(Test-Path -LiteralPath $record)) { throw 'No backup record from this installer was found. Nothing changed.' }
$state = Get-Content -LiteralPath $record -Raw | ConvertFrom-Json
$allowed = [IO.Path]::GetFullPath((Join-Path $env:ProgramFiles 'Lenovo\LegionSpace')).TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
$original = [IO.Path]::GetFullPath([string]$state.Original)
$backup = [IO.Path]::GetFullPath([string]$state.Backup)
if (!$original.StartsWith($allowed,[StringComparison]::OrdinalIgnoreCase) -or [IO.Path]::GetFileName($original) -ine 'LegionSpace.exe' -or $backup -ine (Join-Path (Split-Path -Parent $original) 'LegionSpace.Manual.exe')) { throw 'Backup record has unexpected paths. Nothing changed.' }
if (Test-Path -LiteralPath $original) { throw 'A launcher already exists, possibly from a Lenovo update. It will not be overwritten.' }
if (!(Test-Path -LiteralPath $backup)) { throw 'Backup is missing. Nothing changed.' }
if ((Get-FileHash -LiteralPath $backup -Algorithm SHA256).Hash -ne $state.SHA256) { throw 'Backup checksum changed. Nothing changed.' }
Rename-Item -LiteralPath $backup -NewName 'LegionSpace.exe'
$manualLink = Join-Path ([Environment]::GetFolderPath('Programs')) 'Legion Space (Manual).lnk'
if (Test-Path -LiteralPath $manualLink) {
    $link = (New-Object -ComObject WScript.Shell).CreateShortcut($manualLink)
    if ($link.TargetPath -ieq $backup) { Remove-Item -LiteralPath $manualLink }
}
Remove-Item -LiteralPath $record
Write-Host 'Original Legion Space launcher restored. Stop/uninstall the listener if returning to Lenovo button behaviour.'

