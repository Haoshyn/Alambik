extends Control

var titre := "Le passage s’ouvre"
var sous_titre := "Un nouveau niveau vous attend…"
var _anim := 0.0

func configurer(titre_: String, sous_titre_: String) -> void:
	titre = titre_
	sous_titre = sous_titre_
	queue_redraw()

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	HabillagePeint.appliquer(self)
	PassageManga.preparer(self)
	process_mode = Node.PROCESS_MODE_ALWAYS
	visibility_changed.connect(func(): set_process(is_visible_in_tree()))

func _process(delta: float) -> void:
	_anim += delta * (0.0 if ReglagesJoueur.effets_reduits else 1.0)
	queue_redraw()

func _draw() -> void:
	PassageManga.dessiner(self, size, _anim, titre, sous_titre)
