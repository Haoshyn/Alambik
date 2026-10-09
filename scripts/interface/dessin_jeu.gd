class_name DessinJeu
extends RefCounted

# Primitives dessinees du HUD et des annonces : jauges bombees, textes a
# contour epais et pastilles. Elles reprennent les teintes de StyleJeu.

static var _boites := {}


static func texte(surface: CanvasItem, police: Font, position: Vector2, contenu: String, taille: int,
		couleur: Color, contour := StyleJeu.CONTOUR_TEXTE, alignement := HORIZONTAL_ALIGNMENT_LEFT,
		largeur := -1.0, epaisseur := -1) -> void:
	var epaisseur_contour := epaisseur if epaisseur >= 0 else maxi(4, roundi(float(taille) * 0.22))
	var ombre := Color(0.02, 0.01, 0.08, 0.5 * couleur.a)
	surface.draw_string_outline(police, position + Vector2(0, maxf(2.0, taille * 0.08)), contenu, alignement,
		largeur, taille, epaisseur_contour + 2, ombre)
	surface.draw_string_outline(police, position, contenu, alignement, largeur, taille, epaisseur_contour, Color(contour, contour.a * couleur.a))
	surface.draw_string(police, position, contenu, alignement, largeur, taille, couleur)


static func texte_centre(surface: CanvasItem, police: Font, centre: Vector2, contenu: String, taille: int,
		couleur: Color, contour := StyleJeu.CONTOUR_TEXTE, largeur_max := -1.0) -> void:
	var taille_finale := taille
	if largeur_max > 0.0:
		while taille_finale > 16 and police.get_string_size(contenu, HORIZONTAL_ALIGNMENT_LEFT, -1, taille_finale).x > largeur_max:
			taille_finale -= 2
	var dimensions := police.get_string_size(contenu, HORIZONTAL_ALIGNMENT_LEFT, -1, taille_finale)
	var origine := centre + Vector2(-dimensions.x * 0.5, police.get_ascent(taille_finale) * 0.5 - police.get_descent(taille_finale) * 0.35)
	texte(surface, police, origine, contenu, taille_finale, couleur, contour)


# Jauge bombee : rail sombre, remplissage en degrade, reflet et trace du
# dernier coup (« retard ») pour lire les degats recus.
static func jauge(surface: CanvasItem, rect: Rect2, ratio: float, haut: Color, bas: Color,
		retard := -1.0, graduations := 0) -> void:
	var r := rect.size.y * 0.5
	var rail := _boite("rail", r)
	surface.draw_style_box(rail, rect)
	var interieur := rect.grow(-maxf(3.0, rect.size.y * 0.16))
	var ri := interieur.size.y * 0.5
	if retard > ratio:
		var trace := Rect2(interieur.position, Vector2(interieur.size.x * clampf(retard, 0.0, 1.0), interieur.size.y))
		if trace.size.x > ri:
			_capsule(surface, trace, ri, Color(1.0, 0.96, 0.86, 0.9), Color(1.0, 0.82, 0.6, 0.9))
	var plein := Rect2(interieur.position, Vector2(interieur.size.x * clampf(ratio, 0.0, 1.0), interieur.size.y))
	if plein.size.x > 1.0:
		plein.size.x = maxf(plein.size.x, minf(interieur.size.x, ri * 2.0))
		_capsule(surface, plein, ri, haut, bas)
		var reflet := Rect2(plein.position + Vector2(ri * 0.5, plein.size.y * 0.1),
			Vector2(maxf(0.0, plein.size.x - ri), plein.size.y * 0.32))
		if reflet.size.x > 2.0:
			_capsule(surface, reflet, reflet.size.y * 0.5, Color(1, 1, 1, 0.55), Color(1, 1, 1, 0.12))
	for i in range(1, graduations):
		var x := interieur.position.x + interieur.size.x * float(i) / float(graduations)
		surface.draw_line(Vector2(x, interieur.position.y + 2.0), Vector2(x, interieur.end.y - 2.0),
			Color(0.05, 0.03, 0.15, 0.55), 2.0, true)


static func pastille(surface: CanvasItem, centre: Vector2, rayon: float, nom_teinte: String) -> void:
	var boite := StyleJeu.boite(nom_teinte, rayon, "normal")
	surface.draw_style_box(boite, Rect2(centre - Vector2.ONE * rayon, Vector2.ONE * rayon * 2.0))


static func _capsule(surface: CanvasItem, rect: Rect2, r: float, haut: Color, bas: Color) -> void:
	var points := StyleBoxJeu._arrondi(rect, r)
	if points.size() < 3:
		return
	var couleurs := PackedColorArray()
	couleurs.resize(points.size())
	for i in points.size():
		couleurs[i] = haut.lerp(bas, clampf((points[i].y - rect.position.y) / maxf(1.0, rect.size.y), 0.0, 1.0))
	surface.draw_polygon(points, couleurs)


static func _boite(nom: String, rayon: float) -> StyleBoxJeu:
	var cle := "%s/%d" % [nom, roundi(rayon)]
	if _boites.has(cle):
		return _boites[cle]
	var s := StyleBoxJeu.new()
	s.rayon = rayon
	s.face_haut = Color("140f2e")
	s.face_bas = Color("2a2257")
	s.epaisseur_couleur = Color("0c0920")
	s.epaisseur = 0.0
	s.reflet = 0.0
	s.liseret = 0.0
	s.largeur_monture = 2.5
	s.largeur_contour = 2.5
	s.ombre = Color(0.02, 0.01, 0.08, 0.4)
	s.ombre_decalage = Vector2(0, 3)
	_boites[cle] = s
	return s


# Rayons tournants derriere une annonce ou une recompense.
static func rayons(surface: CanvasItem, centre: Vector2, rayon: float, couleur: Color, angle: float, nombre := 12) -> void:
	for i in nombre:
		var a := angle + TAU * float(i) / float(nombre)
		var largeur := PI / float(nombre) * 0.55
		var points := PackedVector2Array([centre,
			centre + Vector2.from_angle(a - largeur) * rayon,
			centre + Vector2.from_angle(a + largeur) * rayon])
		surface.draw_polygon(points, PackedColorArray([couleur, Color(couleur, 0.0), Color(couleur, 0.0)]))


# Halo doux : disques concentriques degressifs, sans texture.
static func halo(surface: CanvasItem, centre: Vector2, rayon: float, couleur: Color, couches := 6) -> void:
	for i in couches:
		var part := 1.0 - float(i) / float(couches)
		surface.draw_circle(centre, rayon * part, Color(couleur, couleur.a * 0.16))
