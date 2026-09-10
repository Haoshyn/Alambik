extends RefCounted

# Graphe de visibilite reserve aux sondes : aucune aide au joueur ni teleportation.
static func chemin(depart: Vector2, arrivee: Vector2, limites: Rect2,
		obstacles: Array, rayon: float) -> PackedVector2Array:
	var marge := maxf(0.0,rayon-0.5)
	if Geometrie.ligne_libre(depart,arrivee,obstacles,marge):
		return PackedVector2Array([depart,arrivee])
	var points := PackedVector2Array([depart,arrivee])
	for rect: Rect2 in obstacles:
		var contour := rect.grow(rayon+8.0)
		for p in [contour.position,Vector2(contour.end.x,contour.position.y),contour.end,Vector2(contour.position.x,contour.end.y)]:
			if not limites.grow(-rayon).has_point(p): continue
			if Geometrie.ligne_libre(p,p,obstacles,marge): points.append(p)
	var graphe := AStar2D.new()
	for i in points.size(): graphe.add_point(i,points[i])
	for i in points.size():
		for j in range(i+1,points.size()):
			if Geometrie.ligne_libre(points[i],points[j],obstacles,marge):
				graphe.connect_points(i,j)
	return graphe.get_point_path(0,1)
