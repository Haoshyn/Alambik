extends Node

const MENU := preload("res://scenes/menu.tscn")
const ECRAN_PASSIFS := preload("res://ui/passifs.gd")

var _erreurs: Array[String] = []
var _controles := 0
var _racine: Window

func _ready() -> void:
	_racine = get_tree().root
	_demarrer.call_deferred()

func _demarrer() -> void:
	if "verification" not in OS.get_user_data_dir().to_lower():
		push_error("Ce controle exige un profil de verification isole.")
		get_tree().quit(1)
		return
	ReglagesJoueur.sauvegarde_active = false
	ReglagesJoueur.specialisation = "sorcier"
	ReglagesJoueur.mode_dev = false
	ReglagesJoueur.effets_reduits = true
	ReglagesJoueur.volume_musique = 0.0
	ReglagesJoueur.volume_effets = 0.0
	Sons.appliquer_reglages()
	_verifier_glyphes()
	for format: Vector2i in [Vector2i(1080, 1920), Vector2i(1080, 2340), Vector2i(720, 1280)]:
		_racine.content_scale_size = format
		_racine.size = format
		ReglagesJoueur.rangs_passifs.clear()
		ReglagesJoueur.passifs_equipes.clear()
		var menu := MENU.instantiate()
		_racine.add_child(menu)
		menu.call("_afficher_page", 4, false)
		await _attendre_cadrage()
		var page: Control = menu.get("_page_actuelle")
		_verifier_cadrage(page, format)
		_verifier_textes_libres(page)
		if format == Vector2i(1080, 1920): await _verifier_animations(page)
		var slots: Array = page.get("_slots")
		_exiger(slots.size() == Passifs.EMPLACEMENTS, "Quatre emplacements disponibles")
		_exiger(page.find_child("VoilePassifs", true, false) == null, "Aucun voile propre aux passifs")
		var fond: Control = menu.get("_fond_menu")
		_exiger(is_equal_approx(float(fond.get("_voile_cible")), 0.30), "Meme lecture de la clairiere que les autres pages")
		var cartes: GridContainer = page.get("_cartes")
		_exiger(cartes.get_child_count() == Passifs.CATALOGUE.size(), "Catalogue complet sans acquisition")
		await _verifier_glissement(page)
		var verrouille: Button = cartes.get_child(0).find_child("Details_vigueur", true, false)
		verrouille.pressed.emit()
		await _attendre_cadrage()
		var fiche: FenetreFiche = page.get("_fiche_popup")
		_exiger(fiche.contenu.find_children("*", "Button", true, false).is_empty(), "Aucune action d'equipement sur un passif verrouille")
		_exiger(_contient_texte(fiche.contenu, Epreuves.provenance("vigueur")), "Provenance d'Epreuve visible")
		_exiger(bool(page.call("fermer_fiche")), "Fermeture de la fiche verrouillee")
		await _attendre_cadrage()
		for id: String in Passifs.CATALOGUE:
			ReglagesJoueur.rangs_passifs[id] = Passifs.RANG_MAX
		page.call("_rafraichir")
		await _attendre_cadrage()
		await _verifier_filtres_et_tri(page)
		await _verifier_equipement(page)
		_verifier_cadrage(page, format)
		_verifier_textes_libres(page)
		menu.queue_free()
		await _attendre_cadrage()
	# L'entree directe conserve aussi son retour et sa collection.
	var autonome := preload("res://ui/passifs.tscn").instantiate()
	_racine.add_child(autonome)
	await _attendre_cadrage()
	_exiger(autonome.find_child("CartoucheTitre", true, false) != null, "Titre de l'entree autonome")
	_verifier_cadrage(autonome, Vector2i(720, 1280))
	autonome.queue_free()
	await _attendre_cadrage()
	Sons.arreter()
	for erreur: String in _erreurs: push_error(erreur)
	print("Passifs : %d controles, %d erreurs ; SVG, trois formats, filtres, tri, fiches et equipement." % [_controles, _erreurs.size()])
	get_tree().quit(0 if _erreurs.is_empty() else 1)

func _verifier_glyphes() -> void:
	var chemins: Array[String] = []
	var contenus: Array[String] = []
	_exiger(ECRAN_PASSIFS.GLYPHES_PASSIFS.size() == Passifs.CATALOGUE.size(), "Un glyphe par passif")
	for id: String in Passifs.CATALOGUE:
		_exiger(ECRAN_PASSIFS.GLYPHES_PASSIFS.has(id), "Glyphe present : " + id)
		var texture: Texture2D = ECRAN_PASSIFS.GLYPHES_PASSIFS[id]
		var chemin := texture.resource_path
		_exiger(chemin.ends_with(".svg") and not chemins.has(chemin), "SVG distinct : " + id)
		var contenu := FileAccess.get_file_as_string(chemin)
		_exiger("<image" not in contenu and "base64" not in contenu and not contenus.has(contenu), "Source vectorielle autonome : " + id)
		chemins.append(chemin)
		contenus.append(contenu)

