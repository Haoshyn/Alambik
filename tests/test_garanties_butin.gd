extends RefCounted

func test_probabilites_et_seuils_exacts(v: Verif) -> void:
	for echecs in range(6):
		var objet := ButinsRun.offre("grimoire",1,20,4,true,1,{},[],echecs)
		v.presque(float(objet["chance_objet"]),1.0 if echecs >= 2 else 1.0/3.0,"objet : tiers puis garantie au troisieme")
		var sort := ButinsRun.offre("epreuve_sorts",0,5,5,true,1,{},[],0,echecs)
		v.presque(float(sort["chance_sort"]),1.0 if echecs >= 4 else .2,"sort : cinquieme puis garantie au cinquieme")
	var plein := ButinsRun.offre("epreuve_sorts",0,5,5,true,1,{"onde_alchimique":10,"rempart_initial":10},[],0,4)
	v.presque(float(plein["chance_sort"]),0.0,"pool epuisee sans faux drop garanti")
	var perte := ButinsRun.offre("epreuve_sorts",0,4,4,false,1,{},[],0,4)
	v.vrai((perte["sorts"] as Array).is_empty(),"defaite non eligible meme a la garantie")

func test_aucune_serie_ne_depasse_la_garantie(v: Verif) -> void:
	for maximum in [3,5]:
		for graine in range(1,101):
			var rng := RandomNumberGenerator.new()
			rng.seed = graine
			var echecs := 0
			var succes := 0
			for tentative in 30:
				var offre := ButinsRun.offre("grimoire",1,20,4,true,1,{},[],echecs) if maximum == 3 else ButinsRun.offre("epreuve_sorts",0,5,5,true,1,{},[],0,echecs)
				var butin := ButinsRun.tirer(offre,rng)
				var obtenu := not str(butin["objet" if maximum == 3 else "sort"]).is_empty()
				echecs = 0 if obtenu else echecs+1
				if obtenu: succes += 1
				v.vrai(echecs < maximum,"aucune serie de X echecs consecutifs")
			v.vrai(succes >= 30/maximum,"au moins un drop par bloc de X coffres")

func test_compteurs_locaux_et_remise_a_zero(v: Verif) -> void:
	var r: Node = load("res://autoload/reglages_joueur.gd").new()
	r.sauvegarde_active = false
	r.enregistrer_grand_coffre(1,false)
	r.enregistrer_coffre_epreuve(1,false)
	v.egal(r.grands_coffres_rates(1),1,"compteur objet avance")
	v.egal(r.epreuves_ratees(1),1,"compteur sort avance")
	v.egal(r.grands_coffres_rates(2),0,"chapitres independants")
	v.egal(r.epreuves_ratees(2),0,"epreuves independantes")
	r.enregistrer_grand_coffre(1,true)
	r.enregistrer_coffre_epreuve(1,true)
	v.egal(r.grands_coffres_rates(1),0,"objet remet a zero")
	v.egal(r.epreuves_ratees(1),0,"sort remet a zero")
	r.enregistrer_coffre_epreuve(1,false)
	r.reinitialiser_progression()
	v.vrai(r.epreuves_sans_sort.is_empty(),"nouvelle partie efface la garantie")
	r.free()
