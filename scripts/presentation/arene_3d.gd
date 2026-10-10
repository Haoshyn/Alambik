extends Node3D

const DECOR := preload("res://scripts/presentation/decor_alchimique.gd")
const SOL := preload("res://scripts/presentation/sol_alchimique.gd")
const ORNEMENTS := preload("res://scripts/presentation/ornements_monde.gd")
const STATIQUE := preload("res://scripts/presentation/decor_statique.gd")

var _bains: Array[ShaderMaterial] = []
var _rotors: Array[Node3D] = []
var _temps := 0.0

func construire(limites: Rect2, _charger: Callable, monde := 0, contour := PackedVector2Array(), variante := 0, etage := 0) -> void:
	for enfant in get_children():
		remove_child(enfant)
		enfant.queue_free()
	_bains.clear()
	_rotors.clear()
	_temps = 0.0
	var centre := Pont3D.vers_monde(limites.get_center())
	var taille := Pont3D.vers_monde(limites.size)
	if contour.is_empty():
		contour = PackedVector2Array([limites.position,Vector2(limites.end.x,limites.position.y),limites.end,Vector2(limites.position.x,limites.end.y)])
	var sol := Node3D.new()
	sol.name = "SolJouable"
	add_child(sol)
	SOL.construire(sol, contour, limites, monde, variante, etage)
	STATIQUE.regrouper(sol)
	var decor := Node3D.new()
	decor.name = "AtelierDuMonde"
	add_child(decor)
	var fond := DECOR.bloc(decor, centre + Vector3(0,-1.05,0), Vector3(taille.x+30,.1,taille.z+30), DecorsMondes.couleur(monde,"dehors"))
	fond.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_bordure(decor, contour, monde, variante)
	ORNEMENTS.construire(decor, centre, taille, monde, variante, contour, etage)
	for noeud: Node in decor.find_children("*", "Node3D", true, false):
		if noeud.has_meta("mobile_decor"):
			_rotors.append(noeud as Node3D)
			STATIQUE.regrouper(noeud as Node3D)
		if noeud is MeshInstance3D:
			var mat := (noeud as MeshInstance3D).material_override as ShaderMaterial
			if mat != null and mat.shader == ORNEMENTS.BAIN: _bains.append(mat)
	STATIQUE.regrouper(decor)

func _bordure(parent: Node3D, contour: PackedVector2Array, monde: int, variante: int) -> void:
	var mur := DecorsMondes.couleur(monde,"mur")
	var accent := DecorsMondes.couleur(monde,"accent")
	var aire := 0.0
	for i in contour.size(): aire += contour[i].cross(contour[(i+1)%contour.size()])
	var numero_segment := 0
	for i in contour.size():
		var a := Pont3D.vers_monde(contour[i])
		var b := Pont3D.vers_monde(contour[(i+1)%contour.size()])
		var direction := (b-a).normalized()
		var dehors := Vector3(direction.z,0,-direction.x) * (1.0 if aire > 0.0 else -1.0)
		var longueur := a.distance_to(b)
		var angle := -atan2(direction.z,direction.x)
		# La tranche suit aussi les rentrants : la limite visuelle est la collision.
		var tranche := DECOR.bloc(parent,(a+b)*.5+Vector3(0,-.31,0),Vector3(longueur+.025,.62,.26),mur.darkened(.25))
		tranche.rotation.y = angle
		var email := DECOR.bloc(parent,(a+b)*.5+dehors*.10+Vector3(0,-.015,0),Vector3(longueur+.025,.10,.32),accent)
		email.rotation.y = angle
		var filet := DECOR.bloc(parent,(a+b)*.5+dehors*.015+Vector3(0,.04,0),Vector3(longueur+.025,.025,.045),DecorsMondes.CUIVRE)
		filet.rotation.y = angle
		# Les petits arcs gardent une frise continue, sans couvert de largeur negative.
		if longueur < .20: continue
		var morceaux := maxi(1, ceili(longueur/1.8))
		# Murs continus : la salle est cadree comme une arene. Le premier plan,
		# tourne vers la camera, reste bas pour ne rien masquer du jeu.
		var face_camera := dehors.z > .5
		for j in morceaux:
			var position_bord := a.lerp(b,(float(j)+.5)/morceaux)
			var haut := TerrainsMondes.muret_visible(variante,numero_segment)
			var hauteur := .20 if face_camera else (.62 if haut else .46)
			var bord := DECOR.bloc(parent,position_bord+dehors*.19+Vector3(0,hauteur*.5,0),Vector3(longueur/morceaux+.01,hauteur,.34),mur)
			bord.rotation.y = angle
			var couronne := DECOR.bloc(parent,position_bord+dehors*.20+Vector3(0,hauteur+.03,0),Vector3(longueur/morceaux+.03,.06,.38),accent)
			couronne.rotation.y = angle
			var liseret := DECOR.bloc(parent,position_bord+dehors*.20+Vector3(0,hauteur+.065,0),Vector3(longueur/morceaux+.03,.012,.08),DecorsMondes.CUIVRE)
			liseret.rotation.y = angle
			numero_segment += 1
	_piliers(parent, contour, aire, mur, accent)

func _piliers(parent: Node3D, contour: PackedVector2Array, aire: float, mur: Color, accent: Color) -> void:
	# Un pilier serti a chaque angle marque les contours de la salle.
	for i in contour.size():
		var precedent := Pont3D.vers_monde(contour[(i-1+contour.size())%contour.size()])
		var point := Pont3D.vers_monde(contour[i])
		var suivant := Pont3D.vers_monde(contour[(i+1)%contour.size()])
		var entrant := (point-precedent).normalized()
		var sortant := (suivant-point).normalized()
		if entrant.dot(sortant) > .94 or point.distance_to(precedent) < .6 or point.distance_to(suivant) < .6: continue
		var dehors := (Vector3(entrant.z,0,-entrant.x)+Vector3(sortant.z,0,-sortant.x)).normalized() * (1.0 if aire > 0.0 else -1.0)
		var centre := point+dehors*.34
		var hauteur := .26 if dehors.z > .5 else .82
		var fut := DECOR.bloc(parent,centre+Vector3(0,hauteur*.5,0),Vector3(.44,hauteur,.44),mur.darkened(.08))
		fut.rotation.y = -atan2(sortant.z,sortant.x)
		var chapiteau := DECOR.bloc(parent,centre+Vector3(0,hauteur+.05,0),Vector3(.54,.1,.54),accent)
		chapiteau.rotation.y = fut.rotation.y
		var gemme := DECOR.bloc(parent,centre+Vector3(0,hauteur+.13,0),Vector3(.18,.08,.18),DecorsMondes.CUIVRE)
		gemme.rotation.y = fut.rotation.y + PI*.25

func avancer_ambiance(delta: float, effets_reduits: bool) -> void:
	if effets_reduits: return
	_temps += delta
	for mat in _bains: mat.set_shader_parameter("temps", _temps)
	for rotor in _rotors: rotor.rotation.z = _temps * .21
