extends SceneTree

const Modeles = preload("res://tools/statistiques/modeles.gd")
const Valeur = preload("res://tools/statistiques/valeur_sources.gd")
const ProfilsAugments = preload("res://tools/statistiques/profils_augments.gd")

class CibleSatellite extends Node2D:
	var donnees := {"rayon": 200.0}
	var coups: Array[float] = []
	func recevoir_degats(montant: float, _effets: Array = []) -> void:
		coups.append(montant)

class SalleSatellite extends Node2D:
	var numero := 1
	var couverts: Array[Rect2] = []
	var tirs: Array[Tir] = []
	var directions: Array[Vector2] = []
	func obstacles() -> Array[Rect2]: return couverts
	func contour_sol() -> PackedVector2Array: return PackedVector2Array()
	func tirer(tir: Tir, _origine: Vector2, direction: Vector2, _hostile := false) -> void:
		tirs.append(tir)
		directions.append(direction)

var _erreurs: Array[String] = []
var _controles := 0

func _init() -> void:
	_verifier.call_deferred()

func _verifier() -> void:
	if "verification" not in OS.get_user_data_dir().to_lower():
		push_error("Profil de verification isole requis.")
		quit(1)
		return
	var joueur := root.get_node("ReglagesJoueur")
	joueur.sauvegarde_active = false
	joueur.mode_dev = false
	joueur.volume_musique = 0.0
	joueur.volume_effets = 0.0
	root.get_node("Sons").appliquer_reglages()
	_verifier_valeurs()
	_verifier_nuance()
	_verifier_satellites()
	_verifier_effets_periodiques()
	await _verifier_forge()
	for erreur in _erreurs: push_error(erreur)
	print("Reequilibrage : %d controles, %d erreurs ; rares, legendaires, satellites, effets periodiques, forge et fenetres verifies." % [_controles, _erreurs.size()])
	quit(0 if _erreurs.is_empty() else 1)

func _exiger(condition: bool, message: String) -> void:
	_controles += 1
	if not condition: _erreurs.append(message)

func _verifier_valeurs() -> void:
	for profil: Dictionary in [{}, Modeles.complet()]:
		for mesure: Dictionary in Valeur.augments(profil):
			var meilleur_gain := maxf(float(mesure["gain_dps"]), float(mesure["gain_survie"]))
			var contact: bool = "satellites_alchimiques" in CatalogueReactifs.par_id(str(mesure["id"])).mods.get("drapeaux", [])
			_exiger(meilleur_gain >= (0.075 if contact or mesure["rarete"] == Reactif.EPIQUE else 0.16),
				"Un choix n'a pas de socle utile meme sans son effet conditionnel : " + str(mesure["id"]))
	var base := Modeles.mesurer({})
	var triple := Modeles.mesurer({"augments": ["battement_triple"]})
	_exiger(float(triple["dps"]) / float(base["dps"]) >= 1.45 and float(triple["dps"]) / float(base["dps"]) <= 1.85, "Battement triple doit renforcer le debit sans le tripler")
	var force := Modeles.mesurer({"augments": ["frappe_lourde"]})
	_exiger(float(force["dps"]) / float(base["dps"]) >= 1.45 and float(force["dps"]) / float(base["dps"]) <= 1.85, "Force cataclysmique doit garder un gain fort et mesure")
	var mecaniques_rares := 0
	for id: String in CatalogueReactifs.ids():
		var reactif := CatalogueReactifs.par_id(id)
		if reactif.rarete != Reactif.RARE: continue
		if not reactif.mods.get("drapeaux", []).is_empty() or reactif.mods.has("salves_add") or reactif.mods.has("nb_projectiles_add"):
			mecaniques_rares += 1
	_exiger(mecaniques_rares >= 6, "Les rares doivent proposer plusieurs effets distincts des statistiques")
	for avant: Array in [["tir_multiple"]]:
		var ajout := "tir_multiple"
		var debut := Modeles.mesurer({"augments": avant})
		var fin := Modeles.mesurer({"augments": avant + [ajout]})
		_exiger(float(fin["dps"]) > float(debut["dps"]) * 1.25, "La seconde copie de Tir double doit rester utile")
	for monde in Chapitres.MONDES.size():
		for id: String in CatalogueObjets.IDS_PAR_MONDE[monde]:
			for rang in range(Reglages.FORGE_NIVEAU_MAX + 1):
				var bonus := CatalogueObjets.bonus_objet(id, rang)
				_exiger(float(bonus["attaque_base"]) >= 2.0, "Un bijou manque de statistiques de combat : " + id)
				if rang == Reglages.FORGE_NIVEAU_MAX: continue
				var prochain := CatalogueObjets.bonus_objet(id, rang + 1)
				_exiger(float(prochain["attaque_base"]) > float(bonus["attaque_base"]), "Une forge de bijou n'apporte rien : " + id)

