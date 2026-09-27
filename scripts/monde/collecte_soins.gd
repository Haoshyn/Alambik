extends Node2D

signal ramasse(soin: float)
signal gouttes_gagnees(montant: int)

const SOINS := preload("res://data/progression/soins_run.gd")
const VISUEL := preload("res://scripts/presentation/coeurs_sol.gd")

var _heros: Node2D
var _salle: Node2D
var _visuel: Node2D
var _graine := 0
var _mine := false
var _intervalle := -1
var _indices: Array[int] = []
var _morts := 0
var _morts_vues := {}
var _depots: Array[Vector2] = []
var _position_precedente := Vector2.ZERO
var _actif := true

func configurer(heros: Node2D, salle: Node2D, graine: int, combattants: int, mine := false) -> void:
	_heros = heros
	_salle = salle
	_graine = graine
	_mine = mine
	_position_precedente = heros.global_position if is_instance_valid(heros) else Vector2.ZERO
	_visuel = VISUEL.new()
	add_child(_visuel)
	_planifier(0, SOINS.MINE_MORTS_CANDIDATES if mine else combattants)

func _planifier(intervalle: int, combattants: int) -> void:
	_intervalle = intervalle
	_morts = 0
	var alea := RandomNumberGenerator.new()
	# Le soin ne decale ni les vagues, ni les elites, ni les choix d'augments.
	alea.seed = hash("%d/coeurs/%d" % [_graine, intervalle])
	var quota := SOINS.quota_pour_tirage(alea.randf())
	_indices = SOINS.indices_de_morts(combattants, quota, alea)

func avancer_mine(temps: float, duree: float) -> void:
	if not _mine or not _actif: return
	var intervalle := SOINS.intervalle_mine(temps, duree)
	if intervalle > _intervalle:
		_planifier(intervalle, SOINS.MINE_MORTS_CANDIDATES)

func enregistrer_mort(ennemi: Node, point: Vector2) -> void:
	if not _actif or not is_instance_valid(ennemi) or ennemi.has_meta("invocateur"): return
	var identifiant := ennemi.get_instance_id()
	if _morts_vues.has(identifiant): return
	_morts_vues[identifiant] = true
	_morts += 1
	if not _heros_vivant(): return
	var nombre := _indices.count(_morts)
	for index in nombre:
		var decalage := (float(index) - float(nombre - 1) * 0.5) * SOINS.ECART_DEPOTS
		_depots.append(_position_depot(point, Vector2(decalage, 0.0)))
	if nombre > 0: _afficher()

func nombre_au_sol() -> int:
	return _depots.size()

func positions_au_sol() -> Array[Vector2]:
	return _depots.duplicate()

func arreter() -> void:
	_actif = false
	set_physics_process(false)

func ramasser_avant_transition() -> void:
	# Les dernieres morts restent visibles pendant la collecte de fin, puis aucun
	# coeur ne se perd dans une victoire ou une transition automatique d'Epreuve.
	if not _actif: return
	# Fermer avant les signaux empeche une transition repetee de recompter les coeurs.
	arreter()
	if not _heros_vivant(): return
	var nombre := _depots.size()
	_depots.clear()
	_afficher()
	for _coeur in nombre:
		if not _heros_vivant(): return
		if float(_heros.stats.pv) < float(_heros.stats.pv_max):
			_soigner(1)
		else:
			gouttes_gagnees.emit(SOINS.GOUTTES_PAR_COEUR_INUTILISE)

func _heros_vivant() -> bool:
	return is_instance_valid(_heros) and not _heros.is_queued_for_deletion() \
		and not _heros.stats.est_mort()

func _physics_process(_delta: float) -> void:
	if not _actif or not _heros_vivant(): return
	var position_heros := _heros.global_position
	var restants: Array[Vector2] = []
	var nombre := 0
	var obstacles: Array = _salle.obstacles()
	var soin_unitaire := SOINS.soin_base(float(_heros.stats.pv_max)) * maxf(0.0, float(_heros.stats.soin_mult))
	var manquants := maxf(0.0, float(_heros.stats.pv_max) - float(_heros.stats.pv))
	var necessaires := ceili(manquants / soin_unitaire) if soin_unitaire > 0.0 else 0
	for point in _depots:
		var proche := Geometry2D.get_closest_point_to_segment(point, _position_precedente, position_heros)
		if nombre < necessaires \
				and point.distance_to(proche) <= SOINS.RAYON_RAMASSAGE \
				and Geometrie.ligne_libre(point, proche, obstacles):
			nombre += 1
		else:
			restants.append(point)
	_position_precedente = position_heros
	if nombre <= 0: return
	_depots = restants
	_afficher()
	_soigner(nombre)

func _soigner(nombre: int) -> void:
	var avant := float(_heros.stats.pv)
	_heros.stats.soigner_garanti(SOINS.soin_base(float(_heros.stats.pv_max)) * nombre)
	ramasse.emit(float(_heros.stats.pv) - avant)

func _position_depot(point: Vector2, decalage: Vector2) -> Vector2:
	var limites: Rect2 = _salle.limites
	var resultat := Geometrie.contraindre_dans_rect(point + decalage, limites, SOINS.MARGE_DEPOT)
	var obstacles: Array = _salle.obstacles()
	for obstacle: Rect2 in obstacles:
		var bord := obstacle.grow(SOINS.MARGE_DEPOT)
		if not bord.has_point(resultat): continue
		var sorties: Array[Vector2] = [Vector2(bord.position.x, resultat.y),
			Vector2(bord.end.x, resultat.y), Vector2(resultat.x, bord.position.y), Vector2(resultat.x, bord.end.y)]
		var distance := INF
		for sortie in sorties:
			if not limites.grow(-SOINS.MARGE_DEPOT).has_point(sortie): continue
			var ecart := point.distance_squared_to(sortie)
			if ecart < distance:
				distance = ecart
				resultat = sortie
	# Le decalage des doubles depots ne doit franchir ni muret ni bord arrondi.
	if not Geometrie.ligne_libre(point, resultat, obstacles): return point
	if _salle.has_method("contour_sol"):
		var contour: PackedVector2Array = _salle.contour_sol()
		if not Geometry2D.is_point_in_polygon(resultat, contour): return point
	return resultat

func _afficher() -> void:
	_visuel.afficher_depots(_depots)
