extends Control

const FOND := preload("res://assets/visual/interface/accueil_fond_anime.png")
const MAGE := preload("res://assets/visual/interface/accueil_mage_detoure.png")
const LUEURS := preload("res://ui/composants/lueurs_accueil.gd")
const MOUVEMENT_DECOR := preload("res://shaders/accueil_vivant.gdshader")
const POSITION_MAGE := Vector2(0.25, 0.28)
const ECHELLE_MAGE := 0.45

var _temps := 0.0
var _taille_image: Vector2
var _plateau: Control
var _mage: TextureRect
var _ombre: Control
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
	decor.size = _taille_image
	decor.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	decor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_matiere_decor = ShaderMaterial.new()
	_matiere_decor.shader = MOUVEMENT_DECOR
	decor.material = _matiere_decor
	_plateau.add_child(decor)

	_ombre = Control.new()
	_ombre.name = "Ombre"
	_ombre.size = _taille_image
	_ombre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_plateau.add_child(_ombre)
	_ombre.draw.connect(_dessiner_ombre)
	_ombre.queue_redraw()

	_mage = TextureRect.new()
	_mage.name = "Mage"
	_mage.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_mage.stretch_mode = TextureRect.STRETCH_SCALE
	_mage.texture = MAGE
	_mage.position = _taille_image * POSITION_MAGE
	_mage.size = _taille_image * ECHELLE_MAGE
	_mage.pivot_offset = _mage.size * Vector2(0.50, 0.90)
	_mage.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_mage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_plateau.add_child(_mage)

	var lueurs := Control.new()
	lueurs.name = "Lueurs"
	lueurs.size = _taille_image
	lueurs.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lueurs.set_script(LUEURS)
	_plateau.add_child(lueurs)

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
	set_process(not ReglagesJoueur.effets_reduits)
	_matiere_decor.set_shader_parameter("intensite", 0.0 if ReglagesJoueur.effets_reduits else 1.0)
	if ReglagesJoueur.effets_reduits:
		_mage.scale = Vector2.ONE
		_mage.rotation = 0.0

func _process(delta: float) -> void:
	_temps += delta
	var respiration := sin(_temps * 2.1)
	_mage.scale = Vector2(1.0 + respiration * 0.006, 1.0 + respiration * 0.013)
	_mage.rotation = sin(_temps * 1.25) * 0.006

func _dessiner_ombre() -> void:
	_ombre.draw_set_transform(_taille_image * Vector2(0.50, 0.684), 0.0, Vector2(1.0, 0.22))
	_ombre.draw_circle(Vector2.ZERO, 118.0, Color(0.14, 0.16, 0.32, 0.035))
	_ombre.draw_circle(Vector2.ZERO, 92.0, Color(0.14, 0.16, 0.32, 0.06))
	_ombre.draw_circle(Vector2.ZERO, 65.0, Color(0.14, 0.16, 0.32, 0.07))
