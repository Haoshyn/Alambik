extends RefCounted

const Rendu = preload("res://data/presentation/animations_projectiles.gd")
const Formes = preload("res://data/presentation/formes_tirs.gd")
static var _formes: Dictionary = {}
static var _matiere: StandardMaterial3D
static var _matiere_halo: StandardMaterial3D

static func construire(silhouette: String, teinte: Color, allongement := 1.0, monde := -1) -> Node3D:
	if _matiere == null:
		_matiere = StandardMaterial3D.new()
		_matiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_matiere.vertex_color_use_as_albedo = true
		_matiere.cull_mode = BaseMaterial3D.CULL_DISABLED
		_matiere_halo = _matiere.duplicate() as StandardMaterial3D
		_matiere_halo.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var cle := silhouette + teinte.to_html() + str(allongement) + str(monde)
	if not _formes.has(cle):
		var mesh := ImmediateMesh.new()
		mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, _matiere)
		if silhouette in Formes.BOULES:
			if monde >= 0: _face(mesh, Formes.contour(silhouette), Rendu.CONTOUR_HOSTILE, .02)
			_amande(mesh, Vector3(0, .24, 0), .87, 1.74, .65, teinte.darkened(.55) if silhouette == "devoreur_neant" else teinte, 10, 16)
			match silhouette:
				"roi_braises": _relief(mesh, Formes.contour(silhouette), teinte, .08, monde >= 0)
				"archiscribe_encres":
					_cercler(mesh, teinte.lightened(.5), .92, .10, .34)
					_cercler(mesh, teinte.lightened(.3), .72, .07, .69)
				"devoreur_neant": _cercler(mesh, teinte.lightened(.4), .95, .14, .20)
				"grand_alambic":
					for i in 3:
						var angle := i * TAU / 3.0
						_amande(mesh, Vector3(cos(angle) * .72, .60, sin(angle) * .72), .25, .50, .22, Rendu.REFLET, 5, 8)
				"salamandre": _cercler(mesh, teinte.lightened(.45), .95, .08, .2)
		else:
			_relief(mesh, Formes.contour(silhouette), teinte, .28, monde >= 0)
		if monde >= 0:
			for i in monde + 1:
				var angle := TAU * i / float(monde + 1)
				_amande(mesh, Vector3(cos(angle) * .33, .92, sin(angle) * .33), .075, .15, .04, Rendu.REFLET, 3, 5)
		mesh.surface_end()
		var halo := ImmediateMesh.new()
		halo.surface_begin(Mesh.PRIMITIVE_TRIANGLES, _matiere_halo)
		for i in 28:
			var a := Vector3(cos(TAU * i / 28.0), .015, sin(TAU * i / 28.0))
			var b := Vector3(cos(TAU * (i + 1) / 28.0), .015, sin(TAU * (i + 1) / 28.0))
			# La lueur couvre la capsule, y compris les coins hors du motif decoupe.
			a.z = (a.z + signf(a.z) * (allongement - 1.0)) / allongement
			b.z = (b.z + signf(b.z) * (allongement - 1.0)) / allongement
			_triangle(halo, Vector3(0, .015, 0), a, b, Color(teinte, .32), Color(teinte, .08), Color(teinte, .08))
		halo.surface_end()
		_formes[cle] = [mesh, halo]
	var racine := Node3D.new()
	for mesh: Mesh in _formes[cle]:
		var piece := MeshInstance3D.new()
		piece.mesh = mesh
		piece.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		racine.add_child(piece)
	return racine

static func _face(mesh: ImmediateMesh, contour: PackedVector2Array, couleur: Color, hauteur: float) -> void:
	var indices := Geometry2D.triangulate_polygon(contour)
	for i in range(0, indices.size(), 3):
		var a := contour[indices[i]]
		var b := contour[indices[i + 1]]
		var c := contour[indices[i + 2]]
		_triangle(mesh, Vector3(a.x, hauteur, a.y), Vector3(b.x, hauteur, b.y), Vector3(c.x, hauteur, c.y), couleur, couleur, couleur)

