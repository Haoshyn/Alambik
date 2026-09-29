extends RefCounted

# Au pas, les points d'appui restent fixes ; la course absorbe l'exces de translation.
# Deux segments resolvent la pose ; aucune collision ni sonde physique en 3D.
const Rendu = preload("res://data/presentation/animations_combat.gd")
const APPUI_PART := .64
var pattes: Array[Dictionary] = []
var phase := 0.0
var vitesse := 0.0
var _modele: Node3D
var _porteur: Node3D
var _precedente := Vector3.ZERO
var _initialise := false
var _avancait := false
var _foulee := .30
var _decalage_appuis := Vector3.ZERO

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
			"ancre":Vector3.ZERO, "depart":Vector3.ZERO, "cible":Vector3.ZERO,
			"vol":false, "retour":0.0, "cycle":0.0})
	_foulee = .28 if pattes.size() == 2 else .46

func mesurer(delta: float) -> Vector3:
	var position := _porteur.global_position
	var trajet := position - _precedente if _initialise else Vector3.ZERO
	_precedente = position
	if trajet.length() > 1.5 * _modele.global_basis.get_scale().length():
		_initialise = false
		trajet = Vector3.ZERO
	var echelle := maxf(_modele.global_basis.get_scale().x, .01)
	vitesse = trajet.length() / maxf(delta * echelle, .001)
	var avance := trajet.length_squared() > .0000001
	# Le premier appui part du milieu de la foulee, comme apres un arret.
	if avance and not _avancait:
		phase = .35
		for patte: Dictionary in pattes:
			patte["cycle"] = phase + float(patte["groupe"]) * .5
	_avancait = avance
	# La course reste lisible meme quand le corps traverse plusieurs foulees par seconde.
	var progression := minf(trajet.length() / (echelle * _foulee), Rendu.PATTES_CADENCE_MAX * maxf(delta, 0.0))
	phase += progression
	# L'exces de vitesse accompagne les appuis au lieu de forcer des replacements secs.
	_decalage_appuis = trajet - trajet.limit_length(progression * echelle * _foulee)
	return trajet

func poser(delta: float, trajet: Vector3) -> void:
	var echelle := maxf(_modele.global_basis.get_scale().x, .01)
	var marche := trajet.length_squared() > .0000001
	for patte: Dictionary in pattes:
		var origine: Vector3 = patte["origine"]
		var maison := _modele.to_global(origine)
		# Le mouvement vertical du corps n'emporte pas les pieds.
		maison.y = _porteur.global_position.y + origine.y * _modele.global_basis.get_scale().y
		if not _initialise:
			patte["ancre"] = maison
			patte["depart"] = maison
			patte["cible"] = maison
		else:
			for cle in ["ancre", "depart", "cible"]:
				var point: Vector3 = patte[cle]
				patte[cle] = point + _decalage_appuis
		var cycle_total := phase + float(patte["groupe"]) * .5
		var cycle := fposmod(cycle_total, 1.0)
		var nouveau_pas := floorf(cycle_total) > floorf(float(patte["cycle"]))
		var vol := cycle >= APPUI_PART and marche
		var ancre: Vector3 = patte["ancre"]
		var foulee := trajet.normalized() * _foulee * echelle
		if vol and (not bool(patte["vol"]) or nouveau_pas):
			if nouveau_pas: ancre = maison - foulee * (cycle - APPUI_PART * .5)
			patte["depart"] = ancre
			# Viser le sol a la fin du vol, en anticipant l'avancee du corps.
			patte["cible"] = maison + foulee * (1.0 - cycle + APPUI_PART * .5)
			patte["retour"] = 0.0
		if vol:
			var t := (cycle - APPUI_PART) / (1.0 - APPUI_PART)
			ancre = _lever(patte, t, echelle)
		elif marche and (bool(patte["vol"]) or nouveau_pas):
			# A basse frequence, un pas entier peut etre franchi entre deux images.
			ancre = maison + foulee * (APPUI_PART * .5 - cycle)
		elif not marche and (bool(patte["vol"]) or ancre.distance_to(maison) > .004 * echelle or (float(patte["retour"]) > 0.0 and float(patte["retour"]) < 1.0)):
			# A l'arret, finir le pas une fois, sans entretenir un pietinement.
			if float(patte["retour"]) <= 0.0:
				patte["depart"] = ancre
				patte["cible"] = maison
			patte["retour"] = minf(1.0, float(patte["retour"]) + delta * 7.0)
			ancre = _lever(patte, float(patte["retour"]), echelle)
		else:
			patte["retour"] = 0.0
		var hanche: Node3D = patte["hanche"]
		var tibia: Transform3D = patte["repos_tibia"]
		var bout: Node3D = patte["bout"]
		var repos: Transform3D = patte["repos_hanche"]
		var repere := hanche.get_parent() as Node3D
		var extension := repere.to_local(ancre).distance_to(repos.origin)
		if marche and extension > (tibia.origin.length() + bout.position.length()) * .98:
			# La limite de portee reste continue, meme en virage ou en bout de pas.
			var visee := repere.to_local(ancre) - repos.origin
			var portee := (tibia.origin.length() + bout.position.length()) * .98
			ancre = repere.to_global(repos.origin + visee.limit_length(portee))
		patte["ancre"] = ancre
		patte["vol"] = vol
		patte["cycle"] = cycle_total
		_resoudre(patte, ancre)
	_initialise = true

func _lever(patte: Dictionary, t: float, echelle: float) -> Vector3:
	var depart: Vector3 = patte["depart"]
	var cible: Vector3 = patte["cible"]
	return depart.lerp(cible, smoothstep(0.0, 1.0, t)) + Vector3.UP * sin(t * PI) * .065 * echelle

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
