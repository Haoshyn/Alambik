class_name CompositionArcane
extends Control

var hauteur := 1080.0
var traces: Array[PackedVector2Array] = []
var _elements: Array[Dictionary] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_composer)
	_composer()

func placer(element: Control, rectangle: Rect2) -> void:
	add_child(element)
	_elements.append({"element": element, "rect": rectangle})
	_composer()

func _composer() -> void:
	var facteur := maxf(size.x / 960.0, 0.1)
	custom_minimum_size.y = hauteur * facteur
	for entree in _elements:
		var element: Control = entree["element"]
		var rectangle: Rect2 = entree["rect"]
		element.position = rectangle.position * facteur
		element.size = rectangle.size
		element.scale = Vector2.ONE * facteur
	queue_redraw()

func _draw() -> void:
	var facteur := size.x / 960.0
	for trace in traces:
		var points := PackedVector2Array()
		for point in trace: points.append(point * facteur)
		if points.size() > 1:
			draw_polyline(points, Color("142e4966"), 9.0 * facteur, true)
			draw_polyline(points, Color("75bdbd77"), 2.0 * facteur, true)
			for point in points:
				draw_circle(point, 4.0 * facteur, Color("d0b88899"))
