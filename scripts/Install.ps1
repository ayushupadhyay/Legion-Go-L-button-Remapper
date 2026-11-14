param([switch]$NoStart)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$binary = Join-Path $root 'dist\LegionLGameBar.exe'
if (!(Test-Path -LiteralPath $binary)) { & (Join-Path $PSScriptRoot 'Build.ps1') | Out-Host }
$install = Join-Path $env:LOCALAPPDATA 'LegionLGameBar'
New-Item -ItemType Directory -Force -Path $install | Out-Null
$target = Join-Path $install 'LegionLGameBar.exe'
Get-CimInstance Win32_Process -Filter "Name='LegionLGameBar.exe'" | Where-Object { $_.ExecutablePath -eq $target } | ForEach-Object { Stop-Process -Id $_.ProcessId -ErrorAction Stop }
Copy-Item -LiteralPath $binary -Destination $target -Force
$installedScripts = Join-Path $install 'scripts'
New-Item -ItemType Directory -Force -Path $installedScripts | Out-Null
foreach ($name in @('Setup.ps1','Uninstall.ps1','Restore-Space.ps1','Block-LegionL-SpaceLaunch.ps1')) {
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot $name) -Destination (Join-Path $installedScripts $name) -Force
}
$menuLink = Join-Path ([Environment]::GetFolderPath('Programs')) 'Uninstall Legion Go L button Remapper.lnk'
$link = (New-Object -ComObject WScript.Shell).CreateShortcut($menuLink)
$link.TargetPath = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
$link.Arguments = '-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "' + (Join-Path $installedScripts 'Setup.ps1') + '" -Mode Uninstall'
$link.WorkingDirectory = $install
$link.Save()
$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$action = New-ScheduledTaskAction -Execute $target -WorkingDirectory $install
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $user
$trigger.Delay = 'PT5S'
$principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero) -StartWhenAvailable -MultipleInstances IgnoreNew -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
Register-ScheduledTask -TaskName 'Legion L Game Bar Community' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description 'Open Game Bar with Legion L on supported Legion Go S hardware.' -Force | Out-Null
if (!$NoStart) { Start-ScheduledTask -TaskName 'Legion L Game Bar Community' }
Write-Host "Installed in $install. Startup task: Legion L Game Bar Community."
