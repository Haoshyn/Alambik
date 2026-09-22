extends Control

const MAGE := preload("res://assets/visual/interface/accueil_mage_detoure.png")

var _mage: TextureRect
var _temps := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mage = TextureRect.new()
	_mage.texture = MAGE
	_mage.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_mage.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_mage.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_mage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_mage)
	resized.connect(_cadrer)
	ReglagesJoueur.reglages_changes.connect(_actualiser_effets)
	_cadrer()
	_actualiser_effets()

func _cadrer() -> void:
	if _mage != null:
		_mage.pivot_offset = Vector2(size.x * 0.5, size.y * 0.9)

func _actualiser_effets() -> void:
	set_process(not ReglagesJoueur.effets_reduits)
	if ReglagesJoueur.effets_reduits:
		_mage.scale = Vector2.ONE
		_mage.rotation = 0.0

func _process(delta: float) -> void:
	_temps += delta
	var respiration := sin(_temps * 2.1)
	_mage.scale = Vector2(1.0 + respiration * 0.006, 1.0 + respiration * 0.01)
	_mage.rotation = sin(_temps * 1.25) * 0.003
