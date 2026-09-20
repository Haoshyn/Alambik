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
const VOILE_TRANSITION := preload("res://scripts/voile_transition.gd")
const APPRENTISSAGE := preload("res://scripts/apprentissage.gd")
const PassifsCombat = preload("res://scripts/passifs_combat.gd")
const ReglagesPassifs = preload("res://data/passifs_combat.gd")

var _fond: Node2D
var _salle: Node2D
var _heros: CharacterBody2D
var _effets: Node2D
var _hud: Control
var _joystick: Control
var _couche: CanvasLayer
var _panneau: Control
var _visee_active := false
var _vitesse_avant_visee := 1.0
var _limites := Rect2()
var _terminee := false
var _temps_dans_la_salle := 0.0
var _musique_minuterie := 0.0
var _recharge_sort_actif := 0.0
var _recharge_riposte := 0.0
var _charge_ultime := 0.0
var _ultimes_utilises := 0
var _delai_charge := 0.0
var _compteur_moisson := 0
var _niveaux_en_attente := 0
var _familier_minuterie := 0.0
var _meteore_minuterie := 0.0
var _zone_minuterie := 0.0
var _orbe_minuterie := 0.0
var _chaine_minuterie := 0.0
var _onde_choc_minuterie := 0.0
var _orbes_chargees := 0
var _gardien: Gardien
var _fin_salle_en_attente := false
var _camera: Camera2D
var _voile_salle: VOILE_TRANSITION
var _transition_salle := false
var _apprentissage: APPRENTISSAGE
var _passifs_combat := PassifsCombat.new()

func _ready() -> void:
	add_to_group("charge_combat")
	if OS.get_name() == "Android":
		get_tree().set_auto_accept_quit(false)
	var arguments := OS.get_cmdline_user_args()
	if "--hud-complet" in arguments:
		var actif_capture := str(Sorts.ACTIFS.keys()[0])
		var ultime_capture := str(Sorts.ULTIMES.keys()[0])
		ReglagesJoueur.sort_actif_equipe = actif_capture
		ReglagesJoueur.ultime_equipe = ultime_capture
		ReglagesJoueur.rangs_sorts[actif_capture] = Reglages.CAPACITE_RANG_MAX
		ReglagesJoueur.rangs_sorts[ultime_capture] = Reglages.CAPACITE_RANG_MAX
		_recharge_sort_actif = 3.4
		_charge_ultime = 12
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
	_fond.set_script(load("res://scripts/fond.gd"))
	add_child(_fond)

	_salle = SALLE.instantiate()
	add_child(_salle)
	_salle.ennemi_abattu.connect(_sur_ennemi_abattu)

	_heros = HEROS.instantiate()
	add_child(_heros)
	_heros.limites = _limites
	_heros.tir_demande.connect(_sur_tir_heros)
	_heros.touchee.connect(_sur_heros_touche)
	_heros.bouclier_brise.connect(_sur_bouclier_brise)
	_heros.morte.connect(func(): Jeu.terminer_run(false))

	_effets = Node2D.new()
	_effets.set_script(load("res://scripts/effets.gd"))
	add_child(_effets)


	_couche = CanvasLayer.new()
	add_child(_couche)
	_hud = HUD.instantiate()
	_couche.add_child(_hud)
	_hud.pause_demandee.connect(func() -> void:
		if not _terminee and _panneau == null:
			_ouvrir_pause())
	_hud.sort_actif_demande.connect(_lancer_sort_actif)
	_hud.ultime_demande.connect(_lancer_ultime)
	_hud.rafraichir_sorts(_recharge_sort_actif, _charge_ultime, _ultimes_utilises)
	_joystick = JOYSTICK.instantiate()
	_couche.add_child(_joystick)
	_joystick.intention_changee.connect(_sur_intention)
	_joystick.tape_rapide.connect(_sur_tape_rapide)
	if "--visuel-2d" in OS.get_cmdline_user_args():
		var cadre_retro := Control.new()
		cadre_retro.set_script(load("res://scripts/cadre_retro.gd"))
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
		monde.relier(_salle, _heros, _fond)
	_animer_entree_salle()
	if APPRENTISSAGE.disponible(arguments):
		_apprentissage = APPRENTISSAGE.new()
		add_child(_apprentissage)
		var conseils := preload("res://ui/conseils_debut.gd").new()
		_couche.add_child(conseils)
		_apprentissage.consigne_changee.connect(conseils.afficher_etape)
		_apprentissage.visibilite_changee.connect(conseils.set_visible)
		_apprentissage.termine.connect(conseils.queue_free)
		conseils.passe.connect(_apprentissage.passer)
		_apprentissage.configurer(_heros, _salle)
	# Arguments de capture reserves au controle visuel automatise des panneaux.
	if "--ouvrir-pause" in arguments:
		call_deferred("_ouvrir_pause")
	elif "--ouvrir-pause-ameliorations" in arguments:
		call_deferred("_ouvrir_pause_ameliorations_capture")
	elif "--ouvrir-amelioration" in arguments:
		Jeu.niveau_run = maxi(1, Jeu.niveau_run)
		_niveaux_en_attente = 1
		call_deferred("_ouvrir_recompense_etage")
	elif "--ouvrir-alambic" in arguments:
		call_deferred("_ouvrir_alambic_apres_salle")
	elif "--ouvrir-portail" in arguments:
		call_deferred("_preparer_capture_portail")
	Capture.programmer(self)

