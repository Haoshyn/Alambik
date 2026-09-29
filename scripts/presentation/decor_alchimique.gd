extends RefCounted

const ATLAS := preload("res://assets/3d/textures/bestiaire_matieres_peintes.png")

static func pierre(taille: Vector3) -> ArrayMesh:
	var b := minf(0.09, minf(taille.x, minf(taille.y, taille.z)) * 0.18)
	var anneaux: Array[PackedVector3Array] = []
	for niveau in 4:
		var retrait := b if niveau in [0,3] else 0.0
		var x := taille.x * .5 - retrait
		var z := taille.z * .5 - retrait
		var y := [-taille.y*.5, -taille.y*.5+b, taille.y*.5-b, taille.y*.5][niveau] as float
		var coin := b
		anneaux.append(PackedVector3Array([Vector3(-x+coin,y,-z),Vector3(x-coin,y,-z),Vector3(x,y,-z+coin),Vector3(x,y,z-coin),Vector3(x-coin,y,z),Vector3(-x+coin,y,z),Vector3(-x,y,z-coin),Vector3(-x,y,-z+coin)]))
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(-1)
	for j in 3:
		for i in 8:
			var k := (i+1)%8
			for point: Vector3 in [anneaux[j][i],anneaux[j+1][k],anneaux[j+1][i],anneaux[j][i],anneaux[j][k],anneaux[j+1][k]]:
				var normale := Vector3(anneaux[j][i].x, 0, anneaux[j][i].z).normalized()
				_sommet_pierre(surface, point, taille, normale)
	for i in range(1,7):
		for point: Vector3 in [anneaux[3][0],anneaux[3][i],anneaux[3][i+1],anneaux[0][0],anneaux[0][i+1],anneaux[0][i]]:
			_sommet_pierre(surface, point, taille, Vector3.UP)
	surface.generate_normals()
	return surface.commit()

static func _sommet_pierre(surface: SurfaceTool, point: Vector3, taille: Vector3, normale: Vector3) -> void:
	var uv := Vector2(point.x / taille.x, point.z / taille.z) + Vector2.ONE * .5
	if absf(normale.y) < .5:
		uv = Vector2(point.z / taille.z if absf(normale.x) > .5 else point.x / taille.x, point.y / taille.y) + Vector2.ONE * .5
	surface.set_uv(uv)
	# Le modelage reste visible sur Android lorsque les ombres sont reduites.
	var valeur := lerpf(.72, 1.04, clampf(point.y / taille.y + .5, 0.0, 1.0))
	surface.set_color(Color(valeur, valeur, valeur))
	surface.add_vertex(point)

static func bloc(parent: Node3D, centre: Vector3, taille: Vector3, couleur: Color) -> MeshInstance3D:
	return piece(parent, pierre(taille), centre, couleur)

static func piece(parent: Node3D, forme: Mesh, position: Vector3, teinte: Color, rugosite := .82, peint := true) -> MeshInstance3D:
	var objet := MeshInstance3D.new()
	objet.mesh = forme
	var mat := StandardMaterial3D.new()
	mat.albedo_color = teinte
	mat.roughness = rugosite
	mat.metallic_specular = .22
	if peint:
		# L'atelier reprend l'atlas original du bestiaire, sans nouvelle texture par objet.
		mat.albedo_texture = ATLAS
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		mat.texture_repeat = false
		mat.uv1_scale = Vector3(.46, .46, 1)
		mat.uv1_offset = Vector3(.02, .02, 0)
		mat.vertex_color_use_as_albedo = true
	objet.material_override = mat
	objet.position = position
	parent.add_child(objet)
	return objet

static func cylindre(parent: Node3D, position: Vector3, rayon: float, hauteur: float, teinte: Color, sommet := -1.0, facettes := 16) -> MeshInstance3D:
	var forme := CylinderMesh.new()
	forme.bottom_radius = rayon
	forme.top_radius = rayon if sommet < 0.0 else sommet
	forme.height = hauteur
	forme.radial_segments = facettes
	return piece(parent, forme, position, teinte)

