extends RefCounted

const ReglagesPassifs := preload("res://data/passifs_combat.gd")

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
