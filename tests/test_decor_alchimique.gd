extends RefCounted

func test_pierres_fermees_et_normales_exterieures(v: Verif) -> void:
	for taille: Vector3 in [Vector3(2,.8,1),Vector3(.13,.025,.13),Vector3(12,.32,.16)]:
		var mesh := preload("res://scripts/presentation/decor_alchimique.gd").pierre(taille)
		var donnees := mesh.surface_get_arrays(0)
		var points: PackedVector3Array = donnees[Mesh.ARRAY_VERTEX]
		var normales: PackedVector3Array = donnees[Mesh.ARRAY_NORMAL]
		for i in points.size():
			v.vrai(normales[i].dot(points[i]) > 0.0,"les faces eclairent l'exterieur de la pierre")
		v.vrai(mesh.get_aabb().size.is_equal_approx(taille),"les chanfreins preservent l'emprise physique")
