extends Node3D

var logique: Node2D
var _familier: Node3D
var _temps := 0.0

func _ready() -> void:
	_familier = preload("res://scripts/presentation/familier_tireur_3d.gd").new()
	_familier.name = "FamilierEquipe"
	add_child(_familier)
	logique.set_meta("visuel_3d", true)
	mettre_a_jour(0.0)

func mettre_a_jour(delta: float) -> void:
	if not is_instance_valid(logique):
		hide()
		return
	visible = logique.visible
	_temps += delta
	var position_logique: Vector2 = logique.position_affichee()
	_familier.position = Pont3D.vers_monde(position_logique, 0.45)
	_familier.animer(delta, ReglagesJoueur.effets_reduits)
	if not ReglagesJoueur.effets_reduits:
		_familier.position.y += sin(_temps * 3.5) * 0.045
