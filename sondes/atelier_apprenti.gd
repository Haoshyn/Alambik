extends SceneTree

var modele: Node3D
var lecteur: AnimationPlayer
var camera: Camera3D
var angle := 0.35
var elevation := 0.22
var distance_vue := 2.35
var tourner := false
var temps := 0.0
var legende: Label
var controleur: AnimationTree
var vitesse := 0.0
var parcours := false
var capture_active := false

func _initialize() -> void:
	call_deferred("preparer")

func preparer() -> void:
	root.get_node("ReglagesJoueur").sauvegarde_active = false
	root.size = Vector2i(1000, 1000)
	root.content_scale_size = root.size
	root.title = "Alambik — Apprenti A · corps rond et lancer du bras"
	root.msaa_3d = Viewport.MSAA_4X
	var scene := Node3D.new()
	root.add_child(scene)
	modele = load("res://assets/3d/characters/apprenti_a.glb").instantiate()
	scene.add_child(modele)
	preload("res://scripts/presentation/materiaux_apprenti.gd").appliquer(modele)
	lecteur = modele.find_child("AnimationPlayer", true, false) as AnimationPlayer
	for nom: String in ["repos", "course", "victoire"]:
		lecteur.get_animation(nom).loop_mode = Animation.LOOP_LINEAR
	controleur = load("res://scripts/presentation/animation_heros_3d.gd").new()
	modele.add_child(controleur)
	controleur.preparer(lecteur)
	var environnement := WorldEnvironment.new()
	environnement.environment = Environment.new()
	environnement.environment.background_mode = Environment.BG_COLOR
	environnement.environment.background_color = Color("e6ded0")
	environnement.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environnement.environment.ambient_light_color = Color("dce8f3")
	environnement.environment.ambient_light_energy = .3
	scene.add_child(environnement)
	var lumiere := DirectionalLight3D.new()
	lumiere.rotation_degrees = Vector3(-45, -35, 0)
	lumiere.light_color = Color("ffe6cf")
	lumiere.light_energy = .45
	lumiere.shadow_enabled = true
	lumiere.directional_shadow_max_distance = 12.0
	scene.add_child(lumiere)
	var appoint := DirectionalLight3D.new()
	appoint.rotation_degrees = Vector3(-25, 140, 0)
	appoint.light_energy = .12
	appoint.light_color = Color("b9dfe9")
	scene.add_child(appoint)
	var sol := MeshInstance3D.new()
	var plan := PlaneMesh.new()
	plan.size = Vector2(200, 200)
	sol.mesh = plan
	sol.position.y = -.01
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("dfd6c6")
	mat.roughness = 1.0
	sol.material_override = mat
	scene.add_child(sol)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	scene.add_child(camera)
	var interface := VBoxContainer.new()
	interface.position = Vector2(28, 22)
	root.add_child(interface)
	var titre := Label.new()
	titre.text = "ALAMBIK / L’APPRENTI A"
	titre.add_theme_color_override("font_color", Color("432948"))
	titre.add_theme_font_size_override("font_size", 26)
	interface.add_child(titre)
	legende = Label.new()
	legende.text = "Silhouette ronde vue du dessus · bras continus · mains retravaillées"
	legende.add_theme_color_override("font_color", Color("594d56"))
	interface.add_child(legende)
	var boutons := HBoxContainer.new()
	interface.add_child(boutons)
	for nom: String in ["repos", "course", "attaque", "touche", "victoire"]:
		var bouton := Button.new()
		bouton.text = nom.capitalize()
		bouton.pressed.connect(func():
			controleur.active = nom != "victoire"
			if nom == "course": vitesse = Reglages.HEROS_VITESSE
			elif nom == "repos": vitesse = 0.0
			elif nom == "attaque": controleur.tirer()
			elif nom == "touche": controleur.toucher()
			else: lecteur.play(nom, .15))
		boutons.add_child(bouton)
	var vues := HBoxContainer.new()
	interface.add_child(vues)
	for nom: String in ["Face", "Profil", "Dos", "Dessus", "Caméra jeu", "Tourner", "Parcours"]:
		var bouton := Button.new()
		bouton.text = nom
		bouton.pressed.connect(func():
			if nom == "Parcours":
				parcours = not parcours
				vitesse = Reglages.HEROS_VITESSE if parcours else 0.0
				distance_vue = 3.6 if parcours else 2.35
				if not parcours:
					modele.position = Vector3.ZERO
					modele.rotation.y = 0.0
			elif nom == "Tourner": tourner = not tourner
			else:
				tourner = false
				angle = PI * .5 if nom == "Profil" else (PI + .35 if nom == "Dos" else .35)
				elevation = PI / 2.0 if nom == "Dessus" else (deg_to_rad(48.0) if nom == "Caméra jeu" else .22))
		vues.add_child(bouton)
	actualiser_camera()
	if "--capturer" in OS.get_cmdline_user_args():
		await capturer()

