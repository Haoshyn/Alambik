extends RefCounted

const Catalogue = preload("res://data/animations_sorts.gd")

static func creer(id: String, centre: Vector2, rayon: float) -> Dictionary:
	var profil: Dictionary = Catalogue.PROFILS.get(id, {})
	if profil.is_empty():
		return {}
	return {"id": id, "centre": centre, "rayon": rayon, "age": 0.0,
		"duree": float(profil["duree"]), "couleur": profil["couleur"]}

# La percussion commence avec les degats ; seule la traine persiste.
# La geometrie partagee preserve les signatures dans le rendu de secours.
static func segments(sort: Dictionary, reduit: bool) -> Array[Dictionary]:
	var resultat: Array[Dictionary] = []
	var t := clampf(float(sort["age"]) / float(sort["duree"]), 0.0, 1.0)
	var centre: Vector2 = sort["centre"]
	var rayon := float(sort["rayon"])
	var teinte: Color = sort["couleur"]
	var opacite := (1.0 - smoothstep(0.18, 1.0, t)) * (0.52 if reduit else 0.85)
	var couleur := Color(teinte, opacite)
	var creme := Color(teinte.lightened(0.72), opacite)
	var or_chaud := Color(Color("ffdb91"), opacite * 0.8)
	var expansion := 1.0 - pow(1.0 - t, 4.0)
	var nombre := 6 if reduit else 12
	var ultime := str(sort["id"]) in Catalogue.ULTIMES
	_percussion(resultat, centre, rayon, teinte, float(sort["age"]), ultime, reduit)
	match str(sort["id"]):
		"onde_alchimique":
			for i in (2 if reduit else 3):
				var vague := clampf(expansion - i * 0.13, 0.02, 1.0)
				_anneau(resultat, centre, rayon * vague, 9.0 * (1.0 - t) + 1.0, couleur, 0.04 + i * 0.09)
			_sceau(resultat, centre, rayon * 0.43, -t * 0.5, or_chaud, reduit)
			_etincelles(resultat, centre, rayon, t, creme, nombre, false)
		"nova_de_givre":
			_anneau(resultat, centre, rayon * expansion, 5.0, couleur)
			for i in nombre:
				var angle := TAU * i / float(nombre)
				var direction := Vector2.from_angle(angle)
				var pousse := clampf(t * 7.0 - float(i % 3) * 0.23, 0.0, 1.0)
				var point := centre + direction * rayon * (0.45 + 0.4 * float(i % 2)) * expansion
				_cristal(resultat, point, angle, rayon * 0.12 * pousse, couleur, 0.1, 0.55 * pousse)
				_ruban(resultat, centre + direction * rayon * 0.15, point, creme, 2.0)
				for signe in [-1.0, 1.0]:
					_ruban(resultat, point - direction * rayon * 0.2,
						point - direction.rotated(signe * 0.55) * rayon * 0.34, couleur, 3.0)
		"barrage_de_braise":
			_anneau(resultat, centre, rayon * expansion, 8.0 * (1.0 - t), Color(teinte, opacite * 0.4))
			for i in nombre:
				var phase := clampf(t * 1.7 - float(i % 3) * 0.13, 0.0, 1.0)
				var angle := TAU * i / float(nombre) + 0.18 * sin(float(i * 7))
				var direction := Vector2.from_angle(angle)
				var point := centre + direction * rayon * (0.12 + 0.78 * phase)
				var hauteur := sin(phase * PI) * 0.8
				var braise := Color(teinte, opacite * (1.0 - phase))
				_ruban(resultat, point - direction * rayon * 0.2, point, braise, 12.0 * (1.0 - phase), hauteur * 0.5, hauteur)
				_flamme(resultat, point, angle, 18.0 * (1.0 - phase), phase, braise, hauteur)
			_etincelles(resultat, centre, rayon, t, creme, nombre, true)
		"impulsion_foudroyante":
			_anneau(resultat, centre, rayon * expansion, 4.0, couleur)
			for i in nombre:
				var direction := Vector2.from_angle(TAU * i / float(nombre))
				var precedent := centre + direction * rayon * 0.08
				for j in range(1, 6):
					var battement := 0.0 if reduit else sin(t * TAU * 2.0) * 0.18 * (1.0 - t)
					var ecart := sin(float(i * 7 + j * 13) + battement) * rayon * 0.13
					var point := centre + direction * rayon * float(j) / 5.0 + direction.orthogonal() * ecart
					_ruban(resultat, precedent, point, couleur, 8.0, 0.12, 0.12)
					_ruban(resultat, precedent, point, creme, 2.0, 0.13, 0.13)
					if j == 3:
						_ruban(resultat, point, point + direction.rotated(0.8) * rayon * 0.3, couleur, 3.0, 0.12, 0.4)
					precedent = point
		"explosion_corrosive":
			_anneau(resultat, centre, rayon * expansion, 7.0 * (1.0 - t), Color(couleur, opacite * 0.45))
			for i in nombre:
				var angle := TAU * i / float(nombre)
				var point := centre + Vector2.from_angle(angle) * rayon * (0.3 + 0.48 * expansion)
				var phase_bulle := clampf((t - float(i % 3) * 0.08) / 0.65, 0.0, 1.0)
				var taille := rayon * 0.10 * sin(PI * phase_bulle)
				_anneau(resultat, point, taille, 5.0, couleur, 0.03, 16)
				var hauteur := phase_bulle * (0.3 + 0.16 * float(i % 3))
				_bulle(resultat, point, taille * 0.5, couleur, hauteur)
			_sceau(resultat, centre, rayon * 0.35, t * 0.2, couleur, reduit)
		"vortex_alchimique":
			_anneau(resultat, centre, rayon * (0.18 + 0.08 * sin(t * PI)), 6.0 * (1.0 - t), creme, 0.12)
			for i in (3 if reduit else 5):
				var precedent := centre
				var hauteur_precedente := 0.75
				for j in range(1, 19):
					var part := float(j) / 18.0
					var angle := TAU * i / (3.0 if reduit else 5.0) + part * TAU - t * TAU * 1.5
					var point := centre + Vector2.from_angle(angle) * rayon * part * (1.0 - t * 0.55)
					var hauteur := (1.0 - part) * 0.75
					_ruban(resultat, precedent, point, couleur, 2.0 + 9.0 * part, hauteur_precedente, hauteur)
					precedent = point
					hauteur_precedente = hauteur
			_etincelles(resultat, centre, rayon, t, creme, nombre, true, true)
		"grand_oeuvre":
			_sceau(resultat, centre, rayon * (0.22 + 0.3 * expansion), t * 0.25, or_chaud, reduit)
			_anneau(resultat, centre, rayon * expansion, 12.0 * (1.0 - t), couleur)
			for i in (3 if reduit else 6):
				var angle := TAU * i / (3.0 if reduit else 6.0) + t * 0.35
				var point := centre + Vector2.from_angle(angle) * rayon * 0.34
				_cristal(resultat, point, angle, 22.0 * sin(PI * t), or_chaud, 0.15, 1.1)
				_ruban(resultat, point, point, Color(creme, opacite * 0.3), 14.0, 0.0, 2.2 * sin(PI * t))
			_etincelles(resultat, centre, rayon, t, creme, nombre, true)
		"temps_suspendu":
			var taille := rayon * (0.43 + 0.06 * expansion)
			_anneau(resultat, centre, taille, 4.0, or_chaud)
			_anneau(resultat, centre, taille * 0.9, 2.0, couleur)
			for i in 12:
				var direction := Vector2.from_angle(TAU * i / 12.0)
				_ruban(resultat, centre + direction * taille * 0.82, centre + direction * taille * 0.96, or_chaud, 4.0)
			var angle := -PI * 0.5 + (1.0 - pow(1.0 - minf(t * 3.0, 1.0), 3.0)) * PI * 0.5
			_ruban(resultat, centre, centre + Vector2.from_angle(angle) * taille * 0.73, creme, 5.0)
			_ruban(resultat, centre, centre + Vector2.from_angle(angle - 1.8) * taille * 0.45, or_chaud, 7.0)
			# Les fragments se figent avec les aiguilles avant de se dissoudre.
			_etincelles(resultat, centre, rayon * 0.8, minf(t, 0.32), couleur, nombre, true)
		"transmutation_totale":
			_sceau(resultat, centre, rayon * (0.22 + expansion * 0.25), -t * 0.3, or_chaud, reduit)
			for i in nombre:
				var angle := TAU * i / float(nombre) + t * 0.4
				var point := centre + Vector2.from_angle(angle) * rayon * (0.25 + 0.55 * expansion)
				var transformation := smoothstep(0.15, 0.7, t)
				var facette := couleur.lerp(or_chaud, transformation)
				_cristal(resultat, point, angle + t * PI, 22.0 * sin(PI * t), facette, 0.12, 0.6)
				_anneau(resultat, point, 28.0 * expansion, 2.0, facette, 0.04, 6)
			_anneau(resultat, centre, rayon * expansion, 6.0, couleur)
		"purification_totale":
			for i in (2 if reduit else 3):
				var vague := clampf(expansion - i * 0.12, 0.01, 1.0)
				_anneau(resultat, centre, rayon * vague, 10.0 * (1.0 - t) + 1.0, couleur, i * 0.18)
			for i in nombre:
				var angle := TAU * i / float(nombre)
				var direction := Vector2.from_angle(angle)
				var point := centre + direction * rayon * (0.2 + 0.7 * expansion)
				var taille := 24.0 * sin(PI * t)
				_cristal(resultat, point, angle, taille, creme, 0.2, 0.6)
				_ruban(resultat, point - direction.orthogonal() * taille, point + direction.orthogonal() * taille, or_chaud, 3.0, 0.25, 0.25)
	return resultat

