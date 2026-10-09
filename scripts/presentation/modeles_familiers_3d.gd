extends RefCounted

const SCENES := {
	"homoncule_encre": preload("res://assets/3d/familiers/homoncule_encre.glb"),
	"salamandre": preload("res://assets/3d/familiers/salamandre.glb"),
	"ondine": preload("res://assets/3d/familiers/ondine.glb"),
	"sylphe": preload("res://assets/3d/familiers/sylphe.glb"),
	"golem": preload("res://assets/3d/familiers/golem.glb"),
}

static var _matiere: StandardMaterial3D

# La peinture est portee par les sommets (COLOR_0, valeurs sRGB). La matiere
# importee l'ignorait et laissait les familiers blancs : une seule matiere
# partagee lit ces couleurs pour tous les pivots.
static func matiere() -> StandardMaterial3D:
	if _matiere == null:
		_matiere = StandardMaterial3D.new()
		_matiere.resource_name = "Familiers_Peinture"
		_matiere.vertex_color_use_as_albedo = true
		_matiere.vertex_color_is_srgb = true
		_matiere.roughness = 0.68
		_matiere.metallic_specular = 0.4
	return _matiere

# Les sculptures sont peintes et fusionnees dans Blender. Seuls leurs pivots
# anatomiques restent separes pour le deplacement et le recul de chaque tir.
static func construire(corps: Node3D, id: String) -> Array[Dictionary]:
	var scene: PackedScene = SCENES.get(id, SCENES["homoncule_encre"])
	var modele := scene.instantiate() as Node3D
	corps.add_child(modele)
	var membres: Array[Dictionary] = []
	for noeud: Node3D in modele.find_children("Art_*", "Node3D", true, false):
		var morceaux := String(noeud.name).split("_")
		if morceaux.size() < 3:
			continue
		noeud.set_meta("mobile_decor", true)
		membres.append({"noeud": noeud, "repos": noeud.transform,
			"role": morceaux[1], "cote": -1.0 if morceaux[2] == "G" else 1.0})
	for maillage: MeshInstance3D in modele.find_children("*", "MeshInstance3D", true, false):
		maillage.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		maillage.material_override = matiere()
	return membres

static func hauteur(id: String) -> float:
	return .22 if id == "sylphe" else 0.0

static func terrestre(id: String) -> bool:
	return id != "sylphe"
