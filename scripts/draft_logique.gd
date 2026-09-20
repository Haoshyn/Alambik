class_name DraftLogique
extends RefCounted

# Une offre partage sa rarete : un pouvoir ne concurrence jamais un petit bonus.
# Sans rarete explicite, les modes annexes piochent parmi les rares et epiques.
static func candidats(inventaire: Array, rarete := "", niveau := 0, contexte: Dictionary = {}) -> Array[String]:
	var liste: Array[String] = []
	for id in CatalogueReactifs.ids():
		if not bool(contexte.get("avec_sorts", true)) and id in CatalogueReactifs.AUGMENTS_SORTS:
			continue
		var reactif := CatalogueReactifs.par_id(id)
		if rarete.is_empty() and reactif.rarete in [Reactif.COMMUN, Reactif.LEGENDAIRE]:
			continue
		if not rarete.is_empty() and reactif.rarete != rarete:
			continue
		if copies(inventaire, id) >= reactif.copies_permises():
			continue
		if niveau > ProgressionAugments.DERNIER_NIVEAU_AVIDITE and id == "avidite":
			continue
		var compatible := true
		for drapeau: String in contexte.get("drapeaux_arme", []):
			if id in ProgressionAugments.INCOMPATIBLES_ARMES.get(drapeau, []):
				compatible = false
		for autre: String in ProgressionAugments.INCOMPATIBLES.get(id, []):
			if autre in inventaire:
				compatible = false
		if compatible:
			liste.append(id)
	return liste

static func proposer(inventaire: Array, rng: RandomNumberGenerator, nb := ProgressionAugments.NOMBRE_CHOIX,
		rarete := "", niveau := 0, eviter: Array = [], contexte: Dictionary = {}) -> Array[String]:
	if rarete == Reactif.COMMUN:
		# Le soin est une vraie carte : trois choix fixes, aucune quatrieme option.
		var communs: Array[String] = []
		communs.assign(ProgressionAugments.COMMUNS)
		return communs
	var restants := candidats(inventaire, rarete, niveau, contexte)
	var tirage: Array[String] = []
	var familles: Array[String] = []
	while tirage.size() < nb and not restants.is_empty():
		var nouveaux: Array[String] = []
		for id in restants:
			if id not in eviter:
				nouveaux.append(id)
		var source: Array[String] = nouveaux if not nouveaux.is_empty() else restants
		var varies: Array[String] = []
		# Les legendaires ont toutes la meme chance, sans imposer celle de sorts.
		for id in source:
			if rarete != Reactif.LEGENDAIRE and CatalogueReactifs.par_id(id).famille not in familles:
				varies.append(id)
		if varies.is_empty():
			varies = source.duplicate()
		var choix: String = varies[rng.randi_range(0, varies.size() - 1)]
		tirage.append(choix)
		familles.append(CatalogueReactifs.par_id(choix).famille)
		restants.erase(choix)
	return tirage

static func copies(inventaire: Array, id: String) -> int:
	return inventaire.count(id)

static func proposer_halte(inventaire: Array, rng: RandomNumberGenerator) -> Array[String]:
	var exclus := inventaire.duplicate()
	for id in CatalogueReactifs.ids():
		if CatalogueReactifs.par_id(id).famille not in [CatalogueReactifs.PROJECTILE, CatalogueReactifs.PHENOMENE]:
			exclus.append(id)
	var choix := proposer(exclus, rng)
	return choix if not choix.is_empty() else proposer(inventaire, rng)
