extends RefCounted

# Retours visuels portes par les modeles 3D : ombre de contact sous chaque
# acteur (les ombres projetees sont coupees sur Android) et eclair blanc au
# moment ou un ennemi encaisse un coup.

static var _matiere_ombre: StandardMaterial3D
static var _maillage_ombre: PlaneMesh
static var _matiere_eclat: StandardMaterial3D


static func ombre(parent: Node3D, rayon: float, opacite := 0.42) -> MeshInstance3D:
	if _matiere_ombre == null:
		var degrade := Gradient.new()
		degrade.set_color(0, Color(0.02, 0.0, 0.06, 1.0))
		degrade.set_color(1, Color(0.02, 0.0, 0.06, 0.0))
		degrade.add_point(0.55, Color(0.02, 0.0, 0.06, 0.55))
		var texture := GradientTexture2D.new()
		texture.gradient = degrade
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5, 0.5)
		texture.fill_to = Vector2(1.0, 0.5)
		texture.width = 64
		texture.height = 64
		_matiere_ombre = StandardMaterial3D.new()
		_matiere_ombre.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_matiere_ombre.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_matiere_ombre.albedo_texture = texture
		_matiere_ombre.vertex_color_use_as_albedo = false
		_matiere_ombre.cull_mode = BaseMaterial3D.CULL_DISABLED
		_matiere_ombre.render_priority = -1
		_maillage_ombre = PlaneMesh.new()
		_maillage_ombre.size = Vector2(2.0, 2.0)
	var instance := MeshInstance3D.new()
	instance.name = "OmbreContact"
	instance.mesh = _maillage_ombre
	var matiere := _matiere_ombre
	if not is_equal_approx(opacite, 0.42):
		matiere = _matiere_ombre.duplicate() as StandardMaterial3D
		matiere.albedo_color = Color(1, 1, 1, opacite / 0.42)
	instance.material_override = matiere
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.scale = Vector3(rayon, 1.0, rayon)
	instance.position.y = 0.012
	parent.add_child(instance)
	return instance


static func maillages(modele: Node) -> Array[MeshInstance3D]:
	var resultat: Array[MeshInstance3D] = []
	if modele == null:
		return resultat
	for noeud in modele.find_children("*", "MeshInstance3D", true, false):
		resultat.append(noeud as MeshInstance3D)
	return resultat


# Une matiere par ennemi : l'eclair ne doit pas allumer tout le bestiaire.
static func preparer_eclat() -> StandardMaterial3D:
	if _matiere_eclat == null:
		_matiere_eclat = StandardMaterial3D.new()
		_matiere_eclat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_matiere_eclat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_matiere_eclat.albedo_color = Color(1.0, 0.98, 0.94, 0.0)
		_matiere_eclat.no_depth_test = false
	return _matiere_eclat.duplicate() as StandardMaterial3D


static func appliquer_eclat(cibles: Array[MeshInstance3D], matiere: StandardMaterial3D, intensite: float) -> void:
	var actif := intensite > 0.01
	matiere.albedo_color.a = clampf(intensite, 0.0, 1.0) * 0.6
	for maillage in cibles:
		if is_instance_valid(maillage):
			maillage.material_overlay = matiere if actif else null
