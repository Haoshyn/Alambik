extends Area2D

# Les caracteristiques du projectile viennent du Tir partage entre les salves.

signal impact_visuel(position: Vector2, couleur: Color, ampleur: float)

const RAYON := Reglages.TIR_RAYON
const MEMOIRE_TRAINEE := 9

var tir: Tir
var direction := Vector2.RIGHT
var hostile := false
var couleur := Palette.TIR_HALO
var _facteur_degats := 1.0
var _distance_parcourue := 0.0
var _rebonds_restants := 0
var _perforations_restantes := 0
var _deja_touches: Array[int] = []
var _corps_exclus: Array[RID] = []
var _trainee: Array[Vector2] = []
var _age := 0.0
var _termine := false
var _rebonds_murs_restants := 0
var _normale_mur := Vector2.ZERO
var _dernier_rebond := -1
var _origine := Vector2.ZERO
var _retour := false
var _attente_retour := 0.0
var _forme: CollisionShape2D

func _ready() -> void:
	# Le rendu suit les positions entre deux ticks physiques, indispensable sur
	# les projectiles rapides quand l'ecran du telephone rafraichit au-dessus de 60 Hz.
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	_origine = global_position
	_forme = $CollisionShape2D
	# Chaque instance possede sa forme : la scene ne partage plus un rayon mutable.
	if tir.longueur > tir.rayon * 2.0:
		var capsule := CapsuleShape2D.new()
		capsule.radius = tir.rayon
		capsule.height = tir.longueur
		_forme.shape = capsule
	else:
		var cercle := CircleShape2D.new()
		cercle.radius = tir.rayon
		_forme.shape = cercle
	_forme.rotation = direction.angle() + PI * .5
	_rebonds_restants = tir.rebonds
	_rebonds_murs_restants = tir.rebonds_murs
	_perforations_restantes = tir.perforations
	couleur = Palette.TIR_ENNEMI_HALO if hostile else Palette.teinte_du_tir(tir.effets)
	if "trait_familier" in tir.drapeaux:
		couleur = Color("66dfd3")
	if "trait_periodique" in tir.drapeaux:
		couleur = Color("86e8d1")
	if hostile:
		add_to_group("tirs_ennemis")
		collision_layer = 16
		collision_mask = 1 | 4
	else:
		add_to_group("tirs_heros")
		collision_layer = 8
		collision_mask = 2 | 4
		if "indelebile" in tir.drapeaux:
			collision_mask = 0
	if tir.traverse_murs:
		collision_mask &= ~4
	body_entered.connect(_sur_contact)

func _physics_process(delta: float) -> void:
	if _termine: return
	if not hostile and "indelebile" in tir.drapeaux:
		_avancer_indelebile(delta)
		return
	_appliquer_guidage(delta)
	if tir.trajectoire == "aller_retour":
		var distance_origine := global_position.distance_to(_origine)
		if not _retour and (distance_origine >= tir.distance_retour or is_equal_approx(distance_origine, tir.distance_retour)):
			_commencer_retour()
		if _attente_retour > 0.0:
			_attente_retour = maxf(0.0, _attente_retour - delta)
			queue_redraw()
			return
	var pas := direction * tir.vitesse * delta
	var fin_retour := false
	if tir.trajectoire == "aller_retour":
		if _retour:
			var restant := global_position.distance_to(_origine)
			fin_retour = restant <= pas.length()
			pas = pas.limit_length(restant)
		else:
			pas = pas.limit_length(maxf(0.0, tir.distance_retour - global_position.distance_to(_origine)))
	if hostile and tir.trajectoire == "sinus":
		var avant := sin(_age * TAU * tir.frequence)
		var apres := sin((_age + delta) * TAU * tir.frequence)
		pas += direction.orthogonal() * tir.amplitude * (apres - avant)
	# Balayer toute la forme evite de traverser un coin ou un heros entre deux ticks.
	_forme.rotation = pas.angle() + PI * .5
	var impact := _balayer(pas)
	var distance_effective := pas.length()
	if not impact.is_empty():
		global_position += pas * float(impact["fraction"])
		distance_effective *= float(impact["fraction"])
		_normale_mur = impact["normal"]
		var corps := instance_from_id(int(impact["collider_id"])) as Node
		if is_instance_valid(corps): _sur_contact(corps)
		_normale_mur = Vector2.ZERO
	else:
		position += pas
	_distance_parcourue += distance_effective
	_age += delta
	_trainee.push_front(position)
	if _trainee.size() > MEMOIRE_TRAINEE:
		_trainee.resize(MEMOIRE_TRAINEE)
	queue_redraw()
	# Le dernier segment du retour doit lui aussi pouvoir toucher le heros.
	if fin_retour and not _termine:
		_finir()
		return
	if tir.portee_limitee and _distance_parcourue > tir.portee:
		if not hostile:
			Jeu.tirs_perdus += 1
		queue_free()

