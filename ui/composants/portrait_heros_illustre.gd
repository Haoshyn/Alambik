extends Control

const MAGE := preload("res://assets/visual/interface/accueil_mage_detoure.png")

var _mage: TextureRect

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
	var matiere := ShaderMaterial.new()
	matiere.shader = preload("res://shaders/portrait_menu.gdshader")
	_mage.material = matiere
