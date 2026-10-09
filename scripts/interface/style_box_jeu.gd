@tool
class_name StyleBoxJeu
extends StyleBox

# Surface d'email sur monture doree : contour sombre, liseré de metal,
# epaisseur visible, face en degrade et reflet. Elle remplace les aplats des
# boutons, panneaux et cartes ; toute la geometrie est calculee ici pour que
# les ecrans gardent leurs conteneurs et leurs marges habituels.

@export var face_haut := Color("8e6cf0")
@export var face_bas := Color("5a37b8")
@export var epaisseur_couleur := Color("341d77")
@export var monture_haut := Color("ffe9a8")
@export var monture_bas := Color("b97a2f")
@export var contour := Color("1a1030")
@export var rayon := 26.0
@export var largeur_contour := 3.0
@export var largeur_monture := 4.0
@export var epaisseur := 8.0
@export var reflet := 0.30
@export var liseret := 0.55
@export var ombre := Color(0.03, 0.02, 0.10, 0.45)
@export var ombre_decalage := Vector2(0.0, 7.0)
@export var lueur := Color(1.0, 0.85, 0.4, 0.0)
@export var lueur_taille := 0.0
@export var enfonce := false

const SEGMENTS_COIN := 7


func _init() -> void:
	content_margin_left = 30.0
	content_margin_right = 30.0
	content_margin_top = 18.0
	content_margin_bottom = 22.0


func _get_draw_rect(rect: Rect2) -> Rect2:
	var marge := maxf(lueur_taille, absf(ombre_decalage.y) + 4.0)
	return rect.grow(marge)


func _draw(item: RID, rect: Rect2) -> void:
	if rect.size.x < 2.0 or rect.size.y < 2.0:
		return
	var r := minf(rayon, minf(rect.size.x, rect.size.y) * 0.5)
	if lueur.a > 0.0 and lueur_taille > 0.0:
		for i in 5:
			var part := 1.0 - float(i) / 5.0
			_remplir(item, rect.grow(lueur_taille * (float(i) + 1.0) / 5.0), r + lueur_taille * 0.5,
				Color(lueur, lueur.a * 0.22 * part), Color(lueur, lueur.a * 0.22 * part))
	if ombre.a > 0.0 and not enfonce:
		_remplir(item, Rect2(rect.position + ombre_decalage + Vector2(-1, 1), rect.size + Vector2(2, 0)),
			r + 2.0, Color(ombre, ombre.a * 0.45), Color(ombre, ombre.a * 0.45))
		_remplir(item, Rect2(rect.position + ombre_decalage, rect.size), r, ombre, ombre)
	_remplir(item, rect, r, contour, contour)
	var monture := rect.grow(-largeur_contour)
	var r_monture := maxf(2.0, r - largeur_contour)
	if largeur_monture > 0.0:
		_remplir(item, monture, r_monture, monture_haut, monture_bas)
	var interieur := monture.grow(-largeur_monture)
	var r_interieur := maxf(2.0, r_monture - largeur_monture)
	if interieur.size.x <= 2.0 or interieur.size.y <= 2.0:
		return
	var relief := minf(epaisseur, interieur.size.y * 0.3)
	if enfonce:
		relief *= 0.35
	_remplir(item, interieur, r_interieur, epaisseur_couleur, epaisseur_couleur.darkened(0.25))
	var face := Rect2(interieur.position, Vector2(interieur.size.x, interieur.size.y - relief))
	if enfonce:
		face.position.y += relief
		face.size.y = interieur.size.y - relief
	_remplir(item, face, r_interieur, face_haut, face_bas)
	if reflet > 0.0:
		var haut := Rect2(face.position + Vector2(r_interieur * 0.35, face.size.y * 0.06),
			Vector2(face.size.x - r_interieur * 0.7, face.size.y * 0.42))
		if haut.size.x > 4.0 and haut.size.y > 2.0:
			_remplir(item, haut, minf(r_interieur, haut.size.y * 0.5),
				Color(1, 1, 1, reflet), Color(1, 1, 1, 0.0))
	if liseret > 0.0:
		var ligne := _arrondi(face.grow(-1.5), maxf(1.0, r_interieur - 1.5), true)
		RenderingServer.canvas_item_add_polyline(item, ligne,
			PackedColorArray([Color(1, 1, 1, liseret)]), 2.0, true)
	# Le contour lisse masque l'escalier des polygones sur les ecrans denses.
	var bordure := _arrondi(rect.grow(-0.5), maxf(1.0, r - 0.5))
	bordure.append(bordure[0])
	RenderingServer.canvas_item_add_polyline(item, bordure, PackedColorArray([contour]), 1.5, true)


func _remplir(item: RID, rect: Rect2, r: float, haut: Color, bas: Color) -> void:
	var points := _arrondi(rect, r)
	if points.size() < 3:
		return
	var couleurs := PackedColorArray()
	couleurs.resize(points.size())
	for i in points.size():
		var t := clampf((points[i].y - rect.position.y) / maxf(1.0, rect.size.y), 0.0, 1.0)
		couleurs[i] = haut.lerp(bas, t)
	RenderingServer.canvas_item_add_polygon(item, points, couleurs)


static func _arrondi(rect: Rect2, r: float, haut_seulement := false) -> PackedVector2Array:
	var points := PackedVector2Array()
	r = clampf(r, 0.0, minf(rect.size.x, rect.size.y) * 0.5)
	var centres := [
		Vector2(rect.position.x + r, rect.position.y + r),
		Vector2(rect.end.x - r, rect.position.y + r),
		Vector2(rect.end.x - r, rect.end.y - r),
		Vector2(rect.position.x + r, rect.end.y - r),
	]
	var departs := [PI, PI * 1.5, 0.0, PI * 0.5]
	var coins := 2 if haut_seulement else 4
	for coin in coins:
		for pas in SEGMENTS_COIN + 1:
			var angle: float = departs[coin] + PI * 0.5 * float(pas) / float(SEGMENTS_COIN)
			var point: Vector2 = centres[coin] + Vector2(cos(angle), sin(angle)) * r
			# Une capsule parfaite fait se rejoindre deux coins : un sommet double
			# empeche la triangulation.
			if points.is_empty() or points[-1].distance_squared_to(point) > 0.01:
				points.append(point)
	if not haut_seulement and points.size() > 2 and points[0].distance_squared_to(points[-1]) <= 0.01:
		points.remove_at(points.size() - 1)
	return points
