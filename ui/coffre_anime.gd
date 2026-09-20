extends Button

var ouverture := 0.0:
	set(valeur):
		ouverture = clampf(valeur, 0.0, 1.0)
		queue_redraw()
var rang := 0

var _corps: Texture2D
var _couvercle: Texture2D
var _halo: Texture2D

func _ready() -> void:
	HabillagePeint.appliquer(self)
	custom_minimum_size = Vector2(0, 360)
	focus_mode = Control.FOCUS_NONE
	action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	for etat in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(etat, StyleBoxEmpty.new())
	_corps = StyleAzur.texture_interface("coffre_corps")
	_couvercle = StyleAzur.texture_interface("coffre_couvercle")
	_halo = StyleAzur.texture_interface("halo_recompense")
	tooltip_text = "Ouvrir le coffre de l’aventure"

func _draw() -> void:
	if _corps == null or _couvercle == null:
		return
	var centre := size * Vector2(0.5, 0.51)
	var couleurs: Array[Color] = [Color("c5cde1"), Color("e2ae85"), Color("9fd5ee"), Color("ffe0a0"), Color("d3adff")]
	var teinte := couleurs[clampi(rang, 0, couleurs.size() - 1)]
	var cote_halo := 300.0 + ouverture * 100.0
	if _halo != null:
		draw_texture_rect(_halo, Rect2(centre - Vector2.ONE * cote_halo * 0.5, Vector2.ONE * cote_halo), false, Color(teinte, 0.32 + ouverture * 0.68))
	var decalage := Vector2(0, 4) if is_pressed() else Vector2.ZERO
	var teinte_coffre := Color.WHITE.lerp(teinte, 0.25)
	draw_texture_rect(_corps, Rect2(centre + Vector2(-160, -18) + decalage, Vector2(320, 160)), false, teinte_coffre)
	var hauteur := 160.0 * (1.0 - ouverture * 0.22)
	var levee := ouverture * (34.0 if ReglagesJoueur.effets_reduits else 76.0)
	draw_texture_rect(_couvercle, Rect2(centre + Vector2(-160, -114 - levee) + decalage, Vector2(320, hauteur)), false, teinte_coffre)
