extends RefCounted

# L'atlas reste partage ; UV2 conserve le role et le modelage peint des volumes.
const ATLAS := preload("res://assets/3d/textures/bestiaire_matieres_peintes.png")
static var _maillages: Dictionary = {}
static var _matiere: StandardMaterial3D

static func appliquer(modele: Node3D, donnees: Dictionary) -> void:
	var boss := str(donnees.get("cerveau", "")) == "boss"
	var monde := clampi(int(donnees.get("monde_visuel", 0)), 0, BestiaireMondes.COULEURS.size() - 1)
	if _matiere == null:
		_matiere = StandardMaterial3D.new()
		_matiere.vertex_color_use_as_albedo = true
		_matiere.albedo_texture = ATLAS
		_matiere.roughness = .84
		_matiere.metallic_specular = .22
		_matiere.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	for objet: MeshInstance3D in modele.find_children("Email_*", "MeshInstance3D", true, false):
		if not boss:
			var cle := "%s/%s/%d" % [modele.scene_file_path, modele.get_path_to(objet), monde]
			objet.mesh = _teinter(objet.mesh, monde, cle)
		objet.material_override = _matiere
	if not boss:
		modele.scale *= BestiaireMondes.ECHELLES[monde]
		if monde > 0:
			modele.add_child(preload("res://scripts/presentation/ornements_bestiaire_3d.gd").construire(str(donnees["forme"]), monde, _matiere))

static func _teinter(source: Mesh, monde: int, cle: String) -> ArrayMesh:
	# Un chemin stable reutilise la variante meme apres dechargement de la salle.
	if _maillages.has(cle): return _maillages[cle]
	var teinte: Color = BestiaireMondes.COULEURS[monde].srgb_to_linear()
	var accent: Color = BestiaireMondes.ACCENTS[monde].srgb_to_linear()
	var mesh := ArrayMesh.new()
	for index in source.get_surface_count():
		var tableaux := source.surface_get_arrays(index)
		var couleurs: PackedColorArray = tableaux[Mesh.ARRAY_COLOR]
		var roles: PackedVector2Array = tableaux[Mesh.ARRAY_TEX_UV2]
		for i in mini(couleurs.size(), roles.size()):
			if monde == 0: continue
			var modelage := maxf(roles[i].y, .4)
			if roles[i].x > .7:
				couleurs[i] = couleurs[i].lerp(Color(accent.r * modelage, accent.g * modelage, accent.b * modelage), .55)
			elif roles[i].x > .1:
				couleurs[i] = couleurs[i].lerp(Color(teinte.r * modelage, teinte.g * modelage, teinte.b * modelage), .55)
		tableaux[Mesh.ARRAY_COLOR] = couleurs
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, tableaux)
	_maillages[cle] = mesh
	return mesh
