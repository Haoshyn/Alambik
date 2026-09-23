class_name CommandeDepart
extends Control

signal depart_demande
signal mine_demandee
signal epreuve_demandee

const MODE := preload("res://ui/composants/bouton_mode_accueil.tscn")

var _mine: BoutonModeAccueil
var _epreuve: BoutonModeAccueil
var _jouer: Button

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mine = MODE.instantiate() as BoutonModeAccueil
	_mine.name = "Mine"
	add_child(_mine)
	_mine.configurer("mine", "Mine")
	_mine.pressed.connect(func(): mine_demandee.emit())
	_jouer = StyleAzur.bouton("JOUER", func(): depart_demande.emit(), true)
	_jouer.name = "Jouer"
	StyleAzur.habiller_accueil(_jouer, true)
	_jouer.add_theme_font_size_override("font_size", 61)
	add_child(_jouer)
	_epreuve = MODE.instantiate() as BoutonModeAccueil
	_epreuve.name = "Epreuves"
	add_child(_epreuve)
	_epreuve.configurer("epreuves", "Épreuves")
	_epreuve.pressed.connect(func(): epreuve_demandee.emit())
	resized.connect(_replacer)
	_replacer()

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
