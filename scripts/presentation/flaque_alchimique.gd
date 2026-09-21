class_name FlaqueAlchimique
extends Node2D

var _duree := 1.0
var _restant := 1.0
var _rayon := 64.0

func configurer(duree: float, rayon: float) -> void:
	_duree = maxf(0.01, duree)
	_restant = _duree
	_rayon = rayon
	queue_redraw()

func _process(delta: float) -> void:
	_restant = maxf(0.0, _restant - delta)
	queue_redraw()
	if _restant <= 0.0:
		queue_free()

func _draw() -> void:
	var alpha := 0.10 + 0.22 * (_restant / _duree)
	draw_circle(Vector2.ZERO, _rayon, Color(0.45, 0.86, 0.58, alpha))
	draw_arc(Vector2.ZERO, _rayon, 0.0, TAU, 28, Color(0.68, 1.0, 0.72, alpha + 0.18), 3.0, true)
