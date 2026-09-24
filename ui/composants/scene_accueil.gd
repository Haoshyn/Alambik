class_name SceneAccueil
extends Control

signal campagne_demandee

const ILE_ANIMEE := preload("res://ui/composants/ile_animee.gd")
const DONNEES := preload("res://data/animations_decors.gd")
const FOND_LEGENDE := preload("res://assets/visual/interface/menu/bandeau_monde_braise.svg")

var ile_externe := false
var _ile: Control
var _animation_ile: IleAnimee
var _texture_monde: Texture2D
var _choisir: Button
var _legende: Panel
var _fond_legende: StyleBoxTexture
var _titre: Label
var _niveau: Label

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
	_legende = Panel.new()
	_legende.name = "LegendeCampagne"
	_legende.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fond_legende = StyleBoxTexture.new()
	_fond_legende.texture = FOND_LEGENDE
	for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		_fond_legende.set_texture_margin(cote, 40)
	_legende.add_theme_stylebox_override("panel", _fond_legende)
	add_child(_legende)
	_choisir = StyleInterface.zone_tactile(func(): campagne_demandee.emit())
	_choisir.name = "ChoisirCampagne"
	_choisir.tooltip_text = "Choisir une campagne"
	add_child(_choisir)
	_titre = StyleAzur.texte("", 46, Color("543446"))
	_titre.name = "TitreCampagne"
	_titre.add_theme_font_override("font", Polices.TITRE)
	_titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_titre.autowrap_mode = TextServer.AUTOWRAP_OFF
	_titre.clip_text = true
	add_child(_titre)
	_niveau = StyleAzur.texte("", 29, Color("6c4d58"))
	_niveau.name = "NiveauCampagne"
	_niveau.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_niveau.autowrap_mode = TextServer.AUTOWRAP_OFF
	_niveau.clip_text = true
	add_child(_niveau)
	resized.connect(_replacer)
	_replacer()

func afficher_campagne(index_monde: int, numero_niveau: int, nom_monde: String) -> void:
	var donnees: Dictionary = DONNEES.MONDES[clampi(index_monde, 0, DONNEES.MONDES.size() - 1)]
	_texture_monde = donnees["image"]
	if is_instance_valid(_animation_ile):
		_animation_ile.afficher_monde(index_monde)
	var monde: Dictionary = Chapitres.MONDES[clampi(index_monde, 0, Chapitres.MONDES.size() - 1)]
	var teinte: Color = monde["teinte"]
	_fond_legende.modulate_color = Color.WHITE.lerp(teinte, 0.05)
	_titre.text = "Monde %d · %s" % [index_monde + 1, nom_monde]
	_niveau.text = "Niveau %d sélectionné  ›" % numero_niveau
	_choisir.accessibility_name = "Choisir une campagne. Monde %d, %s, niveau %d." % [index_monde + 1, nom_monde, numero_niveau]
	_replacer()

func _replacer() -> void:
	if _ile == null or _texture_monde == null or size.x <= 0.0 or size.y <= 0.0:
		return
	var dimensions := _texture_monde.get_size()
	var rapport := dimensions.y / dimensions.x
	var largeur := maxf(0.0, minf(size.x * 0.64, (size.y - 170.0) / rapport))
	var hauteur := largeur * rapport
	var haut := maxf(0.0, (size.y - hauteur - 155.0) * 0.5)
	_ile.position = Vector2((size.x - largeur) * 0.5, haut)
	_ile.size = Vector2(largeur, hauteur)
	var largeur_legende := minf(610.0, size.x - 42.0)
	var haut_legende := minf(size.y - 134.0, haut + hauteur - 8.0)
	_legende.position = Vector2((size.x - largeur_legende) * 0.5, haut_legende)
	_legende.size = Vector2(largeur_legende, 122.0)
	_choisir.position = _ile.position
	_choisir.size = Vector2(_ile.size.x, haut_legende + _legende.size.y - haut)
	_titre.position = _legende.position + Vector2(18, 8)
	_titre.size = Vector2(largeur_legende - 36.0, 62.0)
	_niveau.position = _legende.position + Vector2(18, 65)
	_niveau.size = Vector2(largeur_legende - 36.0, 42.0)

func cadre_monde_global() -> Rect2:
	return _ile.get_global_rect() if is_instance_valid(_ile) else Rect2()
