extends RefCounted

const Rendu := preload("res://data/presentation/animations_combat.gd")

static func creer(proxy: Node3D, corps: Node3D) -> void:
	var reduit := ReglagesJoueur.effets_reduits
	var plafond := Rendu.DISSIPATIONS_REDUITES if reduit else Rendu.DISSIPATIONS_MAX
	if proxy.get_tree().get_nodes_in_group("dissipations_ennemis").size() >= plafond: return
	var vestige := Node3D.new()
	proxy.get_parent().add_child(vestige)
	vestige.add_to_group("dissipations_ennemis")
	vestige.global_transform = proxy.global_transform
	# Detacher seulement le visuel : l'acteur et sa collision disparaissent tout de suite.
	corps.reparent(vestige, false)
	var duree := Rendu.DISSIPATION_CORPS_REDUITE if reduit else Rendu.DISSIPATION_CORPS_DUREE
	var mouvement := vestige.create_tween().set_parallel(true)
	mouvement.tween_property(corps, "scale", Vector3(.01, .01, .01), duree).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if not reduit:
		mouvement.tween_property(corps, "rotation:z", corps.rotation.z + .35, duree)
		mouvement.tween_property(corps, "position:y", -.09, duree)
	mouvement.chain().tween_callback(vestige.queue_free)
