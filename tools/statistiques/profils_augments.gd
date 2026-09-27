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
