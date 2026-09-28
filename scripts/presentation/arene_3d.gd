extends Node3D

const DECOR := preload("res://scripts/presentation/decor_alchimique.gd")
const SOL := preload("res://scripts/presentation/sol_alchimique.gd")
const ORNEMENTS := preload("res://scripts/presentation/ornements_monde.gd")
const STATIQUE := preload("res://scripts/presentation/decor_statique.gd")

var _bains: Array[ShaderMaterial] = []
var _rotors: Array[Node3D] = []
var _temps := 0.0

func construire(limites: Rect2, _charger: Callable, monde := 0, contour := PackedVector2Array(), variante := 0) -> void:
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
	SOL.construire(sol, contour, limites, monde, variante)
	STATIQUE.regrouper(sol)
	var decor := Node3D.new()
	decor.name = "AtelierDuMonde"
	add_child(decor)
	var fond := DECOR.bloc(decor, centre + Vector3(0,-1.05,0), Vector3(taille.x+30,.1,taille.z+30), DecorsMondes.couleur(monde,"dehors"))
	fond.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_bordure(decor, contour, monde, variante)
	ORNEMENTS.construire(decor, centre, taille, monde, variante)
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
		var morceaux := maxi(1, ceili(longueur/1.8))
		for j in morceaux:
			var position_bord := a.lerp(b,(float(j)+.5)/morceaux)
			if TerrainsMondes.muret_visible(variante,numero_segment):
				var bord := DECOR.bloc(parent,position_bord+dehors*.13+Vector3(0,.16,0),Vector3(longueur/morceaux-.08,.28,.27),mur)
				bord.rotation.y = angle
				var couronne := DECOR.bloc(parent,position_bord+dehors*.13+Vector3(0,.32,0),Vector3(longueur/morceaux-.06,.055,.32),accent)
				couronne.rotation.y = angle
			else:
				var agrafe := DECOR.bloc(parent,position_bord+dehors*.10+Vector3(0,.05,0),Vector3(.075,.035,.31),DecorsMondes.CUIVRE)
				agrafe.rotation.y = angle
			numero_segment += 1

func avancer_ambiance(delta: float, effets_reduits: bool) -> void:
	if effets_reduits: return
	_temps += delta
	for mat in _bains: mat.set_shader_parameter("temps", _temps)
	for rotor in _rotors: rotor.rotation.z = _temps * .21
