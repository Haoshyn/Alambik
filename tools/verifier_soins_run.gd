extends SceneTree

const SOINS := preload("res://data/progression/soins_run.gd")
const COLLECTE := preload("res://scripts/monde/collecte_soins.gd")
const CAS_COEURS := [
	{"pv": 40.0, "pv_fin": 56.0, "soins": 2, "conversions": 0},
	{"pv": 94.0, "pv_fin": 100.0, "soins": 1, "conversions": 1},
	{"pv": 100.0, "pv_fin": 100.0, "soins": 0, "conversions": 2},
	{"pv": 0.0, "pv_fin": 0.0, "soins": 0, "conversions": 0},
]

class HerosTest extends Node2D:
	var stats := Stats.new()

class SalleTest extends Node2D:
	var limites := Rect2(0, 0, 1000, 1400)
	var blocs: Array[Rect2] = []
	var forme := PackedVector2Array([Vector2(0, 0), Vector2(1000, 0), Vector2(1000, 1400), Vector2(0, 1400)])
	func obstacles() -> Array[Rect2]: return blocs
	func contour_sol() -> PackedVector2Array: return forme

class EnnemiTest extends Node2D:
	var donnees := {"experience": 0, "elite": false}

var _erreurs: Array[String] = []
var _controles := 0
var _reglages: Node
var _jeu: Node

func _init() -> void:
	call_deferred("_executer")

func _verifier(condition: bool, message: String) -> void:
	_controles += 1
	if not condition: _erreurs.append(message)

func _executer() -> void:
	var profil := OS.get_user_data_dir().replace("\\", "/")
	if not profil.contains("/tmp/verification_") or not profil.contains("/profil/"):
		push_error("Profil temporaire APPDATA/LOCALAPPDATA requis pour verifier les soins")
		quit(1)
		return
	_reglages = root.get_node("ReglagesJoueur")
	_reglages.sauvegarde_active = false
	_jeu = root.get_node("Jeu")
	_verifier_quota()
	_verifier_collecte()
	_verifier_transition()
	_verifier_bords()
	_verifier_mine()
	for cas: Dictionary in CAS_COEURS:
		if float(cas["pv"]) <= 0.0: continue
		await _verifier_fin_salle("grimoire", 1, cas)
		await _verifier_fin_salle("grimoire", Reglages.SALLES_PAR_RUN, cas)
		await _verifier_fin_salle("epreuves", 1, cas)
		await _verifier_fin_salle("mine", 1, cas)
	await _verifier_menu()
	_verifier_heros()
	for erreur in _erreurs: push_error(erreur)
	print("Verification soins et retrait tutoriel : %d controles, %d erreurs." % [_controles, _erreurs.size()])
	quit(0 if _erreurs.is_empty() else 1)

func _verifier_quota() -> void:
	_verifier(is_equal_approx(SOINS.esperance_par_rencontre(), 0.9), "Esperance de 0,9 coeur par rencontre")
	_verifier(SOINS.quota_pour_tirage(0.0) == 0 and SOINS.quota_pour_tirage(0.14999) == 0, "15 % sans coeur")
	_verifier(SOINS.quota_pour_tirage(0.15) == 1 and SOINS.quota_pour_tirage(0.94999) == 1, "80 % avec un coeur")
	_verifier(SOINS.quota_pour_tirage(0.95) == 2 and SOINS.quota_pour_tirage(1.0) == 2, "5 % avec deux coeurs")
	var alea := RandomNumberGenerator.new()
	alea.seed = 27092026
	var sommes := 0
	for _tirage in 10000:
		var quota := SOINS.quota_pour_tirage(alea.randf())
		sommes += quota
		var indices := SOINS.indices_de_morts(11, quota, alea)
		_verifier(indices.size() == quota, "Chaque quota repartit tous ses coeurs")
		_verifier(indices.is_empty() or indices.front() >= 1 and indices.back() <= 11, "Indices dans toutes les vagues")
		_verifier(indices.size() < 2 or indices[0] != indices[1], "Deux monstres distincts quand possible")
	_verifier(absf(float(sommes) / 10000.0 - 0.9) < 0.025, "Distribution reproductible proche de 0,9")
	_verifier(SOINS.indices_de_morts(1, 2, alea) == [1, 1], "Un boss seul peut laisser deux coeurs")
	_verifier(SOINS.indices_de_morts(0, 2, alea).is_empty(), "Aucun coeur dans une salle vide")
	_verifier(SOINS.compter_combattants([[1, 2, 3], [4, 5], [6]]) == 6, "Budget de salle partage entre vagues")

