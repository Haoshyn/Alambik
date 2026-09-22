extends Area2D

# Les caracteristiques du projectile viennent du Tir partage entre les salves.

signal fragments_demandes(origine: Vector2, direction: Vector2, tir_source: Tir, hostile: bool, cible_exclue: int)
signal impact_visuel(position: Vector2, couleur: Color, ampleur: float)

const RAYON := Reglages.TIR_RAYON
const MEMOIRE_TRAINEE := 9

var tir: Tir
var direction := Vector2.RIGHT
var hostile := false
var couleur := Palette.TIR_HALO
# Cible que ce projectile ne doit jamais toucher. Ce garde-fou historique reste
# utile aux projectiles secondaires crees depuis un point d'impact.
var cible_exclue := 0

var _facteur_degats := 1.0
var _distance_parcourue := 0.0
var _rebonds_restants := 0
var _perforations_restantes := 0
var _deja_touches: Array[int] = []
var _corps_exclus: Array[RID] = []
var _trainee: Array[Vector2] = []
var _age := 0.0
var _dernier_touche := 0
var _termine := false
var _rebonds_murs_restants := 0
var _normale_mur := Vector2.ZERO
var _dernier_rebond := -1

func _ready() -> void:
	# Le rendu suit les positions entre deux ticks physiques, indispensable sur
	# les projectiles rapides quand l'ecran du telephone rafraichit au-dessus de 60 Hz.
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	($CollisionShape2D.shape as CircleShape2D).radius = RAYON
	_rebonds_restants = tir.rebonds
	_rebonds_murs_restants = tir.rebonds_murs
	_perforations_restantes = tir.perforations
	if cible_exclue != 0:
		_deja_touches.append(cible_exclue)
		var exclusion := instance_from_id(cible_exclue) as CollisionObject2D
		if exclusion != null: _corps_exclus.append(exclusion.get_rid())
	couleur = Palette.TIR_ENNEMI_HALO if hostile else Palette.teinte_du_tir(tir.effets)
	if hostile:
		add_to_group("tirs_ennemis")
		collision_layer = 16
		collision_mask = 1 | 4
	else:
		add_to_group("tirs_heros")
		collision_layer = 8
		collision_mask = 2 | 4
		if "traverse_murs" in tir.drapeaux:
			collision_mask = 2
		if "indelebile" in tir.drapeaux:
			collision_mask = 0
	body_entered.connect(_sur_contact)

func _physics_process(delta: float) -> void:
	if _termine: return
	if "indelebile" in tir.drapeaux:
		_avancer_indelebile(delta)
		return
	_appliquer_guidage(delta)
	var pas := direction * tir.vitesse * delta
	if hostile and tir.trajectoire == "sinus":
		var avant := sin(_age * TAU * tir.frequence)
		var apres := sin((_age + delta) * TAU * tir.frequence)
		pas += direction.orthogonal() * tir.amplitude * (apres - avant)
	# Le segment bouche les trous entre deux positions de l'Area2D rapide.
	# Les contacts lateraux restent geres par sa forme circulaire.
	var requete := PhysicsRayQueryParameters2D.create(global_position, global_position + pas, collision_mask, _corps_exclus)
	var impact := get_world_2d().direct_space_state.intersect_ray(requete)
	if not impact.is_empty():
		global_position = impact["position"]
		_normale_mur = impact["normal"]
		_sur_contact(impact["collider"])
		_normale_mur = Vector2.ZERO
	else:
		position += pas
	_distance_parcourue += pas.length()
	_age += delta
	_trainee.push_front(position)
	if _trainee.size() > MEMOIRE_TRAINEE:
		_trainee.resize(MEMOIRE_TRAINEE)
	queue_redraw()
	if tir.portee_limitee and _distance_parcourue > tir.portee:
		if not hostile:
			Jeu.tirs_perdus += 1
		queue_free()

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
	_dernier_touche = corps.get_instance_id()

	if not hostile:
		Jeu.tirs_touches += 1
	# Le Tir est partage entre tous les projectiles d'une salve : on ne le mute
	# jamais, la perte de puissance vit dans le projectile.
	var degats_infliges := tir.degats * _facteur_degats
	corps.recevoir_degats(degats_infliges, tir.effets)
	if not hostile:
		get_tree().call_group("charge_combat", "charger_sort")
		if _deja_touches.size() == 1:
			get_tree().call_group("charge_combat", "attaque_touche", global_position,
				degats_infliges, tir.drapeaux, corps)
	if not hostile and tir.rayon_explosion > 0.0 and tir.degats_zone_mult > 0.0:
		_exploser_autour(corps, degats_infliges)
	if not hostile and "orbes_chargees" in tir.drapeaux and _deja_touches.size() == 1:
		_exploser_orbe(corps, degats_infliges)
	impact_visuel.emit(global_position, couleur, 1.0)
	Sons.jouer("impact", -18.0, randf_range(0.9, 1.2))

	if "ricochet_perforation_infinie" in tir.drapeaux:
		if not _rebondir_vers_une_autre_cible():
			_finir()
		return
	if "perfore_tout" in tir.drapeaux:
		return
	match PrioriteProjectile.apres_impact(_rebonds_restants, _perforations_restantes):
		"rebond":
			_rebonds_restants -= 1
			if "annule_malus_degats" not in tir.drapeaux:
				_facteur_degats *= 1.0 - Reglages.REBOND_PERTE
			if not _rebondir_vers_une_autre_cible():
				_finir()
		"perforation":
			_perforations_restantes -= 1
			_facteur_degats *= 1.0 if "perforation_sans_perte" in tir.drapeaux \
				or "annule_malus_degats" in tir.drapeaux else 1.0 - Reglages.PERFORATION_PERTE
		"fin":
			_finir()

