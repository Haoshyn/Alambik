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
var _slots: Array[Button] = []

func _ready() -> void:
	var col := StyleAzur.page(self,"Grimoire des sorts",integre_menu)
	var categories := HBoxContainer.new()
	col.add_child(categories)
	for cat in ["Actifs","Passifs","Ultimes"]:
		categories.add_child(StyleAzur.bouton(cat,func(): _afficher(cat)))
	var equipe := GridContainer.new()
	equipe.columns = 2
	col.add_child(equipe)
	for i in 4:
		var b := StyleAzur.bouton("",func(): _retirer_slot(i))
		b.add_theme_font_size_override("font_size",23)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		equipe.add_child(b)
		_slots.append(b)
	_statut = StyleAzur.texte("",26,StyleAzur.MAGIE)
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
	_statut.text = _message
	var passifs := ReglagesJoueur.passifs_equipes
	var equipes := [ReglagesJoueur.sort_actif_equipe,str(passifs[0]) if passifs.size()>0 else "",str(passifs[1]) if passifs.size()>1 else "",ReglagesJoueur.ultime_equipe]
	for i in 4:
		_slots[i].text = "%s : %s" % [["Actif","Passif I","Passif II","Ultime"][i],Sorts.donnees(equipes[i]).get("nom","Vide") if not str(equipes[i]).is_empty() else "Vide"]
		_slots[i].icon = null if str(equipes[i]).is_empty() else StyleAzur.glyphe(str(equipes[i]))
		_slots[i].expand_icon = true
		_slots[i].add_theme_constant_override("icon_max_width",48)
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
		b.icon = StyleAzur.glyphe(id)
		b.expand_icon = true
		b.add_theme_constant_override("icon_max_width",120)
		b.text = "%s\n%s\n%s" % [d["nom"],d["description"],"Équipé · toucher pour retirer" if id in equipes else "Toucher pour équiper" if ReglagesJoueur.sort_debloque(id) else "À obtenir dans les Épreuves"]
		b.add_theme_font_size_override("font_size",26)
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
		_message = "%s s’obtient dans les Épreuves." % str(_catalogue()[id]["nom"])
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
