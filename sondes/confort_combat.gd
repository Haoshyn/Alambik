extends SceneTree

class Horloge:
	extends Node
	var ecoule := 0.0
	func _process(delta: float) -> void:
		ecoule += delta

var echecs := 0
var controles := 0

func _initialize() -> void:
	verifier.call_deferred()

func exiger(condition: bool, message: String) -> void:
	controles += 1
	if not condition:
		echecs += 1
		push_error(message)

func verifier() -> void:
	var regles := root.get_node("ReglagesJoueur")
	regles.sauvegarde_active = false
	regles.mode_dev = false
	regles.mode_run_choisi = "grimoire"
	regles.sort_actif_equipe = "onde_alchimique"
	regles.rangs_sorts["onde_alchimique"] = 1
	var jeu := root.get_node("Jeu")
	var run: Node = load("res://scenes/run.tscn").instantiate()
	root.add_child(run)
	await process_frame
	await process_frame
	var heros: Node = run.get("_heros")
	var hud: Control = run.get("_hud")
	for format in [Vector2i(540,960),Vector2i(540,1200),Vector2i(540,1320),Vector2i(480,800),Vector2i(768,1024)]:
		root.size = format
		await process_frame
		await process_frame
		for cle in ["_bouton_pause","_bouton_actif","_bouton_ultime"]:
			var bouton: Button = hud.get(cle)
			exiger(root.get_visible_rect().encloses(bouton.get_global_rect()),"Commande dans le cadre : %s / %s" % [format,cle])
	for salle in [4,5,10,15,20]:
		jeu.salle_courante = salle
		heros.stats.pv = heros.stats.pv_max * 0.25
		heros.stats.soin_restant = 0.0
		run.call("_soigner_avant_boss")
		var attendu: float = heros.stats.pv_max * (0.25 if salle == 4 else 0.55)
		exiger(is_equal_approx(heros.stats.pv,attendu),"Soin exact avant boss %d" % salle)
		run.call("_soigner_avant_boss")
		exiger(is_equal_approx(heros.stats.pv,attendu),"Pas de double soin %d" % salle)
	jeu.salle_courante = 1
	exiger(CatalogueProjectiles.disponibles(1) == ["standard"],"Une seule arme initiale")
	var horloge := Horloge.new()
	root.add_child(horloge)
	run.call("_lancer_sort_actif")
	exiger(is_equal_approx(Engine.time_scale,0.1) and not paused,"Visee a 10 %, monde vivant")
	await process_frame
	await process_frame
	horloge.ecoule = 0.0
	await create_timer(0.12,true,false,true).timeout
	exiger(horloge.ecoule > 0.0 and horloge.ecoule < 0.06,"Le temps continue lentement : %.4f s" % horloge.ecoule)
	var visee: Control = run.get("_panneau")
	var clic := InputEventMouseButton.new()
	clic.button_index = MOUSE_BUTTON_LEFT
	clic.pressed = true
	clic.position = root.get_visible_rect().get_center()
	visee.call("_gui_input",clic)
	exiger(run.get("_panneau") == null and is_equal_approx(Engine.time_scale,1.0),"Clic unique ferme et restaure le temps")
	var recharge: float = run.get("_recharge_sort_actif")
	exiger(recharge > 0.0,"Clic lance vraiment le sort")
	visee.call("_gui_input",clic)
	exiger(is_equal_approx(recharge,run.get("_recharge_sort_actif")),"Double evenement sans double lancement")
	run.set("_recharge_sort_actif",0.0)
	run.call("_lancer_sort_actif")
	run.call("_notification",Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	exiger(not run.get("_visee_active") and is_equal_approx(Engine.time_scale,1.0),"Retour Android annule")
	run.call("_lancer_sort_actif")
	var touche := InputEventScreenTouch.new()
	touche.pressed = true
	touche.position = root.get_visible_rect().get_center()
	run.get("_panneau").call("_gui_input",touche)
	exiger(run.get("_recharge_sort_actif") > 0.0 and is_equal_approx(Engine.time_scale,1.0),"Touche mobile lance immediatement")
	run.set("_recharge_sort_actif",0.0)
	run.call("_lancer_sort_actif")
	run.call("_ouvrir_pause")
	exiger(paused and is_equal_approx(Engine.time_scale,1.0),"Pause restaure le temps")
	run.call("_fermer_pause")
	run.call("_lancer_sort_actif")
	run.call("_sur_run_terminee",false)
	exiger(paused and is_equal_approx(Engine.time_scale,1.0),"Fin de run restaure le temps")
	paused = false
	run.queue_free()
	horloge.queue_free()
	await process_frame
	var sortie: Node = load("res://scenes/run.tscn").instantiate()
	root.add_child(sortie)
	sortie.call("_lancer_sort_actif")
	exiger(is_equal_approx(Engine.time_scale,0.1),"Visee avant sortie de scene")
	sortie.queue_free()
	await process_frame
	exiger(is_equal_approx(Engine.time_scale,1.0),"Sortie de scene restaure le temps")
	print("CONFORT_COMBAT : %d controles, %d echecs" % [controles,echecs])
	quit(1 if echecs else 0)
