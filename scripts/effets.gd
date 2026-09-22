extends Node2D

# Retours visuels ephemeres : impacts, eclats et textes. Un seul noeud
# les dessine tous, ce qui evite de creer et detruire des dizaines de scenes
# par seconde sur un telephone.

const GRAVITE := 220.0
const AnimationSorts = preload("res://scripts/presentation/animation_sorts.gd")
const CatalogueAnimations = preload("res://data/animations_sorts.gd")
const AnimationAugments = preload("res://scripts/presentation/animation_augments.gd")
const CatalogueAugments = preload("res://data/animations_augments.gd")
const AnimationImpacts = preload("res://scripts/presentation/animation_impacts.gd")
const RenduCombat = preload("res://data/animations_combat.gd")

var _particules: Array[Dictionary] = []
var _ondes: Array[Dictionary] = []
var _arcs: Array[Dictionary] = []
var _textes: Array[Dictionary] = []
var _sorts: Array[Dictionary] = []
var _segments_sorts: Array[Dictionary] = []
var _augments: Array[Dictionary] = []
var _impacts: Array[Dictionary] = []

func _process(delta: float) -> void:
	_segments_sorts.clear()
	var sorts_vivants: Array[Dictionary] = []
	for sort in _sorts:
		sort["age"] = float(sort["age"]) + delta
		if float(sort["age"]) < float(sort["duree"]):
			sorts_vivants.append(sort)
			_segments_sorts.append_array(AnimationSorts.segments(sort, ReglagesJoueur.effets_reduits))
	_sorts = sorts_vivants
	var augments_vivants: Array[Dictionary] = []
	for animation in _augments:
		animation["age"] = float(animation["age"]) + delta
		if float(animation["age"]) < float(animation["duree"]):
			augments_vivants.append(animation)
			_segments_sorts.append_array(AnimationAugments.segments(animation, ReglagesJoueur.effets_reduits))
	_augments = augments_vivants
	var impacts_vivants: Array[Dictionary] = []
	for effet in _impacts:
		effet["age"] = float(effet["age"]) + delta
		if float(effet["age"]) < float(effet["duree"]):
			impacts_vivants.append(effet)
			_segments_sorts.append_array(AnimationImpacts.segments(effet, ReglagesJoueur.effets_reduits))
	_impacts = impacts_vivants
	# On itere a rebours : la liste se vide pendant qu'on la parcourt.
	for i in range(_particules.size() - 1, -1, -1):
		var p := _particules[i]
		p["vie"] -= delta
		if p["vie"] <= 0.0:
			_particules.remove_at(i)
			continue
		p["vitesse"] = p["vitesse"] * (1.0 - 2.2 * delta) + Vector2(0, GRAVITE * delta * p["poids"])
		p["precedente"] = p["position"]
		p["position"] += p["vitesse"] * delta
	for liste in [_ondes, _arcs, _textes]:
		for i in range(liste.size() - 1, -1, -1):
			liste[i]["vie"] -= delta
			if liste[i]["vie"] <= 0.0:
				liste.remove_at(i)
	for t in _textes:
		t["position"] += Vector2(0, -60.0 * delta)
	queue_redraw()

func eclats(position: Vector2, couleur: Color, nombre := 8, force := 260.0, poids := 1.0) -> void:
	if ReglagesJoueur.effets_reduits:
		nombre = maxi(2, ceili(float(nombre) * 0.45))
	for i in nombre:
		var angle := randf() * TAU
		var vie := randf_range(0.25, 0.55)
		_particules.append({
			"position": position,
			"precedente": position,
			"vitesse": Vector2(cos(angle), sin(angle)) * force * randf_range(0.35, 1.0),
			"vie": vie,
			"vie_max": vie,
			"taille": randf_range(3.0, 7.0),
			"couleur": couleur,
			"poids": poids,
		})

func impact(position: Vector2, couleur: Color, ampleur := 1.0) -> void:
	eclats(position, couleur, int(4 * ampleur) + 2, 270.0 * ampleur, 0.45)
	_ajouter_percussion(position, couleur, ampleur, false)

func mort(position: Vector2, couleur: Color) -> void:
	eclats(position, couleur, 14, 390.0, 0.82)
	eclats(position, couleur.lightened(0.55), 6, 220.0, 0.18)
	_ajouter_percussion(position, couleur, 1.0, true)

func _ajouter_percussion(position: Vector2, couleur: Color, ampleur: float, mort: bool) -> void:
	var plafond := RenduCombat.IMPACTS_REDUITS if ReglagesJoueur.effets_reduits else RenduCombat.IMPACTS_MAX
	if _impacts.size() >= plafond: _impacts.pop_front()
	_impacts.append(AnimationImpacts.creer(position, couleur, ampleur, mort))

func apparition(position: Vector2, couleur: Color, rayon: float, majeure := false) -> void:
	var nombre := 18 if majeure else 9
	if ReglagesJoueur.effets_reduits:
		nombre = 7 if majeure else 4
	for index in nombre:
		var angle := TAU * float(index) / float(nombre) + randf_range(-0.08, 0.08)
		var direction := Vector2.RIGHT.rotated(angle)
		_particules.append({
			"position": position + direction * rayon * (2.0 if majeure else 1.55),
			"precedente": position + direction * rayon * (2.0 if majeure else 1.55),
			"vitesse": -direction * (185.0 if majeure else 120.0),
			"vie": 0.62 if majeure else 0.42,
			"vie_max": 0.62 if majeure else 0.42,
			"taille": randf_range(3.0, 8.0 if majeure else 6.0),
			"couleur": couleur.lightened(0.28),
			"poids": 0.0,
		})
	_ondes.append({"position": position, "vie": 0.65 if majeure else 0.38,
		"vie_max": 0.65 if majeure else 0.38, "rayon": rayon * (2.5 if majeure else 1.8),
		"couleur": couleur})

