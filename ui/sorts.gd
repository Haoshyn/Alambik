extends Control
signal ferme
var integre_menu := false
var _categorie := "Actifs"
var _page := 0
var _message := ""
var _precedent: Button
var _suivant: Button
var _cartes: VBoxContainer
var _statut: Label
var _collection: Label
var _slots: Array[Button] = []
var _icones_slots: Array[TextureRect] = []
var _textes_slots: Array[Label] = []
var _categories: Dictionary = {}

func _ready() -> void:
	var col := StyleAzur.page(self,"Sorts",integre_menu)
	StyleAzur.banniere(col, "Le grimoire vivant", "6 sorts actifs, 10 passifs et 4 ultimes à découvrir. Préparez un actif, deux passifs et un ultime.", "grimoire")
	_collection = StyleAzur.texte("", 26, StyleAzur.MAGIE)
	col.add_child(_collection)
	var categories := HBoxContainer.new()
	categories.add_theme_constant_override("separation", 14)
	for cat in ["Actifs","Passifs","Ultimes"]:
		var bouton := StyleAzur.bouton(cat,func(): _afficher(cat))
		categories.add_child(bouton)
		_categories[cat] = bouton
	var equipe := GridContainer.new()
	equipe.columns = 4
	equipe.add_theme_constant_override("h_separation",12)
	var prepares := StyleAzur.plaque(col)
	prepares.add_child(StyleAzur.texte("VOTRE COMBINAISON",24,StyleAzur.CUIVRE))
	prepares.add_child(equipe)
	for i in 4:
		var b := StyleAzur.bouton("",func(): _retirer_slot(i))
		b.custom_minimum_size.y = 178
		var marge := MarginContainer.new()
		marge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		marge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for cote in ["left", "right", "top", "bottom"]: marge.add_theme_constant_override("margin_" + cote, 14)
		b.add_child(marge)
		var composition := VBoxContainer.new()
		composition.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		composition.add_theme_constant_override("separation", 4)
		composition.mouse_filter = Control.MOUSE_FILTER_IGNORE
		marge.add_child(composition)
		var illustration := StyleAzur.vignette("onde_alchimique", 70)
		illustration.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		composition.add_child(illustration)
		_icones_slots.append(illustration)
		var legende := StyleAzur.texte("", 22, StyleAzur.IVOIRE)
		legende.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		composition.add_child(legende)
		_textes_slots.append(legende)
		marge.minimum_size_changed.connect(func(): b.custom_minimum_size.y = maxf(178.0, marge.get_combined_minimum_size().y))
		equipe.add_child(b)
		_slots.append(b)
	col.add_child(categories)
	_statut = StyleAzur.texte("",26,StyleAzur.IVOIRE)
	col.add_child(_statut)
	_cartes = StyleAzur.defilement(col)
	var pagination := HBoxContainer.new()
	col.add_child(pagination)
	_precedent = StyleAzur.bouton("‹ Précédent",func(): _changer_page(-1))
	_suivant = StyleAzur.bouton("Suivant ›",func(): _changer_page(1))
	pagination.add_child(_precedent)
	pagination.add_child(_suivant)
	_rafraichir()
	Capture.programmer(self)