func _process(delta: float) -> bool:
	if capture_active:
		return false
	if is_instance_valid(camera):
		temps += delta
		if not capture_active and is_instance_valid(controleur) and controleur.active:
			controleur.mettre_a_jour(delta, vitesse, false)
			if parcours:
				modele.position = Vector3(.65 * sin(temps * 1.7), 0, .35 * sin(temps * 3.4))
				var direction := Vector3(1.105 * cos(temps * 1.7), 0, 1.19 * cos(temps * 3.4))
				modele.rotation.y = lerp_angle(modele.rotation.y, atan2(direction.x, direction.z), 1.0 - exp(-14.0 * delta))
		if tourner: angle += delta * .5
		actualiser_camera()
	return false

func actualiser_camera() -> void:
	camera.size = distance_vue
	camera.position = Vector3(sin(angle) * cos(elevation), sin(elevation), cos(angle) * cos(elevation)) * 5.0 + Vector3(0, .93, 0)
	camera.look_at(Vector3(0, .93, 0), Vector3.FORWARD if elevation > 1.56 else Vector3.UP)

func capturer() -> void:
	capture_active = true
	var dossier := "res://tmp/apprenti-a/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dossier))
	for vue: String in ["face", "dos", "profil", "jeu", "dessus"]:
		angle = PI + .35 if vue == "dos" else .35
		if vue == "profil": angle = PI / 2.0
		elevation = deg_to_rad(48.0) if vue == "jeu" else .22
		if vue == "dessus": elevation = PI / 2.0
		actualiser_camera()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(dossier + "godot-" + vue + ".png")
	angle = .95
	elevation = .22
	actualiser_camera()
	controleur.mettre_a_jour(0.0, Reglages.HEROS_VITESSE, false)
	for i in 48:
		controleur.mettre_a_jour(1.0 / 30.0, Reglages.HEROS_VITESSE, false)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(dossier + "course-%03d.png" % i)
	print("ATELIER_APPRENTI : 5 vues et 48 images de course capturees")
	if "--attaques" in OS.get_cmdline_user_args():
		for vue: String in ["prise", "attaque", "attaque-dessus"]:
			angle = -.65 if vue == "prise" else .65
			elevation = deg_to_rad(48.0) if vue == "attaque-dessus" else .20
			distance_vue = 2.35
			actualiser_camera()
			if vue == "prise":
				camera.size = .9
				camera.position = Vector3(2.0, 1.0, 2.5)
				camera.look_at(Vector3(.44, .45, .25))
			for i in 60:
				if i in [12, 36] and vue != "prise": controleur.tirer()
				controleur.mettre_a_jour(1.0 / 30.0, 0.0, false)
				await process_frame
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(dossier + "%s-%03d.png" % [vue, i])
		print("ATELIER_APPRENTI : prise et attaques dans deux vues capturees")
	if "--parcours" in OS.get_cmdline_user_args():
		distance_vue = 3.4
		elevation = deg_to_rad(40.0)
		angle = .0
		actualiser_camera()
		for i in 150:
			var t := float(i) / 30.0
			var actif := t >= .5 and t < 4.0
			controleur.mettre_a_jour(1.0 / 30.0, Reglages.HEROS_VITESSE if actif else 0.0, false)
			if actif:
				var phase := (t - .5) * 1.6
				modele.position = Vector3(.70 * sin(phase), 0, .36 * sin(phase * 2.0))
				var direction := Vector3(cos(phase), 0, 1.03 * cos(phase * 2.0))
				modele.rotation.y = lerp_angle(modele.rotation.y, atan2(direction.x, direction.z), 1.0 - exp(-14.0 / 30.0))
			if i in [72, 129]: controleur.tirer()
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(dossier + "parcours-%03d.png" % i)
		print("ATELIER_APPRENTI : parcours, virages, tirs et arret captures")
	quit()
