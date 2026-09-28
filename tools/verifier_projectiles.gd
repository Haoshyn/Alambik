extends SceneTree

const FAMILIER := preload("res://scripts/combat/familier.gd")
const FORMES := preload("res://data/presentation/formes_tirs.gd")
const RENDU := preload("res://data/presentation/animations_projectiles.gd")

class CibleTest extends CharacterBody2D:
	var coups := 0
	func recevoir_degats(_montant: float, _effets: Array = []) -> void: coups += 1

class SalleTest extends Node2D:
	var limites := Rect2(0, 0, 1200, 1800)
	var blocs: Array[Rect2] = []
	func obstacles() -> Array[Rect2]: return blocs
	func contour_sol() -> PackedVector2Array:
		return PackedVector2Array([limites.position, Vector2(limites.end.x, limites.position.y), limites.end, Vector2(limites.position.x, limites.end.y)])

var _erreurs: Array[String] = []
var _controles := 0
var _scene: Node2D

func _init() -> void:
	_executer.call_deferred()

func _executer() -> void:
	if "verification" not in OS.get_user_data_dir().to_lower():
		push_error("Profil de verification isole requis.")
		quit(1)
		return
	root.get_node("ReglagesJoueur").sauvegarde_active = false
	_scene = Node2D.new()
	root.add_child(_scene)
	_catalogues()
	await _collisions()
	await _contacts_monstres()
	await _trajectoires()
	await _familier()
	await _boss()
	await _rendus()
	_scene.free()
	for erreur in _erreurs: push_error(erreur)
	print("Projectiles : %d controles, %d erreurs (collisions, retours, rebonds, familier et contact)." % [_controles, _erreurs.size()])
	quit(0 if _erreurs.is_empty() else 1)

func _exiger(condition: bool, message: String) -> void:
	_controles += 1
	if not condition: _erreurs.append(message)

func _catalogues() -> void:
	for monde in Chapitres.MONDES.size():
		var signatures: Array[String] = []
		for id: String in ProjectilesEnnemis.PROFILS:
			var donnees := BestiaireMondes.appliquer(CatalogueEnnemis.par_id(id), id, monde * Chapitres.CHAPITRES_PAR_MONDE)
			var tir := _tir(id)
			ProjectilesEnnemis.appliquer(tir, donnees)
			_exiger(tir.silhouette not in signatures, "Identite de tir partagee : " + id)
			signatures.append(tir.silhouette)
			_exiger(RENDU.PROFILS.has(tir.silhouette), "Profil visuel absent : " + id)
			_exiger(not Geometry2D.triangulate_polygon(FORMES.contour(id)).is_empty(), "Contour invalide : " + id)
			_exiger(tir.rayon > 0 and tir.longueur >= tir.rayon * 2, "Collision invalide : " + id)
			var copie := tir.copie()
			_exiger(copie.rayon == tir.rayon and copie.longueur == tir.longueur and copie.distance_retour == tir.distance_retour, "Copie incomplete : " + id)
			if donnees.has("contact_boss"):
				for cle in ["motifs_phase_1", "motifs_phase_2"]:
					_exiger("assaut_contact" in donnees[cle] and "pause" in donnees[cle], "Contact et respiration perdus : " + id)
					var motifs_source: Array = CatalogueEnnemis.par_id(id)[cle]
					_exiger(motifs_source[1] in donnees[cle], "Signature remplacee par le monde : " + id)
			if tir.rebonds_murs > 0: _exiger(tir.vitesse <= ProjectilesEnnemis.REBOND_VITESSE_MAX, "Ricochet trop rapide : " + id)

func _tir(id: String) -> Tir:
	var tir := Tir.new()
	var d := CatalogueEnnemis.par_id(id)
	tir.degats = 1.0
	tir.vitesse = float(d["vitesse_projectile"])
	tir.portee = 5000.0
	ProjectilesEnnemis.appliquer(tir, d)
	return tir

func _projectile(tir: Tir, point: Vector2, hostile := true) -> Area2D:
	var p: Area2D = load("res://scenes/projectile.tscn").instantiate()
	p.tir = tir
	p.position = point
	p.direction = Vector2.RIGHT
	p.hostile = hostile
	_scene.add_child(p)
	p.set_physics_process(false)
	return p

