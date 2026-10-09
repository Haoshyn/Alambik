extends RefCounted

# Un seul dessin pour tous les impacts ; salves proches et ticks de braise
# se regroupent par cible sans modifier leur montant ni prolonger leur vie.
# Les critiques jaillissent plus gros, en or, avec un eclat derriere eux.
const DUREE := 0.8
const DUREE_REDUITE := 0.55
const GROUPE_IMPACTS := 0.08
const GROUPE_CONTINU := 0.24
const GROUPE_REDUIT := 0.20
const MAX_NOMBRES := 36
const MAX_REDUITS := 16
const MAX_PAR_CIBLE := 3
const TAILLE := 40
const TAILLE_CRITIQUE := 58
const TAILLE_CONTINU := 30
const COULEURS := {
	"normal": [Color("fffaf0"), Color("2a1238")],
	"critique": [Color("ffd84a"), Color("7a1a08")],
	"continu": [Color("ffae5c"), Color("4a1a08")],
	"subi": [Color("ff6b74"), Color("3a0710")],
}

var _nombres: Array[Dictionary] = []
var _alternance := 0

func ajouter(cible: int, position: Vector2, montant: float, rayon: float, continu := false, reduit := false, critique := false, subi := false) -> void:
	if not is_finite(montant) or montant <= 0.0 or not position.is_finite(): return
	var fenetre := GROUPE_CONTINU if continu else (GROUPE_REDUIT if reduit else GROUPE_IMPACTS)
	for nombre in _nombres:
		if int(nombre["cible"]) == cible and (reduit or (bool(nombre["continu"]) == continu
				and bool(nombre["critique"]) == critique)) and float(nombre["age"]) < fenetre:
			nombre["montant"] = float(nombre["montant"]) + montant
			nombre["texte"] = formater(float(nombre["montant"]))
			nombre["continu"] = bool(nombre["continu"]) and continu
			nombre["critique"] = bool(nombre["critique"]) or critique
			return
	var compte := 0
	var ancien := -1
	for index in _nombres.size():
		if int(_nombres[index]["cible"]) != cible: continue
		compte += 1
		if ancien < 0: ancien = index
	if compte >= (1 if reduit else MAX_PAR_CIBLE): _nombres.remove_at(ancien)
	var plafond := MAX_REDUITS if reduit else MAX_NOMBRES
	while _nombres.size() >= plafond: _nombres.pop_front()
	_alternance += 1
	_nombres.append({"cible": cible, "position": position + Vector2.UP * (rayon * 1.6 + 18.0),
		"montant": montant, "texte": formater(montant), "age": 0.0,
		"duree": DUREE_REDUITE if reduit else DUREE, "continu": continu, "reduit": reduit,
		"critique": critique, "subi": subi, "sens": 1.0 if _alternance % 2 == 0 else -1.0})

func avancer(delta: float) -> void:
	var vivants: Array[Dictionary] = []
	for nombre in _nombres:
		nombre["age"] = float(nombre["age"]) + delta
		if float(nombre["age"]) < float(nombre["duree"]): vivants.append(nombre)
	_nombres = vivants

# Les nombres restent entiers : jusqu'a 9 999 ils sont complets, puis compacts.
static func formater(montant: float) -> String:
	if montant < 10000.0: return str(maxi(1, roundi(montant)))
	for palier: float in [1.0e9, 1.0e6, 1.0e3]:
		if montant < palier * 0.9995: continue
		var unite := "Md" if palier == 1.0e9 else ("M" if palier == 1.0e6 else "k")
		return str(roundi(montant / palier)) + unite
	return str(roundi(montant))

func dessiner(support: Node2D) -> void:
	for nombre in _nombres:
		var age := float(nombre["age"])
		var progression := age / float(nombre["duree"])
		var reduit := bool(nombre["reduit"])
		var critique := bool(nombre["critique"]) and not bool(nombre["continu"])
		var genre := "critique" if critique else ("continu" if bool(nombre["continu"]) else "normal")
		if bool(nombre.get("subi", false)):
			genre = "subi"
		var taille := TAILLE_CRITIQUE if critique else (TAILLE_CONTINU if genre == "continu" else TAILLE)
		var point: Vector2 = nombre["position"]
		# Saut initial puis montee freinee, avec une derive laterale alternee.
		point.y -= (14.0 if reduit else 70.0) * (1.0 - pow(1.0 - minf(1.0, progression * 1.4), 3.0))
		if not reduit: point.x += float(nombre["sens"]) * (10.0 + 22.0 * progression)
		var echelle := 1.0
		var inclinaison := 0.0
		if not reduit:
			var pop := clampf(age / 0.16, 0.0, 1.0)
			var depart := 2.1 if critique else 1.55
			echelle = lerpf(depart, 1.0, 1.0 - pow(1.0 - pop, 3.0)) + 0.08 * sin(pop * PI)
			if critique:
				inclinaison = float(nombre["sens"]) * -0.12 * (1.0 - pop)
		var opacite := 1.0 - smoothstep(0.62, 1.0, progression)
		var couleurs: Array = COULEURS[genre]
		var contenu := ("−" if genre == "subi" else "") + str(nombre["texte"])
		var police := Polices.CHIFFRES
		var largeur := police.get_string_size(contenu, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x
		var origine := Vector2(-largeur * 0.5, police.get_ascent(taille) * 0.35)
		support.draw_set_transform(point, inclinaison, Vector2.ONE * echelle)
		if critique and not reduit and progression < 0.45:
			var eclat := 1.0 - progression / 0.45
			DessinJeu.rayons(support, Vector2.ZERO, largeur * 0.95 + 26.0, Color(1.0, 0.86, 0.35, 0.55 * eclat), age * 2.4, 8)
		var contour: Color = couleurs[1]
		support.draw_string_outline(police, origine + Vector2(0, 4), contenu, HORIZONTAL_ALIGNMENT_LEFT, -1,
			taille, 12, Color(0.02, 0.01, 0.06, opacite * 0.45))
		support.draw_string_outline(police, origine, contenu, HORIZONTAL_ALIGNMENT_LEFT, -1,
			taille, 9 if critique else 8, Color(contour, opacite))
		support.draw_string(police, origine, contenu, HORIZONTAL_ALIGNMENT_LEFT, -1,
			taille, Color(couleurs[0], opacite))
	support.draw_set_transform(Vector2.ZERO)
