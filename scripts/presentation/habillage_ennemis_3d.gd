extends RefCounted

static func appliquer(modele: Node3D, donnees: Dictionary) -> void:
	if str(donnees.get("cerveau", "")) == "boss": return
	var monde := int(donnees.get("monde_visuel", 0))
	var teinte: Color = BestiaireMondes.COULEURS[monde]
	_teinter(modele, teinte)
	modele.scale *= BestiaireMondes.ECHELLES[monde]
	var accent := StandardMaterial3D.new()
	accent.albedo_color = BestiaireMondes.ACCENTS[monde]
	accent.metallic = .30
	accent.roughness = .45
	var corps := StandardMaterial3D.new()
	corps.albedo_color = teinte
	corps.roughness = .65
	var parure := Node3D.new()
	parure.name = "IdentiteDuMonde"
	modele.add_child(parure)
	var costaud := str(donnees.get("categorie", "")) == "costaud"
	var hauteur := .85 if costaud else .60
	match monde:
		0:
			# Une collerette de feuillets et une pointe d'encre : silhouette etroite.
			for cote in [-1.0, 1.0]:
				_piece(parure, _prisme(Vector3(.30,.65,.08)), accent, Vector3(cote*.30,hauteur,0), Vector3(0,0,cote*.40))
			_piece(parure, _pointe(.20,.60), corps, Vector3(0,hauteur+.35,0))
		1:
			# Plaques basses, larges et deux cornes : creatures minerales.
			for cote in [-1.0, 1.0]:
				_piece(parure, _boite(Vector3(.42,.34,.48)), corps, Vector3(cote*.33,hauteur-.12,0), Vector3(0,cote*.25,cote*.15))
				_piece(parure, _pointe(.14,.40), accent, Vector3(cote*.29,hauteur+.25,0), Vector3(0,0,-cote*.30))
		2:
			# Deux nageoires et une crete dorsale, avec un volume plus allonge.
			for cote in [-1.0, 1.0]:
				_piece(parure, _prisme(Vector3(.48,.48,.06)), accent, Vector3(cote*.34,hauteur,-.10), Vector3(.20,0,cote*1.0))
			_piece(parure, _prisme(Vector3(.09,.55,.65)), corps, Vector3(0,hauteur+.20,-.22))
		3:
			# Ailes ajourees et anneau suspendu : le contour reste ouvert.
			for cote in [-1.0, 1.0]:
				for plume in 2:
					_piece(parure, _prisme(Vector3(.16,.72,.07)), accent, Vector3(cote*(.34+plume*.16),hauteur,-plume*.14), Vector3(0,0,-cote*.85))
			_piece(parure, _anneau(.24,.30), corps, Vector3(0,hauteur+.45,0))
		4:
			# Colonne de scories et trois flammes solides, lisibles sans particules.
			for i in 3:
				var cote := float(i-1)
				_piece(parure, _pointe(.14,.62-absf(cote)*.16), accent, Vector3(cote*.23,hauteur+.23,0), Vector3(0,0,-cote*.25))
			_piece(parure, _anneau(.27,.37), corps, Vector3(0,hauteur-.16,0))
	# La capacite se reconnait aussi a son accessoire, independamment du monde.
	if str(donnees["cerveau"]) == "artilleur":
		_piece(parure, _anneau(.15,.23), accent, Vector3(0,hauteur+.48,.12), Vector3(.35,0,0))
	elif str(donnees["cerveau"]) in ["sentinelle", "harceleur"]:
		_piece(parure, _prisme(Vector3(.12,.15,.65)), accent, Vector3(0,hauteur,.42), Vector3(PI/2,0,0))

static func _teinter(noeud: Node, couleur: Color) -> void:
	if noeud is MeshInstance3D:
		var instance := noeud as MeshInstance3D
		if instance.mesh != null:
			for surface in instance.mesh.get_surface_count():
				var original := instance.get_active_material(surface) as BaseMaterial3D
				if original != null:
					var matiere := original.duplicate() as BaseMaterial3D
					matiere.albedo_color = matiere.albedo_color.lerp(couleur, .72)
					instance.set_surface_override_material(surface, matiere)
	for enfant in noeud.get_children(): _teinter(enfant, couleur)

static func _piece(parent: Node3D, forme: Mesh, matiere: Material, point: Vector3, orientation := Vector3.ZERO) -> void:
	var piece := MeshInstance3D.new()
	piece.mesh = forme
	piece.material_override = matiere
	piece.position = point
	piece.rotation = orientation
	piece.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(piece)

static func _prisme(taille: Vector3) -> PrismMesh:
	var forme := PrismMesh.new()
	forme.size = taille
	return forme

static func _boite(taille: Vector3) -> BoxMesh:
	var forme := BoxMesh.new()
	forme.size = taille
	return forme

static func _pointe(rayon: float, hauteur: float) -> CylinderMesh:
	var forme := CylinderMesh.new()
	forme.top_radius = 0.0
	forme.bottom_radius = rayon
	forme.height = hauteur
	forme.radial_segments = 6
	return forme

static func _anneau(interieur: float, exterieur: float) -> TorusMesh:
	var forme := TorusMesh.new()
	forme.inner_radius = interieur
	forme.outer_radius = exterieur
	forme.rings = 16
	forme.ring_segments = 6
	return forme
