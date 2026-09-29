extends RefCounted

const DECOR := preload("res://scripts/presentation/decor_alchimique.gd")

static func construire(parent: Node3D, monde: int, famille: int) -> void:
	var palette: Array = DecorsMondes.profil(monde)["parure"]
	var couleurs: Array[Color] = []
	for teinte: String in palette: couleurs.append(Color(teinte))
	match famille:
		0: _lanterne(parent, couleurs)
		1: _etabli(parent, monde, couleurs)
		2: _massif(parent, monde, couleurs)

static func habiller_couvert(parent: Node3D, taille: Vector3, monde: int, variante: int, type: String) -> void:
	if type not in ["muret", "rocher"]: return
	var longitudinal := taille.x >= taille.z
	var longueur := maxf(taille.x, taille.z)
	var profondeur := minf(taille.x, taille.z)
	var nombre := clampi(floori(longueur/1.25), 1, 3)
	var pas := longueur*.82/nombre
	var echelle := minf(.62, minf(pas,profondeur*.84)/1.30)
	# Les petits volumes restent sur l'obstacle physique, avec leur vraie emprise.
	for i in nombre:
		var decalage := ((i+.5)/nombre-.5)*longueur*.82
		var position := Vector3(decalage,1.10,0) if longitudinal else Vector3(0,1.10,decalage)
		if type == "rocher": position.y = .83
		var ornement := _ensemble(parent, position, echelle)
		ornement.name = "ParureCouvert"
		if not longitudinal: ornement.rotation.y = PI*.5
		construire(ornement, monde, 0 if posmod(i+variante,2)==0 else 2)

static func _ensemble(parent: Node3D, position: Vector3, echelle := 1.0) -> Node3D:
	var ensemble := Node3D.new()
	parent.add_child(ensemble)
	ensemble.position = position
	ensemble.scale = Vector3.ONE * echelle
	return ensemble

static func _lueur(objet: MeshInstance3D, couleur: Color) -> void:
	# Le verre peint brille sans ajouter de lumiere dynamique sur mobile.
	var mat := objet.material_override as StandardMaterial3D
	mat.albedo_color = couleur
	mat.roughness = .35
	mat.emission_enabled = true
	mat.emission = couleur
	mat.emission_energy_multiplier = .38
	objet.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

static func _lanterne(parent: Node3D, couleurs: Array[Color]) -> void:
	DECOR.cylindre(parent, Vector3(0,.08,0), .34, .16, couleurs[0], .28, 8)
	DECOR.cylindre(parent, Vector3(0,.36,0), .11, .45, DecorsMondes.CUIVRE, .085, 8)
	DECOR.cylindre(parent, Vector3(0,.62,0), .39, .10, DecorsMondes.CUIVRE, .32, 8)
	var coeur := DECOR.boule(parent, Vector3(0,.91,0), Vector3(.56,.63,.56), couleurs[3])
	_lueur(coeur, couleurs[3])
	for i in 4:
		var angle := PI * .25 + i * PI * .5
		var position := Vector3(cos(angle)*.28,0,sin(angle)*.28)
		DECOR.tige(parent, position + Vector3(0,.64,0), position + Vector3(0,1.20,0), .028, DecorsMondes.CUIVRE)
	DECOR.cylindre(parent, Vector3(0,1.23,0), .39, .18, couleurs[0], .10, 8)
	DECOR.anneau(parent, Vector3(0,1.35,0), .10, .025, DecorsMondes.CUIVRE)

static func _etabli(parent: Node3D, monde: int, couleurs: Array[Color]) -> void:
	for x: float in [-.43,.43]:
		for z: float in [-.35,.35]:
			DECOR.bloc(parent, Vector3(x,.25,z), Vector3(.10,.50,.10), DecorsMondes.CUIVRE)
	DECOR.bloc(parent, Vector3(0,.54,0), Vector3(1.16,.16,1.02), couleurs[0])
	DECOR.bloc(parent, Vector3(0,.63,0), Vector3(1.04,.035,.90), couleurs[2])
	match monde:
		0, 2:
			for i in 3:
				var fiole := _ensemble(parent, Vector3((i-1)*.33,.66,(-.16 if i%2==0 else .20)), .48 if i != 1 else .65)
				DECOR.fiole(fiole, couleurs[3] if i%2==0 else couleurs[1])
		1:
			for cote: float in [-1.0,1.0]:
				var jarre := _ensemble(parent, Vector3(cote*.29,.66,0), .70 if cote < 0 else .55)
				DECOR.vasque(jarre, Vector3.ZERO, PackedVector2Array([Vector2(.24,0),Vector2(.35,.12),Vector2(.39,.49),Vector2(.26,.69),Vector2(.23,.84)]), couleurs[1])
				DECOR.cylindre(jarre, Vector3(0,.86,0), .27, .08, DecorsMondes.CUIVRE)
				DECOR.anneau(jarre, Vector3(0,.32,0), .38, .027, DecorsMondes.CUIVRE)
		3:
			DECOR.tige(parent, Vector3(0,.65,0), Vector3(0,1.47,0), .04, DecorsMondes.CUIVRE)
			DECOR.tige(parent, Vector3(-.38,1.43,0), Vector3(.38,1.43,0), .03, DecorsMondes.CUIVRE)
			for i in 3:
				var hauteur := .28 + i*.12
				DECOR.tige(parent, Vector3((i-1)*.29,1.42,0), Vector3((i-1)*.29,1.28-hauteur,0), .014, DecorsMondes.CUIVRE)
				DECOR.cylindre(parent, Vector3((i-1)*.29,1.10-hauteur*.5,0), .055, hauteur, couleurs[3], .04, 8)
		4:
			for i in 3:
				var lingot := DECOR.bloc(parent, Vector3((i%2)*.20-.10,.75+i*.15,-.12), Vector3(.63,.15,.32), couleurs[1] if i%2==0 else DecorsMondes.CUIVRE)
				lingot.rotation.y = (i-1)*.18
			DECOR.tige(parent, Vector3(-.40,.70,.30), Vector3(.18,.74,.30), .033, DecorsMondes.CUIVRE)
			DECOR.bloc(parent, Vector3(.25,.77,.30), Vector3(.27,.18,.23), couleurs[0])

