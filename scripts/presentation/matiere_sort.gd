extends RefCounted

# Les couleurs par sommet donnent du volume sans texture ni eclairage plein ecran.
static func facette(r: Array[Dictionary], points: Array[Vector2], hauteurs: Array[float], couleurs: Array[Color]) -> void:
	if maxf(couleurs[0].a, maxf(couleurs[1].a, couleurs[2].a)) < .004: return
	r.append({"points": points, "hauteurs": hauteurs, "couleur": couleurs[0], "couleurs": couleurs})

static func quad(r: Array[Dictionary], points: Array[Vector2], hauteurs: Array[float], couleurs: Array[Color]) -> void:
	facette(r, [points[0], points[1], points[2]], [hauteurs[0], hauteurs[1], hauteurs[2]], [couleurs[0], couleurs[1], couleurs[2]])
	facette(r, [points[0], points[2], points[3]], [hauteurs[0], hauteurs[2], hauteurs[3]], [couleurs[0], couleurs[2], couleurs[3]])

static func halo(r: Array[Dictionary], centre: Vector2, rayon: float, couleur: Color,
		hauteur := .025, etirement := Vector2.ONE, nombre := 24, phase := 0.0) -> void:
	if rayon <= .1 or couleur.a < .004: return
	for i in nombre:
		var a := TAU * i / float(nombre)
		var b := TAU * (i + 1) / float(nombre)
		var pa := Vector2.from_angle(a) * rayon * (1.0 + .055 * sin(a * 5.0 + phase)) * etirement
		var pb := Vector2.from_angle(b) * rayon * (1.0 + .055 * sin(b * 5.0 + phase)) * etirement
		var milieu := Color(couleur, couleur.a * .44)
		var vide := Color(couleur, 0.0)
		facette(r, [centre, centre + pa * .5, centre + pb * .5], [hauteur, hauteur, hauteur], [couleur, milieu, milieu])
		quad(r, [centre + pa * .5, centre + pa, centre + pb, centre + pb * .5],
			[hauteur, hauteur, hauteur, hauteur], [milieu, vide, vide, milieu])

static func couronne(r: Array[Dictionary], centre: Vector2, rayon: float, largeur: float,
		couleur: Color, hauteur := .035, angle := 0.0, ouverture := TAU, nombre := 48) -> void:
	if rayon <= .1 or largeur <= .05 or couleur.a < .004: return
	var interne := maxf(0.0, rayon - largeur * 1.6)
	var externe := rayon + largeur * .6
	var creme := Color(couleur.lightened(.60), couleur.a)
	var vide := Color(couleur, 0.0)
	for i in nombre:
		var a := Vector2.from_angle(angle + ouverture * i / float(nombre))
		var b := Vector2.from_angle(angle + ouverture * (i + 1) / float(nombre))
		var relief := hauteur + minf(.22, largeur * .012)
		quad(r, [centre + a * interne, centre + a * rayon, centre + b * rayon, centre + b * interne],
			[hauteur, relief, relief, hauteur], [vide, creme, creme, vide])
		quad(r, [centre + a * rayon, centre + a * externe, centre + b * externe, centre + b * rayon],
			[relief, hauteur, hauteur, relief], [creme, vide, vide, creme])

static func ruban(r: Array[Dictionary], debut: Vector2, fin: Vector2, couleur: Color,
		largeur: float, hauteur := .05, hauteur_fin := -1.0) -> void:
	if couleur.a < .004 or largeur <= .05: return
	r.append({"depart": debut, "arrivee": fin, "couleur": couleur, "largeur": largeur,
		"hauteur": hauteur, "hauteur_fin": hauteur if hauteur_fin < 0 else hauteur_fin})

