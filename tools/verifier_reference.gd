extends SceneTree

const Modeles = preload("res://tools/statistiques/modeles.gd")
const ProfilReference = preload("res://tools/statistiques/profil_reference.gd")
const ProfilsAugments = preload("res://tools/statistiques/profils_augments.gd")
const Attribution = preload("res://tools/statistiques/attribution.gd")

var _erreurs: Array[String] = []
var _controles := 0

func _init() -> void:
	var historique := Modeles.complet()
	var reference := ProfilReference.construire()
	_verifier_legalite(reference)
	_verifier_profils_augments()
	_verifier_copies(reference)
	_verifier(Modeles.complet() == historique, "Le profil historique reste intact")
	_verifier_etapes()
	var mesure := Modeles.mesurer(reference)
	_verifier_maximum(reference, float(mesure["dps"]))
	_verifier_attribution(reference)
	_verifier_attribution_permanente(reference)
	historique["conditions"] = true
	historique["augments"] = ProfilReference.AUGMENTS_CLASSIQUES.duplicate()
	var mesure_historique := Modeles.mesurer(historique)
	print(JSON.stringify({"equipement": {"arme": reference["arme"], "familier": reference["familier"],
		"bijoux": reference["bijoux"]}, "mesure": mesure,
		"dps_equipement_dernier_monde": mesure_historique["dps"],
		"gain_dps": float(mesure["dps"]) / float(mesure_historique["dps"]) - 1.0,
		"combinaisons": ProfilReference.nombre_combinaisons()}))
	for id: String in Personnage.ATTRIBUTS:
		print(JSON.stringify({"attribut": id, "points": Personnage.points_totaux(Personnage.NIVEAU_MAX),
			"bonus": Personnage.bonus({id: Personnage.points_totaux(Personnage.NIVEAU_MAX)})}))
	for erreur: String in _erreurs:
		push_error(erreur)
	print("Référence : %d contrôles, %d erreurs." % [_controles, _erreurs.size()])
	quit(0 if _erreurs.is_empty() else 1)

func _verifier(condition: bool, contexte: String) -> void:
	_controles += 1
	if not condition:
		_erreurs.append(contexte)

func _verifier_legalite(configuration: Dictionary) -> void:
	var attributs: Dictionary = configuration["attributs"]
	var passifs: Dictionary = configuration["passifs"]
	var maitrises: Dictionary = configuration["maitrises"]
	var bijoux: Dictionary = configuration["bijoux"]
	var forge_bijoux: Dictionary = configuration["forge_bijoux"]
	_verifier(int(configuration["niveau"]) == Personnage.NIVEAU_MAX, "Compte au niveau maximum")
	_verifier(Personnage.points_depenses(attributs) == Personnage.points_totaux(Personnage.NIVEAU_MAX), "Budget des attributs")
	_verifier(attributs == {"force": 40, "vitalite": 50, "agilite": 25, "intelligence": 30}, "Répartition demandée des attributs")
	_verifier(passifs == {"vigueur": 2, "celerite": 2, "oeil_precis": 2, "vitalite": 2}, "Quatre passifs demandés")
	_verifier(passifs.size() <= Passifs.EMPLACEMENTS, "Nombre légal de passifs")
	_verifier(maitrises == Modeles.toutes_maitrises(), "Toutes les maîtrises au maximum")
	_verifier(int(configuration["coeurs"]) == Epreuves.nombre(), "Tous les Cœurs")
	_verifier(bool(configuration["conditions"]), "Conditions du tir continu actives")
	_verifier(int(configuration["forge_arme"]) == Reglages.FORGE_NIVEAU_MAX, "Forge maximale de l’arme")
	_verifier(int(configuration["forge_familier"]) == Reglages.FORGE_NIVEAU_MAX, "Forge maximale du familier")
	_verifier(str(configuration["arme"]) in CatalogueProjectiles.disponibles(Chapitres.nombre()), "Arme actuellement accessible")
	_verifier(str(configuration["familier"]) in CatalogueFamiliers.disponibles(Chapitres.nombre()), "Familier actuellement accessible")
	for slot: String in ["anneau", "bracelet", "collier"]:
		var id := str(bijoux[slot])
		var objet: Dictionary = CatalogueObjets.OBJETS[id]
		_verifier(CatalogueObjets.compatible(slot, id), "Bijou compatible : " + slot)
		_verifier(int(objet["monde"]) >= 0 and int(objet["monde"]) < Chapitres.MONDES.size(), "Bijou actif : " + id)
		_verifier(int(forge_bijoux[id]) == Reglages.FORGE_NIVEAU_MAX, "Forge maximale : " + id)
	var raretes := {}
	var copies := {}
	var augments: Array = configuration["augments"]
	_verifier(augments == ProfilReference.AUGMENTS_CLASSIQUES, "Panier classique inchangé")
	for id: String in augments:
		var reactif := CatalogueReactifs.par_id(id)
		_verifier(reactif != null, "Augment connu : " + id)
		if reactif == null:
			continue
		raretes[reactif.rarete] = int(raretes.get(reactif.rarete, 0)) + 1
		copies[id] = int(copies.get(id, 0)) + 1
		_verifier(int(copies[id]) <= reactif.copies_permises(), "Copies légales : " + id)
	_verifier(raretes == {Reactif.RARE: 6, Reactif.EPIQUE: 3, Reactif.LEGENDAIRE: 1}, "Budget de référence : dix choix sans légendaire bonus")
	var mesure := Modeles.mesurer(configuration)
	_verifier(is_equal_approx(float(mesure["degats_projectile_mult"]), pow(ReglagesAugments.MALUS_TIRS_MULT, 2)), "Réductions indépendantes de Salve et Tir double")
	_verifier(is_finite(float(mesure["dps"])) and float(mesure["dps"]) > 0.0, "DPS de référence valide")

