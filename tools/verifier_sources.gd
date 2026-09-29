extends SceneTree

const Modeles = preload("res://tools/statistiques/modeles.gd")
const Reference = preload("res://tools/statistiques/profil_reference.gd")
const Valeur = preload("res://tools/statistiques/valeur_sources.gd")

var _erreurs: Array[String] = []
var _controles := 0

func _init() -> void:
	_verifier.call_deferred()

func _verifier() -> void:
	if "verification" not in OS.get_user_data_dir().to_lower():
		push_error("Profil de verification isole requis.")
		quit(1)
		return
	root.get_node("ReglagesJoueur").sauvegarde_active = false
	var profil := Reference.construire()
	profil.erase("augments")
	var copie := profil.duplicate(true)
	var fin := Modeles.mesurer(profil)
	var nu := Modeles.mesurer({"arme": "", "familier": ""})
	_exiger(is_equal_approx(float(nu["tir_normal"]), 10.0), "Le heros nu commence a dix degats")
	_exiger(float(fin["tir_normal"]) >= 1000.0 and float(fin["tir_normal"]) <= 1500.0,
		"Le compte complet doit atteindre environ mille degats normaux sans augment")
	for retrait: Dictionary in Valeur.equipement(profil):
		_exiger(float(retrait["perte_dps"]) >= 0.05 or float(retrait["perte_survie"]) >= 0.10,
			"Un emplacement ne contribue pas assez au build complet : " + str(retrait["emplacement"]))
	for configuration: Dictionary in [{}, profil]:
		for mesure: Dictionary in Valeur.augments(configuration):
			var id := str(mesure["id"])
			if id in ["cadence_febrile", "sceau_ruine", "pointe_lucide", "encrage_vif"]:
				_exiger(float(mesure["gain_dps"]) >= 0.15, "Rare offensif trop faible : " + id)
			if id in ["sceau_garde", "peau_cuivre"]:
				_exiger(float(mesure["gain_survie"]) >= 0.20, "Rare defensif trop faible : " + id)
	for id: String in CatalogueFamiliers.TYPES:
		var precedent := 0.0
		for forge in range(Reglages.FORGE_NIVEAU_MAX + 1):
			var attaque := CatalogueFamiliers.attaque_combat(id, forge, 0.0)
			_exiger(attaque > precedent, "La forge ne doit jamais etre annulee : " + id)
			_exiger(is_equal_approx(CatalogueFamiliers.attaque_combat(id, forge, 1.0, 1.25), attaque * 2.5),
				"Le familier doit partager une seule fois les facteurs permanent et de run : " + id)
			precedent = attaque
	for niveau in [1, 4, 15, Personnage.NIVEAU_MAX]:
		for id: String in Personnage.ATTRIBUTS:
			for points in [0, 1, 25, 40, 144]:
				var avant := Personnage.bonus({id: points}, niveau)
				var gain := Personnage.gain_point(id, points, niveau)
				var apres := Personnage.bonus({id: points + 1}, niveau)
				for champ: String in avant:
					_exiger(is_equal_approx(float(avant[champ]) + float(gain[champ]), float(apres[champ])),
						"Le prochain point affiche un gain different du combat : " + id)
				_exiger(Personnage.description_attribut(id, points, niveau).contains("Prochain point"),
					"Le prochain point manque dans la description : " + id)
	_exiger(profil == copie, "Les mesures ne modifient pas le profil permanent")
	var lignes: Array[String] = []
	Valeur.ajouter(lignes)
	_exiger("\n".join(lignes).contains("Rendements réduits par les cumuls"), "Les listes doivent rendre les cumuls visibles")
	await _verifier_heros()
	for erreur: String in _erreurs: push_error(erreur)
	print("Valeur des sources : %d controles, %d erreurs ; impact normal final %.2f." % [_controles, _erreurs.size(), float(fin["tir_normal"])])
	quit(0 if _erreurs.is_empty() else 1)

func _verifier_heros() -> void:
	var script := load("res://ui/heros.gd") as GDScript
	var joueur := root.get_node("ReglagesJoueur")
	joueur.mode_dev = false
	joueur.specialisation = "sorcier"
	for format: Vector2i in [Vector2i(720, 1280), Vector2i(1080, 2340)]:
		root.size = format
		for niveau in [1, Personnage.NIVEAU_MAX]:
			joueur.niveau_compte = niveau
			joueur.attributs = {} if niveau == 1 else Modeles.complet()["attributs"].duplicate()
			var page: Control = script.new()
			root.add_child(page)
			for _image in 8: await process_frame
			var descriptions: Dictionary = page.get("_descriptions")
			var plus: Dictionary = page.get("_plus")
			for id: String in Personnage.ATTRIBUTS:
				var description: Label = descriptions[id]
				var panneau := page.find_child("Attribut_" + id, true, false) as PanelContainer
				var bouton: Button = plus[id]
				_exiger(description.text == Personnage.description_attribut(id, joueur.rang_attribut(id), niveau),
					"La fiche affiche les valeurs d'un autre niveau : " + id)
				_exiger(panneau.get_global_rect().encloses(description.get_global_rect()), "Description hors carte : " + id)
				_exiger(not description.get_global_rect().intersects(bouton.get_global_rect()), "Description sur la commande Plus : " + id)
			page.free()
			await process_frame

func _exiger(condition: bool, message: String) -> void:
	_controles += 1
	if not condition: _erreurs.append(message)
