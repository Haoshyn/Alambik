class_name SceneAccueil
extends Control

signal mine_demandee
signal epreuve_demandee

@onready var _heros: Control = $Heros
@onready var _mine: BoutonModeAccueil = $Mine
@onready var _epreuve: BoutonModeAccueil = $Epreuves

func _ready() -> void:
	_mine.configurer("mine", "La Mine")
	_epreuve.configurer("epreuves", "Épreuves")
	_mine.pressed.connect(func(): mine_demandee.emit())
	_epreuve.pressed.connect(func(): epreuve_demandee.emit())
	resized.connect(_replacer)
	_replacer()

func definir_acces(mine_ouverte: bool, niveau_mine: int, epreuve_ouverte: bool, niveau_epreuve: int) -> void:
	_mine.definir_acces(mine_ouverte, niveau_mine)
	_epreuve.definir_acces(epreuve_ouverte, niveau_epreuve)

func _replacer() -> void:
	if _heros == null: return
	# Les sceaux gardent leurs cibles tactiles ; l'espace restant appartient au heros.
	var largeur_mode := clampf(size.x * 0.22, Ecran.CIBLE_TACTILE, 176.0)
	var hauteur_mode := largeur_mode + 72.0
	var espace := largeur_mode + 12.0
	var largeur_heros := maxf(0.0, size.x - espace * 2.0)
	var hauteur_heros := minf(size.y, largeur_heros * 1.65)
	_heros.position = Vector2(espace, size.y - hauteur_heros)
	_heros.size = Vector2(largeur_heros, hauteur_heros)
	var position_modes := clampf(size.y * 0.58 - hauteur_mode * 0.5, 0.0, maxf(0.0, size.y - hauteur_mode))
	_mine.position = Vector2(0, position_modes)
	_epreuve.position = Vector2(size.x - largeur_mode, maxf(0, position_modes - 100))
	_mine.size = Vector2(largeur_mode, hauteur_mode)
	_epreuve.size = Vector2(largeur_mode, hauteur_mode)
