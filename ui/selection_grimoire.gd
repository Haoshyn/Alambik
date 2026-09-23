extends Control
signal ferme
signal selection_changee
signal epreuve_lancement_demande
const TRANSITION := preload("res://ui/transition_grimoire.tscn")
var selection_seulement := false
var lancer_epreuve_apres_choix := false
var mode_initial := ""
var _defilement: ScrollContainer
var _monde := 0
var _chapitre_monde := 0
var _message := ""
var _lancement := false
var _zones_chapitres: Array[Button] = []
var _icones_chapitres: Array[TextureRect] = []
var _textes_chapitres: Array[Label] = []
var _bouton_selectionner: Button
var _bouton_mine: Button
var _bouton_epreuve: Button
var _titre: Label
var _details: Label
var _liste_epreuves: VBoxContainer
var _apercu: Control
var _monde_sous_titre: Label
var _embleme_monde: TextureRect
var _precedent: Button
var _suivant: Button

func _ready() -> void:
	_monde = clampi(ReglagesJoueur.chapitre_choisi / Chapitres.CHAPITRES_PAR_MONDE, 0, Chapitres.MONDES.size() - 1)
	_chapitre_monde = posmod(ReglagesJoueur.chapitre_choisi, Chapitres.CHAPITRES_PAR_MONDE)
	var col := StyleAzur.page(self, "Campagne & modes")
	var contenu := StyleAzur.defilement(col)
	_defilement = contenu.get_parent() as ScrollContainer
	var atlas := StyleAzur.plaque(contenu, true)
	var monde := HBoxContainer.new()
	monde.add_theme_constant_override("separation", 22)
	atlas.add_child(monde)
	_embleme_monde = StyleAzur.illustration("portail", 176)
	monde.add_child(_embleme_monde)
	var textes := VBoxContainer.new()
	textes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textes.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	monde.add_child(textes)
	textes.add_child(StyleAzur.texte("L’ATLAS DES MONDES", 23, StyleAzur.CUIVRE))
	_titre = StyleAzur.texte("", 38)
	textes.add_child(_titre)
	_monde_sous_titre = StyleAzur.texte("", 27, StyleAzur.ATTENUE)
	textes.add_child(_monde_sous_titre)
	var navigation := BoxContainer.new()
	StyleAzur.adapter_ligne(navigation)
	navigation.add_theme_constant_override("separation", 18)
	atlas.add_child(navigation)
	_precedent = StyleAzur.bouton("‹ Monde précédent", func(): _changer_monde(-1))
	_suivant = StyleAzur.bouton("Monde suivant ›", func(): _changer_monde(1))
	navigation.add_child(_precedent)
	navigation.add_child(_suivant)
	contenu.add_child(StyleAzur.texte("CHOISISSEZ VOTRE NIVEAU", 24, StyleAzur.CUIVRE))
	var chemin := GridContainer.new()
	chemin.columns = 3
	StyleAzur.adapter_grille(chemin, 240.0, 3)
	chemin.add_theme_constant_override("h_separation", 14)
	chemin.add_theme_constant_override("v_separation", 14)
	contenu.add_child(chemin)
	for i in Chapitres.CHAPITRES_PAR_MONDE:
		var bouton := StyleAzur.bouton("", func(): _choisir_chapitre(i))
		bouton.custom_minimum_size.y = 180
		var marge := MarginContainer.new()
		marge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		marge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for cote in ["left", "right"]: marge.add_theme_constant_override("margin_" + cote, 44)
		for cote in ["top", "bottom"]: marge.add_theme_constant_override("margin_" + cote, 44)
		bouton.add_child(marge)
		var composition := VBoxContainer.new()
		composition.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		composition.add_theme_constant_override("separation", 6)
		composition.mouse_filter = Control.MOUSE_FILTER_IGNORE
		marge.add_child(composition)
		var illustration := StyleAzur.illustration("couronne" if i == Chapitres.CHAPITRES_PAR_MONDE - 1 else "portail", 74)
		illustration.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		composition.add_child(illustration)
		_icones_chapitres.append(illustration)
		var legende := StyleAzur.texte("", 25, StyleAzur.IVOIRE)
		legende.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		composition.add_child(legende)
		_textes_chapitres.append(legende)
		marge.minimum_size_changed.connect(func(): bouton.custom_minimum_size.y = maxf(180.0, marge.get_combined_minimum_size().y))
		chemin.add_child(bouton)
		_zones_chapitres.append(bouton)
	var selection := StyleAzur.plaque(contenu, true)
	selection.add_child(StyleAzur.texte("LE NIVEAU SÉLECTIONNÉ", 23, StyleAzur.MAGIE))
	_details = StyleAzur.texte("", 29)
	selection.add_child(_details)
	var actions := BoxContainer.new()
	StyleAzur.adapter_ligne(actions)
	actions.add_theme_constant_override("separation", 14)
	selection.add_child(actions)
	_bouton_selectionner = StyleAzur.bouton("Choisir ce niveau" if selection_seulement else "Jouer ce niveau", _selectionner, true)
	actions.add_child(_bouton_selectionner)
	var recompenses := StyleAzur.bouton("Butin", func(): _voir_loots("grimoire", _index_selectionne()))
	recompenses.size_flags_horizontal = Control.SIZE_FILL
	recompenses.custom_minimum_size.x = 190
	actions.add_child(recompenses)
	StyleAzur.separateur(contenu)
	StyleAzur.banniere(contenu, "Au-delà de la campagne", "Des pierres pour la forge. Des sorts pour votre grimoire.", "astrolabe")
	var mine := StyleAzur.plaque(contenu)
	var presentation_mine := HBoxContainer.new()
	presentation_mine.add_theme_constant_override("separation", 18)
	mine.add_child(presentation_mine)
	presentation_mine.add_child(StyleAzur.illustration("forge", 122))
	var texte_mine := StyleAzur.texte("La Mine\nRécoltez les pierres qui éveillent vos bijoux.", 28)
	texte_mine.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	presentation_mine.add_child(texte_mine)
	var ligne_mine := BoxContainer.new()
	StyleAzur.adapter_ligne(ligne_mine)
	ligne_mine.add_theme_constant_override("separation", 14)
	mine.add_child(ligne_mine)
	_bouton_mine = StyleAzur.bouton("Choisir la Mine", func(): _choisir_mode("mine"))
	StyleAzur.habiller_mode(_bouton_mine, "mine")
	ligne_mine.add_child(_bouton_mine)
	var info_mine := StyleAzur.bouton("Butin", func(): _voir_loots("mine"))
	info_mine.size_flags_horizontal = Control.SIZE_FILL
	info_mine.custom_minimum_size.x = 190
	ligne_mine.add_child(info_mine)
	var epreuve := StyleAzur.plaque(contenu)
	var presentation_epreuve := HBoxContainer.new()
	presentation_epreuve.add_theme_constant_override("separation", 18)
	epreuve.add_child(presentation_epreuve)
	presentation_epreuve.add_child(StyleAzur.illustration("astrolabe", 122))
	var texte_epreuve := StyleAzur.texte("Épreuves de magie\nCinq boss. Un grimoire à enrichir.", 28)
	texte_epreuve.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	presentation_epreuve.add_child(texte_epreuve)
	_bouton_epreuve = StyleAzur.bouton("Explorer les épreuves", func(): _choisir_mode("epreuve_sorts"))
	StyleAzur.habiller_mode(_bouton_epreuve, "epreuve_sorts")
	epreuve.add_child(_bouton_epreuve)
	_liste_epreuves = VBoxContainer.new()
	_liste_epreuves.add_theme_constant_override("separation", 18)
	epreuve.add_child(_liste_epreuves)
	_liste_epreuves.visible = ReglagesJoueur.mode_run_choisi == "epreuve_sorts"
	_liste_epreuves.add_child(StyleAzur.texte("Une augmentation entre chaque boss. Chaque niveau cache un Cœur de mana unique : +10 % de dégâts finaux.", 25, StyleAzur.ATTENUE))
	var epreuves_ouvertes := ReglagesJoueur.mode_debloque("epreuve_sorts")
	for i in Epreuves.nombre():
		var niveau := i + 1
		var fiche := StyleAzur.plaque(_liste_epreuves)
		var noms: Array[String] = []
		var symboles := HBoxContainer.new()
		fiche.add_child(symboles)
		for id in Epreuves.sorts(niveau):
			noms.append(str(Sorts.donnees(str(id))["nom"]))
			symboles.add_child(StyleAzur.vignette(str(id), 76))
		fiche.add_child(StyleAzur.texte("Niveau %d · %s\nCœur de mana : %s" % [niveau,
			" / ".join(noms), "obtenu" if ReglagesJoueur.coeur_mana_obtenu(niveau) else "à trouver"], 27))
		var ligne := HBoxContainer.new()
		ligne.add_theme_constant_override("separation", 14)
		fiche.add_child(ligne)
		var bouton := StyleAzur.bouton("Choisir l’épreuve", func(): _choisir_epreuve(niveau))
		StyleAzur.habiller_mode(bouton, "epreuve_sorts")
		bouton.disabled = not epreuves_ouvertes or (not ReglagesJoueur.mode_dev and niveau > ReglagesJoueur.niveau_epreuve_debloque)
		if not epreuves_ouvertes:
			bouton.text = "Niveau %d de campagne requis" % Reglages.EPREUVE_NIVEAU_DEBLOCAGE
		elif bouton.disabled:
			bouton.text = "Terminez le niveau précédent"
		ligne.add_child(bouton)
		var info := StyleAzur.bouton("Butin", func(): _voir_loots("epreuve_sorts", 0, niveau))
		info.size_flags_horizontal = Control.SIZE_FILL
		info.custom_minimum_size.x = 190
		ligne.add_child(info)
	_rafraichir()
	if not mode_initial.is_empty(): _ouvrir_mode_initial()
	Capture.programmer(self)