func _remettre_progression_a_zero() -> void:
	ReglagesJoueur.sauvegarde_active = false
	# Le Mode dev ouvre toutes les Maitrises au rang maximal : le laisser actif
	# ferait passer un compte complet pour un compte neuf.
	ReglagesJoueur.mode_dev = false
	ReglagesJoueur.rangs_competences.clear()
	ReglagesJoueur.rangs_sorts.clear()
	ReglagesJoueur.passifs_equipes.clear()
	ReglagesJoueur.sort_actif_equipe = ""
	ReglagesJoueur.ultime_equipe = ""
	ReglagesJoueur.objets.clear()
	ReglagesJoueur.forge_niveaux.clear()
	ReglagesJoueur.equipements = {"anneau_gauche": "", "anneau_droit": "", "collier": ""}

func _doter_progression_intermediaire() -> void:
	# Profil de fin de campagne : offense rang 8 et defense rang 2, ancien set
	# Forge 30 et capacites rang 5. Il teste la nouvelle courbe sans le plafond
	# des Maitrises, de la Forge ou du second Passif.
	ReglagesJoueur.sauvegarde_active = false
	ReglagesJoueur.mode_dev = false
	ReglagesJoueur.niveau_compte = 22
	ReglagesJoueur.rangs_competences.clear()
	for branche in ["Offensif", "Défensif"]:
		for id in ArbreCompetences.BRANCHES[branche]:
			ReglagesJoueur.rangs_competences[str(id)] = 8 if branche == "Offensif" else 2
	ReglagesJoueur.rangs_sorts.clear()
	for id in ["onde_alchimique", "seconde_chance", "grand_oeuvre"]:
		ReglagesJoueur.rangs_sorts[id] = 5
	ReglagesJoueur.sort_actif_equipe = "onde_alchimique"
	ReglagesJoueur.ultime_equipe = "grand_oeuvre"
	ReglagesJoueur.passifs_equipes = ["seconde_chance"]
	# Simule les deblocages accessibles a la fin de la campagne.
	ReglagesJoueur.meilleures_par_chapitre.clear()
	for chapitre in range(Chapitres.nombre() - 1):
		ReglagesJoueur.meilleures_par_chapitre[str(chapitre)] = Reglages.SALLES_PAR_RUN
	var anciens: Array = CatalogueObjets.IDS_PAR_MONDE[0]
	ReglagesJoueur.objets.clear()
	ReglagesJoueur.forge_niveaux.clear()
	for id in anciens:
		ReglagesJoueur.objets.append(str(id))
		ReglagesJoueur.forge_niveaux[str(id)] = 30
	ReglagesJoueur.equipements = {"anneau_gauche": str(anciens[0]),
		"anneau_droit": str(anciens[1]), "collier": str(anciens[2])}

