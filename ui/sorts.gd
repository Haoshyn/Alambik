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
	StyleAzur.banniere(col, "Le grimoire vivant", "6 sorts actifs, 8 passifs et 4 ultimes à découvrir. Préparez un actif, deux passifs et un ultime.", "grimoire")
	_collection = StyleAzur.texte("", 26, StyleAzur.MAGIE)
	col.add_child(_collection)
	var categories := BoxContainer.new()
	StyleAzur.adapter_ligne(categories)
	categories.add_theme_constant_override("separation", 14)
	for cat in ["Actifs","Passifs","Ultimes"]:
		var bouton := StyleAzur.bouton(cat,func(): _afficher(cat))
		categories.add_child(bouton)
		_categories[cat] = bouton
	var equipe := CompositionArcane.new()
	equipe.hauteur = 280
	equipe.traces = [PackedVector2Array([Vector2(106,156),Vector2(346,106),Vector2(586,126),Vector2(826,166)])]
	col.add_child(equipe)
	for i in 4:
		var b := StyleAzur.bouton("",func(): _retirer_slot(i))
		b.custom_minimum_size = Vector2(192,192)
		var marge := MarginContainer.new()
		marge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		marge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for cote in ["left", "right", "top", "bottom"]: marge.add_theme_constant_override("margin_" + cote, 38)
		b.add_child(marge)
		var composition := VBoxContainer.new()
		composition.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		composition.add_theme_constant_override("separation", 4)
		composition.mouse_filter = Control.MOUSE_FILTER_IGNORE
		marge.add_child(composition)
		var illustration := StyleAzur.vignette("onde_alchimique", 56)
		illustration.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		composition.add_child(illustration)
		_icones_slots.append(illustration)
		var legende := StyleAzur.texte("", 22, StyleAzur.IVOIRE)
		legende.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		composition.add_child(legende)
		_textes_slots.append(legende)
		b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		equipe.placer(b, Rect2(10 + i * 240, [60, 10, 30, 70][i], 192, 192))
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
	_collection.text = "%d / %d capacités · %d / %d Cœurs de mana" % [debloques, Sorts.nombre_capacites_debloquees({}, true), ReglagesJoueur.nombre_coeurs_mana(), Epreuves.nombre()]
	_statut.text = _message
	_statut.visible = not _message.is_empty()
	for cat: String in _categories:
		var symbole: String = {"Actifs":"onde_alchimique", "Passifs":"sagesse", "Ultimes":"grand_oeuvre"}[cat]
		StyleAzur.onglet_symbolique(_categories[cat], StyleAzur.glyphe(symbole), cat == _categorie)
	_precedent.get_parent().visible = _ids().size() > 6
	var passifs := ReglagesJoueur.passifs_equipes
	var equipes := [ReglagesJoueur.sort_actif_equipe,str(passifs[0]) if passifs.size()>0 else "",str(passifs[1]) if passifs.size()>1 else "",ReglagesJoueur.ultime_equipe]
	for i in 4:
		var vide := str(equipes[i]).is_empty()
		var legende: String = ["Actif","Passif I","Passif II","Ultime"][i]
		_textes_slots[i].text = legende
		_slots[i].tooltip_text = str(Sorts.donnees(equipes[i]).get("nom","Vide")) if not str(equipes[i]).is_empty() else "Emplacement vide"
		_slots[i].accessibility_name = legende + " · " + _slots[i].tooltip_text
		_icones_slots[i].texture = StyleAzur.glyphe(["onde_alchimique", "sagesse", "endurance", "grand_oeuvre"][i]) if vide else StyleAzur.glyphe(str(equipes[i]))
		_icones_slots[i].modulate = Color("b4ac95") if vide else Color.WHITE
		_slots[i].self_modulate = Color("b4ac95") if vide else Color.WHITE
		for etat in ["normal", "hover", "pressed", "disabled"]:
			_slots[i].add_theme_stylebox_override(etat, StyleAzur.cercle(not vide))
	for enfant in _cartes.get_children():
		_cartes.remove_child(enfant)
		enfant.queue_free()
	var ids := _ids_page()
	var constellation := CompositionArcane.new()
	constellation.hauteur = 950
	_cartes.add_child(constellation)
	var positions := [Vector2(80,20), Vector2(560,80), Vector2(320,300), Vector2(20,490), Vector2(650,490), Vector2(365,710)]
	for i in ids.size():
		var id := ids[i]
		var d: Dictionary = _catalogue()[id]
		var b := StyleAzur.bouton_rond("", _ouvrir_fiche.bind(i), 160)
		b.icon = StyleAzur.glyphe(id)
		b.expand_icon = true
		b.add_theme_constant_override("icon_max_width", 100)
		b.tooltip_text = str(d["nom"])
		b.accessibility_name = str(d["nom"])
		if not ReglagesJoueur.sort_debloque(id): b.self_modulate = Color("9dabb7")
		constellation.placer(b, Rect2(positions[i] + Vector2(40, 0), Vector2(160,160)))
		var nom := StyleAzur.texte(str(d["nom"]), 27, StyleAzur.IVOIRE)
		nom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		constellation.placer(nom, Rect2(positions[i] + Vector2(0,166), Vector2(240,70)))

func _ouvrir_fiche(index: int) -> void:
	var id := _ids_page()[index]
	var donnees: Dictionary = _catalogue()[id]
	var fiche := Control.new()
	add_child(fiche)
	var col := StyleAzur.page(fiche, "Grimoire", true)
	var contenu := StyleAzur.defilement(col)
	contenu.add_child(StyleAzur.bouton("‹ Refermer le grimoire", func(): fiche.queue_free()))
	var illustration := StyleAzur.vignette(id, 210)
	illustration.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	contenu.add_child(illustration)
	contenu.add_child(StyleAzur.texte(str(donnees["nom"]), 42))
	var lecture := StyleAzur.plaque(contenu)
	lecture.add_child(StyleAzur.texte(str(donnees["description"]), 30))
	var rang := ReglagesJoueur.rang_sort(id)
	lecture.add_child(StyleAzur.texte("Rang %d / %d · %s" % [rang, Sorts.rang_max(id), Sorts.resume_rang(id, rang)], 26))
	lecture.add_child(StyleAzur.texte(Sorts.progression_rang(id), 24))
	if donnees.has("recharge"):
		lecture.add_child(StyleAzur.texte("Récupération : %s s" % String.num(ReglagesJoueur.recharge_sort(id), 1), 26))
	var equipe := id == ReglagesJoueur.sort_actif_equipe or id == ReglagesJoueur.ultime_equipe or id in ReglagesJoueur.passifs_equipes
	if ReglagesJoueur.sort_debloque(id):
		contenu.add_child(StyleAzur.bouton("Retirer" if equipe else "Équiper", func():
			_choisir_index(index)
			fiche.queue_free(), true))
	else:
		lecture.add_child(StyleAzur.texte(Epreuves.provenance(id), 26))

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
