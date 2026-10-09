extends Node

# Orchestrateur des salles et des choix de run. La campagne construit son
# melange en dix niveaux et trois paliers majeurs ; les modes annexes conservent leur propre cadence.
# Le heros lui appartient, pas a la salle : ses PV et son inventaire persistent.

const SALLE := preload("res://scenes/salle.tscn")
const HEROS := preload("res://scenes/heros.tscn")
const DRAFT := preload("res://ui/draft.tscn")
const FIN := preload("res://ui/fin_de_run.tscn")
const HUD := preload("res://ui/hud.tscn")
const JOYSTICK := preload("res://ui/joystick.tscn")
const PAUSE := preload("res://ui/pause.tscn")
const VOILE_TRANSITION := preload("res://scripts/interface/voile_transition.gd")

var _fond: Node2D
var _salle: Node2D
var _heros: CharacterBody2D
var _effets: Node2D
var _hud: Control
var _joystick: Control
var _couche: CanvasLayer
var _panneau: Control
var _limites := Rect2()
var _terminee := false
var _temps_dans_la_salle := 0.0
var _musique_minuterie := 0.0
var _compteur_moisson := 0
var _niveaux_en_attente := 0
var _familier: Node2D
var _fin_salle_en_attente := false
var _camera: Camera2D
var _voile_salle: VOILE_TRANSITION
var _transition_salle := false
var _compteur_attaques_objet := 0
var _trauma := 0.0
var _gel_en_cours := false