static func anneau(parent: Node3D, position: Vector3, rayon: float, tube: float, teinte: Color) -> MeshInstance3D:
	var forme := TorusMesh.new()
	forme.inner_radius = maxf(.01, rayon - tube)
	forme.outer_radius = rayon + tube
	forme.rings = 24
	forme.ring_segments = 6
	return piece(parent, forme, position, teinte, .55)

static func boule(parent: Node3D, position: Vector3, taille: Vector3, teinte: Color) -> MeshInstance3D:
	var forme := SphereMesh.new()
	forme.radius = .5
	forme.height = 1.0
	forme.radial_segments = 16
	forme.rings = 8
	var objet := piece(parent, forme, position, teinte, .48)
	objet.scale = taille
	return objet

static func tige(parent: Node3D, debut: Vector3, fin: Vector3, rayon: float, teinte: Color) -> MeshInstance3D:
	var direction := fin - debut
	var objet := cylindre(parent, (debut + fin) * .5, rayon, direction.length(), teinte, -1.0, 8)
	objet.basis = Basis(Quaternion(Vector3.UP, direction.normalized()))
	return objet

static func tuyau(parent: Node3D, points: PackedVector3Array, rayon: float, teinte: Color) -> void:
	for i in points.size() - 1:
		tige(parent, points[i], points[i + 1], rayon, teinte)
		if i > 0: boule(parent, points[i], Vector3.ONE * rayon * 2.05, teinte)

static func vasque(parent: Node3D, position: Vector3, profil: PackedVector2Array, teinte: Color) -> MeshInstance3D:
	# Une vraie silhouette tournee : pied, panse, epaule et col restent lisibles
	# sans transparence couteuse ni empilement de cylindres independants.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for niveau in profil.size() - 1:
		var bas := profil[niveau]
		var haut := profil[niveau + 1]
		var pente := (haut - bas).normalized()
		for i in 20:
			var a := float(i) * TAU / 20.0
			var b := float(i + 1) * TAU / 20.0
			for coin: Vector2 in [Vector2(a,0),Vector2(b,1),Vector2(a,1),Vector2(a,0),Vector2(b,0),Vector2(b,1)]:
				var point := bas if coin.y == 0.0 else haut
				surface.set_normal(Vector3(cos(coin.x) * pente.y, -pente.x, sin(coin.x) * pente.y))
				surface.set_uv(Vector2(coin.x / TAU, point.y / maxf(profil[-1].y, .01)))
				var valeur := lerpf(.78, 1.02, clampf(point.y / maxf(profil[-1].y, .01), 0.0, 1.0))
				surface.set_color(Color(valeur, valeur, valeur))
				surface.add_vertex(Vector3(cos(coin.x) * point.x, point.y, sin(coin.x) * point.x))
	return piece(parent, surface.commit(), position, teinte, .45)

static func feuille(parent: Node3D, position: Vector3, taille: Vector3, teinte: Color) -> MeshInstance3D:
	# Deux faces pliees forment une feuille ou une plume, avec une nervure claire.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(-1)
	var points := PackedVector3Array([Vector3.ZERO, Vector3(-.45,.40,.05), Vector3(0,.48,-.14), Vector3(.45,.40,.05), Vector3(0,1,.28)])
	for indice: int in [0,2,1,0,3,2,1,2,4,2,3,4,1,2,0,2,3,0,4,2,1,4,3,2]:
		surface.set_uv(Vector2(points[indice].x + .5, points[indice].y))
		var valeur := 1.08 if indice == 2 else .87
		surface.set_color(Color(valeur, valeur, valeur))
		surface.add_vertex(points[indice] * taille)
	surface.generate_normals()
	return piece(parent, surface.commit(), position, teinte)

