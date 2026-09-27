extends SceneTree

const PROFILS := preload("res://tools/statistiques/profils_augments.gd").PROFILS
const CLES_AUTORISEES := [
	"attaque_mult", "cadence_mult", "vitesse_mult", "portee_mult", "pv_max_mult", "pv_max_final_mult", "defense_mult",
	"deplacement_mult", "soin_mult", "degats_subis_mult", "experience_mult", "gouttes_mult",
	"critique_add", "degats_critiques_add", "conversion_critique", "invulnerabilite_add", "boucliers_salle_add",
	"salves_add", "degats_salve_mult", "rebonds_add", "perforations_add", "nb_projectiles_add",
	"projectiles_lateraux_add", "angle_eventail_add", "ecart_lateral_min",
	"degats_projectile_mult", "degats_finaux_projectile_mult", "drapeaux",
]
const DRAPEAUX_AUTORISES := ["homing", "perfore_tout", "perforation_sans_perte", "indelebile",
	"egide", "courageux", "elan_vital", "ricochet_perforation_infinie"]
const IDS_ATTENDUS := ["salve", "tir_multiple", "homing", "cadence_febrile", "avidite",
	"sceau_garde", "sceau_ruine", "pointe_lucide", "peau_cuivre", "pas_brume", "encrage_vif",
	"baume_profond", "ricochet", "perforation", "spirale", "trait_transpercant", "peau_de_pierre",
	"elan_vital", "garde_remanente", "encre_mordante", "noyau_pesant", "frappe_lourde", "egide",
	"courageux", "battement_triple", "couronne_incisive"]
const FACTEURS := ["attaque_mult", "cadence_mult", "vitesse_mult", "portee_mult", "pv_max_mult", "pv_max_final_mult",
	"defense_mult", "deplacement_mult", "soin_mult", "degats_subis_mult", "experience_mult", "gouttes_mult"]

class CibleProjectile extends Node2D:
	var coups := 0
	var degats: Array[float] = []
	func recevoir_degats(montant: float, _effets: Array = []) -> void:
		coups += 1
		degats.append(montant)

var _erreurs: Array[String] = []

func _init() -> void:
	# Les autoloads doivent exister avant d'exercer le recalcul reel du heros.
	_verifier.call_deferred()

func _verifier() -> void:
	_verifier_catalogue()
	_verifier_tirages()
	_verifier_profils()
	_verifier_valeur_defense()
	_verifier_tirs_et_ordre()
	_verifier_multiplication_tirs()
	_verifier_projectiles_paralleles()
	_verifier_trajectoires()
	_verifier_recalcul_heros()
	for erreur in _erreurs:
		push_error(erreur)
	if _erreurs.is_empty():
		print("Augments : catalogue sans malus ordinaires, offres, profils, tirs et effets du héros vérifiés.")
	quit(0 if _erreurs.is_empty() else 1)

func _exiger(condition: bool, message: String) -> void:
	if not condition:
		_erreurs.append(message)

func _verifier_catalogue() -> void:
	_exiger(CatalogueReactifs.ids().size() == IDS_ATTENDUS.size(), "Le catalogue doit contenir 26 augments")
	for id: String in IDS_ATTENDUS:
		_exiger(CatalogueReactifs.par_id(id) != null, "Augment absent : " + id)
	for id in CatalogueReactifs.ids():
		var reactif := CatalogueReactifs.par_id(id)
		_exiger(reactif.id == id and reactif.copies_permises() > 0, "Identifiant ou limite invalide : " + id)
		_exiger(reactif.rarete in [Reactif.RARE, Reactif.EPIQUE, Reactif.LEGENDAIRE], "Un augment possède une rareté retirée : " + id)
		_exiger(not DetailsReactif.lignes(reactif).is_empty(), "Carte sans chiffres : " + id)
		for cle: String in reactif.mods:
			_exiger(cle in CLES_AUTORISEES, "Effet sans contrôle : " + id + "/" + cle)
			if cle == "drapeaux":
				for drapeau: String in reactif.mods[cle]:
					_exiger(drapeau in DRAPEAUX_AUTORISES, "Comportement sans contrôle : " + id + "/" + drapeau)
			else:
				var valeur := float(reactif.mods[cle])
				_exiger(is_finite(valeur) and valeur >= 0.0, "Valeur invalide : " + id + "/" + cle)
				# Les comptes, secondes, angles et distances ne sont pas des pourcentages.
				if cle.ends_with("_mult") or cle in ["critique_add", "degats_critiques_add", "conversion_critique"]:
					_exiger(is_equal_approx(valeur * 20.0, roundf(valeur * 20.0)),
						"Pourcentage non arrondi à un multiple de 5 : " + id + "/" + cle)
				if cle.ends_with("_mult"):
					_exiger(valeur > 0.0, "Facteur nul : " + id + "/" + cle)
					if cle == "degats_subis_mult":
						_exiger(valeur <= 1.0, "Malus de dégâts subis : " + id)
					elif cle in ["degats_salve_mult", "degats_finaux_projectile_mult"]:
						_exiger(id in ["salve", "tir_multiple", "battement_triple"] and is_equal_approx(valeur, 0.80),
							"Seuls les augments de tirs multiples réduisent les projectiles de 20 % : " + id)
					else:
						_exiger(valeur >= 1.0, "Malus ordinaire interdit : " + id + "/" + cle)

