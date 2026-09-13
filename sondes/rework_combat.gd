extends SceneTree

func _initialize() -> void:
	call_deferred("verifier")

func verifier() -> void:
	var profil := root.get_node("ReglagesJoueur")
	profil.sauvegarde_active = false
	profil.mode_dev = true
	profil.passifs_equipes.clear()
	profil.rangs_competences.clear()
	profil.sort_actif_equipe = "onde_alchimique"
	profil.ultime_equipe = "grand_oeuvre"
	profil.rangs_sorts["onde_alchimique"] = 1
	profil.rangs_sorts["grand_oeuvre"] = 1
	root.size = Vector2i(608,1080)
	var v := Verif.new()
	var run: Node = load("res://scenes/run.tscn").instantiate()
	root.add_child(run)
	current_scene = run
	await create_timer(0.7).timeout
	var heros: CharacterBody2D = run.get("_heros")
	var salle: Node2D = run.get("_salle")
	salle.set_process(false)
	heros.set_process(false)
	heros.set_physics_process(false)
	for enfant in salle.get_children():
		if enfant is Area2D: enfant.queue_free()
	await process_frame
	var forme := heros.get_node("CollisionShape2D").shape as CircleShape2D
	v.presque(forme.radius, Reglages.HEROS_RAYON, "la collision suit le rayon compact")
	var sentinelle: CharacterBody2D = load("res://scenes/ennemi.tscn").instantiate()
	sentinelle.configurer(CatalogueEnnemis.par_id("plume_sentinelle"))
	salle.add_child(sentinelle)
	sentinelle.set_physics_process(false)
	sentinelle.position = heros.position + Vector2(0,-300)
	sentinelle.set("_cible", heros)
	sentinelle.set("_recharge", 0.0)
	sentinelle.call("_agir_sentinelle")
	var verrou: Vector2 = sentinelle.get("_point_vise")
	heros.position.x += 40
	v.egal(sentinelle.get("_point_vise"), verrou, "la visee annoncee ne suit plus le deplacement")
	v.presque(sentinelle.call("_distance_contact"), forme.radius + 28.0 * Reglages.ENNEMI_HITBOX_MULT, "le contact utilise les deux vrais rayons")
	sentinelle.queue_free()
	run.set("_delai_charge", 0.0)
	run.set("_recharge_sort_actif", 5.0)
	await create_timer(0.4).timeout
	v.presque(run.get("_recharge_sort_actif"), 5.0, "attendre ne recharge pas le sort")
	run.call("charger_sort")
	v.presque(run.get("_recharge_sort_actif"), 4.0, "un impact recharge le sort")
	run.call("charger_sort")
	v.presque(run.get("_recharge_sort_actif"), 4.0, "une salve simultanee ne remplit pas la jauge")
	run.set("_recharge_sort_actif", 0.0)
	run.call("_lancer_sort_actif")
	v.vrai(paused, "viser suspend la partie")
	var panneau: Control = run.get("_panneau")
	v.vrai(panneau != null, "le panneau de visee est construit")
	var positions := {}
	for ennemi in get_nodes_in_group("ennemis"):
		positions[ennemi] = ennemi.global_position
	await create_timer(0.3, true).timeout
	for ennemi in positions:
		v.egal(ennemi.global_position, positions[ennemi], "les ennemis restent immobiles pendant la visee")
	var point := heros.global_position + Vector2(0,-160)
	var ecran: Vector2 = run.call("_ecran_sort", point)
	print("VISEE aller=%s retour=%s ecart=%s" % [point, run.call("_point_sort", ecran), point.distance_to(run.call("_point_sort", ecran))])
	v.vrai(point.distance_to(run.call("_point_sort", ecran)) < 0.5, "la visee ecran et le terrain correspondent a moins d'un demi-pixel")
	if DisplayServer.get_name() != "headless":
		panneau.point = point
		panneau.queue_redraw()
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tmp/visee-rework.png")
	panneau.annule.emit()
	v.vrai(not paused, "annuler reprend le combat")
	v.presque(run.get("_recharge_sort_actif"), 0.0, "annuler ne consomme rien")
	run.call("_lancer_sort_actif")
	panneau = run.get("_panneau")
	panneau.confirme.emit(point)
	v.vrai(not paused, "confirmer reprend le combat")
	v.vrai(float(run.get("_recharge_sort_actif")) > 0.0, "le lancer consomme la charge")
	for utilisation in 5:
		run.set("_charge_ultime", 1000)
		run.call("_lancer_ultime")
	v.egal(run.get("_ultimes_utilises"), Reglages.ULTIMES_PAR_RUN, "quatre ultimes au maximum meme avec une reserve enorme")
	print("REWORK_COMBAT : %d assertions, %d echecs" % [v.total, v.echecs.size()])
	for echec in v.echecs: push_error(echec)
	run.queue_free()
	await process_frame
	quit(0 if v.echecs.is_empty() else 1)