func _doter_progression_maximale() -> void:
	# Outil de sonde : la vraie sauvegarde du joueur ne doit jamais recevoir ca.
	ReglagesJoueur.sauvegarde_active = false
	ReglagesJoueur.mode_dev = false
	# Le niveau de compte porte le socle de statistiques : un compte entierement
	# farme a forcement monte en niveau, l'oublier fausse toute la mesure.
	ReglagesJoueur.niveau_compte = Reglages.NIVEAU_REFERENCE_FIN
	for id in ArbreCompetences.NOEUDS:
		ReglagesJoueur.rangs_competences[id] = ArbreCompetences.rangs(str(id))
	for catalogue in [Sorts.ACTIFS, Sorts.PASSIFS, Sorts.ULTIMES]:
		for id in catalogue:
			ReglagesJoueur.rangs_sorts[id] = Reglages.CAPACITE_RANG_MAX
	# Un compte maxe choisit un loadout coherent ; prendre les premieres cles du
	# Dictionary rendait la sonde artificiellement fragile et mesurait l'ordre du
	# catalogue plutot que le plafond reel de progression.
	ReglagesJoueur.sort_actif_equipe = "explosion_corrosive"
	ReglagesJoueur.ultime_equipe = "grand_oeuvre"
	ReglagesJoueur.passifs_equipes = ["rempart_initial", "seconde_chance"]
	var derniers: Array = CatalogueObjets.IDS_PAR_MONDE[CatalogueObjets.IDS_PAR_MONDE.size() - 1]
	ReglagesJoueur.equipements = {"anneau_gauche": str(derniers[0]),
		"anneau_droit": str(derniers[1]), "collier": str(derniers[2])}
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
func _physics_process(_delta: float) -> void:
	if not _terminee and _panneau == null:
		Jeu.images_de_jeu += 1

func _process(delta: float) -> void:
	_suivre_heros()
	if is_instance_valid(_apprentissage):
		_apprentissage.suspendre(_panneau != null or _voile_salle.visible or _transition_salle or _terminee)
	if not _terminee and not _transition_salle and _panneau == null:
		_recharge_sort_actif = maxf(0.0, _recharge_sort_actif - delta)
		_recharge_riposte = maxf(0.0, _recharge_riposte - delta)
		_charge_ultime = maxf(0.0, _charge_ultime - delta)
		if _passifs_combat.avancer_deplacement(_heros.global_position, ReglagesJoueur.passifs_equipes_effectifs()):
			_effets.onde(_heros.global_position, ReglagesPassifs.RAYON_SIGNAL,
				ReglagesPassifs.COULEUR_SANG_FROID, ReglagesPassifs.DUREE_SIGNAL)
	if _hud != null:
		_hud.rafraichir_sorts(_recharge_sort_actif, _charge_ultime, _ultimes_utilises)
	_avancer_phenomenes(delta)
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
	_passifs_combat.nouvelle_salle(_heros.global_position)
	_suivre_heros()


	_hud.rafraichir()
	_temps_dans_la_salle = 0.0
	if Jeu.mode_auto:
		print("salle %d/%d (%s) : inventaire=%d pv=%d" % [Jeu.salle_courante, Jeu.salles_du_chapitre(),
			Jeu.nom_run(), Jeu.inventaire.size(), roundi(_heros.stats.pv)])
	_salle.demarrer(Jeu.salle_courante, _limites)

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
	if Jeu.mode_run == "epreuve_sorts":
		_sur_palier_defi_termine()
		return
	if Jeu.salle_courante >= Jeu.salles_du_chapitre():
		Jeu.terminer_run(true)
		return
	if Jeu.mode_run == "grimoire" and Jeu.salle_courante + 1 in ProgressionAugments.ETAGES_EPIQUES:
		_ouvrir_alambic_apres_salle()
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
	_voile_salle.configurer("SALLE %02d" % (Jeu.salle_courante + 1), Jeu.nom_run().to_upper())
	var fermeture := create_tween()
	fermeture.set_trans(Tween.TRANS_QUINT)
	fermeture.set_ease(Tween.EASE_IN)
	fermeture.tween_property(_voile_salle, "modulate:a", 1.0,
		0.12 if ReglagesJoueur.effets_reduits else 0.26)
	await fermeture.finished
	Jeu.salle_courante += 1
	_entrer_dans_la_salle()
	await get_tree().create_timer(0.04 if ReglagesJoueur.effets_reduits else 0.16).timeout
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
	var titre := "SALLE %02d" % Jeu.salle_courante if Jeu.mode_run == "grimoire" else Jeu.nom_run().to_upper()
	var sous_titre := Jeu.nom_run().to_upper() if Jeu.mode_run == "grimoire" else (
			"SURVIVEZ 5 MINUTES" if Jeu.mode_run == "mine" else "CINQ RITUELS")
	if Jeu.mode_run == "epreuve_sorts":
		sous_titre = "Choisissez une augmentation après chaque boss"
	_voile_salle.configurer(titre, sous_titre)
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
	_panneau.campagne = Jeu.mode_run == "grimoire"
	_panneau.etage_recompense = Jeu.niveau_run - _niveaux_en_attente + 1
	_panneau.process_mode = Node.PROCESS_MODE_ALWAYS
	_couche.add_child(_panneau)
	_panneau.termine.connect(func() -> void:
		var soin_choisi: float = _panneau.soin_choisi
		_panneau.queue_free()
		_panneau = null
		_heros.recalculer()
		if soin_choisi > 0.0:
			_heros.stats.soigner_garanti(_heros.stats.pv_max * soin_choisi)
			_effets.onde(_heros.global_position, 130.0, Color("71d9b4"), 0.4)
		if Jeu.mode_run == "mine":
			_heros.stats.soigner(_heros.stats.pv_max * Reglages.MINE_SOIN_NIVEAU)
			_effets.onde(_heros.global_position, 150.0, Color(0.42, 1.0, 0.66), 0.45)
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
		var soin: float = _panneau.soin_choisi
		_panneau.queue_free()
		_panneau = null
		_heros.recalculer()
		_heros.stats.soigner_garanti(_heros.stats.pv_max * soin)
		get_tree().paused = false
		_avancer_salle())