func _verifier_profils_augments() -> void:
	for nom: String in ProfilsAugments.PROFILS:
		var inventaire: Array = ProfilsAugments.PROFILS[nom]
		var raretes := {}
		var copies := {}
		_verifier(inventaire.size() == ProgressionAugments.niveau_max(), "Dix choix dans le profil " + nom)
		for id: String in inventaire:
			var reactif := CatalogueReactifs.par_id(id)
			_verifier(reactif != null, "Augment connu du profil " + nom + " : " + id)
			if reactif == null:
				continue
			raretes[reactif.rarete] = int(raretes.get(reactif.rarete, 0)) + 1
			copies[id] = int(copies.get(id, 0)) + 1
			_verifier(int(copies[id]) <= reactif.copies_permises(), "Copies légales du profil " + nom + " : " + id)
		_verifier(raretes == {Reactif.RARE: 6, Reactif.EPIQUE: 3, Reactif.LEGENDAIRE: 1}, "Budget ordinaire comparable : " + nom)

func _verifier_copies(reference: Dictionary) -> void:
	var copie := ProfilReference.construire()
	var attributs: Dictionary = copie["attributs"]
	var maitrises: Dictionary = copie["maitrises"]
	var passifs: Dictionary = copie["passifs"]
	var bijoux: Dictionary = copie["bijoux"]
	var forges: Dictionary = copie["forge_bijoux"]
	var augments: Array = copie["augments"]
	attributs.clear()
	maitrises.clear()
	passifs.clear()
	bijoux.clear()
	forges.clear()
	augments.clear()
	copie["arme"] = ""
	_verifier(ProfilReference.construire() == reference, "Les variantes ne modifient pas le cache")
	_verifier(ProfilReference.AUGMENTS_CLASSIQUES.size() == ProgressionAugments.niveau_max(), "Le panier constant de dix choix reste intact")

func _verifier_maximum(reference: Dictionary, maximum: float) -> void:
	# Cette enumeration indexee utilise les mondes, independamment du filtre
	# des objets et des boucles imbriquees du constructeur de reference.
	var choix: Array = [CatalogueProjectiles.disponibles(Chapitres.nombre()),
		CatalogueFamiliers.disponibles(Chapitres.nombre())]
	for slot: String in ["anneau", "bracelet", "collier"]:
		var ids: Array[String] = []
		for monde in Chapitres.MONDES.size():
			for id: String in CatalogueObjets.IDS_PAR_MONDE[monde]:
				if CatalogueObjets.compatible(slot, id):
					ids.append(id)
		choix.append(ids)
	var total := 1
	for ids: Array in choix:
		total *= ids.size()
	_verifier(total == ProfilReference.nombre_combinaisons(), "Toutes les combinaisons actives sont évaluées")
	var candidat := reference.duplicate(true)
	for indice in total:
		var reste := indice
		var selection: Array[String] = []
		for ids: Array in choix:
			selection.append(str(ids[reste % ids.size()]))
			reste = floori(float(reste) / float(ids.size()))
		candidat["arme"] = selection[0]
		candidat["familier"] = selection[1]
		candidat["bijoux"] = {"anneau": selection[2], "bracelet": selection[3], "collier": selection[4]}
		candidat["forge_bijoux"] = {selection[2]: Reglages.FORGE_NIVEAU_MAX,
			selection[3]: Reglages.FORGE_NIVEAU_MAX, selection[4]: Reglages.FORGE_NIVEAU_MAX}
		var mesure := Modeles.mesurer(candidat)
		_verifier(float(mesure["dps"]) <= maximum, "Maximum global : " + ", ".join(selection))

