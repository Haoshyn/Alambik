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
	var t := 1.0 - _restant / _duree
	var alpha := (1.0 - smoothstep(.72, 1.0, t)) * .34
	var age := _duree - _restant
	var reduit := ReglagesJoueur.effets_reduits
	var mouvement := 0.0 if reduit else age
	var points := PackedVector2Array()
	var sommets := 24 if reduit else 40
	for i in sommets:
		var angle := TAU * i / float(sommets)
		var contour := 1.0 + .035 * sin(angle * 5.0 + mouvement * 1.8) + .018 * sin(angle * 9.0 - mouvement)
		points.append(Vector2.from_angle(angle) * _rayon * contour)
	draw_colored_polygon(points, Color("248054", alpha * .7))
	for i in range(4, 0, -1):
		var part := float(i) / 4.0
		draw_circle(Vector2.ZERO, _rayon * part * .92, Color("70df85", alpha * (1.0 - part * .55) * .32))
	var bulles := 3 if reduit else 5
	for i in bulles:
		var angle := TAU * i / float(bulles) + mouvement * .18
		var point := Vector2.from_angle(angle) * _rayon * (.34 + .20 * (i % 2))
		var phase := fposmod(mouvement * .65 + .2 + i * .23, 1.0)
		var taille := (3.0 + (i % 3) * 1.8) * sin(PI * phase)
		draw_circle(point, taille, Color("60d58c", alpha * .8))
		draw_arc(point, taille, -.8, PI * 1.2, 14, Color("cdffb0", alpha * 1.8), 1.4, true)
		draw_circle(point + Vector2(-.28, -.32) * taille, taille * .22, Color("e7ffc7", alpha * 2.0))
	for i in 4:
		var debut := TAU * i / 4.0 + mouvement * .1
		draw_arc(Vector2.ZERO, _rayon * .98, debut, debut + 1.05, 12, Color("b2f38b", alpha * 1.25), 2.0, true)