func _ouvrir_alambic_apres_salle() -> void:
	if _terminee or _panneau != null:
		return
	_neutraliser_deplacement()
	get_tree().paused = true
	Sons.musique_calme()
	_panneau = DRAFT.instantiate()
	_panneau.campagne = true
	_panneau.palier_epique = Jeu.salle_courante + 1
	_panneau.rarete_imposee = Reactif.LEGENDAIRE if _panneau.palier_epique == Jeu.etage_legendaire else Reactif.EPIQUE
	_panneau.process_mode = Node.PROCESS_MODE_ALWAYS
	_couche.add_child(_panneau)
	_panneau.termine.connect(func() -> void:
		var soin: float = _panneau.soin_choisi
		_panneau.queue_free()
		_panneau = null
		_heros.recalculer()
		_heros.stats.soigner_garanti(_heros.stats.pv_max * soin)
		_effets.onde(_heros.global_position, 130.0, Color("71d9b4"), 0.4)
		_hud.rafraichir()
		get_tree().paused = false
		Sons.musique_combat(0.35)
		_avancer_salle())

func _ouvrir_pause() -> void:
	if _visee_active: _fermer_visee()
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
				and (_panneau == null or _visee_active):
			_ouvrir_pause()
		return
	if quoi != NOTIFICATION_WM_GO_BACK_REQUEST or _terminee:
		return
	if _visee_active:
		_fermer_visee()
	elif _panneau != null and _panneau.scene_file_path == "res://ui/pause.tscn":
		_fermer_pause()
	elif _panneau == null:
		_ouvrir_pause()

func _sur_intention(direction: Vector2, intensite: float) -> void:
	if _heros != null and not Jeu.mode_auto and _panneau == null and not get_tree().paused \
			and not _transition_salle and not _voile_salle.visible:
		_heros.definir_intention(direction, intensite)
		if is_instance_valid(_apprentissage):
			_apprentissage.definir_intention(direction, intensite)

func _neutraliser_deplacement() -> void:
	_joystick.annuler()
	_heros.definir_intention(Vector2.ZERO, 0.0)
	_heros.velocity = Vector2.ZERO
	if is_instance_valid(_apprentissage):
		_apprentissage.definir_intention(Vector2.ZERO, 0.0)

func _sur_tir_heros(tir_courant: Tir, origine: Vector2, direction: Vector2) -> void:
	if not _heros.peut_tirer(): return
	var tir_effectif := tir_courant.copie()
	var attaque_sans_conditions := BonusSorts.attaque(_heros.stats, Jeu.mods())
	var facteur_conditionnel: float = _heros.attaque_reelle() / attaque_sans_conditions if attaque_sans_conditions > 0.0 else 1.0
	tir_effectif.degats = _heros.degats_finaux(tir_effectif.degats * facteur_conditionnel)
	_passifs_combat.preparer_tir(tir_effectif, ReglagesJoueur.passifs_equipes_effectifs())
	_salle.tirer(tir_effectif, origine, direction, false)
	if _orbes_chargees > 0 and "orbes_chargees" in tir_courant.drapeaux:
		for i in _orbes_chargees:
			var angle := (float(i) - float(_orbes_chargees - 1) * 0.5) * 0.13
			_tirer_phenomene("orbes_chargees", Reglages.ORBE_PART_DEGATS, origine,
				direction.rotated(angle))
		_orbes_chargees = 0