func _ready() -> void:
	if OS.get_name() == "Android":
		get_tree().set_auto_accept_quit(false)
	var arguments := OS.get_cmdline_user_args()
	Jeu.mode_auto = "--auto" in arguments
	# Une sonde ne doit jamais ecrire dans la sauvegarde du joueur. Vingt runs
	# automatiques gonflaient ses compteurs, sa monnaie et ses deblocages, et
	# rendaient au passage toute mesure suivante ininterpretable.
	if Jeu.mode_auto:
		ReglagesJoueur.sauvegarde_active = false
	# --vierge mesure ce que vit un nouveau compte. Sans lui, une sauvegarde en
	# Mode dev fait croire a une descente sans Maitrises alors qu'elles sont
	# toutes au rang maximal.
	if "--vierge" in arguments:
		_remettre_progression_a_zero()
	# --maxe simule un compte entierement farme. --intermediaire represente un
	# joueur arrive au dernier Monde avec une progression correcte mais loin du
	# maximum : c'est le profil critique pour verifier que la campagne reste finie.
	if "--maxe" in arguments:
		_doter_progression_maximale()
	elif "--intermediaire" in arguments:
		_doter_progression_intermediaire()
	var mode_argument := _texte_argument(arguments, "--mode=")
	Jeu.demarrer_run(_valeur_argument(arguments, "--graine="), maxi(1, _valeur_argument(arguments, "--salle=")),
		maxi(0, _valeur_argument(arguments, "--chapitre=") - 1) if _valeur_argument(arguments, "--chapitre=") > 0 else ReglagesJoueur.chapitre_choisi,
		mode_argument if not mode_argument.is_empty() else ReglagesJoueur.mode_run_choisi)
	# --dote=N remplit l'inventaire : c'est ce qui permet d'aller regarder
	# un choix epique ou le boss sans rejouer huit salles a chaque essai.
	var dote := _valeur_argument(arguments, "--dote=")
	if dote > 0:
		# Sans remise : l'inventaire d'une vraie run ne contient jamais deux fois
		# le meme reactif, et un outil qui ment sur l'etat teste ne sert a rien.
		var candidats := CatalogueReactifs.ids()
		for i in mini(dote, candidats.size()):
			var index := Jeu.rng.randi_range(0, candidats.size() - 1)
			Jeu.ajouter_reactif(candidats[index])
			candidats.remove_at(index)
	Jeu.run_terminee.connect(_sur_run_terminee)

	_camera = Camera2D.new()
	_camera.process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	_camera.enabled = true
	add_child(_camera)
	_calculer_limites()
	get_tree().get_root().size_changed.connect(_calculer_limites)

	_fond = Node2D.new()
	_fond.set_script(load("res://scripts/presentation/fond.gd"))
	add_child(_fond)

	_salle = SALLE.instantiate()
	add_child(_salle)
	_salle.ennemi_abattu.connect(_sur_ennemi_abattu)
	_salle.experience_ramassee.connect(_sur_experience_ramassee)
	_salle.sortie_ouverte.connect(_sur_portail_ouvert)

	_heros = HEROS.instantiate()
	add_child(_heros)
	_heros.limites = _limites
	_heros.tir_demande.connect(_sur_tir_heros)
	_heros.touchee.connect(_sur_heros_touche)
	_heros.bouclier_brise.connect(_sur_bouclier_brise)
	_heros.morte.connect(func(): Jeu.terminer_run(false))
	_familier = preload("res://scripts/combat/familier.gd").new()
	add_child(_familier)
	_familier.tir_demande.connect(_tirer_familier)

	_effets = Node2D.new()
	_effets.set_script(load("res://scripts/presentation/effets.gd"))
	add_child(_effets)
	_effets.secousse_demandee.connect(_secouer)
	_effets.arret_demande.connect(_figer)


	_couche = CanvasLayer.new()
	add_child(_couche)
	var vignette := ColorRect.new()
	vignette.name = "VignetteCombat"
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.material = ShaderMaterial.new()
	(vignette.material as ShaderMaterial).shader = preload("res://shaders/vignette_combat.gdshader")
	_couche.add_child(vignette)
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hud = HUD.instantiate()
	_couche.add_child(_hud)
	_hud.pause_demandee.connect(func() -> void:
		if not _terminee and _panneau == null:
			_ouvrir_pause())
	_joystick = JOYSTICK.instantiate()
	_couche.add_child(_joystick)
	_joystick.intention_changee.connect(_sur_intention)
	if "--visuel-2d" in OS.get_cmdline_user_args():
		var cadre_retro := Control.new()
		cadre_retro.set_script(load("res://scripts/interface/cadre_retro.gd"))
		_couche.add_child(cadre_retro)
	_construire_voile_salle()

	if Jeu.mode_auto:
		# Le bot appartient aux sondes et n'est volontairement pas exporte dans
		# l'APK. Le charger uniquement quand une sonde PC le demande permet a la
		# scene de combat mobile de rester autonome.
		var script_bot := load("res://sondes/bot.gd")
		if script_bot != null:
			var bot := Node.new()
			bot.set_script(script_bot)
			bot.bavard = "--bavard" in arguments
			add_child(bot)

	_entrer_dans_la_salle()
	if DisplayServer.get_name() != "headless" and not "--visuel-2d" in arguments:
		var monde: Node3D = load("res://scenes/3d/monde_3d.tscn").instantiate()
		add_child(monde)
		monde.relier(_salle, _heros, _fond, _familier)
	_animer_entree_salle()
	# Arguments de capture reserves au controle visuel automatise des panneaux.
	if "--ouvrir-pause" in arguments:
		call_deferred("_ouvrir_pause")
	elif "--ouvrir-pause-ameliorations" in arguments:
		call_deferred("_ouvrir_pause_ameliorations_capture")
	elif "--ouvrir-amelioration" in arguments:
		Jeu.niveau_run = maxi(1, Jeu.niveau_run)
		_niveaux_en_attente = 1
		call_deferred("_ouvrir_recompense_etage")
	elif "--ouvrir-portail" in arguments:
		call_deferred("_preparer_capture_portail")
	Capture.programmer(self)

func _remettre_progression_a_zero() -> void:
	ReglagesJoueur.sauvegarde_active = false
	# Le Mode dev ouvre toutes les Maitrises au rang maximal : le laisser actif
	# ferait passer un compte complet pour un compte neuf.
	ReglagesJoueur.mode_dev = false
	ReglagesJoueur.rangs_competences.clear()
	ReglagesJoueur.rangs_passifs.clear()
	ReglagesJoueur.passifs_equipes.clear()
	ReglagesJoueur.objets.clear()
	ReglagesJoueur.forge_niveaux.clear()
	ReglagesJoueur.equipements = {"anneau": "", "bracelet": "", "collier": ""}

