extends Node

# Lancer uniquement avec un XDG_DATA_HOME de test et --profil-isole.
var _verifications := 0
var _echecs := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if "--profil-isole" not in OS.get_cmdline_user_args() or OS.get_environment("XDG_DATA_HOME").is_empty():
		push_error("Cette sonde exige un profil isolé explicite.")
		get_tree().quit(2)
		return
	ReglagesJoueur.sauvegarde_active = false
	await get_tree().process_frame
	if "--combat" in OS.get_cmdline_user_args():
		_lancer_combat()
		return
	_tester_parcours()
	_tester_avance()
	await _tester_interfaces()
	_terminer()

func _verifier(condition: bool, detail: String) -> void:
	_verifications += 1
	if not condition:
		_echecs += 1
		push_error("ECHEC : " + detail)

func _tester_parcours() -> void:
	ReglagesJoueur.reinitialiser_progression()
	_verifier(ParcoursTutoriel.prochaine_etape() == "combat", "Premier lancement : niveau tutoriel")
	_verifier(not ReglagesJoueur.mode_debloque("mine"), "Mine avant initiation")
	ParcoursTutoriel.commencer()
	Jeu.demarrer_run(42, 1, 0, DonneesTutoriel.MODE)
	_verifier(Jeu.salles_du_chapitre() == 5 and not Jeu.est_boss_courant(), "Cinq étages séparés")
	_verifier(ReglagesJoueur.projectile_equipe == DonneesTutoriel.ARME, "Première arme équipée")
	Jeu.salle_courante = 5
	_verifier(Jeu.est_boss_courant(), "Mini-boss au cinquième étage")
	var defaite := BilanRun.finaliser(false, 5)
	_verifier(int(defaite["gouttes"]) == 0 and ParcoursTutoriel.niveau_a_faire(), "Défaite sans cadeau, nouvel essai possible")
	Jeu.demarrer_run(42, 1, 0, DonneesTutoriel.MODE)
	var bilan := BilanRun.finaliser(true, 5)
	var cadeau := DonneesTutoriel.recompense_gouttes()
	_verifier(int(bilan["gouttes"]) == cadeau and ReglagesJoueur.gouttes == cadeau, "Cadeau exact")
	BilanRun.finaliser(true, 5)
	ParcoursTutoriel.terminer_niveau(true)
	_verifier(ReglagesJoueur.gouttes == cadeau, "Récompense non duplicable")
	_verifier(ReglagesJoueur.niveau_compte == 1 and ReglagesJoueur.runs == 0
		and ReglagesJoueur.meilleures_par_chapitre.is_empty(), "Aucune avance campagne ou XP")
	_verifier(ReglagesJoueur.mode_debloque("mine") and ReglagesJoueur.mode_debloque("epreuve_sorts"), "Deux annexes accessibles")
	ReglagesJoueur.acheter_competence(DonneesTutoriel.MAITRISE)
	_verifier(ReglagesJoueur.gouttes == 0 and ReglagesJoueur.rang_competence(DonneesTutoriel.MAITRISE) == 1,
		"Cadeau pour exactement un rang")
	ParcoursTutoriel.noter("accueil_vu")
	ParcoursTutoriel.resultat_annexe("epreuve_sorts", "")
	_verifier(ParcoursTutoriel.sort_a_expliquer().is_empty(), "Pas de commandes sans sort gagné")
	ReglagesJoueur.debloquer_sort("moisson_vitale")
	ParcoursTutoriel.resultat_annexe("epreuve_sorts", "moisson_vitale")
	_verifier(ParcoursTutoriel.sort_a_expliquer().is_empty(), "Un passif ne déclenche pas la visée")
	ReglagesJoueur.debloquer_sort("onde_alchimique")
	ParcoursTutoriel.resultat_annexe("epreuve_sorts", "onde_alchimique")
	_verifier(ParcoursTutoriel.prochaine_etape() == "commandes", "Commandes après le premier actif d’épreuve")
	_verifier_persistance("Reprise du tutoriel après relance")
	ParcoursTutoriel.passer()
	ParcoursTutoriel.resultat_annexe("epreuve_sorts", "onde_alchimique")
	_verifier(not ParcoursTutoriel.actif() and ParcoursTutoriel.sort_a_expliquer().is_empty(), "Passer supprime les leçons suivantes")
	_verifier_persistance("Tutoriel passé mémorisé")
	ReglagesJoueur.reinitialiser_progression()
	ParcoursTutoriel.passer()
	ParcoursTutoriel.terminer_niveau(true)
	_verifier(ReglagesJoueur.gouttes == 0 and ReglagesJoueur.mode_debloque("mine"), "Passer sans cadeau ouvre les modes")
	# Une sauvegarde d'avant cette fonctionnalite n'impose pas une initiation.
	var ancien := ConfigFile.new()
	ancien.set_value("resultats", "runs", 3)
	ancien.set_value("campagne", "version", ReglagesJoueur.VERSION_CAMPAGNE)
	ancien.save(ReglagesJoueur.FICHIER)
	ReglagesJoueur.charger()
	_verifier(ParcoursTutoriel.etat() == "ancien" and not ParcoursTutoriel.actif(), "Migration des comptes existants")
	print("Parcours : récompense, relances, passage et migration vérifiés")

