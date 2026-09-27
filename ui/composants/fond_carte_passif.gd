extends Control

const ACCENTS := {
	"vigueur": Color("ffb56b"), "vitalite": Color("9eecb2"),
	"carapace": Color("a3cfff"), "celerite": Color("ffe185"),
	"pas_leger": Color("bcb0ff"), "oeil_precis": Color("ffe091"),
	"impact_critique": Color("ff9681"), "projectiles_vifs": Color("cfb5ff"),
	"soins_renforces": Color("a5f786"), "recuperation": Color("c4ed87"),
	"moisson_vitale": Color("9eecb2"), "sang_froid": Color("9ddeff"),
	"rempart_initial": Color("a3cfff"), "audace": Color("ff9681"),
	"butin_precieux": Color("ffd9a1"), "savoir_pratique": Color("d5b6ff"),
}

var identifiant := "vigueur"
var _nuance: TextureRect
var _animation: Tween
var _eclat := 0.0

static func accent_pour(id: String) -> Color:
	var accent: Color = ACCENTS.get(id, ACCENTS["vigueur"])
	return accent

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# La couleur se dissipe autour du glyphe, sans enfermer la description.
	var degrade := Gradient.new()
	var accent := accent_pour(identifiant)
	degrade.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	degrade.colors = PackedColorArray([Color(accent, 0.14), Color(accent, 0.05), Color(accent, 0.0)])
	var texture := GradientTexture2D.new()
	texture.gradient = degrade
	texture.width = 128
	texture.height = 96
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.2, 0.3)
	texture.fill_to = Vector2(0.4, 0.3)
	_nuance = TextureRect.new()
	_nuance.name = "NuanceDuGlyphe"
	_nuance.texture = texture
	_nuance.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_nuance.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_nuance)
	_nuance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(queue_redraw)

func _draw() -> void:
	var accent := accent_pour(identifiant)
	var debut := Vector2(32, size.y - 2)
	var fin := Vector2(maxf(32, size.x - 32), size.y - 2)
	draw_line(debut, fin, Color(accent, 0.22 + 0.2 * _eclat), 1.5, true)
	draw_line(debut, debut + Vector2(48, 0), Color(accent, 0.65), 2.0, true)

func illuminer(actif: bool) -> void:
	if not is_inside_tree(): return
	if is_instance_valid(_animation): _animation.kill()
	var cible := 1.0 if actif else 0.0
	if ReglagesJoueur.effets_reduits:
		_definir_eclat(cible)
		return
	_animation = create_tween()
	_animation.tween_method(_definir_eclat, _eclat, cible, 0.15)

func _definir_eclat(valeur: float) -> void:
	_eclat = valeur
	_nuance.modulate.a = 1.0 + valeur * 0.65
	queue_redraw()
