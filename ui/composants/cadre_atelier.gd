class_name CadreAtelier
extends Control

var accent := Color("f5dbaa")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(queue_redraw)

func _draw() -> void:
	var marge := 9.0
	var longueur := minf(30.0, size.x * 0.08)
	for coin: Vector2 in [Vector2(marge, marge), Vector2(size.x - marge, marge), Vector2(marge, size.y - marge), size - Vector2.ONE * marge]:
		var vers := Vector2(1.0 if coin.x < size.x * 0.5 else -1.0, 1.0 if coin.y < size.y * 0.5 else -1.0)
		draw_line(coin + Vector2(0, vers.y * longueur), coin, Color(accent, 0.6), 1.5, true)
		draw_line(coin, coin + Vector2(vers.x * longueur, 0), Color(accent, 0.6), 1.5, true)
		draw_circle(coin + vers * 4.0, 1.8, Color(accent, 0.85))