static func _percussion(resultat: Array[Dictionary], centre: Vector2, rayon: float,
		teinte: Color, age: float, ultime: bool, reduit: bool) -> void:
	var duree := Catalogue.PERCUSSION_DUREE_ULTIME if ultime else Catalogue.PERCUSSION_DUREE
	var t := clampf(age / duree, 0.0, 1.0)
	if t >= 1.0: return
	var expansion := 1.0 - pow(1.0 - t, 3.0)
	var force := pow(1.0 - t, 2.0) * (0.45 if reduit else 0.75)
	var coeur := Color(teinte.lightened(0.85), force)
	var taille := rayon * (0.06 + expansion * 0.18)
	var nombre := 4 if reduit else (8 if ultime else 6)
	for i in nombre:
		var direction := Vector2.from_angle(TAU * float(i) / nombre + PI * 0.25)
		var pointe := centre + direction * taille * (1.6 if i % 2 == 0 else 1.0)
		var cote := direction.orthogonal() * taille * 0.12 * (1.0 - t)
		_triangle(resultat, [centre + cote, centre - cote, pointe], [0.12, 0.12, 0.12], coeur)
	_anneau(resultat, centre, rayon * (0.08 + 0.42 * expansion), 10.0 * (1.0 - t), Color(teinte, force * 0.65), 0.035, 24 if reduit else 48)