func _verifier_tirages() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 27092026
	for rarete: String in [Reactif.RARE, Reactif.EPIQUE, Reactif.LEGENDAIRE]:
		var offre := DraftLogique.proposer([], rng, ProgressionAugments.NOMBRE_CHOIX, rarete)
		_exiger(offre.size() == ProgressionAugments.NOMBRE_CHOIX, "Offre incomplète : " + rarete)
		var deja_vus: Array[String] = []
		for id in offre:
			_exiger(id not in deja_vus, "Doublon dans une offre : " + id)
			_exiger(CatalogueReactifs.par_id(id).rarete == rarete, "Rareté incohérente : " + id)
			deja_vus.append(id)
	for id in CatalogueReactifs.ids():
		var reactif := CatalogueReactifs.par_id(id)
		var plein: Array[String] = []
		for _copie in reactif.copies_permises():
			plein.append(id)
		_exiger(id not in DraftLogique.candidats(plein, reactif.rarete), "Limite de copies ignorée : " + id)
	_exiger("avidite" not in DraftLogique.candidats([], Reactif.RARE,
		ProgressionAugments.DERNIER_NIVEAU_AVIDITE + 1), "Avidité proposée trop tard")
	var salve := CatalogueReactifs.par_id("salve")
	var double_tir := CatalogueReactifs.par_id("tir_multiple")
	_exiger(salve.rarete == Reactif.RARE and salve.copies_permises() == 1, "Salve doit rester rare et unique")
	_exiger(double_tir.rarete == Reactif.RARE and double_tir.copies_permises() == ReglagesAugments.COPIES_MAX,
		"Tir double doit rester rare et cumulable")
	_exiger("tir_multiple" in DraftLogique.candidats(["tir_multiple"], Reactif.RARE), "La deuxième copie de Tir double n'est pas proposée")
	var triple := CatalogueReactifs.par_id("battement_triple")
	_exiger(triple.rarete == Reactif.LEGENDAIRE and triple.copies_permises() == 1,
		"Battement triple doit rester légendaire et unique")
	_exiger(CatalogueReactifs.par_id("spirale").copies_permises() == 2, "Éventail doit rester limité à deux copies")

func _verifier_profils() -> void:
	var mesures := {}
	for nom: String in PROFILS:
		var inventaire: Array = PROFILS[nom]
		var raretes := {}
		for id: String in inventaire:
			var reactif := CatalogueReactifs.par_id(id)
			_exiger(reactif != null, "Choix du profil absent : " + id)
			if reactif == null:
				return
			_exiger(inventaire.count(id) <= reactif.copies_permises(), "Profil au-dessus d'une limite : " + nom + "/" + id)
			raretes[reactif.rarete] = int(raretes.get(reactif.rarete, 0)) + 1
		_exiger(inventaire.size() == ProgressionAugments.niveau_max(), "Le profil doit contenir un choix par niveau : " + nom)
		_exiger(int(raretes.get(Reactif.RARE, 0)) == ProgressionAugments.niveau_max() - ProgressionAugments.NOMBRE_EPIQUES - 1,
			"Budget rare incohérent : " + nom)
		_exiger(int(raretes.get(Reactif.EPIQUE, 0)) == ProgressionAugments.NOMBRE_EPIQUES,
			"Budget épique incohérent : " + nom)
		_exiger(int(raretes.get(Reactif.LEGENDAIRE, 0)) == 1, "Budget légendaire incohérent : " + nom)
		var mesure := mesurer(inventaire)
		mesures[nom] = mesure
		for cle: String in mesure:
			_exiger(is_finite(float(mesure[cle])) and float(mesure[cle]) >= 0.0, "Mesure invalide : " + nom + "/" + cle)
		_exiger(float(mesure["pv"]) >= 1.0 and float(mesure["defense"]) >= 1.0
			and float(mesure["degats_subis"]) <= 1.0 and float(mesure["vie_effective"]) >= 1.0,
			"Un profil introduit un malus de survie : " + nom)
		print("Profil %s : %s" % [nom, JSON.stringify(mesure)])
	var offensif: Dictionary = mesures["offensif"]
	var equilibre: Dictionary = mesures["equilibre"]
	var defensif: Dictionary = mesures["defensif"]
	_exiger(float(offensif["dps_central"]) > float(equilibre["dps_central"])
		and float(equilibre["dps_central"]) > float(defensif["dps_central"]), "Les choix offensifs ne renforcent pas le DPS")
	_exiger(float(defensif["vie_effective"]) > float(equilibre["vie_effective"])
		and float(equilibre["vie_effective"]) > float(offensif["vie_effective"]), "Les choix défensifs ne renforcent pas la survie")

