extends RefCounted

func test_tirer_apres_contournement_d_un_pilier_long(v: Verif) -> void:
	var navigation := preload("res://sondes/navigation_bot.gd")
	var limites := Rect2(Vector2(78,244),Vector2(1638,1900))
	var contour := FormesSalles.contour(limites,3)
	var obstacles := [Rect2(limites.position+Vector2(.43,.30)*limites.size,Vector2(.14,.35)*limites.size)]
	var depart := Vector2(823,1499.1)
	var cible := Vector2(795,792)
	v.vrai(not Geometrie.ligne_libre(depart,cible,obstacles,18),"le pilier masque la cible")
	var point := navigation.point_de_tir(depart,cible,limites,obstacles,Reglages.HEROS_RAYON,18,contour)
	v.vrai(point != Vector2.ZERO,"une position accessible permet de tirer derriere le pilier")
	v.vrai(Geometrie.ligne_libre(point,cible,obstacles,18),"le tir ne heurte pas la pierre")
	var trajet := navigation.chemin(depart,point,limites,obstacles,Reglages.HEROS_RAYON,contour)
	v.vrai(trajet.size()>1,"le point est accessible sans traverser le pilier")
	for i in range(1,trajet.size()):
		v.vrai(Geometrie.ligne_libre(trajet[i-1],trajet[i],obstacles,Reglages.HEROS_RAYON-.5),"trajet praticable")
