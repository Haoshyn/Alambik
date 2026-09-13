extends RefCounted

func test_debut_et_progression_complets(v: Verif) -> void:
	for id in CatalogueEnnemis.TOUS:
		var base := CatalogueEnnemis.par_id(id)
		var avant := base.duplicate(true)
		for chapitre in [0,1,2]:
			v.egal(EvolutionEnnemis.appliquer(base,chapitre),base,"premier monde preserve : "+id)
		for chapitre in [3,12,21,29]:
			var evolue := EvolutionEnnemis.appliquer(base,chapitre)
			v.egal(evolue["pv"],base["pv"],"evolution sans inflation de vie : "+id)
			v.egal(evolue["cerveau"],base["cerveau"],"identite preservee : "+id)
			v.vrai(int(evolue["evolution"]) > 0,"tout le bestiaire evolue : "+id)
			for cle in ["preparation","telegraphe"]:
				if evolue.has(cle): v.vrai(float(evolue[cle]) >= EvolutionEnnemis.TELEGRAPHE_MIN,"annonce lisible : "+id)
		v.egal(base,avant,"catalogue non modifie : "+id)

func test_evolutions_de_comportement(v: Verif) -> void:
	for id in CatalogueEnnemis.TOUS:
		var base := CatalogueEnnemis.par_id(id)
		var fin := EvolutionEnnemis.appliquer(base,29)
		match str(base["cerveau"]):
			"sentinelle","orbiteur","harceleur","tisseur","phaseur":
				v.vrai(int(fin["projectiles"]) > int(base.get("projectiles",1)),"eventail enrichi : "+id)
				v.egal(fin["salves"],3,"trois salves bornees : "+id)
			"essaimeur","miroir","volatile":
				v.vrai(int(fin["projectiles_cercle"]) > int(base["projectiles_cercle"]),"anneau enrichi : "+id)
			"veloce": v.egal(fin["charges"],2,"deux charges annoncees : "+id)
			"rampant": v.vrai(float(fin["elan_distance"]) > 0.0,"elan de melee annonce")
			"boss":
				v.vrai(float(fin["vitesse_projectile"]) > float(base["vitesse_projectile"]),"pression accrue du boss : "+id)

func test_palier_borne(v: Verif) -> void:
	v.egal(EvolutionEnnemis.palier(-1),0,"pas de palier negatif")
	v.egal(EvolutionEnnemis.palier(999),3,"pression plafonnee")

func test_fabrique_de_salle(v: Verif) -> void:
	var mode_avant: String = Jeu.mode_run
	var chapitre_avant: int = Jeu.chapitre
	Jeu.mode_run = "grimoire"
	Jeu.chapitre = 12
	var salle: Node = load("res://scripts/salle.gd").new()
	for id in CatalogueEnnemis.TOUS:
		var d: Dictionary = salle.call("_mis_a_l_echelle",CatalogueEnnemis.par_id(id),id)
		v.egal(d["evolution"],2,"fabrique commune aux vagues et invocations : "+id)
	salle.free()
	Jeu.mode_run = mode_avant
	Jeu.chapitre = chapitre_avant
