extends SceneTree

var echecs := 0
var run: Node
var monde: Node3D

func _initialize() -> void:
	call_deferred("verifier")

func exiger(condition: bool, texte: String) -> void:
	if not condition:
		push_error(texte)
		echecs += 1

func verifier() -> void:
	root.get_node("ReglagesJoueur").sauvegarde_active = false
	run = load("res://scenes/run.tscn").instantiate()
	root.add_child(run)
	current_scene = run
	await process_frame
	monde = run.get_node_or_null("Monde3D")
	if monde == null:
		push_error("La sonde d'integration exige un rendu graphique")
		quit(1)
		return
	var salle: Node2D = run.get("_salle")
	var heros: CharacterBody2D = run.get("_heros")
	for enfant in run.get_children():
		if enfant.get_script() != null and enfant.get_script().resource_path == "res://sondes/bot.gd":
			enfant.queue_free()
	# Pose deterministe lisible ; les objets restent les vraies scenes de combat.
	for enfant in salle.get_children():
		if enfant.is_in_group("ennemis") or enfant is Area2D:
			enfant.queue_free()
	await process_frame
	heros.position = Vector2(540,1270)
	heros.set_process(false)
	heros.set_physics_process(false)
	heros.set("_visee",Vector2(0.5,1).normalized())
	salle.set_process(false)
	var places := [Vector2(300,700),Vector2(700,850),Vector2(320,1040)]
	var noms := ["encrier_rampant","plume_sentinelle","tache_veloce"]
	for i in noms.size():
		salle.faire_apparaitre(noms[i],places[i])
	for ennemi in get_nodes_in_group("ennemis"):
		ennemi.set("_apparition",1.0)
		ennemi.set_physics_process(false)
	salle.tirer(heros.tir_courant,Vector2(500,1050),Vector2.UP)
	await process_frame
	await process_frame
	for enfant in salle.get_children():
		if enfant is Area2D:
			enfant.set_physics_process(false)
	var proxies: Dictionary = monde.get("_proxies")
	exiger(proxies.size()==5,"heros, trois ennemis et projectile representes")
	for proxy in proxies.values():
		var logique: Node2D = proxy.get("logique")
		exiger(logique.visible,"le rendu ne doit pas masquer une cible logique")
		var projete: Vector2 = monde.camera.unproject_position(proxy.position)
		var attendu: Vector2 = root.canvas_transform*logique.global_position
		exiger(projete.distance_to(attendu)<0.1,"ancrage reel du proxy sur sa collision")
	# Les animations exportees doivent modifier le squelette, pas seulement exister.
	var proxy_heros: Node3D = proxies[heros.get_instance_id()]
	var squelette := proxy_heros.find_child("Skeleton3D",true,false) as Skeleton3D
	var lecteur: AnimationPlayer = proxy_heros.get("lecteur")
	exiger(squelette!=null,"squelette du heros exporte")
	if squelette != null:
		var os := squelette.find_bone("jambe_gauche")
		lecteur.play("course")
		lecteur.seek(0.0,true)
		var avant := squelette.get_bone_pose_rotation(os)
		lecteur.seek(0.20,true)
		exiger(not avant.is_equal_approx(squelette.get_bone_pose_rotation(os)),"course articulee effective")
		lecteur.play("repos")
	await create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tmp/atelier-validation.png")
	print("RENDU_3D draws=%d primitives=%d" % [Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)])
	# Nettoyer une salle ne doit conserver aucun ennemi ni projectile fantome.
	for enfant in salle.get_children():
		if enfant.is_in_group("ennemis") or enfant is Area2D:
			enfant.queue_free()
	await process_frame
	await process_frame
	exiger(proxies.size()==1,"nettoyage des proxies apres suppression des entites")
	salle.call("_ouvrir_portail")
	await process_frame
	await process_frame
	var portail: Node3D = monde.get("_portail")
	exiger(is_instance_valid(portail) and portail.visible,"portail 3D apres nettoyage")
	var regles: Node = root.get_node("ReglagesJoueur")
	regles.effets_reduits = true
	await process_frame
	exiger(not monde.get("_lumiere").shadow_enabled,"profil reduit sans ombres")
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tmp/atelier-portail-reduit.png")
	print("INTEGRATION_3D : %d echecs" % echecs)
	run.queue_free()
	await process_frame
	quit(1 if echecs else 0)
