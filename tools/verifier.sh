#!/bin/sh
# Equivalent Linux de verifier.ps1 : memes controles, profil isole par
# XDG_DATA_HOME pour ne jamais lire ni ecrire la vraie sauvegarde.
#
#   tools/verifier.sh                      tous les controles
#   tools/verifier.sh progression augments seulement ces controles
#   ACTUALISER_STATISTIQUES=1 tools/verifier.sh statistiques
cd "$(dirname "$0")/.." || exit 1
GODOT="${GODOT:-$HOME/Téléchargements/Godot_v4.7.1-stable_linux.x86_64}"
DOSSIER="tmp/verification_$(date +%Y%m%d_%H%M%S)_$$"
mkdir -p "$DOSSIER/profil"
export XDG_DATA_HOME="$PWD/$DOSSIER/profil"

controles="import:--editor --import
fonds:res://tools/verifier_fonds.tscn
decors:res://tools/verifier_decors.tscn
terrains:res://tools/verifier_terrains.tscn
statistiques:--script res://tools/statistiques/exporter.gd
progression:--script res://tools/verifier_progression.gd
patterns:--script res://tools/verifier_patterns.gd
reference:--script res://tools/verifier_reference.gd
sources:--script res://tools/verifier_sources.gd
augments:--script res://tools/verifier_augments.gd
reequilibrage:--script res://tools/verifier_reequilibrage.gd
niveaux_augments:--script res://tools/verifier_niveaux_augments.gd
projectiles:--script res://tools/verifier_projectiles.gd
bestiaire:--script res://tools/verifier_bestiaire.gd
degats_affiches:--script res://tools/verifier_degats_affiches.gd
simulation_augments:--script res://tools/verifier_simulation_augments.gd
parcours:--script res://tools/verifier_parcours.gd
retour_campagne:--script res://tools/verifier_retour_campagne.gd
equilibrage_progression:--script res://tools/verifier_equilibrage_progression.gd
rythme_progression:--script res://tools/verifier_rythme_progression.gd
maturation_progression:--script res://tools/verifier_maturation_progression.gd
soins:--script res://tools/verifier_soins_run.gd
migrations:--script res://tools/verifier_migrations.gd
passifs:res://tools/verifier_passifs.tscn
scenes:res://tools/verifier_scenes.tscn
heros_aster:res://tools/verifier_heros_aster.tscn
familiers:--script res://tools/verifier_familiers.gd"

echecs=0
echo "$controles" | while IFS=: read -r nom arguments; do
	if [ "$#" -gt 0 ]; then
		case " $* " in *" $nom "*) ;; *) continue ;; esac
	fi
	supplement=""
	if [ "$nom" = "statistiques" ] && [ -z "$ACTUALISER_STATISTIQUES" ]; then
		supplement="-- --verifier"
	fi
	journal="$DOSSIER/$nom.log"
	# shellcheck disable=SC2086
	"$GODOT" --headless --path . --log-file "$journal" $arguments $supplement \
		> "$DOSSIER/${nom}_console.log" 2>&1
	code=$?
	erreurs=$(grep -E 'SCRIPT ERROR:|Parse Error:|ERROR:|FAIL:' "$DOSSIER/${nom}_console.log" \
		| grep -v -E 'RID allocations of type|resources still in use at exit|leaked [0-9]+ bytes')
	if [ "$code" -ne 0 ] || [ -n "$erreurs" ]; then
		echo "ECHEC $nom (code $code) : $DOSSIER/${nom}_console.log"
		echo "$erreurs" | head -20
		echo "1" >> "$DOSSIER/echecs"
	else
		grep -E '^(OK|Listes|Verification|Vérification|Progression|Référence|Valeur des sources :|Augments :|Reequilibrage :|Projectiles :|Simulation augments :|Parcours :|Retour campagne :|Equilibrage progression :|Rythme progression :|Maturation progression :|Passifs :)' \
			"$DOSSIER/${nom}_console.log" | head -5
		echo "ok $nom"
	fi
done
if [ -f "$DOSSIER/echecs" ]; then
	echo "Des controles ont echoue. Journaux : $DOSSIER"
	exit 1
fi
echo "OK : controles termines. Journaux : $DOSSIER"