func _verifier_nuance() -> void:
	_exiger("battement_triple" not in DraftLogique.candidats(["salve"], Reactif.LEGENDAIRE), "Battement triple est encore propose apres Salve")
	_exiger("salve" not in DraftLogique.candidats(["battement_triple"], Reactif.RARE), "Salve est encore proposee apres Battement triple")
	var chance := 0.10 + 0.20 + 0.35
	var critiques := Mods.bonus_degats_critiques(Mods.depuis_l_inventaire(["pointe_lucide", "couronne_incisive"]), chance)
	_exiger(is_equal_approx(1.0 + chance * (0.5 + critiques), 1.8275), "Les augments de critique multiplient encore leurs gains entre eux")
	for profil: Dictionary in [{}, Modeles.complet()]:
		var cas := profil.duplicate(true)
		cas["augments"] = ProfilsAugments.NUANCE["mixte_sans_combo"]
		var faible := Modeles.mesurer(cas)
		var pire_rapport := 0.0
		var inventaires := ProfilsAugments.cas_nuance()
		for nom: String in inventaires:
			cas["augments"] = inventaires[nom]
			var fort := Modeles.mesurer(cas)
			var rapport := float(fort["dps_tous_projectiles"]) / float(faible["dps"])
			pire_rapport = maxf(pire_rapport, rapport)
			_exiger(rapport <= 4.5, "Un build coherent sans combo subit un ecart de DPS excessif : " + nom)
		print("Nuance des builds : ecart maximal ideal %.2f ; tous les tirs et diagonales supposés toucher." % pire_rapport)
	var base := Tir.de_base(Stats.depuis_reglages())
	var double := Mods.appliquer(base, Mods.depuis_l_inventaire(["salve", "tir_multiple"]))
	var rapide := Mods.appliquer(base, Mods.depuis_l_inventaire(["salve", "tir_multiple", "cadence_febrile"]))
	var debit := rapide.degats * rapide.degats_finaux_projectile_mult * rapide.nb_projectiles * rapide.salves * rapide.cadence
	var debit_base := base.degats * base.cadence
	_exiger(is_equal_approx(debit / debit_base, 2.10), "Le cumul des tirs et de la cadence doit ajouter leurs gains")
	_exiger(rapide.cadence > double.cadence and rapide.degats_finaux_projectile_mult < double.degats_finaux_projectile_mult, "Le cumul doit conserver ses gestes et attenuer ses impacts")

func _verifier_satellites() -> void:
	var jeu := root.get_node("Jeu")
	jeu.inventaire.assign(["satellites_alchimiques", "salve", "battement_triple", "tir_multiple", "spirale", "ricochet"])
	var salle := SalleSatellite.new()
	root.add_child(salle)
	salle.add_to_group("salle")
	var heros := load("res://scripts/combat/heros.gd").new() as Node2D
	var stats := Stats.depuis_reglages()
	stats.attaque_base = 100.0
	stats.degats = 100.0
	stats.critique = 1.0
	heros.set("stats", stats)
	root.add_child(heros)
	heros.set_process(false)
	heros.set_physics_process(false)
	heros.call("definir_intention", Vector2.RIGHT)
	var satellites := heros.get_node("SatellitesAlchimiques") as SatellitesAlchimiques
	satellites.set_physics_process(false)
	var cible := CibleSatellite.new()
	root.add_child(cible)
	cible.add_to_group("ennemis")
	satellites._physics_process(0.0)
	_exiger(cible.coups.size() == 1 and is_equal_approx(cible.coups[0], 36.0), "Les cercles doivent frapper en mouvement sans multiplier critiques, salves, diagonales ou rebonds")
	satellites._physics_process(0.30)
	_exiger(cible.coups.size() == 1, "Les deux satellites contournent le delai partage par ennemi")
	satellites._physics_process(0.30)
	_exiger(cible.coups.size() == 2, "Le delai des satellites ne se recharge pas")
	cible.position = Vector2(2000, 0)
	satellites._physics_process(1.0)
	_exiger(cible.coups.size() == 2, "Les satellites frappent a distance")
	cible.position = Vector2(135, 0)
	cible.donnees["rayon"] = 0.0
	salle.couverts.assign([Rect2(40, -500, 20, 1000)])
	satellites.preparer_nouvelle_salle()
	satellites._physics_process(0.0)
	_exiger(cible.coups.size() == 2, "Les satellites frappent derriere un mur")
	salle.couverts.clear()
	satellites._physics_process(0.0)
	_exiger(cible.coups.size() == 3, "Un obstacle disparu reste memorise")
	var rendu := load("res://scripts/presentation/satellites_alchimiques_3d.gd").new() as Node3D
	rendu.set("logique", satellites)
	root.add_child(rendu)
	var cercles: Array = rendu.get("_cercles")
	_exiger(rendu.visible and cercles.size() == 2, "Le rendu n'affiche pas les deux cercles")
	var points := satellites.positions_satellites()
	for index in cercles.size():
		_exiger((cercles[index] as Node3D).position.is_equal_approx(Pont3D.vers_monde(points[index], 0.32)), "Le cercle visible quitte sa position de contact")
	stats.pv = 0.0
	satellites._physics_process(1.0)
	rendu.call("mettre_a_jour", 0.0)
	_exiger(not satellites.actif() and cible.coups.size() == 3, "Les satellites restent actifs apres la mort")
	_exiger(not rendu.visible, "Les cercles visibles survivent au heros")
	rendu.free()
	heros.free()
	cible.free()
	salle.free()
	jeu.inventaire.clear()

