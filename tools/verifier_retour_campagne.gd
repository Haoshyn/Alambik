extends SceneTree

const Retour = preload("res://tools/statistiques/retour_campagne.gd")
var _erreurs: Array[String] = []
var _controles := 0

func _init() -> void:
	_verifier.call_deferred()

func _verifier() -> void:
	var arguments := OS.get_cmdline_user_args()
	var nom := arguments[0] if not arguments.is_empty() else "courant"
	var rapport := Retour.rapport()
	_verifier_acces()
	_verifier_comptes(rapport)
	_verifier_specialisation(rapport)
	var chemin := "res://tmp/verification_retour_campagne/" + nom.validate_filename() + ".json"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(chemin.get_base_dir()))
	var fichier := FileAccess.open(chemin, FileAccess.WRITE)
	_exiger(fichier != null, "Resultat du parcours inaccessible")
	if fichier == null:
		quit(1)
		return
	fichier.store_string(JSON.stringify(rapport, "\t") + "\n")
	for cas: Dictionary in rapport["cas"]:
		print("%s %d epreuves, chapitre %d : debut %.1f tirs, un projectile %.1f %%, une attaque %.1f %%, boss %.1f s, contacts %.1f, DPS permanent %.1f" % [
			"Suite" if bool(cas["successives"]) else "Repetitions", int(cas["epreuves"]), int(cas["chapitre"]),
			float(cas["tirs_entree"]["mediane"]), float(cas["un_projectile"]["mediane"]) * 100.0,
			float(cas["une_attaque"]["mediane"]) * 100.0, float(cas["boss_final"]["mediane"]),
			float(cas["contacts_min"]["mediane"]), float(cas["dps_permanent"]["mediane"])])
	print("Retour campagne : %d/%d comptes sans boss > %.0f s ; murs observes %s." % [
		int(rapport["comptes_sans_mur_dps"]), int(rapport["nombre"]), Retour.Parcours.BOSS_LIMITE,
		JSON.stringify(rapport["murs_dps_observes"])])
	print("Retour campagne, premier contact mortel : " + JSON.stringify(rapport["premier_contact_mortel"]))
	for chapitre: int in rapport["progression"]:
		var mesure: Dictionary = rapport["progression"][chapitre]
		print("Continuation chapitre %d : une attaque %.1f %%, boss %.1f s, contacts %.1f" % [chapitre,
			float(mesure["une_attaque"]["mediane"]) * 100.0, float(mesure["boss_final"]["mediane"]),
			float(mesure["contacts_min"]["mediane"])])
	for erreur: String in _erreurs: push_error(erreur)
	print("Retour campagne : %d controles, %d erreurs." % [_controles, _erreurs.size()])
	quit(0 if _erreurs.is_empty() else 1)

func _exiger(condition: bool, message: String) -> void:
	_controles += 1
	if not condition: _erreurs.append(message)

func _verifier_specialisation(rapport: Dictionary) -> void:
	var avant := {"dps": 100.0, "pv_effectifs": 100.0}
	var defense := {"dps": 100.0, "pv_effectifs": 200.0}
	var attaque := {"dps": 110.0, "pv_effectifs": 100.0}
	_exiger(is_zero_approx(Retour.Simulation.score_choix(avant, defense, "tout_offensif")),
		"La politique tout offensive valorise une hausse de defense")
	_exiger(Retour.Simulation.score_choix(avant, attaque, "tout_offensif") > 0.0,
		"La politique tout offensive ignore une hausse de degats")
	# Le sur-farm garde une avance a l'entree du monde suivant. Les epiques et
	# legendaires peuvent effacer des rencontres ; verifier les rares seuls.
	for chapitre: int in rapport["progression"]:
		var mesure: Dictionary = rapport["progression"][chapitre]
		_exiger(float(mesure["rares_attaque"]["mediane"]) <= Retour.limite_retour_farm(chapitre),
			"Eliminations avec rares seuls trop courantes apres les Epreuves : " + str(chapitre))