func _verifier_cadrage(page: Control, format: Vector2i) -> void:
	var defilement: ScrollContainer = page.get("_defilement_collection")
	var cartes: GridContainer = page.get("_cartes")
	var slots: Array = page.get("_slots")
	_exiger(defilement.size.y >= 180.0, "Collection lisible sur %s : %s" % [format, defilement.size])
	_exiger(defilement.get_global_rect().end.y <= page.size.y - Ecran.marge_basse(), "Collection dans la zone sure : " + str(format))
	for bouton: Button in slots:
		_exiger(bouton.get_global_rect().position.x >= 0.0 and bouton.get_global_rect().end.x <= page.size.x, "Emplacement dans l'ecran : " + str(format))
		_exiger(bouton.size.x >= Ecran.CIBLE_TACTILE, "Emplacement tactile : " + str(format))
	for carte: Control in cartes.get_children():
		_exiger(carte.get_global_rect().position.x >= 0.0 and carte.get_global_rect().end.x <= page.size.x, "Entree dans la largeur : " + str(carte.name))
		var nom: Label = carte.find_child("Nom_*", true, false)
		var description: Label = carte.find_child("Description_*", true, false)
		var etat: Label = carte.find_child("Etat_*", true, false)
		_exiger(nom.get_global_rect().end.y <= description.global_position.y and description.get_global_rect().end.y <= etat.global_position.y, "Textes sans chevauchement : " + str(carte.name))
		var id := str(carte.name).trim_prefix("Carte_")
		_exiger(description.text == Passifs.resume_rang(id, maxi(1, ReglagesJoueur.rang_passif(id)), ReglagesJoueur.niveau_compte_effectif()), "Bonus reel dans la collection : " + id)
	print("Cadrage passifs %s : collection=%s, colonnes=%d" % [format, defilement.size, cartes.columns])

func _verifier_textes_libres(page: Control) -> void:
	for label: Label in page.find_children("*", "Label", true, false):
		_exiger(label.get_theme_stylebox("normal") is StyleBoxEmpty, "Texte libre : " + str(label.name))

func _verifier_glissement(page: Control) -> void:
	var defilement: ScrollContainer = page.get("_defilement_collection")
	var origine := defilement.get_global_transform_with_canvas() * Vector2(defilement.size.x * 0.25, minf(120.0, defilement.size.y * 0.5))
	var toucher := InputEventScreenTouch.new()
	toucher.index = 0
	toucher.position = origine
	toucher.pressed = true
	Input.parse_input_event(toucher)
	await _attendre_cadrage()
	var glisser := InputEventScreenDrag.new()
	glisser.index = 0
	glisser.position = origine - Vector2(0, 96)
	glisser.relative = Vector2(0, -96)
	Input.parse_input_event(glisser)
	await _attendre_cadrage()
	_exiger(defilement.scroll_vertical >= 80, "Defilement tactile depuis une entree")
	var relacher := InputEventScreenTouch.new()
	relacher.index = 0
	relacher.position = glisser.position
	relacher.pressed = false
	Input.parse_input_event(relacher)
	await _attendre_cadrage()
	_exiger(not is_instance_valid(page.get("_fiche_popup")), "Le glissement n'ouvre pas de fiche")
	defilement.scroll_vertical = 0
	await _attendre_cadrage()

