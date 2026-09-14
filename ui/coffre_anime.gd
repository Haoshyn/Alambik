extends Button

var ouverture := 0.0:
	set(valeur):
		ouverture = valeur
		queue_redraw()
var rang := 0

func _ready() -> void:
	custom_minimum_size = Vector2(0, 350)
	for etat in ["normal", "hover", "pressed", "disabled"]:
		add_theme_stylebox_override(etat, StyleBoxEmpty.new())
	tooltip_text = "Ouvrir le coffre"

func _draw() -> void:
	var centre := size * Vector2(0.5, 0.55)
	var or_ := Color("f1c36d")
	var fond: Color = [Color("877496"), Color("bc8064"), Color("96aacd"), Color("d1a64f"), Color("af8add")][clampi(rang, 0, 4)]
	if ouverture > 0.0:
		draw_circle(centre, 118 + ouverture * 34, Color(1.0, 0.8, 0.35, ouverture * 0.12))
		for i in 10:
			var direction := Vector2.from_angle(float(i) * TAU / 10.0)
			draw_line(centre + direction * 120, centre + direction * (120 + ouverture * 55), Color(or_, ouverture * 0.65), 4, true)
	var corps := Rect2(centre + Vector2(-120, -25), Vector2(240, 118))
	draw_style_box(StyleAzur.cadre(fond.darkened(0.2), Color("382743")), corps)
	for x in [-80.0, 60.0]: draw_rect(Rect2(centre + Vector2(x, -25), Vector2(20, 115)), or_)
	draw_line(centre + Vector2(-109, 64), centre + Vector2(109, 64), fond.lightened(0.2), 3, true)
	var hauteur := 62.0 * (1.0 - ouverture * 0.35)
	var couvercle := Rect2(centre + Vector2(-125, -82 - ouverture * 68), Vector2(250, hauteur))
	draw_style_box(StyleAzur.cadre(fond.lightened(0.12), Color("382743")), couvercle)
	draw_line(couvercle.position + Vector2(18, 14), couvercle.position + Vector2(225, 14), or_, 6, true)
	draw_style_box(StyleAzur.cadre(or_, Color("382743")), Rect2(centre + Vector2(-19, -38 - ouverture * 95), Vector2(38, 42)))
	draw_circle(centre + Vector2(0, -22 - ouverture * 95), 6, Color("382743"))