static func _massif(parent: Node3D, monde: int, couleurs: Array[Color]) -> void:
	DECOR.vasque(parent, Vector3.ZERO, PackedVector2Array([Vector2(.39,0),Vector2(.60,.12),Vector2(.65,.26),Vector2(.59,.33),Vector2(.46,.16)]), couleurs[0])
	match monde:
		0, 4:
			for i in 3:
				var cristal := _cristal(parent, Vector3((i-1)*.30,.16,(.18 if i==1 else -.10)), .54+i*.15, couleurs[3] if monde == 0 else couleurs[2])
				cristal.rotation.z = (i-1)*-.18
				_lueur(cristal, couleurs[3] if monde == 0 else couleurs[2])
		1:
			for i in 3:
				var position := Vector3((i-1)*.32,.17,(.17 if i==1 else -.11))
				var hauteur := .30 + i*.13
				DECOR.cylindre(parent, position+Vector3(0,hauteur*.5,0), .08, hauteur, DecorsMondes.PAPIER, .055, 8)
				var chapeau := DECOR.boule(parent, position+Vector3(0,hauteur,0), Vector3(.55,.24,.52), couleurs[1] if i%2==0 else couleurs[2])
				chapeau.rotation.z = (i-1)*.12
				DECOR.boule(parent, position+Vector3(-.08,hauteur+.105,.02), Vector3(.11,.035,.11), DecorsMondes.PAPIER)
		2:
			for i in 3:
				var depart := Vector3((i-1)*.28,.19,(.18 if i==1 else -.08))
				var coude := depart + Vector3((i-1)*.07,.29+i*.09,0)
				DECOR.tige(parent, depart, coude, .055, couleurs[2])
				for cote: float in [-1.0,1.0]:
					var pointe := coude + Vector3(cote*.17,.15,.04)
					DECOR.tige(parent, coude, pointe, .037, couleurs[2])
					DECOR.boule(parent, pointe, Vector3.ONE*.10, couleurs[1])
			var perle := DECOR.boule(parent, Vector3(.22,.24,.34), Vector3.ONE*.21, couleurs[3])
			_lueur(perle, couleurs[3])
		3:
			for i in 3:
				DECOR.boule(parent, Vector3((i-1)*.29,.32+(i%2)*.07,0), Vector3(.65,.29,.60), couleurs[1])
			DECOR.tige(parent, Vector3(0,.20,0), Vector3(0,.98,0), .032, DecorsMondes.CUIVRE)
			var perle := DECOR.boule(parent, Vector3(0,1.03,0), Vector3.ONE*.23, couleurs[3])
			_lueur(perle, couleurs[3])
			DECOR.anneau(parent, Vector3(0,.99,0), .25, .025, DecorsMondes.CUIVRE)

static func _cristal(parent: Node3D, position: Vector3, hauteur: float, couleur: Color) -> MeshInstance3D:
	var base := PackedVector3Array()
	var ceinture := PackedVector3Array()
	for i in 6:
		var angle := i*TAU/6.0
		base.append(Vector3(cos(angle)*.14,0,sin(angle)*.14))
		ceinture.append(Vector3(cos(angle)*.19,hauteur*.67,sin(angle)*.19))
	var pointe := Vector3(.04,hauteur,-.025)
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(-1)
	for i in 6:
		var j := (i+1)%6
		for point: Vector3 in [base[i],ceinture[j],ceinture[i],base[i],base[j],ceinture[j],ceinture[i],ceinture[j],pointe]:
			surface.set_uv(Vector2(point.x/.4+.5,point.y/hauteur))
			surface.set_color(Color(.80,.80,.80) if point.y < hauteur*.1 else Color.WHITE)
			surface.add_vertex(point)
	surface.generate_normals()
	return DECOR.piece(parent, surface.commit(), position, couleur, .40)
