extends SceneTree

func _initialize() -> void:
	call_deferred("verifier")

func verifier() -> void:
	var r := root.get_node("ReglagesJoueur")
	r.sauvegarde_active = false
	r.mode_dev = false
	r.rangs_competences.clear()
	r.passifs_equipes.clear()
	r.objets.assign(["plume_encres","robe_enluminee","sceau_scribe"])
	r.equipements = {"anneau_gauche":"plume_encres","anneau_droit":"robe_enluminee","collier":"sceau_scribe"}
	r.forge_niveaux = {"plume_encres":30,"robe_enluminee":20,"sceau_scribe":30}
	var v := Verif.new()
	var run: Node = load("res://scenes/run.tscn").instantiate()
	root.add_child(run)
	current_scene = run
	await physics_frame
	await process_frame
	run.set_process(false)
	var heros: CharacterBody2D = run.get("_heros")
	heros.set_process(false)
	heros.set_physics_process(false)
	var tir: Tir = heros.tir_courant
	v.egal(tir.rebonds,0,"pas d'ancien pouvoir de niveau 10")
	v.egal(tir.fragments,0,"pas d'ancien pouvoir de niveau 20")
	v.presque(tir.cadence,Reglages.HEROS_CADENCE,"aucune cadence via les bijoux en combat")
	run._avancer_phenomenes(0.1)
	v.vrai(is_instance_valid(run.get("_gardien")),"le collier cree le gardien reel")
	v.vrai(float(run.get("_familier_minuterie"))>0.0,"le familier tireur du niveau 30 est actif")
	var jeu := root.get_node("Jeu")
	v.egal(jeu.inventaire.size(),0,"les pouvoirs ne consomment aucun choix de run")
	run.queue_free()
	await process_frame
	await process_frame
	current_scene = null
	var page: Control = load("res://ui/equipement.tscn").instantiate()
	root.add_child(page)
	page._selectionner_slot("anneau_gauche")
	await process_frame
	var effets: Label = page.get("_effets_objet")
	for seuil in [10]:
		v.vrai(effets.text.contains("Niv. %d" % seuil),"palier visible dans la fiche")
	v.vrai(not effets.text.contains("Verrouillé"),"pouvoir unique acquis au maximum")
	for format in [Vector2i(540,960),Vector2i(540,1320),Vector2i(960,540)]:
		root.size = format
		await process_frame
		await process_frame
		for bouton: Button in page.get("_actions"):
			v.vrai(bouton.get_global_rect().end.y <= root.get_visible_rect().end.y+1.0,"actions accessibles avec une longue fiche")
	page.queue_free()
	await process_frame
	print("Bijoux en combat et interface : %d controles, %d echecs" % [v.total,v.echecs.size()])
	for echec in v.echecs: print("ECHEC "+echec)
	quit(0 if v.echecs.is_empty() else 1)