func _doter_progression_intermediaire() -> void:
	# Profil de fin de campagne : offense rang 8 et defense rang 2, ancien set
	# au palier de familier planifie et passifs rang 1. Il teste la courbe
	# sans le plafond des Maitrises et des passifs.
	ReglagesJoueur.sauvegarde_active = false
	ReglagesJoueur.mode_dev = false
	ReglagesJoueur.niveau_compte = 22
	ReglagesJoueur.rangs_competences.clear()
	for branche in ["Offensif", "Défensif"]:
		for id in ArbreCompetences.BRANCHES[branche]:
			ReglagesJoueur.rangs_competences[str(id)] = 8 if branche == "Offensif" else 2
	ReglagesJoueur.rangs_passifs.clear()
	for id in ["vigueur", "vitalite", "moisson_vitale", "celerite"]:
		ReglagesJoueur.rangs_passifs[id] = 1
	ReglagesJoueur.passifs_equipes = ["vigueur", "vitalite", "moisson_vitale", "celerite"]
	# Simule les deblocages accessibles a la fin de la campagne.
	ReglagesJoueur.meilleures_par_chapitre.clear()
	for chapitre in range(Chapitres.nombre() - 1):
		ReglagesJoueur.meilleures_par_chapitre[str(chapitre)] = Reglages.SALLES_PAR_RUN
	var anciens: Array = CatalogueObjets.IDS_PAR_MONDE[0]
	ReglagesJoueur.objets.clear()
	ReglagesJoueur.forge_niveaux.clear()
	for id in anciens:
		ReglagesJoueur.objets.append(str(id))
		ReglagesJoueur.forge_niveaux[str(id)] = Reglages.FORGE_NIVEAU_MAX
	ReglagesJoueur.equipements = {"anneau": str(anciens[0]),
		"bracelet": str(anciens[1]), "collier": str(anciens[2])}

func _doter_progression_maximale() -> void:
	# Outil de sonde : la vraie sauvegarde du joueur ne doit jamais recevoir ca.
	ReglagesJoueur.sauvegarde_active = false
	ReglagesJoueur.mode_dev = false
	# Le niveau de compte porte le socle de statistiques : un compte entierement
	# farme a forcement monte en niveau, l'oublier fausse toute la mesure.
	ReglagesJoueur.niveau_compte = Reglages.NIVEAU_REFERENCE_FIN
	for id in ArbreCompetences.NOEUDS:
		ReglagesJoueur.rangs_competences[id] = ArbreCompetences.rangs(str(id))
	for id in Passifs.CATALOGUE:
		ReglagesJoueur.rangs_passifs[id] = Passifs.RANG_MAX
	# Un compte maxe choisit un loadout coherent ; prendre les premieres cles du
	# Dictionary rendait la sonde artificiellement fragile et mesurait l'ordre du
	# catalogue plutot que le plafond reel de progression.
	ReglagesJoueur.passifs_equipes = ["vigueur", "vitalite", "rempart_initial", "moisson_vitale"]
	var derniers: Array = CatalogueObjets.IDS_PAR_MONDE[CatalogueObjets.IDS_PAR_MONDE.size() - 1]
	ReglagesJoueur.equipements = {"anneau": str(derniers[0]),
		"bracelet": str(derniers[1]), "collier": str(derniers[2])}
	for id in derniers:
		if not str(id) in ReglagesJoueur.objets:
			ReglagesJoueur.objets.append(str(id))
		ReglagesJoueur.forge_niveaux[str(id)] = Reglages.FORGE_NIVEAU_MAX

func _ouvrir_pause_ameliorations_capture() -> void:
	_ouvrir_pause()
	await get_tree().process_frame
	if _panneau != null:
		_panneau._ouvrir_ameliorations()

