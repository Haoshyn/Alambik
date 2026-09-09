param(
    [string]$Godot = "$PSScriptRoot/../tmp/outils/godot-4.7.1/Godot_v4.7.1-stable_win64_console.exe",
    [switch]$VingtRuns
)
$ErrorActionPreference = 'Stop'
Set-Location "$PSScriptRoot/.."
$Godot = (Resolve-Path -LiteralPath $Godot).Path
New-Item -ItemType Directory -Force tmp/profil/AppData,tmp/profil/LocalAppData | Out-Null
# Les sondes ne lisent et n'ecrivent pas le profil reel du joueur.
$env:APPDATA = (Resolve-Path tmp/profil/AppData).Path
$env:LOCALAPPDATA = (Resolve-Path tmp/profil/LocalAppData).Path
$env:GODOT = $Godot.Replace('\','/')
$version = & $Godot --version
if ($version -notlike '4.7.1.*') { throw "Godot 4.7.1 requis, trouve : $version" }
$script = if ($VingtRuns) { './sondes/vingt_runs.sh' } else { './verifier.sh' }
& 'C:/Program Files/Git/bin/bash.exe' -c ('export PATH=/usr/bin:/bin:$PATH; ' + $script)
exit $LASTEXITCODE
