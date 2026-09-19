extends RefCounted

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
				surface.add_vertex(point)
	for i in range(1,7):
		for point: Vector3 in [anneaux[3][0],anneaux[3][i],anneaux[3][i+1],anneaux[0][0],anneaux[0][i+1],anneaux[0][i]]:
			surface.add_vertex(point)
	surface.generate_normals()
	return surface.commit()

static func bloc(parent: Node3D, centre: Vector3, taille: Vector3, couleur: Color) -> MeshInstance3D:
	var objet := MeshInstance3D.new()
	objet.mesh = pierre(taille)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = couleur
	mat.roughness = .88
	objet.material_override = mat
	objet.position = centre
	parent.add_child(objet)
	return objet

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
		# Un sceau cuivre et turquoise donne une fonction aux blocs de pierre.
		if (i+variante)%2 == 0:
			bloc(ensemble,Vector3(x,.58,taille.z*.465),Vector3(minf(.30,largeur*.5),.30,.055),Color("987447"))
			bloc(ensemble,Vector3(x,.58,taille.z*.50),Vector3(minf(.15,largeur*.25),.15,.035),DecorsMondes.couleur(monde,"accent"))
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
			var colonne := MeshInstance3D.new()
			var forme := CylinderMesh.new()
			forme.bottom_radius = .5
			forme.top_radius = .42
			forme.height = 1.0 + variante * .12
			forme.radial_segments = 8
			colonne.mesh = forme
			colonne.scale = Vector3(taille.x * .80, 1.0, taille.z * .80)
			colonne.position.y = .16 + forme.height * .5
			var mat := StandardMaterial3D.new()
			mat.albedo_color = pierre_
			mat.roughness = .9
			colonne.material_override = mat
			ensemble.add_child(colonne)
			bloc(ensemble, Vector3(0,.20+forme.height,0), Vector3(taille.x*.82,.12,taille.z*.82), accent)
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
	return ensemble
