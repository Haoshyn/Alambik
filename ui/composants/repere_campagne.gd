class_name RepereCampagne
extends Control

signal activee(numero: int)

var numero := 1
var _selectionne := false
var _survole := false
var _accessible := true
var _termine := false
var _teinte := StyleAzur.MAGIE
var _bouton: Button
var _halo: TextureRect
var _motif: TextureRect
var _numero: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(76, 108)
	_bouton = Button.new()
	_bouton.flat = false
	_bouton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	add_child(_bouton)
	for etat in ["normal", "hover", "pressed", "focus", "disabled"]:
		_bouton.add_theme_stylebox_override(etat, _style_sceau(etat))
	_bouton.pressed.connect(func(): activee.emit(numero))
	_bouton.mouse_entered.connect(func() -> void:
		_survole = true
		_actualiser_halo())
	_bouton.mouse_exited.connect(func() -> void:
		_survole = false
		_actualiser_halo())
	_bouton.focus_entered.connect(func() -> void:
		_survole = true
		_actualiser_halo())
	_bouton.focus_exited.connect(func() -> void:
		_survole = false
		_actualiser_halo())
	_halo = StyleAzur.illustration("halo_recompense", 96)
	_bouton.add_child(_halo)
	_motif = StyleAzur.illustration("portail", 56)
	_bouton.add_child(_motif)
	_numero = StyleAzur.texte("", 24, StyleAzur.CUIVRE)
	_numero.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_numero.autowrap_mode = TextServer.AUTOWRAP_OFF
	_numero.add_theme_constant_override("outline_size", 2)
	_numero.add_theme_color_override("font_outline_color", Color("15213c"))
	add_child(_numero)
	resized.connect(_dimensionner)
	_dimensionner()
	_actualiser_halo()

func afficher(nouveau_numero: int, choisie: bool, accessible: bool, statut: String,
		boss := false, termine := false, teinte := StyleAzur.MAGIE) -> void:
	numero = nouveau_numero
	_selectionne = choisie
	_accessible = accessible
	_termine = termine
	_teinte = teinte
	_motif.texture = StyleAzur.texture_interface(
		"cadenas" if not accessible else "couronne" if boss else "validation" if termine else "portail")
	_motif.modulate = Color.WHITE if accessible else Color("929fbc")
	_numero.text = "%02d" % numero
	_bouton.accessibility_name = "Niveau %d · %s" % [numero, statut]
	_bouton.tooltip_text = _bouton.accessibility_name
	_actualiser_halo()

func _dimensionner() -> void:
	if not is_instance_valid(_bouton) or size.x <= 0.0 or size.y <= 0.0:
		return
	var cote := minf(size.x, size.y - 30.0)
	_bouton.position = Vector2.ZERO
	_bouton.size = Vector2.ONE * cote
	_halo.size = Vector2.ONE * cote * 1.32
	_halo.position = (Vector2.ONE * cote - _halo.size) * 0.5
	var cote_motif := cote * 0.59
	_motif.size = Vector2.ONE * cote_motif
	_motif.position = (Vector2.ONE * cote - _motif.size) * 0.5
	_numero.position = Vector2(0.0, cote + 3.0)
	_numero.size = Vector2(cote, 28.0)
	_numero.add_theme_font_size_override("font_size", maxi(20, roundi(cote * 0.27)))
	for etat in ["normal", "hover", "pressed", "focus", "disabled"]:
		_bouton.add_theme_stylebox_override(etat, _style_sceau(etat))

func _style_sceau(etat: String) -> StyleBoxFlat:
	var proportion := 0.16 if _accessible else 0.1
	var accent := _teinte if _accessible else Color("8896b6")
	if _termine:
		accent = StyleAzur.MENTHE
		proportion = 0.18
	if _selectionne:
		proportion = 0.4
	if etat in ["hover", "focus"]:
		proportion = maxf(proportion, 0.28)
	if etat == "pressed":
		proportion *= 0.78
	var style := StyleBoxFlat.new()
	style.bg_color = Color("202949").lerp(accent, proportion)
	style.border_color = Color(accent.r, accent.g, accent.b, 0.95 if _selectionne else 0.72)
	style.set_border_width_all(3 if _selectionne or _survole else 2)
	style.set_corner_radius_all(roundi(minf(size.x, size.y) * 0.5))
	style.shadow_color = Color(accent.r, accent.g, accent.b, 0.34 if _selectionne else 0.12)
	style.shadow_size = 7 if _selectionne else 2
	style.anti_aliasing = true
	return style

func _actualiser_halo() -> void:
	if not is_instance_valid(_halo):
		return
	_halo.visible = _selectionne or _survole
	_halo.modulate = Color(_teinte.r, _teinte.g, _teinte.b, 0.56 if _selectionne else 0.34)
	_numero.add_theme_color_override(
		"font_color",
		StyleAzur.MENTHE if _termine else StyleAzur.CUIVRE if _selectionne else StyleAzur.ATTENUE)
	for etat in ["normal", "hover", "pressed", "focus", "disabled"]:
		_bouton.add_theme_stylebox_override(etat, _style_sceau(etat))