func _verifier_valeur_defense() -> void:
	var comparaisons: Array[Dictionary] = [
		{"defense": "sceau_garde", "attaque": "sceau_ruine"},
		{"defense": "peau_de_pierre", "attaque": "noyau_pesant"},
		{"defense": "egide", "attaque": "frappe_lourde"},
	]
	for comparaison in comparaisons:
		var id_defense: String = comparaison["defense"]
		var id_attaque: String = comparaison["attaque"]
		_exiger(CatalogueReactifs.par_id(id_defense).rarete == CatalogueReactifs.par_id(id_attaque).rarete,
			"La comparaison défensive doit porter sur une même rareté : " + id_defense + "/" + id_attaque)
		var defense := mesurer([id_defense])
		var attaque := mesurer([id_attaque])
		var gain_survie := float(defense["vie_effective"]) - 1.0
		var gain_dps := float(attaque["dps_tous_projectiles"]) - 1.0
		_exiger(gain_survie >= gain_dps * 0.85 and gain_survie <= gain_dps * 1.15,
			"Les gains offensif et defensif de meme rarete doivent rester comparables : " + id_defense + "/" + id_attaque)
	var egide := mesurer(["egide"])
	_exiger(float(egide["vie_effective"]) <= 1.8 and float(egide["vie_effective"]) >= 1.5,
		"Egide doit rester dans le budget d'un legendaire")
	_exiger(float(mesurer(["egide", "peau_de_pierre"])["vie_effective"]) <= 2.3,
		"Deux defenses ne doivent pas multiplier la resistance par six")

static func mesurer(inventaire: Array) -> Dictionary:
	var stats := Stats.depuis_reglages()
	var mods := Mods.depuis_l_inventaire(inventaire)
	var base := Tir.de_base(stats)
	var tir := Mods.appliquer(base, mods)
	var chance_brute := stats.critique + stats.critique_excedentaire + Mods.bonus_heros(mods, "critique_add")
	var critique := clampf(chance_brute, 0.0, 1.0)
	var multiplicateur_critique := Reglages.CRITIQUE_MULT_BASE + stats.degats_critiques + Mods.bonus_degats_critiques(mods, chance_brute)
	var critique_moyen := (1.0 + critique * (multiplicateur_critique - 1.0)) \
		/ (1.0 + stats.critique * (Reglages.CRITIQUE_MULT_BASE + stats.degats_critiques - 1.0))
	var dps_central := tir.degats * tir.cadence * float(tir.salves) * tir.degats_finaux_projectile_mult \
		* critique_moyen / (base.degats * base.cadence)
	var somme_projectiles := 0.0
	for index in tir.nb_projectiles:
		somme_projectiles += tir.facteur_projectile(index)
	var vie_effective := Mods.facteur_heros(mods, "pv_max_mult") \
		* (Reglages.DEFENSE_REFERENCE + stats.defense * Mods.facteur_heros(mods, "defense_mult")) \
		/ (Reglages.DEFENSE_REFERENCE + stats.defense) / Mods.facteur_heros(mods, "degats_subis_mult")
	return {"dps_central": dps_central, "dps_tous_projectiles": dps_central * somme_projectiles,
		"pv": Mods.facteur_heros(mods, "pv_max_mult"), "defense": Mods.facteur_heros(mods, "defense_mult"),
		"degats_subis": Mods.facteur_heros(mods, "degats_subis_mult"), "vie_effective": vie_effective,
		"boucliers": Mods.bonus_heros(mods, "boucliers_salle_add")}

