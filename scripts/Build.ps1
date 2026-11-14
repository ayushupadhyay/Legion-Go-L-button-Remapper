param([string]$OutputDirectory = (Join-Path $PSScriptRoot '..\dist'))
$ErrorActionPreference = 'Stop'
$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (!(Test-Path -LiteralPath $compiler)) { throw '.NET Framework 4.x compiler not found. Use 64-bit Windows with .NET Framework 4.8.' }
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$output = Join-Path $OutputDirectory 'LegionLGameBar.exe'
$sources = @((Join-Path $PSScriptRoot '..\src\NativeHidLib.cs'), (Join-Path $PSScriptRoot '..\src\LegionLGameBar.cs'))
& $compiler /nologo /platform:x64 /target:winexe /reference:System.Windows.Forms.dll /reference:System.Drawing.dll "/out:$output" $sources
if ($LASTEXITCODE -ne 0) { throw 'Build failed.' }
Get-FileHash -LiteralPath $output -Algorithm SHA256
