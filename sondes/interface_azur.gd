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
	if DisplayServer.get_name() != "headless": await RenderingServer.frame_post_draw

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
	if DisplayServer.get_name() != "headless": root.get_texture().get_image().save_png("res://tmp/azur-equipement-complet.png")
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
	regles.mode_dev = true
	campagne.call("_choisir_mode","mine")
	exiger(regles.mode_run_choisi=="mine","mode alternatif memorise")
	regles.mode_dev = false
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
	if DisplayServer.get_name() != "headless": root.get_texture().get_image().save_png("res://tmp/azur-ameliorations.png")
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
	if DisplayServer.get_name() != "headless": root.get_texture().get_image().save_png("res://tmp/azur-parametres.png")
	reglages.queue_free()
	await attendre()
	var menu: Control = load("res://scenes/menu.tscn").instantiate()
	root.add_child(menu)
	await create_timer(2.0).timeout
	var accueil: Control = menu.get("_page_actuelle")
	await attendre()
	var illustration: TextureRect = accueil.get("_illustration")
	exiger(illustration.texture != null and illustration.texture.resource_path == "res://assets/visual/arcane/accueil.png","illustration originale de l'accueil chargee")
	exiger(accueil.find_children("*","SubViewport",true,false).is_empty(),"aucun rendu 3D dans l'accueil")
	var onglets: Array = menu.get("_onglets")
	var rectangle: Rect2 = onglets[0].get_global_rect()
	await create_timer(.7).timeout
	exiger(rectangle == onglets[0].get_global_rect(),"navigation immobile")
	var style_arcane: Script = load("res://scripts/presentation/style_azur.gd")
	for catalogue in [CatalogueReactifs.TOUS, ArbreCompetences.NOEUDS, Sorts.ACTIFS, Sorts.PASSIFS, Sorts.ULTIMES]:
		for identifiant in catalogue:
			exiger(IconesArcane.contient(str(identifiant)),"illustration du catalogue : "+str(identifiant))
			var icone := style_arcane.glyphe(str(identifiant)) as AtlasTexture
			exiger(icone != null and Rect2(Vector2.ZERO,icone.atlas.get_size()).encloses(icone.region),"region d'icone valide : "+str(identifiant))
	if DisplayServer.get_name() != "headless": root.get_texture().get_image().save_png("res://tmp/azur-accueil-final.png")
	menu.queue_free()
	await attendre()
	await verifier_reglages_en_pause()
	print("INTERFACE_AZUR : %d controles, %d echecs" % [controles,echecs])
	quit(1 if echecs else 0)

func verifier_reglages_en_pause() -> void:
	var style: Script = load("res://scripts/presentation/style_azur.gd")
	var pause := page("pause")
	pause.process_mode = Node.PROCESS_MODE_ALWAYS
	paused = true
	pause.call("_ouvrir_reglages")
	await attendre()
	var reglages: Control = pause.get("_reglages")
	exiger(reglages.can_process(),"parametres utilisables pendant la pause")
	var selecteurs := reglages.find_children("*","OptionButton",true,false)
	exiger(selecteurs.size()==3,"musiques et raccourci accessibles")
	for selecteur: OptionButton in selecteurs:
		var liste := selecteur.get_popup()
		exiger(liste.get_theme_color("font_color")==style.ENCRE,"listes lisibles sur fond arcane")
		exiger(liste.get_theme_stylebox("panel") is StyleBoxFlat,"cadre manga sans texture realiste dans les listes")
		liste.popup()
		await attendre()
		exiger(liste.visible,"liste ouvrable en pause")
		exiger(liste.max_size.y <= root.get_visible_rect().size.y,"hauteur de liste bornee")
		liste.hide()
		var index := mini(1,selecteur.item_count-1)
		selecteur.select(index)
		selecteur.item_selected.emit(index)
	exiger(regles.piste_musique==str(selecteurs[0].get_item_metadata(selecteurs[0].selected)),"musique de combat selectionnee")
	exiger(regles.piste_menu==str(selecteurs[1].get_item_metadata(selecteurs[1].selected)),"musique du menu selectionnee")
	exiger(regles.raccourci_sort==str(selecteurs[2].get_item_metadata(selecteurs[2].selected)),"raccourci selectionne")
	var volumes := reglages.find_children("*","HSlider",true,false)
	volumes[0].value = .31
	volumes[1].value = .64
	exiger(is_equal_approx(regles.volume_musique,.31) and is_equal_approx(regles.volume_effets,.64),"volumes independants en pause")
	reglages.emit_signal("ferme")
	await attendre()
	exiger(pause.get("_reglages")==null and paused,"retour aux commandes de pause sans reprise du combat")
	paused = false
	pause.queue_free()
	await attendre()