func _verifier_attribution(reference: Dictionary) -> void:
	var partage := Attribution.calculer(reference)
	var total: Dictionary = partage["total"]
	var base: Dictionary = partage["base"]
	var parts: Array = partage["parts"]
	_verifier(total == Modeles.mesurer(reference), "L'analyse complete conserve les mesures du combat")
	for cle: String in Attribution.MESURES:
		var somme := float(base[cle])
		for part: Dictionary in parts:
			_verifier(is_finite(float(part[cle])), "Contribution finie : " + cle)
			somme += float(part[cle])
		_verifier(is_equal_approx(somme, float(total[cle])), "Contributions sans double comptage : " + cle)
	var coeurs: Dictionary = parts[Attribution.SOURCES.find("coeurs")]
	_verifier(is_zero_approx(float(coeurs["pv"])) and is_zero_approx(float(coeurs["defense"])), "Les Coeurs ne recoivent aucune contribution defensive")
	# La synergie entre l'attaque brute d'une arme et une maitrise est partagee
	# en deux, quel que soit leur ordre ; les autres familles sont absentes.
	var exemple := Attribution.calculer({"arme": "standard", "familier": "", "maitrises": {"force": 1}})
	var contributions: Array = exemple["parts"]
	var maitrises: Dictionary = contributions[Attribution.SOURCES.find("maitrises")]
	var equipement: Dictionary = contributions[Attribution.SOURCES.find("equipement")]
	var arme_brute := CatalogueProjectiles.attaque_base("standard", 0)
	var maitrise := ArbreCompetences.bonus_attaque({"force": 1})
	var interaction := arme_brute * maitrise
	_verifier(is_equal_approx(float(maitrises["attaque"]), Stats.base_degats(1) * maitrise + interaction * 0.5), "Synergie partagee : maitrise")
	_verifier(is_equal_approx(float(equipement["attaque"]), arme_brute + interaction * 0.5), "Synergie partagee : equipement")
	for source: String in ["attributs", "passifs", "coeurs", "augments"]:
		var part: Dictionary = contributions[Attribution.SOURCES.find(source)]
		_verifier(is_zero_approx(float(part["attaque"])), "Une source absente ne recoit aucune part : " + source)
	var salve := Attribution.calculer({"arme": "", "familier": "", "augments": ["salve"]})
	var parts_salve: Array = salve["parts"]
	var apport: Dictionary = parts_salve[Attribution.SOURCES.find("augments")]
	_verifier(float(apport["tir_moyen"]) < 0.0 and float(apport["dps_heros"]) > 0.0,
		"Salve diminue l'impact mais augmente le DPS : signes distincts conserves")
	_verifier(ProfilReference.construire() == reference, "L'attribution ne modifie pas le profil cache")

func _verifier_attribution_permanente(reference: Dictionary) -> void:
	var partage := Attribution.calculer_permanent(reference)
	var sans_augments := reference.duplicate(true)
	sans_augments.erase("augments")
	var complet_sans := Attribution.calculer(sans_augments)
	var total: Dictionary = partage["total"]
	var base: Dictionary = partage["base"]
	var parts: Array = partage["parts"]
	var parts_sans: Array = complet_sans["parts"]
	_verifier(total == Modeles.mesurer(sans_augments), "Le partage permanent exclut effectivement tous les augments")
	_verifier(parts.size() == 5 and "augments" not in partage["sources"], "Exactement cinq familles permanentes")
	_verifier(partage == Attribution.calculer_permanent(sans_augments), "Un augment equipe ne change aucune part permanente")
	var proportions := {}
	for cle: String in Attribution.MESURES:
		var somme := float(base[cle])
		for index in parts.size():
			var part: Dictionary = parts[index]
			var part_sans: Dictionary = parts_sans[index]
			_verifier(is_equal_approx(float(part[cle]), float(part_sans[cle])), "Cinq sources coherentes avec la famille augment absente : " + cle)
			somme += float(part[cle])
		_verifier(is_equal_approx(somme, float(total[cle])), "Sources permanentes et socle totalisent 100 % : " + cle)
	for index in parts.size():
		var part: Dictionary = parts[index]
		proportions[Attribution.SOURCES_PERMANENTES[index]] = float(part["dps"]) / float(total["dps"]) * 100.0
	var arrivee := Modeles.mesurer(reference)
	var gain := float(arrivee["dps"]) - float(total["dps"])
	var facteur := float(arrivee["dps"]) / float(total["dps"])
	var part_finale := gain / float(arrivee["dps"])
	_verifier(is_equal_approx(part_finale, 1.0 - 1.0 / facteur), "Le gain temporel utilise le DPS final comme denominateur")
	_verifier(part_finale > 0.5, "Le panier classique ajoute la majorite du DPS final")
	print(JSON.stringify({"dps_permanent": total["dps"], "dps_final": arrivee["dps"],
		"gain_augments": gain, "facteur_augments": facteur, "part_augments_finale": part_finale,
		"parts_permanentes_pourcent": proportions, "socle_pourcent": float(base["dps"]) / float(total["dps"]) * 100.0}))
	_verifier(ProfilReference.construire() == reference, "Le partage permanent ne modifie pas le profil cache")

