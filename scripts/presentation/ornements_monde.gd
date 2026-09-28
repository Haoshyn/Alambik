extends RefCounted

const DECOR := preload("res://scripts/presentation/decor_alchimique.gd")
const BAIN := preload("res://shaders/bain_alchimique.gdshader")

static func _ensemble(parent: Node3D, nom: String, position := Vector3.ZERO) -> Node3D:
	var ensemble := Node3D.new()
	ensemble.name = nom
	parent.add_child(ensemble)
	ensemble.position = position
	return ensemble

static func construire(parent: Node3D, centre: Vector3, taille: Vector3, monde: int, variante: int) -> void:
	var mur := DecorsMondes.couleur(monde, "mur")
	var accent := DecorsMondes.couleur(monde, "accent")
	# Rien de haut en aval : sa projection masquerait le heros et les tirs.
	for cote: float in [-1.0, 1.0]:
		var x := cote * (taille.x * .5 + 1.0)
		for i in 3:
			var p := centre + Vector3(x, -.12, (i - 1) * taille.z * .32)
			var atelier := _ensemble(parent, "AtelierLateral", p)
			atelier.scale = Vector3.ONE * .67
			atelier.rotation.y = .12 * cote
			if (i + variante + int(cote)) % 2 == 0:
				_repere(atelier, monde)
			else:
				_accessoires(atelier, monde, variante + i)
			DECOR.bloc(parent, p + Vector3(0,-.42,0), Vector3(1.7,.84,2.0), mur.darkened(.20))
		var canal := centre + Vector3(cote * (taille.x * .5 + .37), -.24, 0)
		DECOR.bloc(parent, canal, Vector3(.48,.16,taille.z*.96), mur.darkened(.30))
		if monde in [0, 2, 4]:
			var bain := DECOR.bloc(parent, canal + Vector3(0,.09,0), Vector3(.27,.025,taille.z*.94), accent)
			_liquide(bain, monde)
		else:
			DECOR.tige(parent, canal + Vector3(0,.1,-taille.z*.47), canal + Vector3(0,.1,taille.z*.47), .075, DecorsMondes.CUIVRE)
		for i in 4:
			var p := centre + Vector3(cote * (taille.x * .5 + 2.3), -.55, (i - 1.5) * taille.z * .25)
			_abords(parent, p, monde, i + variante)
	var signature := _ensemble(parent, "SignatureMonde", centre + Vector3(0,-.05,-taille.z*.5-2.1))
	signature.set_meta("monde", monde)
	signature.scale = Vector3.ONE * 1.35
	_repere(signature, monde)
	for cote: float in [-1.0, 1.0]:
		var aile := _ensemble(parent, "AileAtelier", centre + Vector3(cote*3.1,0,-taille.z*.5-.85))
		DECOR.bloc(aile, Vector3(0,.12,0), Vector3(1.7,.24,1.25), mur.darkened(.2))
		_accessoires(aile, monde, variante)

static func _liquide(objet: MeshInstance3D, monde: int) -> void:
	var mat := ShaderMaterial.new()
	mat.shader = BAIN
	var teinte := DecorsMondes.couleur(monde, "liquide")
	mat.set_shader_parameter("teinte", teinte)
	objet.material_override = mat
	objet.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

static func _repere(parent: Node3D, monde: int) -> void:
	match monde:
		0: _scriptorium(parent)
		1: _distillerie(parent)
		2: _fontaine(parent)
		3: _soufflerie(parent)
		4: _fourneau(parent)

static func _livre(parent: Node3D, position: Vector3, taille: Vector3, teinte: Color, angle := 0.0) -> void:
	var livre := _ensemble(parent, "Grimoire", position)
	livre.rotation.y = angle
	DECOR.bloc(livre, Vector3.ZERO, taille * Vector3(.92,.68,.9), DecorsMondes.PAPIER)
	for cote: float in [-1.0, 1.0]:
		DECOR.bloc(livre, Vector3(0,cote*taille.y*.42,0), Vector3(taille.x,taille.y*.18,taille.z), teinte)
	DECOR.bloc(livre, Vector3(-taille.x*.46,0,0), Vector3(taille.x*.12,taille.y,taille.z), teinte)
	for cote: float in [-1.0, 1.0]:
		DECOR.bloc(livre, Vector3(-taille.x*.49,0,cote*taille.z*.30), Vector3(taille.x*.14,taille.y*1.06,.08), DecorsMondes.CUIVRE)
	DECOR.bloc(livre, Vector3(taille.x*.28,taille.y*.52,.02), Vector3(.13,.025,taille.z*.7), DecorsMondes.CUIVRE)

