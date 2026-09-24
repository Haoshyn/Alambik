class_name CommandeDepart
extends Control

signal depart_demande
signal mine_demandee
signal epreuve_demandee

const MODE := preload("res://ui/composants/bouton_mode_accueil.tscn")
const ORNEMENT := preload("res://assets/visual/interface/menu/ornement_depart.svg")

var _mine: BoutonModeAccueil
var _epreuve: BoutonModeAccueil
var _jouer: Button
var _ornement_haut: TextureRect
var _ornement_bas: TextureRect

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mine = MODE.instantiate() as BoutonModeAccueil
	_mine.name = "Mine"
	add_child(_mine)
	_mine.configurer("mine", "Mine")
	_mine.pressed.connect(func(): mine_demandee.emit())
	_jouer = StyleAzur.bouton("Jouer", func(): depart_demande.emit(), true)
	_jouer.name = "Jouer"
	StyleAzur.habiller_accueil(_jouer, true)
	_jouer.add_theme_font_size_override("font_size", 62)
	add_child(_jouer)
	_epreuve = MODE.instantiate() as BoutonModeAccueil
	_epreuve.name = "Epreuves"
	add_child(_epreuve)
	_epreuve.configurer("epreuves", "Épreuves")
	_epreuve.pressed.connect(func(): epreuve_demandee.emit())
	_ornement_haut = _creer_ornement("OrnementHaut")
	_ornement_bas = _creer_ornement("OrnementBas")
	_ornement_bas.flip_v = true
	resized.connect(_replacer)
	_replacer()

func _creer_ornement(nom: String, texture: Texture2D = ORNEMENT) -> TextureRect:
	var ornement := TextureRect.new()
	ornement.name = nom
	ornement.texture = texture
	ornement.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ornement.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ornement.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ornement)
	return ornement

func definir_acces(mine_ouverte: bool, niveau_mine: int, epreuve_ouverte: bool, niveau_epreuve: int) -> void:
	_mine.definir_acces(mine_ouverte, niveau_mine)
	_epreuve.definir_acces(epreuve_ouverte, niveau_epreuve)

func _replacer() -> void:
	if _jouer == null or size.x <= 0.0:
		return
	var largeur_mode := clampf(size.x * 0.17, Ecran.CIBLE_TACTILE, 182.0)
	var hauteur_mode := minf(size.y, largeur_mode + 68.0)
	var largeur_jouer := minf(size.x * 0.64, size.x - largeur_mode * 2.0 - 24.0)
	largeur_jouer = maxf(0.0, largeur_jouer)
	var hauteur_jouer := minf(160.0, size.y * 0.75)
	_mine.position = Vector2(0, (size.y - hauteur_mode) * 0.5)
	_mine.size = Vector2(largeur_mode, hauteur_mode)
	_epreuve.position = Vector2(size.x - largeur_mode, (size.y - hauteur_mode) * 0.5)
	_epreuve.size = Vector2(largeur_mode, hauteur_mode)
	_jouer.position = Vector2((size.x - largeur_jouer) * 0.5, (size.y - hauteur_jouer) * 0.5 - 12.0)
	_jouer.size = Vector2(largeur_jouer, hauteur_jouer)
	var largeur_ornement := minf(178.0, largeur_jouer * 0.33)
	_ornement_haut.position = Vector2((size.x - largeur_ornement) * 0.5, _jouer.position.y - 15.0)
	_ornement_haut.size = Vector2(largeur_ornement, 42.0)
	_ornement_bas.position = Vector2((size.x - largeur_ornement) * 0.5, _jouer.position.y + hauteur_jouer - 28.0)
	_ornement_bas.size = Vector2(largeur_ornement, 42.0)
