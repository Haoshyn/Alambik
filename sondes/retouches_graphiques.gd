extends SceneTree

var echecs := 0
var controles := 0

func _initialize() -> void:
	call_deferred("verifier")

func exiger(condition: bool, message: String) -> void:
	controles += 1
	if not condition:
		echecs += 1
		push_error(message)

func capturer(nom: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tmp/retouches-"+nom+".png")

func verifier() -> void:
	var style: GDScript = load("res://scripts/presentation/style_azur.gd")
	var regles := root.get_node("ReglagesJoueur")
	regles.sauvegarde_active = false
	regles.mode_dev = false
	regles.objets.clear()
	regles.equipements = {"anneau_gauche":"","anneau_droit":"","collier":""}
	var equipement: Control = load("res://ui/equipement.tscn").instantiate()
	root.add_child(equipement)
	await process_frame
	for bouton: Button in equipement.get("_boutons_slots"):
		exiger(bouton.icon == null,"aucun bijou illustre dans un emplacement vide")
	for bouton: Button in equipement.get("_boutons_objets"):
		exiger(not bouton.visible,"collection vide sans item fictif")
	equipement.queue_free()
	await process_frame
	var scene := Node3D.new()
	root.add_child(scene)
	var camera := Camera3D.new()
	scene.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.75
	camera.position = Vector3(2.3,2.0,4.6)
	camera.look_at(Vector3(0,0.92,0))
	var environnement := WorldEnvironment.new()
	environnement.environment = Environment.new()
	environnement.environment.background_mode = Environment.BG_COLOR
	environnement.environment.background_color = Color("123542")
	environnement.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environnement.environment.ambient_light_color = Color("b4d4e5")
	environnement.environment.ambient_light_energy = 0.55
	scene.add_child(environnement)
	var lumiere := DirectionalLight3D.new()
	lumiere.rotation_degrees = Vector3(-40,-32,0)
	lumiere.light_color = Color("ffe4bc")
	lumiere.light_energy = 1.0
	lumiere.shadow_enabled = true
	scene.add_child(lumiere)
	var sol := MeshInstance3D.new()
	var plan := CylinderMesh.new()
	plan.top_radius = 0.9
	plan.bottom_radius = 0.94
	plan.height = 0.10
	sol.mesh = plan
	sol.position.y = -0.05
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("4d747e")
	mat.roughness = 0.85
	sol.material_override = mat
	scene.add_child(sol)
	var heros: Node3D = load("res://assets/3d/characters/heros.glb").instantiate()
	scene.add_child(heros)
	var lecteur := heros.find_child("AnimationPlayer",true,false) as AnimationPlayer
	exiger(lecteur != null and lecteur.has_animation("course"),"mage articule disponible")
	if lecteur != null:
		lecteur.play("repos")
		lecteur.seek(0.2,true)
	await capturer("heros")
	if lecteur != null:
		lecteur.play("attaque")
		lecteur.seek(0.16,true)
		lecteur.pause()
		await capturer("heros-attaque")
		lecteur.play("repos")
		lecteur.seek(0.2,true)
		lecteur.pause()
		heros.rotation.y = PI
		await capturer("heros-dos")
	heros.queue_free()
	await process_frame
	var portail: Node3D = load("res://assets/3d/environment/portail.glb").instantiate()
	portail.set_script(load("res://scripts/presentation/portail_3d.gd"))
	scene.add_child(portail)
	await create_timer(0.6).timeout
	await capturer("portail")
	regles.effets_reduits = true
	await process_frame
	await process_frame
	var eclats: MultiMesh = portail.get("_eclats")
	exiger(eclats.visible_instance_count == 4,"portail allege en effets reduits")
	scene.queue_free()
	await process_frame
	var voile := Control.new()
	voile.set_script(load("res://scripts/voile_transition.gd"))
	root.add_child(voile)
	var titre: Label = style.texte("SALLE 04",54)
	titre.set_anchors_preset(Control.PRESET_CENTER)
	titre.position = Vector2(-260,-62)
	titre.size = Vector2(520,76)
	titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	voile.add_child(titre)
	var sous_titre: Label = style.texte("LES JARDINS D'AZUR",24,Color("bc9258"))
	sous_titre.set_anchors_preset(Control.PRESET_CENTER)
	sous_titre.position = Vector2(-300,18)
	sous_titre.size = Vector2(600,48)
	sous_titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	voile.add_child(sous_titre)
	await capturer("transition")
	voile.queue_free()
	await process_frame
	print("RETOUCHES_GRAPHIQUES : %d controles, %d echecs" % [controles,echecs])
	quit(1 if echecs else 0)