func onde(position: Vector2, rayon: float, couleur: Color, duree := 0.45) -> void:
	_ondes.append({"position": position, "vie": duree, "vie_max": duree, "rayon": rayon, "couleur": couleur})

func animer_augment(id: String, centre: Vector2, rayon: float, arrivee := Vector2.ZERO) -> void:
	var animation := AnimationAugments.creer(id, centre, rayon, arrivee)
	if animation.is_empty():
		return
	# Les procs ne doivent pas evincer une animation d'ultime.
	if _augments.size() >= CatalogueAugments.MAX_SIMULTANES:
		_augments.pop_front()
	_augments.append(animation)

func effacer_augments() -> void:
	_augments.clear()

func animer_sort(id: String, centre: Vector2, rayon: float) -> void:
	var animation := AnimationSorts.creer(id, centre,
		CatalogueAnimations.RAYON_ULTIME if is_inf(rayon) else rayon)
	if animation.is_empty():
		return
	if _sorts.size() >= CatalogueAnimations.MAX_SIMULTANES:
		_sorts.pop_front()
	_sorts.append(animation)
	var couleur: Color = animation["couleur"]
	eclats(centre, couleur, 16, 220.0, 0.0)

# Un arc bref entre deux points. La Chaîne alchimique doit se lire comme un
# maillon, pas comme deux impacts sans lien.
func arc(depart: Vector2, arrivee: Vector2, couleur: Color, duree := 0.22) -> void:
	_arcs.append({"depart": depart, "arrivee": arrivee, "vie": duree, "vie_max": duree,
		"couleur": couleur})

func texte(position: Vector2, contenu: String, couleur := Palette.TEXTE) -> void:
	_textes.append({"position": position, "contenu": contenu, "vie": 0.9, "vie_max": 0.9, "couleur": couleur})

func _draw() -> void:
	if has_meta("visuel_3d"):
		_dessiner_textes()
		return
	for segment in _segments_sorts:
		if segment.has("points"):
			var points: Array = segment["points"]
			var hauteurs: Array = segment["hauteurs"]
			var projetes := PackedVector2Array()
			for i in 3:
				projetes.append(_projeter_animation(points[i], float(hauteurs[i])))
			if absf((projetes[1] - projetes[0]).cross(projetes[2] - projetes[0])) > 0.01:
				draw_colored_polygon(projetes, segment["couleur"])
		else:
			var largeur := float(segment["largeur"])
			var couleur: Color = segment["couleur"]
			var debut := _projeter_animation(segment["depart"], float(segment["hauteur"]))
			var fin := _projeter_animation(segment["arrivee"], float(segment["hauteur_fin"]))
			draw_line(debut, fin, Color(couleur, couleur.a * 0.15), largeur * 2.6, true)
			draw_line(debut, fin, couleur, largeur, true)
	for o in _ondes:
		var t: float = 1.0 - o["vie"] / o["vie_max"]
		var c: Color = o["couleur"]
		c.a = (1.0 - t) * 0.7
		draw_arc(o["position"], o["rayon"] * (0.3 + t), 0.0, TAU, 24, c, 4.0 * (1.0 - t) + 1.0, true)
	for a in _arcs:
		var f: float = clampf(a["vie"] / a["vie_max"], 0.0, 1.0)
		var c: Color = a["couleur"]
		draw_line(Retro16.pixel(a["depart"]), Retro16.pixel(a["arrivee"]),
			Color(c.lightened(0.35), f * 0.85), 4.0 * f + 2.0, false)
	for p in _particules:
		var t: float = clampf(p["vie"] / p["vie_max"], 0.0, 1.0)
		var c: Color = p["couleur"]
		c.a = t
		var taille := maxf(4.0, roundf(p["taille"] * t / 4.0) * 4.0)
		var precedente: Vector2 = p.get("precedente", p["position"])
		var direction: Vector2 = precedente - p["position"]
		if direction.length_squared() > 4.0:
			var trainee := direction.normalized() * minf(24.0, direction.length() * 2.2)
			draw_line(Retro16.pixel(p["position"]), Retro16.pixel(p["position"] + trainee),
				Color(c, t * 0.45), taille, false)
		Dessin.halo(self, p["position"], taille * 3.2, Color(c, t * 0.38), 3)
		draw_rect(Rect2(Retro16.pixel(p["position"]) - Vector2.ONE * taille * 0.5,
			Vector2.ONE * taille), c)
	_dessiner_textes()

func _projeter_animation(point: Vector2, hauteur: float) -> Vector2:
	return point + Vector2.UP * hauteur * cos(deg_to_rad(Pont3D.INCLINAISON)) / Pont3D.ECHELLE

func _dessiner_textes() -> void:
	var police := ThemeDB.fallback_font
	for t in _textes:
		var f: float = t["vie"] / t["vie_max"]
		var c: Color = t["couleur"]
		c.a = f
		draw_string(police, t["position"], t["contenu"], HORIZONTAL_ALIGNMENT_CENTER, -1, 34, c)
