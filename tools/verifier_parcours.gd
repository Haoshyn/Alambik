extends SceneTree

const Parcours = preload("res://tools/statistiques/parcours_progression.gd")
const Modeles = preload("res://tools/statistiques/modeles.gd")
const Synthese = preload("res://tools/statistiques/synthese_progression.gd")

var _erreurs: Array[String] = []
var _controles := 0

func _init() -> void:
	_verifier.call_deferred()

func _verifier() -> void:
	_verifier_ennemis_runtime()
	_verifier_annexes()
	_verifier_garde_survie()
	var rapport := Parcours.rapport()
	for nom: String in ["sans_annexes", "equilibre", "adaptatif", "mixte", "seuil_90"]:
		var cas: Dictionary = rapport[nom]
		_verifier_compte(cas)
		print("Parcours %s : %d chapitres, premier mur %s, %.1f minutes dont %.1f annexes ; %d lots." % [nom,
			int(cas["chapitres_valides"]), JSON.stringify(cas["premier_mur"]), float(cas["duree"]) / 60.0,
			float(cas["duree_annexes"]) / 60.0, (cas["lots"] as Array).size()])
	for nom: String in ["depart", "retry", "complet"]:
		print("Duree %s : %s" % [nom, JSON.stringify(rapport[nom])])
	for cas: Dictionary in rapport["cohorte_comptes"]:
		_verifier_compte(cas)
		var farm_max := 0.0
		var total_max := 0.0
		for bloc: Dictionary in cas["blocs"]:
			farm_max = maxf(farm_max, float(bloc["farm"]))
			total_max = maxf(total_max, float(bloc["avant_succes"]))
			_exiger(is_equal_approx(float(bloc["avant_succes"]), float(bloc["farm"]) + float(bloc["echecs"])), "Le bloc confond farm et echecs")
		print("Compte graine %d : %d chapitres, farm maximum %.1f min ; farm + echecs maximum %.1f min." % [
			int(cas["options"].get("graine", Parcours.GRAINE_BASE)), int(cas["chapitres_valides"]), farm_max / 60.0, total_max / 60.0])
	print("Cohorte premiers murs : " + JSON.stringify(rapport["distribution_murs"]))
	_exiger(JSON.stringify(rapport["sans_annexes"]) == JSON.stringify(Parcours.parcours(false)), "Le parcours et ses coffres ne sont pas reproductibles")
	var premier: Dictionary = rapport["sans_annexes"]["actions"][0]
	_exiger(not bool(premier["victoire"]) and int(premier["salles_validees"]) == 8 and int(premier["boss_valides"]) == 1,
		"La defaite en salle neuf paie une victoire ou une salle non terminee")
	var rapide := Parcours.campagne({}, 0, Parcours.GRAINE_BASE, {"tir_utile": 0.80, "tir_utile_boss": 0.80})
	var lent := Parcours.campagne({}, 0, Parcours.GRAINE_BASE, {"tir_utile": 0.50, "tir_utile_boss": 0.50})
	_exiger(float(lent["duree"]) > float(rapide["duree"]), "La sensibilite du temps de tir utile est inversee")
	var chemin := "res://tmp/verification_parcours/resultat.json"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(chemin.get_base_dir()))
	var fichier := FileAccess.open(chemin, FileAccess.WRITE)
	_exiger(fichier != null, "Le resultat ne peut pas etre ecrit")
	if fichier != null: fichier.store_string(JSON.stringify(rapport, "\t") + "\n")
	var lignes: Array[String] = []
	Synthese.ajouter(lignes)
	var extrait := FileAccess.open("res://tmp/verification_parcours/extrait.md", FileAccess.WRITE)
	_exiger(extrait != null, "La synthese ne peut pas etre ecrite")
	if extrait != null: extrait.store_string("\n".join(lignes) + "\n")
	for erreur: String in _erreurs: push_error(erreur)
	print("Parcours : %d contrôles, %d erreurs." % [_controles, _erreurs.size()])
	quit(0 if _erreurs.is_empty() else 1)

func _exiger(condition: bool, message: String) -> void:
	_controles += 1
	if not condition: _erreurs.append(message)