func _balayer(pas: Vector2) -> Dictionary:
	var requete := PhysicsShapeQueryParameters2D.new()
	requete.shape = _forme.shape
	requete.transform = _forme.global_transform
	requete.collision_mask = collision_mask
	requete.exclude = _corps_exclus
	var espace := get_world_2d().direct_space_state
	var impact := espace.get_rest_info(requete)
	if not impact.is_empty():
		impact["fraction"] = 0.0
		return impact
	requete.motion = pas
	var fractions := espace.cast_motion(requete)
	if fractions[0] >= 1.0: return {}
	requete.transform.origin += pas * fractions[1]
	requete.motion = Vector2.ZERO
	impact = espace.get_rest_info(requete)
	if not impact.is_empty(): impact["fraction"] = fractions[0]
	return impact

func _sur_contact(corps: Node) -> void:
	if _termine:
		return
	if not corps.has_method("recevoir_degats"):
		_heurter_un_mur(corps)
		return
	# Un projectile perforant ne doit pas frapper deux fois le meme ennemi.
	if corps.get_instance_id() in _deja_touches:
		return
	_deja_touches.append(corps.get_instance_id())
	if corps is CollisionObject2D: _corps_exclus.append(corps.get_rid())

	if not hostile:
		Jeu.tirs_touches += 1
	# Le Tir est partage entre tous les projectiles d'une salve : on ne le mute
	# jamais, la perte de puissance vit dans le projectile.
	var degats_infliges := tir.degats * _facteur_degats
	corps.recevoir_degats(degats_infliges, tir.effets)
	impact_visuel.emit(global_position, couleur, 1.0)
	Sons.jouer("impact", -18.0, randf_range(0.9, 1.2))

	if _rebonds_restants > 0:
		_rebonds_restants -= 1
		_facteur_degats *= 1.0 - Reglages.REBOND_PERTE
		if not _rebondir_vers_une_autre_cible():
			if "perfore_tout" not in tir.drapeaux:
				_finir()
		return
	if "perfore_tout" in tir.drapeaux:
		return
	match PrioriteProjectile.apres_impact(_rebonds_restants, _perforations_restantes):
		"perforation":
			_perforations_restantes -= 1
			if "perforation_sans_perte" not in tir.drapeaux:
				_facteur_degats *= 1.0 - Reglages.PERFORATION_PERTE
		"fin":
			_finir()

func _commencer_retour() -> void:
	_retour = true
	_attente_retour = tir.pause_retour
	direction = global_position.direction_to(_origine)
	_trainee.clear()