func _heros() -> HerosTest:
	var heros := HerosTest.new()
	heros.stats.pv_max = 100.0
	heros.stats.pv = 100.0
	heros.stats.soin_mult = 1.0
	heros.stats.soin_restant = 0.0
	heros.position = Vector2(500, 1100)
	root.add_child(heros)
	return heros

func _creer_collecte(heros: Node2D, salle: Node2D, mine := false) -> Node2D:
	var collecte := COLLECTE.new()
	salle.add_child(collecte)
	collecte.configurer(heros, salle, 704, 8, mine)
	collecte.set_physics_process(false)
	return collecte

func _abattre(collecte: Node2D, point: Vector2, invocation := false) -> void:
	var ennemi := Node.new()
	if invocation: ennemi.set_meta("invocateur", 42)
	collecte.enregistrer_mort(ennemi, point)
	ennemi.free()

func _suivre_collecte(collecte: Node2D) -> Dictionary:
	var bilan := {"soin": 0.0, "gouttes": 0, "soins": 0, "conversions": 0}
	collecte.ramasse.connect(func(soin: float) -> void:
		bilan["soin"] = float(bilan["soin"]) + soin
		bilan["soins"] = int(bilan["soins"]) + 1)
	collecte.gouttes_gagnees.connect(func(montant: int) -> void:
		bilan["gouttes"] = int(bilan["gouttes"]) + montant
		bilan["conversions"] = int(bilan["conversions"]) + 1)
	return bilan

func _verifier_collecte() -> void:
	var heros := _heros()
	var salle := SalleTest.new()
	root.add_child(salle)
	var collecte := _creer_collecte(heros, salle)
	var bilan := _suivre_collecte(collecte)
	var indices: Array[int] = [3, 8]
	collecte._indices = indices
	for _invocation in 12: _abattre(collecte, Vector2(500, 300), true)
	_verifier(collecte._morts == 0 and collecte.nombre_au_sol() == 0, "Les invocations ne consomment ni ne produisent de soin")
	var ennemi := Node.new()
	collecte.enregistrer_mort(ennemi, Vector2(500, 300))
	collecte.enregistrer_mort(ennemi, Vector2(500, 300))
	ennemi.free()
	_verifier(collecte._morts == 1, "Un signal de mort duplique ne compte qu'une fois")
	for _mort in 7: _abattre(collecte, Vector2(500, 300))
	_verifier(collecte.nombre_au_sol() == 2, "Les morts choisies des differentes vagues donnent le quota complet")
	heros.position = Vector2(500, 300)
	collecte._physics_process(0.0)
	_verifier(collecte.nombre_au_sol() == 2, "PV pleins : les coeurs restent disponibles")
	_verifier(int(bilan["soins"]) == 0 and int(bilan["gouttes"]) == 0, "PV pleins en combat : ni soin ni Goutte au passage")
	heros.stats.pv = 94.0
	heros.stats.soin_mult = 1.5
	collecte._physics_process(0.0)
	_verifier(is_equal_approx(heros.stats.pv, 100.0) and collecte.nombre_au_sol() == 1, "Seul le coeur necessaire est consomme")
	_verifier(is_equal_approx(float(bilan["soin"]), 6.0) and int(bilan["gouttes"]) == 0, "Un petit manque consomme le coeur sans convertir le soin excedentaire")
	heros.stats.pv = 40.0
	heros.position = Vector2(700, 300)
	collecte._physics_process(0.0)
	_verifier(is_equal_approx(heros.stats.pv, 52.0), "Ramassage le long du deplacement : 8 % PV max fois soin_mult")
	_verifier(is_zero_approx(heros.stats.soin_restant), "Le soin garanti ne consomme pas le budget des passifs")
	var derniere_mort: Array[int] = [9]
	collecte._indices = derniere_mort
	_abattre(collecte, Vector2(550, 300))
	salle.blocs = [Rect2(510, 200, 20, 200)]
	heros.position = Vector2(490, 300)
	collecte._position_precedente = heros.position
	collecte._physics_process(0.0)
	_verifier(collecte.nombre_au_sol() == 1, "Pas de collecte a travers un obstacle")
	heros.stats.pv = 0.0
	var mort_apres_heros: Array[int] = [10]
	collecte._indices = mort_apres_heros
	_abattre(collecte, Vector2(550, 300))
	_verifier(collecte.nombre_au_sol() == 1, "Une mort ennemie tardive ne cree pas de soin apres la mort du heros")
	heros.position = Vector2(550, 300)
	collecte._physics_process(0.0)
	collecte.ramasser_avant_transition()
	_verifier(is_zero_approx(heros.stats.pv), "Un coeur ne ressuscite jamais le heros mort")
	_verifier(int(bilan["gouttes"]) == 0 and int(bilan["soins"]) == 2, "La mort du heros interdit toute nouvelle recompense")
	heros.stats.pv = 40.0
	collecte._physics_process(0.0)
	_verifier(is_equal_approx(heros.stats.pv, 40.0), "Collecte arretee sans effet dans la salle suivante")
	salle.free()
	heros.free()