static func _relief(mesh: ImmediateMesh, contour: PackedVector2Array, teinte: Color, hauteur: float, hostile := false) -> void:
	var dessus := contour.duplicate()
	if hostile:
		# Le liseret opaque reste dans le volume dangereux, meme sans les effets.
		_face(mesh, contour, Rendu.CONTOUR_HOSTILE, hauteur)
		for i in dessus.size(): dessus[i] *= Rendu.INTERIEUR_HOSTILE
	var indices := Geometry2D.triangulate_polygon(contour)
	for i in range(0, indices.size(), 3):
		var a: Vector2 = dessus[indices[i]]
		var b: Vector2 = dessus[indices[i + 1]]
		var c: Vector2 = dessus[indices[i + 2]]
		var plan := hauteur + (.01 if hostile else 0.0)
		_triangle(mesh, Vector3(a.x, plan, a.y), Vector3(b.x, plan, b.y), Vector3(c.x, plan, c.y),
			teinte if hostile else teinte.lightened(.3), teinte, teinte.lerp(Rendu.REFLET, Rendu.REFLET_HOSTILE if hostile else .5))
	for i in contour.size():
		var a := Vector3(contour[i].x, 0, contour[i].y)
		var b := Vector3(contour[(i + 1) % contour.size()].x, 0, contour[(i + 1) % contour.size()].y)
		_triangle(mesh, a, b, a + Vector3.UP * hauteur, teinte.darkened(.65), teinte.darkened(.4), teinte)
		_triangle(mesh, b, b + Vector3.UP * hauteur, a + Vector3.UP * hauteur, teinte.darkened(.4), teinte.lightened(.15), teinte)

static func _cercler(mesh: ImmediateMesh, teinte: Color, rayon: float, epaisseur: float, hauteur: float) -> void:
	for i in 32:
		var a := Vector3(cos(TAU * i / 32.0), 0, sin(TAU * i / 32.0))
		var b := Vector3(cos(TAU * (i + 1) / 32.0), 0, sin(TAU * (i + 1) / 32.0))
		var haut := Vector3.UP * hauteur
		_triangle(mesh, a * rayon + haut, b * rayon + haut, a * (rayon - epaisseur) + haut, teinte, teinte, Rendu.REFLET)
		_triangle(mesh, b * rayon + haut, b * (rayon - epaisseur) + haut, a * (rayon - epaisseur) + haut, teinte, Rendu.REFLET, Rendu.REFLET)

static func _triangle(mesh: ImmediateMesh, a: Vector3, b: Vector3, c: Vector3,
		ca: Color, cb: Color, cc: Color) -> void:
	for sommet: Array in [[a, ca], [b, cb], [c, cc]]:
		mesh.surface_set_color(sommet[1])
		mesh.surface_add_vertex(sommet[0])

static func _vernis(normale: Vector3, teinte: Color, facette := false) -> Color:
	var lumiere := maxf(0.0, normale.dot(Vector3(-.40, .78, .48).normalized()))
	var couleur := teinte.darkened(.70).lerp(teinte, smoothstep(-.15, .55, normale.y * .65 + lumiere * .6))
	var reflet := pow(lumiere, 5.0 if facette else 12.0)
	return couleur.lerp(Rendu.REFLET, reflet * .9)

static func _point_amande(v: float, angle: float, centre: Vector3,
		largeur: float, longueur: float, hauteur: float) -> Vector3:
	var radial := sin(v * PI)
	var ventre := radial * (.72 + .28 * sin(v * PI))
	return centre + Vector3(cos(angle) * ventre * largeur, sin(angle) * ventre * hauteur,
		cos(v * PI) * longueur * .52)

static func _amande(mesh: ImmediateMesh, centre: Vector3, largeur: float,
		longueur: float, hauteur: float, teinte: Color, anneaux: int, faces: int) -> void:
	for j in anneaux:
		for i in faces:
			var points: Array[Vector3] = []
			var couleurs: Array[Color] = []
			for uv: Vector2 in [Vector2(i, j), Vector2(i + 1, j), Vector2(i, j + 1), Vector2(i + 1, j + 1)]:
				var v := uv.y / anneaux
				var angle := TAU * uv.x / faces
				points.append(_point_amande(v, angle, centre, largeur, longueur, hauteur))
				couleurs.append(_vernis(Vector3(cos(angle) * sin(v * PI), sin(angle) * sin(v * PI), cos(v * PI)), teinte))
			_triangle(mesh, points[0], points[1], points[2], couleurs[0], couleurs[1], couleurs[2])
			_triangle(mesh, points[1], points[3], points[2], couleurs[1], couleurs[3], couleurs[2])