func _avancer_phenomenes(delta: float) -> void:
	if is_instance_valid(_apprentissage) and _apprentissage.combat_suspendu():
		return
	if _heros == null or _terminee or _panneau != null or _heros.tir_courant == null:
		return
	var drapeaux: Array[String] = _heros.tir_courant.drapeaux
	if "familier_tireur" in drapeaux:
		_familier_minuterie -= delta
		if _familier_minuterie <= 0.0:
			_familier_minuterie = Reglages.FAMILIER_TIR_INTERVALLE
			var cible := _ennemi_plus_proche(_heros.global_position)
			if cible != null:
				var origine := _heros.global_position + Reglages.FAMILIER_DECALAGE
				var vise := Geometrie.point_anticipe(cible.global_position,
					_vitesse_de(cible), origine, _heros.stats.vitesse_projectile)
				# La lueur souligne le tir du compagnon visible dans le monde 3D.
				_effets.onde(origine, 44.0, Palette.ESSENCE, 0.22)
				_tirer_phenomene("familier_tireur", Reglages.FAMILIER_TIR_PART_DEGATS,
					origine, origine.direction_to(vise))
	if "meteores" in drapeaux:
		_meteore_minuterie -= delta
		if _meteore_minuterie <= 0.0:
			_meteore_minuterie = Reglages.METEORE_INTERVALLE
			_declencher_meteore()
	if "zone_heros" in drapeaux:
		_zone_minuterie -= delta
		if _zone_minuterie <= 0.0:
			_zone_minuterie = Reglages.ZONE_HEROS_INTERVALLE
			_frapper_zone_heros()
	if "orbes_chargees" in drapeaux:
		_orbe_minuterie -= delta
		if _orbe_minuterie <= 0.0:
			_orbe_minuterie = Reglages.ORBE_INTERVALLE
			_orbes_chargees = mini(Reglages.ORBE_MAX, _orbes_chargees + 1)
	if "chaine_alchimique" in drapeaux:
		_chaine_minuterie -= delta
		if _chaine_minuterie <= 0.0:
			_chaine_minuterie = Reglages.CHAINE_INTERVALLE
			_declencher_chaine()
	if "onde_de_choc" in drapeaux:
		_onde_choc_minuterie -= delta
		if _onde_choc_minuterie <= 0.0:
			_onde_choc_minuterie = Reglages.ONDE_CHOC_INTERVALLE
			_declencher_onde_de_choc()
	if "familier_gardien" in drapeaux and (_gardien == null or not is_instance_valid(_gardien)):
		_gardien = Gardien.new()
		_gardien.heros = _heros
		_gardien.global_position = _heros.global_position + Vector2(-70.0, -25.0)
		add_child(_gardien)

func _tirer_phenomene(id: String, part_degats: float, origine: Vector2, direction: Vector2) -> void:
	if not _heros.peut_tirer(): return
	var tir := Tir.de_base(_heros.stats)
	tir.degats = _heros.degats_finaux(_heros.attaque_reelle() * part_degats)
	if id == "familier_tireur":
		tir.drapeaux.append("trait_familier")
	_salle.tirer(tir, origine, direction, false)

func _declencher_meteore() -> void:
	var cible := _ennemi_plus_proche(_heros.global_position)
	if cible == null:
		return
	var tir := Tir.de_base(_heros.stats)
	tir.degats = _heros.degats_finaux(_heros.attaque_reelle() * Reglages.METEORE_PART_DEGATS)
	_effets.onde(cible.global_position, Reglages.METEORE_RAYON, Palette.BRAISE, 0.65)
	for ennemi in get_tree().get_nodes_in_group("ennemis"):
		if is_instance_valid(ennemi) and ennemi.global_position.distance_to(cible.global_position) <= Reglages.METEORE_RAYON:
			_infliger_phenomene(ennemi, tir)

# La chaine ne revient jamais sur un maillon deja frappe.
func _declencher_chaine() -> void:
	var tir := Tir.de_base(_heros.stats)
	tir.degats = _heros.degats_finaux(_heros.attaque_reelle() * Reglages.CHAINE_PART_DEGATS)
	var depart := _heros.global_position
	var deja: Array[int] = []
	for maillon in Reglages.CHAINE_CIBLES:
		var cible := _maillon_suivant(depart, deja)
		if cible == null:
			return
		deja.append(cible.get_instance_id())
		_effets.arc(depart, cible.global_position, Palette.ESSENCE)
		_infliger_phenomene(cible, tir)
		depart = cible.global_position