func _verifier_tirs_et_ordre() -> void:
	var stats := Stats.depuis_reglages()
	var base := Tir.de_base(stats)
	for nom: String in PROFILS:
		var inventaire: Array = PROFILS[nom]
		var inverse := inventaire.duplicate()
		inverse.reverse()
		var mods := Mods.depuis_l_inventaire(inventaire)
		var mods_inverses := Mods.depuis_l_inventaire(inverse)
		for cle: String in FACTEURS:
			_exiger(is_equal_approx(Mods.facteur_heros(mods, cle), Mods.facteur_heros(mods_inverses, cle)),
				"Ordre de cumul influent : " + nom + "/" + cle)
		var tir := Mods.appliquer(base, mods)
		var tir_inverse := Mods.appliquer(base, mods_inverses)
		for champ: String in ["degats", "cadence", "vitesse", "portee", "salves", "nb_projectiles",
			"rebonds", "perforations", "degats_finaux_projectile_mult"]:
			_exiger(is_equal_approx(float(tir.get(champ)), float(tir_inverse.get(champ))), "Ordre des tirs influent : " + nom + "/" + champ)
	_exiger(base.salves == 1 and base.nb_projectiles == 1 and is_equal_approx(base.degats, stats.degats), "Le tir de base a été muté")
	var lateral := Mods.appliquer(base, Mods.depuis_l_inventaire(["spirale"]))
	_exiger(lateral.nb_projectiles == base.nb_projectiles + 2 and lateral.projectiles_lateraux == 2
		and is_equal_approx(lateral.facteur_projectile(1), 0.65) and is_equal_approx(lateral.facteur_projectile(2), 0.65)
		and is_equal_approx(lateral.degats, base.degats), "Éventail doit ajouter deux diagonales à 65 % sans réduire l'attaque")
	var cadence := Mods.appliquer(base, Mods.depuis_l_inventaire(["cadence_febrile"]))
	_exiger(is_equal_approx(cadence.cadence, base.cadence * float(CatalogueReactifs.par_id("cadence_febrile").mods["cadence_mult"])), "Cadence febrile doit appliquer son bonus une seule fois")
	var ricochet := Mods.appliquer(base, Mods.depuis_l_inventaire(["ricochet"]))
	_exiger(ricochet.rebonds == 3, "Ricochet doit accorder trois rebonds")
	var perforation := Mods.appliquer(base, Mods.depuis_l_inventaire(["perforation"]))
	_exiger("perfore_tout" in perforation.drapeaux and "perforation_sans_perte" in perforation.drapeaux
		and is_equal_approx(perforation.degats, base.degats * 1.15), "Perforation doit traverser sans perte avec 15 % de dégâts de projectile")
	_exiger(is_equal_approx(Mods.facteur_attaque_run(Mods.depuis_l_inventaire(["perforation"])), 1.0),
		"Le bonus de Perforation ne doit pas augmenter l'attaque des familiers")
	var trajectoires := Mods.appliquer(base, Mods.depuis_l_inventaire(["ricochet", "perforation"]))
	_exiger("ricochet_perforation_infinie" in trajectoires.drapeaux,
		"Ricochet et Perforation doivent activer leurs rebonds illimités sans perte")
	var indelebile := Mods.appliquer(base, Mods.depuis_l_inventaire(["trait_transpercant"]))
	_exiger("indelebile" in indelebile.drapeaux and is_equal_approx(indelebile.vitesse, base.vitesse * 1.20),
		"Tir indélébile doit conserver son effet et ses 20 % de vitesse")
	var force := Mods.appliquer(base, Mods.depuis_l_inventaire(["frappe_lourde", "salve", "tir_multiple"]))
	_exiger(is_equal_approx(force.degats, base.degats * float(CatalogueReactifs.par_id("frappe_lourde").mods["attaque_mult"])) and is_equal_approx(force.degats_finaux_projectile_mult, 0.64),
		"Force cataclysmique doit renforcer l'attaque sans annuler les couts de Salve et Tir double")

