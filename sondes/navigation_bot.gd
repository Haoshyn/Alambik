extends RefCounted

# Graphe de visibilite reserve aux sondes : aucune aide au joueur ni teleportation.
static func chemin(depart: Vector2, arrivee: Vector2, limites: Rect2,
		obstacles: Array, rayon: float, contour_sol := PackedVector2Array()) -> PackedVector2Array:
	var marge := maxf(0.0,rayon-0.5)
	if Geometrie.ligne_libre(depart,arrivee,obstacles,marge):
		return PackedVector2Array([depart,arrivee])
	var points := PackedVector2Array([depart,arrivee])
	for rect: Rect2 in obstacles:
		var contour := rect.grow(rayon+8.0)
		for p in [contour.position,Vector2(contour.end.x,contour.position.y),contour.end,Vector2(contour.position.x,contour.end.y)]:
			if not limites.grow(-rayon).has_point(p): continue
			if not contour_sol.is_empty() and not FormesSalles.contient_disque(p,contour_sol,rayon): continue
			if Geometrie.ligne_libre(p,p,obstacles,marge): points.append(p)
	var graphe := AStar2D.new()
	for i in points.size(): graphe.add_point(i,points[i])
	for i in points.size():
		for j in range(i+1,points.size()):
			if Geometrie.ligne_libre(points[i],points[j],obstacles,marge):
				graphe.connect_points(i,j)
	return graphe.get_point_path(0,1)

# Un point de tir peut se trouver plus loin que le cercle local du bot quand
# un pilier long separe les acteurs. Les coins permettent alors le contournement.
static func point_de_tir(depart: Vector2, cible: Vector2, limites: Rect2,
		obstacles: Array, rayon: float, marge_tir: float, contour_sol: PackedVector2Array) -> Vector2:
	var candidats := PackedVector2Array()
	for origine in [depart,cible]:
		for distance in [200.0,380.0]:
			for i in 12:
				candidats.append(origine+Vector2.from_angle(TAU*float(i)/12.0)*distance)
	for rect: Rect2 in obstacles:
		var bord := rect.grow(rayon+8.0)
		candidats.append_array(PackedVector2Array([bord.position,bord.end,
			Vector2(bord.position.x,bord.end.y),Vector2(bord.end.x,bord.position.y)]))
	var meilleur := Vector2.ZERO
	var cout := INF
	for p in candidats:
		if not limites.grow(-rayon).has_point(p): continue
		if not contour_sol.is_empty() and not FormesSalles.contient_disque(p,contour_sol,rayon): continue
		if not Geometrie.ligne_libre(p,cible,obstacles,marge_tir): continue
		if not Geometrie.ligne_libre(p,p,obstacles,rayon): continue
		var trajet := chemin(depart,p,limites,obstacles,rayon,contour_sol)
		if trajet.is_empty(): continue
		var longueur := 0.0
		for i in range(1,trajet.size()): longueur += trajet[i-1].distance_to(trajet[i])
		var score := longueur + absf(p.distance_to(cible)-380.0)
		if score < cout:
			cout = score
			meilleur = p
	return meilleur