func _cible(point: Vector2, camp: int, rayon := 10.0) -> CibleTest:
	var cible := CibleTest.new()
	cible.position = point
	cible.collision_layer = camp
	cible.collision_mask = 0
	var collision := CollisionShape2D.new()
	var forme := CircleShape2D.new()
	forme.radius = rayon
	collision.shape = forme
	cible.add_child(collision)
	_scene.add_child(cible)
	return cible

func _mur(point: Vector2) -> StaticBody2D:
	var mur := StaticBody2D.new()
	mur.collision_layer = 4
	mur.collision_mask = 0
	mur.position = point
	var collision := CollisionShape2D.new()
	var forme := RectangleShape2D.new()
	forme.size = Vector2(12, 300)
	collision.shape = forme
	mur.add_child(collision)
	_scene.add_child(mur)
	return mur

func _avancer(p: Node, secondes: float, pas := 1.0 / 60.0) -> void:
	for i in ceili(secondes / pas):
		if not is_instance_valid(p) or p.is_queued_for_deletion(): return
		p._physics_process(pas)

func _vider() -> void:
	for enfant in _scene.get_children(): enfant.queue_free()
	await process_frame

func _collisions() -> void:
	for id: String in ProjectilesEnnemis.PROFILS:
		var contact := _cible(Vector2(200, 200), 1, Reglages.HEROS_RAYON)
		await physics_frame
		await physics_frame
		var superpose := _projectile(_tir(id), contact.position)
		_avancer(superpose, 1.0 / 60.0)
		_exiger(contact.coups == 1, "Projectile deja au contact inflige ses degats : " + id)
		await _vider()
	var cible := _cible(Vector2(250, 200), 1)
	await physics_frame
	await physics_frame
	var fin := _projectile(_tir("plume_sentinelle"), Vector2(50, 226))
	_avancer(fin, .6)
	_exiger(cible.coups == 0, "Aiguille etroite : passage lateral ferme")
	var gros := _projectile(_tir("roi_braises"), Vector2(50, 226))
	_exiger((fin.get_node("CollisionShape2D") as CollisionShape2D).shape != (gros.get_node("CollisionShape2D") as CollisionShape2D).shape, "Formes partagees entre projectiles")
	_avancer(gros, 1.1)
	_exiger(cible.coups == 1, "Grosse boule : collision laterale absente")
	await _vider()
	cible = _cible(Vector2(200, 200), 1)
	await physics_frame
	await physics_frame
	var rapide := _tir("plume_sentinelle")
	rapide.vitesse = 12000.0
	var p := _projectile(rapide, Vector2(50, 214))
	_avancer(p, 1.0 / 60.0)
	_exiger(cible.coups == 1, "Balayage de capsule rapide : cible traversee")
	await _vider()
	_mur(Vector2(160, 200))
	_mur(Vector2(240, 200))
	cible = _cible(Vector2(330, 200), 2)
	await physics_frame
	await physics_frame
	var tir := Tir.new()
	tir.vitesse = 1050.0
	tir.degats = 1.0
	p = _projectile(tir, Vector2(60, 200), false)
	_avancer(p, .5)
	_exiger(cible.coups == 0 and p.is_queued_for_deletion(), "Le tir ordinaire doit heurter le mur")
	CatalogueFamiliers.configurer_tir(tir, "homoncule_encre", Vector2(1200, 1800))
	p = _projectile(tir, Vector2(60, 200), false)
	_avancer(p, .5)
	_exiger(cible.coups == 1, "Familier : les deux murs bloquent encore sa cible")
	_exiger((p.collision_mask & 4) == 0 and (p.collision_mask & 2) != 0, "Familier : masque incorrect")
	await _vider()
	p = _projectile(tir, Vector2(60, 200), false)
	_avancer(p, 3.0)
	_exiger(p.is_queued_for_deletion(), "Tir traversant les murs exterieurs sans fin de vie")
	await _vider()

