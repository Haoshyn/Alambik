extends RefCounted

# Le corps reste dangereux quel que soit le cerveau ou la cible visee.
static func frapper_sur_segment(attaquant: CharacterBody2D, avant: Vector2,
		degats: float, marge := 0.0) -> bool:
	var collision := attaquant.get_node("CollisionShape2D") as CollisionShape2D
	var rayon := (collision.shape as CircleShape2D).radius
	for corps: Node in attaquant.get_tree().get_nodes_in_group("cibles_ennemis"):
		var cible := corps as Node2D
		if cible == null or not cible.visible or cible.is_queued_for_deletion(): continue
		var forme := cible.get_node_or_null("CollisionShape2D") as CollisionShape2D
		var rayon_cible := Reglages.HEROS_RAYON
		if forme != null and forme.shape is CircleShape2D:
			rayon_cible = (forme.shape as CircleShape2D).radius
		var proche := Geometry2D.get_closest_point_to_segment(cible.global_position, avant, attaquant.global_position)
		if proche.distance_squared_to(cible.global_position) > pow(rayon + rayon_cible + marge, 2): continue
		if not Geometrie.ligne_libre(proche, cible.global_position,
				attaquant.get_parent().obstacles(), 0.0, attaquant.get_parent().contour_sol()): continue
		cible.recevoir_degats(degats)
		return true
	return false