static func _scriptorium(parent: Node3D) -> void:
	var encre := DecorsMondes.couleur(0, "accent")
	DECOR.cylindre(parent, Vector3(0,.10,0), .85, .20, DecorsMondes.ENCRE, .77, 8)
	DECOR.vasque(parent, Vector3.ZERO, PackedVector2Array([Vector2(.54,.2),Vector2(.70,.35),Vector2(.65,.8),Vector2(.4,1.05),Vector2(.38,1.22)]), encre)
	DECOR.anneau(parent, Vector3(0,1.17,0), .41, .065, DecorsMondes.CUIVRE)
	var bain := DECOR.cylindre(parent, Vector3(0,1.13,0), .35, .03, encre)
	_liquide(bain, 0)
	DECOR.tige(parent, Vector3(.05,1.13,0), Vector3(.72,3.10,-.1), .04, DecorsMondes.CUIVRE)
	var plume := DECOR.feuille(parent, Vector3(.29,1.66,-.05), Vector3(1.0,1.65,.5), DecorsMondes.PAPIER)
	plume.rotation.z = -.34
	var pointe := DECOR.feuille(parent, Vector3(.29,1.67,-.015), Vector3(.35,1.45,.5), encre.lightened(.28))
	pointe.rotation.z = -.34
	for i in 3:
		_livre(parent, Vector3(-.59,.16+i*.3,.6), Vector3(1.25,.27,.83), DecorsMondes.couleur(0,"mur") if i % 2 == 0 else encre, -.16+i*.15)
	var ouvert := _ensemble(parent, "PagesOuvertes", Vector3(-.59,1.10,.59))
	for cote: float in [-1.0, 1.0]:
		var page := _ensemble(ouvert, "Page", Vector3(cote*.32,0,0))
		page.rotation.z = cote * -.20
		DECOR.bloc(page, Vector3(0,-.04,0), Vector3(.65,.06,.87), encre)
		DECOR.bloc(page, Vector3.ZERO, Vector3(.58,.08,.79), DecorsMondes.PAPIER)
		for i in 3: DECOR.bloc(page, Vector3(0,.045,(i-1)*.16), Vector3(.36,.012,.025), DecorsMondes.CUIVRE)

static func _plante(parent: Node3D, position: Vector3, monde: int, ampleur := 1.0) -> void:
	var plante := _ensemble(parent, "HerbesAlchimiques", position)
	plante.scale = Vector3.ONE * ampleur
	var vert := DecorsMondes.couleur(monde, "detail")
	DECOR.vasque(plante, Vector3.ZERO, PackedVector2Array([Vector2(.23,0),Vector2(.35,.38),Vector2(.39,.41),Vector2(.39,.48),Vector2(.3,.48)]), DecorsMondes.couleur(1,"mur"))
	DECOR.cylindre(plante, Vector3(0,.45,0), .3, .02, DecorsMondes.ENCRE)
	for i in 5:
		var pousse := _ensemble(plante, "Pousse", Vector3(0,.45,0))
		pousse.rotation.y = float(i) * TAU / 5.0
		pousse.rotation.x = .40 + (i % 2) * .3
		DECOR.feuille(pousse, Vector3.ZERO, Vector3(.57,1.1+(i%2)*.18,.7), vert.lightened((i%3)*.05))

static func _distillerie(parent: Node3D) -> void:
	var vert := DecorsMondes.couleur(1, "accent")
	for cote: float in [-1.0, 1.0]:
		DECOR.tige(parent, Vector3(cote*.56,.03,.23), Vector3(cote*.34,.72,0), .09, DecorsMondes.CUIVRE)
	DECOR.vasque(parent, Vector3(0,.25,0), PackedVector2Array([Vector2(.2,0),Vector2(.53,.12),Vector2(.67,.55),Vector2(.58,.95),Vector2(.31,1.18),Vector2(.25,1.42)]), vert)
	DECOR.anneau(parent, Vector3(0,.84,0), .66, .045, DecorsMondes.CUIVRE)
	DECOR.anneau(parent, Vector3(0,1.63,0), .27, .055, DecorsMondes.CUIVRE)
	DECOR.boule(parent, Vector3(-.22,1.0,.52), Vector3(.11,.39,.03), DecorsMondes.REFLET)
	DECOR.tuyau(parent, PackedVector3Array([Vector3(0,1.67,0),Vector3(0,2.08,0),Vector3(.25,2.28,0),Vector3(.86,2.28,0),Vector3(1.13,2.02,0),Vector3(1.13,1.26,0)]), .085, DecorsMondes.CUIVRE)
	for i in 3: DECOR.anneau(parent, Vector3(1.13,1.42+i*.16,0), .16, .04, vert)
	var fiole := _ensemble(parent, "EssenceVegetale", Vector3(1.13,.06,0))
	fiole.scale = Vector3.ONE * .85
	DECOR.fiole(fiole, DecorsMondes.couleur(1,"liquide"), false)
	_plante(parent, Vector3(-.65,0,.56), 1, .84)
	_plante(parent, Vector3(.74,0,.75), 1, .57)

