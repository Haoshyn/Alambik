extends Control

const FOND := preload("res://assets/visual/interface/accueil_fond_anime.png")
const MOUVEMENT_DECOR := preload("res://shaders/accueil_vivant.gdshader")

var _taille_image: Vector2
var _plateau: Control
var _matiere_decor: ShaderMaterial

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	_taille_image = FOND.get_size()
	_plateau = Control.new()
	_plateau.name = "Plateau"
	_plateau.size = _taille_image
	_plateau.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_plateau)

	var decor := TextureRect.new()
	decor.name = "Decor"
	decor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	decor.stretch_mode = TextureRect.STRETCH_SCALE
	decor.texture = FOND
	decor.modulate = Color("d2d8ec")
	decor.size = _taille_image
	decor.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	decor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_matiere_decor = ShaderMaterial.new()
	_matiere_decor.shader = MOUVEMENT_DECOR
	decor.material = _matiere_decor
	_plateau.add_child(decor)

	resized.connect(_cadrer)
	ReglagesJoueur.reglages_changes.connect(_actualiser_effets)
	_cadrer()
	_actualiser_effets()

func _cadrer() -> void:
	if _taille_image.x <= 0.0 or _taille_image.y <= 0.0:
		return
	# Une echelle uniforme couvre l'ecran ; seul le surplus est rogne.
	var echelle := maxf(size.x / _taille_image.x, size.y / _taille_image.y)
	_plateau.scale = Vector2.ONE * echelle
	_plateau.position = (size - _taille_image * echelle) * 0.5

func _actualiser_effets() -> void:
	_matiere_decor.set_shader_parameter("intensite", 0.0 if ReglagesJoueur.effets_reduits else 1.0)
