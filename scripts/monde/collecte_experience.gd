extends Node2D

signal ramassee(experience: int)

# La Mine conserve la valeur de chaque depot a sa position de mort. Le rendu
# n'impose aucun plafond qui ferait perdre ou deplacer de l'experience.
var _depots: Array[Dictionary] = []
var _heros: Node2D
var _visuel: Node2D
var _salle: Node2D
var _position_precedente := Vector2.ZERO

func configurer(heros: Node2D, visuel: Node2D, salle: Node2D) -> void:
	_heros = heros
	_visuel = visuel
	_salle = salle
	_position_precedente = heros.global_position

func deposer(point: Vector2, experience: int) -> void:
	if experience <= 0: return
	_depots.append({"position": point, "experience": experience})
	_afficher()

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(_heros) or float(_heros.stats.pv) <= 0.0: return
	var position_heros := _heros.global_position
	var restants: Array[Dictionary] = []
	var experience := 0
	var obstacles: Array = _salle.obstacles()
	for depot in _depots:
		var point: Vector2 = depot["position"]
		# Le segment conserve les ramassages meme pendant un deplacement rapide.
		var proche := Geometry2D.get_closest_point_to_segment(point, _position_precedente, position_heros)
		if point.distance_to(proche) <= Reglages.MINE_XP_RAYON_RAMASSAGE \
				and Geometrie.ligne_libre(point, proche, obstacles):
			experience += int(depot["experience"])
		else:
			restants.append(depot)
	_position_precedente = position_heros
	if experience <= 0: return
	_depots = restants
	_afficher()
	# Retirer les depots avant le signal : le choix d'augment peut mettre en pause.
	ramassee.emit(experience)

func _afficher() -> void:
	var positions: Array[Vector2] = []
	for depot in _depots:
		var point: Vector2 = depot["position"]
		positions.append(point)
	_visuel.afficher_depots(positions)
