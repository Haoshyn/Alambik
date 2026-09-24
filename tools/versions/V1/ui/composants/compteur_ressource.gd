class_name CompteurRessource
extends PanelContainer

const MARGE_GAUCHE := 20.0
const MARGE_DROITE := 24.0
const LARGEUR_ICONE := 59.0
const ESPACE_ICONE := 6.0

var _icone: TextureRect
var _valeur: Label
var _cadre: StyleBoxTexture
var _libelle := ""

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	HabillagePeint.appliquer(self)
	_cadre = StyleBoxTexture.new()
	_cadre.texture = HabillagePeint.texture("compteur")
	for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		_cadre.set_texture_margin(cote, 40)
		_cadre.set_content_margin(cote, 8)
	_cadre.set_content_margin(SIDE_LEFT, MARGE_GAUCHE)
	_cadre.set_content_margin(SIDE_RIGHT, MARGE_DROITE)
	add_theme_stylebox_override("panel", _cadre)
	var ligne := HBoxContainer.new()
	ligne.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ligne.add_theme_constant_override("separation", int(ESPACE_ICONE))
	add_child(ligne)
	_icone = StyleAzur.illustration("gouttes", LARGEUR_ICONE)
	ligne.add_child(_icone)
	_valeur = StyleAzur.texte("", 36, StyleAzur.IVOIRE)
	_valeur.autowrap_mode = TextServer.AUTOWRAP_OFF
	_valeur.clip_text = true
	_valeur.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_valeur.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ligne.add_child(_valeur)
	resized.connect(_ajuster_valeur)

func configurer(icone: String, libelle: String) -> void:
	_icone.texture = StyleAzur.texture_interface(icone)
	_cadre.texture = HabillagePeint.texture("compteur_" + icone) if icone in ["gouttes", "pierres"] else HabillagePeint.texture("compteur")
	_libelle = libelle
	tooltip_text = libelle

func afficher(valeur: String) -> void:
	_valeur.text = valeur
	accessibility_name = "%s : %s" % [_libelle, valeur]
	_ajuster_valeur()

func _ajuster_valeur() -> void:
	if _valeur == null:
		return
	var largeur := maxf(0.0, size.x - MARGE_GAUCHE - MARGE_DROITE - LARGEUR_ICONE - ESPACE_ICONE)
	var taille := 36
	while taille > 22 and Polices.TITRE.get_string_size(_valeur.text, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x > largeur:
		taille -= 1
	_valeur.add_theme_font_size_override("font_size", taille)
