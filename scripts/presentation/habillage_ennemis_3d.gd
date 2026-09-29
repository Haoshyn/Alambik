extends RefCounted

# L'atlas reste partage ; UV2 conserve le role et le modelage peint des volumes.
const ATLAS := preload("res://assets/3d/textures/bestiaire_matieres_peintes.png")
const Matieres = preload("res://data/presentation/matieres_bestiaire.gd")
static var _maillages: Dictionary = {}
static var _matiere: StandardMaterial3D

static func appliquer(modele: Node3D, donnees: Dictionary) -> void:
	var boss := str(donnees.get("cerveau", "")) == "boss"
	var monde := clampi(int(donnees.get("monde_visuel", 0)), 0, BestiaireMondes.COULEURS.size() - 1)
	if _matiere == null:
		_matiere = StandardMaterial3D.new()
		_matiere.vertex_color_use_as_albedo = true
		_matiere.albedo_texture = ATLAS
		var reponse := _carte_surfaces()
		_matiere.roughness = 1.0
		_matiere.roughness_texture = reponse
		_matiere.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
		_matiere.metallic = 1.0
		_matiere.metallic_texture = reponse
		_matiere.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
		_matiere.metallic_specular = Matieres.SPECULAIRE
		_matiere.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		_matiere.texture_repeat = false
	for objet: MeshInstance3D in modele.find_children("Email_*", "MeshInstance3D", true, false):
		if not boss:
			var cle := "%s/%s/%d" % [modele.scene_file_path, modele.get_path_to(objet), monde]
			objet.mesh = _teinter(objet.mesh, monde, cle)
		objet.material_override = _matiere
	if not boss:
		modele.scale *= BestiaireMondes.ECHELLES[monde]
		if monde > 0:
			modele.add_child(preload("res://scripts/presentation/ornements_bestiaire_3d.gd").construire(str(donnees["forme"]), monde, _matiere))

static func _carte_surfaces() -> ImageTexture:
	# Une petite carte partagee distingue les reflets sans multiplier les surfaces.
	var image := Image.create(Matieres.CARTE_TAILLE, Matieres.CARTE_TAILLE, false, Image.FORMAT_RGBA8)
	var moitie := Matieres.CARTE_TAILLE / 2
	for ligne in 2:
		for colonne in 2:
			var reponse: Array = Matieres.SURFACES[ligne * 2 + colonne]
			image.fill_rect(Rect2i(colonne * moitie, ligne * moitie, moitie, moitie), Color(float(reponse[0]), float(reponse[1]), 0.0, 1.0))
	image.generate_mipmaps()
	return ImageTexture.create_from_image(image)

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
				couleurs[i] = couleurs[i].lerp(Color(accent.r * modelage, accent.g * modelage, accent.b * modelage), Matieres.TEINTE_VARIANTE)
			elif roles[i].x > .1:
				couleurs[i] = couleurs[i].lerp(Color(teinte.r * modelage, teinte.g * modelage, teinte.b * modelage), Matieres.TEINTE_VARIANTE)
		tableaux[Mesh.ARRAY_COLOR] = couleurs
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, tableaux)
	_maillages[cle] = mesh
	return mesh
