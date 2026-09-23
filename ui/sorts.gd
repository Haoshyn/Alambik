extends Control
signal ferme
var integre_menu := false
var _categorie := "Actifs"
var _message := ""
var _cartes: VBoxContainer
var _statut: Label
var _collection: Label
var _fiche_popup: FenetreFiche
var _slots: Array[Button] = []
var _icones_slots: Array[TextureRect] = []
var _textes_slots: Array[Label] = []
var _categories: Dictionary = {}

func _ready() -> void:
	var col := StyleAzur.page(self,"Sorts",integre_menu)
	StyleAzur.banniere(col, "Le grimoire vivant", "6 sorts actifs, 8 passifs et 4 ultimes à découvrir. Préparez un actif, deux passifs et un ultime.", "grimoire")
	var infos := StyleAzur.cartouche_infos(col, StyleAzur.MENTHE)
	_collection = StyleAzur.texte("", 26, StyleAzur.IVOIRE)
	infos.add_child(_collection)
	var categories := BoxContainer.new()
	StyleAzur.adapter_ligne(categories)
	categories.add_theme_constant_override("separation", 14)
	for cat in ["Actifs","Passifs","Ultimes"]:
		var bouton := StyleAzur.bouton(cat,func(): _afficher(cat))
		categories.add_child(bouton)
		_categories[cat] = bouton
	col.add_child(StyleAzur.texte("Sorts équipés", 34, StyleAzur.IVOIRE))
	var equipe := GridContainer.new()
	equipe.columns = 4
	equipe.add_theme_constant_override("h_separation", 18)
	equipe.add_theme_constant_override("v_separation", 12)
	StyleAzur.adapter_grille(equipe, 152.0, 4)
	col.add_child(equipe)
	for i in 4:
		var b := StyleAzur.bouton("",func(): _retirer_slot(i))
		b.custom_minimum_size = Vector2(136,136)
		b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		var bloc := VBoxContainer.new()
		bloc.custom_minimum_size.x = 152
		bloc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bloc.add_theme_constant_override("separation", 4)
		equipe.add_child(bloc)
		bloc.add_child(b)
		var marge := MarginContainer.new()
		marge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		marge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for cote in ["left", "right", "top", "bottom"]: marge.add_theme_constant_override("margin_" + cote, 26)
		b.add_child(marge)
		var composition := VBoxContainer.new()
		composition.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		composition.add_theme_constant_override("separation", 4)
		composition.mouse_filter = Control.MOUSE_FILTER_IGNORE
		marge.add_child(composition)
		var illustration := StyleAzur.vignette("onde_alchimique", 58)
		illustration.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		composition.add_child(illustration)
		_icones_slots.append(illustration)
		var legende := StyleAzur.texte("", 24, StyleAzur.IVOIRE)
		legende.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bloc.add_child(legende)
		_textes_slots.append(legende)
		_slots.append(b)
	col.add_child(categories)
	_statut = StyleAzur.texte("",26,StyleAzur.IVOIRE)
	col.add_child(_statut)
	_cartes = StyleAzur.defilement(col)
	_rafraichir()
	Capture.programmer(self)