func _preparer_capture_portail() -> void:
	# Outil de controle visuel uniquement : aucune partie normale ne passe ici.
	for ennemi in get_tree().get_nodes_in_group("ennemis"):
		if is_instance_valid(ennemi):
			ennemi.queue_free()
	await get_tree().process_frame
	if _salle != null:
		_salle._ouvrir_portail()

# En mode auto, une salle qui ne se termine pas est un blocage, pas une
# difficulte. On veut le savoir avec l'etat de la salle, pas par un silence.
func _physics_process(delta: float) -> void:
	if not _terminee and _panneau == null:
		Jeu.images_de_jeu += 1
		if not _transition_salle and is_instance_valid(_familier):
			_familier.avancer(delta)

func _process(delta: float) -> void:
	_suivre_heros()
	_appliquer_secousse(delta)
	_musique_minuterie -= delta
	if _musique_minuterie <= 0.0 and not _terminee and _panneau == null:
		_musique_minuterie = 0.35
		if Jeu.est_boss_courant():
			Sons.musique_boss()
		else:
			var menaces := get_tree().get_nodes_in_group("ennemis").size()
			Sons.musique_combat(clampf(float(menaces) / 7.0, 0.25, 1.0))
	if not Jeu.mode_auto or _terminee or _panneau != null:
		return
	_temps_dans_la_salle += delta
	var delai_blocage := Reglages.MINE_DUREE + 120.0 if Jeu.mode_run == "mine" else 120.0
	if _temps_dans_la_salle < delai_blocage:
		return
	var restants := get_tree().get_nodes_in_group("ennemis")
	var ou := ""
	for e in restants:
		if is_instance_valid(e):
			ou += "%s(pv=%d) " % [str(e.global_position.round()), roundi(e.pv)]
	print("BLOCAGE salle %d apres %ds : ennemis restants=%d %s heros=%s tirs=%d touches=%d murs=%d perdus=%d" % [
		Jeu.salle_courante, roundi(_temps_dans_la_salle), restants.size(), ou,
		str(_heros.global_position.round()), Jeu.tirs_emis, Jeu.tirs_touches,
		Jeu.tirs_dans_un_mur, Jeu.tirs_perdus])
	Jeu.terminer_run(false)

func _valeur_argument(arguments: PackedStringArray, prefixe: String) -> int:
	for argument in arguments:
		if argument.begins_with(prefixe):
			return int(argument.substr(prefixe.length()))
	return 0

func _texte_argument(arguments: PackedStringArray, prefixe: String) -> String:
	for argument in arguments:
		if argument.begins_with(prefixe):
			return argument.substr(prefixe.length())
	return ""

func _appliquer_secousse(delta: float) -> void:
	if _camera == null:
		return
	_trauma = maxf(0.0, _trauma - delta * 1.8)
	var energie := _trauma * _trauma
	if energie <= 0.0001:
		_camera.offset = Vector2.ZERO
		return
	var temps := Time.get_ticks_msec() * 0.001
	_camera.offset = Vector2(sin(temps * 61.0) + sin(temps * 23.0) * 0.5,
		cos(temps * 57.0) + cos(temps * 19.0) * 0.5) * 16.0 * energie

func _calculer_limites() -> void:
	var taille := get_viewport().get_visible_rect().size
	if Jeu.mode_run == "mine":
		var zoom := Reglages.MINE_CAMERA_ZOOM
		var taille_monde := taille / zoom
		var haut_mine := (Reglages.ARENE_HAUT + Ecran.marge_haute()) / zoom
		var bas_mine := (Reglages.ARENE_BAS + Ecran.marge_basse()) / zoom
		_limites = Rect2(
			Vector2(Reglages.ARENE_MARGE_LATERALE / zoom, haut_mine),
			Vector2(taille_monde.x - 2.0 * Reglages.ARENE_MARGE_LATERALE / zoom,
				maxf(850.0, taille_monde.y - haut_mine - bas_mine)))
		if _camera != null:
			_camera.zoom = Vector2.ONE * zoom
			_camera.global_position = taille_monde / 2.0
		if _heros != null:
			_heros.limites = _limites
		return
	_limites = Rect2(Vector2(Reglages.ARENE_MARGE_LATERALE,Reglages.ARENE_HAUT),FormesSalles.taille(Jeu.salle_courante, Jeu.chapitre, Jeu.graine, Jeu.mode_run))
	if _camera != null:
		_camera.zoom = Vector2.ONE*Reglages.ARENE_CAMERA_ZOOM
	if _heros != null:
		_heros.limites = _limites

