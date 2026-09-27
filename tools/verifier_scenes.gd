extends Node

const MENU := preload("res://scenes/menu.tscn")
const RUN := preload("res://scenes/run.tscn")

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
	for mode: String in ["grimoire", "mine", "epreuves"]:
		ReglagesJoueur.mode_run_choisi = mode
		Jeu.nouvelle_tentative.clear()
		var aventure := RUN.instantiate()
		add_child(aventure)
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
		aventure.queue_free()
		await get_tree().process_frame
	Sons.arreter()
	for erreur: String in _erreurs: push_error(erreur)
	if _erreurs.is_empty(): print("OK : cinq onglets sur deux formats et trois modes de combat instancies.")
	get_tree().quit(0 if _erreurs.is_empty() else 1)

func _exiger(condition: bool, message: String) -> void:
	if not condition: _erreurs.append(message)