func _verifier_transition() -> void:
	for cas: Dictionary in CAS_COEURS:
		var heros := _heros()
		var salle := SalleTest.new()
		root.add_child(salle)
		var collecte := _creer_collecte(heros, salle)
		var deux_sur_boss: Array[int] = [1, 1]
		collecte._indices = deux_sur_boss
		for _invocation in 12: _abattre(collecte, Vector2(500, 300), true)
		_abattre(collecte, Vector2(500, 300))
		for _invocation in 12: _abattre(collecte, Vector2(500, 300), true)
		_verifier(collecte.nombre_au_sol() == 2, "Les invocations n'ajoutent aucun coeur convertible au quota du boss")
		heros.stats.pv = float(cas["pv"])
		var bilan := _suivre_collecte(collecte)
		# Les callbacks de transition peuvent redemander la collecte immediatement.
		collecte.ramasse.connect(func(_soin: float) -> void: collecte.ramasser_avant_transition())
		collecte.gouttes_gagnees.connect(func(_montant: int) -> void: collecte.ramasser_avant_transition())
		collecte.ramasser_avant_transition()
		var contexte := "Transition a %.1f PV" % float(cas["pv"])
		_verifier(is_equal_approx(heros.stats.pv, float(cas["pv_fin"])), "%s : soin attendu" % contexte)
		_verifier(int(bilan["soins"]) == int(cas["soins"]), "%s : chaque coeur soigne individuellement" % contexte)
		_verifier(is_equal_approx(float(bilan["soin"]), float(cas["pv_fin"]) - float(cas["pv"])), "%s : aucun soin au-dela des PV manquants" % contexte)
		_verifier(int(bilan["conversions"]) == int(cas["conversions"]), "%s : seuls les coeurs inutilises sont convertis" % contexte)
		_verifier(int(bilan["gouttes"]) == int(cas["conversions"]) * SOINS.GOUTTES_PAR_COEUR_INUTILISE, "%s : montant centralise de Gouttes" % contexte)
		_verifier(collecte.nombre_au_sol() == (2 if float(cas["pv"]) <= 0.0 else 0), "%s : les coeurs traites sont retires" % contexte)
		var apres := bilan.duplicate()
		collecte.ramasser_avant_transition()
		collecte._physics_process(0.0)
		_verifier(bilan == apres and is_equal_approx(heros.stats.pv, float(cas["pv_fin"])), "%s : aucun effet lors d'un second appel" % contexte)
		salle.free()
		heros.free()

func _verifier_bords() -> void:
	var heros := _heros()
	var salle := SalleTest.new()
	root.add_child(salle)
	salle.forme = PackedVector2Array([Vector2(0, 0), Vector2(1000, 0), Vector2(1000, 1000)])
	var collecte := _creer_collecte(heros, salle)
	var indices: Array[int] = [1, 1]
	collecte._indices = indices
	_abattre(collecte, Vector2(500, 490))
	for point: Vector2 in collecte.positions_au_sol():
		_verifier(Geometry2D.is_point_in_polygon(point, salle.forme), "Le double depot respecte un contour non rectangulaire")
	salle.free()
	heros.free()

func _verifier_mine() -> void:
	var heros := _heros()
	var salle := SalleTest.new()
	root.add_child(salle)
	var collecte := _creer_collecte(heros, salle, true)
	var nombre_intervalles := ceili(Reglages.MINE_DUREE / SOINS.MINE_INTERVALLE_QUOTA)
	for intervalle in nombre_intervalles:
		collecte.avancer_mine(intervalle * SOINS.MINE_INTERVALLE_QUOTA, Reglages.MINE_DUREE)
		var avant := int(collecte.nombre_au_sol())
		var quota := (collecte._indices as Array[int]).size()
		for _mort in SOINS.MINE_MORTS_CANDIDATES:
			_abattre(collecte, Vector2(500, 300))
		for _invocation in 20: _abattre(collecte, Vector2(500, 300), true)
		_verifier(collecte.nombre_au_sol() - avant == quota and quota <= 2, "Mine : quota au plus deux par intervalle")
	var maximum := int(collecte.nombre_au_sol())
	for temps in [Reglages.MINE_DUREE, Reglages.MINE_DUREE * 2.0, Reglages.MINE_DUREE * 100.0]:
		collecte.avancer_mine(temps, Reglages.MINE_DUREE)
		for _mort in 100: _abattre(collecte, Vector2(500, 300))
	_verifier(collecte.nombre_au_sol() == maximum and maximum <= nombre_intervalles * 2, "Attendre le boss ne renouvelle jamais les coeurs")
	salle.free()
	heros.free()

