extends Node3D

var logique: SatellitesAlchimiques
var _cercles: Array[Node3D] = []

func _ready() -> void:
	for index in ReglagesAugments.SATELLITES_NOMBRE:
		var cercle := Node3D.new()
		cercle.name = "CercleEmail_%d" % index
		add_child(cercle)
		_cercles.append(cercle)
		var email := StandardMaterial3D.new()
		email.albedo_color = Color("86e8d1")
		email.emission_enabled = true
		email.emission = Color("478d83")
		email.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var anneau := MeshInstance3D.new()
		var tore := TorusMesh.new()
		tore.inner_radius = 0.11
		tore.outer_radius = 0.20
		tore.rings = 16
		tore.ring_segments = 8
		anneau.mesh = tore
		anneau.material_override = email
		anneau.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		cercle.add_child(anneau)
		var coeur := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.055
		sphere.height = 0.11
		sphere.radial_segments = 12
		sphere.rings = 6
		coeur.mesh = sphere
		var cuivre := email.duplicate() as StandardMaterial3D
		cuivre.albedo_color = Color("f5dbaa")
		coeur.material_override = cuivre
		coeur.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		cercle.add_child(coeur)
	mettre_a_jour(0.0)

func mettre_a_jour(_delta: float) -> void:
	visible = is_instance_valid(logique) and logique.actif()
	if not visible: return
	var points := logique.positions_satellites()
	for index in _cercles.size():
		_cercles[index].position = Pont3D.vers_monde(points[index], 0.32)
