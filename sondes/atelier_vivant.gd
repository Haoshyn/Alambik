extends SceneTree

var echecs := 0

func _initialize() -> void:
	call_deferred("verifier")

func photo(nom: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tmp/atelier-"+nom+".png")

func verifier() -> void:
	var regles := root.get_node("ReglagesJoueur")
	regles.sauvegarde_active = false
	regles.mode_dev = true
	root.size = Vector2i(540,1200)
	var menu: Control = load("res://scenes/menu.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	for entree in [[0,"equipement"],[2,"maitrises"],[3,"sorts"],[1,"accueil"]]:
		menu.call("_afficher_page",int(entree[0]),false)
		await create_timer(.5).timeout
		await photo(str(entree[1]))
	menu.queue_free()
	await process_frame
	for nom in ["draft","pause","reglages","selection_grimoire","alambic"]:
		var page: Control = load("res://ui/"+nom+".tscn").instantiate()
		root.add_child(page)
		await photo(nom)
		page.queue_free()
		await process_frame
	# Meme camera et meme aire jouable pour comparer les dix profils.
	var scene := Node3D.new()
	root.add_child(scene)
	var camera := Camera3D.new()
	scene.add_child(camera)
	var limites := Rect2(0,0,1260,1900)
	var centre := Pont3D.vers_monde(limites.get_center())
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.keep_aspect = Camera3D.KEEP_WIDTH
	camera.size = 16.0
	camera.position = centre+Vector3(0,30,27)
	camera.look_at(centre)
	var lumiere := DirectionalLight3D.new()
	lumiere.rotation_degrees = Vector3(-62,-32,0)
	lumiere.light_energy = 1.1
	scene.add_child(lumiere)
	var environnement := WorldEnvironment.new()
	environnement.environment = Environment.new()
	environnement.environment.background_mode = Environment.BG_COLOR
	environnement.environment.background_color = Color("ddd2be")
	environnement.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environnement.environment.ambient_light_color = Color("d3d3e6")
	environnement.environment.ambient_light_energy = .5
	scene.add_child(environnement)
	for monde in DecorsMondes.PROFILS.size():
		var arene: Node3D = load("res://scripts/presentation/arene_3d.gd").new()
		scene.add_child(arene)
		arene.construire(limites,Callable(),monde)
		for p in [Vector2(380,660),Vector2(860,970),Vector2(480,1380)]:
			var obstacle: Node3D = load("res://scripts/presentation/decor_alchimique.gd").obstacle(Vector3(1.7,0,1.4),0,monde)
			arene.add_child(obstacle)
			obstacle.position = Pont3D.vers_monde(p)
		await photo("monde-%02d" % monde)
		print("ATELIER_MONDE %d : %s / %d objets" % [monde,DecorsMondes.profil(monde)["nom"],arene.get_child_count()])
		arene.queue_free()
		await process_frame
	scene.queue_free()
	await process_frame
	print("ATELIER : captures des menus et des dix mondes terminees")
	quit(echecs)
