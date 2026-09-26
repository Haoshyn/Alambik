extends RefCounted

const Rendu = preload("res://data/animations_projectiles.gd")

static func remplir(mesh: ImmediateMesh, matiere: Material, points: Array[Vector2],
		origine: Vector3, couleur: Color, silhouette: String, reduit: bool) -> void:
	mesh.clear_surfaces()
	var nombre := mini(points.size(), Rendu.POINTS_TRAINEE_REDUITS if reduit else Rendu.POINTS_TRAINEE)
	if nombre < 2: return
	var largeur := float(Rendu.profil(silhouette)["trainee"])
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, matiere)
	for i in nombre - 1:
		var a := Pont3D.vers_monde(points[i], .13) - origine
		var b := Pont3D.vers_monde(points[i + 1], .13) - origine
		var cote := (b - a).cross(Vector3.UP).normalized()
		if cote.is_zero_approx(): continue
		var debut := 1.0 - float(i) / (nombre - 1)
		var fin := 1.0 - float(i + 1) / (nombre - 1)
		var chaud_a := Color(couleur.lerp(Rendu.REFLET, .62), pow(debut, 1.5) * .70)
		var chaud_b := Color(couleur.lerp(Rendu.REFLET, .62), pow(fin, 1.5) * .70)
		_bande(mesh, a - cote * largeur * debut, a, b - cote * largeur * fin, b, Color(couleur, 0), chaud_a, Color(couleur, 0), chaud_b)
		_bande(mesh, a, a + cote * largeur * debut, b, b + cote * largeur * fin, chaud_a, Color(couleur, 0), chaud_b, Color(couleur, 0))
		if not reduit:
			var reflet_a := Color(Rendu.REFLET, pow(debut, 2.0) * .62)
			var reflet_b := Color(Rendu.REFLET, pow(fin, 2.0) * .62)
			_bande(mesh, a - cote * largeur * debut * .18, a + cote * largeur * debut * .18,
				b - cote * largeur * fin * .18, b + cote * largeur * fin * .18, reflet_a, reflet_a, reflet_b, reflet_b)
	mesh.surface_end()

static func _bande(mesh: ImmediateMesh, a: Vector3, b: Vector3, c: Vector3, d: Vector3,
		ca: Color, cb: Color, cc: Color, cd: Color) -> void:
	for sommet: Array in [[a, ca], [b, cb], [d, cd], [a, ca], [d, cd], [c, cc]]:
		mesh.surface_set_color(sommet[1])
		mesh.surface_add_vertex(sommet[0])
