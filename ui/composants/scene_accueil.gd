class_name SceneAccueil
extends Control

signal mine_demandee
signal epreuve_demandee

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
	if _mine == null or _epreuve == null: return
	var largeur_mode := clampf(size.x * 0.22, Ecran.CIBLE_TACTILE, 176.0)
	var hauteur_mode := largeur_mode + 72.0
	var position_modes := maxf(0.0, size.y - hauteur_mode - 8.0)
	_mine.position = Vector2(0, position_modes)
	_epreuve.position = Vector2(size.x - largeur_mode, position_modes)
	_mine.size = Vector2(largeur_mode, hauteur_mode)
	_epreuve.size = Vector2(largeur_mode, hauteur_mode)
