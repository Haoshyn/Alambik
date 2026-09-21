class_name ProfilsProgression
extends RefCounted

# Parcours de confort utilise pour construire la difficulte fixe. Ce ne sont ni
# des statistiques lues sur la sauvegarde, ni des recompenses automatiques.
# Chaque entree suppose cinq victoires au chapitre precedent, les reprises
# utiles necessaires, les Epreuves deja ouvertes et les Mines indiquees.
# Les budgets detailles et leurs formules sont conserves dans plan_eq.txt.
const FORGE_ARME := [
	0, 1, 1, 2, 2, 3, 3, 3, 4, 4, 5, 5, 5, 6, 6, 7, 7, 7,
	8, 8, 9, 9, 9, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11,
]
const FORGE_BIJOU_PRINCIPAL := [
	0, 0, 0, 0, 1, 2, 2, 2, 2, 3, 3, 4, 4, 4, 5, 5, 6, 6,
	6, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
]
const RANGS_MAITRISE_OFFENSIVE := [
	0, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40,
	41, 42, 43, 44, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45, 45,
]
const RANGS_MAITRISE_DEFENSIVE := [
	0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 21, 22, 23, 24, 25, 26, 27,
	28, 29, 30, 31, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
]
const FORGE_FAMILIER := [
	0, 0, 0, 0, 0, 0, 0, 1, 1, 2, 2, 2, 3, 3, 4, 4, 4, 5,
	5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
]
const MINES_CUMULEES := [
	0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7,
	8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13, 14, 14, 15, 15, 16,
]
const COEURS_GARANTIS := [
	0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6,
	6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11,
]

static func par_palier(palier: int) -> Dictionary:
	var p := clampi(palier, 0, ProgressionStatistiques.MULTIPLICATEURS_PV.size() - 1)
	return {
		"niveau": p + 1,
		"victoires_campagne": p * 5,
		"forge_arme": FORGE_ARME[p],
		"forge_bijou_principal": FORGE_BIJOU_PRINCIPAL[p],
		"forge_familier": FORGE_FAMILIER[p],
		"rangs_offensifs": RANGS_MAITRISE_OFFENSIVE[p],
		"rangs_defensifs": RANGS_MAITRISE_DEFENSIVE[p],
		"mines": MINES_CUMULEES[p],
		"coeurs": COEURS_GARANTIS[p],
		"attaque_reference": 14.0 * float(ProgressionStatistiques.MULTIPLICATEURS_PV[p]),
		"pv_effectifs_reference": 110.0 * float(ProgressionStatistiques.MULTIPLICATEURS_DEGATS[p]),
	}