func _maillon_suivant(origine: Vector2, deja: Array[int]) -> Node2D:
	var resultat: Node2D = null
	var distance := Reglages.CHAINE_PORTEE * Reglages.CHAINE_PORTEE
	for ennemi in get_tree().get_nodes_in_group("ennemis"):
		if not is_instance_valid(ennemi) or ennemi.get_instance_id() in deja:
			continue
		var d := origine.distance_squared_to(ennemi.global_position)
		if d < distance:
			distance = d
			resultat = ennemi
	return resultat

func _declencher_onde_de_choc() -> void:
	var tir := Tir.de_base(_heros.stats)
	tir.degats = _heros.degats_finaux(_heros.attaque_reelle() * Reglages.ONDE_CHOC_PART_DEGATS)
	_effets.onde(_heros.global_position, Reglages.ONDE_CHOC_RAYON, Palette.OR, 0.55)
	for ennemi in get_tree().get_nodes_in_group("ennemis"):
		if not is_instance_valid(ennemi) \
				or ennemi.global_position.distance_to(_heros.global_position) > Reglages.ONDE_CHOC_RAYON:
			continue
		_infliger_phenomene(ennemi, tir)
		_repousser(ennemi, _heros.global_position, Reglages.ONDE_CHOC_REPOUSSEE)

func _frapper_zone_heros() -> void:
	var tir := Tir.de_base(_heros.stats)
	tir.degats = _heros.degats_finaux(_heros.attaque_reelle() * Reglages.ZONE_HEROS_PART_DEGATS)
	_effets.onde(_heros.global_position, Reglages.ZONE_HEROS_RAYON, Palette.MOUSSE_MAGIQUE, 0.32)
	for ennemi in get_tree().get_nodes_in_group("ennemis"):
		if is_instance_valid(ennemi) and ennemi.global_position.distance_to(_heros.global_position) <= Reglages.ZONE_HEROS_RAYON:
			_infliger_phenomene(ennemi, tir)

func _infliger_phenomene(ennemi: Node, tir: Tir) -> void:
	ennemi.recevoir_degats(tir.degats, tir.effets)

func _vitesse_de(cible: Node2D) -> Vector2:
	var vitesse: Vector2 = cible.velocity if "velocity" in cible else Vector2.ZERO
	return vitesse

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
	_hud.impact_degats()
	var passifs := ReglagesJoueur.passifs_equipes_effectifs()
	var ratio_pv: float = _heros.stats.pv / maxf(1.0, _heros.stats.pv_max)
	if _passifs_combat.recharge_audace(passifs, ratio_pv, _recharge_sort_actif):
		_recharge_sort_actif = 0.0
		_effets.onde(position, ReglagesPassifs.RAYON_SIGNAL,
			ReglagesPassifs.COULEUR_AUDACE, ReglagesPassifs.DUREE_SIGNAL)
	if _passifs_combat.declencher_rempart(passifs, ratio_pv, _heros, _salle, _limites):
		_effets.onde(position, Sorts.rayon_rempart(passifs),
			ReglagesPassifs.COULEUR_REMPART, ReglagesPassifs.DUREE_SIGNAL)
	if passifs.has("riposte_alchimique") and _recharge_riposte <= 0.0:
		_recharge_riposte = Reglages.RIPOSTE_RECHARGE
		var degats: float = _heros.degats_finaux(_heros.attaque_reelle() \
			* Reglages.RIPOSTE_PART_DEGATS * float(passifs["riposte_alchimique"]))
		_effets.onde(position, Reglages.RIPOSTE_RAYON, Palette.OR, 0.45)
		for ennemi in get_tree().get_nodes_in_group("ennemis"):
			if not is_instance_valid(ennemi) \
					or ennemi.global_position.distance_to(position) > Reglages.RIPOSTE_RAYON:
				continue
			ennemi.recevoir_degats(degats, [])
			# La riposte doit rendre l'espace repris : encaisser un coup sans
			# desengager ne changeait rien a la situation.
			_repousser(ennemi, position, Reglages.RIPOSTE_REPOUSSEE)

func _sur_bouclier_brise(position: Vector2) -> void:
	_effets.onde(position, 200.0, Color(0.85, 0.92, 1.0), 0.5)

