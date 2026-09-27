extends RefCounted

const Modeles = preload("res://tools/statistiques/modeles.gd")

# Le partage des synergies evite d'attribuer tous les produits croises a la
# derniere source ajoutee. Le socle nu reste explicite et les parts s'additionnent.
const SOURCES := ["attributs", "equipement", "maitrises", "passifs", "coeurs", "augments"]
const NOMS := ["Attributs", "Équipement", "Maîtrises", "Passifs", "Cœurs", "Augments"]
const SOURCES_PERMANENTES := ["attributs", "equipement", "maitrises", "passifs", "coeurs"]
const NOMS_PERMANENTS := ["Attributs", "Équipement", "Maîtrises", "Passifs", "Cœurs"]
const MESURES := ["attaque", "tir_moyen", "cadence", "critique", "dps_heros", "dps_familier", "dps", "pv", "defense", "pv_effectifs"]
const CLES_EQUIPEMENT := ["arme", "forge_arme", "familier", "forge_familier", "bijoux", "forge_bijoux"]

static func selectionner(configuration: Dictionary, masque: int, sources: Array = SOURCES) -> Dictionary:
	var selection := {"arme": "", "familier": "", "niveau": int(configuration.get("niveau", 1)),
		"conditions": bool(configuration.get("conditions", false))}
	for index in sources.size():
		if (masque & (1 << index)) == 0: continue
		var source: String = sources[index]
		if source == "equipement":
			for cle: String in CLES_EQUIPEMENT:
				if configuration.has(cle): selection[cle] = configuration[cle]
		elif configuration.has(source):
			selection[source] = configuration[source]
	return selection

static func calculer(configuration: Dictionary) -> Dictionary:
	return _calculer(configuration, SOURCES, NOMS)

static func calculer_permanent(configuration: Dictionary) -> Dictionary:
	# Les augments arrivent pendant la run : leur gain temporel est mesure
	# apres le socle, jamais partage parmi les sources de progression permanente.
	return _calculer(configuration, SOURCES_PERMANENTES, NOMS_PERMANENTS)

static func _calculer(configuration: Dictionary, sources: Array, noms: Array) -> Dictionary:
	var nombre_sources := sources.size()
	var masque_complet := (1 << nombre_sources) - 1
	var mesures: Array[Dictionary] = []
	for masque in range(masque_complet + 1):
		mesures.append(Modeles.mesurer(selectionner(configuration, masque, sources)))
	var parts: Array[Dictionary] = []
	var retraits: Array[Dictionary] = []
	for index in nombre_sources:
		var part := {}
		for cle: String in MESURES: part[cle] = 0.0
		for masque in range(masque_complet + 1):
			if (masque & (1 << index)) != 0: continue
			var taille := _nombre_bits(masque)
			var poids := _factorielle(taille) * _factorielle(nombre_sources - taille - 1) / _factorielle(nombre_sources)
			var avec: Dictionary = mesures[masque | (1 << index)]
			var sans: Dictionary = mesures[masque]
			for cle: String in MESURES:
				part[cle] = float(part[cle]) + poids * (float(avec[cle]) - float(sans[cle]))
		parts.append(part)
		retraits.append(mesures[masque_complet & ~(1 << index)])
	return {"base": mesures[0], "total": mesures[masque_complet], "parts": parts, "sans_source": retraits,
		"sources": sources.duplicate(), "noms": noms.duplicate()}

static func _nombre_bits(masque: int) -> int:
	var nombre := 0
	while masque > 0:
		nombre += masque & 1
		masque >>= 1
	return nombre

static func _factorielle(nombre: int) -> float:
	var resultat := 1.0
	for facteur in range(2, nombre + 1): resultat *= facteur
	return resultat