static func _ruban(resultat: Array[Dictionary], debut: Vector2, fin: Vector2, couleur: Color,
		largeur := 3.0, hauteur := 0.04, hauteur_fin := -1.0) -> void:
	if couleur.a <= 0.005 or largeur <= 0.01:
		return
	resultat.append({"depart": debut, "arrivee": fin, "couleur": couleur, "largeur": largeur,
		"hauteur": hauteur, "hauteur_fin": hauteur if hauteur_fin < 0.0 else hauteur_fin})

static func _anneau(resultat: Array[Dictionary], centre: Vector2, rayon: float, largeur: float,
		couleur: Color, hauteur := 0.04, nombre := 48) -> void:
	for i in nombre:
		_ruban(resultat, centre + Vector2.from_angle(TAU * i / float(nombre)) * rayon,
			centre + Vector2.from_angle(TAU * (i + 1) / float(nombre)) * rayon, couleur, largeur, hauteur)

static func _triangle(resultat: Array[Dictionary], points: Array[Vector2], hauteurs: Array[float], couleur: Color) -> void:
	if couleur.a <= 0.005 or absf((points[1] - points[0]).cross(points[2] - points[0])) < 0.01:
		return
	resultat.append({"points": points, "hauteurs": hauteurs, "couleur": couleur})