func _ouvrir_mode_initial() -> void:
	if mode_initial == "epreuve_sorts": _liste_epreuves.show()
	# L'acces direct doit montrer le mode vise sans refaire defiler l'atlas.
	await get_tree().process_frame
	if is_instance_valid(_defilement):
		var section: Control = _bouton_epreuve if mode_initial == "epreuve_sorts" else _bouton_mine
		while section != null and not section is PanelContainer:
			section = section.get_parent() as Control
		if section != null:
			var decalage := section.global_position.y - _defilement.global_position.y
			_defilement.scroll_vertical = maxi(0, _defilement.scroll_vertical + roundi(decalage) - 24)

func _choisir_mode(mode: String) -> void:
	if _lancement:
		return
	if not ReglagesJoueur.mode_debloque(mode):
		_message = "Terminez davantage de niveaux pour ouvrir ce mode."
		_rafraichir()
		return
	if mode == "epreuve_sorts":
		_liste_epreuves.visible = not _liste_epreuves.visible
		return
	ReglagesJoueur.choisir_mode_run(mode)
	selection_changee.emit()
	_fermer()

func _rafraichir() -> void:
	var monde: Dictionary = Chapitres.MONDES[_monde]
	_titre.text = "Monde %d · %s" % [_monde + 1, monde["nom"]]
	_monde_sous_titre.text = str(monde["sous_titre"])
	var teinte: Color = monde["teinte"]
	_embleme_monde.modulate = Color.WHITE.lerp(teinte, 0.25)
	_precedent.disabled = _monde == 0
	_suivant.disabled = _monde == Chapitres.MONDES.size() - 1
	for i in Chapitres.CHAPITRES_PAR_MONDE:
		var index := _monde * Chapitres.CHAPITRES_PAR_MONDE + i
		var accessible := ReglagesJoueur.chapitre_debloque(index)
		var legende := "Niveau %d\n%s" % [i + 1, "Sélectionné" if i == _chapitre_monde else "Accessible" if accessible else "Verrouillé"]
		_textes_chapitres[i].text = legende
		_zones_chapitres[i].accessibility_name = legende.replace("\n", " · ")
		_zones_chapitres[i].tooltip_text = legende.replace("\n", " · ")
		# L'etat verrouille attenue le decor, jamais la legende qui l'explique.
		_zones_chapitres[i].self_modulate = Color.WHITE if accessible else Color("a9b4ce")
		_icones_chapitres[i].modulate = Color.WHITE if accessible else Color("a9b4ce")
		StyleAzur.case_objet(_zones_chapitres[i], i == _chapitre_monde)
	_bouton_selectionner.disabled = not ReglagesJoueur.chapitre_debloque(_index_selectionne())
	_bouton_epreuve.disabled = not ReglagesJoueur.mode_debloque("epreuve_sorts")
	_bouton_mine.disabled = not ReglagesJoueur.mode_debloque("mine")
	_bouton_epreuve.text = "Explorer les épreuves" if not _bouton_epreuve.disabled else "Niveau %d de campagne requis" % Reglages.EPREUVE_NIVEAU_DEBLOCAGE
	_bouton_mine.text = "Choisir la Mine" if not _bouton_mine.disabled else "Niveau %d de campagne requis" % Reglages.MINE_NIVEAU_DEBLOCAGE
	var chapitre := Chapitres.par_index(_index_selectionne())
	_details.text = "%s\nMeilleur étage : %d / %d" % [chapitre["nom"], ReglagesJoueur.meilleure_du_chapitre(_index_selectionne()), chapitre["salles"]]
	if not _message.is_empty(): _details.text += "\n" + _message

