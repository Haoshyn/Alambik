extends SceneTree

func _initialize() -> void:
	call_deferred("capturer")

func capturer() -> void:
	root.get_node("ReglagesJoueur").sauvegarde_active = false
	root.size = Vector2i(608, 1080)
	Engine.max_fps = 30
	var run: Node = load("res://scenes/run.tscn").instantiate()
	root.add_child(run)
	current_scene = run
	await process_frame
	var salle: Node2D = run.get("_salle")
	var heros: CharacterBody2D = run.get("_heros")
	salle.set_process(false)
	for enfant in salle.get_children():
		if enfant.is_in_group("ennemis") or enfant is Area2D:
			enfant.queue_free()
	await process_frame
	heros.position = Vector2(350, 1270)
	salle.faire_apparaitre("encrier_rampant", Vector2(350, 1010))
	await process_frame
	for ennemi in get_nodes_in_group("ennemis"):
		ennemi.set("_apparition", 1.0)
		ennemi.set("pv", 100000.0)
		ennemi.set_physics_process(false)
	var dossier := "res://tmp/apprenti-a/"
	var detail := "--detail" in OS.get_cmdline_user_args()
	if detail:
		var camera: Camera2D = run.get("_camera")
		camera.zoom *= 1.8
	for i in 180:
		var direction := Vector2.ZERO
		if i >= 30 and i < 40: direction = Vector2.LEFT
		elif i >= 100 and i < 113: direction = Vector2.RIGHT
		heros.definir_intention(direction)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(dossier + ("combat-detail-%03d.png" if detail else "combat-%03d.png") % i)
	print("APERCU_COMBAT : course, arrets et tirs automatiques reels a la camera de jeu")
	run.queue_free()
	await process_frame
	quit()
