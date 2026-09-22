class_name BoutonModeAccueil
extends Button

var _visuel: Control
var _icone: TextureRect
var _libelle: Label
var _condition: Label
var _verrou: TextureRect
var _animation: Tween

func _ready() -> void:
	StyleInterface.rendre_invisible(self)
	action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	_visuel = Control.new()
	_visuel.name = "Sceau"
	_visuel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_visuel)
	var cadre := Panel.new()
	cadre.name = "Cadre"
	cadre.add_theme_stylebox_override("panel", StyleAzur.cercle())
	cadre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_visuel.add_child(cadre)
	cadre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_icone = StyleAzur.illustration("forge", 0)
	_icone.name = "Icone"
	_visuel.add_child(_icone)
	_icone.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_icone.offset_left = 38
	_icone.offset_right = -38
	_icone.offset_top = 38
	_icone.offset_bottom = -38
	_libelle = StyleAzur.texte("", 27, StyleAzur.IVOIRE)
	_libelle.name = "Libelle"
	_libelle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_libelle.autowrap_mode = TextServer.AUTOWRAP_OFF
	_libelle.add_theme_constant_override("outline_size", 5)
	_libelle.add_theme_color_override("font_outline_color", Color("213c51"))
	add_child(_libelle)
	_condition = StyleAzur.texte("", 22, StyleAzur.CUIVRE)
	_condition.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_condition.autowrap_mode = TextServer.AUTOWRAP_OFF
	_condition.add_theme_constant_override("outline_size", 4)
	_condition.add_theme_color_override("font_outline_color", Color("213c51"))
	add_child(_condition)
	_verrou = StyleAzur.illustration("cadenas", 0)
	_verrou.name = "Verrou"
	add_child(_verrou)
	resized.connect(_replacer)
	button_down.connect(func(): _animer(true))
	button_up.connect(func(): _animer(false))
	_replacer()

func configurer(icone: String, libelle: String) -> void:
	_icone.texture = StyleAzur.texture_interface(icone)
	_libelle.text = libelle
	tooltip_text = libelle

func definir_acces(ouvert: bool, niveau: int) -> void:
	disabled = not ouvert
	_verrou.visible = not ouvert
	_condition.text = "Niveau %d" % niveau if not ouvert else ""
	_icone.modulate = Color.WHITE if ouvert else Color("a49e87")

func _replacer() -> void:
	if _visuel == null: return
	var cote := minf(size.x, size.y - 72.0)
	_visuel.position = Vector2((size.x - cote) * 0.5, 0)
	_visuel.size = Vector2.ONE * cote
	_visuel.pivot_offset = _visuel.size * 0.5
	_libelle.add_theme_font_size_override("font_size", int(clampf(size.x * 0.16, 20.0, 27.0)))
	_condition.add_theme_font_size_override("font_size", int(clampf(size.x * 0.13, 18.0, 22.0)))
	_libelle.position = Vector2(0, cote + 2)
	_libelle.size = Vector2(size.x, 34)
	_condition.position = Vector2(0, cote + 37)
	_condition.size = Vector2(size.x, 30)
	_verrou.position = Vector2(size.x - 52, cote - 48)
	_verrou.size = Vector2(52, 52)

func _animer(enfonce: bool) -> void:
	if _animation != null and _animation.is_valid(): _animation.kill()
	_animation = create_tween()
	_animation.tween_property(_visuel, "scale", Vector2.ONE * (0.96 if enfonce else 1.0), 0.06 if ReglagesJoueur.effets_reduits else 0.12)
