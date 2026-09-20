extends Node3D

var salle: Node2D
var _source: Node2D
var _visuels: Array[Node3D] = []

func _materiau(teinte: Color, lumineux := false) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = teinte
	mat.roughness = .55
	if teinte.a < 1.0: mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if lumineux:
		mat.emission_enabled = true
		mat.emission = teinte
		mat.emission_energy_multiplier = .45
	return mat

func _disque(parent: Node3D, rayon: float, teinte: Color, lumineux := false) -> void:
	var instance := MeshInstance3D.new()
	var forme := CylinderMesh.new()
	forme.top_radius = rayon
	forme.bottom_radius = rayon
	forme.height = .025
	forme.radial_segments = 24
	instance.mesh = forme
	instance.material_override = _materiau(teinte, lumineux)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(instance)

func _anneau(parent: Node3D, rayon: float, epaisseur: float, hauteur: float, teinte: Color) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var forme := TorusMesh.new()
	forme.inner_radius = maxf(.01, rayon - epaisseur)
	forme.outer_radius = rayon
	forme.rings = 24
	forme.ring_segments = 6
	instance.mesh = forme
	instance.position.y = hauteur
	instance.material_override = _materiau(teinte)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(instance)
	return instance

func _construire() -> void:
	for visuel in _visuels: visuel.queue_free()
	_visuels.clear()
	if _source == null: return
	for zone: Dictionary in _source.zones:
		var ensemble := Node3D.new()
		add_child(ensemble)
		# Le dessin couvre le meme disque que la logique, malgre la camera inclinee.
		ensemble.scale.z = 1.0 / sin(deg_to_rad(Pont3D.INCLINAISON))
		var rayon := float(zone["rayon"]) * Pont3D.ECHELLE
		var teinte: Color = zone["couleur"]
		var type := str(zone["type"])
		if type == "vent":
			_construire_vent(ensemble, zone)
		else:
			_disque(ensemble, rayon, teinte.darkened(.2), type == "lave")
			_anneau(ensemble, rayon, .035, .035, teinte.lightened(.15))
			for i in 5:
				var tache := Node3D.new()
				var angle := i * TAU / 5.0
				tache.position = Vector3(cos(angle) * rayon * .46, .026, sin(angle) * rayon * .46)
				ensemble.add_child(tache)
				_disque(tache, rayon * .27, teinte.lightened(.12 if i % 2 == 0 else -.05), type == "lave")
			if type in ["eau", "sable"]:
				var reflet := Color("a6e0e6") if type == "eau" else Color("b29360")
				for i in 3: _anneau(ensemble, rayon * (.28 + i * .21), .016, .06, reflet)
		_visuels.append(ensemble)

func _construire_vent(ensemble: Node3D, zone: Dictionary) -> void:
	var direction: Vector2 = zone["direction"]
	var teinte: Color = zone["couleur"]
	for i in 9:
		var trace_vent := Node3D.new()
		var origine := Vector3((.18 + (i % 3) * .32 - .5) * salle.limites.size.x * Pont3D.ECHELLE, .16,
			(.22 + (i / 3) * .27 - .5) * salle.limites.size.y * Pont3D.ECHELLE)
		trace_vent.position = origine
		trace_vent.rotation.y = -direction.angle()
		trace_vent.set_meta("origine", origine)
		ensemble.add_child(trace_vent)
		for morceau in 3:
			var barre := MeshInstance3D.new()
			var forme := BoxMesh.new()
			forme.size = Vector3(.46 if morceau == 0 else .16, .012, .018)
			barre.mesh = forme
			barre.material_override = _materiau(Color(teinte, .55))
			barre.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			if morceau > 0:
				var cote := -1.0 if morceau == 1 else 1.0
				barre.position = Vector3(.18, 0, cote * .05)
				barre.rotation.y = cote * .6
			trace_vent.add_child(barre)

func mettre_a_jour(_delta: float) -> void:
	if not is_instance_valid(salle): return
	var source: Node2D = salle.terrain_elementaire()
	if not is_instance_valid(_source) or source != _source:
		_source = source
		_construire()
	if _source == null: return
	for i in _visuels.size():
		var zone: Dictionary = _source.zones[i]
		var position_zone: Vector2 = zone["position"]
		var visuel := _visuels[i]
		visuel.position = Pont3D.vers_monde(position_zone, .04)
		if str(zone["type"]) == "vent":
			var direction: Vector2 = zone["direction"]
			var index := 0
			for trace_vent in visuel.get_children():
				var origine: Vector3 = trace_vent.get_meta("origine")
				var avance := 0.0 if ReglagesJoueur.effets_reduits else fposmod(float(_source.temps) * .38 + index * .17, .60) - .30
				trace_vent.position = origine + Vector3(direction.x, 0, direction.y) * avance
				index += 1
