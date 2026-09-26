extends RefCounted

const Rendu = preload("res://data/animations_projectiles.gd")
static var _formes: Dictionary = {}
static var _matiere: StandardMaterial3D
static var _matiere_halo: StandardMaterial3D

static func construire(silhouette: String, teinte: Color) -> Node3D:
	if _matiere == null:
		_matiere = StandardMaterial3D.new()
		_matiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_matiere.vertex_color_use_as_albedo = true
		_matiere.cull_mode = BaseMaterial3D.CULL_DISABLED
		_matiere_halo = _matiere.duplicate() as StandardMaterial3D
		_matiere_halo.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var cle := silhouette + teinte.to_html()
	if not _formes.has(cle):
		var mesh := ImmediateMesh.new()
		mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, _matiere)
		match silhouette:
			"eclat": _gemme(mesh, teinte)
			"lame":
				for i in 2: _volute(mesh, teinte, PI * i, false)
				_amande(mesh, Vector3(0, .18, 0), .065, .19, .045, teinte.lightened(.3), 6, 10)
			"vrille":
				for i in 3: _volute(mesh, teinte, TAU * i / 3.0, true)
				_amande(mesh, Vector3(0, .19, 0), .085, .20, .075, teinte.lightened(.4), 6, 10)
			_:
				_amande(mesh, Vector3(0, .16, 0), .13, .57 if silhouette == "aiguille" else .36, .105, teinte, 9, 14)
		mesh.surface_end()
		var halo := ImmediateMesh.new()
		halo.surface_begin(Mesh.PRIMITIVE_TRIANGLES, _matiere_halo)
		for i in 28:
			var a := Vector3(cos(TAU * i / 28.0) * .29, .035, sin(TAU * i / 28.0) * .32)
			var b := Vector3(cos(TAU * (i + 1) / 28.0) * .29, .035, sin(TAU * (i + 1) / 28.0) * .32)
			_triangle(halo, Vector3(0, .035, 0), a, b, Color(teinte, .22), Color(teinte, 0), Color(teinte, 0))
		halo.surface_end()
		_formes[cle] = [mesh, halo]
	var racine := Node3D.new()
	for mesh: Mesh in _formes[cle]:
		var piece := MeshInstance3D.new()
		piece.mesh = mesh
		piece.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		racine.add_child(piece)
	return racine

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

static func _gemme(mesh: ImmediateMesh, teinte: Color) -> void:
	var centre := Vector3(0, .18, 0)
	for i in 7:
		var a := TAU * i / 7.0
		var b := TAU * (i + 1) / 7.0
		var pied_a := centre + Vector3(cos(a) * .105, sin(a) * .10, -.19)
		var pied_b := centre + Vector3(cos(b) * .105, sin(b) * .10, -.19)
		var epaule_a := centre + Vector3(cos(a + .08) * .17, sin(a + .08) * .15, .015)
		var epaule_b := centre + Vector3(cos(b + .08) * .17, sin(b + .08) * .15, .015)
		var couleur := _vernis(Vector3(cos((a + b) * .5), sin((a + b) * .5), .22).normalized(), teinte, true)
		_triangle(mesh, pied_a, pied_b, centre + Vector3(0, 0, -.32), couleur.darkened(.16), couleur.darkened(.16), teinte.darkened(.6))
		_triangle(mesh, pied_a, epaule_a, epaule_b, couleur.darkened(.18), couleur, couleur.lightened(.1))
		_triangle(mesh, pied_a, epaule_b, pied_b, couleur.darkened(.18), couleur.lightened(.1), couleur.darkened(.18))
		_triangle(mesh, epaule_a, centre + Vector3(0, .025, .30), epaule_b, couleur, couleur.lerp(Rendu.REFLET, .6), couleur.lightened(.1))

static func _volute(mesh: ImmediateMesh, teinte: Color, orientation: float, spirale: bool) -> void:
	var nombre := 18
	for i in nombre:
		var points: Array[Vector3] = []
		var couleurs: Array[Color] = []
		for j in 2:
			var t := float(i + j) / nombre
			var angle := orientation + t * PI * (1.25 if spirale else 1.18)
			var rayon := lerpf(.075, .30, t) if spirale else .235
			var largeur := pow(maxf(0.0, sin(t * PI)), .75) * (.065 if spirale else .055)
			var hauteur := .115 + sin(t * PI) * .09
			var radial := Vector3(cos(angle), 0, sin(angle))
			var point := radial * rayon + Vector3.UP * hauteur
			points.append_array([point - radial * largeur, point + Vector3.UP * .026, point + radial * largeur])
			couleurs.append_array([teinte.darkened(.46), teinte.lerp(Rendu.REFLET, .68 + .20 * sin(t * PI)), teinte])
		_triangle(mesh, points[0], points[3], points[1], couleurs[0], couleurs[3], couleurs[1])
		_triangle(mesh, points[1], points[3], points[4], couleurs[1], couleurs[3], couleurs[4])
		_triangle(mesh, points[1], points[4], points[2], couleurs[1], couleurs[4], couleurs[2])
		_triangle(mesh, points[2], points[4], points[5], couleurs[2], couleurs[4], couleurs[5])