static func _flamme(resultat: Array[Dictionary], centre: Vector2, angle: float, taille: float,
		phase: float, couleur: Color, hauteur: float) -> void:
	var direction := Vector2.from_angle(angle)
	var cote := direction.orthogonal()
	var pointe := centre + direction * taille * 1.8 + cote * sin(phase * TAU) * taille * 0.4
	var gauche := centre - direction * taille * 0.5 + cote * taille * 0.5
	var droite := centre - direction * taille * 0.5 - cote * taille * 0.5
	var milieu := centre + direction * taille * 0.25
	_triangle(resultat, [gauche, milieu, pointe], [hauteur, hauteur + 0.08, hauteur + 0.24], couleur)
	_triangle(resultat, [milieu, droite, pointe], [hauteur + 0.08, hauteur, hauteur + 0.24], couleur)
	_triangle(resultat, [gauche, droite, milieu], [hauteur, hauteur, hauteur + 0.08], Color(couleur.lightened(0.65), couleur.a))

static func _bulle(resultat: Array[Dictionary], centre: Vector2, rayon: float, couleur: Color, hauteur: float) -> void:
	for i in 12:
		var debut := centre + Vector2.from_angle(TAU * i / 12.0) * rayon
		var fin := centre + Vector2.from_angle(TAU * (i + 1) / 12.0) * rayon
		var facette := Color(couleur.lightened(0.2 + 0.2 * sin(TAU * i / 12.0)), couleur.a * 0.65)
		_triangle(resultat, [centre, debut, fin], [hauteur + rayon * 0.008, hauteur, hauteur], facette)
	_anneau(resultat, centre, rayon, 1.5, Color(couleur.lightened(0.6), couleur.a), hauteur, 12)

static func _cristal(resultat: Array[Dictionary], centre: Vector2, angle: float, taille: float,
		couleur: Color, hauteur: float, sommet: float) -> void:
	var direction := Vector2.from_angle(angle)
	var pointe := centre + direction * taille
	var pied := centre - direction * taille * 0.6
	var gauche := centre + direction.orthogonal() * taille * 0.44
	var droite := centre - direction.orthogonal() * taille * 0.44
	_triangle(resultat, [pied, gauche, pointe], [hauteur, hauteur, sommet], Color(couleur.lightened(0.45), couleur.a))
	_triangle(resultat, [pied, pointe, droite], [hauteur, sommet, hauteur], couleur)

static func _sceau(resultat: Array[Dictionary], centre: Vector2, rayon: float, angle: float,
		couleur: Color, reduit: bool) -> void:
	_anneau(resultat, centre, rayon, 2.5, couleur)
	if not reduit:
		_anneau(resultat, centre, rayon * 0.88, 1.5, Color(couleur, couleur.a * 0.5))
	for i in 6:
		var debut := centre + Vector2.from_angle(angle + TAU * i / 6.0) * rayon
		var fin := centre + Vector2.from_angle(angle + TAU * (i + 2) / 6.0) * rayon
		_ruban(resultat, debut, fin, Color(couleur, couleur.a * 0.5), 2.0)
		_cristal(resultat, debut, angle + TAU * i / 6.0, 8.0, couleur, 0.05, 0.08)

static func _etincelles(resultat: Array[Dictionary], centre: Vector2, rayon: float, t: float,
		couleur: Color, nombre: int, elevees: bool, attire := false) -> void:
	for i in nombre:
		var angle := TAU * i / float(nombre) + sin(float(i * 17)) * 0.22
		var avance := 1.0 - t if attire else t
		var point := centre + Vector2.from_angle(angle) * rayon * (0.15 + 0.8 * avance)
		var hauteur := sin(t * PI) * (0.4 + float(i % 3) * 0.18) if elevees else 0.06
		_cristal(resultat, point, angle + t * 2.0, (4.0 + float(i % 3) * 2.0) * (1.0 - t), couleur, hauteur, hauteur + 0.06)
