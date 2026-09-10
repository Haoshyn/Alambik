extends Control
signal ferme
const SLOTS := ["anneau_gauche", "collier", "anneau_droit"]
const NOMS_SLOTS := {"anneau_gauche":"Anneau", "collier":"Collier", "anneau_droit":"Bague"}
var integre_menu := false
var _slot_selectionne := "anneau_gauche"
var _objet_selectionne := ""
var _page := 0
var _boutons_slots: Array[Button] = []
var _boutons_objets: Array[Button] = []
var _actions: Array[Button] = []
var _precedent: Button
var _suivant: Button
var _resume: Label
var _details: Label
var _vide: VBoxContainer

func _ready() -> void:
	var col := StyleAzur.page(self,"Équipement",integre_menu)
	var contenu := StyleAzur.defilement(col)
	var slots := HBoxContainer.new()
	slots.add_theme_constant_override("separation",16)
	contenu.add_child(slots)
	for i in 3:
		var b := StyleAzur.bouton(NOMS_SLOTS[SLOTS[i]],func(): _selectionner_slot(SLOTS[i]))
		b.custom_minimum_size.y = 210
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		b.expand_icon = true
		b.add_theme_constant_override("icon_max_width",120)
		slots.add_child(b)
		_boutons_slots.append(b)
	_resume = StyleAzur.texte("",27,StyleAzur.ATTENUE)
	contenu.add_child(_resume)
	contenu.add_child(StyleAzur.texte("Votre collection",35))
	var grille := GridContainer.new()
	grille.columns = 3
	grille.add_theme_constant_override("h_separation",16)
	grille.add_theme_constant_override("v_separation",16)
	contenu.add_child(grille)
	for i in 6:
		var b := StyleAzur.bouton("",func(): _selectionner_objet(i))
		b.custom_minimum_size.y = 230
		b.expand_icon = true
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		b.add_theme_constant_override("icon_max_width",130)
		b.add_theme_font_size_override("font_size",24)
		grille.add_child(b)
		_boutons_objets.append(b)
	_vide = StyleAzur.plaque(contenu)
	_vide.add_child(StyleAzur.texte("Votre collection commence ici",34))
	_vide.add_child(StyleAzur.texte("Ouvrez les coffres de la campagne pour découvrir de nouveaux bijoux.",28,StyleAzur.ATTENUE))
	var pages := HBoxContainer.new()
	contenu.add_child(pages)
	_precedent = StyleAzur.bouton("‹ Précédent",func(): _changer_page(-1))
	_suivant = StyleAzur.bouton("Suivant ›",func(): _changer_page(1))
	pages.add_child(_precedent)
	pages.add_child(_suivant)
	_details = StyleAzur.texte("",29,StyleAzur.ENCRE)
	StyleAzur.plaque(contenu,true).add_child(_details)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation",12)
	col.add_child(actions)
	for d in [["Équiper",_equiper],["Retirer",_retirer],["Améliorer",_ameliorer]]:
		var b := StyleAzur.bouton(d[0],d[1],true)
		actions.add_child(b)
		_actions.append(b)
	_selectionner_slot(_slot_selectionne)
	Capture.programmer(self)

func _afficher_inventaire() -> void:
	_resume.text = _resume_heros()
	for i in 3:
		var id := str(ReglagesJoueur.equipements.get(SLOTS[i],""))
		_boutons_slots[i].icon = null if id.is_empty() else StyleAzur.icone(StyleAzur.icone_objet(id))
		_boutons_slots[i].text = NOMS_SLOTS[SLOTS[i]]+ (" · vide" if id.is_empty() else " · niv. %d" % ReglagesJoueur.niveau_objet(id))
		_boutons_slots[i].add_theme_stylebox_override("normal",StyleAzur.cadre(StyleAzur.PANNEAU,StyleAzur.MAGIE if SLOTS[i] == _slot_selectionne else StyleAzur.CUIVRE))
	var ids := _objets_page()
	_vide.get_parent().visible = ids.is_empty()
	_precedent.get_parent().visible = _objets_compatibles().size() > 6
	for i in 6:
		var b := _boutons_objets[i]
		b.visible = i < ids.size()
		if i >= ids.size(): continue
		var id := ids[i]
		b.icon = StyleAzur.icone(StyleAzur.icone_objet(id))
		b.text = "%s\nNiveau %d" % [CatalogueObjets.OBJETS[id]["nom"],ReglagesJoueur.niveau_objet(id)]
		b.add_theme_stylebox_override("normal",StyleAzur.cadre(StyleAzur.PANNEAU,StyleAzur.MAGIE if id == _objet_selectionne else StyleAzur.CUIVRE))
	_details.text = "Sélectionnez un bijou pour consulter ses effets."
	if _objet_selectionne.is_empty(): return
	var id := _objet_selectionne
	var niveau := ReglagesJoueur.niveau_objet(id)
	var bonus := CatalogueObjets.bonus_objet(id,niveau,ReglagesJoueur.monde_equipement_atteint())
	var parts: Array[String] = []
	var noms := {"degats":"Dégâts","pv":"PV","cadence":"Cadence","vitesse":"Vitesse","critique":"Critique","reduction":"Protection","collecte":"Collecte"}
	for cle in bonus:
		if float(bonus[cle]) != 0.0: parts.append("%s +%.1f %%" % [noms.get(cle,cle),float(bonus[cle])*100])
	_details.text = "%s · Niveau %d\n%s\n%s" % [CatalogueObjets.OBJETS[id]["nom"],niveau," · ".join(parts),"Niveau maximum" if niveau >= Reglages.FORGE_NIVEAU_MAX else "Forge : %d pierres" % ReglagesJoueur.cout_forge(id)]

