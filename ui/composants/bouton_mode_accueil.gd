class_name BoutonModeAccueil
extends Button

var _visuel: Control
var _icone: TextureRect
var _legende_fond: Panel
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
	_icone = StyleAzur.illustration("mine", 0)
	_icone.name = "Icone"
	_visuel.add_child(_icone)
	_legende_fond = Panel.new()
	_legende_fond.name = "FondLegende"
	_legende_fond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fond := StyleAzur.fond_legende(0.84, 13)
	fond.border_color = Color("c1c9e3a0")
	fond.set_border_width_all(1)
	_legende_fond.add_theme_stylebox_override("panel", fond)
	add_child(_legende_fond)
	_libelle = StyleAzur.texte("", 29, StyleAzur.IVOIRE)
	_libelle.name = "Libelle"
	_libelle.add_theme_font_override("font", Polices.TITRE)
	_libelle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_libelle.autowrap_mode = TextServer.AUTOWRAP_OFF
	add_child(_libelle)
	_condition = StyleAzur.texte("", 21, StyleAzur.ATTENUE)
	_condition.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_condition.autowrap_mode = TextServer.AUTOWRAP_OFF
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
	accessibility_name = libelle

func definir_acces(ouvert: bool, niveau: int) -> void:
	disabled = not ouvert
	_verrou.visible = not ouvert
	_condition.text = "Niveau %d" % niveau if not ouvert else ""
	_icone.modulate = Color.WHITE if ouvert else Color("d4d9e9")
	_replacer()

func _replacer() -> void:
	if _visuel == null:
		return
	var cote := minf(size.x, maxf(0.0, size.y - 68.0))
	_visuel.position = Vector2((size.x - cote) * 0.5, 0)
	_visuel.size = Vector2.ONE * cote
	_visuel.pivot_offset = _visuel.size * 0.5
	var marge_icone := cote * 0.17
	_icone.position = Vector2.ONE * marge_icone
	_icone.size = Vector2.ONE * (cote - 2.0 * marge_icone)
	_libelle.add_theme_font_size_override("font_size", int(clampf(size.x * 0.18, 24.0, 29.0)))
	_condition.add_theme_font_size_override("font_size", int(clampf(size.x * 0.14, 19.0, 22.0)))
	_legende_fond.position = Vector2(0, cote + 1)
	_legende_fond.size = Vector2(size.x, maxf(0.0, size.y - cote - 1.0))
	_libelle.position = Vector2(5, cote + 3)
	_libelle.size = Vector2(size.x - 10, 38)
	_condition.position = Vector2(5, cote + 39)
	_condition.size = Vector2(size.x - 10, 26)
	_verrou.position = Vector2(size.x - 43, cote - 47)
	_verrou.size = Vector2(42, 42)

func _animer(enfonce: bool) -> void:
	if _animation != null and _animation.is_valid():
		_animation.kill()
	_animation = create_tween()
	_animation.tween_property(_visuel, "scale", Vector2.ONE * (0.96 if enfonce else 1.0), 0.06 if ReglagesJoueur.effets_reduits else 0.12)
