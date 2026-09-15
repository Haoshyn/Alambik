extends SceneTree

func _initialize() -> void:
	call_deferred("demarrer")

func demarrer() -> void:
	var repetitions := 2
	var graine := 1
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--repetitions="): repetitions = int(argument.get_slice("=",1))
		if argument.begins_with("--graine="): graine = int(argument.get_slice("=",1))
	var profil := preload("res://sondes/economie_monde_trois.gd").simuler(repetitions,graine)
	var r := root.get_node("ReglagesJoueur")
	r.sauvegarde_active = false
	r.reinitialiser_progression()
	r.mode_dev = false
	r.rangs_competences = profil["rangs"]
	r.objets.assign(profil["objets"])
	r.equipements = profil["equipements"]
	r.rangs_sorts = profil["sorts"]
	r.sort_actif_equipe = "onde_alchimique"
	r.ultime_equipe = "grand_oeuvre"
	for chapitre in 6: r.meilleures_par_chapitre[str(chapitre)] = 20
	r.projectile_equipe = "lourd"
	print("Parcours economique : "+JSON.stringify(profil))
	change_scene_to_file("res://scenes/run.tscn")
