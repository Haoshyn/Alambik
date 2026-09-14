class_name PassageManga
extends RefCounted

static func dessiner(surface: Control, dimensions: Vector2, temps: float) -> void:
	surface.draw_rect(Rect2(Vector2.ZERO,dimensions),StyleAzur.PANNEAU)
	var centre := dimensions*0.5
	var rayon := minf(dimensions.x*0.22, 195.0)
	var livre := centre-Vector2(0,240)
	surface.draw_circle(livre,rayon,Color("493459"))
	surface.draw_arc(livre,rayon+14,-2.5,0.4,48,StyleAzur.CORAIL,5.0,true)
	surface.draw_arc(livre,rayon+14,0.65,2.4,36,StyleAzur.CUIVRE,5.0,true)
	var cote := rayon*1.55
	var rebond := sin(temps*2.4)*5.0
	surface.draw_texture_rect(IconesArcane.texture("navigation_sorts"),Rect2(livre-Vector2.ONE*cote*0.5+Vector2(0,rebond),Vector2.ONE*cote),false)
	for index in 3:
		var position := centre+Vector2((index-1)*28.0,116)
		var couleur: Color = [StyleAzur.CORAIL,StyleAzur.MENTHE,StyleAzur.CUIVRE][index]
		surface.draw_circle(position,5.0+sin(temps*3.0-index)*1.5,couleur)
