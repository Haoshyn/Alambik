extends Node2D

signal tir_demande(id: String, origine: Vector2, direction: Vector2)

var id := "homoncule_encre"
var etat := "repos"
var _salle: Node2D
var _destination := Vector2.ZERO
var _reste := 0.0
var _alea := RandomNumberGenerator.new()
var _position_precedente := Vector2.ZERO

func preparer(salle: Node2D, identifiant: String, graine: int) -> void:
	_salle = salle
	id = identifiant
	_alea.seed = graine
	var limites: Rect2 = salle.limites
	global_position = limites.position + limites.size * CatalogueFamiliers.APPARITION
	# La forme de salle peut creuser ce point : chercher un vrai emplacement au sol.
	if not _point_valide(global_position):
		for ligne in range(1, 10):
			var trouve := false
			for colonne in range(1, 10):
				var point := limites.position + limites.size * Vector2(colonne, ligne) / 10.0
				if _point_valide(point):
					global_position = point
					trouve = true
					break
			if trouve: break
	visible = true
	_position_precedente = global_position
	_commencer_deplacement()
	reset_physics_interpolation()

func avancer(delta: float) -> void:
	if not is_instance_valid(_salle): return
	_position_precedente = global_position
	_reste = maxf(0.0, _reste - delta)
	if etat == "deplacement":
		global_position = global_position.move_toward(_destination, CatalogueFamiliers.DEPLACEMENT_VITESSE * delta)
	if _reste > 0.0: return
	match etat:
		"deplacement":
			etat = "vise"
			_reste = CatalogueFamiliers.VISEE_DUREE
		"vise":
			var cible := _cible_proche()
			if cible != null:
				var vitesse: Vector2 = cible.velocity if "velocity" in cible else Vector2.ZERO
				var profil: Dictionary = CatalogueFamiliers.PROJECTILES[id]
				var point := Geometrie.point_anticipe(cible.global_position, vitesse, global_position, float(profil["vitesse"]))
				tir_demande.emit(id, global_position, global_position.direction_to(point))
			etat = "repos"
			_reste = float(CatalogueFamiliers.TYPES[id]["intervalle"]) - CatalogueFamiliers.DEPLACEMENT_DUREE - CatalogueFamiliers.VISEE_DUREE
		"repos": _commencer_deplacement()
	queue_redraw()

func position_affichee() -> Vector2:
	if not get_tree().physics_interpolation: return global_position
	return _position_precedente.lerp(global_position, Engine.get_physics_interpolation_fraction())

func _commencer_deplacement() -> void:
	etat = "deplacement"
	_reste = CatalogueFamiliers.DEPLACEMENT_DUREE
	_destination = global_position
	var cible := _cible_proche()
	var angle := _alea.randf_range(-PI, PI)
	if cible != null:
		var vers := global_position.direction_to(cible.global_position)
		if global_position.distance_to(cible.global_position) < CatalogueFamiliers.DISTANCE_COMBAT:
			vers = vers.orthogonal()
		angle = vers.angle() + _alea.randf_range(-CatalogueFamiliers.ANGLE_PATROUILLE, CatalogueFamiliers.ANGLE_PATROUILLE)
	for essai in CatalogueFamiliers.DIRECTIONS_PATROUILLE:
		var direction := Vector2.from_angle(angle + essai * TAU / CatalogueFamiliers.DIRECTIONS_PATROUILLE)
		var point := global_position + direction * CatalogueFamiliers.PAS_PATROUILLE
		if _point_valide(point) and Geometrie.ligne_libre(global_position, point, _salle.obstacles(), CatalogueFamiliers.RAYON, _salle.contour_sol()):
			_destination = point
			break

func _point_valide(point: Vector2) -> bool:
	if not FormesSalles.contient_disque(point, _salle.contour_sol(), CatalogueFamiliers.RAYON): return false
	return Geometrie.ligne_libre(point, point, _salle.obstacles(), CatalogueFamiliers.RAYON, _salle.contour_sol())

func _cible_proche() -> Node2D:
	var resultat: Node2D
	var distance := INF
	for ennemi in get_tree().get_nodes_in_group("ennemis"):
		if not is_instance_valid(ennemi) or ennemi.is_queued_for_deletion(): continue
		var ecart := global_position.distance_squared_to(ennemi.global_position)
		if ecart < distance:
			distance = ecart
			resultat = ennemi
	return resultat

func _draw() -> void:
	if has_meta("visuel_3d"): return
	draw_circle(Vector2.ZERO, CatalogueFamiliers.RAYON, Color("285ba1"))
	draw_circle(Vector2.ZERO, CatalogueFamiliers.RAYON * .65, Color("66dfd3"))
