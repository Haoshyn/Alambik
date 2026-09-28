class_name DecorsMondes
extends RefCounted

# Profils artistiques : aucune incidence sur les collisions ou la progression.
const CUIVRE := Color("c49b67")
const PAPIER := Color("eddfba")
const ENCRE := Color("393650")
const REFLET := Color("d8f3ed")
# Centre, demi-etendue, matiere. Chaque atelier a sa composition ; les
# contours sont ensuite deformes de facon reproductible par salle.
const COMPOSITIONS_SOL := [
	[[Vector2(.05,.27),Vector2(.41,.24),0],[Vector2(.90,.64),Vector2(.41,.28),1],[Vector2(.15,.91),Vector2(.30,.16),0]],
	[[Vector2(.18,.49),Vector2(.42,.34),0],[Vector2(.82,.20),Vector2(.37,.20),1],[Vector2(.75,.86),Vector2(.38,.20),1]],
	[[Vector2(.45,.16),Vector2(.52,.19),0],[Vector2(.90,.60),Vector2(.29,.33),1],[Vector2(.10,.85),Vector2(.32,.21),0]],
	[[Vector2(.13,.09),Vector2(.45,.26),0],[Vector2(.09,.66),Vector2(.39,.26),1],[Vector2(.95,.62),Vector2(.28,.34),0]],
	[[Vector2(.03,.47),Vector2(.36,.36),0],[Vector2(.84,.15),Vector2(.42,.22),1],[Vector2(.72,.91),Vector2(.42,.21),1]],
]
const PROFILS := [
	{
		"nom":"Scriptorium vivant", "sol":"b9b8d3", "joint":"9594b2", "mur":"676496", "accent":"9172c4", "dehors":"343c60", "detail":"647ca4", "liquide":"7151a0", "motif":0, "dalle":Vector2(2.35,2.1),
		"ilots":[
			{"nom":"Parquet d'atelier", "sol":"b7a08a", "joint":"928475", "grain":"a08c7b", "motif":5, "dalle":Vector2(.54,2.7), "angle":0.0},
			{"nom":"Mosaïque d'encre", "sol":"91a3bb", "joint":"7f92ac", "grain":"8191aa", "motif":2, "dalle":Vector2(.51,.51), "angle":0.0},
		],
	},
	{
		"nom":"Jardins de pierre", "sol":"d2c2a2", "joint":"b4a283", "mur":"a08760", "accent":"5a9072", "dehors":"43594e", "detail":"77ab70", "liquide":"94b65e", "motif":1, "dalle":Vector2(1.45,1.45),
		"ilots":[
			{"nom":"Terre battue et pas de pierre", "sol":"c5b294", "joint":"ad987b", "grain":"9c8d74", "motif":7, "dalle":Vector2(1.35,1.50), "angle":-.12},
			{"nom":"Pavés moussus", "sol":"b2b397", "joint":"8e9c7d", "grain":"7c8d70", "motif":8, "dalle":Vector2(1.20,1.0), "angle":.10},
		],
	},
	{
		"nom":"Sanctuaire des marées", "sol":"a9c9ce", "joint":"89afb7", "mur":"527e94", "accent":"409caa", "dehors":"25495e", "detail":"68bfae", "liquide":"55b9c9", "motif":2, "dalle":Vector2(2.4,2.4),
		"ilots":[
			{"nom":"Calcaire poli", "sol":"d2ccb3", "joint":"b9b49c", "grain":"b7b39f", "motif":6, "dalle":Vector2(1.80,1.50), "angle":.08},
			{"nom":"Petits émaux des marées", "sol":"81acb2", "joint":"73969f", "grain":"6e97a2", "motif":0, "dalle":Vector2(.72,.72), "angle":0.0},
		],
	},
	{
		"nom":"Terrasses des souffles", "sol":"ced3d5", "joint":"afb9c2", "mur":"849baa", "accent":"62a99d", "dehors":"667f9e", "detail":"d7e4ed", "liquide":"a4d9d6", "motif":3, "dalle":Vector2(1.65,3.5),
		"ilots":[
			{"nom":"Pierre blonde érodée", "sol":"c7c0ad", "joint":"b1aa99", "grain":"aba797", "motif":6, "dalle":Vector2(2.05,1.60), "angle":-.13},
			{"nom":"Ardoises du vent", "sol":"a5bbc4", "joint":"8fa7b3", "grain":"92a9b3", "motif":3, "dalle":Vector2(.82,2.10), "angle":PI*.5},
		],
	},
	{
		"nom":"Forge des braises", "sol":"83818c", "joint":"686774", "mur":"505568", "accent":"b98653", "dehors":"383645", "detail":"9c6754", "liquide":"e9a35b", "motif":4, "dalle":Vector2(2.35,2.35),
		"ilots":[
			{"nom":"Briques réfractaires", "sol":"b0937f", "joint":"8e7c71", "grain":"958070", "motif":0, "dalle":Vector2(1.30,.65), "angle":0.0},
			{"nom":"Plaques de forge", "sol":"939fa6", "joint":"737e88", "grain":"7d8991", "motif":4, "dalle":Vector2(1.80,2.40), "angle":0.0},
		],
	},
]

static func profil(monde: int) -> Dictionary:
	return PROFILS[clampi(monde,0,PROFILS.size()-1)]

static func couleur(monde: int, cle: String) -> Color:
	return Color(str(profil(monde)[cle]))

static func zones_sol(monde: int, variante: int) -> Array[Dictionary]:
	var resultat: Array[Dictionary] = []
	var alea := RandomNumberGenerator.new()
	alea.seed = monde * 104729 + variante * 7919 + 23
	for implantation: Array in COMPOSITIONS_SOL[clampi(monde,0,COMPOSITIONS_SOL.size()-1)]:
		var centre: Vector2 = implantation[0]
		centre += Vector2(alea.randf_range(-.035,.035),alea.randf_range(-.04,.04))
		var etendue: Vector2 = implantation[1] * alea.randf_range(.94,1.08)
		var phase := alea.randf_range(0,TAU)
		var lobes := alea.randi_range(2,4)
		var contour := PackedVector2Array()
		for i in 24:
			var angle := i * TAU / 24.0
			var rayon := .88 + .12 * sin(angle * lobes + phase) + .07 * cos(angle * 5 - phase)
			contour.append(centre + Vector2(cos(angle),sin(angle)) * etendue * rayon)
		resultat.append({"contour":contour,"matiere":int(implantation[2])})
	return resultat