static func fiole(parent: Node3D, teinte: Color, bouchon := true) -> void:
	vasque(parent, Vector3.ZERO, PackedVector2Array([Vector2(0,.04),Vector2(.28,.04),Vector2(.42,.18),Vector2(.46,.44),Vector2(.37,.70),Vector2(.16,.91),Vector2(.15,1.18),Vector2(.19,1.20)]), teinte)
	anneau(parent, Vector3(0,1.17,0), .17, .04, DecorsMondes.CUIVRE)
	anneau(parent, Vector3(0,.21,0), .405, .025, DecorsMondes.CUIVRE)
	if bouchon:
		cylindre(parent, Vector3(0,1.26,0), .155, .16, DecorsMondes.ENCRE, .13)
	# Le reflet peint donne du verre opaque, stable sur le rendu mobile.
	var reflet := boule(parent, Vector3(-.19,.55,.35), Vector3(.085,.31,.025), DecorsMondes.REFLET)
	reflet.rotation.z = -.22

static func obstacle(taille: Vector3, variante: int, monde := 0, type := "muret") -> Node3D:
	if type != "muret": return _obstacle_compact(taille, variante, monde, type)
	var ensemble := Node3D.new()
	var hauteur := .65
	bloc(ensemble,Vector3(0,.10,0),Vector3(taille.x,.20,taille.z),DecorsMondes.couleur(monde,"mur").darkened(.18))
	var colonnes := maxi(1, int(ceil(taille.x/1.1)))
	for i in colonnes:
		var largeur := taille.x/colonnes
		var x := -taille.x*.5+largeur*(i+.5)
		var teinte := DecorsMondes.couleur(monde,"mur") if (i+variante)%2 == 0 else DecorsMondes.couleur(monde,"mur").darkened(.06)
		bloc(ensemble,Vector3(x,.22+hauteur*.5,0),Vector3(largeur-.035,hauteur,taille.z*.92),teinte)
		bloc(ensemble,Vector3(x,.22+hauteur+.07,0),Vector3(largeur-.02,.14,taille.z*.98),DecorsMondes.couleur(monde,"accent"))
		if monde == 0:
			# Les reliures et leurs nerfs transforment le couvert en rayonnage bas.
			for j in 3:
				bloc(ensemble,Vector3(x+(j-1)*largeur*.25,.53,taille.z*.47),Vector3(.045,.55,.035),DecorsMondes.CUIVRE)
		elif monde == 2:
			tige(ensemble,Vector3(x-largeur*.35,1.0,0),Vector3(x+largeur*.35,1.0,0),.055,DecorsMondes.CUIVRE)
		elif monde == 4:
			for cote: float in [-1.0, 1.0]:
				bloc(ensemble,Vector3(x+cote*largeur*.34,.53,taille.z*.47),Vector3(.10,.58,.045),DecorsMondes.CUIVRE)
		# Un sceau cuivre et turquoise donne une fonction aux blocs de pierre.
		if (i+variante)%2 == 0:
			bloc(ensemble,Vector3(x,.58,taille.z*.465),Vector3(minf(.30,largeur*.5),.30,.055),Color("987447"))
			bloc(ensemble,Vector3(x,.58,taille.z*.47),Vector3(minf(.15,largeur*.25),.15,.035),DecorsMondes.couleur(monde,"accent"))
			var sceau := bloc(ensemble,Vector3(x,1.035,0),Vector3(.27,.04,.27),Color("b19a6b"))
			sceau.rotation.y = PI*.25
			var coeur := bloc(ensemble,Vector3(x,1.067,0),Vector3(.13,.025,.13),DecorsMondes.couleur(monde,"accent"))
			coeur.rotation.y = PI*.25
		elif monde == 1:
			for pousse in 3:
				var mousse := MeshInstance3D.new()
				var forme := SphereMesh.new()
				forme.radius = .13 + pousse*.018
				forme.height = forme.radius*2.0
				forme.radial_segments = 12
				forme.rings = 6
				mousse.mesh = forme
				mousse.scale = Vector3(1,.35,1)
				mousse.position = Vector3(x+(pousse-1)*.14,1.025,-taille.z*.18)
				var mat := StandardMaterial3D.new()
				mat.albedo_color = DecorsMondes.couleur(monde,"detail").lightened(pousse*.035)
				mat.roughness = 1.0
				mousse.material_override = mat
				ensemble.add_child(mousse)
	return ensemble