func _verifier_multiplication_tirs() -> void:
	var stats := Stats.depuis_reglages()
	var base := Tir.de_base(stats)
	var familier_reference := CatalogueFamiliers.attaque_combat("homoncule_encre", Reglages.FORGE_NIVEAU_MAX,
		stats.bonus_attaque, stats.attaque_reelle())
	var scenarios: Array[Dictionary] = [
		{"ids": ["salve"], "salves": 2, "projectiles": 1, "malus": 0.80, "dps": 1.60},
		{"ids": ["tir_multiple"], "salves": 1, "projectiles": 2, "malus": 0.80, "dps": 1.60},
		{"ids": ["tir_multiple", "tir_multiple"], "salves": 1, "projectiles": 3, "malus": 0.64, "dps": 1.92},
		{"ids": ["battement_triple"], "salves": 3, "projectiles": 1, "malus": 0.80, "dps": 2.4},
		{"ids": ["battement_triple", "salve"], "salves": 4, "projectiles": 1, "malus": 0.64, "dps": 2.56},
		{"ids": ["battement_triple", "tir_multiple"], "salves": 3, "projectiles": 2, "malus": 0.64, "dps": 3.84},
		{"ids": ["battement_triple", "tir_multiple", "salve"], "salves": 4, "projectiles": 2, "malus": 0.512, "dps": 4.096},
		{"ids": ["salve", "tir_multiple"], "salves": 2, "projectiles": 2, "malus": 0.64, "dps": 2.56},
		{"ids": ["battement_triple", "salve", "tir_multiple", "tir_multiple"],
			"salves": 4, "projectiles": 3, "malus": 0.4096, "dps": 4.9152},
	]
	for scenario: Dictionary in scenarios:
		var inventaire: Array = scenario["ids"]
		var contexte := str(inventaire)
		var mods := Mods.depuis_l_inventaire(inventaire)
		var tir := Mods.appliquer(base, mods)
		_exiger(tir.salves == int(scenario["salves"]) and tir.nb_projectiles == int(scenario["projectiles"]),
			"Quantités de tirs incorrectes : " + contexte)
		_exiger(is_equal_approx(tir.degats_finaux_projectile_mult, float(scenario["malus"])),
			"Les malus de projectiles ne se composent pas : " + contexte)
		var mesures := mesurer(inventaire)
		_exiger(is_equal_approx(float(mesures["dps_tous_projectiles"]), float(scenario["dps"])),
			"DPS frontal incorrect : " + contexte)
		_exiger(is_equal_approx(tir.degats, base.degats) and is_equal_approx(tir.attaque_base, base.attaque_base)
			and is_equal_approx(Mods.facteur_attaque_run(mods), 1.0), "Un malus de tirs a modifié l'attaque : " + contexte)
		var familier := CatalogueFamiliers.attaque_combat("homoncule_encre", Reglages.FORGE_NIVEAU_MAX,
			stats.bonus_attaque, BonusAttaque.attaque(stats, mods))
		_exiger(is_equal_approx(familier, familier_reference), "Un malus de tirs a modifié le familier : " + contexte)
		var inverse := inventaire.duplicate()
		inverse.reverse()
		var tir_inverse := Mods.appliquer(base, Mods.depuis_l_inventaire(inverse))
		_exiger(tir_inverse.salves == tir.salves and tir_inverse.nb_projectiles == tir.nb_projectiles
			and is_equal_approx(tir_inverse.degats_finaux_projectile_mult, tir.degats_finaux_projectile_mult)
			and tir_inverse.decalages() == tir.decalages(), "L'ordre des choix modifie le tir : " + contexte)
	var details := DetailsReactif.texte(CatalogueReactifs.par_id("tir_multiple"), 2)
	_exiger(details.contains("0,64") and details.contains("2 projectiles frontaux parallèles"),
		"La carte Tir double ne décrit pas ses deux copies")
	var details_triple := DetailsReactif.texte(CatalogueReactifs.par_id("battement_triple"))
	_exiger(details_triple.contains("0,8") and details_triple.contains("2 salves"),
		"La carte Battement triple doit annoncer ses deux salves supplémentaires et ses projectiles à 80 %")
	stats.attaque_base = 1000.0
	stats.bonus_attaque = 0.0
	stats.degats = stats.attaque_reelle()
	var degats_attendus := [1500.0, 1200.0, 960.0]
	var inventaire_lourd: Array[String] = []
	for nombre_malus in degats_attendus.size():
		if nombre_malus > 0:
			inventaire_lourd.append("tir_multiple" if nombre_malus == 1 else "salve")
		var tir_lourd := CatalogueProjectiles.appliquer("lourd",
			Mods.appliquer(Tir.de_base(stats), Mods.depuis_l_inventaire(inventaire_lourd)))
		_exiger(is_equal_approx(tir_lourd.degats * tir_lourd.degats_finaux_projectile_mult, float(degats_attendus[nombre_malus])),
			"Le Sceptre de cuivre ne respecte pas la chaîne 1500 → 1200 → 960")
	print("Tirs cumulés : %d combinaisons vérifiées ; Tir double ×1,6 puis ×1,92 ; arme lourde 1500 → 1200 → 960." % scenarios.size())

func _verifier_projectiles_paralleles() -> void:
	var script_salle := load("res://scripts/monde/salle.gd") as GDScript
	_exiger(script_salle != null and script_salle.can_instantiate(), "La salle ne compile pas pour le contrôle des projectiles")
	if script_salle == null or not script_salle.can_instantiate():
		return
	var base := Tir.de_base(Stats.depuis_reglages())
	var origine := Vector2(200.0, 300.0)
	var direction := Vector2.UP
	for arme: String in ["standard", "prisme"]:
		for copies in range(1, ReglagesAugments.COPIES_MAX + 1):
			for copies_eventail in range(3):
				var inventaire: Array[String] = []
				for _copie in copies:
					inventaire.append("tir_multiple")
				for _copie in copies_eventail:
					inventaire.append("spirale")
				var tir := CatalogueProjectiles.appliquer(arme, Mods.appliquer(base, Mods.depuis_l_inventaire(inventaire)))
				var salle := script_salle.new() as Node2D
				salle.call("tirer", tir, origine, direction, false)
				var projectiles := salle.get_children()
				var frontaux := tir.nb_projectiles - tir.projectiles_lateraux
				var contexte := "%s, %d Tir double, %d Éventail" % [arme, copies, copies_eventail]
				_exiger(projectiles.size() == tir.nb_projectiles, "Nombre de projectiles créés incorrect : " + contexte)
				_exiger(tir.projectiles_lateraux == 2 * copies_eventail, "Chaque Éventail doit ajouter deux diagonales : " + contexte)
				var ecart := maxf(tir.ecart_lateral, ReglagesAugments.TIR_DOUBLE_ECART)
				for index in frontaux:
					var projectile := projectiles[index] as Node2D
					var direction_reelle: Vector2 = projectile.get("direction")
					var tir_reel: Tir = projectile.get("tir")
					_exiger(direction_reelle.is_equal_approx(direction), "Les projectiles frontaux divergent : " + contexte)
					_exiger(is_equal_approx((projectile.position - origine).dot(direction), 0.0),
						"Le décalage d'un projectile n'est pas perpendiculaire : " + contexte)
					_exiger(is_equal_approx(tir_reel.degats_finaux_projectile_mult, tir.degats_finaux_projectile_mult),
						"Un projectile a perdu le malus de Tir double : " + contexte)
					if index > 0:
						var precedent := projectiles[index - 1] as Node2D
						_exiger(is_equal_approx(projectile.position.distance_to(precedent.position), ecart),
							"L'espacement des projectiles ne reste pas constant : " + contexte)
				for index in range(frontaux, tir.nb_projectiles):
					var projectile := projectiles[index] as Node2D
					var tir_reel: Tir = projectile.get("tir")
					_exiger(is_equal_approx(tir_reel.degats, tir.degats * 0.65),
						"Les diagonales doivent garder 65 % de la puissance du tir : " + contexte)
				_exiger(ecart > 2.0 * Reglages.TIR_RAYON, "Les projectiles frontaux se superposent : " + contexte)
				salle.free()
	print("Projectiles parallèles : créations réelles standard/Prisme avec zéro, une ou deux copies d'Éventail vérifiées.")