func _verifier_comptes(rapport: Dictionary) -> void:
	for exemple: Dictionary in rapport["exemples"]:
		var actions: Array = exemple["actions"]
		_exiger(not bool(actions[0]["victoire"]) and int(actions[0]["salles_validees"]) == 8,
			"La premiere defaite n'est pas celle du scenario")
		_exiger(bool(actions[1]["victoire"]), "Le retry suppose victorieux a echoue")
		if bool(exemple["successives"]):
			_exiger(actions.size() == 3 and not (exemple["configurations"] as Dictionary).has(5),
				"Le scenario a joue des Epreuves successives sans campagne")
		else:
			_exiger(actions.size() == 8, "Les six repetitions n'ont pas toutes ete jouees")
		for action: Dictionary in actions:
			var avant: Dictionary = action["avant"]
			var apres: Dictionary = action["apres"]
			for cle: String in ["gouttes", "pierres"]:
				_exiger(int(apres[cle]) >= 0 and int(apres["recus"][cle]) - int(apres["depenses"][cle]) == int(apres[cle]),
					"Achat offensif sans ressources : " + cle)
			for achat: Dictionary in action["achats"]:
				_exiger(int(achat["prix"]) > 0, "Achat offert au compte offensif")
			var config: Dictionary = apres["configuration"]
			_exiger(int(config["attributs"].get("force", 0)) == Personnage.points_totaux(int(apres["niveau"])),
				"Le compte dit offensif investit ailleurs qu'en Force")
			if str(action["mode"]) == "epreuves":
				_exiger(int(action["niveau_annexe"]) <= Epreuves.niveau_accessible(int(avant["campagne_vaincue"]) + 1,
					int(avant["epreuve_debloquee"])), "Epreuve hors progression jouee")
			var mesure := Retour.Modeles.mesurer(config)
			_exiger((config.get("augments", []) as Array).is_empty(), "Les augments ont fui dans la progression permanente")
			_exiger(is_equal_approx(Retour.Parcours.Compte.score(config), log(float(mesure["dps"]))),
				"Les achats offensifs valorisent artificiellement la survie")

func _verifier_acces() -> void:
	var reglages := root.get_node("ReglagesJoueur")
	reglages.sauvegarde_active = false
	reglages.mode_dev = false
	reglages.reinitialiser_progression()
	_exiger(int(reglages.niveau_epreuve_accessible()) == 0 and not bool(reglages.choisir_epreuve(1)), "Epreuve accessible avant la premiere victoire")
	reglages.meilleures_par_chapitre["0"] = Reglages.SALLES_PAR_RUN
	_exiger(int(reglages.niveau_epreuve_accessible()) == 1 and bool(reglages.choisir_epreuve(1)), "Premiere Epreuve bloquee apres le chapitre un")
	reglages.niveau_epreuve_debloque = Epreuves.nombre()
	reglages.niveau_epreuve_choisi = Epreuves.nombre()
	_exiger(int(reglages.niveau_epreuve_accessible()) == 1 and not bool(reglages.choisir_epreuve(2)), "Les victoires d'Epreuve contournent la campagne")
	var jeu := root.get_node("Jeu")
	jeu.demarrer_run(123, 1, 0, "epreuves")
	_exiger(int(jeu.niveau_epreuve) == 1, "Une ancienne selection contourne le verrou")
	jeu.niveau_epreuve = Epreuves.nombre()
	jeu.preparer_nouvelle_tentative()
	jeu.demarrer_run()
	_exiger(int(jeu.niveau_epreuve) == 1, "Rejouer contourne le verrou")
	for niveau in range(2, Epreuves.nombre() + 1):
		reglages.meilleures_par_chapitre.clear()
		var requis := Epreuves.campagne_requise(niveau)
		for chapitre in range(requis - 2): reglages.meilleures_par_chapitre[str(chapitre)] = Reglages.SALLES_PAR_RUN
		_exiger(not bool(reglages.choisir_epreuve(niveau)), "Epreuve ouverte avant son chapitre")
		reglages.meilleures_par_chapitre[str(requis - 2)] = Reglages.SALLES_PAR_RUN
		_exiger(bool(reglages.choisir_epreuve(niveau)), "Epreuve fermee au chapitre requis")
	reglages.niveau_epreuve_debloque = 1
	_exiger(int(reglages.niveau_epreuve_accessible()) == 1, "La campagne saute les victoires d'Epreuves precedentes")
