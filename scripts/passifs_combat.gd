extends RefCounted

const ReglagesPassifs = preload("res://data/passifs_combat.gd")

var _audace_disponible := true
var _rempart_disponible := true
var _distance_parcourue := 0.0
var _tir_givre_pret := false
var _derniere_position := Vector2.ZERO

func nouvelle_salle(position: Vector2) -> void:
	_audace_disponible = true
	_rempart_disponible = true
	_distance_parcourue = 0.0
	_tir_givre_pret = false
	_derniere_position = position

func avancer_deplacement(position: Vector2, passifs: Dictionary) -> bool:
	var distance := _derniere_position.distance_to(position)
	_derniere_position = position
	if not passifs.has("sang_froid") or _tir_givre_pret:
		return false
	_distance_parcourue += distance
	if _distance_parcourue < Sorts.distance_sang_froid(passifs):
		return false
	_tir_givre_pret = true
	return true

func preparer_tir(tir: Tir, passifs: Dictionary) -> void:
	if not passifs.has("sang_froid") or not _tir_givre_pret:
		return
	_tir_givre_pret = false
	_distance_parcourue = 0.0
	tir.perforations += ReglagesPassifs.SANG_FROID_PERFORATIONS
	if not tir.effets.has("givre"):
		tir.effets.append("givre")

func recharge_audace(passifs: Dictionary, ratio_pv: float, recharge_active: float) -> bool:
	if not _audace_disponible or not passifs.has("audace") or recharge_active <= 0.0 \
			or ratio_pv >= Sorts.seuil_audace(passifs):
		return false
	_audace_disponible = false
	return true

func declencher_rempart(passifs: Dictionary, ratio_pv: float, heros: Node2D,
		salle: Node2D, limites: Rect2) -> bool:
	if not _rempart_disponible or not passifs.has("dernier_rempart") \
			or ratio_pv >= ReglagesPassifs.REMPART_SEUIL_PV:
		return false
	_rempart_disponible = false
	var rayon := Sorts.rayon_rempart(passifs)
	dissiper_projectiles(heros.get_tree(), heros.global_position, rayon)
	for ennemi: Node2D in heros.get_tree().get_nodes_in_group("ennemis"):
		if not is_instance_valid(ennemi) or ennemi.is_queued_for_deletion() \
				or heros.global_position.distance_to(ennemi.global_position) > rayon:
			continue
		var direction := heros.global_position.direction_to(ennemi.global_position)
		deplacer_ennemi(ennemi, ennemi.global_position + direction * ReglagesPassifs.REMPART_REPOUSSEE,
			salle, limites)
	return true

static func dissiper_projectiles(arbre: SceneTree, centre: Vector2, rayon := INF) -> void:
	for projectile: Node2D in arbre.get_nodes_in_group("tirs_ennemis"):
		if not is_instance_valid(projectile) or projectile.is_queued_for_deletion() \
				or (not is_inf(rayon) and centre.distance_to(projectile.global_position) > rayon):
			continue
		# Desactiver immediatement les impacts, meme si le projectile est deja
		# dans le balayage physique de cette image.
		projectile.set("_termine", true)
		projectile.set_physics_process(false)
		projectile.queue_free()

static func deplacer_ennemi(ennemi: Node2D, destination: Vector2, salle: Node2D,
		limites: Rect2) -> void:
	if not is_instance_valid(ennemi) or ennemi.is_queued_for_deletion():
		return
	var arrivee := Geometrie.contraindre_dans_rect(destination, limites, ReglagesPassifs.MARGE_DEPLACEMENT_ENNEMI)
	var obstacles: Array = salle.obstacles()
	if Geometrie.ligne_libre(ennemi.global_position, arrivee, obstacles, ReglagesPassifs.MARGE_DEPLACEMENT_ENNEMI):
		ennemi.global_position = arrivee
