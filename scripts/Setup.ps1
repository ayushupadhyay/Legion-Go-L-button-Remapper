param([ValidateSet('Install','Uninstall')][string]$Mode = 'Install')
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
$title = 'Legion Go L button Remapper'
$install = Join-Path $env:LOCALAPPDATA 'LegionLGameBar'
$record = Join-Path $install 'space-button-launch.json'
function Show-Info([string]$Text) {
    [Windows.Forms.MessageBox]::Show($Text,$title,'OK','Information') | Out-Null
}
function Ask-Yes([string]$Text) {
    return [Windows.Forms.MessageBox]::Show($Text,$title,'YesNo','Question') -eq 'Yes'
}
function Run-AdminScript([string]$Script,[string]$Launcher = '') {
    $arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $Script + '"'
    if ($Launcher) { $arguments += ' -LauncherPath "' + $Launcher + '"' }
    $process = Start-Process -FilePath "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList $arguments -Verb RunAs -WindowStyle Hidden -Wait -PassThru
    if ($process.ExitCode -ne 0) { throw 'The administrator step did not finish. Your listener can still be installed without changing Legion Space.' }
}
try {
    if ($Mode -eq 'Install') {
        if (!(Ask-Yes "Install Legion L to open Windows Game Bar?`n`nIt will start when you sign in. Lenovo power and fan controls stay unchanged.`n`nTested on Legion Go S in X-input mode only.")) { exit 0 }
        & (Join-Path $PSScriptRoot 'Install.ps1')
        if (!(Test-Path -LiteralPath $record)) {
            $prompt = "Also stop Legion L from opening Legion Space?`n`nSpace stays available through a new 'Legion Space (Manual)' Start-menu shortcut. Its original launcher filename changes, so older shortcuts may no longer work. Lenovo services stay running.`n`nThis step needs Windows administrator approval. Choose No to leave Space untouched."
            if (Ask-Yes $prompt) {
                $service = Get-CimInstance Win32_Service -Filter "Name='DAService'" | Select-Object -First 1
                if (!$service -or !$service.PathName) { throw 'Could not find Lenovo DAService. Listener installed; Space was left untouched.' }
                $servicePath = $service.PathName
                if ($servicePath -match '^"([^"]+\.exe)"') { $serviceExe=$matches[1] }
                elseif ($servicePath -match '^(.*?\.exe)(?:\s|$)') { $serviceExe=$matches[1] }
                else { throw 'Could not identify the Lenovo service folder. Space was left untouched.' }
                $launcher = Join-Path (Split-Path -Parent $serviceExe) 'LegionSpace.exe'
                if (!(Test-Path -LiteralPath $launcher)) { throw 'The stock Space launcher was not found. It may already be modified. Listener installed; Space was left untouched.' }
                Run-AdminScript (Join-Path $PSScriptRoot 'Block-LegionL-SpaceLaunch.ps1') $launcher
            }
        }
        Show-Info "Installed! Press Legion L to open Game Bar.`n`nIt will start at sign-in, including Xbox mode.`n`nTo uninstall later, search Start for 'Uninstall Legion Go L button Remapper', or double-click Uninstall.cmd in this download.`n`nPreview: test the button on your device before relying on it."
    } else {
        if (!(Ask-Yes 'Stop Legion L remapping and remove its automatic startup?')) { exit 0 }
        & (Join-Path $PSScriptRoot 'Uninstall.ps1')
        if (Test-Path -LiteralPath $record) {
            if (Ask-Yes "Restore Legion Space's original launcher and shortcuts too?`n`nWindows will ask for administrator approval. Nothing will overwrite a launcher recreated by a Lenovo update.") {
                Run-AdminScript (Join-Path $PSScriptRoot 'Restore-Space.ps1')
            }
        }
        Show-Info "The listener is stopped and its automatic startup is removed.`n`nLocal files and any remaining Space recovery record were kept in $install."
    }
} catch {
    [Windows.Forms.MessageBox]::Show($_.Exception.Message,$title,'OK','Error') | Out-Null
    exit 1
}
