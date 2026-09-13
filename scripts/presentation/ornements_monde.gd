extends RefCounted

const DECOR := preload("res://scripts/presentation/decor_alchimique.gd")

static func cylindre(parent: Node3D, position: Vector3, rayon: float, hauteur: float, teinte: Color, facettes := 12, sommet := -1.0) -> void:
	var objet := MeshInstance3D.new()
	var forme := CylinderMesh.new()
	forme.bottom_radius = rayon
	forme.top_radius = rayon if sommet < 0.0 else sommet
	forme.height = hauteur
	forme.radial_segments = facettes
	objet.mesh = forme
	var mat := StandardMaterial3D.new()
	mat.albedo_color = teinte
	mat.roughness = 0.78
	objet.material_override = mat
	objet.position = position
	parent.add_child(objet)

static func pilier(parent: Node3D, position: Vector3, monde: int) -> void:
	var ensemble := Node3D.new()
	parent.add_child(ensemble)
	ensemble.position = position
	var mur := DecorsMondes.couleur(monde,"mur")
	var accent := DecorsMondes.couleur(monde,"accent")
	var forme := int(DecorsMondes.profil(monde)["forme"])
	match forme:
		0:
			cylindre(ensemble,Vector3(0,.35,0),.36,.7,mur)
			cylindre(ensemble,Vector3(0,.76,0),.42,.12,Color("bd915e"))
			cylindre(ensemble,Vector3(0,1.03,0),.25,.42,accent,12,.17)
			cylindre(ensemble,Vector3(0,1.30,0),.12,.14,Color("bd915e"))
		1:
			DECOR.bloc(ensemble,Vector3(0,.45,0),Vector3(.65,.9,.65),mur)
			DECOR.bloc(ensemble,Vector3(0,.94,0),Vector3(.77,.16,.77),accent)
			DECOR.bloc(ensemble,Vector3(0,1.16,0),Vector3(.38,.30,.38),mur)
		2:
			cylindre(ensemble,Vector3(0,.6,0),.48,1.2,mur,5,.07)
			cylindre(ensemble,Vector3(.32,.3,.15),.23,.6,accent,5,0.0)
		3:
			cylindre(ensemble,Vector3(0,.48,0),.23,.96,mur,8)
			for y in [.18,.8,1.08]:
				cylindre(ensemble,Vector3(0,y,0),.40,.10,accent,16)
		4:
			for i in 3:
				DECOR.bloc(ensemble,Vector3(0,.18+i*.3,0),Vector3(.85-i*.17,.3,.85-i*.17),mur)
			DECOR.bloc(ensemble,Vector3(0,.66,.28),Vector3(.14,.3,.025),accent)

static func jardin(parent: Node3D, position: Vector3, monde: int) -> void:
	var vert := DecorsMondes.couleur(monde,"detail")
	for i in 3:
		cylindre(parent,position+Vector3((i-1)*.28,.22,0),.30,.44,vert.lightened(i*.035),7,.12)
	DECOR.bloc(parent,position+Vector3(0,.06,0),Vector3(1.1,.12,.65),DecorsMondes.couleur(monde,"mur"))

static func entree(parent: Node3D, position: Vector3, monde: int) -> void:
	var ensemble := Node3D.new()
	parent.add_child(ensemble)
	ensemble.position = position
	var mur := DecorsMondes.couleur(monde,"mur")
	var accent := DecorsMondes.couleur(monde,"accent")
	for cote in [-1.0,1.0]:
		DECOR.bloc(ensemble,Vector3(cote*1.6,.7,0),Vector3(.55,1.4,.6),mur)
		DECOR.bloc(ensemble,Vector3(cote*1.6,.75,.32),Vector3(.30,1.05,.055),accent)
		pilier(ensemble,Vector3(cote*2.3,0,.15),monde)
	if int(DecorsMondes.profil(monde)["forme"]) in [0,3]:
		for i in 9:
			var angle := float(i)/8.0*PI
			var morceau := DECOR.bloc(ensemble,Vector3(cos(angle)*1.6,1.4+sin(angle)*1.3,0),Vector3(.6,.48,.6),mur)
			morceau.rotation.z = angle+PI*.5
	else:
		DECOR.bloc(ensemble,Vector3(0,1.6,0),Vector3(3.8,.45,.65),mur)
		DECOR.bloc(ensemble,Vector3(0,1.87,0),Vector3(2.4,.12,.7),accent)
