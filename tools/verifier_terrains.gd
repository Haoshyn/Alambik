extends Node

const TERRAIN := preload("res://scripts/monde/terrain_elementaire.gd")
const VISUEL := preload("res://scripts/presentation/terrain_elementaire_3d.gd")
const HEROS := preload("res://scenes/heros.tscn")

class SalleTest extends Node2D:
	var numero := 2
	var limites := Rect2(Vector2(-137,81), Reglages.ARENE_TAILLE)
	var forme := 0
	var blocs: Array[Rect2] = []
	var sortie := false
	var terrain: Node2D
	func obstacles() -> Array[Rect2]: return blocs
	func contour_sol() -> PackedVector2Array: return FormesSalles.contour_salle(limites, numero, Jeu.chapitre, Jeu.graine, Jeu.mode_run)
	func portail_ouvert() -> bool: return sortie
	func mouvement_terrain(point: Vector2) -> Vector3: return terrain.mouvement(point)
	func terrain_elementaire() -> Node2D: return terrain

var _erreurs: Array[String] = []
var _controles := 0
var _tirs := 0
var _salle: SalleTest
var _terrain: Node2D
var _heros: CharacterBody2D

func _exiger(condition: bool, message: String) -> void:
	_controles += 1
	if not condition and message not in _erreurs: _erreurs.append(message)

func _ready() -> void:
	if "verification" not in OS.get_user_data_dir().to_lower():
		push_error("Profil APPDATA de verification requis")
		get_tree().quit(1)
		return
	ReglagesJoueur.sauvegarde_active = false
	Jeu.mode_run = "grimoire"
	_salle = SalleTest.new()
	add_child(_salle)
	_salle.add_to_group("salle")
	_terrain = TERRAIN.new()
	_salle.add_child(_terrain)
	_salle.terrain = _terrain
	_terrain.set_physics_process(false)
	_verifier_implantations()
	_heros = HEROS.instantiate()
	add_child(_heros)
	_heros.set_process(false)
	_heros.set_physics_process(false)
	_heros.limites = _salle.limites
	_verifier_flaques()
	await _verifier_vent()
	await _verifier_visuels()
	_heros.free()
	_salle.free()
	Sons.arreter()
	for erreur in _erreurs: push_error(erreur)
	print("Terrains : %d controles, %d erreurs." % [_controles,_erreurs.size()])
	get_tree().quit(0 if _erreurs.is_empty() else 1)

func _configurer(chapitre: int, numero: int) -> void:
	Jeu.chapitre = chapitre
	_salle.numero = numero
	_salle.sortie = false
	_salle.forme = FormesSalles.indice(numero, chapitre, 0, "grimoire")
	_salle.limites.size = FormesSalles.taille(numero,chapitre,0,"grimoire")
	_salle.blocs.clear()
	for obstacle: Dictionary in TerrainsMondes.obstacles(numero,chapitre):
		var rect: Rect2 = obstacle["rect"]
		_salle.blocs.append(Rect2(_salle.limites.position + rect.position * _salle.limites.size, rect.size * _salle.limites.size))
	_terrain.configurer(_salle)