func _verifier_annexes() -> void:
	var compte := Parcours.Compte.new()
	_exiger(not compte.mode_autorise("mine") and not compte.mode_autorise("epreuves"), "Une annexe est ouverte au compte neuf")
	var epreuve := Parcours.epreuve({}, 1, Parcours.GRAINE_BASE)
	_exiger((epreuve["evenements"] as Array).size() == 4, "Les Epreuves donnent des choix d'XP absents du runtime")
	var inventaire: Array[String] = []
	for evenement: Dictionary in epreuve["evenements"]:
		var candidats := DraftLogique.candidats(inventaire)
		for id: String in evenement["offre"]: _exiger(id in candidats, "Offre annexe illegale")
		inventaire.append(str(evenement["choix"]))
	var milieu := ButinsRun.offre("mine", 0, 0, 0, false, 1, {}, [], 0, 0, Mine.palier(1), Reglages.MINE_DUREE * 0.5)
	var fin := ButinsRun.offre("mine", 0, 1, 1, true, 1, {}, [], 0, 0, Mine.palier(1), Reglages.MINE_DUREE)
	_exiger(int(milieu["xp"]) > 0 and int(milieu["xp"]) < int(fin["xp"]), "Une defaite en Mine perd l'XP de survie")
	compte.recevoir("grimoire", 0, Reglages.SALLES_PAR_RUN, 4, true)
	_exiger(compte.mode_autorise("epreuves", 0, 1) and not compte.mode_autorise("epreuves", 0, 2), "Deblocage d'Epreuve anticipe")
	var niveau_avant := compte.epreuve_debloquee
	compte.recevoir("epreuves", 0, 4, 4, false, 1)
	_exiger(compte.epreuve_debloquee == niveau_avant and compte.coeurs.is_empty() and compte.rangs_passifs.is_empty(), "Une Epreuve perdue debloque une recompense de victoire")
	for chapitre in range(1, Reglages.MINE_NIVEAU_DEBLOCAGE - 1):
		compte.recevoir("grimoire", chapitre, Reglages.SALLES_PAR_RUN, 4, true)
	var xp_total := int(compte.recus["xp"])
	var perdu := compte.recevoir("mine", 0, 0, 0, false, 1, Reglages.MINE_DUREE * 0.5)
	_exiger(int(compte.recus["xp"]) > xp_total and int(perdu["xp"]) > 0, "Le compte efface l'XP d'une Mine perdue")
	for graine in range(Parcours.GRAINE_BASE, Parcours.GRAINE_BASE + 4):
		var options := {"politique": "tout_offensif", "contacts_min": 0.0}
		for run: Dictionary in [Parcours.epreuve({}, 1, graine, options), Parcours.mine({}, 1, graine, options)]:
			var acquis: Array[String] = []
			for evenement: Dictionary in run["evenements"]:
				var choix := str(evenement["choix"])
				var mesure_choisie := Modeles.mesurer({"augments": acquis + [choix]})
				for candidat: String in evenement["offre"]:
					var mesure := Modeles.mesurer({"augments": acquis + [candidat]})
					_exiger(float(mesure_choisie["dps"]) + 0.00001 >= float(mesure["dps"]),
						"Une annexe tout offensive prefere une defense au gain de DPS propose")
				acquis.append(choix)

func _verifier_garde_survie() -> void:
	var compte := Parcours.Compte.new()
	compte.niveau = 23
	compte.campagne_vaincue = 31
	compte.rangs_passifs = {"carapace": 2, "celerite": 2, "vigueur": 2, "vitalite": 2, "audace": 2}
	compte.equipement["passifs"] = {"carapace": 2, "celerite": 2, "vigueur": 2, "vitalite": 2}
	compte.proteger_survie = true
	var avant: Dictionary = compte.configuration()
	var avec_audace := avant.duplicate(true)
	avec_audace["passifs"].erase("carapace")
	avec_audace["passifs"]["audace"] = 2
	_exiger(not Parcours.Compte.survie_preservee(avant, avec_audace), "La garde accepte le sacrifice d'Audace")
	compte.acheter()
	var apres: Dictionary = compte.configuration()
	_exiger(Parcours.Compte.survie_preservee(avant, apres), "Le choix prudent reduit les PV effectifs")
	_exiger(not apres["passifs"].has("audace") and (apres["passifs"] as Dictionary).size() == Passifs.EMPLACEMENTS,
		"La garde ne compare pas l'ensemble complet de passifs")
	_exiger(str(apres["politique_compte"]) == "equilibre", "La garde change les poids des choix")

