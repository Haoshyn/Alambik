class_name AnimationsDecors
extends RefCounted

const TAILLE_ACCUEIL := Vector2(948, 1659)
const PAYSAGE := preload("res://assets/visual/interface/clairiere_vivante/paysage.png")
const VEGETATION := preload("res://assets/visual/interface/clairiere_vivante/vegetation.png")
const EAU := preload("res://assets/visual/interface/clairiere_vivante/eau.png")
const ATMOSPHERE := preload("res://assets/visual/interface/clairiere_vivante/atmosphere.png")
const NUAGES := [
	{"case": Vector2(0, 0), "taille": Vector2(640, 245), "haut": 20.0, "vitesse": 12.0, "phase": 0.36, "opacite": 0.86},
	{"case": Vector2(1, 0), "taille": Vector2(730, 245), "haut": 155.0, "vitesse": 7.0, "phase": 0.81, "opacite": 0.80},
	{"case": Vector2(1, 0), "taille": Vector2(430, 155), "haut": 100.0, "vitesse": 16.0, "phase": 0.12, "opacite": 0.72},
	{"case": Vector2(0, 0), "taille": Vector2(440, 155), "haut": 275.0, "vitesse": 5.0, "phase": 0.55, "opacite": 0.65},
]

# Les zones UV designent les matieres peintes ; le shader y epargne la pierre.
const MONDES := [
	{
		"image": preload("res://assets/visual/interface/campagne_encre.png"),
		"accent": Color("75e9fa"),
		"chutes": [Vector4(0.275, 0.406, 0.32, 0.500), Vector4(0.255, 0.539, 0.295, 0.620), Vector4(0.785, 0.578, 0.84, 0.650), Vector4(0.60, 0.696, 0.65, 0.805), Vector4(0.455, 0.722, 0.50, 0.850), Vector4(0.355, 0.675, 0.395, 0.800)],
		"bassins": [Vector4(0.16, 0.350, 0.405, 0.414), Vector4(0.16, 0.478, 0.42, 0.548), Vector4(0.385, 0.531, 0.585, 0.591)],
		"feuillages": [Vector4(0.08, 0.025, 0.51, 0.276), Vector4(0.045, 0.280, 0.285, 0.373), Vector4(0.70, 0.160, 0.85, 0.257), Vector4(0.46, 0.431, 0.72, 0.50)],
		"tissus": [Vector4(0.48, 0.171, 0.556, 0.297)],
		"portail": Vector4(0.47, 0.175, 0.56, 0.31),
		"vapeurs": [{"depart": Vector2(0.35, 0.69), "taille": Vector2(0.48, 0.15), "derive": Vector2(0.06, -0.13), "case": Vector2(0, 1), "couleur": Color(0.61, 0.79, 1.0, 0.23), "duree": 14.0}],
	},
	{
		"image": preload("res://assets/visual/interface/campagne_terre.png"),
		"accent": Color("f9d988"),
		"chutes": [Vector4(0.46, 0.719, 0.61, 0.935), Vector4(0.73, 0.662, 0.806, 0.858)],
		"bassins": [Vector4(0.30, 0.350, 0.585, 0.416), Vector4(0.34, 0.44, 0.71, 0.586)],
		"feuillages": [Vector4(0.07, 0.24, 0.33, 0.406), Vector4(0.02, 0.47, 0.205, 0.613), Vector4(0.81, 0.35, 0.975, 0.462), Vector4(0.36, 0.08, 0.55, 0.24)],
		"tissus": [Vector4(0.734, 0.518, 0.808, 0.657)],
		"portail": Vector4(0.59, 0.12, 0.72, 0.23),
		"vapeurs": [{"depart": Vector2(0.44, 0.63), "taille": Vector2(0.54, 0.13), "derive": Vector2(0.22, -0.07), "case": Vector2(0, 1), "couleur": Color(1.0, 0.83, 0.50, 0.22), "duree": 10.0}],
	},
	{
		"image": preload("res://assets/visual/interface/campagne_eau.png"),
		"accent": Color("a0f5ff"),
		"chutes": [Vector4(0.392, 0.302, 0.459, 0.445), Vector4(0.185, 0.49, 0.245, 0.694), Vector4(0.46, 0.71, 0.588, 0.928), Vector4(0.82, 0.59, 0.895, 0.79), Vector4(0.88, 0.463, 0.942, 0.56)],
		"bassins": [Vector4(0.43, 0.271, 0.78, 0.35), Vector4(0.195, 0.447, 0.548, 0.548), Vector4(0.28, 0.545, 0.87, 0.661)],
		"feuillages": [Vector4(0.315, 0.15, 0.48, 0.251), Vector4(0.39, 0.48, 0.51, 0.60), Vector4(0.76, 0.39, 0.98, 0.52)],
		"tissus": [Vector4(0.453, 0.16, 0.488, 0.252), Vector4(0.762, 0.177, 0.835, 0.304)],
		"portail": Vector4(0.563, 0.132, 0.665, 0.257),
		"vapeurs": [{"depart": Vector2(0.52, 0.87), "taille": Vector2(0.60, 0.18), "derive": Vector2(0.08, -0.14), "case": Vector2(0, 1), "couleur": Color(0.79, 0.96, 1.0, 0.38), "duree": 9.0}],
	},
	{
		# Les noms historiques des deux derniers PNG sont inverses.
		"image": preload("res://assets/visual/interface/campagne_feu.png"),
		"accent": Color("d1f6ff"),
		"chutes": [Vector4(0.22, 0.389, 0.286, 0.51), Vector4(0.65, 0.455, 0.715, 0.58), Vector4(0.46, 0.668, 0.51, 0.803), Vector4(0.48, 0.85, 0.556, 0.98)],
		"bassins": [],
		"feuillages": [Vector4(0.19, 0.108, 0.44, 0.255), Vector4(0.06, 0.439, 0.246, 0.546), Vector4(0.65, 0.394, 0.76, 0.466), Vector4(0.845, 0.344, 0.98, 0.41)],
		"tissus": [Vector4(0.64, 0.312, 0.74, 0.413), Vector4(0.53, 0.51, 0.60, 0.606)],
		"portail": Vector4(0.575, 0.06, 0.67, 0.215),
		"vapeurs": [
			{"depart": Vector2(0.28, 0.64), "taille": Vector2(0.55, 0.22), "derive": Vector2(0.23, -0.03), "case": Vector2(0, 0), "couleur": Color(0.88, 0.94, 1.0, 0.63), "duree": 16.0},
			{"depart": Vector2(0.62, 0.83), "taille": Vector2(0.54, 0.21), "derive": Vector2(-0.17, -0.035), "case": Vector2(1, 0), "couleur": Color(0.89, 0.94, 1.0, 0.60), "duree": 19.0},
		],
	},
	{
		"image": preload("res://assets/visual/interface/campagne_air.png"),
		"accent": Color("ffbc51"),
		"chutes": [Vector4(0.555, 0.055, 0.65, 0.145), Vector4(0.505, 0.12, 0.577, 0.222), Vector4(0.62, 0.155, 0.69, 0.238), Vector4(0.59, 0.64, 0.68, 0.94), Vector4(0.909, 0.435, 0.98, 0.668), Vector4(0.305, 0.452, 0.369, 0.56)],
		"bassins": [Vector4(0.154, 0.27, 0.24, 0.314), Vector4(0.552, 0.23, 0.583, 0.40)],
		"feuillages": [Vector4(0.34, 0.326, 0.446, 0.387), Vector4(0.61, 0.435, 0.731, 0.493), Vector4(0.213, 0.555, 0.34, 0.63), Vector4(0.51, 0.657, 0.61, 0.744)],
		"tissus": [Vector4(0.42, 0.257, 0.471, 0.349), Vector4(0.665, 0.334, 0.712, 0.418)],
		"portail": Vector4(0.534, 0.231, 0.60, 0.401),
		"vapeurs": [
			{"depart": Vector2(0.392, 0.151), "taille": Vector2(0.21, 0.16), "derive": Vector2(-0.11, -0.12), "case": Vector2(1, 1), "couleur": Color(0.62, 0.52, 0.66, 0.60), "duree": 6.0},
			{"depart": Vector2(0.872, 0.209), "taille": Vector2(0.25, 0.19), "derive": Vector2(-0.09, -0.16), "case": Vector2(1, 1), "couleur": Color(0.62, 0.52, 0.66, 0.60), "duree": 7.0},
		],
	},
]
