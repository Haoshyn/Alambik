extends RefCounted

func test_couverture_modeles_et_mondes(v: Verif) -> void:
	v.vrai(Visuels3D.AMBIANCES.size() == Chapitres.MONDES.size(), "une ambiance par monde")
	for ambiance in Visuels3D.AMBIANCES:
		v.vrai(ambiance.size() == 3, "pierre, eau et bordures")
	for id in CatalogueEnnemis.TOUS:
		v.vrai(ResourceLoader.exists(Visuels3D.chemin_ennemi(CatalogueEnnemis.par_id(id))), "modele du bestiaire : " + str(id))
	for chemin in ["characters/heros", "characters/gardien", "environment/socle_atelier"]:
		v.vrai(ResourceLoader.exists("res://assets/3d/" + chemin + ".glb"), "modele : " + chemin)

func test_cadrage_portrait(v: Verif) -> void:
	v.egal(ProjectSettings.get_setting("display/window/stretch/aspect"), "keep", "aucun etirement ni rognage du cadre")

func test_orientation_du_mage(v: Verif) -> void:
	var heros := CharacterBody2D.new()
	var proxy: Node3D = load("res://scripts/presentation/proxy_3d.gd").new()
	proxy.logique = heros
	proxy.genre = "heros"
	proxy.modele = Node3D.new()
	proxy.add_child(proxy.modele)
	# Le mode automatique evite seulement de consulter les stats d'un heros factice.
	var ancien_auto := Jeu.mode_auto
	Jeu.mode_auto = true
	proxy._jouer_tir(null, Vector2.ZERO, Vector2.UP)
	heros.velocity = Vector2.DOWN * 100.0
	proxy.mettre_a_jour(0.0)
	v.vrai(is_equal_approx(proxy.modele.rotation.y, 0.0), "marche vers le bas apres un tir vers le haut")
	v.vrai(proxy.scale.is_equal_approx(Vector3.ONE), "le mage conserve une echelle uniforme de face et de profil")
	heros.velocity = Vector2.LEFT * 100.0
	proxy.mettre_a_jour(0.0)
	v.vrai(is_equal_approx(proxy.modele.rotation.y, -PI/2), "orientation pendant la marche laterale")
	heros.velocity = Vector2.ZERO
	proxy.mettre_a_jour(0.0)
	v.vrai(is_equal_approx(proxy.modele.rotation.y, -PI/2), "orientation conservee a l'arret")
	proxy._jouer_tir(null, Vector2.ZERO, Vector2.RIGHT)
	proxy.mettre_a_jour(0.0)
	v.vrai(is_equal_approx(proxy.modele.rotation.y, PI/2), "le nouveau tir oriente le mage vers sa cible")
	Jeu.mode_auto = ancien_auto
	proxy.free()
	heros.free()

