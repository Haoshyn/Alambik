class_name FondMenuVivant
extends Control

const ILLUSTRATION := preload("res://ui/composants/illustration_accueil.gd")
const ILE := preload("res://ui/composants/ile_animee.gd")

var _ile: IleAnimee
var _voile: ColorRect
var _voile_transition: Tween
var _page_secondaire := false
var _voile_cible := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	var clairiere := ILLUSTRATION.new()
	clairiere.name = "ClairierePartagee"
	add_child(clairiere)
	clairiere.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ile = ILE.new()
	_ile.name = "MondePartage"
	add_child(_ile)
	_placer_monde(_cadre_par_defaut())
	_voile = ColorRect.new()
	_voile.name = "VoileDeLecture"
	_voile.color = Color("172143")
	_voile.modulate.a = 0.0
	_voile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_voile)
	_voile.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(_recadrer)
	ReglagesJoueur.reglages_changes.connect(_actualiser_effets)

func afficher_monde(index: int) -> void:
	_ile.afficher_monde(index)

func presenter_page(secondaire: bool) -> void:
	_page_secondaire = secondaire
	_animer_voile(0.55 if secondaire else 0.0)
	if secondaire:
		_centrer_monde()

func presenter_superposition(visible: bool) -> void:
	_animer_voile(0.72 if visible else (0.55 if _page_secondaire else 0.0))

func _animer_voile(opacite: float) -> void:
	_voile_cible = opacite
	if is_instance_valid(_voile_transition):
		_voile_transition.kill()
	if ReglagesJoueur.effets_reduits:
		_voile.modulate.a = opacite
	else:
		_voile_transition = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_voile_transition.tween_property(_voile, "modulate:a", opacite, 0.32)

func _actualiser_effets() -> void:
	if not ReglagesJoueur.effets_reduits:
		return
	if is_instance_valid(_voile_transition):
		_voile_transition.kill()
	_voile.modulate.a = _voile_cible

func suivre_accueil(cadre_global: Rect2) -> void:
	var cadre := Rect2(cadre_global.position - global_position, cadre_global.size)
	_placer_monde(cadre)

func _cadre_par_defaut() -> Rect2:
	var largeur := minf(size.x * 0.607, 655.36)
	var hauteur := largeur * 1.5
	return Rect2(Vector2((size.x - largeur) * 0.5, (size.y - hauteur) * 0.5 - 218.0), Vector2(largeur, hauteur))

func _centrer_monde() -> void:
	_placer_monde(_cadre_par_defaut())

func _placer_monde(cadre: Rect2) -> void:
	if _ile.position.distance_to(cadre.position) > 0.05:
		_ile.position = cadre.position
	if _ile.size.distance_to(cadre.size) > 0.05:
		_ile.size = cadre.size

func _recadrer() -> void:
	if is_instance_valid(_ile) and _page_secondaire:
		_centrer_monde()
