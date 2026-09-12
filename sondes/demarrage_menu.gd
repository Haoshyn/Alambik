extends SceneTree

func _initialize() -> void:
	call_deferred("verifier")

func verifier() -> void:
	root.get_node("ReglagesJoueur").sauvegarde_active = false
	root.size = Vector2i(608,1080)
	var v := Verif.new()
	var menu: Control = load("res://scenes/menu.tscn").instantiate()
	root.add_child(menu)
	var pages: Control = menu.get("_conteneur_pages")
	var navigation: Control = menu.get("_navigation")
	v.vrai(pages.visible,"le menu est visible des sa construction")
	v.vrai(navigation.visible,"la navigation ne reste pas masquee par une intro")
	v.vrai(is_instance_valid(menu.get("_page_actuelle")),"la page aventure est deja construite")
	v.egal(ProjectSettings.get_setting("application/boot_splash/show_image",true),false,"le splash moteur est desactive dans la section application")
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tmp/demarrage-premiere-image.png")
	await create_timer(.35).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tmp/demarrage-menu.png")
	print("DEMARRAGE_MENU : %d assertions, %d echecs" % [v.total,v.echecs.size()])
	for echec in v.echecs: push_error(echec)
	menu.queue_free()
	await process_frame
	quit(1 if not v.echecs.is_empty() else 0)
