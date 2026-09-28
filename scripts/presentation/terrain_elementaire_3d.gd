extends Node3D

const SOL := preload("res://scripts/presentation/sol_alchimique.gd")
const STATIQUE := preload("res://scripts/presentation/decor_statique.gd")
var salle: Node2D
var _source: Node2D
var _visuels: Array[Node3D] = []
var _matiere_vent: StandardMaterial3D

func _construire() -> void:
	for visuel in _visuels:
		remove_child(visuel)
		visuel.queue_free()
	_visuels.clear()
	_matiere_vent = null
	if _source == null: return
	for zone: Dictionary in _source.zones:
		var ensemble := Node3D.new()
		add_child(ensemble)
		if str(zone["type"]) == "vent":
			_construire_vent(ensemble, zone)
		else:
			_construire_flaque(ensemble, zone)
			STATIQUE.regrouper(ensemble)
		_visuels.append(ensemble)

func _construire_flaque(parent: Node3D, zone: Dictionary) -> void:
	# La silhouette vient de la collision logique, sans disque plus large ni
	# halo trompeur. Le relief reste sous les ombres au pied des personnages.
	var contour := PackedVector2Array()
	for point: Vector2 in zone["contour"]:
		var p := Pont3D.vers_monde(point)
		contour.append(Vector2(p.x,p.z))
	var teinte: Color = zone["couleur"]
	var type := str(zone["type"])
	SOL.surface(parent, contour, -.003, teinte.darkened(.45 if type == "lave" else .30))
	var interieur := PackedVector2Array()
	for point in contour: interieur.append(point * .94)
	var fond := SOL.surface(parent, interieur, -.0015, teinte)
	var mat := fond.material_override as StandardMaterial3D
	mat.roughness = .95 if type == "sable" else .34
	if type == "lave":
		mat.emission_enabled = true
		mat.emission = teinte
		mat.emission_energy_multiplier = .18
	var rayon := float(zone["rayon"]) * Pont3D.ECHELLE
	if type == "lave":
		for i in 3:
			var lignes := PackedVector2Array()
			for j in 7:
				lignes.append(Vector2(-.70 + j * .23,(i-1)*.35 + sin(j*1.4+i)*.11) * rayon)
			SOL._ruban(parent, lignes, .045, interieur, 0, Color("ffc96e"))
	else:
		var reflet := teinte.lightened(.40) if type != "sable" else teinte.darkened(.16)
		for i in 3:
			var lignes := PackedVector2Array()
			for j in 14:
				var angle := j * .14 + i * 1.8
				lignes.append(Vector2(cos(angle),sin(angle) / sin(deg_to_rad(Pont3D.INCLINAISON))) * rayon * (.26 + i * .19))
			SOL._ruban(parent, lignes, .015 if type == "sable" else .026, interieur, 0, reflet)

func _construire_vent(ensemble: Node3D, zone: Dictionary) -> void:
	_matiere_vent = StandardMaterial3D.new()
	_matiere_vent.albedo_color = zone["couleur"]
	_matiere_vent.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_matiere_vent.roughness = .7
	for i in 9:
		var trace_vent := Node3D.new()
		var relatif := Vector2(.18 + (i % 3) * .32 - .5, .22 + floori(i / 3.0) * .27 - .5)
		var origine := Pont3D.vers_monde(relatif * salle.limites.size, .002)
		trace_vent.position = origine
		trace_vent.set_meta("origine", origine)
		ensemble.add_child(trace_vent)
		var forme := PackedVector2Array([Vector2(-.40,-.023),Vector2(.13,-.023),Vector2(.04,-.14),Vector2(.32,0),Vector2(.04,.14),Vector2(.13,.023),Vector2(-.40,.023)])
		var objet := SOL.surface(trace_vent, forme, 0, Color.WHITE)
		objet.material_override = _matiere_vent

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
		visuel.position = Pont3D.vers_monde(position_zone)
		if str(zone["type"]) != "vent": continue
		var vent: Dictionary = _source.etat_vent()
		var force := float(vent["force"])
		visuel.visible = force > 0.0 or bool(vent["annonce"])
		var teinte: Color = zone["couleur"]
		teinte.a = .25 if bool(vent["annonce"]) else lerpf(.25,.75,force)
		_matiere_vent.albedo_color = teinte
		var direction: Vector2 = vent["direction"]
		var direction_monde := Pont3D.vers_monde(direction).normalized()
		var index := 0
		for trace_vent: Node3D in visuel.get_children():
			var origine: Vector3 = trace_vent.get_meta("origine")
			var avance := 0.0 if ReglagesJoueur.effets_reduits or bool(vent["annonce"]) else fposmod(float(_source.temps) * .65 + index * .17, 1.0) - .5
			trace_vent.position = origine + direction_monde * avance
			trace_vent.rotation.y = -atan2(direction_monde.z,direction_monde.x)
			index += 1
