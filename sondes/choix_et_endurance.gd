extends SceneTree

class CibleSoin extends Node2D:
	func recevoir_degats(_montant: float, _effets: Array = []) -> void:
		pass

func _initialize() -> void:
	call_deferred("verifier")

func verifier() -> void:
	root.get_node("ReglagesJoueur").sauvegarde_active = false
	var v := Verif.new()
	var run: Node = load("res://scenes/run.tscn").instantiate()
	root.add_child(run)
	current_scene = run
	await process_frame
	run.set_process(false)
	var salle: Node2D = run.get("_salle")
	var heros: CharacterBody2D = run.get("_heros")
	var joystick: Control = run.get("_joystick")
	salle.set_process(false)
	for enfant in salle.get_children():
		if enfant is PhysicsBody2D or enfant is Area2D:
			enfant.queue_free()
	salle.set("_obstacles", [] as Array[Rect2])
	await process_frame
	var origine := root.get_visible_rect().size * Vector2(0.25, 0.7)
	var appui := InputEventScreenTouch.new()
	appui.index = 0
	appui.position = origine
	appui.pressed = true
	var glisse := InputEventScreenDrag.new()
	glisse.index = 0
	glisse.position = origine + Vector2(100, 0)
	joystick.call("_input", appui)
	joystick.call("_input", glisse)
	v.egal(heros.get("_intention"), Vector2.RIGHT, "deplacement avant le choix")
	heros.velocity = Vector2(200, 0)
	run.set("_niveaux_en_attente", 1)
	run.call("_ouvrir_recompense_etage")
	v.vrai(paused, "le choix met le combat en pause")
	v.egal(heros.get("_intention"), Vector2.ZERO, "le choix annule l'intention")
	v.egal(heros.velocity, Vector2.ZERO, "le choix annule l'inertie")
	v.egal(joystick.get("_doigt"), -1, "le doigt ancien est oublie")
	# Le relachement arrive pendant que le joystick ne traite plus les entrees.
	appui.pressed = false
	root.push_input(appui)
	var panneau: Control = run.get("_panneau")
	panneau.call("_sur_choix", panneau.get("_propositions")[0])
	for i in 60: await process_frame
	v.vrai(not paused and run.get("_panneau") == null, "le choix ferme le panneau et reprend la partie")
	var position_apres := heros.position
	for i in 30: await physics_frame
	v.presque(heros.position.distance_to(position_apres), 0.0, "aucun deplacement fantome apres le choix")
	appui.pressed = true
	joystick.call("_input", appui)
	joystick.call("_input", glisse)
	v.egal(heros.get("_intention"), Vector2.RIGHT, "un nouvel appui fonctionne")
	joystick.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	v.egal(heros.get("_intention"), Vector2.ZERO, "perdre le focus libere les commandes")
	run.call("_neutraliser_deplacement")
	heros.stats = Stats.depuis_reglages()
	heros.tir_courant = Tir.de_base(heros.stats)
	heros.tir_courant.drapeaux.append("elan_vital")
	heros.set("_a_bouge_dans_la_salle", false)
	heros.set("_temps_immobile", 0.0)
	v.presque(heros.multiplicateur_degats_passif(), 1.0, "Elan vital exige un deplacement reel")
	heros.set("_a_bouge_dans_la_salle", true)
	v.presque(heros.multiplicateur_degats_passif(), Reglages.ELAN_VITAL_DEGATS_MULT, "Elan vital recompense le deplacement")
	heros.stats.pv = 50.0
	var cibles: Array[Node2D] = []
	for i in 10:
		var cible := CibleSoin.new()
		root.add_child(cible)
		cible.add_to_group("ennemis")
		cible.position = heros.global_position
		cibles.append(cible)
	run.call("_pulser_sceaux", ["sceau_element_lumiere"] as Array[String])
	v.presque(heros.stats.pv, 50.0 + heros.stats.pv_max * Reglages.SCEAU_AURA_SOIN * Reglages.SCEAU_AURA_CIBLES_SOIN_MAX, "dix ennemis ne depassent pas le plafond de soin de l'aura")
	for cible in cibles: cible.free()
	heros.stats.pv = heros.stats.pv_max
	# Banc controle : vrais tirs, collisions et cadence ; cible fixe sans attaques.
	# Alternance 3 s d'arret / 0,6 s de mouvement, compte vierge sans sorts.
	for cas in [
		["la_rature",0,5,["sceau_furie"]],
		["copiste_aveugle",0,5,["sceau_furie"]],
		["archiscribe_encres",2,20,["tir_multiple","sceau_furie","sceau_celerite"]],
	]:
		var jeu: Node = root.get_node("Jeu")
		jeu.chapitre = cas[1]
		salle.numero = cas[2]
		heros.tir_courant = Mods.appliquer(Tir.de_base(heros.stats), Mods.depuis_l_inventaire(cas[3]))
		heros.position = Vector2(540, 1100)
		var boss: CharacterBody2D = load("res://scenes/boss.tscn").instantiate()
		boss.configurer(salle.call("_mis_a_l_echelle", CatalogueEnnemis.par_id(cas[0]), cas[0]))
		boss.limites = heros.limites
		salle.add_child(boss)
		boss.position = Vector2(540, 650)
		boss.set_physics_process(false)
		var pv: float = boss.pv
		var images := 0
		while is_instance_valid(boss) and images < 7200:
			var mobile := images % 216 >= 180
			heros.definir_intention(Vector2.RIGHT if mobile else Vector2.ZERO, 0.1 if mobile else 0.0)
			heros.position.x = 540.0
			await physics_frame
			images += 1
		var duree := float(images) / 60.0
		print("ENDURANCE %s : %.1f PV, %.2f s, build=%s" % [cas[0],pv,duree,str(cas[3])])
		v.vrai(duree >= 30.0 and duree <= 45.0, "endurance controlee 30-45 s : %s" % cas[0])
		if is_instance_valid(boss): boss.free()
		for enfant in salle.get_children():
			if enfant is Area2D: enfant.queue_free()
		await process_frame
	print("CHOIX_ET_ENDURANCE : %d assertions, %d echecs" % [v.total,v.echecs.size()])
	for echec in v.echecs: push_error(echec)
	run.queue_free()
	await process_frame
	quit(1 if not v.echecs.is_empty() else 0)
