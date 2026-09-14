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
	queue_redraw()
	Capture.programmer(self)

func _process(delta: float) -> void:
	_temps += delta
	queue_redraw()
	if not _terminee and _temps >= DUREE:
		_terminee = true
		terminee.emit()

func _draw() -> void:
	PassageManga.dessiner(self,size,0.0 if ReglagesJoueur.effets_reduits else _temps)
	var centre := size*0.5
	draw_string(Polices.CORPS,Vector2(40,centre.y-10),str(_livre.get("nom","Grimoire")),HORIZONTAL_ALIGNMENT_CENTER,size.x-80,38,StyleAzur.TEXTE)
	draw_string(Polices.CORPS,Vector2(40,centre.y+48),"Votre aventure commence…",HORIZONTAL_ALIGNMENT_CENTER,size.x-80,28,StyleAzur.ATTENUE)
