extends Node3D

var logique: Node2D
var _familier: Node3D
var _temps := 0.0
var _position_precedente := Vector2.ZERO
var _position_connue := false

func _ready() -> void:
	_familier = preload("res://scripts/presentation/familier_tireur_3d.gd").new()
	_familier.name = "FamilierEquipe"
	_familier.id = logique.id
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
	if _familier.id != logique.id:
		_familier.configurer(logique.id)
		_position_connue = false
	var mouvement := Vector2.ZERO
	if _position_connue and delta > 0.0 and logique.etat == "deplacement":
		# Les changements de salle ne doivent pas produire un grand pas artificiel.
		if position_logique.distance_to(_position_precedente) <= CatalogueFamiliers.DEPLACEMENT_VITESSE * delta * 2.0:
			mouvement = (position_logique - _position_precedente) / delta
	_position_precedente = position_logique
	_position_connue = true
	_familier.position = Pont3D.vers_monde(position_logique,
		preload("res://scripts/presentation/modeles_familiers_3d.gd").hauteur(_familier.id))
	_familier.animer(delta, ReglagesJoueur.effets_reduits, mouvement)
	if not ReglagesJoueur.effets_reduits and not preload("res://scripts/presentation/modeles_familiers_3d.gd").terrestre(_familier.id):
		_familier.position.y += sin(_temps * 3.5) * 0.045
