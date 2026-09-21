extends Node3D

# Fiole vivante en email : les volumes arrondis reprennent le langage du mage.
# Les maillages sont construits une fois, sans texture ni lumiere supplementaire.
var _ailes: Array[Node3D] = []
var _corps: Node3D
var _perle: MeshInstance3D
var _taille_perle := Vector3.ZERO
var _temps := 0.0
var _sphere := SphereMesh.new()

func _ready() -> void:
	_sphere.radius = 1.0
	_sphere.height = 2.0
	_sphere.radial_segments = 16
	_sphere.rings = 8
	var saphir := _matiere(Color("285ba1"), 0.15, 0.3)
	var turquoise := _matiere(Color("52d8d1"), 0.12, 0.25)
	var or_chaud := _matiere(Color("e8b763"), 0.55, 0.32)
	var creme := _matiere(Color("fff0cb"), 0.05, 0.4)
	var encre := _matiere(Color("162849"), 0.0, 0.5)
	var lumiere := _matiere(Color("a8fff1"), 0.0, 0.25)
	lumiere.emission_enabled = true
	lumiere.emission = Color("64dace")
	lumiere.emission_energy_multiplier = 0.5
	_corps = Node3D.new()
	add_child(_corps)
	_boule(_corps, Vector3.ZERO, Vector3(0.23, 0.28, 0.19), saphir)
	_boule(_corps, Vector3(0.0, -0.065, 0.065), Vector3(0.185, 0.19, 0.16), turquoise)
	_bague(_corps, Vector3(0.0, -0.17, 0.0), 0.16, 0.018, or_chaud)
	_bague(_corps, Vector3(0.0, 0.2, 0.0), 0.13, 0.023, or_chaud)
	_boule(_corps, Vector3(0.0, 0.26, 0.0), Vector3(0.09, 0.095, 0.09), saphir)
	_bague(_corps, Vector3(0.0, 0.31, 0.0), 0.095, 0.021, or_chaud)
	_perle = _boule(_corps, Vector3(0.0, 0.37, 0.0), Vector3(0.055, 0.07, 0.055), lumiere)
	_taille_perle = _perle.scale
	# La face incline les yeux vers la camera orthographique plongeante.
	var visage := Node3D.new()
	visage.position = Vector3(0.0, 0.07, 0.13)
	visage.rotation.x = -0.45
	_corps.add_child(visage)
	for signe in [-1.0, 1.0]:
		_boule(visage, Vector3(signe * 0.083, 0.02, 0.0), Vector3(0.084, 0.087, 0.039), or_chaud)
		_boule(visage, Vector3(signe * 0.083, 0.024, 0.024), Vector3(0.066, 0.067, 0.025), creme)
		_boule(visage, Vector3(signe * 0.079, 0.028, 0.046), Vector3(0.027, 0.039, 0.014), encre)
		_boule(visage, Vector3(signe * 0.079 - 0.008, 0.044, 0.057), Vector3(0.009, 0.012, 0.006), lumiere)
	_boule(visage, Vector3(0.0, -0.037, 0.046), Vector3(0.031, 0.039, 0.032), or_chaud)
	var pendentif := _boule(_corps, Vector3(0.0, -0.24, 0.09), Vector3(0.048, 0.065, 0.035), or_chaud)
	pendentif.rotation.z = PI * 0.25
	for signe in [-1.0, 1.0]:
		var aile := Node3D.new()
		aile.position = Vector3(signe * 0.18, 0.06, -0.015)
		_corps.add_child(aile)
		_ailes.append(aile)
		var bordure := _boule(aile, Vector3(signe * 0.12, 0.015, 0.0), Vector3(0.2, 0.08, 0.075), or_chaud)
		bordure.rotation.z = signe * 0.45
		for i in 3:
			var plume := _boule(aile, Vector3(signe * (0.17 + float(i) * 0.055), 0.035 - float(i) * 0.055, 0.02),
				Vector3(0.17 - float(i) * 0.022, 0.048, 0.055), creme if i != 1 else turquoise)
			plume.rotation.z = signe * (0.55 + float(i) * 0.28)

func animer(delta: float, reduit: bool) -> void:
	_temps += delta
	var amplitude := 0.1 if reduit else 0.3
	for i in _ailes.size():
		var signe := -1.0 if i == 0 else 1.0
		_ailes[i].rotation.z = signe * (0.12 + sin(_temps * 8.0) * amplitude)
		_ailes[i].rotation.y = signe * cos(_temps * 8.0) * amplitude * 0.3
	_corps.rotation.z = sin(_temps * 2.5) * (0.015 if reduit else 0.055)
	_perle.scale = _taille_perle * (1.0 + sin(_temps * 3.0) * (0.025 if reduit else 0.08))

func _matiere(couleur: Color, metal: float, rugosite: float) -> StandardMaterial3D:
	var matiere := StandardMaterial3D.new()
	matiere.albedo_color = couleur
	matiere.metallic = metal
	matiere.roughness = rugosite
	return matiere

func _boule(parent: Node3D, emplacement: Vector3, taille: Vector3, matiere: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = _sphere
	instance.material_override = matiere
	instance.position = emplacement
	instance.scale = taille
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(instance)
	return instance

func _bague(parent: Node3D, emplacement: Vector3, rayon: float, epaisseur: float, matiere: Material) -> void:
	var anneau := TorusMesh.new()
	anneau.inner_radius = rayon - epaisseur
	anneau.outer_radius = rayon + epaisseur
	anneau.rings = 20
	anneau.ring_segments = 6
	var instance := MeshInstance3D.new()
	instance.mesh = anneau
	instance.material_override = matiere
	instance.position = emplacement
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(instance)
