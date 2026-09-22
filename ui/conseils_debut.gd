extends Control

var _marge: MarginContainer
var _progression: Label
var _titre: Label
var _detail: Label
var _contexte: Label
var _icone: TextureRect

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	visible = false
	_marge = MarginContainer.new()
	_marge.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_marge.offset_left = 36
	_marge.offset_right = -36
	_marge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_marge)
	_replacer()
	get_viewport().size_changed.connect(_replacer)
	var col := StyleAzur.plaque(_marge)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	(col.get_parent() as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	var entete := HBoxContainer.new()
	entete.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entete.add_theme_constant_override("separation", 18)
	col.add_child(entete)
	_progression = StyleAzur.texte("PREMIERS PAS · 1/3", 24, StyleAzur.CUIVRE)
	_progression.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_progression.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	entete.add_child(_progression)
	var ligne := HBoxContainer.new()
	ligne.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ligne.add_theme_constant_override("separation", 18)
	col.add_child(ligne)
	_icone = StyleAzur.illustration("joystick_base", 76.0)
	ligne.add_child(_icone)
	var textes := VBoxContainer.new()
	textes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textes.add_theme_constant_override("separation", 6)
	ligne.add_child(textes)
	_titre = StyleAzur.texte("", 30)
	_detail = StyleAzur.texte("", 24, StyleAzur.ATTENUE)
	textes.add_child(_titre)
	textes.add_child(_detail)
	_contexte = StyleAzur.texte("", 22, StyleAzur.MENTHE)
	col.add_child(_contexte)

func afficher_etape(numero: int) -> void:
	_progression.text = "PREMIERS PAS · %d/3" % numero
	match numero:
		1:
			_titre.text = "Glissez pour vous déplacer"
			_detail.text = "Posez le pouce dans la moitié basse et faites-le glisser."
			_contexte.text = "Prenez votre temps : les ennemis attendent."
		2:
			_titre.text = "Relâchez pour tirer"
			_detail.text = "Arrêtez-vous : votre mage vise et tire automatiquement."
			_contexte.text = "Le combat commence dès votre premier tir."
		3:
			_titre.text = "Rejoignez le portail"
			_detail.text = "Traversez le portail lumineux en haut de la salle pour continuer."
			_contexte.text = "Salle dégagée !"
			_icone.texture = StyleAzur.texture_interface("portail")

func _replacer() -> void:
	_marge.offset_top = Ecran.marge_haute() + 394
