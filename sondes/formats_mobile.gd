extends SceneTree

var echecs := 0
var controles := 0
var menu: Control

func _initialize() -> void:
	call_deferred("verifier")

func exiger(condition: bool, texte: String) -> void:
	controles += 1
	if not condition:
		echecs += 1
		push_error(texte)

func attendre() -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw

func verifier() -> void:
	root.get_node("ReglagesJoueur").sauvegarde_active = false
	menu = load("res://scenes/menu.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	await create_timer(2.0).timeout
	for format in [Vector2i(540,960), Vector2i(540,1200), Vector2i(480,800), Vector2i(768,1024), Vector2i(960,540)]:
		root.size = format
		await attendre()
		var transformation := root.get_screen_transform()
		# Le rectangle physique est arrondi au pixel, notamment en paysage.
		exiger(absf(transformation.x.length()-transformation.y.length())*1080.0 <= 1.0, "Proportions conservees : %s" % format)
		exiger(root.get_visible_rect().size.is_equal_approx(Vector2(1080,1920)), "Cadre de jeu complet : %s" % format)
		for page in [1,0,2,3]:
			menu.call("_afficher_page",page,false)
			await create_timer(0.45).timeout
			await attendre()
			var contenu: Control = menu.get("_page_actuelle")
			for bouton in contenu.find_children("*","Button",true,false):
				if not bouton.is_visible_in_tree():
					continue
				var visible := _rectangle_visible(bouton)
				if visible.size.x <= 0.0 or visible.size.y <= 0.0: continue
				exiger(root.get_visible_rect().encloses(visible), "Bouton hors ecran : %s / %s / %s" % [format,page,bouton.name])
			var onglets: Array = menu.get("_onglets")
			for onglet in onglets:
				if not onglet.is_visible_in_tree(): continue
				exiger(root.get_visible_rect().encloses(onglet.get_global_rect()), "Navigation hors ecran : %s" % format)
				for bouton in contenu.find_children("*","Button",true,false):
					if bouton.is_visible_in_tree():
						exiger(not _rectangle_visible(bouton).intersects(onglet.get_global_rect()), "Navigation recouvre %s / page %s" % [bouton.name,page])
			if page == 1:
				root.get_texture().get_image().save_png("res://tmp/accueil-%dx%d.png" % [format.x,format.y])
		print("FORMAT_VERIFIE %s / echecs cumules %d" % [format,echecs])
	menu.call("_afficher_page",1,false)
	await attendre()
	menu.call("_afficher_page",0,true)
	menu.call("_afficher_page",3,true)
	await create_timer(0.6).timeout
	exiger(not menu.get("_transition_page"), "Transition deverrouillee")
	exiger(menu.get("_conteneur_pages").get_child_count()==1, "Une seule page apres appuis rapides")
	menu.call("_ouvrir_reglages")
	await attendre()
	var panneau: Control = menu.get("_superposition")
	exiger(is_instance_valid(panneau), "Ouverture des reglages")
	exiger(menu.get("_conteneur_pages").process_mode==Node.PROCESS_MODE_DISABLED, "Inventaire inactif sous les reglages")
	menu.call("_ouvrir_reglages")
	exiger(menu.get("_superposition")==panneau, "Pas de double superposition")
	panneau.emit_signal("ferme")
	await attendre()
	exiger(menu.get("_superposition")==null, "Fermeture des reglages")
	exiger(menu.get("_conteneur_pages").process_mode==Node.PROCESS_MODE_INHERIT, "Inventaire reactive apres fermeture")
	menu.call("_afficher_page",1,false)
	await attendre()
	var accueil: Control = menu.get("_page_actuelle")
	accueil.emit_signal("jouer")
	await create_timer(2.5).timeout
	exiger(is_instance_valid(current_scene) and current_scene.scene_file_path=="res://scenes/run.tscn", "Jouer ouvre le combat")
	if is_instance_valid(current_scene):
		current_scene.queue_free()
	await attendre()
	print("FORMATS_MOBILE : %d controles, %d echecs" % [controles,echecs])
	quit(1 if echecs else 0)

func _rectangle_visible(controle: Control) -> Rect2:
	var rect := controle.get_global_rect()
	var parent := controle.get_parent()
	while parent != null:
		if parent is Control and parent.clip_contents:
			rect = rect.intersection(parent.get_global_rect())
		parent = parent.get_parent()
	return rect