func _verifier_persistance(detail: String) -> void:
	var avant := ReglagesJoueur.capturer_progression()
	ReglagesJoueur.sauvegarde_active = true
	ReglagesJoueur.sauvegarder()
	ReglagesJoueur.sauvegarde_active = false
	ReglagesJoueur.reinitialiser_progression()
	ReglagesJoueur.charger()
	_verifier(ReglagesJoueur.capturer_progression() == avant, detail)

func _tester_avance() -> void:
	ReglagesJoueur.reinitialiser_progression()
	ReglagesJoueur.mode_dev = true
	var avant := ReglagesJoueur.capturer_progression()
	var destination := 3 * Chapitres.CHAPITRES_PAR_MONDE
	var apercu := ProgressionDeveloppement.preparer(destination)
	_verifier(ReglagesJoueur.capturer_progression() == avant and ReglagesJoueur.mode_dev,
		"Calcul sans modifier le compte ni dépendre du mode développeur")
	_verifier(apercu == ProgressionDeveloppement.preparer(destination), "Tirages reproductibles")
	_verifier(ProgressionDeveloppement.preparer(-1).is_empty()
		and ProgressionDeveloppement.preparer(Chapitres.nombre()).is_empty(), "Destinations invalides refusées")
	_verifier(int(apercu["campagnes"]) == 105 and int(apercu["mines"]) == 110
		and int(apercu["epreuves"]) == 40, "Monde 4 : 105 campagnes, 110 Mines, 40 Épreuves")
	var progression: Dictionary = apercu["progression"]
	var gouttes := DonneesTutoriel.recompense_gouttes()
	var pierres := 0
	var xp := 0
	var repartition := {}
	for entree: Dictionary in apercu["journal"]:
		var bilan: Dictionary = entree["bilan"]
		gouttes += int(bilan["gouttes"])
		pierres += int(bilan["pierres"])
		xp += int(bilan["xp"])
		var cle := "%s:%d" % [entree["mode"], entree["epreuve"] if entree["mode"] == "epreuve_sorts" else entree["palier"]]
		repartition[cle] = int(repartition.get(cle, 0)) + 1
	var cinq_partout := true
	for nombre: int in repartition.values():
		cinq_partout = cinq_partout and nombre == AvanceDeveloppement.VICTOIRES_PAR_NIVEAU
	_verifier(cinq_partout, "Chaque niveau est gagné exactement cinq fois")
	_verifier(int(progression["gouttes"]) == gouttes and int(progression["pierres_forge"]) == pierres,
		"Soldes égaux à la somme des vrais coffres")
	ReglagesJoueur.volume_musique = 0.37
	_verifier(ReglagesJoueur.appliquer_progression(progression), "Application de l’aperçu")
	_verifier(not ReglagesJoueur.mode_dev and is_equal_approx(ReglagesJoueur.volume_musique, 0.37),
		"Avantages développeur retirés, réglages audio préservés")
	_verifier(ReglagesJoueur.chapitre_choisi == destination and ReglagesJoueur.chapitre_debloque(destination)
		and not ReglagesJoueur.chapitre_debloque(destination + 1)
		and ReglagesJoueur.meilleure_du_chapitre(destination) == 0, "Début du monde 4 sans victoire de trop")
	_verifier(ReglagesJoueur.runs == 255 and ReglagesJoueur.victoires == 255, "Compteurs de victoires natifs")
	_verifier(ReglagesJoueur.niveau_epreuve_debloque == 9 and not ReglagesJoueur.rangs_sorts.is_empty()
		and not ReglagesJoueur.objets.is_empty(), "Capacités, bijoux et Épreuve suivante obtenus")
	var temoin: Node = ReglagesJoueur.get_script().new()
	temoin.sauvegarde_active = false
	temoin.ajouter_experience_compte(xp)
	_verifier(ReglagesJoueur.niveau_compte == temoin.niveau_compte
		and ReglagesJoueur.experience_compte == temoin.experience_compte, "XP exacte du journal")
	temoin.free()
	_verifier_persistance("Avance conservée après relance")
	print("Monde 4 : %d gouttes, %d pierres, niveau %d ; %d victoires" % [gouttes, pierres,
		ReglagesJoueur.niveau_compte, ReglagesJoueur.victoires])
	ReglagesJoueur.mode_dev = true
	ReglagesJoueur.reinitialiser_progression()
	_verifier(not ReglagesJoueur.mode_dev and ReglagesJoueur.gouttes == 0
		and ReglagesJoueur.pierres_forge == 0 and ReglagesJoueur.rangs_sorts.is_empty()
		and ReglagesJoueur.objets.is_empty() and ParcoursTutoriel.niveau_a_faire(), "Réinitialisation complète")
	_verifier_persistance("Réinitialisation conservée après relance")

