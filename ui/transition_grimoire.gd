extends Control

signal terminee

const DUREE := 1.45

var _livre := {}
var _temps := 0.0
var _terminee := false

func configurer(livre: Dictionary) -> void:
	_livre = livre

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	HabillagePeint.appliquer(self)
	PassageManga.preparer(self)
	StyleInterface.animer_entree(self, 0.0)
	queue_redraw()
	Capture.programmer(self)

func _process(delta: float) -> void:
	_temps += delta
	queue_redraw()
	if not _terminee and _temps >= DUREE:
		_terminee = true
		terminee.emit()

func _draw() -> void:
	PassageManga.dessiner(self, size, _temps, str(_livre.get("nom", "Grimoire")), "Votre aventure commence…")
