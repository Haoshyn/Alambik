extends SceneTree

var v := Verif.new()
var r: Node
var jeu: Node

func _initialize() -> void:
	call_deferred("verifier")

func creer_run(mode: String) -> Node:
	paused = false
	r.mode_run_choisi = mode
	var run: Node = load("res://scenes/run.tscn").instantiate()
	root.add_child(run)
	run.set_process(false)
	return run

func verifier() -> void:
	r = root.get_node("ReglagesJoueur")
	jeu = root.get_node("Jeu")
	r.sauvegarde_active = false
	r.mode_dev = false
	r.reinitialiser_progression()
	r.rangs_sorts = {"onde_alchimique": 1, "grand_oeuvre": 1, "sang_froid": 1}
	r.sort_actif_equipe = "onde_alchimique"
	r.ultime_equipe = "grand_oeuvre"
	r.passifs_equipes.assign(["sang_froid"])
	var run := creer_run("grimoire")
	await process_frame
	paused = true
	run._recharge_sort_actif = 12.0
	run._charge_ultime = 75.0
	for i in 100: run.charger_sort()
	v.presque(run._recharge_sort_actif, 12.0, "cent impacts ne rechargent rien")
	for i in 10: run._sur_ennemi_abattu(0)
	v.presque(run._recharge_sort_actif, 12.0, "sang-froid ne reinitialise pas le sort sur les morts")
	v.presque(run._charge_ultime, 75.0, "les morts ne rechargent pas l'ultime")
	run._process(1.0)
	v.presque(run._recharge_sort_actif, 11.0, "une seconde simulee recharge une seconde")
	v.presque(run._charge_ultime, 74.0, "ultime temporel egalement")
	var visuel: Node3D = load("res://scripts/presentation/phenomenes_3d.gd").new()
	visuel.heros = run._heros
	root.add_child(visuel)
	run._heros.tir_courant.drapeaux.assign(["zone_heros", "familier_tireur"])
	for reduit in [false, true]:
		r.effets_reduits = reduit
		visuel.mettre_a_jour(0.0)
		v.vrai(visuel.zone.visible and visuel.familier.visible, "zone et compagnon visibles meme en effets reduits")
		v.vrai(visuel.familier.texture != null, "le familier a une vraie silhouette")
		v.presque(visuel.zone.mesh.size.x, Reglages.ZONE_HEROS_RAYON * 2.0 * Pont3D.ECHELLE, "le cercle montre la portee reelle")
	visuel.free()
	var salle: Node2D = run._salle
	salle.faire_apparaitre("le_correcteur", Vector2(450, 450))
	var boss: Node = get_first_node_in_group("boss")
	boss._commencer_motif("invocation")
	v.egal(get_nodes_in_group("invocations_boss").size(), 2, "salve de deux renforts")
	boss._commencer_motif("invocation")
	v.egal(get_nodes_in_group("invocations_boss").size(), 2, "pas de nouvelle salve pendant le delai")
	boss._recharge_invocation = 0.0
	boss._commencer_motif("invocation")
	v.egal(get_nodes_in_group("invocations_boss").size(), 3, "trois renforts simultanes au maximum")
	for renfort in get_nodes_in_group("invocations_boss"):
		var normal: Dictionary = salle._mis_a_l_echelle(CatalogueEnnemis.par_id("encrier_rampant"), "encrier_rampant")
		v.presque(renfort.pv_max, float(normal["pv"]) * Reglages.INVOCATION_PV_MULT, "renfort nettement moins resistant")
		v.egal(renfort.donnees["experience"], 0, "pas de farm infini sur les invocations")
	# Un abandon immediat passe par le meme bilan interactif.
	run._ouvrir_pause()
	run._panneau._quitter_run()
	v.vrai(run._terminee and not jeu.bilan_run.is_empty(), "quitter ouvre le coffre")
	v.egal(jeu.bilan_run["gouttes"], 0, "aucune salle terminee donne un coffre vide")
	var compte_avant: int = r.runs
	var gouttes_avant: int = r.gouttes
	load("res://scripts/bilan_run.gd").finaliser(false, 1)
	v.egal(r.runs, compte_avant, "bilan attribue une seule fois")
	v.egal(r.gouttes, gouttes_avant, "pas de monnaie dupliquee")
	run.free()
	await process_frame
	# Boss final : pas de portail ni de choix d'augmentation parasite.
	run = creer_run("grimoire")
	await process_frame
	paused = true
	salle = run._salle
	jeu.salle_courante = 20
	salle.numero = 20
	for numero in range(1, 20): jeu.marquer_salle_terminee(numero)
	for numero in [5, 10, 15]: jeu.marquer_boss_vaincu(numero)
	salle.faire_apparaitre("le_correcteur", Vector2(450, 450))
	boss = get_first_node_in_group("boss")
	boss._mourir()
	await process_frame
	await process_frame
	v.vrai(run._terminee, "mort du boss final ouvre immediatement le coffre")
	v.egal(jeu.salles_terminees.size(), 20, "la derniere salle compte sans franchir un portail")
	v.vrai(int(jeu.bilan_run.get("gouttes", 0)) >= 72, "coffre final complet")
	var fin: Control = run._couche.get_child(run._couche.get_child_count() - 1)
	v.vrai(not fin._ouvert and not fin._recompenses.visible, "le coffre attend le toucher")
	fin._ouvrir()
	fin._ouvrir()
	fin._process(1.0)
	v.vrai(fin._revele and fin._recompenses.visible, "un toucher revele les gains")
	run.free()
	await process_frame
	# Epreuve : aucun augment initial, un vrai choix apres le premier boss.
	r.passifs_equipes.assign(["heritage_reactif"])
	r.rangs_sorts["heritage_reactif"] = 1
	run = creer_run("epreuve_sorts")
	await process_frame
	paused = true
	v.egal(jeu.inventaire.size(), 0, "pas d'augment initial en epreuve")
	boss = get_first_node_in_group("boss")
	boss._mourir()
	await process_frame
	await process_frame
	v.vrai(run._panneau != null and run._panneau.has_method("_sur_choix"), "choix d'augment apres le boss")
	v.egal(jeu.inventaire.size(), 0, "aucun choix automatique impose")
	run._panneau._sur_choix("zone_heros")
	v.vrai(jeu.inventaire.has("zone_heros"), "l'augmentation choisie est accordee")
	run.free()
	paused = false
	await process_frame
	# La selection d'epreuve expose ses niveaux et les loots sans lancer de run.
	r.meilleures_par_chapitre = {"0": Reglages.SALLES_PAR_RUN}
	r.niveau_epreuve_debloque = 2
	r.mode_run_choisi = "grimoire"
	var selection: Control = load("res://ui/selection_grimoire.gd").new()
	root.add_child(selection)
	await process_frame
	selection._choisir_mode("epreuve_sorts")
	v.vrai(selection._liste_epreuves.visible, "ouvrir epreuves expose les niveaux")
	v.egal(r.mode_run_choisi, "grimoire", "ouvrir la liste ne choisit pas un niveau arbitraire")
	v.vrai(not r.choisir_epreuve(3), "un niveau non debloque ne peut pas etre choisi")
	v.vrai(r.choisir_epreuve(2), "niveau debloque selectionnable")
	v.egal(r.niveau_epreuve_choisi, 2, "selection du niveau conservee")
	selection._voir_loots("epreuve_sorts", 0, 2)
	await process_frame
	var apercu: Control = selection._apercu
	var textes := ""
	for label in apercu.find_children("*", "Label", true, false): textes += label.text + "\n"
	v.vrai("Nova de givre" in textes and "Héritage réactif" in textes, "le point d'information liste les vrais loots")
	v.vrai("40.0 %" in textes, "les deux sorts annoncés ont chacun quarante pour cent")
	selection._voir_loots("epreuve_sorts", 0, 2)
	v.vrai(selection._apercu == apercu, "pas de double superposition de loots")
	selection.free()
	print("REFONTE_GAMEPLAY : %d assertions, %d echecs" % [v.total, v.echecs.size()])
	for message in v.echecs: push_error(message)
	quit(0 if v.echecs.is_empty() else 1)
