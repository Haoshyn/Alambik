extends RefCounted

func test_identite_accueil_conservee(v: Verif) -> void:
	v.egal(FileAccess.get_sha256("res://assets/visual/azur/accueil_valide.png"),"464be56370deece952b9c44bc2f24dc34648c8bd2d2710e562dd4f2fde8d1414","illustration approuvee sans retouche")

func test_bijoux_compatibles_sauvegardes(v: Verif) -> void:
	for monde in CatalogueObjets.IDS_PAR_MONDE:
		v.vrai(str(CatalogueObjets.OBJETS[monde[0]]["nom"]).begins_with("Anneau"),"premier bijou : Anneau")
		v.vrai(str(CatalogueObjets.OBJETS[monde[1]]["nom"]).begins_with("Bague"),"second bijou : Bague")
		for id in monde.slice(0,2):
			v.vrai(CatalogueObjets.compatible("anneau_gauche",id),"ancien emplacement gauche")
			v.vrai(CatalogueObjets.compatible("anneau_droit",id),"ancien emplacement droit")

func test_salle_portrait(v: Verif) -> void:
	v.vrai(Reglages.ARENE_TAILLE.y > Reglages.ARENE_TAILLE.x,"rectangle plus haut que large")
	v.vrai(Reglages.ARENE_TAILLE.x >= Reglages.ARENE_PASSAGE_MIN*4,"espace pour les obstacles et les passages")
	v.vrai(Reglages.ARENE_TAILLE.x > 1080/Reglages.ARENE_CAMERA_ZOOM,"camera ne montre pas toute la largeur")

func test_glyphes_couvrent_les_catalogues(v: Verif) -> void:
	for catalogue in [CatalogueReactifs.TOUS,ArbreCompetences.NOEUDS,Sorts.ACTIFS,Sorts.PASSIFS,Sorts.ULTIMES,CatalogueElements.TOUS]:
		var empreintes := {}
		for id in catalogue:
			var chemin := "res://assets/visual/azur/glyphes/"+str(id)+".svg"
			v.vrai(ResourceLoader.exists(chemin),"glyphe dedie : "+str(id))
			var empreinte := FileAccess.get_sha256(chemin)
			v.vrai(not empreintes.has(empreinte),"silhouette distincte : "+str(id))
			empreintes[empreinte] = true

func test_passages_des_compositions(v: Verif) -> void:
	for i in Reglages.ARENE_COMPOSITIONS.size():
		var rectangles: Array[Rect2] = []
		for point: Vector2 in Reglages.ARENE_COMPOSITIONS[i]:
			var rect := Rect2(point*Reglages.ARENE_TAILLE-Reglages.ARENE_OBSTACLE_TAILLE/2,Reglages.ARENE_OBSTACLE_TAILLE)
			for autre in rectangles:
				v.vrai(not rect.grow(Reglages.ARENE_PASSAGE_MIN).intersects(autre),"passage entre deux obstacles")
			for retrait: Rect2 in Reglages.ARENE_RETRAITS[i]:
				var bord := Rect2(retrait.position*Reglages.ARENE_TAILLE,retrait.size*Reglages.ARENE_TAILLE)
				v.vrai(not rect.grow(Reglages.ARENE_PASSAGE_MIN).intersects(bord),"passage entre obstacle et retrait")
			rectangles.append(rect)

func test_navigation_portail_autour_des_blocs(v: Verif) -> void:
	var navigation: GDScript = load("res://sondes/navigation_bot.gd")
	var limites := Rect2(Vector2.ZERO,Reglages.ARENE_TAILLE)
	var but := Vector2(limites.get_center().x,180)
	for motif in Reglages.ARENE_COMPOSITIONS.size():
		var obstacles: Array[Rect2] = []
		for point: Vector2 in Reglages.ARENE_COMPOSITIONS[motif]:
			obstacles.append(Rect2(point*limites.size-Reglages.ARENE_OBSTACLE_TAILLE/2,Reglages.ARENE_OBSTACLE_TAILLE))
		for rect: Rect2 in Reglages.ARENE_RETRAITS[motif]:
			obstacles.append(Rect2(rect.position*limites.size,rect.size*limites.size))
		for obstacle in obstacles.slice(0,3):
			var depart := Vector2(obstacle.get_center().x,obstacle.end.y+Reglages.HEROS_RAYON+0.1)
			var chemin: PackedVector2Array = navigation.chemin(depart,but,limites,obstacles,Reglages.HEROS_RAYON)
			v.vrai(chemin.size()>1,"sortir du contact d'un obstacle et rejoindre le portail")
			for i in range(1,chemin.size()):
				v.vrai(Geometrie.ligne_libre(chemin[i-1],chemin[i],obstacles,Reglages.HEROS_RAYON-0.5),"trajet praticable avec le rayon du heros")
