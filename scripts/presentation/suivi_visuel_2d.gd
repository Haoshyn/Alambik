extends Node

var cible: Node2D
var _precedente := Vector2.ZERO
var _courante := Vector2.ZERO

func _ready() -> void:
	process_physics_priority = 100
	cible = get_parent() as Node2D
	_precedente = cible.global_position
	_courante = _precedente

func _physics_process(_delta: float) -> void:
	_precedente = _courante
	_courante = cible.global_position
	if _precedente.distance_to(_courante) > Visuels3D.HEROS_SEUIL_TELEPORTATION:
		_precedente = _courante

func position_affichee() -> Vector2:
	# Un placement hors physique (nouvelle salle, capture) ne doit pas trainer.
	if not cible.is_physics_processing() or not cible.global_position.is_equal_approx(_courante):
		return cible.global_position
	if not get_tree().physics_interpolation:
		return _courante
	return _precedente.lerp(_courante, Engine.get_physics_interpolation_fraction())
