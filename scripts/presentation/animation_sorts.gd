extends RefCounted

const Catalogue = preload("res://data/animations_sorts.gd")
const M = preload("res://scripts/presentation/matiere_sort.gd")
const Actifs = preload("res://scripts/presentation/sorts_actifs_visuels.gd")
const Ultimes = preload("res://scripts/presentation/sorts_ultimes_visuels.gd")

static func creer(id: String, centre: Vector2, rayon: float) -> Dictionary:
	var profil: Dictionary = Catalogue.PROFILS.get(id, Catalogue.PASSIFS.get(id, {}))
	if profil.is_empty(): return {}
	return {"id": id, "centre": centre, "rayon": rayon, "age": 0.0,
		"duree": float(profil["duree"]), "couleur": profil["couleur"]}

static func segments(sort: Dictionary, reduit: bool) -> Array[Dictionary]:
	var resultat: Array[Dictionary] = []
	var t := clampf(float(sort["age"]) / float(sort["duree"]), 0.0, 1.0)
	if t >= 1.0: return resultat
	var centre: Vector2 = sort["centre"]
	var rayon := float(sort["rayon"])
	var teinte: Color = sort["couleur"]
	var couleur := Color(teinte, (1.0 - smoothstep(.32, 1.0, t)) * (.64 if reduit else .90))
	var id := str(sort["id"])
	if Catalogue.PASSIFS.has(id):
		_passif(resultat, id, centre, rayon, t, couleur, reduit)
	else:
		# L'impact precede les volutes : aucun delai visuel n'est ajoute aux degats.
		_percussion(resultat, centre, rayon, teinte, float(sort["age"]), id in Catalogue.ULTIMES, reduit)
		if id in Catalogue.ULTIMES:
			Ultimes.dessiner(resultat, id, centre, rayon, t, couleur, reduit)
		else:
			Actifs.dessiner(resultat, id, centre, rayon, t, couleur, reduit)
	_poussieres(resultat, centre, rayon, t, couleur, reduit, id)
	return resultat

static func _percussion(r: Array[Dictionary], c: Vector2, rayon: float,
		teinte: Color, age: float, ultime: bool, reduit: bool) -> void:
	var duree := Catalogue.PERCUSSION_DUREE_ULTIME if ultime else Catalogue.PERCUSSION_DUREE
	var t := clampf(age / duree, 0.0, 1.0)
	if t >= 1.0: return
	var expansion := 1.0 - pow(1.0 - t, 3.0)
	var force := pow(1.0 - t, 2.0) * (.45 if reduit else .75)
	M.halo(r, c, rayon * (.1 + .32 * expansion), Color(teinte.lightened(.65), force * .52), .10)
	var nombre := 4 if reduit else (8 if ultime else 6)
	for i in nombre:
		var angle := TAU * float(i) / nombre + .2
		M.petale(r, c, angle, rayon * (.08 + .22 * expansion), rayon * .03 * (1.0 - t),
			Color(teinte.lightened(.65), force), .12, .16, 0.0, 4)
	M.couronne(r, c, rayon * (.08 + .40 * expansion), 12.0 * (1.0 - t),
		Color(teinte, force * .75), .05, 0, TAU, 24 if reduit else 48)

static func _poussieres(r: Array[Dictionary], c: Vector2, rayon: float, t: float,
		couleur: Color, reduit: bool, id: String) -> void:
	var nombre := 4 if reduit else 10
	for i in nombre:
		var angle := TAU * i / float(nombre) + sin(float(i * 17)) * .20
		var avance := 1.0 - t if id == "vortex_alchimique" else t
		if id == "temps_suspendu": avance = minf(t, .28)
		var point := c + Vector2.from_angle(angle) * rayon * (.13 + .75 * avance)
		var hauteur := sin(avance * PI) * (.20 + .14 * (i % 3))
		M.etincelle(r, point, (6.0 + (i % 3) * 3.0) * (1.0 - t), couleur.lightened(.55), hauteur, angle)

static func _passif(r: Array[Dictionary], id: String, c: Vector2, rayon: float,
		t: float, couleur: Color, reduit: bool) -> void:
	var expansion := 1.0 - pow(1.0 - t, 3.0)
	M.halo(r, c, rayon * expansion, Color(couleur, couleur.a * .16))
	M.couronne(r, c, rayon * expansion * .82, 10.0 * (1.0 - t), Color(couleur, couleur.a * .75))
	var nombre := 3 if reduit else 5
	for i in nombre:
		var angle := TAU * i / float(nombre) + t * .5
		var point := c + Vector2.from_angle(angle) * rayon * .34 * expansion
		M.petale(r, point, angle + (1.0 if id == "moisson_vitale" else -.8),
			rayon * .30 * sin(PI * t), 9.0 * sin(PI * t), couleur,
			.06 + t * .16, .6 * sin(PI * t), .4, 6)

# Les augments et les impacts partagent ces primitives historiques.
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