func _verifier_implantations() -> void:
	var formes: Dictionary = {}
	var tailles: Dictionary = {}
	for chapitre in Chapitres.nombre():
		for numero in range(1,Reglages.SALLES_PAR_RUN+1):
			_configurer(chapitre,numero)
			var attendu := TerrainsMondes.nombre(numero,chapitre,Jeu.graine,"grimoire")
			_exiger(_terrain.zones.size() == attendu, "Zone manquante ou ajoutee : %d/%d" % [chapitre,numero])
			var reference: Array = _terrain.zones.duplicate(true)
			_terrain.configurer(_salle)
			_exiger(reference == _terrain.zones, "Terrain instable a la reconstruction")
			for zone: Dictionary in _terrain.zones:
				if str(zone["type"]) == "vent": continue
				var centre: Vector2 = zone["position"]
				var contour: PackedVector2Array = zone["contour"]
				var emprise := Rect2(contour[0], Vector2.ZERO)
				for point in contour: emprise = emprise.expand(point)
				_exiger(emprise.size.y > Reglages.HEROS_RAYON * 8.0, "Nappe trop courte pour etre sensible en traversant")
				formes[hash(contour)] = true
				tailles[roundi(float(zone["rayon"]))] = true
				_exiger(_terrain._contient(zone,centre), "Centre de flaque non affecte")
				_exiger(not _terrain._contient(zone,centre+Vector2.RIGHT*float(zone["rayon"])*1.1), "Ralentissement hors de la flaque")
				for point in contour:
					_exiger(Geometry2D.is_point_in_polygon(centre+point,_salle.contour_sol()), "Flaque hors de la salle")
					for bloc in _salle.blocs: _exiger(not bloc.grow(TerrainsMondes.MARGE_OBSTACLE).has_point(centre+point), "Flaque sur un obstacle")
				_exiger(absf(centre.x-_salle.limites.get_center().x) > float(zone["rayon"])+Reglages.HEROS_RAYON, "Passage central ferme par le terrain")
	_exiger(formes.size() > 100 and tailles.size() >= 3, "Les formes et tailles des flaques se repetent")
	for mode: String in ["mine","epreuves"]:
		_exiger(TerrainsMondes.nombre(2,0,0,mode) == 0, "Terrain de campagne ajoute a un mode annexe")

func _verifier_flaques() -> void:
	for monde in [0,1,2,4]:
		_configurer(monde * Chapitres.CHAPITRES_PAR_MONDE,2)
		if _terrain.zones.is_empty(): continue
		var zone: Dictionary = _terrain.zones[0]
		_heros.limites = _salle.limites
		_heros.global_position = zone["position"]
		_heros.stats.pv = _heros.stats.pv_max
		_heros.set("_invulnerable",0.0)
		_heros.bouclier = 0
		_exiger(_terrain.mouvement(_heros.global_position) == Vector3(0,0,1), "Effet avant le delai d'entree")
		_terrain.temps = TerrainsMondes.DELAI_ACTIVATION
		var facteur := float(TerrainsMondes.PROFILS[monde]["vitesse"])
		if monde == 1: facteur = TerrainsMondes.SABLE_VITESSE_INITIALE
		_exiger(is_equal_approx(_terrain.mouvement(_heros.global_position).z,facteur), "Ralentissement incorrect")
		_heros.velocity = Vector2.ZERO
		_heros.definir_intention(Vector2.DOWN)
		for image in 18: _heros._physics_process(1.0 / 60.0)
		_exiger(absf(_heros.velocity.y - _heros.stats.vitesse * facteur) < .1, "Le vrai deplacement du heros ne suit pas le ralentissement")
		_heros.definir_intention(Vector2.ZERO)
		_heros.global_position = zone["position"]
		if monde == 1:
			_terrain._physics_process(TerrainsMondes.SABLE_DUREE_ENFONCEMENT)
			_exiger(is_equal_approx(_terrain.mouvement(_heros.global_position).z,TerrainsMondes.SABLE_VITESSE_MINIMALE), "Enfoncement du sable incorrect")
		if monde == 4:
			var pv: float = _heros.stats.pv
			_terrain._physics_process(.01)
			_exiger(_heros.stats.pv < pv, "La lave ne blesse pas")
			pv = _heros.stats.pv
			_heros.set("_invulnerable",0.0)
			_terrain._physics_process(.01)
			_exiger(is_equal_approx(_heros.stats.pv,pv), "Degats de lave a chaque image")
			_heros.bouclier = 1
			_terrain._physics_process(TerrainsMondes.INTERVALLE_DEGATS)
			_exiger(_heros.bouclier == 0 and is_equal_approx(_heros.stats.pv,pv), "La lave ignore le bouclier")
		_heros.global_position = _salle.limites.get_center()
		_terrain._physics_process(.02)
		_exiger(_terrain.mouvement(_heros.global_position) == Vector3(0,0,1), "Effet conserve hors flaque")
		if monde == 1:
			_exiger(is_equal_approx(float(_terrain.get("_temps_sable")),0), "Le sable ne se reinitialise pas en sortant")
		_heros.global_position = zone["position"]
		_salle.sortie = true
		_heros.set("_invulnerable",0.0)
		var pv_sortie: float = _heros.stats.pv
		_terrain._physics_process(TerrainsMondes.INTERVALLE_DEGATS)
		_exiger(_terrain.mouvement(_heros.global_position) == Vector3(0,0,1) and is_equal_approx(_heros.stats.pv,pv_sortie), "Terrain actif apres victoire")
	# Un tir reel prepare puis emis dans l'eau, sans desarmer le heros.
	_configurer(2 * Chapitres.CHAPITRES_PAR_MONDE,2)
	_terrain.temps = TerrainsMondes.DELAI_ACTIVATION
	_heros.global_position = _terrain.zones[0]["position"]
	var cible := Node2D.new()
	add_child(cible)
	cible.position = _heros.position + Vector2(0,-180)
	cible.add_to_group("ennemis")
	_heros.tir_demande.connect(func(_tir: Tir, _origine: Vector2, _direction: Vector2) -> void: _tirs += 1)
	_heros.definir_intention(Vector2.ZERO)
	for i in 120: _heros._process(1.0/60.0)
	_exiger(_tirs > 0, "L'eau bloque encore les tirs")
	cible.free()