func _tester_interfaces() -> void:
	var guide := GuideAccueil.new()
	add_child(guide)
	guide.presenter()
	_verifier(guide.est_ouvert() and get_tree().paused, "Accueil tutoriel modal")
	guide._confirmer_passage()
	guide._agir("annuler")
	_verifier(guide.est_ouvert() and ParcoursTutoriel.actif(), "Annulation conserve la leçon")
	guide._agir("combat")
	_verifier(not guide.est_ouvert() and not get_tree().paused, "La leçon rend la main au jeu")
	get_tree().paused = true
	guide._confirmer_passage()
	guide._agir("annuler")
	_verifier(get_tree().paused, "Annulation préserve une pause préexistante")
	get_tree().paused = false
	guide._confirmer_passage()
	guide._agir("confirmer_passage")
	_verifier(not ParcoursTutoriel.actif() and not get_tree().paused, "Confirmation du passage")
	guide.queue_free()
	ReglagesJoueur.reinitialiser_progression()
	ParcoursTutoriel.commencer()
	ParcoursTutoriel.terminer_niveau(true)
	var commandes := preload("res://ui/reglages.tscn").instantiate()
	commandes.section_tutoriel = "commandes"
	add_child(commandes)
	await get_tree().process_frame
	_verifier(not ParcoursTutoriel.fait("commandes_vues"), "Les paramètres ne valident pas prématurément la leçon des sorts")
	commandes.queue_free()
	ReglagesJoueur.debloquer_sort("onde_alchimique")
	ParcoursTutoriel.resultat_annexe("epreuve_sorts", "onde_alchimique")
	commandes = preload("res://ui/reglages.tscn").instantiate()
	commandes.section_tutoriel = "commandes"
	add_child(commandes)
	await get_tree().process_frame
	_verifier(ParcoursTutoriel.fait("commandes_vues"), "Leçon des commandes après acquisition en Épreuve")
	commandes.queue_free()
	var reglages := preload("res://ui/reglages.tscn").instantiate()
	add_child(reglages)
	reglages._ouvrir_avance()
	var avance: Control = reglages._avance
	_verifier(is_instance_valid(avance), "Ouverture des outils depuis les paramètres")
	avance._monde.selected = 3
	avance._chapitre.selected = 0
	avance._calculer()
	_verifier(not avance._appliquer.disabled and int(avance._apercu["chapitre"]) == 21, "Aperçu depuis l’interface")
	avance._invalider(0)
	_verifier(avance._appliquer.disabled and avance._apercu.is_empty(), "Changement de destination invalide l’aperçu")
	reglages.queue_free()
	await get_tree().process_frame
	# Garder la sonde en racine pendant que le vrai menu est remplace.
	var menu := preload("res://scenes/menu.tscn").instantiate()
	get_tree().root.add_child(menu)
	get_tree().current_scene = menu
	menu._afficher_page(2, false)
	menu._ouvrir_reglages()
	var options: Control = menu._superposition
	options._ouvrir_avance()
	avance = options._avance
	avance._monde.selected = 3
	avance._chapitre.selected = 0
	avance._calculer()
	var attendu: Dictionary = avance._apercu["progression"].duplicate(true)
	get_tree().paused = true
	avance._remplacer()
	await get_tree().scene_changed
	_verifier(not is_instance_valid(menu) and not get_tree().paused
		and ReglagesJoueur.capturer_progression() == attendu, "Avancer depuis le bouton applique l’aperçu et quitte la pause")
	menu = get_tree().current_scene
	menu._ouvrir_reglages()
	options = menu._superposition
	options._sur_reset()
	_verifier(options._confirmation_reset, "Premier appui demande confirmation")
	Jeu.nouvelle_tentative = {"mode": "mine", "chapitre": 4, "epreuve": 2}
	Jeu.destination_menu = {"page": "sorts"}
	options._sur_reset()
	await get_tree().scene_changed
	_verifier(not is_instance_valid(menu) and get_tree().current_scene.scene_file_path == "res://scenes/menu.tscn"
		and Jeu.nouvelle_tentative.is_empty() and Jeu.destination_menu.is_empty()
		and not get_tree().paused and ParcoursTutoriel.niveau_a_faire(), "Reset ferme l’ancienne scène et rouvre un accueil neuf")
	print("Interfaces : guide, confirmations, aperçu et retour après reset vérifiés")

func _lancer_combat() -> void:
	ReglagesJoueur.reinitialiser_progression()
	ParcoursTutoriel.commencer()
	var run := preload("res://scenes/run.tscn").instantiate()
	add_child(run)
	Jeu.run_terminee.connect(_fin_combat, CONNECT_DEFERRED)
	get_tree().create_timer(480.0, true).timeout.connect(func():
		_verifier(false, "Combat tutoriel bloqué après huit minutes de jeu")
		_terminer())

func _fin_combat(victoire: bool) -> void:
	_verifier(victoire and Jeu.salle_courante == 5, "Bot : victoire au cinquième étage")
	_verifier(Jeu.salles_terminees.size() == 5 and Jeu.boss_vaincus.size() == 1, "Bot : cinq salles et un mini-boss validés")
	_verifier(ReglagesJoueur.gouttes == DonneesTutoriel.recompense_gouttes()
		and ReglagesJoueur.niveau_compte == 1 and ReglagesJoueur.runs == 0, "Bot : bilan tutoriel réel")
	_terminer()

func _terminer() -> void:
	print("RESULTAT : %d vérifications, %d échecs" % [_verifications, _echecs])
	get_tree().paused = false
	get_tree().quit(0 if _echecs == 0 else 1)
