extends AnimationTree

const TIR := preload("res://scripts/presentation/tir_heros_3d.gd")
var mouvement := 0.0
var cadence := 1.0
var _mort := false
var _impact_en_attente := false
var _amorces := 0
var _projections := 0
var _influence_tir := 1.0
var _tir: Node3D
var _modele: Node3D

func preparer(lecteur: AnimationPlayer) -> void:
	anim_player = get_path_to(lecteur)
	_modele = lecteur.get_node(lecteur.root_node) as Node3D
	root_node = get_path_to(_modele)
	callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	lecteur.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	var squelette := _modele.find_child("Skeleton3D",true,false) as Skeleton3D
	_tir = TIR.new()
	_tir.name = "GesteTir"
	squelette.add_child(_tir)
	_tir.preparer(lecteur)
	var graphe := AnimationNodeBlendTree.new()
	for nom: String in ["repos","course","touche","mort"]:
		var clip := AnimationNodeAnimation.new()
		clip.animation = nom
		graphe.add_node(nom,clip)
	graphe.add_node("cadence",AnimationNodeTimeScale.new())
	graphe.connect_node("cadence",0,"course")
	var locomotion := AnimationNodeBlend2.new()
	locomotion.sync = true
	graphe.add_node("locomotion",locomotion)
	graphe.connect_node("locomotion",0,"repos")
	graphe.connect_node("locomotion",1,"cadence")
	var impact := AnimationNodeOneShot.new()
	impact.fadein_time = Visuels3D.HEROS_TRANSITION_IMPACT
	impact.fadeout_time = Visuels3D.HEROS_TRANSITION_MOUVEMENT
	impact.filter_enabled = true
	var touche := lecteur.get_animation("touche")
	for piste in touche.get_track_count():
		var chemin := touche.track_get_path(piste)
		var os := str(chemin.get_subname(0)) if chemin.get_subname_count() > 0 else ""
		if os in Visuels3D.HEROS_OS_HAUT: impact.set_filter_path(chemin,true)
	graphe.add_node("impact",impact)
	graphe.connect_node("impact",0,"locomotion")
	graphe.connect_node("impact",1,"touche")
	var etat := AnimationNodeTransition.new()
	etat.input_count = 2
	etat.set_input_name(0,"vivant")
	etat.set_input_name(1,"mort")
	etat.xfade_time = Visuels3D.HEROS_TRANSITION_MOUVEMENT
	graphe.add_node("etat",etat)
	graphe.connect_node("etat",0,"impact")
	graphe.connect_node("etat",1,"mort")
	graphe.connect_node("output",0,"etat")
	tree_root = graphe
	active = true
	advance(0.0)

func mettre_a_jour(delta: float, vitesse: float, mort: bool, deplacement_commande := false) -> void:
	# Restaurer avant l'evaluation du graphe evite d'accumuler le recul.
	_tir.restaurer()
	var cible := smoothstep(Visuels3D.HEROS_SEUIL_REPOS,Visuels3D.HEROS_VITESSE_PLEINE_POSE,vitesse)
	var lissage := 1.0-exp(-Visuels3D.HEROS_LISSAGE_MOUVEMENT*delta)
	mouvement = lerpf(mouvement,cible,lissage) if delta>0.0 else cible
	var visee := clampf(vitesse/Reglages.HEROS_VITESSE*Visuels3D.HEROS_CADENCE_COURSE,Visuels3D.HEROS_CADENCE_MIN,Visuels3D.HEROS_CADENCE_MAX)
	cadence = lerpf(cadence,visee,1.0-exp(-Visuels3D.HEROS_LISSAGE_CADENCE*delta)) if delta>0.0 else visee
	set("parameters/locomotion/blend_amount",mouvement)
	set("parameters/cadence/scale",cadence)
	if mort and not _mort:
		_mort = true
		_tir.reinitialiser()
		set("parameters/etat/transition_request","mort")
		_modele.exprimer_mort()
	advance(delta)
	# La reaction aux degats garde la priorite sur le geste de tir.
	var impact_actif := bool(get("parameters/impact/active"))
	var transition := Visuels3D.HEROS_TRANSITION_IMPACT if impact_actif else Visuels3D.HEROS_TRANSITION_MOUVEMENT
	_influence_tir = move_toward(_influence_tir,0.0 if impact_actif else 1.0,delta/maxf(transition,0.001))
	if _mort or deplacement_commande:
		_tir.relacher()
	else:
		for i in range(_amorces): _tir.armer()
		for i in range(_projections): _tir.projeter()
	_tir.appliquer(delta,_influence_tir)
	_amorces = 0
	_projections = 0
	_impact_en_attente = false

func tirer() -> void:
	armer()

func toucher() -> void:
	if _mort or _impact_en_attente or bool(get("parameters/impact/active")): return
	_impact_en_attente = true
	set("parameters/impact/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	_modele.exprimer_impact()

func armer() -> void:
	if not _mort: _amorces += 1

func projeter() -> void:
	if not _mort: _projections += 1
