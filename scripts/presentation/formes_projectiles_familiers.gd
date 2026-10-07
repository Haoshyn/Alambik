extends RefCounted

const Formes := preload("res://data/presentation/formes_tirs.gd")
const Rendu := preload("res://data/presentation/animations_projectiles.gd")
const IVOIRE := Rendu.FAMILIER_IVOIRE
const AZUR := Rendu.FAMILIER_AZUR
static var _formes: Dictionary = {}
static var _matiere: StandardMaterial3D
static var _matiere_halo: StandardMaterial3D

static func construire(silhouette: String, teinte: Color) -> Node3D:
	if _matiere == null:
		_matiere = StandardMaterial3D.new()
		_matiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_matiere.vertex_color_use_as_albedo = true
		_matiere.vertex_color_is_srgb = true
		_matiere.cull_mode = BaseMaterial3D.CULL_DISABLED
		_matiere_halo = _matiere.duplicate() as StandardMaterial3D
		_matiere_halo.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var cle := silhouette + teinte.to_html()
	if not _formes.has(cle):
		var corps := ImmediateMesh.new()
		corps.surface_begin(Mesh.PRIMITIVE_TRIANGLES, _matiere)
		var coeur := ImmediateMesh.new()
		coeur.surface_begin(Mesh.PRIMITIVE_TRIANGLES, _matiere)
		_sculpter(corps, coeur, silhouette, teinte)
		corps.surface_end()
		coeur.surface_end()
		var halo := ImmediateMesh.new()
		halo.surface_begin(Mesh.PRIMITIVE_TRIANGLES, _matiere_halo)
		var contour := Formes.contour(silhouette)
		for i in contour.size():
			var j := (i + 1) % contour.size()
			_triangle(halo, Vector3(0, .012, 0), _point(contour[i] * .92, .012), _point(contour[j] * .92, .012),
				Color(teinte, .12), Color(teinte, 0), Color(teinte, 0))
		halo.surface_end()
		_formes[cle] = [corps, coeur, halo]
	var racine := Node3D.new()
	racine.name = "EnergieAlliee"
	var maillages: Array = _formes[cle]
	for i in maillages.size():
		var piece := MeshInstance3D.new()
		piece.name = ["Corps", "Coeur", "Halo"][i]
		piece.mesh = maillages[i]
		piece.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		racine.add_child(piece)
	return racine

static func _sculpter(corps: ImmediateMesh, coeur: ImmediateMesh, silhouette: String, teinte: Color) -> void:
	# Les nervures sont des volumes effiles : aucune plaque ou monture de medaillon.
	var froid := Color("64a9cb").lerp(teinte, .12)
	match silhouette:
		"homoncule_encre":
			_ruban(corps, [Vector3(0,.025,.84),Vector3(-.57,.07,.24),Vector3(-.30,.13,-.39),Vector3(.05,.03,-.79)], .21, .075, Color("747cc6"), 12, 8)
			_ruban(corps, [Vector3(.02,.05,.81),Vector3(.47,.11,.34),Vector3(.43,.18,-.12),Vector3(.10,.045,-.70)], .19, .075, froid, 12, 8)
			_ruban(coeur, [Vector3(-.02,.16,.71),Vector3(-.30,.25,.19),Vector3(.22,.27,-.13),Vector3(.06,.09,-.69)], .050, .020, IVOIRE, 12, 6)
			_ruban(coeur, [Vector3(.31,.15,.18),Vector3(.14,.27,-.02),Vector3(-.07,.22,-.29),Vector3(-.14,.10,-.52)], .025, .015, Color("bec1f5"), 8, 6)
		"salamandre":
			for i in 5:
				var angle := TAU * float(i) / 5.0 + PI * .5
				var a := Vector2.from_angle(angle - .75)
				var b := Vector2.from_angle(angle)
				var c := Vector2.from_angle(angle + .16)
				_ruban(corps, [_point(a * .04,.10),_point(a * .40,.18),_point(b * .65,.14),_point(c * .83,.025)], .14, .035, Color("76b8ad"), 9, 6)
				_ruban(coeur, [_point(a * .08,.15),_point(a * .30,.24),_point(b * .59,.17),_point(c * .78,.035)], .026, .015, IVOIRE, 6, 4)
			_ruban(coeur, [Vector3(0,.18,-.25),Vector3(-.10,.25,-.10),Vector3(.06,.24,.15),Vector3(0,.07,.30)], .060, .022, IVOIRE, 6, 6)
		"ondine":
			_ruban(corps, [Vector3(0,.02,-.84),Vector3(-.10,.16,-.36),Vector3(.12,.18,.30),Vector3(0,.035,.87)], .25, .095, Color("53b0cd"), 12, 4)
			for cote in [-1.0, 1.0]:
				_ruban(corps, [Vector3(cote*.08,.04,-.68),Vector3(cote*.40,.09,-.27),Vector3(cote*.34,.16,.20),Vector3(0,.035,.83)], .065, .027, Color("8bd1d8"), 9, 4)
			_ruban(coeur, [Vector3(0,.08,-.82),Vector3(-.075,.32,-.30),Vector3(.075,.34,.35),Vector3(0,.08,.83)], .018, .014, IVOIRE, 12, 4)
			_ruban(coeur, [Vector3(-.24,.09,-.25),Vector3(-.09,.32,-.10),Vector3(.07,.34,.10),Vector3(.23,.12,.30)], .023, .02, IVOIRE, 6, 4)
		"sylphe":
			_ruban(corps, [Vector3(-.16,.02,-.82),Vector3(-.41,.11,-.28),Vector3(-.18,.18,.43),Vector3(0,.04,.89)], .12, .040, Color("8099d0"), 12, 6)
			for i in 3:
				var z := -.50 + float(i) * .23
				_ruban(corps, [Vector3(-.23,.09,z),Vector3(-.20,.15,z-.04),Vector3(.43,.14,z-.11),Vector3(.52-float(i)*.08,.03,z-.18)], .07 - float(i)*.015, .025, Color("a4b8e4"), 6, 4)
			_ruban(coeur, [Vector3(-.16,.11,-.79),Vector3(-.32,.20,-.25),Vector3(-.13,.24,.39),Vector3(0,.07,.85)], .023, .014, IVOIRE, 12, 4)
			_ruban(coeur, [Vector3(-.29,.09,-.40),Vector3(-.14,.17,-.27),Vector3(.23,.18,-.35),Vector3(.45,.05,-.49)], .022, .02, IVOIRE, 8, 4)
		"golem":
			_quartz(corps, Formes.contour(silhouette), Color("538f9c"))
			_ruban(coeur, [Vector3(-.39,.16,-.38),Vector3(-.12,.39,-.09),Vector3(.13,.39,.09),Vector3(.38,.16,.39)], .029, .018, IVOIRE, 8, 4)
			_ruban(coeur, [Vector3(.34,.17,-.38),Vector3(.14,.38,-.08),Vector3(.10,.39,.11),Vector3(-.30,.20,.35)], .024, .018, IVOIRE, 8, 4)
			for cote in [-1.0, 1.0]:
				_ruban(corps, [Vector3(cote*.64,.02,-.26),Vector3(cote*.78,.05,-.03),Vector3(cote*.71,.08,.26),Vector3(cote*.48,.03,.48)], .025, .015, Color("aacdc0"), 8, 4)

