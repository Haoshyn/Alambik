class_name Epreuves
extends RefCounted

# Une table locale par niveau : rejouer un niveau permet d'en monter les passifs.
const LOOTS := [
	["vigueur", "vitalite"],
	["moisson_vitale", "sang_froid"],
	["carapace", "celerite"],
	["pas_leger", "oeil_precis"],
	["impact_critique", "projectiles_vifs"],
	["soins_renforces"],
	["recuperation"],
	["rempart_initial"],
	["audace"],
	["butin_precieux"],
	["savoir_pratique"],
]
const PALIERS := [0, 2, 5, 8, 11, 14, 17, 20, 23, 26, 29]

static func nombre() -> int:
	return LOOTS.size()

static func palier(niveau: int) -> int:
	return PALIERS[clampi(niveau - 1, 0, nombre() - 1)]

static func campagne_requise(niveau: int) -> int:
	return maxi(Reglages.EPREUVE_NIVEAU_DEBLOCAGE, palier(niveau) + 1)

static func niveau_accessible(niveau_campagne: int, niveau_debloque: int) -> int:
	var accessible := 0
	for niveau in range(1, mini(nombre(), niveau_debloque) + 1):
		if niveau_campagne < campagne_requise(niveau): break
		accessible = niveau
	return accessible

static func passifs(niveau: int) -> Array:
	return LOOTS[clampi(niveau - 1, 0, nombre() - 1)].duplicate()

static func niveau_pour(id: String) -> int:
	for i in LOOTS.size():
		if id in LOOTS[i]: return i + 1
	return nombre() + 1

static func candidats(niveau: int, rangs: Dictionary) -> Array[String]:
	var resultat: Array[String] = []
	var nouveautes: Array[String] = []
	for id in passifs(niveau):
		var rang := int(rangs.get(id, 0))
		if rang <= 0:
			nouveautes.append(str(id))
		elif rang < Passifs.rang_max(str(id)):
			resultat.append(str(id))
	return nouveautes if not nouveautes.is_empty() else resultat

static func nouveau_passif_disponible(niveau: int, rangs: Dictionary) -> bool:
	for id in passifs(niveau):
		if int(rangs.get(id, 0)) <= 0:
			return true
	return false

static func provenance(id: String) -> String:
	return "Épreuve · niveau %d" % niveau_pour(id)
