extends Node3D

var logique: EffetsPeriodiquesAugments
var _noyau: MeshInstance3D
var _anneau: MeshInstance3D
var _matiere: StandardMaterial3D

func _ready() -> void:
	_matiere = StandardMaterial3D.new()
	_matiere.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_matiere.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_matiere.albedo_color = Color("86e8d1")
	_anneau = MeshInstance3D.new()
	var tore := TorusMesh.new()
	var rayon := ReglagesAugments.METEORITE_RAYON * Pont3D.ECHELLE
	tore.inner_radius = rayon - 0.025
	tore.outer_radius = rayon
	tore.rings = 32
	tore.ring_segments = 4
	_anneau.mesh = tore
	_anneau.material_override = _matiere
	_anneau.scale.z = 1.0 / sin(deg_to_rad(Pont3D.INCLINAISON))
	_anneau.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_anneau)
	_noyau = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.20
	sphere.height = 0.40
	sphere.radial_segments = 8
	sphere.rings = 4
	_noyau.mesh = sphere
	var cuivre := _matiere.duplicate() as StandardMaterial3D
	cuivre.albedo_color = Color("f5dbaa")
	_noyau.material_override = cuivre
	_noyau.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_noyau)
	mettre_a_jour(0.0)

func mettre_a_jour(_delta: float) -> void:
	visible = is_instance_valid(logique) and logique.actif() \
		and (logique.chute_restante > 0.0 or logique.impact_restant > 0.0)
	if not visible: return
	position = Pont3D.vers_monde(logique.meteorite_position, 0.06)
	_noyau.visible = logique.chute_restante > 0.0
	if _noyau.visible:
		var restant := logique.chute_restante / ReglagesAugments.METEORITE_CHUTE
		_noyau.position.y = 0.20 + 3.0 * restant * restant
		_noyau.rotation = Vector3(0.0, 0.0, 0.2) if ReglagesJoueur.effets_reduits else Vector3(restant * 3.0, restant * 4.0, 0.2)
		_anneau.scale.x = 1.0
		_anneau.scale.z = 1.0 / sin(deg_to_rad(Pont3D.INCLINAISON))
		_matiere.albedo_color = Color("86e8d199")
	else:
		var progression := 1.0 - logique.impact_restant / ReglagesAugments.METEORITE_IMPACT_VISUEL
		var ampleur := 1.0 if ReglagesJoueur.effets_reduits else 1.0 + progression * 0.15
		_anneau.scale.x = ampleur
		_anneau.scale.z = ampleur / sin(deg_to_rad(Pont3D.INCLINAISON))
		_matiere.albedo_color = Color(Color("86e8d1"), 1.0 - progression)
