extends RefCounted

# Un seul maillage partage par famille et monde ; les appendices restent courts.
static var _formes: Dictionary = {}
const ANCRAGES := {
	"goutte": Vector2(.25,.42), "plume": Vector2(.17,.37), "dard": Vector2(.22,.30),
	"masque": Vector2(.21,.69), "orbite": Vector2(.31,.55), "belier": Vector2(.27,.36),
	"ruban": Vector2(.21,.68), "miroir": Vector2(.21,.55), "phaseur": Vector2(.15,.52),
	"fuseau": Vector2(.20,.35), "fiole": Vector2(.22,.36),
}

static func construire(forme: String, monde: int, matiere: Material) -> MeshInstance3D:
	var cle := "%s/%d" % [forme, monde]
	if not _formes.has(cle):
		var outil := SurfaceTool.new()
		outil.begin(Mesh.PRIMITIVE_TRIANGLES)
		var ancre: Vector2 = ANCRAGES.get(forme, Vector2(.22,.50))
		var couleur: Color = BestiaireMondes.ACCENTS[monde].srgb_to_linear()
		for cote in [-1.0, 1.0]:
			var point := Vector3(cote * ancre.x, ancre.y, -.10)
			match monde:
				1:
					var pierre := SphereMesh.new()
					pierre.radius = .105
					pierre.height = .18
					pierre.radial_segments = 8
					pierre.rings = 3
					_ajouter(outil, pierre, point + Vector3(0,.035,0), Vector3(0,0,cote*.3), couleur.darkened(.15))
				2:
					var nageoire := _feuille(Vector3(.11,.30,.055))
					_ajouter(outil, nageoire, point, Vector3(-.15,0,-cote*.55), couleur)
				3:
					for i in 2:
						var plume := _feuille(Vector3(.09,.23-i*.045,.035))
						_ajouter(outil, plume, point + Vector3(cote*i*.045,0,-i*.04), Vector3(.20,0,-cote*.70), couleur, true)
				4:
					var flamme := _feuille(Vector3(.13,.25,.05))
					_ajouter(outil, flamme, point, Vector3(.15,0,-cote*.35), couleur)
		_formes[cle] = outil.commit()
	var instance := MeshInstance3D.new()
	instance.name = "SignatureDuMonde"
	instance.mesh = _formes[cle]
	instance.material_override = matiere
	return instance

static func _feuille(taille: Vector3) -> ArrayMesh:
	# Une section ovale epaisse garde un contour courbe sous toutes les orientations.
	var outil := SurfaceTool.new()
	outil.begin(Mesh.PRIMITIVE_TRIANGLES)
	outil.set_smooth_group(0)
	var largeurs := [0.06, 0.75, 1.0, 0.62, 0.01]
	const FACES := 8
	for ligne in largeurs.size():
		var t := float(ligne) / float(largeurs.size() - 1)
		for cote in FACES:
			var angle := float(cote) * TAU / FACES
			outil.set_uv(Vector2(float(cote) / FACES, t))
			outil.add_vertex(Vector3(cos(angle) * taille.x * float(largeurs[ligne]) * .5,
				t * taille.y, sin(angle) * taille.z * .5 + sin(t * PI) * .018))
	for ligne in largeurs.size() - 1:
		for cote in FACES:
			var a := ligne * FACES + cote
			var b := ligne * FACES + (cote + 1) % FACES
			for indice in [a, b, b + FACES, a, b + FACES, a + FACES]: outil.add_index(indice)
	for cote in range(1, FACES - 1):
		for indice in [0, cote + 1, cote]: outil.add_index(indice)
		var dernier := (largeurs.size() - 1) * FACES
		for indice in [dernier, dernier + cote, dernier + cote + 1]: outil.add_index(indice)
	outil.generate_normals()
	return outil.commit()

static func _ajouter(outil: SurfaceTool, forme: Mesh, point: Vector3, rotation: Vector3, couleur: Color, papier := false) -> void:
	var tableaux := forme.surface_get_arrays(0)
	var sommets: PackedVector3Array = tableaux[Mesh.ARRAY_VERTEX]
	var normales: PackedVector3Array = tableaux[Mesh.ARRAY_NORMAL]
	var uv: PackedVector2Array = tableaux[Mesh.ARRAY_TEX_UV]
	var indices: PackedInt32Array = tableaux[Mesh.ARRAY_INDEX]
	var axe := Basis.from_euler(rotation)
	for i in indices:
		var modelage := .88 + .12 * maxf(normales[i].y, 0.0)
		outil.set_color(Color(couleur.r * modelage, couleur.g * modelage, couleur.b * modelage, 1.0))
		outil.set_uv(Vector2(.0175, .5175 if papier else .0175) + uv[i] * .465)
		outil.set_uv2(Vector2.ZERO)
		outil.set_normal(axe * normales[i])
		outil.add_vertex(point + axe * sommets[i])
