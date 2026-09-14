extends Control

var _anim := 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	visibility_changed.connect(func(): set_process(is_visible_in_tree()))

func _process(delta: float) -> void:
	_anim += delta * (0.0 if ReglagesJoueur.effets_reduits else 1.0)
	queue_redraw()

func _draw() -> void:
	PassageManga.dessiner(self, size, _anim)