func _suivre_heros() -> void:
	if Jeu.mode_run == "mine" or _camera == null or _heros == null: return
	var vue := get_viewport().get_visible_rect().size / _camera.zoom
	var suivi := _heros.get_node_or_null("SuiviVisuel3D")
	# Camera et modele utilisent le meme instant entre deux pas de physique.
	if suivi != null:
		_camera.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		_camera.process_callback = Camera2D.CAMERA2D_PROCESS_IDLE
	var position_visuelle: Vector2 = suivi.position_affichee() if suivi != null else _heros.global_position
	var visee := position_visuelle-Vector2(0,vue.y*0.13)
	var minimum := _limites.position+vue*0.5-Vector2(70,Reglages.ARENE_HAUT/_camera.zoom.y)
	var maximum := _limites.end-vue*0.5+Vector2(70,Reglages.ARENE_BAS/_camera.zoom.y)
	# Sur un ecran allonge, la vue peut depasser la salle : centrer cet axe
	# plutot que passer des bornes inversees a clampf.
	_camera.global_position = Vector2(
		clampf(visee.x,minimum.x,maximum.x) if minimum.x <= maximum.x else _limites.get_center().x,
		clampf(visee.y,minimum.y,maximum.y) if minimum.y <= maximum.y else _limites.get_center().y)
	_camera.force_update_scroll()

func _entrer_dans_la_salle() -> void:
	for enfant in _salle.get_children():
		enfant.queue_free()
	_calculer_limites()
	_fond.preparer(_limites, Jeu.salle_courante)
	_salle.effets = _effets
	if not _salle.terminee.is_connected(_sur_salle_terminee):
		_salle.terminee.connect(_sur_salle_terminee)
	_heros.global_position = Vector2((_limites.position.x + _limites.end.x) / 2.0, _limites.end.y - 120.0)


	_heros.preparer_nouvelle_salle()
	var familier_id := ReglagesJoueur.familier_equipe_effectif()
	_suivre_heros()


	_hud.rafraichir()
	_temps_dans_la_salle = 0.0
	if Jeu.mode_auto:
		print("salle %d/%d (%s) : inventaire=%d pv=%d" % [Jeu.salle_courante, Jeu.salles_du_chapitre(),
			Jeu.nom_run(), Jeu.inventaire.size(), roundi(_heros.stats.pv)])
	_salle.demarrer(Jeu.salle_courante, _limites)
	_familier.preparer(_salle, familier_id, Jeu.graine + Jeu.salle_courante)

func _sur_salle_terminee() -> void:
	if _terminee or _fin_salle_en_attente:
		return
	if Jeu.salle_courante >= Jeu.salles_du_chapitre():
		Jeu.terminer_run(true)
		return
	_neutraliser_deplacement()
	# Le dernier ennemi et le rattrapage partagent la meme file de choix.
	# La transition attend que tous les niveaux soient effectivement choisis.
	_fin_salle_en_attente = true
	_niveaux_en_attente += Jeu.garantir_niveaux_fin_salle()
	if _panneau != null:
		return
	if _niveaux_en_attente > 0:
		_ouvrir_recompense_etage()
		return
	_fin_salle_en_attente = false
	_traiter_fin_salle()

func _traiter_fin_salle() -> void:
	if Jeu.mode_run == "epreuves":
		_sur_palier_defi_termine()
		return
	if Jeu.salle_courante >= Jeu.salles_du_chapitre():
		Jeu.terminer_run(true)
		return
	_avancer_salle()

