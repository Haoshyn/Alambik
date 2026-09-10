extends SceneTree

class Doublure extends CharacterBody2D:
	signal tir_demande(tir, origine: Vector2, direction: Vector2)
	signal touchee(position: Vector2)
	signal morte

func _initialize() -> void:
	call_deferred("capturer")

func capturer() -> void:
	root.get_node("ReglagesJoueur").sauvegarde_active = false
	root.size = Vector2i(900, 1000)
	root.content_scale_size = root.size
	var scene := Node3D.new()
	root.add_child(scene)
	var doublure := Doublure.new()
	root.add_child(doublure)
	doublure.set_physics_process(false)
	var proxy: Node3D = load("res://scripts/presentation/proxy_3d.gd").new()
	scene.add_child(proxy)
	proxy.preparer(doublure, load(Visuels3D.HEROS_MODELE), "heros")
	var environnement := WorldEnvironment.new()
	environnement.environment = Environment.new()
	environnement.environment.background_mode = Environment.BG_COLOR
	environnement.environment.background_color = Color("172c36")
	environnement.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environnement.environment.ambient_light_color = Color("c3d9e8")
	environnement.environment.ambient_light_energy = 0.55
	scene.add_child(environnement)
	var lumiere := DirectionalLight3D.new()
	lumiere.rotation_degrees = Vector3(-42,-30,0)
	lumiere.light_color = Color("ffe8d3")
	lumiere.light_energy = 0.9
	lumiere.shadow_enabled = true
	lumiere.directional_shadow_max_distance = 12.0
	scene.add_child(lumiere)
	var camera := Camera3D.new()
	scene.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.55
	var sol := MeshInstance3D.new()
	var plan := PlaneMesh.new()
	plan.size = Vector2(200,200)
	sol.mesh = plan
	sol.position.y = -.01
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("243d48")
	mat.roughness = 1.0
	sol.material_override = mat
	scene.add_child(sol)
	var titre := Label.new()
	titre.position = Vector2(36,30)
	titre.add_theme_font_size_override("font_size",24)
	titre.text = "ALAMBIK / LE MAGE"
	root.add_child(titre)
	var legende := Label.new()
	legende.position = Vector2(36,68)
	legende.add_theme_font_size_override("font_size",18)
	legende.modulate = Color("abd9df")
	root.add_child(legende)
	var poses := "--poses" in OS.get_cmdline_user_args()
	var main := "--main" in OS.get_cmdline_user_args()
	var dossier := "res://tmp/heros-polissage/"+("main" if main else ("poses" if poses else "images"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dossier))
	var exclusion := FileAccess.open("res://tmp/heros-polissage/.gdignore", FileAccess.WRITE)
	exclusion.close()
	for i in 720:
		var t := float(i)/60.0
		var vitesse := smoothstep(1.0,1.35,t)*(1.0-smoothstep(8.3,8.65,t))
		doublure.velocity = Vector2.DOWN * Reglages.HEROS_VITESSE * vitesse
		if i in [390, 400, 410, 560, 570, 580, 620]:
			doublure.tir_demande.emit(null, Vector2.ZERO, Vector2.DOWN)
		if i == 450:
			doublure.touchee.emit(Vector2.ZERO)
		if t < 3.0:
			camera.position = Vector3(2.7,2.1,5)
			legende.text = "Repos → course · matières et mouvements secondaires"
		elif t < 5.5:
			camera.position = Vector3(5,1.3,0)
			legende.text = "Profil · appuis, genoux et tenue du bâton"
		elif t < 8.5:
			camera.position = Vector3(0,1.3,5)
			legende.text = "Course + tirs + impact · jambes continues"
		else:
			camera.position = Vector3(2.7,2.1,5)
			legende.text = "Arrêt et rafales · fondus du haut du corps"
		camera.look_at(Vector3(0,.90,0))
		if main:
			camera.size = .85
			camera.position = Vector3(-3,1.8,3)
			camera.look_at(Vector3(-.28,.92,.12))
		proxy.mettre_a_jour(1.0/60.0)
		if (poses or main) and i%30 != 0:
			continue
		await process_frame
		RenderingServer.force_draw(false, 1.0/60.0)
		root.get_texture().get_image().save_png(dossier+"/%04d.png" % i)
		if i%120 == 0:
			print("APERCU_IMAGE : ",i)
	print("APERCU_HEROS : modele et controleur du combat, echantillonnage 60 fps")
	scene.queue_free()
	doublure.queue_free()
	await process_frame
	quit()
