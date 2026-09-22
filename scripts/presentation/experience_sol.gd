extends Node2D

# Les valeurs d'XP appartiennent a Salle ou CollecteExperience, jamais au rendu.
var _depots: Array[Vector2] = []
var _origines: Array[Vector2] = []
var _heros: Node2D
var _ramassage := -1.0

func deposer(point: Vector2) -> void:
	# La campagne attribue son budget entier a la fin, meme si le rendu est borne.
	if _depots.size() < Visuels3D.DEPOTS_EXPERIENCE_MAX:
		_depots.append(to_local(point))
	queue_redraw()

func afficher_depots(points: Array[Vector2]) -> void:
	var positions: Array[Vector2] = []
	for point in points:
		positions.append(to_local(point))
	_depots = positions
	queue_redraw()

func ramasser(heros: Node2D) -> void:
	_heros = heros
	_origines = _depots.duplicate()
	_ramassage = 0.0

func _process(delta: float) -> void:
	if _ramassage < 0.0 or not is_instance_valid(_heros): return
	_ramassage = minf(1.0, _ramassage + delta / Reglages.XP_RAMASSAGE_DUREE)
	for i in _depots.size():
		_depots[i] = _origines[i].lerp(to_local(_heros.global_position), _ramassage * _ramassage)
	if _ramassage >= 1.0:
		_depots.clear()
		_origines.clear()
		_ramassage = -1.0
	queue_redraw()

func _draw() -> void:
	for point in _depots:
		draw_circle(point, 9.0, Color(.03,.08,.12,.38))
		var losange := PackedVector2Array([point + Vector2(0,-7), point + Vector2(5,0), point + Vector2(0,7), point + Vector2(-5,0)])
		draw_colored_polygon(losange, Color(.39,.85,.89,.85))
		draw_line(point + Vector2(0,-4), point + Vector2(0,2), Color(.88,1,1,.9), 2.0)