func _rendre() -> void:
	var debloques := ReglagesJoueur.nombre_capacites_debloquees()
	var bonus := roundi((ReglagesJoueur.multiplicateur_degats_deblocages() - 1.0) * 100.0)
	_collection.text = "%d / %d capacités débloquées · +%d %% de dégâts finaux\nChaque première découverte donne +%d %%, équipée ou non. Les rangs améliorent l’effet." % [debloques, Sorts.nombre_capacites_debloquees({}, true), bonus, roundi(Sorts.BONUS_FINAL_PAR_DEBLOCAGE * 100.0)]
	_statut.text = _message
	_statut.visible = not _message.is_empty()
	for cat: String in _categories:
		_categories[cat].add_theme_stylebox_override("normal",StyleAzur.cadre(StyleAzur.VIOLET if cat == _categorie else StyleAzur.PANNEAU, StyleAzur.MAGIE if cat == _categorie else StyleAzur.LILAS))
		_categories[cat].add_theme_color_override("font_color",StyleAzur.IVOIRE if cat == _categorie else StyleAzur.ENCRE)
	_precedent.get_parent().visible = _ids().size() > 6
	var passifs := ReglagesJoueur.passifs_equipes
	var equipes := [ReglagesJoueur.sort_actif_equipe,str(passifs[0]) if passifs.size()>0 else "",str(passifs[1]) if passifs.size()>1 else "",ReglagesJoueur.ultime_equipe]
	for i in 4:
		var vide := str(equipes[i]).is_empty()
		var legende: String = ["Actif","Passif I","Passif II","Ultime"][i]
		_textes_slots[i].text = legende + ("\nVide" if vide else "")
		_slots[i].tooltip_text = str(Sorts.donnees(equipes[i]).get("nom","Vide")) if not str(equipes[i]).is_empty() else "Emplacement vide"
		_slots[i].accessibility_name = legende + " · " + _slots[i].tooltip_text
		_icones_slots[i].texture = StyleAzur.glyphe(["onde_alchimique", "sagesse", "endurance", "grand_oeuvre"][i]) if vide else StyleAzur.glyphe(str(equipes[i]))
		_icones_slots[i].modulate = Color("a6afc5") if vide else Color.WHITE
		_slots[i].self_modulate = Color("a6afc5") if vide else Color.WHITE
		StyleAzur.case_objet(_slots[i],not str(equipes[i]).is_empty())
	for enfant in _cartes.get_children():
		_cartes.remove_child(enfant)
		enfant.queue_free()
	var ids := _ids_page()
	for i in ids.size():
		var id := ids[i]
		var d: Dictionary = _catalogue()[id]
		var b := StyleAzur.bouton("",func(): _choisir_index(i))
		b.custom_minimum_size.y = 230
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var marge := MarginContainer.new()
		marge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		for cote in ["left","right","top","bottom"]: marge.add_theme_constant_override("margin_"+cote,26)
		marge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(marge)
		var ligne := HBoxContainer.new()
		ligne.add_theme_constant_override("separation",24)
		ligne.mouse_filter = Control.MOUSE_FILTER_IGNORE
		marge.add_child(ligne)
		var sceau := PanelContainer.new()
		HabillagePeint.appliquer(sceau)
		sceau.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sceau.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		sceau.add_theme_stylebox_override("panel", StyleAzur.cadre(StyleAzur.VIOLET, StyleAzur.LILAS, 64))
		sceau.add_child(StyleAzur.vignette(id, 136))
		ligne.add_child(sceau)
		var texte := VBoxContainer.new()
		texte.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		texte.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ligne.add_child(texte)
		texte.add_child(StyleAzur.texte(str(d["nom"]),34))
		texte.add_child(StyleAzur.texte(str(d["description"]),27,StyleAzur.ATTENUE))
		var rang := ReglagesJoueur.rang_sort(id)
		texte.add_child(StyleAzur.texte(("Découverte acquise : +%d %% de dégâts finaux" if rang > 0 else "Première découverte : +%d %% de dégâts finaux") % roundi(Sorts.BONUS_FINAL_PAR_DEBLOCAGE * 100.0), 24, StyleAzur.CUIVRE))
		texte.add_child(StyleAzur.texte("Rang %d : %s" % [maxi(1, rang), Sorts.resume_rang(id, rang)], 24, StyleAzur.MAGIE))
		texte.add_child(StyleAzur.texte(Sorts.progression_rang(id), 23, StyleAzur.ATTENUE))
		if d.has("recharge"):
			var recharge := String.num(ReglagesJoueur.recharge_sort(id), 1).trim_suffix(".0").replace(".", ",")
			texte.add_child(StyleAzur.texte("Récupération avec vos bonus : %s s" % recharge, 24, StyleAzur.MAGIE))
		texte.add_child(StyleAzur.texte("RANG %d / %d" % [ReglagesJoueur.rang_sort(id), Reglages.CAPACITE_RANG_MAX],23,StyleAzur.CUIVRE))
		texte.add_child(StyleAzur.texte("Équipé · toucher pour retirer" if id in equipes else "Toucher pour équiper" if ReglagesJoueur.sort_debloque(id) else Epreuves.provenance(id),24,StyleAzur.MAGIE))
		marge.minimum_size_changed.connect(func(): b.custom_minimum_size.y = maxf(230.0,marge.get_combined_minimum_size().y))
		if not ReglagesJoueur.sort_debloque(id):
			sceau.modulate = Color("8194b8")
		if id in equipes:
			b.add_theme_stylebox_override("normal",StyleAzur.cadre(Color("285c85"),StyleAzur.MAGIE))
		_cartes.add_child(b)

func _catalogue() -> Dictionary:
	match _categorie:
		"Passifs": return Sorts.PASSIFS
		"Ultimes": return Sorts.ULTIMES
	return Sorts.ACTIFS

func _ids() -> Array[String]:
	var ids: Array[String] = []
	for id in _catalogue(): ids.append(id)
	return ids

func _ids_page() -> Array[String]:
	var ids := _ids()
	var debut := _page * 6
	var resultat: Array[String] = []
	for index in range(debut, mini(debut + 6, ids.size())):
		resultat.append(ids[index])
	return resultat

func _afficher(categorie: String) -> void:
	if categorie == _categorie and _page == 0:
		return
	_categorie = categorie
	_page = 0
	_message = ""
	Sons.jouer("choix", -17.0)
	_rafraichir()

func _changer_page(direction: int) -> void:
	var pages := maxi(1, ceili(float(_ids().size()) / 6.0))
	var nouvelle := clampi(_page + direction, 0, pages - 1)
	if nouvelle == _page:
		return
	_page = nouvelle
	_message = ""
	Sons.jouer("choix", -17.0)
	_rafraichir()

func _choisir_index(index: int) -> void:
	var ids := _ids_page()
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
	var pages := maxi(1, ceili(float(_ids().size()) / 6.0))
	_precedent.disabled = _page <= 0
	_suivant.disabled = _page >= pages - 1
	_rendre()
