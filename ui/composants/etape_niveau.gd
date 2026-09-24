class_name EtapeNiveau
extends VBoxContainer

signal activee(numero: int)

var numero := 1
var _bouton: Button
var _numero: Label
var _statut: Label
var _motif: TextureRect
var _insigne: TextureRect

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(188, 212)
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 8)
	_bouton = StyleAzur.bouton("", func(): activee.emit(numero))
	_bouton.custom_minimum_size = Vector2(144, 144)
	_bouton.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_bouton.add_theme_stylebox_override("normal", StyleAzur.cercle())
	_bouton.add_theme_stylebox_override("hover", StyleAzur.cercle(true))
	_bouton.add_theme_stylebox_override("pressed", StyleAzur.cercle(true))
	add_child(_bouton)
	_motif = StyleAzur.illustration("portail", 76)
	_motif.position = Vector2(34, 8)
	_bouton.add_child(_motif)
	_numero = StyleAzur.texte("", 39, StyleAzur.IVOIRE)
	_numero.position = Vector2(0, 85)
	_numero.size = Vector2(144, 48)
	_numero.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_numero.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bouton.add_child(_numero)
	_insigne = StyleAzur.illustration("cadenas", 40)
	_insigne.position = Vector2(109, -6)
	_bouton.add_child(_insigne)
	_statut = StyleAzur.texte("", 24, StyleAzur.ATTENUE)
	_statut.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_statut.custom_minimum_size.y = 60
	_statut.add_theme_constant_override("outline_size", 4)
	_statut.add_theme_color_override("font_outline_color", Color("1c2744"))
	add_child(_statut)

func afficher(nouveau_numero: int, choisie: bool, accessible: bool, statut: String, boss := false, motif := "portail") -> void:
	numero = nouveau_numero
	_numero.text = "%02d" % numero
	_motif.texture = StyleAzur.texture_interface("couronne" if boss and accessible else motif)
	_motif.modulate = Color(1.0, 1.0, 1.0, 0.9 if accessible else 0.42)
	_bouton.add_theme_stylebox_override("normal", StyleAzur.cercle(choisie))
	_bouton.self_modulate = Color.WHITE if accessible else Color("aab5ce")
	_statut.text = statut
	_statut.add_theme_color_override("font_color", StyleAzur.MAGIE if choisie else StyleAzur.ATTENUE)
	_insigne.visible = not accessible
	_bouton.accessibility_name = "Niveau %d · %s" % [numero, statut]
	_bouton.tooltip_text = _bouton.accessibility_name