func _contacts_monstres() -> void:
	for id: String in ["encrier_rampant", "tache_veloce", "sceau_belier"]:
		var salle := SalleTest.new()
		_scene.add_child(salle)
		var cible := _cible(Vector2(600, 700), 1, Reglages.HEROS_RAYON)
		cible.add_to_group("cibles_ennemis")
		var ennemi: CharacterBody2D = load("res://scenes/ennemi.tscn").instantiate()
		ennemi.configurer(CatalogueEnnemis.par_id(id))
		ennemi.position = cible.position - Vector2(0, 35)
		salle.add_child(ennemi)
		ennemi.set_physics_process(false)
		ennemi._apparition = 1.0
		ennemi._recharge = 10.0
		ennemi._physics_process(.016)
		_exiger(cible.coups == 1, "Contact immediat independant de la preparation : " + id)
		ennemi._physics_process(.016)
		_exiger(cible.coups == 1, "Un contact ne multiplie pas les degats par image : " + id)
		ennemi.position = cible.position + Vector2(300, 0)
		ennemi._recharge_contact = 0.0
		ennemi._physics_process(.016)
		_exiger(cible.coups == 1, "Aucun contact a distance : " + id)
		ennemi.position = cible.position + Vector2(100, 0)
		_exiger(CapacitesEnnemis.frapper_sur_segment(ennemi, cible.position - Vector2(100, 0)), "Croisement rapide du corps detecte : " + id)
		_exiger(cible.coups == 2, "Croisement inflige les degats : " + id)
		ennemi._recharge_contact = 0.0
		ennemi.position = cible.position - Vector2(35, 0)
		salle.blocs.assign([Rect2(cible.position - Vector2(20, 50), Vector2(4, 100))])
		_exiger(not CapacitesEnnemis.frapper_sur_segment(ennemi, ennemi.position), "Obstacle protege du contact : " + id)
		salle.blocs.clear()
		_exiger(CapacitesEnnemis.frapper_sur_segment(ennemi, ennemi.position) and cible.coups == 3, "Contact redevient dangereux apres recharge : " + id)
		await _vider()
	var salle := SalleTest.new()
	_scene.add_child(salle)
	var heros: CharacterBody2D = load("res://scenes/heros.tscn").instantiate()
	heros.position = Vector2(600, 700)
	salle.add_child(heros)
	heros.set_physics_process(false)
	heros.bouclier = 0
	heros._invulnerable = 0.0
	var pv_avant: float = heros.stats.pv
	var poursuivant: CharacterBody2D = load("res://scenes/ennemi.tscn").instantiate()
	poursuivant.configurer(CatalogueEnnemis.par_id("encrier_rampant"))
	poursuivant.position = heros.position - Vector2(0, 35)
	salle.add_child(poursuivant)
	poursuivant.set_physics_process(false)
	poursuivant._apparition = 1.0
	poursuivant._physics_process(.016)
	_exiger(float(heros.stats.pv) < pv_avant, "Contact retire effectivement des PV au heros")
	var pv_apres: float = heros.stats.pv
	poursuivant._recharge_contact = 0.0
	poursuivant._physics_process(.016)
	_exiger(is_equal_approx(float(heros.stats.pv), pv_apres), "Invulnerabilite normale apres impact preservee")
	await _vider()

