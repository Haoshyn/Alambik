extends Node

const MENU := preload("res://scenes/menu.tscn")
const RUN := preload("res://scenes/run.tscn")
const ARENE_3D := preload("res://scripts/presentation/arene_3d.gd")

var _erreurs: Array[String] = []

func _ready() -> void:
	if "verification" not in OS.get_user_data_dir().to_lower():
		push_error("Utiliser tools/verifier.ps1 : ce controle exige un profil isole.")
		get_tree().quit(1)
		return
	ReglagesJoueur.sauvegarde_active = false
	ReglagesJoueur.specialisation = "sorcier"
	ReglagesJoueur.mode_dev = false
	ReglagesJoueur.volume_musique = 0.0
	ReglagesJoueur.volume_effets = 0.0
	Sons.appliquer_reglages()
	for id: String in Passifs.CATALOGUE:
		ReglagesJoueur.rangs_passifs[id] = Passifs.RANG_MAX
	ReglagesJoueur.passifs_equipes.assign(["vigueur", "vitalite", "celerite", "sang_froid"])
	for format: Vector2i in [Vector2i(720, 1280), Vector2i(1080, 2340)]:
		ReglagesJoueur.effets_reduits = format.x == 720
		get_tree().root.size = format
		var menu := MENU.instantiate()
		add_child(menu)
		for page in 5:
			menu.call("_afficher_page", page, false)
			await get_tree().process_frame
			await get_tree().process_frame
			var contenu: Control = menu.get("_page_actuelle")
			_exiger(is_instance_valid(contenu) and contenu.size.x > 0.0, "Page menu vide : %d" % page)
			if page == 4:
				var slots: Array = contenu.get("_slots")
				_exiger(slots.size() == Passifs.EMPLACEMENTS, "Emplacements passifs manquants")
		await _verifier_campagne(menu)
		menu.queue_free()
		await get_tree().process_frame
		ReglagesJoueur.meilleures_par_chapitre["0"] = Reglages.SALLES_PAR_RUN
		ReglagesJoueur.niveau_epreuve_debloque = Epreuves.nombre()
		ReglagesJoueur.niveau_epreuve_choisi = Epreuves.nombre()
		var selection := preload("res://ui/selection_mode.gd").new()
		selection.mode = "epreuves"
		add_child(selection)
		await get_tree().process_frame
		_exiger(int(selection.get("_niveau")) == 1 and int(selection.call("_nombre_debloque")) == 1,
			"La selection d'Epreuves ignore le palier de campagne")
		selection.queue_free()
		await get_tree().process_frame
	for scenario in 6:
		var mode: String = ["grimoire", "mine", "epreuves"][scenario % 3]
		get_tree().root.size = Vector2i(720,1280) if scenario < 3 else Vector2i(1080,2340)
		ReglagesJoueur.effets_reduits = scenario < 3
		ReglagesJoueur.mode_run_choisi = mode
		Jeu.nouvelle_tentative.clear()
		var aventure := RUN.instantiate()
		add_child(aventure)
		# Les vrais contours de chaque mode alimentent le decor, meme lorsque
		# le run headless n'instancie pas les proxies 3D des combattants.
		var arene := ARENE_3D.new()
		aventure.add_child(arene)
		_construire_decor(arene, aventure)
		await get_tree().process_frame
		_exiger(Jeu.mode_run == mode, "Mauvais mode lance : " + mode)
		var heros: CharacterBody2D = aventure.get("_heros")
		_exiger(is_instance_valid(heros), "Heros absent : " + mode)
		var hud: Control = aventure.get("_hud")
		_exiger(is_instance_valid(hud), "HUD absent : " + mode)
		if is_instance_valid(heros):
			for id: String in ["salve", "pointe_lucide", "egide"]: Jeu.ajouter_reactif(id)
			heros.call("recalculer")
		for frame in 100:
			await get_tree().physics_frame
		var salle_suivante := Jeu.salle_courante + 1
		await aventure.call("_avancer_salle")
		_construire_decor(arene, aventure)
		for frame in 3: await get_tree().process_frame
		_exiger(arene.get_child_count() == 2, "Ancien decor conserve a la transition : " + mode)
		_exiger(Jeu.salle_courante == salle_suivante, "La transition n'avance pas la salle : " + mode)
		aventure.queue_free()
		await get_tree().process_frame
	Sons.arreter()
	for erreur: String in _erreurs: push_error(erreur)
	if _erreurs.is_empty(): print("OK : cinq onglets, selection de campagne et reglages cliquables ; trois modes de combat et decors 3D avec transition sur deux formats.")
	get_tree().quit(0 if _erreurs.is_empty() else 1)

