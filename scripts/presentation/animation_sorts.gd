extends RefCounted

const Catalogue = preload("res://data/animations_sorts.gd")

static func creer(id: String, centre: Vector2, rayon: float) -> Dictionary:
	var profil: Dictionary = Catalogue.PROFILS.get(id, {})
	if profil.is_empty():
		return {}
	return {"id": id, "centre": centre, "rayon": rayon, "age": 0.0,
		"duree": float(profil["duree"]), "couleur": profil["couleur"]}

# Les memes segments animes alimentent les rendus 2D et 3D.
static func segments(sort: Dictionary, reduit: bool) -> Array[Dictionary]:
	var resultat: Array[Dictionary] = []
	var t := clampf(float(sort["age"]) / float(sort["duree"]), 0.0, 1.0)
	var centre: Vector2 = sort["centre"]
	var rayon := float(sort["rayon"])
	var couleur: Color = sort["couleur"]
	couleur.a = (1.0 - t) * (0.55 if reduit else 0.85)
	var expansion := 1.0 - pow(1.0 - t, 3.0)
	var nombre := 6 if reduit else 12
	match str(sort["id"]):
		"onde_alchimique":
			for i in (1 if reduit else 3):
				_cercle(resultat, centre, rayon * clampf(expansion - i * 0.14, 0.0, 1.0), couleur)
		"nova_de_givre":
			_cercle(resultat, centre, rayon * expansion, couleur)
			for i in 6:
				var direction := Vector2.RIGHT.rotated(TAU * i / 6.0)
				var bout := centre + direction * rayon * expansion
				_ligne(resultat, centre, bout, couleur)
				for signe in [-1.0, 1.0]:
					_ligne(resultat, centre + direction * rayon * expansion * 0.65,
						bout - direction.rotated(signe * 0.65) * rayon * expansion * 0.4, couleur)
		"barrage_de_braise":
			for i in nombre:
				var direction := Vector2.RIGHT.rotated(TAU * i / float(nombre))
				var point := centre + direction * rayon * (0.25 + 0.65 * expansion)
				var taille := rayon * 0.13 * (1.0 - t)
				_ligne(resultat, point - direction.orthogonal() * taille, point + direction * taille * 2.0, couleur)
				_ligne(resultat, point + direction * taille * 2.0, point + direction.orthogonal() * taille, couleur)
		"impulsion_foudroyante":
			for i in nombre:
				var direction := Vector2.RIGHT.rotated(TAU * i / float(nombre))
				var precedent := centre
				for j in range(1, 5):
					var ecart := sin(float(i * 7 + j * 13) + floorf(t * 8.0) * 2.0) * rayon * 0.1
					var point := centre + direction * rayon * float(j) / 4.0 + direction.orthogonal() * ecart
					_ligne(resultat, precedent, point, couleur)
					precedent = point
		"explosion_corrosive":
			for i in nombre:
				var direction := Vector2.RIGHT.rotated(TAU * i / float(nombre))
				_cercle(resultat, centre + direction * rayon * expansion * 0.7,
					rayon * (0.09 + 0.08 * sin(PI * t)), couleur, 8)
		"vortex_alchimique":
			for i in (3 if reduit else 6):
				var precedent := centre
				for j in range(1, 9):
					var part := float(j) / 8.0
					var angle := TAU * i / (3.0 if reduit else 6.0) + part * PI - t * TAU
					var point := centre + Vector2.RIGHT.rotated(angle) * rayon * part * (1.0 - t)
					_ligne(resultat, precedent, point, couleur)
					precedent = point
		"purification_totale":
			_cercle(resultat, centre, rayon * expansion, couleur)
			for i in nombre:
				var direction := Vector2.RIGHT.rotated(TAU * i / float(nombre))
				var point := centre + direction * rayon * expansion
				var taille := rayon * 0.05 * (1.0 - t)
				_ligne(resultat, point - direction * taille, point + direction * taille, couleur)
				_ligne(resultat, point - direction.orthogonal() * taille, point + direction.orthogonal() * taille, couleur)
		"grand_oeuvre", "transmutation_totale":
			var transmutation := str(sort["id"]) == "transmutation_totale"
			var taille := rayon * (0.3 + 0.65 * expansion)
			_cercle(resultat, centre, taille, couleur)
			var sommets := 6 if transmutation else 3
			for i in sommets:
				var angle := TAU * i / float(sommets) + t * (0.4 if transmutation else -0.4)
				_ligne(resultat, centre + Vector2.RIGHT.rotated(angle) * taille,
					centre + Vector2.RIGHT.rotated(angle + TAU * 2.0 / float(sommets)) * taille, couleur)
			if not reduit:
				_cercle(resultat, centre, taille * 0.65, couleur)
		"temps_suspendu":
			var taille := rayon * 0.8
			_cercle(resultat, centre, taille, couleur)
			for i in 12:
				var direction := Vector2.RIGHT.rotated(TAU * i / 12.0)
				_ligne(resultat, centre + direction * taille * 0.86, centre + direction * taille, couleur)
			var angle := -PI * 0.5 + (1.0 - pow(1.0 - minf(t * 2.0, 1.0), 3.0)) * PI * 0.5
			_ligne(resultat, centre, centre + Vector2.RIGHT.rotated(angle) * taille * 0.75, couleur)
			_ligne(resultat, centre, centre + Vector2.RIGHT.rotated(angle - 1.8) * taille * 0.45, couleur)
	return resultat

static func _ligne(resultat: Array[Dictionary], debut: Vector2, fin: Vector2, couleur: Color) -> void:
	resultat.append({"depart": debut, "arrivee": fin, "couleur": couleur})

static func _cercle(resultat: Array[Dictionary], centre: Vector2, rayon: float, couleur: Color, nombre := 32) -> void:
	for i in nombre:
		_ligne(resultat, centre + Vector2.RIGHT.rotated(TAU * i / float(nombre)) * rayon,
			centre + Vector2.RIGHT.rotated(TAU * (i + 1) / float(nombre)) * rayon, couleur)