func _avancer_salle() -> void:
	if _transition_salle:
		return
	_transition_salle = true
	_heros.definir_intention(Vector2.ZERO, 0.0)
	_joystick.annuler()
	_voile_salle.visible = true
	_voile_salle.mouse_filter = Control.MOUSE_FILTER_STOP
	_voile_salle.presenter_etage(Jeu.chapitre_courant(), Jeu.salle_courante + 1, Jeu.salles_du_chapitre(), Jeu.mode_run)
	var fermeture := create_tween()
	fermeture.set_trans(Tween.TRANS_QUINT)
	fermeture.set_ease(Tween.EASE_IN)
	fermeture.tween_property(_voile_salle, "modulate:a", 1.0,
		0.12 if ReglagesJoueur.effets_reduits else 0.26)
	await fermeture.finished
	Jeu.salle_courante += 1
	_entrer_dans_la_salle()
	await get_tree().create_timer(0.10 if ReglagesJoueur.effets_reduits else 0.32).timeout
	var ouverture := create_tween()
	ouverture.set_trans(Tween.TRANS_QUINT)
	ouverture.set_ease(Tween.EASE_OUT)
	ouverture.tween_property(_voile_salle, "modulate:a", 0.0,
		0.16 if ReglagesJoueur.effets_reduits else 0.42)
	await ouverture.finished
	_voile_salle.visible = false
	_voile_salle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_salle = false

func _construire_voile_salle() -> void:
	_voile_salle = VOILE_TRANSITION.new()
	_voile_salle.mouse_filter = Control.MOUSE_FILTER_STOP
	_voile_salle.process_mode = Node.PROCESS_MODE_ALWAYS
	_couche.add_child(_voile_salle)
	_voile_salle.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _animer_entree_salle() -> void:
	_voile_salle.presenter_etage(Jeu.chapitre_courant(), Jeu.salle_courante, Jeu.salles_du_chapitre(), Jeu.mode_run)
	_voile_salle.visible = true
	_voile_salle.modulate.a = 1.0
	await get_tree().create_timer(0.10 if ReglagesJoueur.effets_reduits else 0.38).timeout
	var ouverture := create_tween()
	ouverture.set_trans(Tween.TRANS_QUINT)
	ouverture.set_ease(Tween.EASE_OUT)
	ouverture.tween_property(_voile_salle, "modulate:a", 0.0,
		0.16 if ReglagesJoueur.effets_reduits else 0.52)
	await ouverture.finished
	_voile_salle.visible = false
	_voile_salle.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _ouvrir_recompense_etage() -> void:
	if _terminee or _panneau != null or _niveaux_en_attente <= 0:
		return
	_neutraliser_deplacement()
	get_tree().paused = true
	Sons.musique_calme()
	_panneau = DRAFT.instantiate()
	_panneau.campagne = Jeu.mode_run in ["grimoire", "mine"]
	_panneau.etage_recompense = Jeu.niveau_run - _niveaux_en_attente + 1
	_panneau.process_mode = Node.PROCESS_MODE_ALWAYS
	_couche.add_child(_panneau)
	_panneau.termine.connect(func() -> void:
		_panneau.queue_free()
		_panneau = null
		_heros.recalculer()
		_hud.rafraichir()
		get_tree().paused = false
		_niveaux_en_attente = maxi(0, _niveaux_en_attente - 1)
		if _niveaux_en_attente > 0:
			_ouvrir_recompense_etage()
		else:
			Sons.musique_combat(0.35)
			if _fin_salle_en_attente:
				_fin_salle_en_attente = false
				_traiter_fin_salle())

func _sur_palier_defi_termine() -> void:
	if Jeu.salle_courante >= Jeu.salles_du_chapitre():
		Jeu.terminer_run(true)
		return
	_neutraliser_deplacement()
	get_tree().paused = true
	_panneau = DRAFT.instantiate()
	_panneau.etage_recompense = Jeu.salle_courante
	_panneau.process_mode = Node.PROCESS_MODE_ALWAYS
	_couche.add_child(_panneau)
	_panneau.termine.connect(func() -> void:
		_panneau.queue_free()
		_panneau = null
		_heros.recalculer()
		get_tree().paused = false
		_avancer_salle())

