class_name ProgressionStatistiques
extends RefCounted

# Normalisation figee avec les profils : 14 * 1,6 * 0,65 * 0,75 * 1,01 + 6 * 0,75.
# Elle inclut la baguette, les critiques et le familier ; aucun sort encore.
const DPS_DEPART := 15.5292
const PV_EFFECTIFS_DEPART := 110.0

# Les profils viennent d'achats financables, jamais du build reel du joueur.
# Les Coeurs et synergies supplementaires gardent donc leur avantage.
static func facteur_pv(palier: int) -> float:
	var profil: Dictionary = ProfilsProgression.PROFILS[clampi(palier, 0, ProfilsProgression.PROFILS.size() - 1)]
	return float(profil["dps_reference"]) / DPS_DEPART

static func facteur_degats(palier: int) -> float:
	var profil: Dictionary = ProfilsProgression.PROFILS[clampi(palier, 0, ProfilsProgression.PROFILS.size() - 1)]
	return float(profil["pv_effectifs_reference"]) / PV_EFFECTIFS_DEPART

static func facteur_miniboss(_palier: int) -> float:
	return Reglages.MINIBOSS_PV_MULT
