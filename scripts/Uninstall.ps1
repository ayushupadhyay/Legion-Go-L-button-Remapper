# Removes this project's sign-in task and stops only its installed executable.
# Keeps files, logs and backup records so restoration remains possible.
$ErrorActionPreference = 'Stop'
$task = Get-ScheduledTask -TaskName 'Legion L Game Bar Community' -ErrorAction SilentlyContinue
if ($task) {
    Stop-ScheduledTask -TaskName $task.TaskName -ErrorAction SilentlyContinue
    Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false
}
$target = Join-Path $env:LOCALAPPDATA 'LegionLGameBar\LegionLGameBar.exe'
Get-CimInstance Win32_Process -Filter "Name='LegionLGameBar.exe'" | Where-Object { $_.ExecutablePath -eq $target } | ForEach-Object { Stop-Process -Id $_.ProcessId }
$menuLink = Join-Path ([Environment]::GetFolderPath('Programs')) 'Uninstall Legion Go L button Remapper.lnk'
if (Test-Path -LiteralPath $menuLink) {
    $link = (New-Object -ComObject WScript.Shell).CreateShortcut($menuLink)
    if ($link.Arguments -like ('*' + (Join-Path $env:LOCALAPPDATA 'LegionLGameBar\scripts\Setup.ps1') + '*')) {
        Remove-Item -LiteralPath $menuLink
    }
}
Write-Host 'Listener stopped and automatic startup removed. Files and Space backup records were kept.'
Write-Host 'If you changed the Legion L launch target using this project, run Restore-Space.ps1 as administrator.'

