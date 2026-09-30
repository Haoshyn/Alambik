class_name Mods
extends RefCounted

# Attaque et puissance des projectiles partagent leurs bonus directs de run.
# Les autres familles appliquent une seule somme de bonus a leur base permanente.
# Seuls les tirs multiples reduisent leurs projectiles ; la defense ne coute pas d'attaque.
const CHAMPS_MULT := {
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
	var chance_ajoutee := bonus_heros(mods_liste, "critique_add")
	var puissance_ajoutee := bonus_heros(mods_liste, "degats_critiques_add")
	var croisements := chance_ajoutee * puissance_ajoutee
	for mod: Dictionary in mods_liste:
		croisements -= float(mod.get("critique_add", 0.0)) * float(mod.get("degats_critiques_add", 0.0))
	var chance_finale := clampf(chance_brute, 0.0, 1.0)
	var chance_permanente := clampf(chance_brute - chance_ajoutee, 0.0, 1.0)
	# Chaque augment conserve son gain propre. Retirer le croisement entre la
	# chance d'un choix et la puissance d'un autre evite une synergie exponentielle.
	if chance_ajoutee > 0.0 and chance_finale > 0.0:
		puissance_ajoutee -= maxf(0.0, croisements) * (chance_finale - chance_permanente) \
			/ (chance_ajoutee * chance_finale)
	return puissance_ajoutee + maxf(0.0, chance_brute - 1.0) * bonus_heros(mods_liste, "conversion_critique")

static func facteur_attaque_run(mods_liste: Array) -> float:
	return facteur_heros(mods_liste, "attaque_mult")

static func appliquer(base: Tir, mods_liste: Array) -> Tir:
	var tir := base.copie()
	var salves_ajoutees := 0
	var puissance_salves := 1.0
	var copies_paralleles := 0
	tir.degats *= maxf(Reglages.MODS_PLANCHER,
		facteur_attaque_run(mods_liste) + facteur_heros(mods_liste, "degats_projectile_mult") - 1.0)
	for cle: String in CHAMPS_MULT:
		var champ: String = CHAMPS_MULT[cle]
		tir.set(champ, float(tir.get(champ)) * facteur_heros(mods_liste, cle))
	for mod: Dictionary in mods_liste:
		var salves := int(mod.get("salves_add", 0))
		# Compatibilite des anciens inventaires : seule la variante la plus longue
		# agit, avec sa propre perte de puissance, dans les deux ordres d'acquisition.
		if salves > salves_ajoutees:
			salves_ajoutees = salves
			puissance_salves = float(mod.get("degats_salve_mult", 1.0))
		tir.nb_projectiles += int(mod.get("nb_projectiles_add", 0))
		tir.projectiles_lateraux += int(mod.get("projectiles_lateraux_add", 0))
		tir.rebonds += int(mod.get("rebonds_add", 0))
		tir.perforations += int(mod.get("perforations_add", 0))
		tir.angle_eventail += float(mod.get("angle_eventail_add", 0.0))
		tir.ecart_lateral_min = maxf(tir.ecart_lateral_min, float(mod.get("ecart_lateral_min", 0.0)))
		copies_paralleles += int(mod.get("tirs_paralleles_add", 0))
		tir.degats_finaux_projectile_mult *= float(mod.get("degats_finaux_projectile_mult", 1.0))
		if int(mod.get("projectiles_lateraux_add", 0)) > 0:
			tir.degats_projectiles_lateraux = ReglagesAugments.PROJECTILE_LATERAL_PART
		if float(mod.get("portee_mult", 1.0)) < 1.0:
			tir.portee_limitee = true
		for drapeau: String in mod.get("drapeaux", []):
			if drapeau not in tir.drapeaux:
				tir.drapeaux.append(drapeau)
	tir.salves += salves_ajoutees
	tir.degats_finaux_projectile_mult *= ReglagesAugments.puissance_tirs_cumules(
		1 + salves_ajoutees, puissance_salves, copies_paralleles, facteur_heros(mods_liste, "cadence_mult"))
	return tir