func _verifier_trajectoires() -> void:
	var scene := load("res://scenes/projectile.tscn") as PackedScene
	_exiger(scene != null, "La scène projectile ne se charge pas")
	if scene == null:
		return
	var jeu := root.get_node("Jeu")
	var touches_initiales := int(jeu.get("tirs_touches"))
	var base := Tir.de_base(Stats.depuis_reglages())
	var cibles: Array[CibleProjectile] = []
	for index in 8:
		var cible := CibleProjectile.new()
		cible.position = Vector2(100.0 + index * 100.0, 100.0)
		root.add_child(cible)
		cible.add_to_group("ennemis")
		cibles.append(cible)
	for inventaire: Array in [["perforation"], ["ricochet", "perforation"], ["perforation", "ricochet"]]:
		for cible in cibles:
			cible.coups = 0
			cible.degats.clear()
		var tir := Mods.appliquer(base, Mods.depuis_l_inventaire(inventaire))
		var projectile := _creer_projectile(scene, tir)
		for index in cibles.size():
			var cible := cibles[index]
			projectile.position = cible.position
			projectile.call("_sur_contact", cible)
			projectile.call("_sur_contact", cible)
			_exiger(cible.coups == 1, "Un projectile doit frapper chaque ennemi une seule fois : " + str(inventaire))
			_exiger(cible.degats.size() == 1 and is_equal_approx(cible.degats[0], tir.degats),
				"Perforation perd de la puissance pendant sa trajectoire : " + str(inventaire))
			if index < cibles.size() - 1:
				_exiger(not bool(projectile.get("_termine")), "La trajectoire illimitée s'arrête trop tôt : " + str(inventaire))
		_exiger(is_equal_approx(float(projectile.get("_facteur_degats")), 1.0),
			"La synergie de trajectoires doit conserver toute sa puissance : " + str(inventaire))
		projectile.free()
	for cible in cibles:
		cible.coups = 0
		cible.degats.clear()
	var cible_verrouillee := cibles[0]
	cible_verrouillee.position = Vector2(300.0, 0.0)
	cibles[1].position = Vector2(100.0, 0.0)
	var mur := StaticBody2D.new()
	mur.position = Vector2(200.0, 0.0)
	mur.collision_layer = 4
	var collision := CollisionShape2D.new()
	var forme := RectangleShape2D.new()
	forme.size = Vector2(30.0, 400.0)
	collision.shape = forme
	mur.add_child(collision)
	root.add_child(mur)
	var tir_indelebile := Mods.appliquer(base, Mods.depuis_l_inventaire(["trait_transpercant"]))
	tir_indelebile.cible_verrouillee = cible_verrouillee.get_instance_id()
	_exiger(tir_indelebile.copie().cible_verrouillee == tir_indelebile.cible_verrouillee,
		"La copie d'un tir a perdu sa cible verrouillée")
	var indelebile := _creer_projectile(scene, tir_indelebile.copie())
	_exiger(indelebile.collision_mask == 0, "Tir indélébile doit ignorer les obstacles et les autres corps")
	indelebile.call("_physics_process", 1.0)
	indelebile.call("_physics_process", 1.0)
	_exiger(cible_verrouillee.coups == 1 and cibles[1].coups == 0 and bool(indelebile.get("_termine")),
		"Tir indélébile doit atteindre sa cible derrière un mur sans toucher un autre ennemi")
	indelebile.free()
	var orphelin := _creer_projectile(scene, tir_indelebile.copie())
	cible_verrouillee.free()
	orphelin.call("_physics_process", 1.0)
	_exiger(bool(orphelin.get("_termine")), "Un tir indélébile sans cible doit se terminer")
	orphelin.free()
	mur.free()
	for cible in cibles:
		if is_instance_valid(cible):
			cible.free()
	jeu.set("tirs_touches", touches_initiales)
	print("Trajectoires : huit ennemis sans perte ni double impact ; Tir indélébile traverse les obstacles.")