func _sur_ennemi_abattu(experience: int) -> void:
	if Jeu.mode_run in ["grimoire", "mine"]:
		_niveaux_en_attente += Jeu.gagner_experience_run(experience)
		if _niveaux_en_attente > 0 and _panneau == null and not _terminee:
			_ouvrir_recompense_etage()
	if "soif_de_sang" in _heros.tir_courant.drapeaux:
		_heros.stats.soigner(_heros.stats.pv_max * Reglages.SOIF_DE_SANG_PART)
	var passifs := ReglagesJoueur.passifs_equipes_effectifs()
	if passifs.has("moisson_vitale"):
		_compteur_moisson += 1
		if _compteur_moisson >= Sorts.seuil_moisson(passifs):
			_compteur_moisson = 0
			_heros.stats.soigner_garanti(_heros.stats.pv_max * Sorts.soin_moisson(passifs))
			_effets.onde(_heros.global_position, 150.0, Color(0.35, 1.0, 0.58), 0.5)


func _sur_tape_rapide(nombre: int) -> void:
	var requises := RaccourciTactile.tapes_requises(ReglagesJoueur.raccourci_sort)
	if requises <= 0 or nombre < requises or _terminee or _panneau != null:
		return
	# La serie repart de zero apres un tir, sinon la tape suivante completerait
	# un double appui deja consomme.
	_joystick.consommer_raccourci()
	_lancer_sort_actif()

func charger_sort() -> void:
	# Les impacts ordinaires ne rendent pas de recharge ; Reserve d'ultime
	# reagit une seule fois au resultat du sort actif.
	pass

func _point_sort(position_ecran: Vector2) -> Vector2:
	var camera3d := get_viewport().get_camera_3d()
	var point: Vector2
	if camera3d != null:
		var intersection: Variant = Plane(Vector3.UP, 0).intersects_ray(camera3d.project_ray_origin(position_ecran), camera3d.project_ray_normal(position_ecran))
		point = Pont3D.vers_logique(intersection) if intersection != null else _heros.global_position
	else:
		point = _heros.get_canvas_transform().affine_inverse() * position_ecran
	return Geometrie.contraindre_dans_rect(point, _limites, 0.0)

func _ecran_sort(point: Vector2) -> Vector2:
	var camera3d := get_viewport().get_camera_3d()
	return camera3d.unproject_position(Pont3D.vers_monde(point)) if camera3d != null else _heros.get_canvas_transform() * point

func _lancer_sort_actif() -> void:
	if is_instance_valid(_apprentissage) and _apprentissage.combat_suspendu():
		return
	var id := ReglagesJoueur.sort_actif_effectif()
	if _terminee or _panneau != null or get_tree().paused or _recharge_sort_actif > 0.0 or not Sorts.ACTIFS.has(id): return
	if Jeu.mode_auto:
		var ennemis := get_tree().get_nodes_in_group("ennemis")
		if not ennemis.is_empty(): _confirmer_sort(ennemis[0].global_position)
		return
	_neutraliser_deplacement()
	_panneau = load("res://ui/visee_sort.gd").new()
	_panneau.point = _heros.global_position
	_panneau.rayon = BonusSorts.rayon(float(Sorts.ACTIFS[id]["rayon"]), Jeu.mods())
	_panneau.vers_logique = _point_sort
	_panneau.vers_ecran = _ecran_sort
	_panneau.confirme.connect(func(point: Vector2):
		_fermer_visee()
		_confirmer_sort(point))
	_panneau.annule.connect(_fermer_visee)
	_visee_active = true
	_vitesse_avant_visee = Engine.time_scale
	Engine.time_scale = Reglages.VISEE_VITESSE_TEMPS
	_couche.add_child(_panneau)

func _fermer_visee() -> void:
	if not _visee_active: return
	_visee_active = false
	Engine.time_scale = _vitesse_avant_visee
	_panneau.queue_free()
	_panneau = null
	_neutraliser_deplacement()
	get_tree().paused = false
	_reprendre_apres_visee.call_deferred()

func _reprendre_apres_visee() -> void:
	if _terminee or _panneau != null: return
	if _niveaux_en_attente > 0:
		_ouvrir_recompense_etage()
	elif _fin_salle_en_attente:
		_fin_salle_en_attente = false
		_traiter_fin_salle()

func _exit_tree() -> void:
	if _visee_active:
		Engine.time_scale = _vitesse_avant_visee