func _verifier_effets_periodiques() -> void:
	var jeu := root.get_node("Jeu")
	jeu.inventaire.assign(["encrage_vif", "sceau_ruine", "salve", "battement_triple", "tir_multiple", "spirale", "ricochet"])
	var salle := SalleSatellite.new()
	root.add_child(salle)
	salle.add_to_group("salle")
	var heros := load("res://scripts/combat/heros.gd").new() as Node2D
	var stats := Stats.depuis_reglages()
	stats.attaque_base = 100.0
	stats.degats = 100.0
	stats.critique = 1.0
	heros.set("stats", stats)
	root.add_child(heros)
	heros.set_process(false)
	heros.set_physics_process(false)
	heros.call("definir_intention", Vector2.RIGHT)
	var effets := heros.get_node("EffetsPeriodiquesAugments") as Node2D
	effets.set_physics_process(false)
	var cibles: Array[Node2D] = []
	for point: Vector2 in [Vector2(300, 0), Vector2(360, 0), Vector2(600, 0)]:
		var cible := CibleSatellite.new()
		cible.donnees["rayon"] = 10.0
		cible.position = point
		root.add_child(cible)
		cible.add_to_group("ennemis")
		cibles.append(cible)
	effets.call("_physics_process", 2.99)
	_exiger(salle.tirs.is_empty(), "Le trait periodique se lance avant sa recharge")
	effets.call("_physics_process", 0.01)
	_exiger(salle.tirs.size() == 1, "Le trait doit partir apres trois secondes meme en mouvement")
	if not salle.tirs.is_empty():
		var tir: Tir = salle.tirs[0]
		_exiger(is_equal_approx(tir.degats, 108.75) and tir.nb_projectiles == 1 and tir.salves == 1 and tir.rebonds == 0,
			"Les tirs du build ou ses critiques multiplient le trait periodique")
		_exiger(salle.directions[0].is_equal_approx(Vector2.RIGHT), "Le trait ne vise pas la cible visible la plus proche")
		var projectile := load("res://scenes/projectile.tscn").instantiate() as Area2D
		projectile.set("tir", tir)
		root.add_child(projectile)
		projectile.set_physics_process(false)
		projectile.call("_sur_contact", cibles[0])
		_exiger(is_equal_approx(cibles[0].coups[0], 108.75), "Le projectile ne conserve pas les degats du trait")
		root.remove_child(projectile)
		projectile.free()
		cibles[0].coups.clear()
	effets.call("_physics_process", 2.0)
	_exiger(float(effets.get("chute_restante")) > 0.0 and cibles[0].coups.is_empty(), "La meteorite doit annoncer sa chute avant de frapper")
	var rendu := load("res://scripts/presentation/meteorite_alchimique_3d.gd").new() as Node3D
	rendu.set("logique", effets)
	root.add_child(rendu)
	_exiger(rendu.visible and rendu.position.is_equal_approx(Pont3D.vers_monde(Vector2(300, 0), 0.06)), "La meteorite visible ne suit pas sa position d'impact")
	effets.call("_physics_process", ReglagesAugments.METEORITE_CHUTE)
	_exiger(cibles[0].coups.size() == 1 and is_equal_approx(cibles[0].coups[0], 181.25) \
		and cibles[1].coups.size() == 1 and cibles[2].coups.is_empty(), "Le souffle de meteorite doit frapper une fois les ennemis proches sans critique")
	effets.call("_physics_process", 0.0)
	_exiger(cibles[0].coups.size() == 1, "La meteorite frappe plusieurs fois a son impact")
	jeu.inventaire.append("encrage_vif")
	heros.call("recalculer")
	effets.call("preparer_nouvelle_salle")
	effets.call("_physics_process", ReglagesAugments.TRAIT_INTERVALLE)
	_exiger(salle.tirs.size() == 2 and is_equal_approx(salle.tirs[-1].degats, 255.0), "La deuxieme copie d'Encrage vif ne renforce pas son trait")
	salle.couverts.assign([Rect2(100, -500, 20, 1000)])
	effets.call("preparer_nouvelle_salle")
	effets.call("_physics_process", ReglagesAugments.METEORITE_INTERVALLE)
	_exiger(salle.tirs.size() == 2, "Le trait cible un ennemi derriere un couvert")
	salle.couverts.assign([Rect2(330, -500, 10, 1000)])
	effets.call("_physics_process", ReglagesAugments.METEORITE_CHUTE)
	_exiger(cibles[0].coups.size() == 2 and cibles[1].coups.size() == 1, "Le souffle de meteorite traverse un mur")
	salle.couverts.clear()
	effets.call("preparer_nouvelle_salle")
	effets.call("_physics_process", ReglagesAugments.METEORITE_INTERVALLE)
	cibles[0].position = Vector2(900, 0)
	cibles[1].position = Vector2(1000, 0)
	effets.call("_physics_process", ReglagesAugments.METEORITE_CHUTE)
	_exiger(cibles[0].coups.size() == 2 and cibles[1].coups.size() == 1, "La meteorite suit sa cible apres le debut de chute")
	effets.call("preparer_nouvelle_salle")
	_exiger(is_zero_approx(float(effets.get("chute_restante"))) and is_zero_approx(float(effets.get("impact_restant"))), "Un impact reste arme dans la salle suivante")
	effets.call("_physics_process", ReglagesAugments.METEORITE_INTERVALLE)
	stats.pv = 0.0
	var tirs_avant := salle.tirs.size()
	effets.call("_physics_process", 6.0)
	rendu.call("mettre_a_jour", 0.0)
	_exiger(salle.tirs.size() == tirs_avant and not rendu.visible and is_zero_approx(float(effets.get("chute_restante"))), "Les effets periodiques continuent apres la mort")
	rendu.free()
	heros.free()
	for cible in cibles: cible.free()
	salle.free()
	jeu.inventaire.clear()

