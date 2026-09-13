class_name DraftLogique
extends RefCounted

# Un niveau propose trois Améliorations distincts parmi ceux que la run ne possede
# pas encore. Les six decisions restent ainsi comportementales et lisibles.

static func candidats(inventaire: Array) -> Array[String]:
	var liste: Array[String] = []
	for id in CatalogueReactifs.ids():
		if id not in inventaire:
			liste.append(id)
	return liste

static func proposer(inventaire: Array, rng: RandomNumberGenerator, nb := 3) -> Array[String]:
	var restants := candidats(inventaire)
	var tirage: Array[String] = []
	var familles: Array[String] = []
	while tirage.size() < nb and not restants.is_empty():
		# Trois familles donnent des choix de jeu distincts sans imposer un build.
		var varies: Array[String] = []
		for id in restants:
			if CatalogueReactifs.par_id(id).famille not in familles: varies.append(id)
		if varies.is_empty(): varies = restants.duplicate()
		var choix: String = varies[rng.randi_range(0,varies.size()-1)]
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
