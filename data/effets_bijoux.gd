class_name EffetsBijoux
extends RefCounted

const PALIERS := [10]
# Trois pouvoirs par monde : anneau, bague, collier. Aucun effet de cadence.
const PAR_MONDE := [
	["familier_tireur", "chaine_alchimique", "familier_gardien"],
	["meteores", "tir_multiple", "onde_de_choc"],
	["tir_multiple", "orbes_chargees", "familier_gardien"],
	["chaine_alchimique", "spirale", "chaine_alchimique"],
	["zone_heros", "trait_transpercant", "zone_heros"],
	["spirale", "familier_tireur", "chaine_alchimique"],
	["trait_transpercant", "orbes_chargees", "onde_de_choc"],
	["fragmentation", "familier_gardien", "familier_gardien"],
	["trait_transpercant", "chaine_alchimique", "meteores"],
	["tir_multiple", "spirale", "meteores"],
]

static func parcours(monde: int, profil: int) -> Array:
	return [PAR_MONDE[monde][profil]]