func _rendre() -> void:
	var debloques := ReglagesJoueur.nombre_capacites_debloquees()
	_collection.text = "%d / %d capacités · %d / %d Cœurs de mana" % [debloques, Sorts.nombre_capacites_debloquees({}, true), ReglagesJoueur.nombre_coeurs_mana(), Epreuves.nombre()]
	_statut.text = _message
	_statut.visible = not _message.is_empty()
	for cat: String in _categories:
		var symbole: String = {"Actifs":"onde_alchimique", "Passifs":"sagesse", "Ultimes":"grand_oeuvre"}[cat]
		StyleAzur.onglet_symbolique(_categories[cat], StyleAzur.glyphe(symbole), cat == _categorie)
		if cat == _categorie:
			var accent := _couleur_categorie(cat)
			_categories[cat].add_theme_color_override("font_color", accent)
			_categories[cat].add_theme_color_override("icon_normal_color", accent)
	var passifs := ReglagesJoueur.passifs_equipes
	var equipes := [ReglagesJoueur.sort_actif_equipe,str(passifs[0]) if passifs.size()>0 else "",str(passifs[1]) if passifs.size()>1 else "",ReglagesJoueur.ultime_equipe]
	for i in 4:
		var vide := str(equipes[i]).is_empty()
		var legende: String = ["Actif","Passif I","Passif II","Ultime"][i]
		_textes_slots[i].text = legende if vide else "%s\n%s" % [legende, str(Sorts.donnees(equipes[i]).get("nom", ""))]
		_textes_slots[i].add_theme_color_override("font_color", _couleur_categorie(["Actifs", "Passifs", "Passifs", "Ultimes"][i]))
		_slots[i].tooltip_text = str(Sorts.donnees(equipes[i]).get("nom","Vide")) if not str(equipes[i]).is_empty() else "Emplacement vide"
		_slots[i].accessibility_name = legende + " · " + _slots[i].tooltip_text
		_icones_slots[i].texture = StyleAzur.glyphe(["onde_alchimique", "sagesse", "endurance", "grand_oeuvre"][i]) if vide else StyleAzur.glyphe(str(equipes[i]))
		_icones_slots[i].modulate = Color("a9b4ce") if vide else Color.WHITE
		_slots[i].self_modulate = Color("a9b4ce") if vide else Color.WHITE
		for etat in ["normal", "hover", "pressed", "disabled"]:
			_slots[i].add_theme_stylebox_override(etat, StyleAzur.cercle(not vide))
	for enfant in _cartes.get_children():
		_cartes.remove_child(enfant)
		enfant.queue_free()
	var ids := _ids()
	var grille := GridContainer.new()
	grille.columns = 2
	grille.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grille.add_theme_constant_override("h_separation", 18)
	grille.add_theme_constant_override("v_separation", 18)
	StyleAzur.adapter_grille(grille, 300.0, 2)
	_cartes.add_child(grille)
	for i in ids.size():
		var id := ids[i]
		var d: Dictionary = _catalogue()[id]
		var ouvert := ReglagesJoueur.sort_debloque(id)
		var equipe := id == ReglagesJoueur.sort_actif_equipe or id == ReglagesJoueur.ultime_equipe or id in ReglagesJoueur.passifs_equipes
		var accent := _couleur_categorie(_categorie)
		var b := StyleAzur.bouton("", _ouvrir_fiche.bind(i))
		b.custom_minimum_size = Vector2(300, 190)
		StyleAzur.case_objet(b, equipe)
		b.tooltip_text = str(d["nom"])
		b.accessibility_name = str(d["nom"])
		for etat in ["normal", "hover", "pressed"]:
			var style := b.get_theme_stylebox(etat) as StyleBoxTexture
			style.modulate_color = Color.WHITE.lerp(accent, 0.24 if equipe else 0.14)
		grille.add_child(b)
		var filet := ColorRect.new()
		filet.color = Color(accent, 0.86 if ouvert else 0.56)
		filet.position = Vector2(30, 22)
		filet.size = Vector2(100, 3)
		filet.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(filet)
		var marge := MarginContainer.new()
		marge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		marge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for cote in ["left", "right", "top", "bottom"]: marge.add_theme_constant_override("margin_" + cote, 24)
		b.add_child(marge)
		var ligne := HBoxContainer.new()
		ligne.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ligne.add_theme_constant_override("separation", 14)
		marge.add_child(ligne)
		var icone := StyleAzur.vignette(id, 104)
		icone.modulate = Color.WHITE if ouvert else Color("8995b5")
		icone.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		ligne.add_child(icone)
		var textes := VBoxContainer.new()
		textes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		textes.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		textes.add_theme_constant_override("separation", 8)
		ligne.add_child(textes)
		textes.add_child(StyleAzur.texte(str(d["nom"]), 30, StyleAzur.IVOIRE))
		var statut := "Équipé" if equipe else ("Rang %d / %d" % [ReglagesJoueur.rang_sort(id), Sorts.rang_max(id)] if ouvert else "À découvrir")
		textes.add_child(StyleAzur.texte(statut, 24, accent if ouvert else accent.darkened(0.12)))