func _selectionner_slot(slot: String) -> void:
	_slot_selectionne = slot
	_page = 0
	_objet_selectionne = str(ReglagesJoueur.equipements.get(slot, ""))
	if _objet_selectionne.is_empty():
		var disponibles := _objets_compatibles()
		if not disponibles.is_empty():
			_objet_selectionne = disponibles[0]
	_rafraichir()

func _selectionner_objet(index: int) -> void:
	var visibles := _objets_page()
	if index >= visibles.size():
		return
	_objet_selectionne = visibles[index]
	Sons.jouer("choix", -16.0)
	_rafraichir()

func _objets_compatibles() -> Array[String]:
	var resultat: Array[String] = []
	for id in ReglagesJoueur.objets_disponibles():
		if CatalogueObjets.compatible(_slot_selectionne, id):
			resultat.append(id)
	resultat.sort_custom(func(a: String, b: String) -> bool:
		return int(CatalogueObjets.OBJETS[a]["chapitre"]) < int(CatalogueObjets.OBJETS[b]["chapitre"]))
	return resultat

func _objets_page() -> Array[String]:
	var tous := _objets_compatibles()
	var debut := _page * 6
	return tous.slice(debut, mini(debut + 6, tous.size()))

func _changer_page(direction: int) -> void:
	var pages := maxi(1, ceili(float(_objets_compatibles().size()) / 6.0))
	var nouvelle := clampi(_page + direction, 0, pages - 1)
	if nouvelle == _page:
		return
	_page = nouvelle
	_objet_selectionne = ""
	var visibles := _objets_page()
	if not visibles.is_empty(): _objet_selectionne = visibles[0]
	Sons.jouer("choix", -17.0)
	_rafraichir()

func _equiper() -> void:
	if _objet_selectionne.is_empty():
		return
	if ReglagesJoueur.equiper_objet(_slot_selectionne, _objet_selectionne):
		Sons.jouer("choix", -10.0)
		_rafraichir()

func _retirer() -> void:
	if ReglagesJoueur.retirer_objet(_slot_selectionne):
		Sons.jouer("choix", -12.0)
		_rafraichir()

func _ameliorer() -> void:
	if _objet_selectionne.is_empty():
		return
	if ReglagesJoueur.ameliorer_objet(_objet_selectionne):
		Sons.jouer("fusion", -10.0)
		_rafraichir()

func _rafraichir() -> void:
	var compatibles := _objets_compatibles()
	var pages := maxi(1, ceili(float(compatibles.size()) / 6.0))
	_page = clampi(_page, 0, pages - 1)
	_precedent.disabled = _page <= 0
	_suivant.disabled = _page >= pages - 1
	_actions[0].disabled = _objet_selectionne.is_empty() or str(ReglagesJoueur.equipements.get(_slot_selectionne, "")) == _objet_selectionne
	_actions[1].disabled = str(ReglagesJoueur.equipements.get(_slot_selectionne, "")).is_empty()
	_actions[2].disabled = _objet_selectionne.is_empty() \
		or ReglagesJoueur.niveau_objet(_objet_selectionne) >= Reglages.FORGE_NIVEAU_MAX \
		or ReglagesJoueur.pierres_forge < ReglagesJoueur.cout_forge(_objet_selectionne)
	_afficher_inventaire()

func _resume_heros() -> String:
	var stats := Stats.depuis_reglages(ReglagesJoueur.rangs_competences_effectifs(),ReglagesJoueur.passifs_equipes_effectifs(),ReglagesJoueur.bonus_objets_effectifs(),ReglagesJoueur.niveau_compte_effectif())
	return "Dégâts %d   ·   PV %d   ·   Cadence %.2f /s\nNiveau %d   ·   %d pierres de forge" % [roundi(stats.degats),roundi(stats.pv_max),stats.cadence,ReglagesJoueur.niveau_compte_effectif(),ReglagesJoueur.pierres_forge]