func _creer_projectile(scene: PackedScene, tir: Tir) -> Area2D:
	var projectile := scene.instantiate() as Area2D
	projectile.set("tir", tir)
	root.add_child(projectile)
	projectile.set_physics_process(false)
	return projectile

func _verifier_recalcul_heros() -> void:
	var jeu := root.get_node_or_null("Jeu")
	_exiger(jeu != null, "Autoload Jeu absent du contrôle")
	if jeu == null:
		return
	# En mode --script, un preload compilerait le heros avant ses autoloads.
	var script_heros := load("res://scripts/combat/heros.gd") as GDScript
	_exiger(script_heros != null and script_heros.can_instantiate(), "Le script du héros ne compile pas")
	if script_heros == null or not script_heros.can_instantiate():
		return
	var inventaire: Array[String] = jeu.get("inventaire")
	var inventaire_initial := inventaire.duplicate()
	inventaire.clear()
	var stats := Stats.depuis_reglages()
	stats.critique = 0.98
	stats.pv = stats.pv_max * 0.40
	var critiques_sans_augments := stats.degats_critiques
	var couronne := CatalogueReactifs.par_id("couronne_incisive").mods
	var excedent := maxf(0.0, stats.critique + float(couronne["critique_add"]) - 1.0)
	var heros := _creer_heros(script_heros, stats)
	var vie_avant := stats.pv
	inventaire.assign(["couronne_incisive", "baume_profond"])
	heros.call("recalculer")
	_exiger(is_equal_approx(stats.critique, 1.0), "La chance critique dépasse sa limite")
	_exiger(is_equal_approx(stats.critique_excedentaire, excedent)
		and is_equal_approx(stats.degats_critiques, critiques_sans_augments + float(couronne["degats_critiques_add"]) + excedent * float(couronne["conversion_critique"])),
		"Couronne doit convertir l'excedent critique selon son catalogue")
	_exiger(is_equal_approx(stats.pv, vie_avant), "Une hausse des PV max a accordé un soin caché")
	var vie_sans_egide := stats.pv_max
	var egide := CatalogueReactifs.par_id("egide").mods
	inventaire.append("egide")
	heros.call("recalculer")
	_exiger(is_equal_approx(stats.pv_max, vie_sans_egide * float(egide["pv_max_final_mult"])) and is_equal_approx(stats.pv, stats.pv_max),
		"Egide doit renforcer les PV totaux et soigner une seule fois")
	_exiger(is_equal_approx(Mods.facteur_heros(Mods.depuis_l_inventaire(inventaire), "degats_subis_mult"), float(egide["degats_subis_mult"])),
		"Egide doit appliquer la reduction du catalogue")
	var vie_max := stats.pv_max
	var degats_critiques := stats.degats_critiques
	stats.pv = vie_max * 0.40
	for _recalcul in 3:
		inventaire.reverse()
		heros.call("recalculer")
	_exiger(is_equal_approx(stats.pv_max, vie_max)
		and is_equal_approx(stats.degats_critiques, degats_critiques)
		and is_equal_approx(stats.critique_excedentaire, excedent), "Un recalcul réapplique les augments")
	_exiger(is_equal_approx(stats.pv, vie_max * 0.40), "Un recalcul a répété le soin d'acquisition d'Égide")
	inventaire.assign(["garde_remanente"])
	heros.call("recalculer")
	heros.set("bouclier", 0)
	heros.call("recalculer")
	_exiger(int(heros.get("bouclier")) == 0, "Un recalcul a rechargé un bouclier consommé")
	heros.free()
	_verifier_courage(script_heros, inventaire)
	_verifier_elan(script_heros, inventaire, jeu)
	inventaire.assign(inventaire_initial)
	print("Héros : soin unique d'Égide, résurrection unique de Courage, Couronne stable et Élan sur toutes les salves vérifiés.")

func _creer_heros(script: GDScript, stats: Stats) -> CharacterBody2D:
	var heros := script.new() as CharacterBody2D
	heros.set("stats", stats)
	root.add_child(heros)
	heros.set_process(false)
	heros.set_physics_process(false)
	return heros

