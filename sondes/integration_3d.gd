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
	heros.set_process(false)
	heros.set_physics_process(false)
	salle.set_process(false)
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
	for point in [Vector2(450,950),Vector2(750,1250),Vector2(400,1190)]:
		salle.tirer(heros.tir_courant,point,Vector2.DOWN,true)
	await process_frame
	await process_frame
	for enfant in salle.get_children():
		if enfant is Area2D:
			enfant.set_physics_process(false)
	var proxies: Dictionary = monde.get("_proxies")
	# process_frame precede la synchronisation des proxies de la frame courante.
	await RenderingServer.frame_post_draw
	exiger(proxies.size()==8,"heros, trois ennemis et quatre projectiles representes (%d proxies)" % proxies.size())
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
	exiger(proxy_heros.modele.scene_file_path == Visuels3D.HEROS_MODELE,"modele B utilise dans le combat")
	if squelette != null:
		exiger(squelette.get_bone_count() == 20,"squelette B complet avec pointe du chapeau")
		exiger(proxy_heros.find_child("Baton_heros_B",true,false) != null,"baton exporte dans le modele")
		exiger(proxy_heros.find_child("Main_prise_heros_B",true,false) != null,"gant ferme exporte avec le baton")
		for nom: String in ["repos","course","attaque","touche","mort","victoire"]:
			exiger(lecteur.has_animation(nom),"clip B importe : "+nom)
		monde.set_process(false)
		var animation: AnimationTree = proxy_heros.get("animation_heros")
		var os := squelette.find_bone("cuisse_gauche")
		heros.velocity = Vector2.DOWN * Reglages.HEROS_VITESSE
		proxy_heros.mettre_a_jour(0.0)
		exiger(is_equal_approx(animation.cadence,Visuels3D.HEROS_CADENCE_COURSE),"cadence de la course B")
		var avant := squelette.get_bone_pose_rotation(os)
		proxy_heros.mettre_a_jour(.20)
		exiger(not avant.is_equal_approx(squelette.get_bone_pose_rotation(os)),"course articulee effective")
		var temps_course: float = animation.get("parameters/course/current_position")
		proxy_heros.call("_jouer_tir",null,Vector2.ZERO,Vector2.UP)
		proxy_heros.mettre_a_jour(.02)
		exiger(float(animation.get("parameters/course/current_position")) > temps_course,"rafale mobile sans redemarrage du cycle")
		exiger(bool(animation.get("parameters/tir/active")),"geste de tir superpose a la course")
		animation.toucher()
		proxy_heros.mettre_a_jour(.02)
		exiger(float(animation.get("parameters/course/current_position")) > temps_course+.02,"impact sans interruption des jambes")
		for i in 60:
			proxy_heros.mettre_a_jour(1.0/60.0)
		heros.velocity = Vector2.ZERO
		for i in 30:
			proxy_heros.mettre_a_jour(1.0/60.0)
		proxy_heros.call("_jouer_tir",null,Vector2.ZERO,Vector2.DOWN)
		var bras := squelette.find_bone("bras_droite")
		var avant_tir := squelette.get_bone_pose_rotation(bras)
		var main_droite := squelette.find_bone("main_droite")
		var main_avant := squelette.get_bone_global_pose(main_droite).origin
		for i in 10:
			proxy_heros.mettre_a_jour(1.0/60.0)
		exiger(not avant_tir.is_equal_approx(squelette.get_bone_pose_rotation(bras)),"le bras participe au tir")
		exiger(squelette.get_bone_global_pose(main_droite).origin.distance_to(main_avant)>0.06,"la main accompagne le geste de lancement")
		proxy_heros.call("_jouer_tir",null,Vector2.ZERO,Vector2.DOWN)
		exiger(float(animation.get("parameters/attaque/current_position")) >= 0.15,"les tirs rapproches preservent le geste en cours")
		monde.set_process(true)
	var suivi: Node = proxy_heros.get("suivi")
	heros.set_physics_process(true)
	suivi.set("_precedente", heros.position-Vector2(8,0))
	suivi.set("_courante", heros.position)
	run.call("_suivre_heros")
	monde.call("_process",0.0)
	var position_affichee: Vector2 = suivi.position_affichee()
	exiger(monde.camera.unproject_position(proxy_heros.position).distance_to(root.canvas_transform*position_affichee)<0.1,"camera et modele synchronises entre deux pas de physique")
	var camera_2d: Camera2D = run.get("_camera")
	exiger(camera_2d.physics_interpolation_mode == Node.PHYSICS_INTERPOLATION_MODE_OFF,"absence de double interpolation de la camera")
	heros.set_physics_process(false)
	await create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tmp/atelier-validation.png")
	proxy_heros.set("_orientation",Vector2.RIGHT)
	proxy_heros.call("mettre_a_jour",0.0)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tmp/mage-profil-en-jeu.png")
	proxy_heros.set("_orientation",Vector2.DOWN)
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