func _verifier_fin_salle(mode: String, numero: int, cas: Dictionary) -> void:
	_jeu.demarrer_run(927, numero, 0, mode)
	var heros := _heros()
	heros.add_to_group("heros")
	heros.stats.pv = float(cas["pv"])
	var salle: Node2D = load("res://scripts/monde/salle.gd").new()
	root.add_child(salle)
	salle.demarrer(numero, Rect2(0, 0, 1000, 1400))
	salle.set_process(false)
	salle._terrain.set_physics_process(false)
	for apparition in get_nodes_in_group("apparitions_ennemis"): apparition.annuler()
	salle._vagues = [["boss_test"]]
	salle._vague_courante = 0
	salle._attente_vague = -1.0
	var deux_sur_boss: Array[int] = [1, 1]
	salle._collecte_soins._indices = deux_sur_boss
	salle._collecte_soins.set_physics_process(false)
	var bilan := _suivre_collecte(salle._collecte_soins)
	var resultat := {"terminee": false, "pv": 0.0, "gouttes": 0}
	salle.terminee.connect(func() -> void:
		resultat["terminee"] = true
		resultat["pv"] = heros.stats.pv
		resultat["gouttes"] = int(bilan["gouttes"]))
	var boss := EnnemiTest.new()
	salle.add_child(boss)
	boss.add_to_group("boss")
	boss.add_to_group("ennemis")
	salle._sur_mort_ennemi(boss, Vector2(500, 300), Color.WHITE)
	boss.remove_from_group("ennemis")
	boss.queue_free()
	_verifier(salle._collecte_soins.nombre_au_sol() == 2, "%s : vraie apparition au sol sur la derniere mort" % mode)
	await create_timer(Reglages.XP_RAMASSAGE_DUREE + 0.15).timeout
	if mode == "grimoire" and numero == 1:
		_verifier(salle.portail_ouvert() and not bool(resultat["terminee"]), "La salle normale attend son portail")
		_verifier(salle._collecte_soins.nombre_au_sol() == 2, "Les coeurs restent au sol apres ouverture du portail")
		salle._sur_corps_dans_portail(heros)
	var contexte := "%s salle %d a %.1f PV" % [mode, numero, float(cas["pv"])]
	_verifier(bool(resultat["terminee"]) and is_equal_approx(float(resultat["pv"]), float(cas["pv_fin"])), "%s : soin recu avant la transition" % contexte)
	_verifier(int(resultat["gouttes"]) == int(cas["conversions"]) * SOINS.GOUTTES_PAR_COEUR_INUTILISE, "%s : conversion recue avant la transition" % contexte)
	_verifier(int(bilan["soins"]) + int(bilan["conversions"]) == 2, "%s : chaque coeur donne exactement une recompense" % contexte)
	_verifier(is_zero_approx(heros.stats.soin_restant), "%s : budget passif inchange a la transition" % mode)
	salle.free()
	heros.free()
	await process_frame

func _verifier_menu() -> void:
	_reglages.tutoriel_vu = false
	_reglages.specialisation = ""
	var menu: Control = load("res://scenes/menu.tscn").instantiate()
	root.add_child(menu)
	await process_frame
	await process_frame
	_verifier(not bool(menu._lancement), "Un compte neuf reste au menu sans tutoriel automatique")
	_verifier(not menu.has_method("_demarrer_premiers_pas"), "Le demarrage du tutoriel est retire")
	menu._lancer_mode("grimoire", Chapitres.par_index(0))
	_verifier(is_instance_valid(menu._superposition) and not bool(menu._lancement), "La classe se choisit avant la premiere vraie partie")
	menu.free()
	await process_frame

func _verifier_heros() -> void:
	var script_run: GDScript = load("res://scripts/run.gd")
	_verifier(script_run.can_instantiate(), "Run se compile sans module tutoriel")
	var heros: CharacterBody2D = load("res://scenes/heros.tscn").instantiate()
	root.add_child(heros)
	heros.set_process(false)
	heros.set_physics_process(false)
	heros.bouclier = 0
	heros._invulnerable = 0.0
	var avant := float(heros.stats.pv)
	heros.recevoir_degats(10.0)
	_verifier(float(heros.stats.pv) < avant, "Le nouveau heros subit normalement les degats")
	_verifier(not heros.has_method("configurer_apprentissage") and heros.peut_tirer(), "Aucune protection ni suspension de tir de tutoriel")
	heros.free()
