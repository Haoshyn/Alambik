class_name NavigationPrincipale
extends Control

signal page_demandee(index: int)

const ONGLET := preload("res://ui/onglet_menu.gd")
const FOND := preload("res://assets/visual/interface/menu/navigation_braise.svg")
const LIBELLES := ["HÉROS", "ÉQUIPEMENT", "AVENTURE", "MAÎTRISES", "SORTS"]
const SYMBOLES := ["heros", "equipement", "aventure", "maitrises", "sorts"]
var _socle: Panel
var _barre: HBoxContainer
var _onglets: Array[OngletMenu] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_socle = Panel.new()
	_socle.name = "Cadre"
	_socle.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_socle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	HabillagePeint.appliquer(_socle)
	var style_fond := StyleBoxTexture.new()
	style_fond.texture = FOND
	for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		style_fond.set_texture_margin(cote, 40)
	_socle.add_theme_stylebox_override("panel", style_fond)
	add_child(_socle)
	_barre = HBoxContainer.new()
	_barre.name = "Onglets"
	_barre.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_barre.add_theme_constant_override("separation", 6)
	add_child(_barre)
	for index in LIBELLES.size():
		var onglet := ONGLET.new() as OngletMenu
		onglet.configurer(SYMBOLES[index], LIBELLES[index], index)
		onglet.pressed.connect(func(): page_demandee.emit(index))
		_barre.add_child(onglet)
		_onglets.append(onglet)
	resized.connect(_replacer)
	_replacer()

func selectionner(index: int) -> void:
	for i in _onglets.size():
		_onglets[i].actif = i == index

func _replacer() -> void:
	if _socle == null: return
	var marge := maxf(12.0, (size.x - 1080.0) * 0.5)
	var bas := Ecran.marge_basse() + StyleAzur.MARGE_NAVIGATION_BAS
	_socle.offset_top = -StyleAzur.HAUTEUR_NAVIGATION - bas
	_socle.offset_left = maxf(marge, Ecran.marge_gauche())
	_socle.offset_right = -maxf(marge, Ecran.marge_droite())
	_socle.offset_bottom = -bas
	_barre.offset_top = -StyleAzur.HAUTEUR_NAVIGATION - bas
	_barre.offset_bottom = -bas
	_barre.offset_left = maxf(marge, Ecran.marge_gauche()) + 12
	_barre.offset_right = -maxf(marge, Ecran.marge_droite()) - 12