func _trajectoires() -> void:
	var p := _projectile(_tir("folio_orbiteur"), Vector2(100, 200))
	var duree_aller: float = p.tir.distance_retour / p.tir.vitesse
	_avancer(p, duree_aller + .025)
	_exiger(p._retour and p.direction.x < 0.0 and p._attente_retour > 0.0, "Boomerang : demi-tour et pause absents")
	var sommet := p.position
	_avancer(p, ProjectilesEnnemis.RETOUR_PAUSE * .25)
	_exiger(p.position.is_equal_approx(sommet), "Boomerang : pause de lecture absente")
	_avancer(p, duree_aller + ProjectilesEnnemis.RETOUR_PAUSE)
	_exiger(p.is_queued_for_deletion(), "Boomerang : ne finit pas a son origine")
	await _vider()
	for angle in [.17, .63, 1.27, 2.39]:
		p = _projectile(_tir("folio_orbiteur"), Vector2(100, 200))
		p.direction = Vector2.from_angle(angle)
		_avancer(p, duree_aller * 2.0 + ProjectilesEnnemis.RETOUR_PAUSE + .1)
		_exiger(p.is_queued_for_deletion(), "Boomerang diagonal bloque au demi-tour")
	await _vider()
	for id: String in ["l_errata", "virgule_noire", "souverain_ombres"]:
		var tir := _tir(id)
		tir.vitesse *= Reglages.BOSS_PROJECTILE_VITESSE_MULT
		ProjectilesEnnemis.appliquer(tir, CatalogueEnnemis.par_id(id))
		p = _projectile(tir, Vector2(100, 200))
		_avancer(p, 1500.0 / tir.vitesse)
		_exiger(not p.is_queued_for_deletion() and not p._retour and p.position.x >= 1590.0,
			"Boomerang de boss atteint le fond sans demi-tour premature : " + id)
		_avancer(p, tir.distance_retour * 2.0 / tir.vitesse + tir.pause_retour)
		_exiger(p.is_queued_for_deletion(), "Boomerang de boss finit son aller-retour : " + id)
		await _vider()
		_mur(Vector2(500, 200))
		await physics_frame
		await physics_frame
		p = _projectile(tir, Vector2(100, 200))
		_avancer(p, 410.0 / tir.vitesse)
		_exiger(not p.is_queued_for_deletion() and p._retour and p.direction.x < 0,
			"Le mur declenche un retour vivant : " + id)
		await physics_frame
		_avancer(p, 1.0)
		_exiger(p.is_queued_for_deletion(), "Retour depuis un mur rejoint son origine : " + id)
		await _vider()
	# Le heros est touche sur le dernier tick du retour, juste devant l'origine.
	var cible_retour := _cible(Vector2(112, 200), 1, Reglages.HEROS_RAYON)
	await physics_frame
	await physics_frame
	p = _projectile(_tir("l_errata"), Vector2(100, 200))
	p.position = Vector2(190, 200)
	p._retour = true
	p.direction = Vector2.LEFT
	p.tir.vitesse = 12000.0
	_avancer(p, 1.0 / 60.0)
	_exiger(cible_retour.coups == 1, "Dernier segment du boomerang inflige les degats de contact")
	await _vider()
	_mur(Vector2(350, 200))
	_mur(Vector2(30, 200))
	await physics_frame
	await physics_frame
	p = _projectile(_tir("miroir_encre"), Vector2(180, 200))
	_avancer(p, .7)
	_exiger(not p.is_queued_for_deletion() and p.direction.x < 0.0 and p._rebonds_murs_restants == 0, "Ricochet : rebond unique incorrect")
	await physics_frame
	_avancer(p, 1.5)
	_exiger(p.is_queued_for_deletion(), "Ricochet : rebond illimite")
	await _vider()

func _familier() -> void:
	var salle := SalleTest.new()
	salle.blocs.append(Rect2(400, 650, 180, 180))
	_scene.add_child(salle)
	var cible := _cible(Vector2(600, 400), 2)
	cible.add_to_group("ennemis")
	var heros := _cible(Vector2(600, 1650), 1)
	heros.add_to_group("heros")
	var a := FAMILIER.new()
	var b := FAMILIER.new()
	_scene.add_child(a)
	_scene.add_child(b)
	a.preparer(salle, "homoncule_encre", 42)
	b.preparer(salle, "homoncule_encre", 42)
	var positions_tirs: Array[Vector2] = []
	a.tir_demande.connect(func(_id: String, origine: Vector2, _direction: Vector2): positions_tirs.append(origine))
	var depart := a.position
	for i in 360:
		heros.position = Vector2(100, 100) if i % 2 == 0 else Vector2(1100, 1700)
		a.avancer(1.0 / 60.0)
		heros.position = Vector2(600, 1600)
		b.avancer(1.0 / 60.0)
		_exiger(a.position.is_equal_approx(b.position), "Familier depend de la position du heros")
		_exiger(a._point_valide(a.position), "Familier sort du sol ou traverse un obstacle")
	_exiger(a.position.distance_to(depart) > 30.0 and positions_tirs.size() >= 2, "Familier : cycle de mouvement et de tir absent")
	if positions_tirs.size() >= 2: _exiger(positions_tirs[0].distance_to(positions_tirs[1]) > 20.0, "Familier immobile entre deux tirs")
	a.preparer(salle, "golem", 84)
	_exiger(a.id == "golem" and a.etat == "deplacement", "Familier : transition de salle incorrecte")
	await _vider()