static func _fontaine(parent: Node3D) -> void:
	var mur := DecorsMondes.couleur(2,"mur")
	var eau := DecorsMondes.couleur(2,"accent")
	DECOR.cylindre(parent, Vector3(0,.12,0), .95, .24, mur.darkened(.2), .87)
	DECOR.vasque(parent, Vector3(0,.24,0), PackedVector2Array([Vector2(.72,0),Vector2(.86,.26),Vector2(.9,.36),Vector2(.77,.40),Vector2(.68,.17)]), mur.lightened(.18))
	var bain := DECOR.cylindre(parent, Vector3(0,.49,0), .76, .025, eau)
	_liquide(bain, 2)
	DECOR.cylindre(parent, Vector3(0,.94,-.48), .24, 1.38, mur, .18)
	DECOR.anneau(parent, Vector3(0,1.54,-.48), .29, .045, DecorsMondes.CUIVRE)
	for i in 5:
		var coquille := DECOR.feuille(parent, Vector3(0,1.56,-.52), Vector3(.55,1.3,.7), eau.lightened((i % 2)*.16))
		coquille.rotation.z = (i-2)*.40
		coquille.rotation.x = -.3
	DECOR.tuyau(parent, PackedVector3Array([Vector3(0,1.65,-.5),Vector3(0,1.79,-.24),Vector3(0,1.7,.12)]), .13, DecorsMondes.CUIVRE)
	var chute := DECOR.tige(parent, Vector3(0,1.64,.13), Vector3(0,.51,.32), .068, eau)
	_liquide(chute, 2)
	for i in 3: DECOR.anneau(parent, Vector3(0,.525,.29), .15+i*.13, .018, DecorsMondes.REFLET)
	var fiole := _ensemble(parent, "CollecteurMaree", Vector3(.9,.04,-.26))
	fiole.scale = Vector3.ONE * .78
	DECOR.fiole(fiole, eau)

static func _soufflerie(parent: Node3D) -> void:
	var mur := DecorsMondes.couleur(3,"mur")
	var accent := DecorsMondes.couleur(3,"accent")
	DECOR.cylindre(parent, Vector3(0,.13,0), .65, .26, mur, .53, 8)
	DECOR.cylindre(parent, Vector3(0,.9,0), .30, 1.4, mur, .18)
	for i in 3: DECOR.anneau(parent, Vector3(0,.55+i*.38,0), .31, .045, DecorsMondes.CUIVRE)
	var cadre := DECOR.anneau(parent, Vector3(0,2.03,0), 1.02, .075, DecorsMondes.CUIVRE)
	cadre.rotation.x = PI * .5
	var rotor := _ensemble(parent, "RoueDesSouffles", Vector3(0,2.03,.04))
	rotor.set_meta("mobile_decor", true)
	for i in 4:
		var pale := _ensemble(rotor, "Pale", Vector3.ZERO)
		pale.rotation.z = i * PI * .5 + .28
		DECOR.feuille(pale, Vector3(0,.13,0), Vector3(.58,.82,.62), accent if i%2 == 0 else DecorsMondes.PAPIER)
		DECOR.tige(pale, Vector3.ZERO, Vector3(0,.87,.11), .025, DecorsMondes.CUIVRE)
	DECOR.boule(parent, Vector3(0,2.03,.15), Vector3(.32,.32,.22), mur)
	DECOR.boule(parent, Vector3(0,2.03,.28), Vector3(.14,.14,.07), DecorsMondes.REFLET)
	for i in 3:
		var hauteur := 1.05 + i*.3
		DECOR.cylindre(parent, Vector3(.62+i*.21,hauteur*.5,.0), .08, hauteur, DecorsMondes.CUIVRE)
		DECOR.anneau(parent, Vector3(.62+i*.21,hauteur,0), .09, .025, accent)

