extends RefCounted

# Meme budget ordinaire : dix choix, sans le legendaire supplementaire aleatoire.
const PROFILS := {
	"offensif": ["salve", "tir_multiple", "cadence_febrile", "cadence_febrile", "sceau_ruine", "pointe_lucide",
		"encre_mordante", "noyau_pesant", "noyau_pesant", "frappe_lourde"],
	"equilibre": ["salve", "tir_multiple", "cadence_febrile", "peau_cuivre", "baume_profond", "sceau_garde",
		"trait_transpercant", "peau_de_pierre", "encre_mordante", "courageux"],
	"defensif": ["peau_cuivre", "peau_cuivre", "sceau_garde", "baume_profond", "baume_profond", "pas_brume",
		"peau_de_pierre", "garde_remanente", "trait_transpercant", "egide"],
}

# Meme budget ; le mixte garde quatre choix offensifs ordinaires et une Egide.
# Les deux autres cas poussent les tirs frontaux ou toutes les diagonales guidees.
const NUANCE := {
	"mixte_sans_combo": ["cadence_febrile", "encrage_vif", "homing", "peau_cuivre", "baume_profond", "pas_brume",
		"encre_mordante", "garde_remanente", "peau_de_pierre", "egide"],
	"offensif_frontal": ["salve", "tir_multiple", "tir_multiple", "cadence_febrile", "cadence_febrile", "pointe_lucide",
		"noyau_pesant", "noyau_pesant", "encre_mordante", "frappe_lourde"],
	"synergie_guidee": ["tir_multiple", "tir_multiple", "cadence_febrile", "cadence_febrile", "homing", "pointe_lucide",
		"spirale", "spirale", "encre_mordante", "battement_triple"],
}

static func cas_nuance() -> Dictionary:
	var resultat := {"Mixte sans combo": NUANCE["mixte_sans_combo"].duplicate()}
	for nom: String in ["offensif_frontal", "synergie_guidee"]:
		for id: String in CatalogueReactifs.ids():
			var reactif := CatalogueReactifs.par_id(id)
			if reactif.rarete != Reactif.LEGENDAIRE: continue
			var inventaire: Array = NUANCE[nom].duplicate()
			inventaire[-1] = id
			var titre := "Offensif frontal" if nom == "offensif_frontal" else "Diagonales guidées"
			resultat[titre + " / " + reactif.nom] = inventaire
	return resultat
