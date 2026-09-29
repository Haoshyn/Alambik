param(
    [string]$Godot = '',
    [switch]$ActualiserStatistiques
)

$ErrorActionPreference = 'Stop'
$racineProjet = Split-Path $PSScriptRoot -Parent
if (-not $Godot) { $Godot = $env:GODOT }
if (-not $Godot) {
    $Godot = Join-Path $racineProjet 'tmp/outils/godot-4.7.1/Godot_v4.7.1-stable_win64_console.exe'
}
if (-not (Test-Path -LiteralPath $Godot)) {
    $commandeGodot = Get-Command godot -ErrorAction SilentlyContinue
    if (-not $commandeGodot) { throw 'Indiquer -Godot CHEMIN ou la variable GODOT.' }
    $Godot = $commandeGodot.Source
}
$Godot = (Resolve-Path -LiteralPath $Godot).Path
$dossierControle = Join-Path $racineProjet ('tmp/verification_' + (Get-Date -Format 'yyyyMMdd_HHmmss'))
$profilControle = Join-Path $dossierControle 'profil'
New-Item -ItemType Directory -Path $profilControle -Force | Out-Null
$ancienAppData = $env:APPDATA
$ancienLocalAppData = $env:LOCALAPPDATA

function Executer-Controle([string]$Nom, [string[]]$ArgumentsGodot) {
    $journal = Join-Path $dossierControle ($Nom + '.log')
    $sortie = & $Godot --headless --path $racineProjet --log-file $journal @ArgumentsGodot 2>&1
    $codeGodot = $LASTEXITCODE
    $sortie | Set-Content -LiteralPath (Join-Path $dossierControle ($Nom + '_console.log')) -Encoding utf8
    $erreurs = @($sortie | Select-String -Pattern 'SCRIPT ERROR:|Parse Error:|ERROR:|FAIL:')
    if ($Nom -eq 'import') {
        # L'editeur headless 4.7.1 peut signaler ses caches a la fermeture.
        # Ces diagnostics restent dans le journal ; les erreurs de script echouent.
        $erreurs = @($erreurs | Where-Object { $_ -notmatch "RID allocations of type|resources still in use at exit" })
    }
    if ($codeGodot -ne 0 -or $erreurs.Count -gt 0) {
        $sortie | Write-Output
        throw "Controle $Nom echoue (code $codeGodot). Journal : $journal"
    }
    $sortie | Where-Object { $_ -match '^(OK|Listes|Verification|Vérification|Progression|Référence|Valeur des sources :|Augments :|Projectiles :|Simulation augments :|Parcours :|Retour campagne :|Equilibrage progression :|Rythme progression :|Maturation progression :)' } | Write-Output
}

try {
    # Les autoloads lisent user:// meme pendant certains controles de donnees.
    $env:APPDATA = $profilControle
    $env:LOCALAPPDATA = $profilControle
    Executer-Controle -Nom 'import' -ArgumentsGodot @('--editor', '--import')
    Executer-Controle -Nom 'decors' -ArgumentsGodot @('res://tools/verifier_decors.tscn')
    Executer-Controle -Nom 'terrains' -ArgumentsGodot @('res://tools/verifier_terrains.tscn')
    $argumentsStatistiques = @('--script', 'res://tools/statistiques/exporter.gd')
    if (-not $ActualiserStatistiques) { $argumentsStatistiques += @('--', '--verifier') }
    Executer-Controle -Nom 'statistiques' -ArgumentsGodot $argumentsStatistiques
    Executer-Controle -Nom 'progression' -ArgumentsGodot @('--script', 'res://tools/verifier_progression.gd')
    Executer-Controle -Nom 'patterns' -ArgumentsGodot @('--script', 'res://tools/verifier_patterns.gd')
    Executer-Controle -Nom 'reference' -ArgumentsGodot @('--script', 'res://tools/verifier_reference.gd')
    Executer-Controle -Nom 'sources' -ArgumentsGodot @('--script', 'res://tools/verifier_sources.gd')
    Executer-Controle -Nom 'augments' -ArgumentsGodot @('--script', 'res://tools/verifier_augments.gd')
    Executer-Controle -Nom 'niveaux_augments' -ArgumentsGodot @('--script', 'res://tools/verifier_niveaux_augments.gd')
    Executer-Controle -Nom 'projectiles' -ArgumentsGodot @('--script', 'res://tools/verifier_projectiles.gd')
    Executer-Controle -Nom 'bestiaire' -ArgumentsGodot @('--script', 'res://tools/verifier_bestiaire.gd')
    Executer-Controle -Nom 'degats_affiches' -ArgumentsGodot @('--script', 'res://tools/verifier_degats_affiches.gd')
    Executer-Controle -Nom 'simulation_augments' -ArgumentsGodot @('--script', 'res://tools/verifier_simulation_augments.gd')
    Executer-Controle -Nom 'parcours' -ArgumentsGodot @('--script', 'res://tools/verifier_parcours.gd')
    Executer-Controle -Nom 'retour_campagne' -ArgumentsGodot @('--script', 'res://tools/verifier_retour_campagne.gd')
    Executer-Controle -Nom 'equilibrage_progression' -ArgumentsGodot @('--script', 'res://tools/verifier_equilibrage_progression.gd')
    Executer-Controle -Nom 'rythme_progression' -ArgumentsGodot @('--script', 'res://tools/verifier_rythme_progression.gd')
    Executer-Controle -Nom 'maturation_progression' -ArgumentsGodot @('--script', 'res://tools/verifier_maturation_progression.gd')
    Executer-Controle -Nom 'soins' -ArgumentsGodot @('--script', 'res://tools/verifier_soins_run.gd')
    Executer-Controle -Nom 'migrations' -ArgumentsGodot @('--script', 'res://tools/verifier_migrations.gd')
    Executer-Controle -Nom 'scenes' -ArgumentsGodot @('res://tools/verifier_scenes.tscn')
    Executer-Controle -Nom 'heros_aster' -ArgumentsGodot @('res://tools/verifier_heros_aster.tscn')
    Write-Output "OK : controles termines. Journaux : $dossierControle"
}
finally {
    $env:APPDATA = $ancienAppData
    $env:LOCALAPPDATA = $ancienLocalAppData
}