func _ouvrir_pause() -> void:
	if _panneau != null: return
	_neutraliser_deplacement()
	get_tree().paused = true
	Sons.musique_calme()
	_panneau = PAUSE.instantiate()
	_panneau.process_mode = Node.PROCESS_MODE_ALWAYS
	_couche.add_child(_panneau)
	_panneau.termine.connect(_fermer_pause)

func _fermer_pause() -> void:
	if _panneau == null:
		return
	_panneau.queue_free()
	_panneau = null
	get_tree().paused = false
	if Jeu.est_boss_courant():
		Sons.musique_boss()
	else:
		Sons.musique_combat(0.5)

func _notification(quoi: int) -> void:
	if quoi in [NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT]:
		if is_node_ready() and not _terminee and not Jeu.mode_auto and not Capture.demandee() \
				and _panneau == null:
			_ouvrir_pause()
		return
	if quoi != NOTIFICATION_WM_GO_BACK_REQUEST or _terminee:
		return
	if _panneau != null and _panneau.scene_file_path == "res://ui/pause.tscn":
		_fermer_pause()
	elif _panneau == null:
		_ouvrir_pause()

func _sur_intention(direction: Vector2, intensite: float) -> void:
	if _heros != null and not Jeu.mode_auto and _panneau == null and not get_tree().paused \
			and not _transition_salle and not _voile_salle.visible:
		_heros.definir_intention(direction, intensite)

func _neutraliser_deplacement() -> void:
	_joystick.annuler()
	_heros.definir_intention(Vector2.ZERO, 0.0)
	_heros.velocity = Vector2.ZERO

func _sur_tir_heros(tir_courant: Tir, origine: Vector2, direction: Vector2) -> void:
	if not _heros.peut_tirer(): return
	var tir_effectif := tir_courant.copie()
	_heros.enregistrer_attaque_objet()
	tir_effectif.degats = _heros.degats_finaux(tir_effectif.degats, "baguette")
	tir_effectif.critique = _heros.dernier_critique
	if "indelebile" in tir_effectif.drapeaux:
		var cible_initiale := _ennemi_plus_proche(origine)
		if cible_initiale != null:
			tir_effectif.cible_verrouillee = cible_initiale.get_instance_id()
	var passifs := ReglagesJoueur.passifs_equipes_effectifs()
	if passifs.has("sang_froid"):
		tir_effectif.effets.append("sang_froid_%d" % Passifs.rang_passif(passifs, "sang_froid"))
	if "cinquieme_impact" in ReglagesJoueur.effets_objets_effectifs():
		_compteur_attaques_objet += 1
		if _compteur_attaques_objet >= EffetsBijoux.IMPACT_ATTAQUES:
			_compteur_attaques_objet = 0
			tir_effectif.degats *= EffetsBijoux.IMPACT_MULTIPLICATEUR
	tir_effectif.degats *= tir_effectif.degats_finaux_projectile_mult
	_salle.tirer(tir_effectif, origine, direction, false)

func _tirer_familier(id: String, origine: Vector2, direction: Vector2) -> void:
	if _terminee or _transition_salle or _panneau != null: return
	var tir := Tir.new()
	CatalogueFamiliers.configurer_tir(tir, id, _limites.size)
	var attaque := CatalogueFamiliers.attaque_combat(id, ReglagesJoueur.niveau_familier(id),
		_heros.stats.bonus_attaque, Mods.facteur_attaque_run(Jeu.mods()))
	tir.degats = _heros.degats_finaux(attaque, "familier", false)
	_salle.tirer(tir, origine, direction, false)
	get_tree().call_group("familiers_visuels", "declencher_tir", direction)

func _ennemi_plus_proche(origine: Vector2) -> Node2D:
	var resultat: Node2D = null
	var distance := INF
	for ennemi in get_tree().get_nodes_in_group("ennemis"):
		if not is_instance_valid(ennemi):
			continue
		var d := origine.distance_squared_to(ennemi.global_position)
		if d < distance:
			distance = d
			resultat = ennemi
	return resultat