func _confirmer_sort(point: Vector2) -> void:
	var id := ReglagesJoueur.sort_actif_effectif()
	if _recharge_sort_actif > 0.0 or not Sorts.ACTIFS.has(id):
		return
	var sort: Dictionary = Sorts.ACTIFS[id]
	var efficacite := ReglagesJoueur.efficacite_sort(id)
	var multiplicateur := float(sort["degats"]) * efficacite
	var degats: float = _heros.degats_finaux(_heros.attaque_reelle(true) * multiplicateur)
	_recharge_sort_actif = ReglagesJoueur.recharge_sort(id, Jeu.mods())
	var touches := _appliquer_sort(float(sort["rayon"]), multiplicateur, str(sort["effet"]), false, point, id, degats)
	var passifs := ReglagesJoueur.passifs_equipes_effectifs()
	if touches > 0:
		_charge_ultime = maxf(0.0, _charge_ultime - Sorts.temps_reserve(passifs))
	if passifs.has("echo_alchimique") \
			and Jeu.rng.randf() < Sorts.chance_echo(passifs):
		# Les soins des premieres victimes ne changent pas les degats de l'echo.
		_appliquer_sort(float(sort["rayon"]), multiplicateur, str(sort["effet"]), false, point, id,
			degats * Reglages.ECHO_PART_DEGATS)

func _lancer_ultime() -> void:
	if is_instance_valid(_apprentissage) and _apprentissage.combat_suspendu():
		return
	if _terminee or _panneau != null or get_tree().paused: return
	var id := ReglagesJoueur.ultime_effectif()
	if not Sorts.ULTIMES.has(id):
		return
	var sort: Dictionary = Sorts.ULTIMES[id]
	if _charge_ultime > 0.0: return
	_charge_ultime = ReglagesJoueur.recharge_sort(id, Jeu.mods())
	_ultimes_utilises += 1

	_appliquer_sort(INF, float(sort["degats"]) * ReglagesJoueur.efficacite_sort(id), str(sort["effet"]), true, Vector2.INF, id)

func _appliquer_sort(rayon: float, multiplicateur: float, effet: String, ultime: bool,
		cible := Vector2.INF, id := "", degats_prepares := -1.0) -> int:
	var mods_sorts := Jeu.mods()
	rayon = BonusSorts.rayon(rayon, mods_sorts)
	var degats := degats_prepares
	if degats < 0.0:
		degats = _heros.degats_finaux(_heros.attaque_reelle(true) * multiplicateur)
	var centre := _heros.global_position if cible == Vector2.INF else cible
	_effets.animer_sort(id, centre, rayon)
	if effet == "purifie":
		PassifsCombat.dissiper_projectiles(get_tree(), centre, rayon)
	var touches := 0
	for ennemi in get_tree().get_nodes_in_group("ennemis"):
		if not is_instance_valid(ennemi) or ennemi.is_queued_for_deletion() \
				or (not is_inf(rayon) and ennemi.global_position.distance_to(centre) > rayon):
			continue
		touches += 1
		var effets_sort: Array[String] = []
		if effet in ["braise", "givre", "acide"]:
			effets_sort.append(effet)
		ennemi.recevoir_degats(degats, effets_sort)
		if effet == "givre" and ennemi.has_method("geler"):
			ennemi.geler(Reglages.GEL_ULTIME_DUREE if ultime else Reglages.GEL_SORT_DUREE)
		elif effet == "repousse":
			_repousser(ennemi, centre, Reglages.SORT_REPOUSSEE)
		elif effet == "attire":
			var distance := float(Sorts.donnees(id).get("attraction", 0.0))
			PassifsCombat.deplacer_ennemi(ennemi, ennemi.global_position.move_toward(centre, distance), _salle, _limites)
	Sons.jouer("fusion" if ultime else "choix", -9.0)
	return touches

# Une poussee qui traverse le decor sortirait la creature de l'arene : elle est
# bornee par les memes limites que le heros.
func _repousser(ennemi: Node2D, origine: Vector2, distance: float) -> void:
	var direction := origine.direction_to(ennemi.global_position)
	if direction == Vector2.ZERO:
		return
	PassifsCombat.deplacer_ennemi(ennemi, ennemi.global_position + direction * distance, _salle, _limites)

func _sur_run_terminee(victoire: bool) -> void:
	if _terminee:
		return
	if is_instance_valid(_apprentissage):
		_apprentissage.interrompre()
	if _visee_active: _fermer_visee()
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