func _boss() -> void:
	for id: String in AttaquesContactBoss.PROFILS:
		var salle := SalleTest.new()
		_scene.add_child(salle)
		var cible := _cible(Vector2(600, 650), 1, Reglages.HEROS_RAYON)
		cible.add_to_group("cibles_ennemis")
		var boss: CharacterBody2D = load("res://scenes/boss.tscn").instantiate()
		boss.configurer(CatalogueEnnemis.par_id(id).duplicate(true))
		boss.position = Vector2(600, 500)
		salle.add_child(boss)
		boss.set_physics_process(false)
		boss._motif = "assaut_contact"
		boss._commencer_motif("assaut_contact")
		boss._executer_motif("assaut_contact", .01)
		_exiger(boss._contact.etat == "annonce" and cible.coups == 0, "Frappe sans annonce : " + id)
		var direction: Vector2 = boss._contact.direction
		cible.position = Vector2(600, 350)
		boss._executer_motif("assaut_contact", .1)
		_exiger(boss._contact.direction == direction and boss.velocity == Vector2.ZERO, "Visee de contact poursuit le heros : " + id)
		cible.position = Vector2(600, 650)
		boss._executer_motif("assaut_contact", 2.0)
		_exiger(cible.coups == 1, "Frappe annoncee ne touche pas : " + id)
		boss._executer_motif("assaut_contact", .2)
		_exiger(boss._contact.etat == "recuperation", "Recuperation absente : " + id)
		for i in 60: boss._executer_motif("assaut_contact", 1.0 / 60.0)
		_exiger(cible.coups == 1 and boss._contact.etat == "recuperation" and boss.velocity == Vector2.ZERO, "Boss harcele pendant le repos : " + id)
		var profil: Dictionary = boss._contact.profil
		if float(profil["arc"]) < TAU:
			_exiger(not AttaquesContactBoss.contient_cible(boss.position, Vector2.DOWN, Vector2(600, 350), profil, Reglages.HEROS_RAYON), "Dos du boss sans zone sure : " + id)
		await _vider()

func _rendus() -> void:
	var identites: Array = ProjectilesEnnemis.PROFILS.keys() + CatalogueFamiliers.TYPES.keys()
	for id: String in identites:
		var tir := _tir(id) if ProjectilesEnnemis.PROFILS.has(id) else Tir.new()
		var hostile := ProjectilesEnnemis.PROFILS.has(id)
		if not hostile: CatalogueFamiliers.configurer_tir(tir, id, Vector2(1200, 1800))
		var projectile := _projectile(tir, Vector2(500, 500), hostile)
		var proxy: Node3D = load("res://scripts/presentation/projectile_3d.gd").new()
		_scene.add_child(proxy)
		proxy.preparer(projectile, null, "projectile")
		projectile._trainee.assign([projectile.position, projectile.position - Vector2(200, 0), projectile.position - Vector2(400, 0)])
		if hostile:
			for monde in Chapitres.MONDES.size():
				_exiger(RENDU.couleur_hostile(id, monde).s >= RENDU.SATURATION_HOSTILE_MIN - .001, "Projectile sature dans chaque monde : " + id)
			var bord_sombre := false
			for piece: MeshInstance3D in proxy._tourbillon.get_children():
				var couleurs: PackedColorArray = piece.mesh.surface_get_arrays(0)[Mesh.ARRAY_COLOR]
				for couleur: Color in couleurs:
					if couleur.is_equal_approx(RENDU.CONTOUR_HOSTILE): bord_sombre = true
			_exiger(bord_sombre, "Contour opaque lisible sans halo : " + id)
		for reduit in [false, true]:
			root.get_node("ReglagesJoueur").effets_reduits = reduit
			proxy.mettre_a_jour(.1)
			if hostile:
				_exiger(proxy._ruban.get_surface_count() > 0, "Trainee presente meme en effets reduits : " + id)
				var sommets: PackedVector3Array = proxy._ruban.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
				for point: Vector3 in sommets:
					_exiger(absf(point.x) <= RENDU.TRAINEE_HOSTILE_LONGUEUR_MAX * Pont3D.ECHELLE + .001, "Trainee rapide bornee, sans faux rayon dangereux : " + id)
		_exiger(proxy.modele.get_child_count() > 0, "Volume absent : " + id)
		await _vider()