func _verifier_etapes() -> void:
	# Ce cas chiffre detecte une regression vers la somme globale de pourcentages.
	var exemple := Stats.composer_statistique(10.0, 2.0, 3.0, 1.0, 1.1, 1.2, 1.3)
	_verifier(is_equal_approx(float(exemple["brut"]), 15.0), "Les bases brutes s'additionnent")
	_verifier(is_equal_approx(float(exemple["apres_equipement"]), 16.5), "Premier etage : equipement")
	_verifier(is_equal_approx(float(exemple["apres_maitrises"]), 19.8), "Deuxieme etage : maitrises")
	_verifier(is_equal_approx(float(exemple["permanent"]), 25.74), "Troisieme etage : passifs")
	var profil := Modeles.complet()
	var bonus := Modeles.bonus_equipement(profil)
	var stats := Stats.depuis_reglages(profil["maitrises"], profil["passifs"], bonus,
		int(profil["niveau"]), profil["attributs"])
	for definition: Array in [["attaque", stats.degats], ["pv", stats.pv_max],
		["defense", stats.defense], ["cadence", stats.cadence]]:
		var etape: Dictionary = stats.etapes_permanentes[str(definition[0])]
		_verifier(is_equal_approx(float(etape["permanent"]), float(definition[1])), "Le combat utilise ses etapes : " + str(definition[0]))
	var attaque: Dictionary = stats.etapes_permanentes["attaque"]
	_verifier(is_equal_approx(1.0 + stats.bonus_attaque, float(attaque["facteur_permanent"])), "API familier : produit permanent applique une fois")
	var sans_augments := Modeles.mesurer(profil)
	profil["augments"] = ProfilReference.AUGMENTS_CLASSIQUES.duplicate()
	var avec_augments := Modeles.mesurer(profil)
	_verifier(sans_augments["etapes_permanentes"] == avec_augments["etapes_permanentes"], "Les augments restent hors des etages permanents")
	profil["coeurs"] = 0
	var sans_coeurs := Modeles.mesurer(profil)
	_verifier(is_equal_approx(float(avec_augments["attaque"]), float(sans_coeurs["attaque"])), "Les Coeurs n'augmentent pas l'attaque de run")
	_verifier(is_equal_approx(float(avec_augments["tir_moyen"]), float(sans_coeurs["tir_moyen"]) * float(avec_augments["facteur_coeurs"])), "Les Coeurs multiplient les degats a la fin")
	_verifier(is_equal_approx(float(avec_augments["dps_familier"]), float(sans_coeurs["dps_familier"]) * float(avec_augments["facteur_coeurs"])), "Les Coeurs s'appliquent une fois au familier")
	var equipe_nue := {"arme": "", "familier": "", "niveau": Personnage.NIVEAU_MAX}
	var nu := Modeles.mesurer(equipe_nue)
	_verifier(is_equal_approx(float(nu["attaque"]), Stats.base_degats(Personnage.NIVEAU_MAX)), "Le socle de niveau reste distinct des attributs")
	_verifier(is_equal_approx(float(nu["pv"]), Stats.base_pv(Personnage.NIVEAU_MAX)), "Le socle de PV reste distinct des attributs")
	var paliers := Modeles.paliers_sources()
	var equipement: Dictionary = paliers[2]["build"]
	var attributs: Dictionary = paliers[3]["build"]
	_verifier(int(equipement["niveau"]) == 1 and not equipement.has("attributs"), "Le palier equipement n'ajoute pas le niveau maximum")
	_verifier(int(attributs["niveau"]) == Personnage.NIVEAU_MAX and Personnage.points_depenses(attributs["attributs"]) == Personnage.points_totaux(Personnage.NIVEAU_MAX), "Le palier attributs ajoute explicitement niveau et points")
