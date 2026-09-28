extends RefCounted

# Les pivots viennent des sources Blender ; aucune recherche dans l'arbre par image.
var _membres: Array[Dictionary] = []
var _temps := 0.0
var _mouvement := 0.0
var _elan := Vector2.ZERO
var _preparation_lente := 0.0
var _forme := ""

func preparer(modele: Node3D, donnees: Dictionary) -> void:
	_forme = str(donnees.get("forme", ""))
	_temps = float(modele.get_instance_id() % 101) * .17
	for membre: Node3D in modele.find_children("Art_*", "Node3D", true, false):
		var morceaux := str(membre.name).split("_")
		if morceaux[1] in ["patte", "tibia"]: continue
		_membres.append({"noeud": membre, "repos": membre.transform,
			"role": morceaux[1], "cote": -1.0 if "_g_" in str(membre.name) else 1.0,
			"index": float(morceaux[-1])})

func mettre_a_jour(delta: float, mouvement: float, preparation: float, frappe: float, heurt: float, elan: Vector2, phase: float) -> void:
	_temps += delta
	_mouvement = lerpf(_mouvement, mouvement, 1.0 - exp(-12.0 * delta))
	_elan = _elan.lerp(elan, 1.0 - exp(-5.0 * delta))
	_preparation_lente = lerpf(_preparation_lente, preparation, 1.0 - exp(-7.0 * delta))
	var reduit := ReglagesJoueur.effets_reduits
	var souffle := 0.0 if reduit else sin(_temps * 1.65)
	for membre: Dictionary in _membres:
		var noeud: Node3D = membre["noeud"]
		var repos: Transform3D = membre["repos"]
		var cote: float = membre["cote"]
		var index: float = membre["index"]
		var pas := sin(phase * TAU + (PI if cote < 0 else 0.0)) * _mouvement
		var rotation := Vector3.ZERO
		var decalage := Vector3.ZERO
		match str(membre["role"]):
			"bras":
				rotation.x = _preparation_lente * .55 - frappe * .72 + pas * .08
				rotation.z = cote * (-_preparation_lente * .15 + frappe * .06) + _elan.x * .035
			"arme":
				rotation.x = preparation * .42 - frappe * .80
			"livre":
				rotation.y = cote * (.17 + souffle * .025 + preparation * .40 - frappe * .58)
				rotation.z = cote * (preparation * .06 - frappe * .09)
			"aile":
				rotation.z = cote * (souffle * .035 - _preparation_lente * .18 + frappe * .24) + _elan.x * .06
				rotation.x = _elan.y * .08
			"tete":
				rotation.x = -_preparation_lente * .15 + frappe * .23 - heurt * .08
				rotation.y = -_elan.x * .035
				if _forme == "goutte": rotation.x += preparation * .20 - frappe * .40
			"queue", "pan":
				rotation.x = _elan.y * .20 + _preparation_lente * .08 - frappe * .11
				rotation.y = -_elan.x * .22
				rotation.z = cote * souffle * .018
			"roue":
				# Un nimbe vertical tourne autour de son axe, la bobine autour du sien.
				if index > 0: rotation.z = preparation * .18 - frappe * .26
				else: rotation.y = preparation * .70 - frappe * .45
			"bouchon":
				decalage.y = preparation * .035 + frappe * .085
				rotation.z = heurt * .08
		noeud.transform = repos * Transform3D(Basis.from_euler(rotation), decalage)
