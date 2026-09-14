class_name Epreuves
extends RefCounted

# Une table locale par niveau : rejouer un niveau permet d'en monter les sorts.
const LOOTS := [
	["onde_alchimique", "rempart_initial"],
	["nova_de_givre", "heritage_reactif"],
	["grand_oeuvre"],
	["barrage_de_braise", "moisson_vitale"],
	["temps_suspendu"],
	["riposte_alchimique", "seconde_chance"],
	["impulsion_foudroyante", "reserve_ultime"],
	["sang_froid", "dernier_rempart"],
	["transmutation_totale"],
	["explosion_corrosive"],
	["audace", "echo_alchimique"],
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
	for id in sorts(niveau):
		if int(rangs.get(id, 0)) < Reglages.CAPACITE_RANG_MAX: resultat.append(str(id))
	return resultat

static func provenance(id: String) -> String:
	return "Épreuve de magie · niveau %d" % niveau_pour(id)
