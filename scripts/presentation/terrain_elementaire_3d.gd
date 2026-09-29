extends Node3D

const SOL := preload("res://scripts/presentation/sol_alchimique.gd")
const STATIQUE := preload("res://scripts/presentation/decor_statique.gd")
var salle: Node2D
var _source: Node2D
var _visuels: Array[Node3D] = []
var _matiere_vent: StandardMaterial3D
var _temps_surface := 0.0

func _construire() -> void:
	for visuel in _visuels:
		remove_child(visuel)
		visuel.queue_free()
	_visuels.clear()
	_matiere_vent = null
	_temps_surface = 0.0
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
	# La rive et les nuances restent dans la zone d'effet et sous les ombres.
	var contour := PackedVector2Array()
	for point: Vector2 in zone["contour"]:
		var p := Pont3D.vers_monde(point)
		contour.append(Vector2(p.x,p.z))
	var type := str(zone["type"])
	var rive := SOL.surface(parent, contour, -.005, Color.WHITE)
	rive.name = "RiveNappe"
	rive.material_override = DecorsTerrains.matiere(type, true)
	var cadre := Rect2(contour[0], Vector2.ZERO)
	for point in contour: cadre = cadre.expand(point)
	var maillage := SurfaceTool.new()
	maillage.begin(Mesh.PRIMITIVE_TRIANGLES)
	var anneaux := [0.0, .22, .50, .76, .92, .985]
	for bande in range(1, anneaux.size()):
		var debut: float = anneaux[bande - 1]
		var fin: float = anneaux[bande]
		for i in contour.size():
			var a := contour[i]
			var b := contour[(i + 1) % contour.size()]
			var triangles := [[Vector3(a.x * debut, debut, a.y * debut), Vector3(b.x * fin, fin, b.y * fin), Vector3(a.x * fin, fin, a.y * fin)]]
			if debut > 0.0:
				triangles.append([Vector3(a.x * debut, debut, a.y * debut), Vector3(b.x * debut, debut, b.y * debut), Vector3(b.x * fin, fin, b.y * fin)])
			for triangle: Array in triangles:
				var p: Vector3 = triangle[0]
				var q: Vector3 = triangle[1]
				var r: Vector3 = triangle[2]
				if Vector2(q.x - p.x, q.z - p.z).cross(Vector2(r.x - p.x, r.z - p.z)) < 0.0: triangle.reverse()
				for point: Vector3 in triangle:
					var menisque := smoothstep(.76, .985, point.y) * (.0 if type == "sable" else .24)
					var vers_rive := Vector2(point.x, point.z).normalized() * menisque
					maillage.set_normal(Vector3(-vers_rive.x, 1.0, -vers_rive.y).normalized())
					maillage.set_uv((Vector2(point.x, point.z) - cadre.position) / cadre.size)
					# Le centre plus profond rejoint progressivement une rive fine.
					var nuance := lerpf(.80, 1.0, smoothstep(.12, .96, point.y))
					maillage.set_color(Color(nuance, nuance, nuance))
					maillage.add_vertex(Vector3(point.x, -.002, point.z))
	maillage.generate_tangents()
	var fond := MeshInstance3D.new()
	fond.name = "SurfaceNappe"
	fond.mesh = maillage.commit()
	fond.material_override = DecorsTerrains.matiere(type)
	fond.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(fond)

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

func mettre_a_jour(delta: float) -> void:
	if not is_instance_valid(salle): return
	var source: Node2D = salle.terrain_elementaire()
	if not is_instance_valid(_source) or source != _source:
		_source = source
		_construire()
	if _source == null: return
	if not ReglagesJoueur.effets_reduits: _temps_surface += delta
	for i in _visuels.size():
		var zone: Dictionary = _source.zones[i]
		var position_zone: Vector2 = zone["position"]
		var visuel := _visuels[i]
		visuel.position = Pont3D.vers_monde(position_zone)
		var type := str(zone["type"])
		if type != "vent":
			if type in ["encre", "eau"]:
				var matiere := DecorsTerrains.matiere(type)
				matiere.uv1_offset = Vector3(sin(_temps_surface * .28) * .003, cos(_temps_surface * .23) * .003, 0)
			continue
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
