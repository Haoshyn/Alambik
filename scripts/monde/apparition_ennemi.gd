extends Node2D

signal achevee(apparition: Node2D)

var donnees: Dictionary
var invocateur_id := 0
var invocation_boss := false
var duree := Reglages.APPARITION_ANNONCE
var _age := 0.0

func _ready() -> void:
	add_to_group("apparitions_ennemis")
	if invocation_boss: add_to_group("invocations_boss")
	if bool(donnees.get("elite", false)): add_to_group("elites")
	z_index = 1

func _physics_process(delta: float) -> void:
	_age += delta
	queue_redraw()
	if _age < duree: return
	# La reservation est liberee dans la meme frame que l'arrivee reelle.
	annuler()
	achevee.emit(self)

func annuler() -> void:
	set_physics_process(false)
	remove_from_group("apparitions_ennemis")
	remove_from_group("invocations_boss")
	remove_from_group("elites")
	queue_free()

func _draw() -> void:
	var rayon := float(donnees["rayon"]) + Reglages.HEROS_RAYON
	preload("res://scripts/presentation/annonces_ennemis.gd").dessiner_zone(
		self, Vector2.ZERO, rayon, clampf(_age / duree, 0.0, 1.0))