func _verifier_vent() -> void:
	_configurer(3 * Chapitres.CHAPITRES_PAR_MONDE,2)
	_heros.limites = _salle.limites
	_terrain.temps = TerrainsMondes.DELAI_ACTIVATION + 1.0
	_exiger(_terrain.mouvement(_salle.limites.get_center()) == Vector3(0,0,1), "Vent permanent pendant le calme")
	_terrain.temps = TerrainsMondes.DELAI_ACTIVATION + TerrainsMondes.VENT_REPOS - TerrainsMondes.VENT_ANNONCE * .5
	_exiger(bool(_terrain.etat_vent()["annonce"]) and is_zero_approx(float(_terrain.etat_vent()["force"])), "Rafale non annoncee avant la poussee")
	var temps_plein := TerrainsMondes.DELAI_ACTIVATION + TerrainsMondes.VENT_REPOS + TerrainsMondes.VENT_MONTEE
	_terrain.temps = temps_plein
	var direction: Vector2 = _terrain.etat_vent()["direction"]
	for sens: float in [-1.0,1.0,0.0]:
		_heros.global_position = _salle.limites.get_center()
		_heros.velocity = Vector2.ZERO
		_heros.definir_intention(direction * sens)
		for i in 30:
			await get_tree().physics_frame
			_heros._physics_process(1.0/60.0)
		var attendue: Vector2 = direction * (sens + TerrainsMondes.VENT_VARIATION_VITESSE) * _heros.stats.vitesse
		_exiger(_heros.velocity.distance_to(attendue) < .1, "Vitesse reelle incorrecte avec ou contre la rafale")
	_heros.global_position = _salle.limites.get_center()
	_heros.velocity = Vector2.ZERO
	_heros.definir_intention(-direction,.15)
	for i in 20:
		await get_tree().physics_frame
		_heros._physics_process(1.0/60.0)
	_exiger(_heros.velocity.dot(-direction) > 0.0, "Une commande legere ne peut pas remonter le vent")
	# La meme poussee traverse le moteur de collision ordinaire.
	_terrain.zones[0]["orientation"] = 0
	var mur := StaticBody2D.new()
	mur.collision_layer = 4
	var collision := CollisionShape2D.new()
	var forme := RectangleShape2D.new()
	forme.size = Vector2(30,600)
	collision.shape = forme
	mur.add_child(collision)
	add_child(mur)
	mur.position = _salle.limites.get_center() + Vector2(100,0)
	_heros.global_position = _salle.limites.get_center()
	_heros.velocity = Vector2.ZERO
	_heros.definir_intention(Vector2.ZERO)
	for i in 90:
		await get_tree().physics_frame
		_heros._physics_process(1.0/60.0)
	_exiger(_heros.position.x <= mur.position.x-15-Reglages.HEROS_RAYON+.2, "Le vent pousse au travers d'un mur")
	mur.free()
	_terrain.temps = temps_plein + TerrainsMondes.VENT_REPOS + TerrainsMondes.VENT_DUREE
	_exiger(not (_terrain.etat_vent()["direction"] as Vector2).is_equal_approx(Vector2.RIGHT), "Direction du vent invariable entre rafales")
	_salle.sortie = true
	_exiger(_terrain.mouvement(_heros.position) == Vector3(0,0,1), "Le vent reste actif au portail")