func _verifier_courage(script: GDScript, inventaire: Array[String]) -> void:
	inventaire.assign(["courageux"])
	var stats := Stats.depuis_reglages()
	var vie_sans_augments := stats.pv_max
	var cadence_sans_augments := stats.cadence
	var attaque_sans_augments := stats.attaque_reelle()
	var courage := CatalogueReactifs.par_id("courageux").mods
	var heros := _creer_heros(script, stats)
	var morts: Array[bool] = []
	heros.connect("morte", func() -> void: morts.append(true))
	_exiger(is_equal_approx(stats.pv_max, vie_sans_augments * float(courage["pv_max_mult"]))
		and is_equal_approx(float(heros.call("cadence_effective_actuelle")), cadence_sans_augments * float(courage["cadence_mult"]))
		and is_equal_approx(float(heros.call("attaque_reelle")), attaque_sans_augments * float(courage["attaque_mult"]))
		and is_equal_approx(Mods.facteur_heros(Mods.depuis_l_inventaire(inventaire), "defense_mult"), float(courage["defense_mult"])),
		"Courage doit renforcer chaque statistique selon son catalogue")
	# Le sursis d'un bijou ne doit pas masquer une seconde resurrection de Courage.
	heros.set("_sursis_disponible", false)
	heros.set("bouclier", 0)
	heros.call("recevoir_degats", stats.pv_max * 1000000.0)
	_exiger(is_equal_approx(stats.pv, stats.pv_max) and morts.is_empty()
		and not bool(heros.get("_courage_vie_disponible")), "Courage doit annuler une mort et rendre tous les PV")
	heros.call("recalculer")
	heros.call("preparer_nouvelle_salle")
	_exiger(not bool(heros.get("_courage_vie_disponible")), "Une nouvelle salle a rechargé la résurrection de Courage")
	heros.set("_invulnerable", 0.0)
	heros.set("bouclier", 0)
	heros.call("recevoir_degats", stats.pv_max * 1000000.0)
	_exiger(stats.est_mort() and morts.size() == 1, "Courage doit laisser passer le second coup mortel de la partie")
	heros.free()
	var nouvelle_stats := Stats.depuis_reglages()
	var nouveau_heros := _creer_heros(script, nouvelle_stats)
	nouveau_heros.set("bouclier", 0)
	nouveau_heros.set("_sursis_disponible", false)
	nouveau_heros.call("recevoir_degats", nouvelle_stats.pv_max * 1000000.0)
	_exiger(is_equal_approx(nouvelle_stats.pv, nouvelle_stats.pv_max), "Une nouvelle partie doit retrouver sa résurrection de Courage")
	nouveau_heros.free()

func _verifier_elan(script: GDScript, inventaire: Array[String], jeu: Node) -> void:
	inventaire.assign(["elan_vital", "battement_triple", "salve"])
	var tirs_emis_initial := int(jeu.get("tirs_emis"))
	var heros := _creer_heros(script, Stats.depuis_reglages())
	var tir_base: Tir = heros.get("tir_courant")
	var degats_emis: Array[float] = []
	heros.connect("tir_demande", func(tir: Tir, _origine: Vector2, _direction: Vector2) -> void: degats_emis.append(tir.degats))
	heros.call("definir_intention", Vector2.RIGHT, 0.0)
	heros.call("_process", 1.0)
	_exiger(not bool(heros.get("_elan_chargee")), "Élan ne doit pas charger avec une intensité de déplacement nulle")
	heros.call("definir_intention", Vector2.RIGHT)
	heros.call("_process", 0.30)
	heros.call("definir_intention", Vector2.ZERO)
	heros.call("_process", 0.01)
	heros.call("definir_intention", Vector2.RIGHT)
	heros.call("_process", 0.30)
	_exiger(not bool(heros.get("_elan_chargee")), "Élan ne doit pas cumuler deux déplacements interrompus")
	heros.call("_process", 0.30)
	_exiger(bool(heros.get("_elan_chargee")), "Élan doit charger après 0,6 s de déplacement continu")
	var cible := CibleProjectile.new()
	cible.position = Vector2(400.0, 200.0)
	root.add_child(cible)
	cible.add_to_group("ennemis")
	heros.call("definir_intention", Vector2.ZERO)
	heros.call("_process", Reglages.TIR_DELAI_ARRET + 0.01)
	heros.call("_avancer_rafale", 1.0)
	heros.call("_avancer_tirs_prepares", Reglages.TIR_PREPARATION + 0.01)
	_exiger(degats_emis.size() == 4, "L'attaque chargée doit émettre les quatre salves de Battement triple et Salve")
	for degats in degats_emis:
		_exiger(is_equal_approx(degats, tir_base.degats * (1.0 + ReglagesAugments.ELAN_VITAL_BONUS_DEGATS)), "Toutes les salves de l'attaque chargee doivent recevoir le meme bonus")
	_exiger(not bool(heros.get("_elan_chargee")), "La première attaque doit consommer la charge d'Élan")
	degats_emis.clear()
	heros.set("_recharge", 0.0)
	heros.call("_process", Reglages.TIR_DELAI_ARRET + 0.01)
	heros.call("_avancer_rafale", 1.0)
	heros.call("_avancer_tirs_prepares", Reglages.TIR_PREPARATION + 0.01)
	_exiger(degats_emis.size() == 4, "L'attaque suivante doit conserver ses quatre salves")
	for degats in degats_emis:
		_exiger(is_equal_approx(degats, tir_base.degats), "Élan ne doit pas renforcer une seconde attaque sans recharge")
	cible.free()
	heros.free()
	jeu.set("tirs_emis", tirs_emis_initial)
