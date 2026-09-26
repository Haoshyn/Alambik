extends Control

const ATLAS := preload("res://assets/visual/interface/menu/sorts/fonds_elementaires.png")
const MATIERE := preload("res://shaders/carte_sort_peinte.gdshader")
const AMBIANCES := {
	"onde_alchimique": [0, Color("bcb0ff")], "nova_de_givre": [1, Color("8fe8ff")],
	"barrage_de_braise": [2, Color("ffb56b")], "impulsion_foudroyante": [3, Color("ffe185")],
	"explosion_corrosive": [4, Color("a5f786")], "vortex_alchimique": [5, Color("d1a1ff")],
	"moisson_vitale": [4, Color("9eecb2")], "sang_froid": [1, Color("9ddeff")],
	"riposte_alchimique": [2, Color("ffb58a")], "reserve_ultime": [5, Color("d5b6ff")],
	"rempart_initial": [1, Color("a3cfff")], "heritage_reactif": [4, Color("c4ed87")],
	"audace": [2, Color("ff9681")], "echo_alchimique": [0, Color("cfb5ff")],
	"grand_oeuvre": [3, Color("ffe091")], "temps_suspendu": [1, Color("a0e8ff")],
	"transmutation_totale": [4, Color("d6f39b")], "purification_totale": [3, Color("ffd9a1")],
}

var identifiant := "onde_alchimique"
var _matiere: ShaderMaterial
var _cadre: Panel
var _animation: Tween
var _eclat := 0.0

static func accent_pour(id: String) -> Color:
	var ambiance: Array = AMBIANCES.get(id, AMBIANCES["onde_alchimique"])
	return ambiance[1] as Color

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ambiance: Array = AMBIANCES.get(identifiant, AMBIANCES["onde_alchimique"])
	var index := int(ambiance[0])
	var peinture := TextureRect.new()
	peinture.name = "PeintureElementaire"
	peinture.texture = ATLAS
	peinture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	peinture.stretch_mode = TextureRect.STRETCH_SCALE
	peinture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	peinture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_matiere = ShaderMaterial.new()
	_matiere.shader = MATIERE
	_matiere.set_shader_parameter("region", Vector4(float(index % 2) * 0.5, float(index / 2) / 3.0, 0.5, 1.0 / 3.0))
	peinture.material = _matiere
	add_child(peinture)
	peinture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cadre = Panel.new()
	_cadre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cadre.add_theme_stylebox_override("panel", StyleAzur.cadre_enlumine(accent_pour(identifiant), false, false))
	add_child(_cadre)
	_cadre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(_cadrer)
	_cadrer()

func _cadrer() -> void:
	_matiere.set_shader_parameter("dimensions", size)

func illuminer(actif: bool) -> void:
	if not is_inside_tree(): return
	if is_instance_valid(_animation): _animation.kill()
	_cadre.add_theme_stylebox_override("panel", StyleAzur.cadre_enlumine(accent_pour(identifiant), actif, false))
	var cible := 1.0 if actif else 0.0
	if ReglagesJoueur.effets_reduits:
		_definir_eclat(cible)
		return
	_animation = create_tween()
	_animation.tween_method(_definir_eclat, _eclat, cible, 0.15)

func _definir_eclat(valeur: float) -> void:
	_eclat = valeur
	_matiere.set_shader_parameter("eclat", valeur)
