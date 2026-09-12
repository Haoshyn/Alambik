extends SceneTree

class Cible extends Node2D:
	var pv := 1000.0
	var effets_recus: Array = []
	func recevoir_degats(montant: float, effets: Array = []) -> void:
		pv -= montant
		effets_recus.append_array(effets)

func _initialize() -> void:
	call_deferred("verifier")

func verifier() -> void:
	root.get_node("ReglagesJoueur").sauvegarde_active = false
	var v := Verif.new()
	var jeu: Node = root.get_node("Jeu")
	var run: Node = load("res://scenes/run.tscn").instantiate()
	root.add_child(run)
	current_scene = run
	await process_frame
	run.set_process(false)
	var heros: CharacterBody2D = run.get("_heros")
	var salle: Node2D = run.get("_salle")
	var atelier: Node = get_first_node_in_group("atelier_fusions")
	atelier.set_process(false)
	heros.set_process(false)
	heros.set_physics_process(false)
	heros.stats = Stats.depuis_reglages()
	heros.position = Vector2(500,1100)
	salle.set_process(false)
	salle.set("_obstacles",[] as Array[Rect2])
	for enfant in salle.get_children():
		if enfant is PhysicsBody2D or enfant is Area2D: enfant.queue_free()
	await process_frame
	var cibles: Array[Cible] = []
	for i in 3:
		var cible := Cible.new()
		root.add_child(cible)
		cible.add_to_group("ennemis")
		cible.position = Vector2(500+i*40,950)
		cibles.append(cible)
	atelier.salle_connue = jeu.salle_courante
	for recette in CatalogueRecettes.TOUS:
		atelier.reinitialiser()
		atelier.actives = {recette:true}
		heros.velocity = Vector2.ZERO
		for i in cibles.size():
			cibles[i].pv = 1000.0
			cibles[i].effets_recus.clear()
			cibles[i].position = Vector2(500+i*40,950)
		var avant := salle.get_child_count()
		match recette:
			"braises":
				for i in 3: atelier.impact(cibles[0])
				atelier._process(0.8)
				v.vrai(cibles[0].pv < 1000.0 and cibles[1].pv < 1000.0,"braises : explosion differee de zone")
			"perles":
				for i in 4: atelier.impact(cibles[0])
				v.vrai("eau" in cibles[0].effets_recus,"perles : l'impact applique Mouille")
			"retour":
				for i in 3: atelier.lancer(heros.position,Vector2.UP)
				v.egal(salle.get_child_count()-avant,2,"retour : deux vrais projectiles secondaires")
			"rosee":
				heros.velocity = Vector2.RIGHT*200
				for i in 4: atelier._process(0.75)
				v.egal(atelier.perles,3,"rosee : charge plafonnee")
				atelier.lancer(heros.position,Vector2.UP)
				v.egal(atelier.perles,0,"rosee : charge consommee par le lancer")
				v.egal(salle.get_child_count()-avant,3,"rosee : trois vrais projectiles")
			"secours":
				var position_avant := cibles[0].position
				atelier.protection(heros.position)
				v.vrai(cibles[0].position != position_avant,"secours : repousse les ennemis")
				var pv := cibles[0].pv
				atelier.protection(heros.position)
				v.presque(cibles[0].pv,pv,"secours : recharge respectee")
			"fournaise":
				for i in 4: atelier.lancer(heros.position,Vector2.UP)
				v.vrai(cibles[0].pv < 1000.0,"fournaise : quatre lancers font eclore la flamme")
			"failles":
				atelier._process(0.01)
				v.egal(atelier.attentes.size(),1,"faille : delai visible avant les degats")
				atelier._process(0.8)
				v.vrai(cibles[0].pv < 1000.0,"faille : explosion executee")
			"constellation":
				atelier._process(0.01)
				for cible in cibles:
					v.presque(cible.pv,995.0,"constellation : chaque cible frappee une seule fois")
			"distillation":
				atelier._process(0.01)
				v.egal(atelier.marques.size(),3,"distillation : amorce les cibles proches")
			"reserve":
				heros.stats.pv = 50.0
				for i in 4: atelier.elimination(1)
				v.presque(heros.stats.pv,53.0,"reserve : soigne un heros blesse")
				heros.stats.pv = heros.stats.pv_max
				for i in 4: atelier.elimination(1)
				v.egal(atelier.reserve,1,"reserve : convertit le soin inutile")
				atelier.lancer(heros.position,Vector2.UP)
				v.egal(atelier.reserve,0,"reserve : depensee au lancer")
		print("RECETTE TESTEE : ",recette)
		for enfant in salle.get_children():
			if enfant is Area2D: enfant.queue_free()
		await process_frame
	atelier.reinitialiser()
	atelier.actives = {}
	for cible in cibles: cible.pv = 1000.0
	atelier.marquer(cibles[0],"feu")
	atelier.marquer(cibles[0],"eau")
	v.presque(cibles[0].pv,987.5,"vapeur : reaction entre deux elements")
	atelier.marquer(cibles[0],"feu")
	atelier.marquer(cibles[0],"eau")
	v.presque(cibles[0].pv,987.5,"vapeur : pas de boucle de reaction au meme instant")
	atelier.reinitialiser()
	for cible in cibles: cible.pv = 1000.0
	atelier.marquer(cibles[0],"eau")
	atelier.marquer(cibles[0],"feu")
	v.presque(cibles[0].pv,987.5,"la reaction fonctionne aussi eau puis feu")
	atelier.reinitialiser()
	atelier.marquer(cibles[0],"feu")
	cibles[0].pv = 0.0
	var pv_voisin := cibles[1].pv
	atelier._process(0.01)
	v.vrai(cibles[1].pv < pv_voisin,"une cible amorcee qui meurt libere sa braise")
	atelier.reinitialiser()
	v.vrai(atelier.marques.is_empty() and atelier.attentes.is_empty(),"aucune reaction ne deborde dans la salle suivante")
	for cible in cibles: cible.free()
	jeu.inventaire = ["ricochet","egide","meteores","sceau_furie"] as Array[String]
	var id := CatalogueRecettes.id_fusion("braises","ricochet")
	v.vrai(jeu.ajouter_recette(id),"acquisition valide")
	v.vrai(not jeu.ajouter_recette(id),"double acquisition refusee")
	v.vrai(atelier.actives.has("braises"),"acquisition reliee au vrai module de combat")
	var cible_reelle := Cible.new()
	root.add_child(cible_reelle)
	cible_reelle.add_to_group("ennemis")
	cible_reelle.position = Vector2(500,900)
	for i in 3:
		var projectile: Area2D = load("res://scenes/projectile.tscn").instantiate()
		projectile.tir = Tir.de_base(heros.stats)
		salle.add_child(projectile)
		projectile.global_position = cible_reelle.global_position
		projectile._sur_contact(cible_reelle)
	atelier._process(0.8)
	v.vrai(cible_reelle.pv < 970.0,"les impacts du vrai projectile declenchent la fusion")
	cible_reelle.free()
	atelier.set_process(true)
	paused = true
	var temps_avant: float = atelier.temps
	for i in 5: await process_frame
	v.presque(atelier.temps,temps_avant,"les reactions attendent pendant un choix en pause")
	paused = false
	atelier.set_process(false)
	v.vrai(jeu.reactif(id) != null,"fusion visible dans l'inventaire")
	v.vrai(not jeu.ajouter_recette(CatalogueRecettes.id_fusion("rosee","regeneration")),"support non possede refuse")
	if "--capture" in OS.get_cmdline_user_args():
		paused = true
		var panneau: Control = load("res://ui/alambic.tscn").instantiate()
		panneau.process_mode = Node.PROCESS_MODE_ALWAYS
		run.get("_couche").add_child(panneau)
		for i in 30: await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tmp/alambic-recettes.png")
		panneau._sur_choix(panneau._propositions[0])
		panneau._sur_fusionner()
		for i in 90: await process_frame
		v.vrai(jeu.inventaire.size() == 6,"selection tactile du panneau cree une seule recette")
		paused = false
	print("FUSIONS_EXPERIMENTALES : %d assertions, %d echecs" % [v.total,v.echecs.size()])
	for echec in v.echecs: push_error(echec)
	run.queue_free()
	await process_frame
	quit(1 if not v.echecs.is_empty() else 0)