func _verifier_compte(cas: Dictionary) -> void:
	var dernier: Dictionary = {}
	for action: Dictionary in cas["actions"]:
		var avant: Dictionary = action["avant"]
		var apres: Dictionary = action["apres"]
		var config: Dictionary = apres["configuration"]
		var monnaie := {"gouttes": 0, "pierres": 0}
		var rangs: Dictionary = (avant["configuration"]["maitrises"] as Dictionary).duplicate()
		var forges: Dictionary = (avant["configuration"]["forge_bijoux"] as Dictionary).duplicate()
		for achat: Dictionary in action["achats"]:
			var id := str(achat["id"])
			var rang := int(achat["rang"])
			var prix := int(achat["prix"])
			if str(achat["type"]) == "maitrise":
				_exiger(rang == int(rangs.get(id, 0)) + 1 and rang <= ArbreCompetences.rangs(id), "Rang de maitrise gratuit")
				_exiger(ArbreCompetences.prerequis_atteint(id, rangs) and prix == ArbreCompetences.cout(id, rang - 1), "Prerequis ou prix de maitrise incorrect")
				rangs[id] = rang
				monnaie["gouttes"] = int(monnaie["gouttes"]) + prix
			else:
				_exiger(rang == int(forges.get(id, 0)) + 1 and rang <= Reglages.FORGE_NIVEAU_MAX, "Une forge est transferee ou offerte")
				_exiger(prix == Reglages.cout_forge(rang - 1), "Prix de forge incorrect")
				forges[id] = rang
				monnaie["pierres"] = int(monnaie["pierres"]) + prix
		_exiger(forges == config["forge_bijoux"] and rangs == config["maitrises"], "Le journal d'achats ne reconstitue pas les rangs")
		for cle: String in monnaie:
			_exiger(int(apres[cle]) >= 0 and int(avant[cle]) + int(action["butin"][cle]) - int(monnaie[cle]) == int(apres[cle]), "Budget non finance : " + cle)
			_exiger(int(apres["recus"][cle]) - int(apres["depenses"][cle]) == int(apres[cle]), "La comptabilite cumulee diverge")
		var mode := str(action["mode"])
		var victoire := bool(action["victoire"])
		var niveau_annexe := int(action["niveau_annexe"])
		if mode == "grimoire":
			_exiger(int(action["chapitre"]) <= int(avant["campagne_vaincue"]) + 1, "Campagne non debloquee")
			_exiger(not victoire or int(action["salles_validees"]) == Reglages.SALLES_PAR_RUN, "Victoire incomplete")
		elif mode == "epreuves":
			_exiger(niveau_annexe <= Epreuves.niveau_accessible(int(avant["campagne_vaincue"]) + 1,
				int(avant["epreuve_debloquee"])), "Epreuve verrouillee jouee")
			_exiger(victoire or int(apres["epreuve_debloquee"]) == int(avant["epreuve_debloquee"]), "Epreuve suivante ouverte apres defaite")
		else:
			_exiger(Mine.campagne_requise(niveau_annexe) <= int(avant["campagne_vaincue"]) + 1, "Mine verrouillee jouee")
		for id: String in (config["bijoux"] as Dictionary).values(): _exiger(id in apres["objets"], "Bijou equipe sans butin")
		for id: String in config["passifs"]:
			_exiger(int(config["passifs"][id]) <= int(apres["passifs"].get(id, 0)), "Passif equipe sans butin")
		_exiger(Personnage.points_depenses(config["attributs"]) == Personnage.points_totaux(int(apres["niveau"])), "Attributs non finances par le niveau")
		_exiger(is_finite(float(action["duree"])) and float(action["duree"]) > 0.0, "Duree invalide")
		if not dernier.is_empty():
			_exiger(dernier == avant, "L'etat du compte change entre deux runs sans achat journalise")
		dernier = apres
	_exiger(dernier == cas["etat_final"], "L'etat final du parcours ne correspond pas au journal")

func _verifier_ennemis_runtime() -> void:
	var jeu := root.get_node_or_null("Jeu")
	var script := load("res://scripts/monde/salle.gd") as GDScript
	_exiger(jeu != null and script != null and script.can_instantiate(), "Runtime de salle indisponible")
	if jeu == null or script == null or not script.can_instantiate(): return
	var salle: Node = script.new()
	for cas: Array in [["grimoire", 0, 1, "encrier_rampant", 1, 0.0],
		["grimoire", 34, 20, str(Chapitres.par_index(34)["boss"]), 1, 0.0],
		["epreuves", 0, 5, "index_brise", 4, 0.0], ["mine", 0, 1, "index_brise", 2, Reglages.MINE_DUREE]]:
		jeu.set("mode_run", cas[0])
		jeu.set("chapitre", cas[1])
		jeu.set("niveau_epreuve", cas[4])
		jeu.set("niveau_mine", cas[4])
		salle.set("numero", cas[2])
		salle.set("_mine_temps", cas[5])
		var runtime: Dictionary = salle.call("_mis_a_l_echelle", CatalogueEnnemis.par_id(str(cas[3])), str(cas[3]))
		var modele := Parcours.ennemi(str(cas[0]), int(cas[1]), int(cas[2]), str(cas[3]), int(cas[4]), float(cas[5]))
		_exiger(is_equal_approx(float(runtime["pv"]), float(modele["pv"])) and is_equal_approx(float(runtime["degats"]), float(modele["degats"])), "Les ennemis du modele different du runtime : " + str(cas))
	salle.free()
