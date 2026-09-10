extends Node

# Le bot passe par definir_intention(), comme le joystick. Piloter
# des entrees simulees a deja fait rapporter des succes faux ailleurs :
# Input.action_press() appele chaque frame re-declenche is_action_just_pressed().
#
# Il ne joue pas bien : il fuit ce qui approche et s'arrete quand la voie est
# libre, parce que le tir automatique demande l'immobilite. Son travail est de
# traverser une run sans intervention pour qu'un blocage se voie. Un bot trop
# faible mesurerait la difficulte du bot au lieu de celle du jeu.

const DISTANCE_CONFORT := 460.0
# Un rayon trop large rendait le bot perpetuellement 'sous le feu' face a deux
# sentinelles : il fuyait sans jamais s'arreter, donc sans jamais tirer.
const DANGER_TIR := 150.0
const NAVIGATION := preload("res://sondes/navigation_bot.gd")
const MARGE_TIR := 18.0   # rayon du projectile, plus de quoi ne pas raser le bloc

var bavard := false

var _heros: CharacterBody2D
var _rapport := 0.0
var _cycle := 0.0
var _arret := false
var _derniere_position := Vector2.ZERO
var _coince := 0.0
var _sens_contournement := 1.0
var _cible_observee := 0
var _pv_observes := 0.0
var _sans_impact := 0.0
var _chemin := PackedVector2Array()
var _destination := Vector2.ZERO
var _salle_chemin := -1

# Le bot decide dans la phase physique : les requetes de rayon lancees depuis
# _process renvoyaient des resultats vides, et le bot croyait sa ligne de tir
# libre alors qu'un bloc l'arretait a 200 px.
func _physics_process(delta: float) -> void:
	if _heros == null or not is_instance_valid(_heros):
		_heros = get_tree().get_first_node_in_group("heros")
		return
	if bavard:
		_rapport -= delta
		if _rapport <= 0.0:
			_rapport = 2.0
			print("  [bot] salle=%d ennemis=%d pv=%d pos=%s" % [
				Jeu.salle_courante, get_tree().get_nodes_in_group("ennemis").size(),
				roundi(_heros.stats.pv), str(_heros.global_position.round())])

	_surveiller_le_blocage(delta)

	var ennemis := get_tree().get_nodes_in_group("ennemis")
	if ennemis.is_empty():
		_aller_au_portail()
		return

	var fuite := Vector2.ZERO
	var menace_proche := INF
	var plus_proche: Node2D = null
	for e in ennemis:
		if not is_instance_valid(e):
			continue
		var ecart: Vector2 = _heros.global_position - e.global_position
		var d := ecart.length()
		if d < menace_proche:
			menace_proche = d
			plus_proche = e
		if d < DISTANCE_CONFORT and d > 1.0:
			fuite += ecart / d * (1.0 - d / DISTANCE_CONFORT)

	if plus_proche != null:
		var pv: float = plus_proche.get("pv")
		if _cible_observee != plus_proche.get_instance_id() or not is_equal_approx(pv,_pv_observes):
			_sans_impact = 0.0
			_cible_observee = plus_proche.get_instance_id()
			_pv_observes = pv
		else:
			_sans_impact += delta
		# Un eventail peut manquer sa cible malgre une ligne centrale libre.
		if _sans_impact > 2.5 and menace_proche > DISTANCE_CONFORT:
			var refuge := _point_de_tir(plus_proche.global_position)
			if refuge != Vector2.ZERO:
				_heros.definir_intention(_direction_vers(refuge),1.0)
				return

	# Un bloc d'encre entre le heros et sa cible rend le tir inutile : rester
	# derriere un mur a tirer dans la pierre etait le blocage le plus frequent
	# de la sonde. On va chercher un point d'ou la ligne est libre.
	var vue_bouchee := plus_proche != null and not _ligne_libre(_heros.global_position, plus_proche.global_position)
	if vue_bouchee:
		var refuge := _point_de_tir(plus_proche.global_position)
		if refuge != Vector2.ZERO:
			_heros.definir_intention(_direction_vers(refuge), 1.0)
			return
		var lateral: Vector2 = _heros.global_position.direction_to(plus_proche.global_position).orthogonal()
		fuite += lateral * _sens_contournement * 1.5

	# Les traits d'encre sont ce qui tue le plus : on s'ecarte perpendiculairement
	# plutot que de reculer devant, ce qui ne sort jamais de la trajectoire.
	var sous_le_feu := false
	for tir in get_tree().get_nodes_in_group("tirs_ennemis"):
		if not is_instance_valid(tir):
			continue
		var ecart: Vector2 = _heros.global_position - tir.global_position
		var d := ecart.length()
		if d > DANGER_TIR:
			continue
		if tir.direction.dot(-ecart.normalized()) < 0.55:
			continue
		sous_le_feu = true
		fuite += tir.direction.orthogonal() * (1.0 - d / DANGER_TIR) * 2.0

	# Le biais vers le centre grandit pres du bord : sans lui, le bot se laisse
	# acculer dans un coin, d'ou il ne peut plus ni fuir ni degager sa ligne.
	var limites: Rect2 = _heros.limites
	var centre: Vector2 = limites.position + limites.size / 2.0
	var bord := minf(
		minf(_heros.global_position.x - limites.position.x, limites.end.x - _heros.global_position.x),
		minf(_heros.global_position.y - limites.position.y, limites.end.y - _heros.global_position.y))
	fuite += _heros.global_position.direction_to(centre) * (0.45 + 1.6 * clampf(1.0 - bord / 220.0, 0.0, 1.0))

	if menace_proche > DISTANCE_CONFORT and not sous_le_feu and not vue_bouchee:
		# Trop loin, meme un tir bien vise rate une cible mobile : on se rapproche
		# comme le ferait un joueur, au lieu d'arroser l'autre bout de la salle.
		if menace_proche > 800.0 and plus_proche != null:
			_heros.definir_intention(_devier(_heros.global_position.direction_to(plus_proche.global_position)), 1.0)
			return
		_heros.definir_intention(Vector2.ZERO)
		return

	# Cycle fixe bouger / s'arreter. Une regle conditionnelle laissait le bot
	# fuir sans jamais s'arreter des qu'un rampant restait colle a lui : il ne
	# tirait plus, et la salle ne se vidait jamais.
	_cycle -= delta
	if _cycle <= 0.0:
		_arret = not _arret
		_cycle = 0.30 if _arret else 0.35
	if _arret and not sous_le_feu:
		_heros.definir_intention(Vector2.ZERO)
		return
	if fuite.length() < 0.05:
		fuite = Vector2.from_angle(randf() * TAU)
	_heros.definir_intention(_devier(fuite.normalized()), 1.0)

