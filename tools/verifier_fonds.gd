extends Node

const DONNEES := preload("res://data/presentation/animations_decors.gd")
const CLAIRIERE := preload("res://ui/composants/illustration_accueil.gd")
const ILE := preload("res://ui/composants/ile_animee.gd")

var _erreurs: Array[String] = []

func _ready() -> void:
	if "verification" not in OS.get_user_data_dir().to_lower():
		push_error("Ce controle exige un profil de verification isole.")
		get_tree().quit(1)
		return
	ReglagesJoueur.sauvegarde_active = false
	ReglagesJoueur.volume_musique = 0.0
	ReglagesJoueur.volume_effets = 0.0
	Sons.appliquer_reglages()
	_verifier_masques()
	for format: Vector2i in [Vector2i(720, 1280), Vector2i(1080, 2340)]:
		get_tree().root.size = format
		ReglagesJoueur.effets_reduits = false
		var fond := CLAIRIERE.new()
		fond.size = Vector2(format)
		add_child(fond)
		await get_tree().process_frame
		fond.set_process(false)
		_verifier_rendu(fond)
		_verifier_clairiere(fond)
		_verifier_gel(fond)
		fond.queue_free()
		await get_tree().process_frame
		for monde in DONNEES.MONDES.size():
			ReglagesJoueur.effets_reduits = false
			var ile := ILE.new()
			ile.size = Vector2(format) * Vector2(0.60, 0.50)
			add_child(ile)
			ile.afficher_monde(monde)
			await get_tree().process_frame
			ile.set_process(false)
			_verifier_rendu(ile)
			_verifier_gel(ile)
			ReglagesJoueur.effets_reduits = true
			ReglagesJoueur.reglages_changes.emit()
			var vue: SubViewport = ile.get("_vue_peinte")
			vue.render_target_update_mode = SubViewport.UPDATE_DISABLED
			ile.afficher_monde((monde + 1) % DONNEES.MONDES.size())
			_exiger(vue.render_target_update_mode == SubViewport.UPDATE_ONCE,
				"Le changement de monde ne rafraichit pas l'ile en effets reduits")
			ile.queue_free()
			await get_tree().process_frame
	Sons.arreter()
	for erreur: String in _erreurs:
		push_error(erreur)
	if _erreurs.is_empty():
		print("OK : sols et attaches fixes, masques de feuilles, mouvement continu, cinq iles, deux formats portrait, effets reduits et fond cache.")
	get_tree().quit(0 if _erreurs.is_empty() else 1)

func _verifier_rendu(peinture: Control) -> void:
	var vue: SubViewport = peinture.get("_vue_peinte")
	_exiger(not vue.snap_2d_transforms_to_pixel and not vue.snap_2d_vertices_to_pixel
		and not vue.gui_snap_controls_to_pixels, "Le fond arrondit encore les petits mouvements")
	_exiger(get_viewport().snap_2d_transforms_to_pixel and get_viewport().snap_2d_vertices_to_pixel,
		"Le fond a change la grille des commandes du menu")
	var pixels := peinture.size * peinture.get_screen_transform().get_scale().abs()
	_exiger(Vector2(vue.size).distance_to(pixels) < 1.5, "Le fond reserve une resolution superieure aux pixels affiches")
	var projection := vue.canvas_transform * peinture.size
	_exiger(projection.distance_to(Vector2(vue.size)) < 0.01, "Le rendu a change le cadrage de la peinture")

func _verifier_clairiere(fond: Control) -> void:
	var plateau: Control = fond.get("_plateau")
	var paysage := plateau.get_node("PaysageFixe") as TextureRect
	var cadre := paysage.get_global_transform()
	var rameaux: Array = fond.get("_rameaux")
	var attaches: Array[Vector2] = []
	for rameau: TextureRect in rameaux:
		attaches.append(rameau.get_global_transform() * rameau.pivot_offset)
	for temps: float in [0.0, 0.5, 2.0, 8.0, 2000.0]:
		fond.set("_temps", temps)
		fond.call("_animer")
		_exiger(paysage.material == null and paysage.get_global_transform() == cadre,
			"Le sol, les pierres ou les montagnes bougent avec le vent")
		for index in rameaux.size():
			var rameau: TextureRect = rameaux[index]
			var attache := rameau.get_global_transform() * rameau.pivot_offset
			_exiger(attache.distance_to(attaches[index]) < 0.001, "Une branche glisse hors de son attache")
	var nuages: Array = fond.get("_nuages")
	fond.set("_temps", 1.0)
	fond.call("_animer")
	var precedent: float = nuages[0].position.x
	for image in 60:
		fond.set("_temps", 1.0 + float(image + 1) / 60.0)
		fond.call("_animer")
		var courant: float = nuages[0].position.x
		_exiger(absf(courant - precedent - DONNEES.VITESSE_NUAGES / 60.0) < 0.001,
			"Un nuage avance par sauts")
		precedent = courant

func _verifier_gel(peinture: Control) -> void:
	var temps: float = peinture.get("_temps")
	ReglagesJoueur.effets_reduits = true
	ReglagesJoueur.reglages_changes.emit()
	_exiger(not peinture.is_processing(), "Les effets reduits laissent avancer le fond")
	var vue: SubViewport = peinture.get("_vue_peinte")
	_exiger(vue.render_target_update_mode == SubViewport.UPDATE_ONCE,
		"Les effets reduits redessinent le fond en continu")
	_exiger(float(peinture.get("_temps")) == temps, "Le gel remet l'animation a zero")
	peinture.hide()
	_exiger(vue.render_target_update_mode == SubViewport.UPDATE_DISABLED and not peinture.is_processing(),
		"Un fond cache continue son rendu")
	peinture.show()
	_exiger(vue.render_target_update_mode == SubViewport.UPDATE_ONCE,
		"Un fond fige ne retrouve pas son image a la reouverture")
	ReglagesJoueur.effets_reduits = false
	ReglagesJoueur.reglages_changes.emit()
	_exiger(peinture.is_processing() and float(peinture.get("_temps")) == temps,
		"La reprise fait sauter l'animation")
	peinture.set_process(false)

func _verifier_masques() -> void:
	# Ces points sont dans le bois et les grosses pierres des peintures sources.
	var protections := [
		[Vector2i(109, 156), Vector2i(74, 288), Vector2i(175, 121)],
		[Vector2i(322, 221), Vector2i(233, 156), Vector2i(356, 315)],
		[Vector2i(196, 252), Vector2i(686, 383), Vector2i(844, 482)],
	]
	for index in DONNEES.VENT_VEGETATION.size():
		var texture: Texture2D = DONNEES.VENT_VEGETATION[index]
		var masque := texture.get_image()
		var donnees: Dictionary = DONNEES.VEGETATION_FIXE[index]
		var peinture: Texture2D = donnees["image"]
		var echelle := Vector2(masque.get_size()) / peinture.get_size()
		for point: Vector2i in protections[index]:
			var pixel := Vector2i((Vector2(point) * echelle).floor())
			_exiger(masque.get_pixelv(pixel).r == 0.0, "Le masque du vent recouvre de la pierre ou du bois")

func _exiger(condition: bool, message: String) -> void:
	if not condition:
		_erreurs.append(message)