func _ouvrir_fiche(index: int) -> void:
	var id := _ids()[index]
	var donnees: Dictionary = _catalogue()[id]
	if is_instance_valid(_fiche_popup): _fiche_popup.queue_free()
	var fiche := FenetreFiche.new()
	var parent_fiche: Node = get_parent().get_parent() if integre_menu else self
	parent_fiche.add_child(fiche)
	_fiche_popup = fiche
	fiche.configurer(str(donnees["nom"]), id)
	var contenu := fiche.contenu
	contenu.add_child(StyleAzur.texte(_categorie.trim_suffix("s") + " · " + ("Débloqué" if ReglagesJoueur.sort_debloque(id) else "À découvrir"), 25, _couleur_categorie(_categorie)))
	var lecture := StyleAzur.plaque(contenu)
	lecture.add_child(StyleAzur.texte(str(donnees["description"]), 29))
	var rang := ReglagesJoueur.rang_sort(id)
	lecture.add_child(StyleAzur.texte("Rang %d / %d · %s" % [rang, Sorts.rang_max(id), Sorts.resume_rang(id, rang)], 26))
	lecture.add_child(StyleAzur.texte(Sorts.progression_rang(id), 24))
	if donnees.has("recharge"):
		lecture.add_child(StyleAzur.texte("Récupération : %s s" % String.num(ReglagesJoueur.recharge_sort(id), 1), 26))
	var equipe := id == ReglagesJoueur.sort_actif_equipe or id == ReglagesJoueur.ultime_equipe or id in ReglagesJoueur.passifs_equipes
	if ReglagesJoueur.sort_debloque(id):
		contenu.add_child(StyleAzur.bouton("Retirer" if equipe else "Équiper", func():
			_choisir_index(index)
			fiche.fermer(), true))
	else:
		lecture.add_child(StyleAzur.texte(Epreuves.provenance(id), 26))

func fermer_fiche() -> bool:
	if not is_instance_valid(_fiche_popup) or not _fiche_popup.visible: return false
	_fiche_popup.fermer()
	return true

func _exit_tree() -> void:
	if is_instance_valid(_fiche_popup): _fiche_popup.queue_free()

func _couleur_categorie(categorie: String) -> Color:
	match categorie:
		"Passifs": return StyleAzur.LILAS
		"Ultimes": return StyleAzur.CUIVRE
	return StyleAzur.MAGIE

func _catalogue() -> Dictionary:
	match _categorie:
		"Passifs": return Sorts.PASSIFS
		"Ultimes": return Sorts.ULTIMES
	return Sorts.ACTIFS

func _ids() -> Array[String]:
	var ids: Array[String] = []
	for id in _catalogue(): ids.append(id)
	return ids

func _afficher(categorie: String) -> void:
	if categorie == _categorie:
		return
	_categorie = categorie
	_message = ""
	Sons.jouer("choix", -17.0)
	_rafraichir()

func _choisir_index(index: int) -> void:
	var ids := _ids()
	if index >= ids.size():
		return
	var id := ids[index]
	if not ReglagesJoueur.sort_debloque(id):
		_message = "%s : %s." % [str(_catalogue()[id]["nom"]), Epreuves.provenance(id)]
		_rendre()
		return
	if _categorie == "Actifs":
		if id == ReglagesJoueur.sort_actif_equipe:
			ReglagesJoueur.retirer_sort("actif")
			_message = "%s retiré." % str(Sorts.ACTIFS[id]["nom"])
		else:
			ReglagesJoueur.equiper_sort(id, "actif")
			_message = "%s équipé comme Sort actif." % str(Sorts.ACTIFS[id]["nom"])
	elif _categorie == "Ultimes":
		if id == ReglagesJoueur.ultime_equipe:
			ReglagesJoueur.retirer_sort("ultime")
			_message = "%s retiré." % str(Sorts.ULTIMES[id]["nom"])
		else:
			ReglagesJoueur.equiper_sort(id, "ultime")
			_message = "%s équipé comme Ultime." % str(Sorts.ULTIMES[id]["nom"])
	else:
		var resultat := ReglagesJoueur.basculer_passif(id)
		match resultat:
			"equipe": _message = "%s équipé." % str(Sorts.PASSIFS[id]["nom"])
			"retire": _message = "%s retiré." % str(Sorts.PASSIFS[id]["nom"])
			"plein": _message = "Tous les emplacements Passifs sont occupés."
	Sons.jouer("choix", -12.0)
	_rafraichir()

func _retirer_slot(index: int) -> void:
	var id := ""
	if index == 0:
		id = ReglagesJoueur.sort_actif_equipe
		if not id.is_empty(): ReglagesJoueur.retirer_sort("actif")
	elif index == 3:
		id = ReglagesJoueur.ultime_equipe
		if not id.is_empty(): ReglagesJoueur.retirer_sort("ultime")
	elif index - 1 < ReglagesJoueur.passifs_equipes.size():
		id = str(ReglagesJoueur.passifs_equipes[index - 1])
		ReglagesJoueur.basculer_passif(id)
	if id.is_empty():
		return
	_message = "%s retiré." % str(Sorts.donnees(id).get("nom", "Sort"))
	Sons.jouer("choix", -12.0)
	_rafraichir()

func _rafraichir() -> void:
	_rendre()