func _verifier_filtres_et_tri(page: Control) -> void:
	var cartes: GridContainer = page.get("_cartes")
	var categories: Dictionary = page.get("_categories")
	for categorie: String in categories:
		(categories[categorie] as Button).pressed.emit()
		await _attendre_cadrage()
		var nombre_attendu := 0
		for id: String in Passifs.CATALOGUE:
			var donnees: Dictionary = Passifs.CATALOGUE[id]
			if categorie == "Tous" or str(donnees["categorie"]) == categorie:
				nombre_attendu += 1
		_exiger(cartes.get_child_count() == nombre_attendu, "Filtre : " + categorie)
		_exiger((categories[categorie] as Button).button_pressed, "Filtre selectionne : " + categorie)
	page.call("_afficher", "Tous")
	var tri: OptionButton = page.find_child("TriCollection", true, false)
	tri.item_selected.emit(1)
	await _attendre_cadrage()
	var ids: Array = page.call("_ids")
	for index in range(1, ids.size()):
		var precedent: Dictionary = Passifs.donnees(str(ids[index - 1]))
		var courant: Dictionary = Passifs.donnees(str(ids[index]))
		_exiger(str(precedent["nom"]).nocasecmp_to(str(courant["nom"])) <= 0, "Tri alphabetique")
	ReglagesJoueur.rangs_passifs["vigueur"] = 1
	tri.item_selected.emit(2)
	await _attendre_cadrage()
	ids = page.call("_ids")
	_exiger(ids.back() == "vigueur", "Le rang inferieur suit les passifs maximaux")
	ReglagesJoueur.rangs_passifs["vigueur"] = Passifs.RANG_MAX
	tri.item_selected.emit(0)
	await _attendre_cadrage()

func _verifier_equipement(page: Control) -> void:
	var selection: Array[String] = ["vigueur", "vitalite", "celerite", "sang_froid"]
	for id: String in selection:
		var cartes: GridContainer = page.get("_cartes")
		var bouton: Button = cartes.find_child("Details_" + id, true, false)
		bouton.pressed.emit()
		await _attendre_cadrage()
		var fiche: FenetreFiche = page.get("_fiche_popup")
		var embleme: TextureRect = fiche.get("_embleme")
		_exiger(embleme.texture == ECRAN_PASSIFS.GLYPHES_PASSIFS[id], "Embleme de la fiche : " + id)
		var actions := fiche.contenu.find_children("*", "Button", true, false)
		_exiger(actions.size() == 1, "Action d'equipement : " + id)
		(actions[0] as Button).pressed.emit()
		await _attendre_cadrage()
	_exiger(ReglagesJoueur.passifs_equipes == selection, "Quatre passifs equipes depuis leurs fiches")
	page.call("_choisir_passif", "audace")
	_exiger(ReglagesJoueur.passifs_equipes == selection, "Cinquieme passif refuse")
	var icones: Array = page.get("_icones_slots")
	for index in selection.size():
		_exiger((icones[index] as TextureRect).texture == ECRAN_PASSIFS.GLYPHES_PASSIFS[selection[index]], "SVG de l'emplacement : " + str(index))
	var slots: Array = page.get("_slots")
	(slots[1] as Button).pressed.emit()
	_exiger("vitalite" not in ReglagesJoueur.passifs_equipes and ReglagesJoueur.passifs_equipes.size() == Passifs.EMPLACEMENTS - 1, "Retrait depuis un emplacement")
	page.call("_choisir_passif", "audace")
	_exiger("audace" in ReglagesJoueur.passifs_equipes, "Nouvel equipement apres retrait")
	await _attendre_cadrage()

func _contient_texte(parent: Node, texte: String) -> bool:
	for label: Label in parent.find_children("*", "Label", true, false):
		if label.text == texte: return true
	return false

func _verifier_animations(page: Control) -> void:
	ReglagesJoueur.effets_reduits = false
	var cartes: GridContainer = page.get("_cartes")
	var fond: Control = cartes.find_child("Ambiance_vigueur", true, false)
	fond.call("illuminer", true)
	await get_tree().create_timer(0.25).timeout
	_exiger(is_equal_approx(float(fond.get("_eclat")), 1.0), "Focus anime du filet")
	fond.call("illuminer", false)
	await get_tree().create_timer(0.25).timeout
	_exiger(is_zero_approx(float(fond.get("_eclat"))), "Retour du filet au repos")
	var bouton: Button = cartes.find_child("Details_vigueur", true, false)
	bouton.pressed.emit()
	await get_tree().create_timer(0.4).timeout
	var fiche: FenetreFiche = page.get("_fiche_popup")
	var panneau: Panel = fiche.get("_panneau")
	_exiger(panneau.scale.is_equal_approx(Vector2.ONE) and is_equal_approx(panneau.modulate.a, 1.0), "Ouverture animee de la fiche")
	page.call("fermer_fiche")
	await get_tree().create_timer(0.25).timeout
	_exiger(not is_instance_valid(page.get("_fiche_popup")), "Fermeture animee de la fiche")
	ReglagesJoueur.effets_reduits = true

func _attendre_cadrage() -> void:
	for image in 6: await get_tree().process_frame

func _exiger(condition: bool, contexte: String) -> void:
	_controles += 1
	if not condition: _erreurs.append(contexte)
