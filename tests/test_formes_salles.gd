extends RefCounted

func test_contours_et_passages(v: Verif) -> void:
	var navigation: GDScript = load("res://sondes/navigation_bot.gd")
	for profil in FormesSalles.PROFILS.size():
		var facteur: Vector2 = FormesSalles.PROFILS[profil]["taille"]
		var limites := Rect2(Vector2(78,244), Reglages.ARENE_TAILLE * facteur)
		var contour := FormesSalles.contour(limites, profil)
		v.vrai(not Geometry2D.triangulate_polygon(contour).is_empty(), "sol triangulable du profil %d" % profil)
		var entree := Vector2(limites.get_center().x, limites.end.y-120)
		var sortie := Vector2(limites.get_center().x, limites.position.y+180)
		for point in [entree, sortie]:
			v.vrai(FormesSalles.contient_disque(point, contour, FormesSalles.MARGE_APPARITION), "entree et sortie degagees")
		for composition in Reglages.ARENE_COMPOSITIONS:
			var obstacles: Array[Rect2] = []
			for bloc: Rect2 in composition:
				var rect := Rect2(limites.position+bloc.position*limites.size, bloc.size*limites.size)
				obstacles.append(rect)
				for coin in [rect.position, rect.end, Vector2(rect.position.x,rect.end.y), Vector2(rect.end.x,rect.position.y)]:
					v.vrai(FormesSalles.contient_disque(coin, contour, Reglages.ARENE_PASSAGE_MIN), "passage entre bloc et contour %d" % profil)
			var chemin: PackedVector2Array = navigation.chemin(entree, sortie, limites, obstacles, Reglages.HEROS_RAYON)
			v.vrai(chemin.size()>1, "portail accessible")
			for point in chemin:
				v.vrai(FormesSalles.contient_disque(point, contour, Reglages.HEROS_RAYON), "navigation dans la surface jouable")

func test_rotation_des_formes(v: Verif) -> void:
	for graine in range(6):
		var formes := {}
		for numero in range(1,21):
			var profil := FormesSalles.indice(numero, 0, graine, "grimoire")
			formes[profil] = true
			v.egal(profil, FormesSalles.indice(numero, 0, graine, "grimoire"), "forme reproductible")
			if Chapitres.est_boss(0, numero):
				v.egal(profil, 0, "boss degage")
		v.egal(formes.size(), FormesSalles.PROFILS.size(), "toutes les formes dans le chapitre")
	for mode in ["mine", "retro", "epreuve_sorts"]:
		v.egal(FormesSalles.indice(2, 0, 12, mode), 0, "bords des modes speciaux conserves")