func _verifier_forge() -> void:
	var joueur := root.get_node("ReglagesJoueur")
	for format: Vector2i in [Vector2i(720, 1280), Vector2i(1080, 2340)]:
		root.size = format
		joueur.effets_reduits = format.x == 720
		joueur.forge_niveaux = {}
		joueur.pierres_forge = 10000
		var page := load("res://ui/equipement.gd").new() as Control
		root.add_child(page)
		for _image in 8: await process_frame
		page.call("_selectionner_arme", "standard")
		await create_timer(0.40).timeout
		var fiche: Control = page.get("_fiche_popup")
		_exiger(fiche.find_child("ProgressionForge", true, false) != null, "La forge ne montre pas le prochain rang")
		var identite := fiche.get_instance_id()
		var pierres := int(joueur.pierres_forge)
		var cout := int(joueur.cout_forge_arme("standard"))
		var forge_bouton: Button
		for bouton: Button in fiche.find_children("*", "Button", true, false):
			if bouton.text == "Forge": forge_bouton = bouton
		_exiger(is_instance_valid(forge_bouton) and not forge_bouton.disabled, "La commande de forge financable est absente")
		forge_bouton.pressed.emit()
		_exiger((page.get("_fiche_popup") as Control).get_instance_id() == identite, "Une forge recree sa fenetre")
		_exiger(int(joueur.niveau_arme("standard")) == 1 and int(joueur.pierres_forge) == pierres - cout, "Une animation modifie le paiement ou le rang")
		_exiger(fiche.find_child("ConfirmationForge", true, false) != null, "La forge reussie n'a pas de retour visuel")
		for _image in 8: await process_frame
		var panneau: Panel = fiche.get("_panneau")
		_exiger(Rect2(Vector2.ZERO, fiche.size).encloses(panneau.get_rect()), "Fiche hors de la zone portrait")
		joueur.pierres_forge = 0
		page.call("_ouvrir_fiche_arme")
		for bouton: Button in fiche.find_children("*", "Button", true, false):
			if bouton.text == "Forge": _exiger(bouton.disabled, "La commande reste active sans pierres")
		page.call("_agir_arme", true)
		_exiger(int(joueur.niveau_arme("standard")) == 1 and int(joueur.pierres_forge) == 0, "Une forge sans fonds a reussi")
		fiche.call("fermer")
		fiche.call("fermer")
		await create_timer(0.25).timeout
		_exiger(not is_instance_valid(fiche), "La fermeture ne termine pas ou cree une seconde fenetre")
		page.free()
		await process_frame