static func _quartz(mesh: ImmediateMesh, contour: PackedVector2Array, couleur: Color) -> void:
	# Un cristal ferme aux facettes larges reste lisible quand la lueur est masquee.
	var anneaux: Array[Vector2] = [Vector2(.76,.025),Vector2(.69,.17),Vector2(.30,.30)]
	for niveau in anneaux.size():
		for i in contour.size():
			var j := (i + 1) % contour.size()
			var bas := anneaux[niveau]
			var haut := anneaux[niveau + 1] if niveau < anneaux.size() - 1 else Vector2(0,.34)
			var a := _point(contour[i] * bas.x, bas.y)
			var b := _point(contour[j] * bas.x, bas.y)
			var c := _point(contour[i] * haut.x, haut.y)
			var d := _point(contour[j] * haut.x, haut.y)
			var ca := couleur.darkened(.20).lerp(IVOIRE, clampf(.07 - contour[i].x*.20 + niveau*.035, 0.0, .35))
			var cb := couleur.darkened(.20).lerp(IVOIRE, clampf(.07 - contour[j].x*.20 + niveau*.035, 0.0, .35))
			_triangle(mesh,a,b,c,ca,cb,ca.lightened(.04))
			_triangle(mesh,b,d,c,cb,cb.lightened(.04),ca.lightened(.04))
	for i in contour.size():
		_triangle(mesh,Vector3(0,.025,0),_point(contour[i]*.76,.025),_point(contour[(i+1)%contour.size()]*.76,.025),couleur.darkened(.30),couleur.darkened(.30),couleur.darkened(.30))

static func _ruban(mesh: ImmediateMesh, controles: Array[Vector3], largeur: float, epaisseur: float, couleur: Color, pas: int, faces: int) -> void:
	# Section elliptique et extremites pincees : les rubans se croisent sans s'aplatir.
	for j in pas:
		for i in faces:
			var sommets: Array[Vector3] = []
			var couleurs: Array[Color] = []
			for uv: Vector2 in [Vector2(i,j),Vector2(i+1,j),Vector2(i,j+1),Vector2(i+1,j+1)]:
				var t := uv.y / float(pas)
				var centre := _bezier(controles,t)
				var tangent := (_bezier(controles,minf(1.0,t+.005)) - _bezier(controles,maxf(0.0,t-.005))).normalized()
				var cote := Vector3(tangent.z,0,-tangent.x).normalized()
				var angle := TAU * uv.x / float(faces)
				var ventre := pow(maxf(0.0, sin(t*PI)),.75)
				sommets.append(centre + cote * cos(angle) * largeur * ventre + Vector3.UP * sin(angle) * epaisseur * ventre)
				var reflet := clampf(.22 - cos(angle)*.26 + sin(angle)*.36,0.0,.90)
				couleurs.append(IVOIRE if couleur == IVOIRE and sin(angle) >= .80 else couleur.darkened(.30).lerp(couleur, .40 + reflet * .60).lerp(IVOIRE, reflet * .18))
			_triangle(mesh,sommets[0],sommets[1],sommets[2],couleurs[0],couleurs[1],couleurs[2])
			_triangle(mesh,sommets[1],sommets[3],sommets[2],couleurs[1],couleurs[3],couleurs[2])

static func _bezier(points: Array[Vector3], t: float) -> Vector3:
	var inverse := 1.0 - t
	return points[0]*inverse*inverse*inverse + points[1]*3.0*inverse*inverse*t + points[2]*3.0*inverse*t*t + points[3]*t*t*t

static func _point(point: Vector2, hauteur: float) -> Vector3:
	return Vector3(point.x, hauteur, point.y)

static func _triangle(mesh: ImmediateMesh, a: Vector3, b: Vector3, c: Vector3, ca: Color, cb: Color, cc: Color) -> void:
	for sommet: Array in [[a, ca], [b, cb], [c, cc]]:
		mesh.surface_set_color(sommet[1])
		mesh.surface_add_vertex(sommet[0])
