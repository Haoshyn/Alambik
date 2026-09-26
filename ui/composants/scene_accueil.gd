class_name SceneAccueil
extends Control

signal campagne_demandee

const ILE_ANIMEE := preload("res://ui/composants/ile_animee.gd")
const DONNEES := preload("res://data/animations_decors.gd")

var ile_externe := false
var _ile: Control
var _animation_ile: IleAnimee
var _texture_monde: Texture2D
var _choisir: Button

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ile = Control.new()
	_ile.name = "IllustrationCampagne"
	_ile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_ile)
	if not ile_externe:
		_animation_ile = ILE_ANIMEE.new()
		_animation_ile.name = "MondeAnime"
		_ile.add_child(_animation_ile)
		_animation_ile.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_choisir = StyleInterface.zone_tactile(func(): campagne_demandee.emit())
	_choisir.name = "ChoisirCampagneIllustration"
	_choisir.tooltip_text = "Choisir une campagne"
	add_child(_choisir)
	resized.connect(_replacer)
	_replacer()

func afficher_campagne(index_monde: int, numero_niveau: int, nom_monde: String) -> void:
	var donnees: Dictionary = DONNEES.MONDES[clampi(index_monde, 0, DONNEES.MONDES.size() - 1)]
	_texture_monde = donnees["image"]
	if is_instance_valid(_animation_ile):
		_animation_ile.afficher_monde(index_monde)
	_choisir.accessibility_name = "Choisir une campagne. Monde %d, %s, niveau %d." % [index_monde + 1, nom_monde, numero_niveau]
	_replacer()

func _replacer() -> void:
	if _ile == null or _texture_monde == null or size.x <= 0.0 or size.y <= 0.0:
		return
	var dimensions := _texture_monde.get_size()
	var rapport := dimensions.y / dimensions.x
	var largeur := maxf(0.0, minf(size.x * 0.64, (size.y - 24.0) / rapport))
	var hauteur := largeur * rapport
	var haut := maxf(0.0, (size.y - hauteur) * 0.5)
	_ile.position = Vector2((size.x - largeur) * 0.5, haut)
	_ile.size = Vector2(largeur, hauteur)
	_choisir.position = _ile.position
	_choisir.size = _ile.size

func cadre_monde_global() -> Rect2:
	return _ile.get_global_rect() if is_instance_valid(_ile) else Rect2()
