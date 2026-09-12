param([switch]$EnJeu)
# Profil isole : l'atelier ne lit ni ne modifie la progression du joueur.
$ErrorActionPreference = 'Stop'
$racineApprenti = (Resolve-Path -LiteralPath "$PSScriptRoot/..").Path
$godotApprenti = Join-Path $racineApprenti 'tmp/outils/godot-4.7.1/Godot_v4.7.1-stable_win64.exe'
$env:APPDATA = Join-Path $racineApprenti 'tmp/profil/AppData'
$env:LOCALAPPDATA = Join-Path $racineApprenti 'tmp/profil/LocalAppData'
New-Item -ItemType Directory -Force $env:APPDATA,$env:LOCALAPPDATA | Out-Null
# Fenetre interactive demandee pour essayer les poses et tourner le personnage.
$argumentsApprenti = if ($EnJeu) { '--path . scenes/run.tscn' } else { '--path . --script sondes/atelier_apprenti.gd' }
Start-Process -FilePath $godotApprenti -WorkingDirectory $racineApprenti -ArgumentList $argumentsApprenti -WindowStyle Normal