func _construire_decor(arene: Node3D, aventure: Node) -> void:
	var salle: Node2D = aventure.get("_salle")
	arene.construire(salle.limites,Callable(),int(Jeu.chapitre_courant()["monde"]),salle.contour_sol(),
		TerrainsMondes.variante(salle.numero,Jeu.chapitre,Jeu.graine))
	arene.avancer_ambiance(.5,ReglagesJoueur.effets_reduits)

func _verifier_campagne(menu: Control) -> void:
	menu.call("_afficher_page", 2, false)
	await _attendre_interface()
	var accueil: Control = menu.get("_page_actuelle")
	await _cliquer(accueil.find_child("ChoisirCampagneIllustration", true, false) as Control)
	var selection: Control = menu.get("_superposition")
	_exiger(is_instance_valid(selection), "L'ile n'ouvre pas la selection de campagne")
	if not is_instance_valid(selection): return
	var choisir: Button = selection.get("_bouton_selectionner")
	var navigation: Control = menu.get("_navigation")
	var onglets: Array = navigation.get("_onglets")
	_exiger(choisir.get_global_rect().end.y <= (onglets[0] as Control).global_position.y,
		"La commande de selection est cachee sous la navigation")
	await _cliquer(selection.get("_suivant") as Control)
	_exiger(int(selection.get("_monde")) == 1, "La fleche ne change pas de monde")
	var reperes: Array = selection.get("_zones_chapitres")
	await _cliquer((reperes[2] as Control).get("_bouton") as Control)
	_exiger(int(selection.get("_chapitre_monde")) == 2, "Le repere ne selectionne pas le niveau")
	_exiger(choisir.disabled, "Un niveau verrouille devient jouable")
	var bandeau := selection.find_child("BandeauCampagne", true, false)
	var bouton_reglages := bandeau.get_node("Reglages") as Button
	await _cliquer(bouton_reglages)
	var parametres: Control = menu.get("_superposition")
	_exiger(is_instance_valid(parametres) and parametres != selection,
		"Le bouton des reglages ne repond pas depuis la campagne")
	if parametres == selection or not is_instance_valid(parametres): return
	_exiger(not selection.is_visible_in_tree() and not selection.can_process(),
		"La carte continue de reagir sous les reglages")
	_exiger(not navigation.can_process(), "Les onglets restent actifs sous les reglages")
	var reprendre: Button
	for bouton: Node in parametres.find_children("*", "Button", true, false):
		if (bouton as Button).text == "Reprendre": reprendre = bouton as Button
	await _cliquer(reprendre)
	_exiger(menu.get("_superposition") == selection and selection.is_visible_in_tree(),
		"Reprendre ne revient pas a la selection de campagne")
	_exiger(int(selection.get("_monde")) == 1 and int(selection.get("_chapitre_monde")) == 2,
		"Les reglages ont perdu le monde ou le niveau consulte")
	await _cliquer(bouton_reglages)
	menu.call("_notification", NOTIFICATION_WM_GO_BACK_REQUEST)
	await _attendre_interface()
	_exiger(menu.get("_superposition") == selection, "Le retour Android ne retrouve pas la campagne")
	await _cliquer(selection.get("_precedent") as Control)
	await _cliquer((reperes[0] as Control).get("_bouton") as Control)
	await _cliquer(choisir)
	_exiger(menu.get("_superposition") == null, "Choisir le niveau ne ferme pas la carte")
	_exiger(ReglagesJoueur.chapitre_choisi == 0, "Le niveau choisi n'est pas conserve")
	_exiger((accueil.find_child("Reglages", true, false) as Control).is_visible_in_tree(),
		"Le bandeau d'Aventure ne reapparait pas apres la selection")
	await _cliquer(accueil.find_child("Reglages", true, false) as Control)
	_exiger(menu.get("_superposition") != null, "Les reglages d'Aventure ne repondent plus")
	menu.call("_notification", NOTIFICATION_WM_GO_BACK_REQUEST)
	await _attendre_interface()

func _cliquer(controle: Control) -> void:
	_exiger(is_instance_valid(controle), "Cible de clic absente")
	if not is_instance_valid(controle): return
	var position := controle.get_global_rect().get_center()
	var mouvement := InputEventMouseMotion.new()
	mouvement.position = position
	get_viewport().push_input(mouvement, true)
	for presse: bool in [true, false]:
		var clic := InputEventMouseButton.new()
		clic.button_index = MOUSE_BUTTON_LEFT
		clic.position = position
		clic.pressed = presse
		get_viewport().push_input(clic, true)
		await get_tree().process_frame
	await _attendre_interface()

func _attendre_interface() -> void:
	# Les tweens d'entree et de sortie doivent finir avant le prochain geste.
	await get_tree().create_timer(0.46).timeout
	await get_tree().process_frame

func _exiger(condition: bool, message: String) -> void:
	if not condition: _erreurs.append(message)
