extends RefCounted

func test_catalogue_et_boucles(v: Verif) -> void:
	v.egal(Musiques.RUNS.size(), 10, "dix choix pour les runs")
	v.egal(Musiques.MENU.size(), 10, "dix choix pour le menu")
	for menu in [false, true]:
		for piste in Musiques.MENU if menu else Musiques.RUNS:
			var id := str(piste["id"])
			var flux := Musiques.creer_flux(id, menu)
			v.vrai(flux != null and flux.loop, "la piste boucle : " + id)
			if flux != null:
				v.vrai(flux.get_length() > 1.0, "audio non vide : " + id)
	v.egal(Musiques.valider("absente"), "first_arcade", "repli run des anciennes sauvegardes")
	v.egal(Musiques.valider("absente", true), "accueil", "repli menu des anciennes sauvegardes")

func test_choix_independants(v: Verif) -> void:
	var r: Node = load("res://autoload/reglages_joueur.gd").new()
	r.sauvegarde_active = false
	r.definir_piste_menu("atelier_lunaire")
	for id in ["cuivre_vif", "vortex_azur", "braise_volatile"]:
		r.definir_piste_musique(id)
		v.egal(r.piste_musique, id, "chaque nouvelle piste est selectionnable")
		v.egal(r.piste_menu, "atelier_lunaire", "le choix menu reste independant")
	r.definir_piste_menu("cuivre_vif")
	r.definir_piste_musique("atelier_lunaire")
	v.egal(r.piste_menu, "atelier_lunaire", "une piste run ne remplace pas le menu")
	v.egal(r.piste_musique, "braise_volatile", "une piste menu ne remplace pas la run")
	r.free()

func test_tous_les_choix(v: Verif) -> void:
	var r: Node = load("res://autoload/reglages_joueur.gd").new()
	r.sauvegarde_active = false
	for piste in Musiques.RUNS:
		r.definir_piste_musique(str(piste["id"]))
		v.egal(r.piste_musique,str(piste["id"]),"choix run conserve")
	for piste in Musiques.MENU:
		r.definir_piste_menu(str(piste["id"]))
		v.egal(r.piste_menu,str(piste["id"]),"choix menu conserve")
	r.free()
