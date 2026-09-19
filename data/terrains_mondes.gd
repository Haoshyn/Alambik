class_name TerrainsMondes
extends RefCounted

# Les petites zones restent laterales : le couloir central, l'entree et le
# portail demeurent libres, meme avec deux phenomenes. Le vent concerne
# toute la salle lorsqu'il est present, sans creer d'obstacle.
const EMPLACEMENTS := [Vector2(.16,.30), Vector2(.84,.61), Vector2(.17,.65), Vector2(.83,.34)]
const MURETS := [0, 1, 2, 3, 1, 0, 2]
const MARGE_OBSTACLE := 28.0
const DELAI_ACTIVATION := 1.5
const INTERVALLE_DEGATS := 1.2
const VENT_VARIATION_VITESSE := .25
const VENT_DIRECTIONS := [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
const SABLE_VITESSE_INITIALE := .95
const SABLE_VITESSE_MINIMALE := .40
const SABLE_DUREE_ENFONCEMENT := 4.0
const PROFILS := [
	{"type":"aucun", "rayon":0.0, "vitesse":1.0, "degats":0.0, "couleur":Color("6551a6")},
	{"type":"sable", "rayon":85.0, "vitesse":1.0, "degats":0.0, "couleur":Color("c9aa70")},
	{"type":"eau", "rayon":91.0, "vitesse":.85, "degats":0.0, "couleur":Color("389ec0")},
	{"type":"vent", "rayon":0.0, "vitesse":1.0, "degats":0.0, "couleur":Color("b6e9e2")},
	{"type":"lave", "rayon":82.0, "vitesse":1.0, "degats":.06, "couleur":Color("f38637")},
]
# Forme, composition, murets, nombre de zones : un parcours fixe de vingt
# etages. Le chapitre apporte une declinaison fixe, jamais la graine de run.
const ETAGES := [
	[0,0,0,0], [1,1,1,1], [2,2,2,0], [7,3,3,1], [3,0,4,0],
	[4,4,5,2], [5,5,6,0], [8,6,1,1], [6,7,2,1], [7,0,0,0],
	[1,8,3,0], [3,9,4,2], [8,3,5,1], [2,6,6,0], [4,0,1,0],
	[7,5,2,1], [5,7,0,2], [0,4,3,0], [6,8,4,1], [8,0,5,0],
]
const TYPES_OBSTACLES := ["muret", "pilier", "rocher", "caisses"]
const COMPOSITIONS := [
	[],
	[Rect2(.14,.36,.14,.045)],
	[Rect2(.73,.55,.09,.065), Rect2(.15,.29,.07,.05)],
	[Rect2(.15,.30,.10,.07), Rect2(.73,.62,.12,.045)],
	[Rect2(.15,.27,.075,.06), Rect2(.76,.42,.065,.05), Rect2(.18,.65,.09,.07)],
	[Rect2(.76,.30,.055,.15)],
	[Rect2(.14,.57,.15,.045), Rect2(.14,.615,.055,.09), Rect2(.76,.30,.07,.055)],
	[Rect2(.15,.28,.08,.06), Rect2(.76,.28,.08,.06), Rect2(.16,.64,.065,.05), Rect2(.77,.64,.065,.05)],
	[Rect2(.72,.39,.16,.055), Rect2(.825,.445,.055,.085)],
	[Rect2(.16,.34,.11,.09), Rect2(.73,.63,.12,.08), Rect2(.18,.65,.055,.04)],
]

static func plan(numero: int) -> Array:
	return ETAGES[clampi(numero - 1, 0, ETAGES.size() - 1)]

static func variante(numero: int, chapitre: int, _graine: int) -> int:
	return posmod(int(plan(numero)[2]) + chapitre, MURETS.size())

static func forme(numero: int, chapitre: int) -> int:
	return posmod(int(plan(numero)[0]) + chapitre, FormesSalles.PROFILS.size())

static func obstacles(numero: int, chapitre: int) -> Array[Dictionary]:
	var resultat: Array[Dictionary] = []
	var index_composition := int(plan(numero)[1])
	var composition: Array = COMPOSITIONS[index_composition]
	for i in composition.size():
		var rect: Rect2 = composition[i]
		# Le miroir garde les acces et la largeur centrale strictement identiques.
		if chapitre % 2 != 0: rect.position.x = 1.0 - rect.end.x
		var type := str(TYPES_OBSTACLES[posmod(numero + chapitre + i, TYPES_OBSTACLES.size())])
		# Les bras fins des formes en L restent des murs, avec la meme emprise
		# dans le dessin et dans Geometrie.
		if rect.size.x / rect.size.y > 2.0 or rect.size.y / rect.size.x > 2.0: type = "muret"
		if index_composition in [6, 8] and i < 2: type = "muret"
		resultat.append({"rect":rect, "type":type})
	return resultat

static func nombre(numero: int, chapitre: int, _graine: int, mode: String) -> int:
	if mode != "grimoire" or Chapitres.est_boss(chapitre, numero):
		return 0
	var monde := int(Chapitres.par_index(chapitre)["monde"])
	var type := str(PROFILS[monde]["type"])
	if type == "aucun": return 0
	var quantite := int(plan(numero)[3])
	return mini(1, quantite) if type == "vent" else quantite

static func muret_visible(variante_: int, segment: int) -> bool:
	match MURETS[posmod(variante_, MURETS.size())]:
		0: return false
		1: return segment % 3 == 0
		2: return segment % 4 < 2
		_: return segment % 5 != 0
