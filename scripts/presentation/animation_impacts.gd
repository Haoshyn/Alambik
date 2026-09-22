extends RefCounted

const Rendu = preload("res://data/animations_combat.gd")

static func creer(centre: Vector2, couleur: Color, ampleur: float, mort: bool) -> Dictionary:
	return {"centre": centre, "couleur": couleur, "age": 0.0, "mort": mort,
		"rayon": (Rendu.DISSIPATION_RAYON if mort else Rendu.PERCUSSION_RAYON) * ampleur,
		"duree": Rendu.DISSIPATION_DUREE if mort else Rendu.PERCUSSION_DUREE}

static func segments(effet: Dictionary, reduit: bool) -> Array[Dictionary]:
	var resultat: Array[Dictionary] = []
	var t := clampf(float(effet["age"]) / float(effet["duree"]), 0.0, 1.0)
	var centre: Vector2 = effet["centre"]
	var couleur: Color = effet["couleur"]
	var rayon := float(effet["rayon"])
	var mort := bool(effet["mort"])
	var opacite := pow(1.0 - t, 2.0) * (0.55 if reduit else 0.85)
	var expansion := 1.0 - pow(1.0 - t, 3.0)
	var nombre := 4 if reduit else (9 if mort else 6)
	var orientation := fposmod(centre.x * 0.17 + centre.y * 0.31, TAU)
	for i in nombre:
		var angle := orientation + TAU * float(i) / float(nombre)
		var direction := Vector2.from_angle(angle)
		var distance := rayon * (0.16 + expansion * (0.6 + 0.18 * sin(float(i * 11))))
		var point := centre + direction * distance
		var taille := rayon * (0.11 if mort else 0.075) * (1.0 - t)
		var hauteur := 0.12 + (sin(t * PI) * 0.35 if mort else 0.0)
		var teinte := Color(couleur.lightened(0.6 if i % 2 == 0 else 0.1), opacite)
		resultat.append({"points": [point + direction * taille * 2.0,
			point - direction * taille + direction.orthogonal() * taille * 0.5,
			point - direction * taille - direction.orthogonal() * taille * 0.5],
			"hauteurs": [hauteur, hauteur, hauteur], "couleur": teinte})
		if t < 0.45:
			_trait(resultat, centre + direction * rayon * 0.08, point, Color(teinte, opacite * (1.0 - t / 0.45)), 3.0, 0.14)
	var divisions := 16 if reduit else 32
	var couronne := rayon * (0.2 + expansion * 0.8)
	for i in divisions:
		if mort and i % 4 == 0: continue
		var a := centre + Vector2.from_angle(TAU * float(i) / divisions) * couronne
		var b := centre + Vector2.from_angle(TAU * float(i + 1) / divisions) * couronne
		_trait(resultat, a, b, Color(couleur, opacite * 0.5), (5.0 if mort else 3.0) * (1.0 - t), 0.035)
	return resultat

static func _trait(resultat: Array[Dictionary], a: Vector2, b: Vector2, couleur: Color, largeur: float, hauteur: float) -> void:
	resultat.append({"depart": a, "arrivee": b, "couleur": couleur, "largeur": largeur,
		"hauteur": hauteur, "hauteur_fin": hauteur})
