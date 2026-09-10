extends AnimationTree

var mouvement := 0.0
var cadence := 1.0
var _mort := false
var _tir_en_attente := false
var _impact_en_attente := false

func preparer(lecteur: AnimationPlayer) -> void:
	anim_player = get_path_to(lecteur)
	root_node = get_path_to(lecteur.get_node(lecteur.root_node))
	callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	var graphe := AnimationNodeBlendTree.new()
	for nom: String in ["repos", "course", "attaque", "touche", "mort"]:
		var clip := AnimationNodeAnimation.new()
		clip.animation = nom
		graphe.add_node(nom, clip)
	graphe.add_node("cadence", AnimationNodeTimeScale.new())
	graphe.connect_node("cadence", 0, "course")
	var locomotion := AnimationNodeBlend2.new()
	locomotion.sync = true
	graphe.add_node("locomotion", locomotion)
	graphe.connect_node("locomotion", 0, "repos")
	graphe.connect_node("locomotion", 1, "cadence")
	for nom: String in ["tir", "impact"]:
		var geste := AnimationNodeOneShot.new()
		geste.fadein_time = Visuels3D.HEROS_TRANSITION_TIR if nom == "tir" else Visuels3D.HEROS_TRANSITION_IMPACT
		geste.fadeout_time = Visuels3D.HEROS_TRANSITION_MOUVEMENT
		geste.filter_enabled = true
		var clip := lecteur.get_animation("attaque" if nom == "tir" else "touche")
		for piste in clip.get_track_count():
			var chemin := clip.track_get_path(piste)
			var os := str(chemin.get_subname(0)) if chemin.get_subname_count() > 0 else ""
			if os in Visuels3D.HEROS_OS_HAUT:
				geste.set_filter_path(chemin, true)
		graphe.add_node(nom, geste)
	graphe.connect_node("tir", 0, "locomotion")
	graphe.connect_node("tir", 1, "attaque")
	graphe.connect_node("impact", 0, "tir")
	graphe.connect_node("impact", 1, "touche")
	var etat := AnimationNodeTransition.new()
	etat.input_count = 2
	etat.set_input_name(0, "vivant")
	etat.set_input_name(1, "mort")
	etat.xfade_time = Visuels3D.HEROS_TRANSITION_MOUVEMENT
	graphe.add_node("etat", etat)
	graphe.connect_node("etat", 0, "impact")
	graphe.connect_node("etat", 1, "mort")
	graphe.connect_node("output", 0, "etat")
	tree_root = graphe
	active = true
	advance(0.0)

func mettre_a_jour(delta: float, vitesse: float, mort: bool) -> void:
	var cible := smoothstep(Visuels3D.HEROS_SEUIL_REPOS, Visuels3D.HEROS_VITESSE_PLEINE_POSE, vitesse)
	var lissage := 1.0 - exp(-Visuels3D.HEROS_LISSAGE_MOUVEMENT * delta)
	mouvement = lerpf(mouvement, cible, lissage) if delta > 0.0 else cible
	var visee := clampf(vitesse / Reglages.HEROS_VITESSE * Visuels3D.HEROS_CADENCE_COURSE, Visuels3D.HEROS_CADENCE_MIN, Visuels3D.HEROS_CADENCE_MAX)
	cadence = lerpf(cadence, visee, 1.0 - exp(-Visuels3D.HEROS_LISSAGE_CADENCE * delta)) if delta > 0.0 else visee
	set("parameters/locomotion/blend_amount", mouvement)
	set("parameters/cadence/scale", cadence)
	if mort and not _mort:
		_mort = true
		set("parameters/etat/transition_request", "mort")
	advance(delta)
	_tir_en_attente = false
	_impact_en_attente = false

func tirer() -> void:
	if _mort or _tir_en_attente or bool(get("parameters/tir/active")):
		return
	_tir_en_attente = true
	set("parameters/tir/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func toucher() -> void:
	if _mort or _impact_en_attente or bool(get("parameters/impact/active")):
		return
	_impact_en_attente = true
	set("parameters/impact/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