func _verifier_visuels() -> void:
	var visuel := VISUEL.new()
	visuel.salle = _salle
	add_child(visuel)
	for monde in 5:
		_configurer(monde * Chapitres.CHAPITRES_PAR_MONDE,2)
		var ancien := _terrain
		_terrain = TERRAIN.new()
		_salle.add_child(_terrain)
		_salle.terrain = _terrain
		_terrain.set_physics_process(false)
		_terrain.configurer(_salle)
		ancien.free()
		_terrain.temps = TerrainsMondes.DELAI_ACTIVATION + TerrainsMondes.VENT_REPOS + TerrainsMondes.VENT_MONTEE
		# Comme a la transition reelle, remplacer la source doit suffire au rendu.
		visuel.mettre_a_jour(0)
		await get_tree().process_frame
		_exiger(visuel.get_child_count() == _terrain.zones.size(), "Accumulation des anciens visuels de terrain")
		if monde == 3:
			ReglagesJoueur.effets_reduits = true
			visuel.mettre_a_jour(0)
			var trace: Node3D = visuel.get_child(0).get_child(0)
			var origine := trace.position
			_terrain.temps += .1
			visuel.mettre_a_jour(0)
			_exiger(trace.position.is_equal_approx(origine), "Le vent derive encore en effets reduits")
			_exiger(float(_terrain.etat_vent()["force"]) > 0.0, "Effets reduits desactivant la mecanique du vent")
			_terrain.temps = TerrainsMondes.DELAI_ACTIVATION + .1
			visuel.mettre_a_jour(0)
			_exiger(not visuel.get_child(0).visible, "Vent visible hors rafale")
			ReglagesJoueur.effets_reduits = false
			continue
		for i in _terrain.zones.size():
			var zone: Dictionary = _terrain.zones[i]
			var objets := visuel.get_child(i).find_children("*", "MeshInstance3D", true, false)
			_exiger(objets.size() <= 2, "Trop de surfaces par nappe sur mobile")
			for objet: MeshInstance3D in objets:
				var matiere := objet.material_override as StandardMaterial3D
				_exiger(objet.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "Nappe projettant une ombre")
				if matiere.normal_enabled:
					_exiger(matiere.albedo_texture != null and matiere.normal_texture != null, "Peinture ou normales de nappe absentes")
					_exiger(matiere.albedo_texture.get_image().has_mipmaps(), "Peinture de nappe sans mipmaps")
				for s in objet.mesh.get_surface_count():
					var tableaux := objet.mesh.surface_get_arrays(s)
					var sommets: PackedVector3Array = tableaux[Mesh.ARRAY_VERTEX]
					if matiere.normal_enabled:
						var uv: PackedVector2Array = tableaux[Mesh.ARRAY_TEX_UV]
						var tangentes: PackedFloat32Array = tableaux[Mesh.ARRAY_TANGENT]
						_exiger(uv.size() == sommets.size() and tangentes.size() == sommets.size() * 4, "Repere des normales perdu au regroupement")
					for sommet in sommets:
						_exiger(sommet.y <= 0, "Flaque au-dessus des ombres du heros")
						var p := Pont3D.vers_logique(sommet) * .9999
						_exiger(Geometry2D.is_point_in_polygon(p,zone["contour"]), "Dessin de flaque hors de sa zone d'effet")
		if monde in [0, 2]:
			var matiere := DecorsTerrains.matiere(str(_terrain.zones[0]["type"]))
			ReglagesJoueur.effets_reduits = false
			visuel.mettre_a_jour(.5)
			var decalage := matiere.uv1_offset
			ReglagesJoueur.effets_reduits = true
			visuel.mettre_a_jour(.5)
			_exiger(matiere.uv1_offset.is_equal_approx(decalage), "Reflets de nappe mobiles en effets reduits")
			ReglagesJoueur.effets_reduits = false
	visuel.free()
