class_name CompteurRessource
extends PanelContainer

var _icone: TextureRect
var _valeur: Label
var _libelle: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	HabillagePeint.appliquer(self)
	add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	var ligne := HBoxContainer.new()
	ligne.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ligne.add_theme_constant_override("separation", 10)
	add_child(ligne)
	_icone = StyleAzur.illustration("gouttes", 54)
	ligne.add_child(_icone)
	var textes := VBoxContainer.new()
	textes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textes.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	textes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textes.add_theme_constant_override("separation", 0)
	ligne.add_child(textes)
	_libelle = StyleAzur.texte("", 21, StyleAzur.ATTENUE)
	textes.add_child(_libelle)
	_valeur = StyleAzur.texte("", 30, StyleAzur.IVOIRE)
	_valeur.autowrap_mode = TextServer.AUTOWRAP_OFF
	textes.add_child(_valeur)

func configurer(icone: String, libelle: String) -> void:
	_icone.texture = StyleAzur.texture_interface(icone)
	_libelle.text = libelle

func afficher(valeur: String) -> void:
	_valeur.text = valeur