static func _obstacle_compact(taille: Vector3, variante: int, monde: int, type: String) -> Node3D:
	var ensemble := Node3D.new()
	var pierre_ := DecorsMondes.couleur(monde, "mur")
	var accent := DecorsMondes.couleur(monde, "accent")
	# Le socle signale toute l'emprise rectangulaire utilisee par les collisions
	# et les lignes de vue, y compris sous un pilier rond ou un rocher taille.
	bloc(ensemble, Vector3(0,.08,0), Vector3(taille.x,.16,taille.z), pierre_.darkened(.15))
	match type:
		"pilier":
			var appareil := Node3D.new()
			ensemble.add_child(appareil)
			appareil.position.y = .16
			appareil.scale = Vector3(taille.x*.88,.82,taille.z*.88)
			match monde:
				0, 2:
					fiole(appareil, accent)
				1:
					vasque(appareil,Vector3.ZERO,PackedVector2Array([Vector2(.25,0),Vector2(.44,.45),Vector2(.43,.66),Vector2(.34,.68)]),pierre_)
					for i in 4:
						var plante := feuille(appareil,Vector3(0,.6,0),Vector3(.42,.7,.6),DecorsMondes.couleur(1,"detail"))
						plante.rotation.y = i*PI*.5
				3:
					cylindre(appareil,Vector3(0,.47,0),.23,.94,pierre_,.17)
					for i in 3: anneau(appareil,Vector3(0,.2+i*.31,0),.37,.045,DecorsMondes.CUIVRE)
					boule(appareil,Vector3(0,1.0,0),Vector3(.42,.33,.42),accent)
				4:
					vasque(appareil,Vector3.ZERO,PackedVector2Array([Vector2(.35,0),Vector2(.44,.25),Vector2(.40,.8),Vector2(.46,.94),Vector2(.34,.94)]),pierre_)
					anneau(appareil,Vector3(0,.87,0),.43,.04,DecorsMondes.CUIVRE)
					cylindre(appareil,Vector3(0,.89,0),.34,.02,accent)
		"rocher":
			bloc(ensemble, Vector3(0,.34,0), Vector3(taille.x*.94,.42,taille.z*.90), pierre_.darkened(.08))
			bloc(ensemble, Vector3(-taille.x*.10,.66,taille.z*.06), Vector3(taille.x*.64,.30,taille.z*.65), pierre_)
			bloc(ensemble, Vector3(taille.x*.25,.49,-taille.z*.22), Vector3(taille.x*.33,.22,taille.z*.32), accent.darkened(.20))
		"caisses":
			for i in 2:
				var hauteur := .30
				var y := .18 + hauteur*.5 + i*(hauteur+.04)
				var largeur := taille.x * (1.0 if i == 0 else .76)
				var profondeur := taille.z * (1.0 if i == 0 else .78)
				# Dans le premier monde, les piles sont des livres relies.
				var teinte := Color("e0d4be") if monde == 0 else pierre_.darkened(.12)
				bloc(ensemble, Vector3(0,y,0), Vector3(largeur*.94,hauteur,profondeur*.94), teinte)
				for cote in [-1.0,1.0]:
					bloc(ensemble, Vector3(0,y+cote*hauteur*.5,0), Vector3(largeur,.045,profondeur), accent)
			if monde != 0:
				var reserve := Node3D.new()
				ensemble.add_child(reserve)
				reserve.position.y = .87
				reserve.scale = Vector3(taille.x*.5,.43,taille.z*.5)
				fiole(reserve,accent)
	return ensemble