func _sur_heros_touche(position: Vector2) -> void:
	_effets.impact(position, Palette.DANGER, 1.6)
	_effets.degats_subis(position, _heros.dernier_degat_recu)
	_hud.impact_degats()
	_secouer(0.55)
	_figer(0.05)

# Secousse « trauma » : l'amplitude suit le carre de l'energie restante. La
# camera 2D entraine aussi le rendu 3D, cadre sur sa transformation.
func _secouer(force: float) -> void:
	if not ReglagesJoueur.secousses_ecran or Jeu.mode_auto:
		return
	_trauma = clampf(_trauma + force * (0.5 if ReglagesJoueur.effets_reduits else 1.0), 0.0, 1.0)

# Micro-arret sur les coups marquants : quelques centiemes de seconde figes.
func _figer(duree: float) -> void:
	if Jeu.mode_auto or ReglagesJoueur.effets_reduits or Capture.demandee() or _gel_en_cours:
		return
	_gel_en_cours = true
	Engine.time_scale = 0.06
	await get_tree().create_timer(duree, true, false, true).timeout
	Engine.time_scale = 1.0
	_gel_en_cours = false

# Un micro-arret interrompu par un changement de scene ne doit jamais laisser
# le jeu ralenti.
func _exit_tree() -> void:
	Engine.time_scale = 1.0

func _sur_portail_ouvert() -> void:
	if Jeu.mode_run == "grimoire":
		_hud.annoncer("SALLE NETTOYÉE !", "Le portail est ouvert", "emeraude")
		Sons.jouer("salle", -9.0)

func _sur_bouclier_brise(position: Vector2) -> void:
	_effets.onde(position, 200.0, Color(0.85, 0.92, 1.0), 0.5)

func _sur_experience_ramassee(experience: int, fin_run: bool) -> void:
	if _terminee or Jeu.mode_run not in ["grimoire", "mine"]: return
	# La Mine ramasse pendant le combat ; la campagne collecte apres nettoyage.
	var niveaux_gagnes := Jeu.gagner_experience_run(experience)
	_niveaux_en_attente += niveaux_gagnes
	if niveaux_gagnes > 0 and not fin_run:
		Sons.jouer("niveau", -7.0)
	if Jeu.mode_run == "grimoire":
		_niveaux_en_attente += Jeu.garantir_niveaux_fin_salle()
	if fin_run:
		_niveaux_en_attente = 0
		return
	if _niveaux_en_attente > 0 and _panneau == null:
		_neutraliser_deplacement()
		_ouvrir_recompense_etage()

func _sur_ennemi_abattu(_experience: int) -> void:
	var passifs := ReglagesJoueur.passifs_equipes_effectifs()
	if passifs.has("moisson_vitale"):
		_compteur_moisson += 1
		if _compteur_moisson >= Passifs.seuil_moisson(passifs):
			_compteur_moisson = 0
			_heros.stats.soigner_garanti(_heros.stats.pv_max * Passifs.soin_moisson(passifs))


func _sur_run_terminee(victoire: bool) -> void:
	if _terminee:
		return
	_terminee = true
	if is_instance_valid(_panneau):
		_panneau.queue_free()
		_panneau = null
	Sons.musique_calme()
	get_tree().paused = true
	var fin := FIN.instantiate()
	fin.process_mode = Node.PROCESS_MODE_ALWAYS
	_couche.add_child(fin)
	fin.afficher(victoire, Jeu.salle_courante)
	print("run terminee : victoire=%s chapitre=%d salle atteinte=%d/%d graine=%d abattus=%d duree=%d min %02d s" % [
		victoire, Jeu.chapitre + 1, Jeu.salle_courante, Jeu.salles_du_chapitre(),
		Jeu.graine, Jeu.ennemis_abattus, int(Jeu.duree_run() / 60.0), int(Jeu.duree_run()) % 60])
