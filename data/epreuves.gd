class_name Epreuves
extends RefCounted

# Une table locale par niveau : rejouer un niveau permet d'en monter les sorts.
const LOOTS := [
	["onde_alchimique", "moisson_vitale"],
	["nova_de_givre", "sang_froid"],
	["grand_oeuvre"],
	["barrage_de_braise", "riposte_alchimique"],
	["temps_suspendu"],
	["impulsion_foudroyante", "reserve_ultime"],
	["rempart_initial"],
	["heritage_reactif"],
	["transmutation_totale"],
	["explosion_corrosive", "vortex_alchimique", "audace"],
	["echo_alchimique", "purification_totale"],
]
const PALIERS := [0, 2, 5, 8, 11, 14, 17, 20, 23, 26, 29]

static func nombre() -> int:
	return LOOTS.size()

static func palier(niveau: int) -> int:
	return PALIERS[clampi(niveau - 1, 0, nombre() - 1)]

static func sorts(niveau: int) -> Array:
	return LOOTS[clampi(niveau - 1, 0, nombre() - 1)].duplicate()

static func niveau_pour(id: String) -> int:
	for i in LOOTS.size():
		if id in LOOTS[i]: return i + 1
	return nombre() + 1

static func candidats(niveau: int, rangs: Dictionary) -> Array[String]:
	var resultat: Array[String] = []
	var nouveautes: Array[String] = []
	for id in sorts(niveau):
		var rang := int(rangs.get(id, 0))
		if rang <= 0:
			nouveautes.append(str(id))
		elif rang < Sorts.rang_max(str(id)):
			resultat.append(str(id))
	return nouveautes if not nouveautes.is_empty() else resultat

static func nouvelle_capacite_disponible(niveau: int, rangs: Dictionary) -> bool:
	for id in sorts(niveau):
		if int(rangs.get(id, 0)) <= 0:
			return true
	return false

static func provenance(id: String) -> String:
	return "Épreuve de magie · niveau %d" % niveau_pour(id)
