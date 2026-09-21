extends RefCounted

const Catalogue = preload("res://data/animations_augments.gd")
const Formes = preload("res://scripts/presentation/animation_sorts.gd")

static func creer(id: String, centre: Vector2, rayon: float, arrivee: Vector2) -> Dictionary:
	var profil: Dictionary = Catalogue.PROFILS.get(id, {})
	if profil.is_empty():
		return {}
	return {"id": id, "centre": centre, "rayon": rayon, "arrivee": arrivee,
		"age": 0.0, "duree": float(profil["duree"]), "couleur": profil["couleur"]}

static func segments(animation: Dictionary, reduit: bool) -> Array[Dictionary]:
	var resultat: Array[Dictionary] = []
	var t := clampf(float(animation["age"]) / float(animation["duree"]), 0.0, 1.0)
	var centre: Vector2 = animation["centre"]
	var rayon := float(animation["rayon"])
	var teinte: Color = animation["couleur"]
	var couleur := Color(teinte, (1.0 - t) * (0.55 if reduit else 0.9))
	var expansion := 1.0 - pow(1.0 - t, 3.0)
	var nombre := 5 if reduit else 10
	match str(animation["id"]):
		"chute_meteore":
			var chute := t * t
			var point := centre + Vector2(-65.0, -35.0) * (1.0 - chute)
			var hauteur := 3.4 * (1.0 - chute) + 0.08
			var feu := Color(teinte, 0.65 if reduit else 0.95)
			Formes._anneau(resultat, centre, rayon * 0.4, 2.5, Color(teinte, 0.25 + t * 0.2))
			# La queue accompagne le volume jusqu'au contact, sans cacher la cible.
			Formes._ruban(resultat, point + Vector2(-45.0, -25.0), point, Color(feu, 0.3), 24.0, hauteur + 1.0, hauteur)
			Formes._ruban(resultat, point + Vector2(-30.0, -16.0), point, feu, 9.0, hauteur + 0.7, hauteur)
			Formes._cristal(resultat, point, -0.4 + t * 3.0, 19.0, Color("805349"), hauteur, hauteur + 0.27)
			Formes._cristal(resultat, point + Vector2(3.0, 3.0), t * 4.0, 12.0, feu, hauteur + 0.03, hauteur + 0.3)
		"impact_meteore":
			Formes._anneau(resultat, centre, rayon * expansion, 10.0 * (1.0 - t) + 1.0, couleur)
			Formes._anneau(resultat, centre, rayon * expansion * 0.65, 4.0, Color(teinte.lightened(0.6), couleur.a))
			for i in nombre:
				var angle := TAU * i / float(nombre)
				var point := centre + Vector2.from_angle(angle) * rayon * expansion * 0.85
				var hauteur := sin(t * PI) * (0.3 + float(i % 3) * 0.15)
				Formes._flamme(resultat, point, angle, 16.0 * (1.0 - t), t, couleur, hauteur)
				Formes._cristal(resultat, point, angle + t * 4.0, 7.0 * (1.0 - t), Color(Color("b78762"), couleur.a), hauteur, hauteur + 0.1)
		"chaine_alchimique":
			var arrivee: Vector2 = animation["arrivee"]
			var trajet := arrivee - centre
			var normale := trajet.normalized().orthogonal()
			var precedent := centre
			for i in range(1, 9):
				var part := float(i) / 8.0
				var ecart := sin(float(i) * 13.0 + (0.0 if reduit else floorf(t * 4.0))) * sin(PI * part) * 13.0
				var point := centre + trajet * part + normale * ecart
				Formes._ruban(resultat, precedent, point, couleur, 7.0, 0.18, 0.18)
				Formes._ruban(resultat, precedent, point, Color(teinte.lightened(0.8), couleur.a), 2.0, 0.19, 0.19)
				precedent = point
			Formes._anneau(resultat, arrivee, 9.0 + expansion * 18.0, 3.0, couleur, 0.12, 20)
		"onde_de_choc":
			Formes._anneau(resultat, centre, rayon * expansion, 11.0 * (1.0 - t) + 1.0, couleur)
			Formes._anneau(resultat, centre, rayon * expansion * 0.85, 3.0, couleur, 0.15)
			for i in nombre:
				var direction := Vector2.from_angle(TAU * i / float(nombre))
				Formes._ruban(resultat, centre + direction * rayon * expansion * 0.7,
					centre + direction * rayon * expansion, couleur, 4.0)
		"zone_heros":
			Formes._anneau(resultat, centre, rayon * (0.7 + t * 0.3), 3.0, couleur)
			for i in 6:
				var angle := TAU * i / 6.0 + t * 0.2
				var point := centre + Vector2.from_angle(angle) * rayon * 0.78
				Formes._cristal(resultat, point, angle, 6.0, couleur, 0.05, 0.08 + sin(PI * t) * 0.15)
		"orbes_chargees":
			Formes._anneau(resultat, centre, 12.0 + t * 20.0, 3.0, couleur, 0.2, 24)
			Formes._etincelles(resultat, centre, 40.0, t, couleur, nombre, true)
		"frappe_gardien":
			var arrivee: Vector2 = animation["arrivee"]
			var axe := centre.direction_to(arrivee).angle()
			var distance := centre.distance_to(arrivee)
			for i in 12:
				var angle := axe - 0.8 + float(i) * 1.6 / 12.0 + t * 0.4
				Formes._ruban(resultat, centre + Vector2.from_angle(angle) * distance,
					centre + Vector2.from_angle(angle + 1.6 / 12.0) * distance,
					couleur, 5.0 * sin(PI * float(i + 1) / 13.0), 0.22, 0.22)
			Formes._etincelles(resultat, arrivee, 25.0, t, couleur, nombre, true)
	return resultat
