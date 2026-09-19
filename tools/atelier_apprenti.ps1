param([switch]$EnJeu, [switch]$ApercuReference, [switch]$Sculpte)
# Profil isole : l'atelier ne lit ni ne modifie la progression du joueur.
$ErrorActionPreference = 'Stop'
$racineApprenti = (Resolve-Path -LiteralPath "$PSScriptRoot/..").Path
$godotApprenti = Join-Path $racineApprenti 'tmp/outils/godot-4.7.1/Godot_v4.7.1-stable_win64.exe'
$env:APPDATA = Join-Path $racineApprenti 'tmp/profil/AppData'
$env:LOCALAPPDATA = Join-Path $racineApprenti 'tmp/profil/LocalAppData'
New-Item -ItemType Directory -Force $env:APPDATA,$env:LOCALAPPDATA | Out-Null
# Fenetre interactive demandee pour essayer les poses et tourner le personnage.
$argumentsApprenti = if ($EnJeu) { '--path . scenes/run.tscn' } else { '--path . --script sondes/atelier_apprenti.gd' }
if (-not $EnJeu -and ($ApercuReference -or $Sculpte)) {
    $argumentsApprenti += ' --'
    if ($ApercuReference) { $argumentsApprenti += ' --apercu-reference' }
    if ($Sculpte) { $argumentsApprenti += ' --mage-sculpte' }
}
$journalApprenti = Join-Path $racineApprenti $(if ($Sculpte) { 'tmp/atelier-sculpte' } else { 'tmp/atelier-original' })
New-Item -ItemType Directory -Force $journalApprenti | Out-Null
Start-Process -FilePath $godotApprenti -WorkingDirectory $racineApprenti -ArgumentList $argumentsApprenti -WindowStyle Normal -RedirectStandardOutput "$journalApprenti/sortie.log" -RedirectStandardError "$journalApprenti/erreurs.log" -PassThru | Select-Object Id,ProcessName