func _index_selectionne() -> int:
	return _monde * Chapitres.CHAPITRES_PAR_MONDE + _chapitre_monde

func _changer_monde(direction: int) -> void:
	var nouveau := clampi(_monde + direction, 0, Chapitres.MONDES.size() - 1)
	if nouveau == _monde:
		return
	_monde = nouveau
	_message = ""
	# Conserver le numero de niveau rend la comparaison entre mondes naturelle.
	# Si celui-ci est verrouille, la fiche le dit sans modifier le choix en cachette.
	Sons.jouer("choix", -16.0, 1.0 + float(direction) * 0.04)
	_rafraichir()

func _choisir_chapitre(index: int) -> void:
	if _lancement: return
	_chapitre_monde = clampi(index, 0, Chapitres.CHAPITRES_PAR_MONDE - 1)
	var chapitre := _index_selectionne()
	_message = "" if ReglagesJoueur.chapitre_debloque(chapitre) else "Ce niveau est encore verrouillé."
	Sons.jouer("choix", -16.0)
	_rafraichir()

func _selectionner() -> void:
	if _lancement: return
	var index := _index_selectionne()
	if not ReglagesJoueur.chapitre_debloque(index):
		_message = "Terminez le niveau précédent pour ouvrir celui-ci."
		_rafraichir()
		return
	ReglagesJoueur.choisir_mode_run("grimoire")
	ReglagesJoueur.choisir_chapitre(index)
	Sons.jouer("choix", -10.0)
	if selection_seulement:
		selection_changee.emit()
		_fermer()
	else:
		_lancer_chapitre(index)

func _lancer_chapitre(index: int) -> void:
	if _lancement:
		return
	_lancement = true
	Sons.demarrer_musique_combat()
	var transition := TRANSITION.instantiate()
	transition.configurer(Chapitres.par_index(index))
	add_child(transition)
	transition.terminee.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/run.tscn"))

func _fermer() -> void:
	if _lancement:
		return
	Sons.jouer("choix", -14.0)
	StyleInterface.sortir_puis(self, func() -> void: ferme.emit())

func _choisir_epreuve(niveau: int) -> void:
	if not ReglagesJoueur.choisir_epreuve(niveau): return
	selection_changee.emit()
	if lancer_epreuve_apres_choix:
		epreuve_lancement_demande.emit()
	else:
		_fermer()

func _voir_loots(mode: String, chapitre := 0, niveau := 1) -> void:
	if is_instance_valid(_apercu): return
	_apercu = preload("res://ui/apercu_butin.gd").new()
	_apercu.mode = mode
	_apercu.chapitre = chapitre
	_apercu.niveau_epreuve = niveau
	add_child(_apercu)
	_apercu.ferme.connect(func():
		_apercu.queue_free()
		_apercu = null)