static func _fourneau(parent: Node3D) -> void:
	var mur := DecorsMondes.couleur(4,"mur")
	DECOR.bloc(parent, Vector3(0,.14,0), Vector3(1.7,.28,1.4), mur.darkened(.18))
	DECOR.vasque(parent, Vector3(0,.22,0), PackedVector2Array([Vector2(.6,0),Vector2(.73,.2),Vector2(.69,.9),Vector2(.52,1.18),Vector2(.65,1.35),Vector2(.51,1.43),Vector2(.43,1.12)]), mur)
	DECOR.anneau(parent, Vector3(0,.42,0), .7, .055, DecorsMondes.CUIVRE)
	DECOR.anneau(parent, Vector3(0,1.56,0), .57, .065, DecorsMondes.CUIVRE)
	var fusion := DECOR.cylindre(parent, Vector3(0,1.51,0), .5, .04, DecorsMondes.couleur(4,"liquide"))
	_liquide(fusion, 4)
	DECOR.bloc(parent, Vector3(0,.83,.64), Vector3(.64,.52,.07), DecorsMondes.ENCRE)
	for i in 3:
		var fente := DECOR.bloc(parent, Vector3((i-1)*.18,.83,.69), Vector3(.065,.34,.025), DecorsMondes.CUIVRE)
		_liquide(fente, 4)
	for cote: float in [-1.0, 1.0]:
		DECOR.tuyau(parent, PackedVector3Array([Vector3(cote*.57,.58,0),Vector3(cote*.98,.8,0),Vector3(cote*.98,2.2,0),Vector3(cote*.81,2.42,0)]), .14, mur)
		for i in 2: DECOR.anneau(parent, Vector3(cote*.98,1.16+i*.64,0), .15, .035, DecorsMondes.CUIVRE)
		DECOR.cylindre(parent, Vector3(cote*.81,2.42,0), .16, .08, DecorsMondes.ENCRE)
	var fiole := _ensemble(parent, "FioleBraise", Vector3(.95,.1,.55))
	fiole.scale = Vector3.ONE * .56
	DECOR.fiole(fiole, DecorsMondes.couleur(4,"accent"))

static func _accessoires(parent: Node3D, monde: int, variante: int) -> void:
	var accent := DecorsMondes.couleur(monde,"accent")
	match monde:
		0:
			for i in 4: _livre(parent, Vector3(0,.16+i*.29,0), Vector3(1.45-i*.11,.27,1.0), accent if i%2 == 0 else DecorsMondes.couleur(0,"mur"), sin(i+variante)*.14)
			var fiole := _ensemble(parent, "FioleEncre", Vector3(.34,1.20,.04))
			fiole.scale = Vector3.ONE * .64
			DECOR.fiole(fiole, DecorsMondes.couleur(0,"liquide"))
		1: _plante(parent, Vector3.ZERO, 1, 1.3)
		2:
			for cote: float in [-1.0, 1.0]:
				var fiole := _ensemble(parent, "ReserveMaree", Vector3(cote*.38,0,0))
				fiole.scale = Vector3.ONE * (1.0 if cote < 0 else .73)
				DECOR.fiole(fiole, accent if cote < 0 else DecorsMondes.couleur(2,"detail"))
		3:
			DECOR.tige(parent, Vector3(0,0,0), Vector3(0,2.0,0), .055, DecorsMondes.CUIVRE)
			DECOR.cylindre(parent, Vector3(0,.12,0), .48, .24, DecorsMondes.couleur(3,"mur"), .34)
			for i in 3:
				var voile := DECOR.feuille(parent, Vector3(0,1.9-i*.38,0), Vector3(.45,.95,.7), accent if i%2 == 0 else DecorsMondes.PAPIER)
				voile.rotation.z = -PI*.57
		4:
			for i in 3:
				var lingot := DECOR.bloc(parent, Vector3((i%2)*.28,.16+i*.23,0), Vector3(.94,.23,.63), accent if i%2 == 0 else DecorsMondes.couleur(4,"mur"))
				lingot.rotation.y = (i-1)*.28
			DECOR.tige(parent, Vector3(-.55,.1,.32), Vector3(-.38,1.5,.1), .075, DecorsMondes.CUIVRE)
			DECOR.bloc(parent, Vector3(-.38,1.5,.1), Vector3(.65,.28,.3), DecorsMondes.couleur(4,"mur"))

static func _abords(parent: Node3D, position: Vector3, monde: int, variante: int) -> void:
	match monde:
		1: _plante(parent, position, 1, 1.15 + (variante%2)*.3)
		3:
			for i in 3: DECOR.boule(parent, position+Vector3((i-1)*.57,-.28,0), Vector3(1.65, .55+(i%2)*.22,1.8), DecorsMondes.couleur(3,"detail").darkened((i%2)*.05))
		_:
			var teinte := DecorsMondes.couleur(monde,"mur").darkened(.14)
			for i in 2:
				var pierre := DECOR.bloc(parent, position + Vector3(i*.47,-.05+i*.13,i*.38), Vector3(1.35,.42,1.15), teinte)
				pierre.rotation.y = (variante+i)*.63
