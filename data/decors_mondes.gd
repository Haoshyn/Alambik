class_name DecorsMondes
extends RefCounted

# Profils artistiques : aucune incidence sur les collisions ou la progression.
const PROFILS := [
	{"nom":"Scriptorium vivant", "sol":"ddd0e6", "joint":"b8a8c9", "mur":"9990b7", "accent":"c7a86a", "dehors":"6b6897", "detail":"aca0c8", "motif":0, "forme":5},
	{"nom":"Jardins de pierre", "sol":"dcc399", "joint":"b49b76", "mur":"bfa477", "accent":"b4bd78", "dehors":"819576", "detail":"649157", "motif":0, "forme":4},
	{"nom":"Sanctuaire des marées", "sol":"c3dce4", "joint":"9dbfcf", "mur":"91b8c7", "accent":"4dbac4", "dehors":"377e98", "detail":"70a798", "motif":0, "forme":0},
	{"nom":"Terrasses des souffles", "sol":"e7dcc4", "joint":"c9bd9e", "mur":"ede1c4", "accent":"79c9b7", "dehors":"93bad2", "detail":"8ca98a", "motif":0, "forme":3},
	{"nom":"Forge des braises", "sol":"80717c", "joint":"635664", "mur":"665366", "accent":"cb9259", "dehors":"ad643e", "detail":"c88b48", "motif":1, "forme":1},
]

static func profil(monde: int) -> Dictionary:
	return PROFILS[clampi(monde,0,PROFILS.size()-1)]

static func couleur(monde: int, cle: String) -> Color:
	return Color(str(profil(monde)[cle]))
