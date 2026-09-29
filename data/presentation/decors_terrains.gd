class_name DecorsTerrains
extends RefCounted

# Les nappes partagent une peinture continue ; leur bord vient du vrai contour.
const PROFILS := {
	"encre": {"fond":"4b365f", "profond":"241d36", "clair":"71618a", "rive":"756184", "reflet":"ada2bb", "rugosite":.30, "speculaire":.38},
	"sable": {"fond":"c1a06a", "profond":"957145", "clair":"dfc495", "rive":"bda078", "reflet":"ebd4ac", "rugosite":.98, "speculaire":.08},
	"eau": {"fond":"438da2", "profond":"2b5e78", "clair":"7cbbc5", "rive":"9ebdc1", "reflet":"d2e5dc", "rugosite":.23, "speculaire":.43},
	"lave": {"fond":"b2502d", "profond":"68312a", "clair":"e18a39", "rive":"69504b", "reflet":"ffcc70", "rugosite":.67, "speculaire":.14},
}
const DOSSIER := "res://assets/visual/terrains/"
static var _matieres: Dictionary = {}

static func couleur(type: String, cle: String) -> Color:
	var profil: Dictionary = PROFILS[type]
	return Color(str(profil[cle]))

static func matiere(type: String, rive := false) -> StandardMaterial3D:
	var cle := type + ("_rive" if rive else "")
	if _matieres.has(cle): return _matieres[cle] as StandardMaterial3D
	var profil: Dictionary = PROFILS[type]
	var resultat := StandardMaterial3D.new()
	resultat.resource_name = "Nappe_" + cle
	resultat.roughness = float(profil["rugosite"])
	resultat.metallic_specular = float(profil["speculaire"])
	resultat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	resultat.texture_repeat = false
	if rive:
		resultat.albedo_color = couleur(type, "rive")
		resultat.roughness = .88
	else:
		resultat.albedo_texture = load(DOSSIER + type + ".png") as Texture2D
		resultat.normal_enabled = true
		resultat.normal_texture = load(DOSSIER + type + "_normale.png") as Texture2D
		resultat.normal_scale = .38 if type == "sable" else .65
		resultat.vertex_color_use_as_albedo = true
		resultat.vertex_color_is_srgb = true
		if type == "lave":
			resultat.emission_enabled = true
			resultat.emission = couleur(type, "clair")
			resultat.emission_energy_multiplier = .12
	_matieres[cle] = resultat
	return resultat
