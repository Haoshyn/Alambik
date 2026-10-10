extends RefCounted

# Cycle de pas dessine sous le corps : appui en ligne droite, retour en arc.
# La cadence suit la vitesse pour que le pied pose recule au rythme du corps ;
# l'amplitude est bornee par la portee, les pattes ne s'ecartent jamais.
# Deux segments resolvent la pose ; aucune collision ni sonde physique en 3D.
const Rendu = preload("res://data/presentation/animations_combat.gd")
const APPUI_PART := .55
const CADENCE_MIN := 1.6
const CADENCE_MAX := 5.2
var pattes: Array[Dictionary] = []
var phase := 0.0
var vitesse := 0.0
var _modele: Node3D
var _porteur: Node3D
var _precedente := Vector3.ZERO
var _initialise := false
var _foulee := .30
var _amplitude := 0.0
var _direction := Vector3.FORWARD

func preparer(modele: Node3D) -> void:
	_modele = modele
	_porteur = modele.get_parent() as Node3D
	for hanche: Node3D in modele.find_children("Art_patte_*", "Node3D", true, false):
		var tibia := hanche.find_child("Art_tibia_*", true, false) as Node3D
		var bout := hanche.find_child("Appui_*", true, false) as Node3D
		if tibia == null or bout == null: continue
		var morceaux := str(hanche.name).split("_")
		var groupe := (int(morceaux[-1]) + (0 if "_g_" in str(hanche.name) else 1)) % 2
		pattes.append({"hanche":hanche, "tibia":tibia, "bout":bout,
			"repos_hanche":hanche.transform, "repos_tibia":tibia.transform,
			"origine":modele.to_local(bout.global_position), "groupe":groupe,
			"ancre":Vector3.ZERO, "vol":false})
	_foulee = .24 if pattes.size() == 2 else .26

func mesurer(delta: float) -> Vector3:
	var position := _porteur.global_position
	var trajet := position - _precedente if _initialise else Vector3.ZERO
	_precedente = position
	if trajet.length() > 1.5 * _modele.global_basis.get_scale().length():
		_initialise = false
		trajet = Vector3.ZERO
	var echelle := maxf(_modele.global_basis.get_scale().x, .01)
	vitesse = trajet.length() / maxf(delta * echelle, .001)
	return trajet

func poser(delta: float, trajet: Vector3) -> void:
	var echelle := maxf(_modele.global_basis.get_scale().x, .01)
	var marche := trajet.length_squared() > .0000001
	if marche:
		var local := _modele.global_basis.inverse() * trajet
		local.y = 0.0
		if local.length_squared() > .0000001:
			_direction = _direction.slerp(local.normalized(), 1.0 - exp(-14.0 * delta)).normalized()
	# Pied pose : il recule de toute la foulee pendant APPUI_PART du cycle.
	var cadence := clampf(vitesse * APPUI_PART / maxf(_foulee, .01), CADENCE_MIN, CADENCE_MAX) if marche else 0.0
	var voulue := minf(vitesse * APPUI_PART / maxf(cadence, .01), _foulee) if marche else 0.0
	_amplitude = move_toward(_amplitude, voulue, delta * (_foulee * 6.0))
	if _amplitude > 0.0:
		phase += (cadence if marche else CADENCE_MIN * 1.5) * delta
	elif not marche:
		# Le cycle s'arrete pieds poses : aucun pietinement a l'arret.
		phase = roundf(phase * 2.0) * .5
	var levee := (.045 + .06 * clampf(vitesse / 4.0, 0.0, 1.0)) * minf(1.0, _amplitude / maxf(_foulee * .4, .001))
	for patte: Dictionary in pattes:
		var origine: Vector3 = patte["origine"]
		var cycle := fposmod(phase + float(patte["groupe"]) * .5, 1.0)
		var avance := 0.0
		var hauteur := 0.0
		var vol := cycle >= APPUI_PART
		if not vol:
			avance = lerpf(.5, -.5, cycle / APPUI_PART)
		else:
			var t := (cycle - APPUI_PART) / (1.0 - APPUI_PART)
			avance = lerpf(-.5, .5, smoothstep(0.0, 1.0, t))
			hauteur = sin(t * PI)
		var cible_locale := origine + _direction * avance * _amplitude + Vector3.UP * hauteur * levee
		var ancre := _modele.to_global(cible_locale)
		# Le mouvement vertical du corps n'emporte pas les pieds poses.
		ancre.y = _porteur.global_position.y + (origine.y + hauteur * levee) * _modele.global_basis.get_scale().y
		var hanche: Node3D = patte["hanche"]
		var tibia: Transform3D = patte["repos_tibia"]
		var bout: Node3D = patte["bout"]
		var repos: Transform3D = patte["repos_hanche"]
		var repere := hanche.get_parent() as Node3D
		var portee := (tibia.origin.length() + bout.position.length()) * .98
		var visee := repere.to_local(ancre) - repos.origin
		if visee.length() > portee:
			ancre = repere.to_global(repos.origin + visee.limit_length(portee))
		patte["ancre"] = ancre
		patte["vol"] = vol and _amplitude > 0.0
		_resoudre(patte, ancre)
	_initialise = true

func _resoudre(patte: Dictionary, cible: Vector3) -> void:
	var hanche: Node3D = patte["hanche"]
	var tibia: Node3D = patte["tibia"]
	var bout: Node3D = patte["bout"]
	var repos_hanche: Transform3D = patte["repos_hanche"]
	var repos_tibia: Transform3D = patte["repos_tibia"]
	var cuisse := repos_tibia.origin
	var jambe := bout.position
	var repere := hanche.get_parent() as Node3D
	var visee := repere.to_local(cible) - repos_hanche.origin
	var longueur := clampf(visee.length(), absf(cuisse.length() - jambe.length()) + .001, cuisse.length() + jambe.length() - .001)
	var axe := visee.normalized()
	if axe.is_zero_approx(): return
	# Un pole de repos stable evite que le genou bascule quand le pied monte.
	var axe_repos := (cuisse + repos_tibia.basis * jambe).normalized()
	var pole := cuisse - axe_repos * cuisse.dot(axe_repos)
	var pli := pole - axe * pole.dot(axe)
	if pli.length_squared() < .00001: pli = axe.cross(Vector3.RIGHT)
	pli = pli.normalized()
	var avance := (cuisse.length_squared() - jambe.length_squared() + longueur * longueur) / (2.0 * longueur)
	var genou := axe * avance + pli * sqrt(maxf(0.0, cuisse.length_squared() - avance * avance))
	var rotation := Basis(Quaternion(cuisse.normalized(), genou.normalized()))
	hanche.transform = Transform3D(rotation * repos_hanche.basis, repos_hanche.origin)
	var direction := rotation.inverse() * (axe * longueur - genou)
	tibia.transform = Transform3D(Basis(Quaternion(jambe.normalized(), direction.normalized())) * repos_tibia.basis, repos_tibia.origin)
