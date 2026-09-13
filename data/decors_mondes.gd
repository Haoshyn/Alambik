class_name DecorsMondes
extends RefCounted

# Profils artistiques : aucune incidence sur les collisions ou la progression.
const PROFILS := [
	{"nom":"Cour des alchimistes", "sol":"dfd2ba", "joint":"b9aa8d", "mur":"eddbb8", "accent":"319f9d", "dehors":"7da89b", "detail":"6e9561", "motif":0, "forme":0},
	{"nom":"Fonderies de braise", "sol":"c58c66", "joint":"9a705a", "mur":"645663", "accent":"da995b", "dehors":"a77c76", "detail":"c77e44", "motif":1, "forme":1},
	{"nom":"Palais de givre", "sol":"c8e0e3", "joint":"9cbfc9", "mur":"a2c6db", "accent":"719ecd", "dehors":"88aaba", "detail":"b2dcdf", "motif":2, "forme":2},
	{"nom":"Terrasses des orages", "sol":"b7c3ce", "joint":"8b9cac", "mur":"8493ac", "accent":"cdb363", "dehors":"8398ae", "detail":"acbccb", "motif":3, "forme":3},
	{"nom":"Serres des venins", "sol":"bec8a4", "joint":"96a07f", "mur":"8d9f85", "accent":"8985b2", "dehors":"789485", "detail":"65975e", "motif":2, "forme":0},
	{"nom":"Galeries des echos", "sol":"d3c3d8", "joint":"ac9eb5", "mur":"b8a6cc", "accent":"d3af83", "dehors":"a79bb8", "detail":"9b91b3", "motif":3, "forme":3},
	{"nom":"Cloitre des ombres", "sol":"a5a3b9", "joint":"858297", "mur":"77758f", "accent":"8bb6c7", "dehors":"85869d", "detail":"77838f", "motif":0, "forme":1},
	{"nom":"Jardins des runes", "sol":"b8ccb3", "joint":"92ab91", "mur":"8db2a0", "accent":"56a99c", "dehors":"799d91", "detail":"688d64", "motif":4, "forme":4},
	{"nom":"Rives du neant", "sol":"c4adc7", "joint":"9d89a6", "mur":"9682a4", "accent":"b88dc2", "dehors":"93829f", "detail":"af99be", "motif":2, "forme":2},
	{"nom":"Le Grand Atelier", "sol":"ead3a0", "joint":"bca77d", "mur":"d7bb84", "accent":"369f9d", "dehors":"9ab6a5", "detail":"bc905c", "motif":3, "forme":0},
]

static func profil(monde: int) -> Dictionary:
	return PROFILS[clampi(monde,0,PROFILS.size()-1)]

static func couleur(monde: int, cle: String) -> Color:
	return Color(str(profil(monde)[cle]))
