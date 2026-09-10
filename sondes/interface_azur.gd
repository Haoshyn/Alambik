extends SceneTree
var echecs := 0
var controles := 0
var regles: Node
var jeu: Node

func _initialize() -> void:
	call_deferred("verifier")

func exiger(condition: bool, message: String) -> void:
	controles += 1
	if not condition:
		echecs += 1
		push_error(message)

func attendre() -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw

func page(nom: String) -> Control:
	var p: Control = load("res://ui/"+nom+".tscn").instantiate()
	root.add_child(p)
	return p

func verifier() -> void:
	regles = root.get_node("ReglagesJoueur")
	jeu = root.get_node("Jeu")
	regles.sauvegarde_active = false
	regles.mode_dev = true
	regles.gouttes = 10000
	regles.pierres_forge = 1000
	var equipement := page("equipement")
	await attendre()
	var actions: Array = equipement.get("_actions")
	exiger(actions.size()==3,"trois actions de bijoux")
	var id := str(equipement.get("_objet_selectionne"))
	exiger(not id.is_empty(),"collection disponible en developpement")
	actions[0].emit_signal("pressed")
	exiger(str(regles.equipements["anneau_gauche"])==id,"equipement reel")
	var niveau: int = regles.niveau_objet(id)
	var cout: int = regles.cout_forge(id)
	var pierres: int = regles.pierres_forge
	actions[2].emit_signal("pressed")
	exiger(regles.niveau_objet(id)==niveau+1,"forge ameliore le bijou")
	exiger(regles.pierres_forge==pierres-cout,"forge debite le cout exact")
	await attendre()
	root.get_texture().get_image().save_png("res://tmp/azur-equipement-complet.png")
	equipement.queue_free()
	await attendre()
	regles.mode_dev = false
	regles.rangs_competences.clear()
	var arbre := page("arbre_competences")
	await attendre()
	var noeuds: Dictionary = arbre.get("_noeuds")
	exiger(noeuds.size()==30,"trois branches completes")
	var selection := str(arbre.get("_selection"))
	var rang: int = regles.rang_competence(selection)
	noeuds[selection].emit_signal("pressed")
	exiger(regles.rang_competence(selection)==rang,"consulter ne depense rien")
	arbre.get("_achat").emit_signal("pressed")
	exiger(regles.rang_competence(selection)==rang+1,"achat explicite du rang")
	arbre.queue_free()
	await attendre()
	var campagne := page("selection_grimoire")
	campagne.call("_choisir_mode","mine")
	exiger(regles.mode_run_choisi=="mine","mode alternatif memorise")
	await create_timer(0.5).timeout
	campagne.queue_free()
	await attendre()
	jeu.inventaire.clear()
	jeu.rerolls_restants = 1
	var draft := page("draft")
	await attendre()
	exiger(draft.get("_propositions").size()==3,"trois cartes proposees")
	draft.call("_sur_reroll")
	exiger(jeu.rerolls_restants==0,"dernier tirage consomme")
	exiger(draft.get("_bouton_reroll").disabled,"tirage desactive a zero")
	draft.call("_sur_reroll")
	exiger(jeu.rerolls_restants==0,"aucun tirage negatif")
	await attendre()
	root.get_texture().get_image().save_png("res://tmp/azur-ameliorations.png")
	var reactif := str(draft.get("_propositions")[0])
	draft.call("_sur_choix",reactif)
	draft.call("_sur_choix",reactif)
	exiger(jeu.inventaire.count(reactif)==1,"double appui sans double recompense")
	await create_timer(0.5).timeout
	draft.queue_free()
	await attendre()
	var reglages := page("reglages")
	await attendre()
	var sliders := reglages.find_children("*","HSlider",true,false)
	exiger(sliders.size()==2,"deux volumes independants")
	sliders[0].value = 0.37
	exiger(is_equal_approx(regles.volume_musique,0.37),"volume reel applique")
	root.get_texture().get_image().save_png("res://tmp/azur-parametres.png")
	reglages.queue_free()
	await attendre()
	var menu: Control = load("res://scenes/menu.tscn").instantiate()
	root.add_child(menu)
	await create_timer(2.0).timeout
	var accueil: Control = menu.get("_page_actuelle")
	await attendre()
	accueil.set_process(false)
	var mat: ShaderMaterial = accueil.get("_matiere")
	mat.set_shader_parameter("temps",0.0)
	await attendre()
	var debut := root.get_texture().get_image()
	mat.set_shader_parameter("temps",1.2)
	await attendre()
	var fin := root.get_texture().get_image()
	var surface: Control = accueil.get("_surface")
	var transform := root.get_screen_transform()*surface.get_global_transform()
	var changements := 0
	var commandes := 0
	for x in range(100,900,8):
		for y in range(150,1300,8):
			var point := Vector2i(transform*Vector2(x,y))
			if debut.get_pixelv(point) != fin.get_pixelv(point): changements += 1
		for y in range(1740,1890,8):
			var point := Vector2i(root.get_screen_transform()*Vector2(x,y))
			if debut.get_pixelv(point) != fin.get_pixelv(point): commandes += 1
	exiger(changements>50,"accueil vivant dans le rendu Godot")
	exiger(commandes==0,"navigation illustree immobile")
	root.get_texture().get_image().save_png("res://tmp/azur-accueil-final.png")
	menu.queue_free()
	await attendre()
	print("INTERFACE_AZUR : %d controles, %d echecs" % [controles,echecs])
	quit(1 if echecs else 0)