static func petale(r: Array[Dictionary], centre: Vector2, angle: float, longueur: float,
		largeur: float, couleur: Color, hauteur := .05, relief := .35, courbure := .15, nombre := 8) -> void:
	if longueur <= .1 or largeur <= .05 or couleur.a < .004: return
	var direction := Vector2.from_angle(angle)
	var cote := direction.orthogonal()
	for i in nombre:
		var points: Array[Vector2] = []
		var hauteurs: Array[float] = []
		var couleurs: Array[Color] = []
		for j in 2:
			var t := float(i + j) / nombre
			var ventre := pow(maxf(0.0, sin(t * PI)), .7)
			var point := centre + direction * longueur * t + cote * sin(t * PI) * longueur * courbure
			var h := hauteur + relief * sin(t * PI)
			points.append_array([point - cote * largeur * ventre, point, point + cote * largeur * ventre])
			hauteurs.append_array([h, h + largeur * .008, h])
			var opacite := couleur.a * (1.0 - smoothstep(.74, 1.0, t))
			couleurs.append_array([Color(couleur.darkened(.25), opacite * .65),
				Color(couleur.lightened(.7), opacite), Color(couleur, opacite * .80)])
		quad(r, [points[0], points[1], points[4], points[3]], [hauteurs[0], hauteurs[1], hauteurs[4], hauteurs[3]], [couleurs[0], couleurs[1], couleurs[4], couleurs[3]])
		quad(r, [points[1], points[2], points[5], points[4]], [hauteurs[1], hauteurs[2], hauteurs[5], hauteurs[4]], [couleurs[1], couleurs[2], couleurs[5], couleurs[4]])

static func cristal(r: Array[Dictionary], centre: Vector2, angle: float, taille: float,
		couleur: Color, hauteur := .04, sommet := .55) -> void:
	if taille <= .1 or couleur.a < .004: return
	var direction := Vector2.from_angle(angle)
	var cote := direction.orthogonal()
	var pointe := centre + direction * taille * .85
	var pied := centre - direction * taille * .5
	for i in 6:
		var a := TAU * i / 6.0
		var b := TAU * (i + 1) / 6.0
		var pa := centre + direction * cos(a) * taille * .34 + cote * sin(a) * taille * .40
		var pb := centre + direction * cos(b) * taille * .34 + cote * sin(b) * taille * .40
		var facette_couleur := Color(couleur.lightened(.1 + .50 * maxf(0.0, sin(a))), couleur.a)
		facette(r, [pa, pointe, pb], [hauteur + sommet * .25, hauteur + sommet, hauteur + sommet * .25],
			[facette_couleur, Color(couleur.lightened(.8), couleur.a), facette_couleur.darkened(.12)])
		facette(r, [pied, pa, pb], [hauteur, hauteur + sommet * .25, hauteur + sommet * .25],
			[Color(couleur.darkened(.35), couleur.a * .7), facette_couleur, facette_couleur.darkened(.12)])

static func bulle(r: Array[Dictionary], centre: Vector2, rayon: float, couleur: Color, hauteur: float) -> void:
	if rayon <= .2: return
	for i in 16:
		var a := Vector2.from_angle(TAU * i / 16.0) * rayon
		var b := Vector2.from_angle(TAU * (i + 1) / 16.0) * rayon
		facette(r, [centre, centre + a, centre + b], [hauteur + rayon * .008, hauteur, hauteur],
			[Color(couleur.lightened(.55), couleur.a * .25), Color(couleur, couleur.a * .65), Color(couleur, couleur.a * .65)])
	couronne(r, centre, rayon, maxf(1.0, rayon * .12), Color(couleur, couleur.a * .8), hauteur, .1, TAU, 16)
	halo(r, centre + Vector2(-.26, -.3) * rayon, rayon * .28, Color(couleur.lightened(.85), couleur.a * .9), hauteur + rayon * .01, Vector2(1, .65), 10)

static func etincelle(r: Array[Dictionary], centre: Vector2, taille: float, couleur: Color, hauteur := .06, angle := 0.0) -> void:
	if taille <= .1: return
	var creme := Color(couleur.lightened(.85), couleur.a)
	for i in 4:
		var a := Vector2.from_angle(angle + PI * i * .5)
		var b := a.rotated(PI * .5)
		facette(r, [centre, centre + a * taille, centre + b * taille * .23], [hauteur, hauteur, hauteur],
			[creme, Color(couleur, 0), Color(couleur, 0)])

static func sceau(r: Array[Dictionary], centre: Vector2, rayon: float, couleur: Color, angle: float, reduit: bool) -> void:
	couronne(r, centre, rayon, 3.8, Color(couleur, couleur.a * .8), .035, 0, TAU, 24 if reduit else 48)
	for i in 6:
		var a := Vector2.from_angle(angle + TAU * i / 6.0)
		var b := Vector2.from_angle(angle + TAU * (i + 2) / 6.0)
		ruban(r, centre + a * rayon * .85, centre + b * rayon * .85, Color(couleur, couleur.a * .46), 2.5)
		cristal(r, centre + a * rayon, a.angle(), 6.0 if reduit else 9.0, couleur, .06, .06)
