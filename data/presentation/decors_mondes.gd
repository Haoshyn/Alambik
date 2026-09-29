class_name DecorsMondes
extends RefCounted

# Profils artistiques : aucune incidence sur les collisions ou la progression.
const CUIVRE := Color("c49b67")
const PAPIER := Color("eddfba")
const ENCRE := Color("393650")
const REFLET := Color("d8f3ed")
const TEXTURE_ENDUIT := "res://assets/visual/sols/enduit_cire.png"
const PROFILS := [
	{
		"nom":"Scriptorium vivant", "sol":"b9b8d3", "joint":"9594b2", "mur":"8c85a4", "accent":"76639e", "dehors":"343c60", "detail":"647ca4", "liquide":"7151a0",
		"texture":TEXTURE_ENDUIT, "enduit":"b7a4d8", "reprise":"d6bbdc", "patine":"8266ad", "rugosite_sol":.86,
		"parure":["7852ac", "b18ddb", "efd69b", "78c9be"],
	},
	{
		"nom":"Distillerie vegetale", "sol":"d2c2a2", "joint":"b4a283", "mur":"a89575", "accent":"698765", "dehors":"43594e", "detail":"77ab70", "liquide":"94b65e",
		"texture":TEXTURE_ENDUIT, "enduit":"c5cf94", "reprise":"e5d5a0", "patine":"85a173", "rugosite_sol":.92,
		"parure":["508466", "96bc7e", "f2d78b", "b5d6a1"],
	},
	{
		"nom":"Sanctuaire des marees", "sol":"a9c9ce", "joint":"89afb7", "mur":"7e9fae", "accent":"518fa0", "dehors":"25495e", "detail":"68bfae", "liquide":"55b9c9",
		"texture":TEXTURE_ENDUIT, "enduit":"8fcbd6", "reprise":"bbdccf", "patine":"5c9daf", "rugosite_sol":.82,
		"parure":["367fac", "81c9dd", "eedca4", "9de1ce"],
	},
	{
		"nom":"Terrasses des souffles", "sol":"ced3d5", "joint":"afb9c2", "mur":"9fadb9", "accent":"7e99ae", "dehors":"667f9e", "detail":"d7e4ed", "liquide":"a4d9d6",
		"texture":TEXTURE_ENDUIT, "enduit":"b9d3df", "reprise":"e5deb7", "patine":"83adca", "rugosite_sol":.87,
		"parure":["557fae", "a5c9e2", "f1dfac", "89d0c1"],
	},
	{
		"nom":"Forge des braises", "sol":"97939b", "joint":"77717d", "mur":"827982", "accent":"aa795c", "dehors":"383645", "detail":"9c6754", "liquide":"e9a35b",
		"texture":TEXTURE_ENDUIT, "enduit":"b99eaf", "reprise":"d7b189", "patine":"866689", "rugosite_sol":.90,
		"parure":["805878", "b38aa6", "eabd64", "8ebeb7"],
	},
]
static var _matieres_sol: Dictionary = {}

static func profil(monde: int) -> Dictionary:
	return PROFILS[clampi(monde, 0, PROFILS.size() - 1)]

static func couleur(monde: int, cle: String) -> Color:
	return Color(str(profil(monde)[cle]))

static func composition_sol(monde: int, etage: int, variante: int) -> Dictionary:
	var hasard := RandomNumberGenerator.new()
	hasard.seed = monde * 104729 + etage * 7919 + variante * 101 + 41
	var marge_x := hasard.randf_range(.06, .14)
	var marge_y := hasard.randf_range(.06, .14)
	var fenetre := Rect2(Vector2(marge_x, marge_y), Vector2(1.0 - marge_x * 2.0, 1.0 - marge_y * 2.0))
	var ambiance := posmod(etage + monde, 3)
	var zones: Array[Dictionary] = []
	var nombre := hasard.randi_range(4, 6)
	var premier_cote := hasard.randi_range(0, 1)
	for i in nombre:
		# Les reprises forment de grandes plages asymetriques, avec un axe central calme.
		var position := Vector2(hasard.randf_range(.10, .30), (i + .6) / (nombre + .2) + hasard.randf_range(-.035, .035))
		if posmod(i + premier_cote, 2) == 1: position.x = 1.0 - position.x
		var reprise := posmod(i + ambiance, 3) == 0
		var rayon := Vector2(hasard.randf_range(.16, .29), hasard.randf_range(.10, .19))
		if ambiance == 1: rayon *= Vector2(.8, 1.35)
		zones.append({"position":position, "rayon":rayon, "angle":hasard.randf_range(-.65, .65),
			"teinte":couleur(monde, "reprise" if reprise else "patine"),
			"force":hasard.randf_range(.65, .88) if reprise else hasard.randf_range(.38, .62),
			"phase":hasard.randf_range(0.0, TAU), "torsion":hasard.randf_range(-.22, .22)})
	return {
		"fenetre_uv":fenetre,
		"angle_matiere":hasard.randf_range(-PI, PI),
		"miroir_x":hasard.randi_range(0, 1) == 1,
		"miroir_y":hasard.randi_range(0, 1) == 1,
		"teinte":couleur(monde, "enduit"),
		"phase":hasard.randf_range(0.0, TAU),
		"usure":hasard.randf_range(.015, .035),
		"axe_poli":hasard.randf_range(.44, .56),
		"zones":zones,
		"decalage_frise":hasard.randf_range(.18, .82),
	}

static func composition_rives(monde: int, etage: int, variante: int) -> Array[Dictionary]:
	var hasard := RandomNumberGenerator.new()
	hasard.seed = monde * 104729 + etage * 7919 + variante * 101 + 65578
	var decors: Array[Dictionary] = []
	for cote in 2:
		var nombre := hasard.randi_range(2, 3)
		for rang in nombre:
			decors.append({"cote":cote,
				"hauteur":lerpf(.15, .79, float(rang) / (nombre - 1)) + hasard.randf_range(-.035, .035),
				"angle":hasard.randf_range(-.22, .22), "echelle":hasard.randf_range(.88, 1.08),
				"famille":posmod(rang + cote + etage, 4)})
	return decors

static func matiere_sol(monde: int) -> StandardMaterial3D:
	var indice := clampi(monde, 0, PROFILS.size() - 1)
	if _matieres_sol.has(indice):
		return _matieres_sol[indice] as StandardMaterial3D
	var matiere := StandardMaterial3D.new()
	matiere.resource_name = "Enduit_" + str(indice)
	matiere.albedo_texture = load(str(profil(indice)["texture"])) as Texture2D
	matiere.vertex_color_use_as_albedo = true
	matiere.vertex_color_is_srgb = true
	matiere.roughness = float(profil(indice)["rugosite_sol"])
	matiere.metallic_specular = .22
	matiere.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	# Une peinture couvre toute la salle : ni repetition ni joint sous les acteurs.
	matiere.texture_repeat = false
	_matieres_sol[indice] = matiere
	return matiere
