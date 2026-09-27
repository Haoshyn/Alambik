extends RefCounted

# Un seul dessin pour tous les impacts ; salves proches et ticks de braise
# se regroupent par cible sans modifier leur montant ni prolonger leur vie.
const DUREE := 0.65
const DUREE_REDUITE := 0.55
const GROUPE_IMPACTS := 0.08
const GROUPE_CONTINU := 0.24
const GROUPE_REDUIT := 0.20
const MAX_NOMBRES := 36
const MAX_REDUITS := 16
const MAX_PAR_CIBLE := 3
const TAILLE := 32

var _nombres: Array[Dictionary] = []
var _alternance := 0

func ajouter(cible: int, position: Vector2, montant: float, rayon: float, continu := false, reduit := false) -> void:
	if not is_finite(montant) or montant <= 0.0 or not position.is_finite(): return
	var fenetre := GROUPE_CONTINU if continu else (GROUPE_REDUIT if reduit else GROUPE_IMPACTS)
	for nombre in _nombres:
		if int(nombre["cible"]) == cible and (reduit or bool(nombre["continu"]) == continu) and float(nombre["age"]) < fenetre:
			nombre["montant"] = float(nombre["montant"]) + montant
			nombre["texte"] = formater(float(nombre["montant"]))
			nombre["continu"] = bool(nombre["continu"]) and continu
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
		"sens": 1.0 if _alternance % 2 == 0 else -1.0})

func avancer(delta: float) -> void:
	var vivants: Array[Dictionary] = []
	for nombre in _nombres:
		nombre["age"] = float(nombre["age"]) + delta
		if float(nombre["age"]) < float(nombre["duree"]): vivants.append(nombre)
	_nombres = vivants

static func formater(montant: float) -> String:
	if montant < 1.0: return ("%.1f" % maxf(0.1, montant)).replace(".", ",")
	var unite := ""
	var valeur := montant
	for palier: float in [1.0e9, 1.0e6, 1.0e3]:
		if montant < palier: continue
		valeur = montant / palier
		unite = "Md" if palier == 1.0e9 else ("M" if palier == 1.0e6 else "k")
		break
	if unite.is_empty(): return str(roundi(valeur))
	var texte := "%.1f" % valeur if valeur < 100.0 else str(roundi(valeur))
	return texte.trim_suffix(".0").replace(".", ",") + unite

func dessiner(support: Node2D) -> void:
	for nombre in _nombres:
		var age := float(nombre["age"])
		var progression := age / float(nombre["duree"])
		var reduit := bool(nombre["reduit"])
		var point: Vector2 = nombre["position"]
		point.y -= (12.0 if reduit else 42.0) * (1.0 - pow(1.0 - progression, 2.0))
		if not reduit: point.x += float(nombre["sens"]) * (8.0 + 12.0 * progression)
		var echelle := 1.0 if reduit else 1.0 + 0.18 * sin(PI * clampf(age / 0.14, 0.0, 1.0))
		var opacite := 1.0 - smoothstep(0.5, 1.0, progression)
		var couleur := Palette.OR if bool(nombre["continu"]) else Palette.TEXTE
		var contenu := str(nombre["texte"])
		var largeur := Polices.CHIFFRES.get_string_size(contenu, HORIZONTAL_ALIGNMENT_LEFT, -1, TAILLE).x
		var origine := Vector2(-largeur * 0.5, 0.0)
		support.draw_set_transform(point, 0.0, Vector2.ONE * echelle)
		support.draw_string_outline(Polices.CHIFFRES, origine, contenu, HORIZONTAL_ALIGNMENT_LEFT, -1,
			TAILLE, 4, Color(Palette.FOND, opacite * 0.9))
		support.draw_string(Polices.CHIFFRES, origine, contenu, HORIZONTAL_ALIGNMENT_LEFT, -1,
			TAILLE, Color(couleur, opacite))
	support.draw_set_transform(Vector2.ZERO)
