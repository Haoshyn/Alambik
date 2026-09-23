extends RefCounted

static var _matieres: Dictionary = {}
static var _formes := {}
static var _perle: SphereMesh

static func construire(silhouette: String, teinte: Color) -> Node3D:
	var racine := Node3D.new()
	if not _matieres.has(silhouette):
		var nouvelles_matieres: Array[StandardMaterial3D] = []
		for couleur in [Color("481a3f"), teinte, Color("fff2cf")]:
			var matiere := StandardMaterial3D.new()
			matiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			matiere.cull_mode = BaseMaterial3D.CULL_DISABLED
			matiere.albedo_color = couleur
			nouvelles_matieres.append(matiere)
		_matieres[silhouette] = nouvelles_matieres
	var matieres: Array[StandardMaterial3D] = _matieres[silhouette]
	if not _formes.has(silhouette):
		var forme: Mesh
		if silhouette == "vrille":
			forme = _spirale()
		else:
			var prisme := PrismMesh.new()
			prisme.size = Vector3(.28,.22,.30) if silhouette == "eclat" else (Vector3(.20,.10,.58) if silhouette == "lame" else Vector3(.16,.13,.57))
			forme = prisme
		_formes[silhouette] = forme
	var nombre := 3 if silhouette in ["vrille", "eclat"] else (2 if silhouette == "lame" else 1)
	for i in nombre:
		var angle := TAU * float(i) / float(nombre) if silhouette in ["vrille", "eclat"] else (-.30 if i == 0 else .30)
		var decalage := Vector3(sin(angle) * .10, .12, cos(angle) * .10) if silhouette == "eclat" else Vector3(0, .10, 0)
		if silhouette == "lame": decalage.x = -.10 if i == 0 else .10
		for couche in 2:
			var piece := MeshInstance3D.new()
			piece.mesh = _formes[silhouette]
			piece.material_override = matieres[couche]
			piece.position = decalage + Vector3(0, .01 * float(couche), 0)
			piece.rotation.y = angle
			piece.scale = Vector3(1.24, 1.12, 1.20) if couche == 0 else Vector3.ONE
			piece.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			racine.add_child(piece)
	if _perle == null:
		_perle = SphereMesh.new()
		_perle.radius = .09
		_perle.height = .18
		_perle.radial_segments = 8
		_perle.rings = 4
	var coeur := MeshInstance3D.new()
	coeur.mesh = _perle
	coeur.material_override = matieres[2]
	coeur.position.y = .20
	coeur.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	racine.add_child(coeur)
	return racine

static func _spirale() -> ImmediateMesh:
	var mesh := ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 20:
		var t := float(i) / 20.0
		var suivant := float(i + 1) / 20.0
		var a := Vector3(cos(t * TAU) * (.06 + .25 * t), .42 * t, sin(t * TAU) * (.06 + .25 * t))
		var b := Vector3(cos(suivant * TAU) * (.06 + .25 * suivant), .42 * suivant, sin(suivant * TAU) * (.06 + .25 * suivant))
		var largeur_a := Vector3.UP * (.025 + sin(t * PI) * .034)
		var largeur_b := Vector3.UP * (.025 + sin(suivant * PI) * .034)
		for point: Vector3 in [a - largeur_a, b - largeur_b, a + largeur_a, a + largeur_a, b - largeur_b, b + largeur_b]:
			mesh.surface_add_vertex(point)
	mesh.surface_end()
	return mesh
