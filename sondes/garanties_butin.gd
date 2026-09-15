extends SceneTree

func _initialize() -> void:
	call_deferred("verifier")

func verifier() -> void:
	# Cette sonde exerce la vraie sauvegarde, uniquement dans le profil de test.
	if not OS.get_user_data_dir().replace("\\","/").contains("tmp/profil/"):
		push_error("Profil tmp/profil requis pour tester la persistance.")
		quit(1)
		return
	var r := root.get_node("ReglagesJoueur")
	var jeu := root.get_node("Jeu")
	r.sauvegarde_active = false
	r.reinitialiser_progression()
	var v := Verif.new()
	var fin: GDScript = load("res://scripts/bilan_run.gd")
	jeu.mode_run = "epreuve_sorts"
	jeu.niveau_epreuve = 1
	jeu.chapitre = 0
	jeu.salles_terminees.assign([1,2,3,4,5])
	jeu.boss_vaincus.assign([1,2,3,4,5])
	for echecs in 4:
		jeu.bilan_run.clear()
		var offre: Dictionary = fin.offre(true)
		var hasard := RandomNumberGenerator.new()
		var graine := 1
		while true:
			hasard.seed = graine
			if str(ButinsRun.tirer(offre,hasard)["sort"]).is_empty(): break
			graine += 1
		jeu.rng.seed = graine
		fin.finaliser(true,5)
		v.egal(r.epreuves_ratees(1),echecs+1,"coffre eligible compte exactement une fois")
		fin.finaliser(true,5)
		v.egal(r.epreuves_ratees(1),echecs+1,"reouvrir le bilan ne compte pas deux fois")
	var ancien := ""
	var existait := FileAccess.file_exists(r.FICHIER)
	if existait: ancien = FileAccess.get_file_as_string(r.FICHIER)
	r.sauvegarde_active = true
	r.sauvegarder()
	r.epreuves_sans_sort.clear()
	r.charger()
	v.egal(r.epreuves_ratees(1),4,"la garantie survit au rechargement de sauvegarde")
	r.sauvegarde_active = false
	if existait:
		var fichier := FileAccess.open(r.FICHIER,FileAccess.WRITE)
		fichier.store_string(ancien)
		fichier.close()
	else:
		DirAccess.remove_absolute(r.FICHIER)
	jeu.bilan_run.clear()
	fin.finaliser(false,4)
	v.egal(r.epreuves_ratees(1),4,"defaite ne consomme pas la garantie")
	jeu.bilan_run.clear()
	var bilan: Dictionary = fin.finaliser(true,5)
	v.vrai(not str(bilan["sort"]).is_empty(),"cinquieme victoire donne un sort")
	v.egal(r.epreuves_ratees(1),0,"drop reel remet a zero")
	jeu.bilan_run.clear()
	r.rangs_sorts = {"onde_alchimique":10,"rempart_initial":10}
	fin.finaliser(true,5)
	v.egal(r.epreuves_ratees(1),0,"pool complete ne fait pas monter le compteur")
	jeu.mode_run = "grimoire"
	jeu.chapitre = 1
	jeu.salles_terminees.clear()
	for salle in range(1,21): jeu.salles_terminees.append(salle)
	jeu.boss_vaincus.assign([5,10,15,20])
	r.grands_coffres_sans_objet = {"1":2}
	jeu.bilan_run.clear()
	bilan = fin.finaliser(true,20)
	v.egal(str(bilan["objet"]),CatalogueObjets.objet_du_chapitre(1),"troisieme coffre donne l'objet")
	v.egal(r.grands_coffres_rates(1),0,"drop objet remet a zero")
	jeu.bilan_run.clear()
	fin.finaliser(true,20)
	v.egal(r.grands_coffres_rates(1),0,"objet deja obtenu : compteur inactif")
	var page: Control = load("res://ui/apercu_butin.gd").new()
	page.mode = "epreuve_sorts"
	r.rangs_sorts.clear()
	r.epreuves_sans_sort = {"1":4}
	root.add_child(page)
	await process_frame
	var carte: Button = page.find_child("Carte_onde_alchimique",true,false)
	v.vrai(carte != null and carte.text.contains("50.0"),"garantie affichee : un sort, moitie de chance pour chaque candidat")
	page.queue_free()
	await process_frame
	print("Garanties : %d controles, %d echecs" % [v.total,v.echecs.size()])
	for echec in v.echecs: print("ECHEC "+echec)
	quit(0 if v.echecs.is_empty() else 1)