# Un bloc d'encre entre le bot et sa cible l'immobilise sans que rien ne le dise :
# il pousse contre le mur pour l'eternite. On devie des qu'il n'avance plus.
func _surveiller_le_blocage(delta: float) -> void:
	_coince = maxf(0.0, _coince - delta)
	if _derniere_position == Vector2.ZERO:
		_derniere_position = _heros.global_position
		return
	if _heros.velocity.length() > 20.0 and _heros.global_position.distance_to(_derniere_position) < 2.0 and _coince <= 0.0:
		_coince = 0.9
		_sens_contournement = -_sens_contournement
	_derniere_position = _heros.global_position

func _ligne_libre(depuis: Vector2, vers: Vector2) -> bool:
	var salle := get_tree().get_first_node_in_group("salle")
	if salle == null:
		return true
	return Geometrie.ligne_libre(depuis, vers, salle.obstacles(), MARGE_TIR)

# Choisir un point atteignable et plus proche evite de longer indefiniment un mur.
func _point_de_tir(cible: Vector2) -> Vector2:
	var limites: Rect2 = _heros.limites.grow(-Reglages.HEROS_RAYON)
	var meilleur := Vector2.ZERO
	var cout := INF
	for rayon in [200.0, 380.0]:
		for i in 12:
			var p: Vector2 = _heros.global_position + Vector2.from_angle(TAU * float(i) / 12.0) * rayon
			if not limites.has_point(p): continue
			if not _ligne_libre(p,cible) or not _trajet_libre(p,p): continue
			var distance := p.distance_to(cible)+float(rayon)*0.15
			if distance < cout:
				cout = distance
				meilleur = p
	return meilleur

func _trajet_libre(depuis: Vector2, vers: Vector2) -> bool:
	var salle := get_tree().get_first_node_in_group("salle")
	return salle == null or Geometrie.ligne_libre(depuis,vers,salle.obstacles(),Reglages.HEROS_RAYON-0.5)

func _devier(direction: Vector2) -> Vector2:
	if _coince <= 0.0:
		return direction
	return direction.rotated(_sens_contournement * PI * 0.5).lerp(direction, 0.2).normalized()

func _direction_vers(destination: Vector2) -> Vector2:
	var salle := get_tree().get_first_node_in_group("salle")
	if salle == null: return _heros.global_position.direction_to(destination)
	if _salle_chemin != Jeu.salle_courante or _chemin.is_empty() or _destination.distance_to(destination)>60.0:
		_destination = destination
		_salle_chemin = Jeu.salle_courante
		_chemin = NAVIGATION.chemin(_heros.global_position,destination,_heros.limites,salle.obstacles(),Reglages.HEROS_RAYON)
		if not _chemin.is_empty(): _chemin.remove_at(0)
	while _chemin.size()>1 and _heros.global_position.distance_to(_chemin[0])<12.0:
		_chemin.remove_at(0)
	if _chemin.is_empty(): return _devier(_heros.global_position.direction_to(destination))
	if _heros.global_position.distance_to(_chemin[0])<8.0:
		_chemin.clear()
		return Vector2.ZERO
	return _heros.global_position.direction_to(_chemin[0])

func _aller_au_portail() -> void:
	var salle := get_tree().get_first_node_in_group("salle")
	if salle == null or not salle.portail_ouvert():
		_heros.definir_intention(Vector2.ZERO)
		return
	var portail: Vector2 = salle.position_portail()
	_heros.definir_intention(_direction_vers(portail),1.0)
