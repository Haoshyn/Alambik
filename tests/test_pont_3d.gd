extends RefCounted

func test_projection_sans_decalage(v: Verif) -> void:
	var chemin := "res://scripts/presentation/pont_3d.gd"
	v.vrai(ResourceLoader.exists(chemin), "le pont 3D doit exister")
	if not ResourceLoader.exists(chemin):
		return
	var pont: GDScript = load(chemin)
	for inclinaison in [55.0, 65.0, 90.0]:
		for point in [Vector2.ZERO, Vector2(80, 300), Vector2(1000, 1700), Vector2(540, 960)]:
			var monde: Vector3 = pont.vers_monde(point, 0.0, inclinaison)
			var retour: Vector2 = pont.vers_logique(monde, inclinaison)
			v.presque(retour.distance_to(point), 0.0, "conversion reversible")
			v.presque(monde.x / 0.01, point.x, "projection horizontale")
			v.presque(monde.z * sin(deg_to_rad(inclinaison)) / 0.01, point.y, "projection verticale compensee")
