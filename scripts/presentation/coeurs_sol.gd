extends Node2D

# Un coeur de verre menthe et son joint dore se distinguent des dangers rouges.
# Le plan 2D partage le cadrage orthographique du sol 3D via Pont3D.
const CONTOUR := [Vector2(0, -9), Vector2(-7, -16),
	Vector2(-15, -16), Vector2(-21, -10), Vector2(-21, -2), Vector2(-16, 6),
	Vector2(0, 21), Vector2(16, 6), Vector2(21, -2), Vector2(21, -10),
	Vector2(15, -16), Vector2(7, -16), Vector2(0, -9)]

var _depots: Array[Vector2] = []

func _ready() -> void:
	z_index = 12

func afficher_depots(points: Array[Vector2]) -> void:
	var positions: Array[Vector2] = []
	for point in points: positions.append(to_local(point))
	_depots = positions
	queue_redraw()

func _draw() -> void:
	for point in _depots:
		draw_circle(point + Vector2(0, 8), 25.0, Color(0.02, 0.07, 0.08, 0.32))
		draw_circle(point, 29.0, Color(0.39, 1.0, 0.79, 0.13))
		var contour := PackedVector2Array()
		for sommet in CONTOUR: contour.append(point + sommet)
		draw_colored_polygon(contour, Color(0.17, 0.77, 0.58))
		draw_polyline(contour, Color(0.96, 0.85, 0.52), 2.5, true)
		draw_polyline(PackedVector2Array([point + Vector2(-15, -5),
			point + Vector2(-13, -10), point + Vector2(-8, -11)]), Color(0.84, 1.0, 0.93), 3.0, true)
		draw_line(point + Vector2(-6, 3), point + Vector2(6, 3), Color(0.93, 1.0, 0.95), 3.0, true)
		draw_line(point + Vector2(0, -3), point + Vector2(0, 9), Color(0.93, 1.0, 0.95), 3.0, true)
