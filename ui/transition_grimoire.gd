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
	draw_rect(Rect2(Vector2.ZERO,size),StyleAzur.FOND)
	var centre := size*0.5
	var pulsation := 1.0+sin(_temps*2.0)*0.025
	draw_texture_rect(StyleAzur.icone(10),Rect2(centre-Vector2.ONE*150*pulsation,Vector2.ONE*300*pulsation),false)
	draw_string(Polices.CORPS,Vector2(40,centre.y+245),str(_livre.get("nom","Grimoire")),HORIZONTAL_ALIGNMENT_CENTER,size.x-80,38,StyleAzur.TEXTE)
	draw_string(Polices.CORPS,Vector2(40,centre.y+305),"Votre aventure commence…",HORIZONTAL_ALIGNMENT_CENTER,size.x-80,28,StyleAzur.ATTENUE)
