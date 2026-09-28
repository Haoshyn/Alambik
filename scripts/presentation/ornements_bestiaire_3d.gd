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
					pierre.radius = .125
					pierre.height = .17
					pierre.radial_segments = 5
					pierre.rings = 2
					_ajouter(outil, pierre, point, Vector3(0,0,cote*.3), couleur.darkened(.25))
				2:
					var nageoire := PrismMesh.new()
					nageoire.size = Vector3(.07,.31,.19)
					_ajouter(outil, nageoire, point, Vector3(.25,0,-cote*.65), couleur)
				3:
					for i in 2:
						var plume := PrismMesh.new()
						plume.size = Vector3(.05,.27-i*.06,.075)
						_ajouter(outil, plume, point + Vector3(cote*i*.045,0,-i*.06), Vector3(.4,0,-cote*.8), couleur)
				4:
					var flamme := PrismMesh.new()
					flamme.size = Vector3(.09,.25,.12)
					_ajouter(outil, flamme, point + Vector3(0,.025,0), Vector3(.22,0,-cote*.40), couleur)
		_formes[cle] = outil.commit()
	var instance := MeshInstance3D.new()
	instance.name = "SignatureDuMonde"
	instance.mesh = _formes[cle]
	instance.material_override = matiere
	return instance

static func _ajouter(outil: SurfaceTool, forme: PrimitiveMesh, point: Vector3, rotation: Vector3, couleur: Color) -> void:
	var tableaux := forme.surface_get_arrays(0)
	var sommets: PackedVector3Array = tableaux[Mesh.ARRAY_VERTEX]
	var normales: PackedVector3Array = tableaux[Mesh.ARRAY_NORMAL]
	var indices: PackedInt32Array = tableaux[Mesh.ARRAY_INDEX]
	var axe := Basis.from_euler(rotation)
	for i in indices:
		outil.set_color(couleur)
		outil.set_uv(Vector2(.25,.75))
		outil.set_uv2(Vector2.ZERO)
		outil.set_normal(axe * normales[i])
		outil.add_vertex(point + axe * sommets[i])
