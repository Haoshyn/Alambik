param([int]$Graine = 1, [switch]$DepuisDebut)
# Essai interactif isole : aucune lecture ni ecriture dans le profil du joueur.
$ErrorActionPreference = 'Stop'
$racineFusions = (Resolve-Path -LiteralPath "$PSScriptRoot/..").Path
$godotFusions = Join-Path $racineFusions 'tmp/outils/godot-4.7.1/Godot_v4.7.1-stable_win64.exe'
$env:APPDATA = Join-Path $racineFusions 'tmp/essai-fusions/AppData'
$env:LOCALAPPDATA = Join-Path $racineFusions 'tmp/essai-fusions/LocalAppData'
New-Item -ItemType Directory -Force $env:APPDATA,$env:LOCALAPPDATA | Out-Null
$argumentsFusions = "--path . scenes/run.tscn -- --vierge --mode=grimoire --chapitre=1 --graine=$Graine"
if (-not $DepuisDebut) { $argumentsFusions += ' --salle=4 --dote=3' }
# La fenetre est visible car cet outil sert a essayer la nouvelle mecanique.
Start-Process -FilePath $godotFusions -WorkingDirectory $racineFusions -ArgumentList $argumentsFusions -WindowStyle Normal