func _exploser_autour(cible_principale: Node, degats_principaux: float) -> void:
	for cible in get_tree().get_nodes_in_group("ennemis"):
		if not is_instance_valid(cible) or cible == cible_principale \
				or cible.get_instance_id() in _deja_touches:
			continue
		if cible.global_position.distance_to(global_position) > tir.rayon_explosion:
			continue
		cible.recevoir_degats(degats_principaux * tir.degats_zone_mult \
			* Mods.facteur_heros(Jeu.mods(), "degats_hors_baguette_mult"), tir.effets)

func _exploser_orbe(cible_principale: Node, degats_principaux: float) -> void:
	for cible in get_tree().get_nodes_in_group("ennemis"):
		if not is_instance_valid(cible) or cible == cible_principale:
			continue
		if cible.global_position.distance_to(global_position) <= Reglages.ORBE_RAYON:
			cible.recevoir_degats(degats_principaux * Reglages.ORBE_PART_DEGATS \
				* Mods.facteur_heros(Jeu.mods(), "degats_hors_baguette_mult"), tir.effets)
	impact_visuel.emit(global_position, couleur, 1.5)

func _heurter_un_mur(_mur: Node) -> void:
	if hostile and _dernier_rebond == Engine.get_physics_frames(): return
	if hostile and _rebonds_murs_restants > 0:
		var normale := _normale_mur
		if normale.is_zero_approx():
			# Le contact lateral peut preceder le rayon central. On cherche alors
			# la face du mur sans teleporter le projectile de l'autre cote.
			var depart := global_position - direction * BestiaireMondes.REBOND_MARGE
			var requete := PhysicsRayQueryParameters2D.create(depart, global_position + direction * BestiaireMondes.REBOND_MARGE, 4)
			var impact := get_world_2d().direct_space_state.intersect_ray(requete)
			if not impact.is_empty():
				normale = impact["normal"]
				global_position = impact["position"]
		if not normale.is_zero_approx():
			_rebonds_murs_restants -= 1
			_dernier_rebond = Engine.get_physics_frames()
			direction = direction.bounce(normale).normalized()
			global_position += normale * BestiaireMondes.REBOND_MARGE
			impact_visuel.emit(global_position, couleur, .6)
			return
	if not hostile:
		Jeu.tirs_dans_un_mur += 1
	# Ricochet ne concerne que les impacts sur une creature. Rediriger un tir
	# depuis l'interieur de la collision d'un mur le faisait ressortir de l'autre
	# cote sans nouveau body_entered.
	impact_visuel.emit(global_position, couleur, 0.6)
	_finir(false)

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
	_distance_parcourue = 0.0
	return true

func _avancer_indelebile(delta: float) -> void:
	var cible := instance_from_id(tir.cible_verrouillee) as Node2D
	if cible == null or not is_instance_valid(cible):
		_finir(false)
		return
	var distance := global_position.distance_to(cible.global_position)
	var pas := tir.vitesse * delta
	direction = global_position.direction_to(cible.global_position)
	if distance <= pas + RAYON:
		global_position = cible.global_position
		_sur_contact(cible)
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

func _finir(creer_fragments := true) -> void:
	if _termine:
		return
	_termine = true
	if creer_fragments and tir.fragments > 0:
		fragments_demandes.emit(global_position, direction, tir, hostile, _dernier_touche)
	queue_free()

func _draw() -> void:
	if has_meta("visuel_3d"):
		return
	Retro16.dessiner_projectile(self, _trainee, position, couleur, hostile,
		"trait_familier" in tir.drapeaux)
