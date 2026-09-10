extends RefCounted

const ECRAN := preload("res://autoload/ecran.gd")

func test_encoche_dans_les_bandes(v: Verif) -> void:
	var visible := Rect2(0,0,1080,1920)
	var transformation := Transform2D(Vector2(0.5,0),Vector2(0,0.5),Vector2(0,120))
	v.egal(ECRAN.convertir_zone_sure(visible,Rect2(0,60,540,1100),transformation),visible,
		"une encoche dans la bande ne mange pas le contenu")
	v.egal(ECRAN.convertir_zone_sure(visible,Rect2(0,140,540,900),transformation),Rect2(0,40,1080,1800),
		"encoche et barre systeme converties dans le cadre logique")
	v.egal(ECRAN.convertir_zone_sure(visible,Rect2(),transformation),visible,
		"zone systeme inconnue sans faire disparaitre les menus")