func _heurter_un_mur(_mur: Node) -> void:
	if tir.traverse_murs: return
	if hostile and _dernier_rebond == Engine.get_physics_frames(): return
	var retour_sur_mur := hostile and tir.trajectoire == "aller_retour" and not _retour
	if hostile and (_rebonds_murs_restants > 0 or retour_sur_mur):
		var normale := _normale_mur
		if normale.is_zero_approx():
			var requete := PhysicsShapeQueryParameters2D.new()
			requete.shape = _forme.shape
			requete.transform = _forme.global_transform
			requete.collision_mask = 4
			var impact := get_world_2d().direct_space_state.get_rest_info(requete)
			if not impact.is_empty():
				normale = impact["normal"]
		if not normale.is_zero_approx():
			_dernier_rebond = Engine.get_physics_frames()
			global_position += normale * BestiaireMondes.REBOND_MARGE
			if retour_sur_mur:
				_commencer_retour()
			else:
				_rebonds_murs_restants -= 1
				direction = direction.bounce(normale).normalized()
				_trainee.clear()
			impact_visuel.emit(global_position, couleur, .6)
			return
	if not hostile:
		Jeu.tirs_dans_un_mur += 1
	# Ricochet ne concerne que les impacts sur une creature. Rediriger un tir
	# depuis l'interieur de la collision d'un mur le faisait ressortir de l'autre
	# cote sans nouveau body_entered.
	impact_visuel.emit(global_position, couleur, 0.6)
	_finir()

func _rebondir_vers_une_autre_cible() -> bool:
	var positions: Array[Vector2] = []
	var noeuds: Array[Node] = []
	var groupe := "heros" if hostile else "ennemis"
	for noeud in get_tree().get_nodes_in_group(groupe):
		if not is_instance_valid(noeud) or noeud.get_instance_id() in _deja_touches:
			continue
		noeuds.append(noeud)
		positions.append(noeud.global_position)
	var index := Ciblage.plus_proche(global_position, positions)
	if index == -1:
		return false
	direction = global_position.direction_to(positions[index])
	if "indelebile" in tir.drapeaux:
		tir.cible_verrouillee = noeuds[index].get_instance_id()
	_distance_parcourue = 0.0
	return true

func _avancer_indelebile(delta: float) -> void:
	var cible := instance_from_id(tir.cible_verrouillee) as Node2D
	if not is_instance_valid(cible):
		_finir()
		return
	var distance := global_position.distance_to(cible.global_position)
	var pas := tir.vitesse * delta
	direction = global_position.direction_to(cible.global_position)
	if distance <= pas + RAYON:
		global_position = cible.global_position
		_sur_contact(cible)
		# Un ricochet peut verrouiller la cible suivante ; autrement le tir finit.
		if tir.cible_verrouillee in _deja_touches:
			_finir()
		return
	global_position += direction * pas
	_age += delta
	_trainee.push_front(position)
	if _trainee.size() > MEMOIRE_TRAINEE:
		_trainee.resize(MEMOIRE_TRAINEE)
	queue_redraw()

func _appliquer_guidage(delta: float) -> void:
	if hostile:
		return
	if "homing" in tir.drapeaux:
		var positions: Array[Vector2] = []
		for cible in get_tree().get_nodes_in_group("ennemis"):
			if is_instance_valid(cible) and not cible.get_instance_id() in _deja_touches:
				positions.append(cible.global_position)
		var index := Ciblage.plus_proche(global_position, positions)
		if index != -1:
			# Homing doit sauver un tir qui aurait manque, pas seulement corriger de
			# quelques degres une trajectoire deja bonne.
			direction = direction.lerp(global_position.direction_to(positions[index]),
				minf(1.0, delta * Reglages.HOMING_ROTATION_PAR_SECONDE)).normalized()

func _finir() -> void:
	if _termine:
		return
	_termine = true
	queue_free()

func _draw() -> void:
	if has_meta("visuel_3d"):
		return
	if hostile or "trait_familier" in tir.drapeaux:
		preload("res://scripts/presentation/dessin_projectiles.gd").dessiner(self)
		return
	Retro16.dessiner_projectile(self, _trainee, position, couleur, hostile,
		"trait_familier" in tir.drapeaux)
