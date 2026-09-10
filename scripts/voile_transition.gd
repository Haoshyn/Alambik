extends Control

var _anim := 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	var fond := ColorRect.new()
	fond.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fond.z_index = -1
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://shaders/fond_azur.gdshader")
	fond.material = mat
	add_child(fond)
	visibility_changed.connect(func(): set_process(is_visible_in_tree()))

func _process(delta: float) -> void:
	_anim += delta * (0.1 if ReglagesJoueur.effets_reduits else 1.0)
	queue_redraw()

func _draw() -> void:
	var centre := size * 0.5
	var sceau := centre-Vector2(0,180)
	# Le passage reprend les montants du portail, en laissant les titres respirer.
	for cote in [-1.0,1.0]:
		var x: float = centre.x+cote*minf(size.x*0.34,330.0)
		draw_line(Vector2(x,centre.y+245),Vector2(x,centre.y-260),Color(StyleAzur.CUIVRE,0.28),2.0,true)
		draw_line(Vector2(x,centre.y-260),Vector2(centre.x,centre.y-410),Color(StyleAzur.CUIVRE,0.28),2.0,true)
		draw_line(Vector2(centre.x+cote*28,centre.y+116),Vector2(x,centre.y+116),Color(StyleAzur.CUIVRE,0.5),2.0,true)
	var respiration := 0.8+sin(_anim*2)*0.1
	draw_arc(sceau,57,0,TAU,64,Color(StyleAzur.CUIVRE,0.75),2.0,true)
	Dessin.contour(self,Dessin.etoile(sceau,47,12,4,-PI/2),Color(StyleAzur.MAGIE,respiration),2.5)
	draw_circle(sceau,5,StyleAzur.TEXTE)
	draw_colored_polygon(Dessin.polygone_regulier(centre+Vector2(0,116),7,4),StyleAzur.CUIVRE)
