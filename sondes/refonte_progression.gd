extends SceneTree

class Cible extends Node2D:
	var recu := 0.0
	func recevoir_degats(montant: float, _effets: Array) -> void:
		recu += montant

func _initialize() -> void:
	call_deferred("verifier")

func verifier() -> void:
	var v := Verif.new()
	var r := root.get_node("ReglagesJoueur")
	r.sauvegarde_active = false
	r.mode_dev = false
	r.rangs_competences.clear()
	r.tutoriel_vu = false
	r.objets.clear()
	r.rangs_sorts.clear()
	r.meilleures_par_chapitre = {"0":20,"1":20}
	var projectile: Area2D = load("res://scenes/projectile.tscn").instantiate()
	projectile.tir = CatalogueProjectiles.appliquer("lourd", Tir.de_base(Stats.depuis_reglages()))
	root.add_child(projectile)
	projectile.set_physics_process(false)
	for i in 3:
		var cible := Cible.new()
		root.add_child(cible)
		projectile._sur_contact(cible)
		v.presque(cible.recu, projectile.tir.degats, "cuivre : pleine puissance sur cible %d" % (i+1))
		cible.queue_free()
	await process_frame
	var conseil: Control = load("res://ui/conseils_debut.gd").new()
	root.add_child(conseil)
	v.vrai(not paused, "le tutoriel ne met pas en pause")
	v.egal(conseil.mouse_filter, Control.MOUSE_FILTER_IGNORE, "le tutoriel laisse passer les gestes")
	conseil._fermer()
	v.vrai(r.tutoriel_vu, "la fermeture memorise la lecture")
	await process_frame
	for format in [Vector2i(540,960),Vector2i(540,1320),Vector2i(960,540)]:
		root.size = format
		var page: Control = load("res://ui/apercu_butin.gd").new()
		root.add_child(page)
		await process_frame
		await process_frame
		var carte: Button = page.find_child("Carte_plume_encres",true,false)
		v.vrai(carte != null and carte.icon != null, "bijou illustre dans l'apercu")
		v.vrai(carte.text.contains("100.0") or carte.text.contains("100,0"), "premier objet garanti dans l'apercu")
		carte.pressed.emit()
		await process_frame
		v.vrai(is_instance_valid(page.get("_detail")), "le toucher ouvre la fiche")
		page.get("_detail").emit_signal("ferme")
		await process_frame
		page._ouvrir_detail("onde_alchimique", "sort")
		await process_frame
		v.vrai(is_instance_valid(page.get("_detail")), "fiche de sort illustree")
		page.queue_free()
		await process_frame
		var equipement: Control = load("res://ui/equipement.tscn").instantiate()
		root.add_child(equipement)
		await process_frame
		await process_frame
		var grille: GridContainer = equipement.get("_armes").get_child(1)
		v.egal(grille.get_child_count(),10,"dix armes accessibles dans la grille")
		v.egal(grille.columns,2,"grille adaptee au portrait")
		v.vrai(grille.size.x <= root.get_visible_rect().size.x,"grille sans debordement horizontal")
		equipement.queue_free()
		await process_frame
	var selection: Control = load("res://ui/selection_grimoire.tscn").instantiate()
	selection.selection_seulement = true
	root.add_child(selection)
	await process_frame
	selection._choisir_chapitre(2)
	v.vrai(selection.get("_lancement"), "un toucher de chapitre lance la transition meme depuis le menu")
	v.egal(r.chapitre_choisi,2,"le chapitre touche est celui lance")
	selection._choisir_chapitre(0)
	v.egal(r.chapitre_choisi,2,"un double toucher ne change pas le lancement")
	selection.queue_free()
	await process_frame
	print("Refonte : %d controles, %d echecs" % [v.total,v.echecs.size()])
	for echec in v.echecs: print("ECHEC "+echec)
	quit(0 if v.echecs.is_empty() else 1)
