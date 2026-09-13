extends SceneTree

var controles := 0
var echecs := 0

func _initialize() -> void:
	call_deferred("verifier")

func exiger(valide: bool, contexte: String) -> void:
	controles += 1
	if not valide:
		echecs += 1
		push_error(contexte)

func verifier() -> void:
	root.get_node("ReglagesJoueur").sauvegarde_active = false
	root.get_node("ReglagesJoueur").mode_dev = true
	var menu: Control = load("res://scenes/menu.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	for format in [Vector2i(540,960),Vector2i(540,1200),Vector2i(540,1320)]:
		root.size = format
		for index in [0,1,2,3]:
			menu.call("_afficher_page",index,false)
			await create_timer(0.15).timeout
			controler(menu.get("_page_actuelle"),str(format)+" page "+str(index))
		for nom in ["reglages","pause","draft","selection_grimoire","alambic","recompense_sorts","fin_de_run"]:
			var page: Control = load("res://ui/"+nom+".tscn").instantiate()
			root.add_child(page)
			await create_timer(0.15).timeout
			controler(page,str(format)+" "+nom)
			page.queue_free()
			await process_frame
	menu.queue_free()
	await process_frame
	print("MENUS_ATELIER : %d controles, %d echecs" % [controles,echecs])
	quit(1 if echecs else 0)

func controler(page: Control, contexte: String) -> void:
	for element in page.find_children("*","Control",true,false):
		if not element.is_visible_in_tree(): continue
		if element is Label:
			var label: Label = element
			exiger(label.size.y+1.0 >= label.get_minimum_size().y,contexte+" texte trop bas : "+label.text)
			var parent := label.get_parent()
			# Les etiquettes des cartes sont des enfants de conteneurs, jamais des masques.
			if parent is Container:
				exiger(label.size.x <= parent.size.x+1.0,contexte+" texte trop large : "+label.text)
		if element is Button:
			var bouton: Button = element
			exiger(bouton.size.y+1.0 >= bouton.get_minimum_size().y,contexte+" bouton tronque : "+bouton.text)
