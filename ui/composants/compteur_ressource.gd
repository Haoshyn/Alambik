class_name CompteurRessource
extends PanelContainer

var _icone: TextureRect
var _valeur: Label
var _libelle := ""

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	HabillagePeint.appliquer(self)
	var cadre := StyleBoxTexture.new()
	cadre.texture = HabillagePeint.texture("compteur")
	for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		cadre.set_texture_margin(cote, 40)
		cadre.set_content_margin(cote, 8)
	add_theme_stylebox_override("panel", cadre)
	var ligne := HBoxContainer.new()
	ligne.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ligne.add_theme_constant_override("separation", 6)
	add_child(ligne)
	_icone = StyleAzur.illustration("gouttes", 59)
	ligne.add_child(_icone)
	_valeur = StyleAzur.texte("", 36, StyleAzur.IVOIRE)
	_valeur.autowrap_mode = TextServer.AUTOWRAP_OFF
	_valeur.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_valeur.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ligne.add_child(_valeur)

func configurer(icone: String, libelle: String) -> void:
	_icone.texture = StyleAzur.texture_interface(icone)
	_libelle = libelle
	tooltip_text = libelle

func afficher(valeur: String) -> void:
	_valeur.text = valeur
	accessibility_name = "%s : %s" % [_libelle, valeur]
