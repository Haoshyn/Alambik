class_name Mods
extends RefCounted

# Chaque famille applique une seule somme de bonus a sa base permanente.
# Seuls les tirs multiples reduisent leurs projectiles ; la defense ne coute pas d'attaque.
const CHAMPS_MULT := {
	"degats_projectile_mult": "degats",
	"cadence_mult": "cadence",
	"vitesse_mult": "vitesse",
	"portee_mult": "portee",
}

static func depuis_l_inventaire(inventaire: Array) -> Array:
	var liste: Array = []
	for id: String in inventaire:
		var reactif := CatalogueReactifs.par_id(id)
		if reactif != null:
			liste.append(reactif.mods.duplicate(true))
	return liste

static func facteur_heros(mods_liste: Array, cle: String) -> float:
	var bonus := 0.0
	var penalite := 1.0
	var final := 1.0
	for mod: Dictionary in mods_liste:
		var facteur := float(mod.get(cle, 1.0))
		if facteur < 1.0:
			penalite *= facteur
		else:
			bonus += facteur - 1.0
		if cle == "pv_max_mult":
			final *= float(mod.get("pv_max_final_mult", 1.0))
	return maxf(Reglages.MODS_PLANCHER, (1.0 + bonus) * penalite * final)

static func bonus_heros(mods_liste: Array, cle: String) -> float:
	var bonus := 0.0
	for mod: Dictionary in mods_liste:
		bonus += float(mod.get(cle, 0.0))
	return bonus

static func bonus_attaque(mods_liste: Array) -> float:
	return facteur_attaque_run(mods_liste) - 1.0

static func bonus_degats_critiques(mods_liste: Array, chance_brute: float) -> float:
	return bonus_heros(mods_liste, "degats_critiques_add") \
		+ maxf(0.0, chance_brute - 1.0) * bonus_heros(mods_liste, "conversion_critique")

static func facteur_attaque_run(mods_liste: Array) -> float:
	return facteur_heros(mods_liste, "attaque_mult")

static func appliquer(base: Tir, mods_liste: Array) -> Tir:
	var tir := base.copie()
	var reduction_salves := 1.0
	tir.degats *= facteur_attaque_run(mods_liste)
	for cle: String in CHAMPS_MULT:
		var champ: String = CHAMPS_MULT[cle]
		tir.set(champ, float(tir.get(champ)) * facteur_heros(mods_liste, cle))
	for mod: Dictionary in mods_liste:
		tir.salves += int(mod.get("salves_add", 0))
		tir.nb_projectiles += int(mod.get("nb_projectiles_add", 0))
		tir.projectiles_lateraux += int(mod.get("projectiles_lateraux_add", 0))
		tir.rebonds += int(mod.get("rebonds_add", 0))
		tir.perforations += int(mod.get("perforations_add", 0))
		tir.angle_eventail += float(mod.get("angle_eventail_add", 0.0))
		tir.ecart_lateral_min = maxf(tir.ecart_lateral_min, float(mod.get("ecart_lateral_min", 0.0)))
		# Salve garde un gain reel meme apres Battement triple ; leurs reductions
		# appartiennent a la meme famille, contrairement aux tirs paralleles.
		reduction_salves = minf(reduction_salves, float(mod.get("degats_salve_mult", 1.0)))
		tir.degats_finaux_projectile_mult *= float(mod.get("degats_finaux_projectile_mult", 1.0))
		if int(mod.get("projectiles_lateraux_add", 0)) > 0:
			tir.degats_projectiles_lateraux = ReglagesAugments.PROJECTILE_LATERAL_PART
		if float(mod.get("portee_mult", 1.0)) < 1.0:
			tir.portee_limitee = true
		for drapeau: String in mod.get("drapeaux", []):
			if drapeau not in tir.drapeaux:
				tir.drapeaux.append(drapeau)
	tir.degats_finaux_projectile_mult *= reduction_salves
	return tir
