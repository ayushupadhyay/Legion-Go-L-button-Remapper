param([Parameter(Mandatory=$true)][string]$LauncherPath)
# Run as administrator. Only renames the exact launcher supplied; never changes services.
$ErrorActionPreference = 'Stop'
$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (!$admin) { throw 'Run this script in PowerShell as administrator.' }
$exe = (Resolve-Path -LiteralPath $LauncherPath).Path
$allowed = [IO.Path]::GetFullPath((Join-Path $env:ProgramFiles 'Lenovo\LegionSpace')).TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
if (![IO.Path]::GetFullPath($exe).StartsWith($allowed,[StringComparison]::OrdinalIgnoreCase) -or [IO.Path]::GetFileName($exe) -ine 'LegionSpace.exe') { throw 'Select only LegionSpace.exe inside Program Files\Lenovo\LegionSpace.' }
$signature = Get-AuthenticodeSignature -LiteralPath $exe
if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch 'Lenovo') { throw 'This is not a valid Lenovo-signed launcher. Nothing changed.' }
$backup = Join-Path (Split-Path -Parent $exe) 'LegionSpace.Manual.exe'
if (Test-Path -LiteralPath $backup) { throw 'Backup already exists. Nothing changed.' }
$stateDir = Join-Path $env:LOCALAPPDATA 'LegionLGameBar'
New-Item -ItemType Directory -Force -Path $stateDir | Out-Null
$record = Join-Path $stateDir 'space-button-launch.json'
if (Test-Path -LiteralPath $record) { throw 'A backup record already exists. Restore it before disabling a different launcher.' }
$state = [pscustomobject]@{ Original=$exe; Backup=$backup; SHA256=(Get-FileHash -LiteralPath $exe -Algorithm SHA256).Hash }
# Save the recovery record before changing the file.
$manualLink = Join-Path ([Environment]::GetFolderPath('Programs')) 'Legion Space (Manual).lnk'
if (Test-Path -LiteralPath $manualLink) { throw 'Manual shortcut already exists. Nothing changed.' }
$state | Add-Member -NotePropertyName Shortcut -NotePropertyValue $manualLink
$state | ConvertTo-Json | Set-Content -LiteralPath $record -Encoding UTF8
try { Rename-Item -LiteralPath $exe -NewName ([IO.Path]::GetFileName($backup)) } catch { Remove-Item -LiteralPath $record; throw }
try {
    $link = (New-Object -ComObject WScript.Shell).CreateShortcut($manualLink)
    $link.TargetPath = $backup
    $link.WorkingDirectory = Split-Path -Parent $backup
    $link.Description = 'Open Legion Space manually; Legion L opens Game Bar instead.'
    $link.Save()
} catch {
    # A failed shortcut must not leave the normal launcher unavailable.
    Rename-Item -LiteralPath $backup -NewName 'LegionSpace.exe'
    Remove-Item -LiteralPath $record
    throw
}
Get-CimInstance Win32_Process | Where-Object { $_.ExecutablePath -eq $exe } | ForEach-Object { Stop-Process -Id $_.ProcessId -ErrorAction SilentlyContinue }
Write-Host "Legion L launch target removed. Space remains available through Legion Space (Manual) in Start. Original launcher: $backup. Lenovo services unchanged."

