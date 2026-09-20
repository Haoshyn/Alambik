extends Control
signal ferme
const SLOTS := ["anneau_gauche", "collier", "anneau_droit"]
const NOMS_SLOTS := {"anneau_gauche":"Anneau", "collier":"Collier", "anneau_droit":"Bague"}
var integre_menu := false
var objet_initial := ""
var _slot_selectionne := "anneau_gauche"
var _objet_selectionne := ""
var _arme_selectionnee := ""
var _page := 0
var _boutons_slots: Array[Button] = []
var _boutons_objets: Array[Button] = []
var _actions: Array[Button] = []
var _precedent: Button
var _suivant: Button
var _resume: Label
var _details: Label
var _effets_objet: Label
var _armes: VBoxContainer
var _vide: VBoxContainer
var _portrait_objet: TextureRect
var _fiche_objet: PanelContainer
var _bijoux: VBoxContainer
var _actions_ligne: HBoxContainer
var _onglets_atelier: Array[Button] = []
var _page_collection: Label

func _ready() -> void:
	var col := StyleAzur.page(self,"Équipement",integre_menu)
	StyleAzur.banniere(col, "L’atelier des reliques", "Forgez vos armes et colliers pour l’attaque, vos anneaux pour les PV.", "forge")
	var onglets := HBoxContainer.new()
	onglets.add_theme_constant_override("separation", 14)
	col.add_child(onglets)
	for index in 2:
		var onglet := StyleAzur.bouton(["Bijoux & forge", "Armes & forge"][index], func(): _changer_atelier(index))
		onglets.add_child(onglet)
		_onglets_atelier.append(onglet)
	var contenu := StyleAzur.defilement(col)
	var bilan := StyleAzur.plaque(contenu)
	_resume = StyleAzur.texte("", 30, StyleAzur.IVOIRE)
	_resume.add_theme_constant_override("line_spacing", 8)
	bilan.add_child(_resume)
	_armes = VBoxContainer.new()
	_armes.add_theme_constant_override("separation", 20)
	contenu.add_child(_armes)
	_afficher_armes()
	_bijoux = VBoxContainer.new()
	_bijoux.add_theme_constant_override("separation", 20)
	contenu.add_child(_bijoux)
	var slots := HBoxContainer.new()
	slots.add_theme_constant_override("separation",16)
	_bijoux.add_child(StyleAzur.texte("Votre parure", 34, StyleAzur.IVOIRE))
	_bijoux.add_child(slots)
	for i in 3:
		var b := StyleAzur.bouton(NOMS_SLOTS[SLOTS[i]],func(): _selectionner_slot(SLOTS[i]))
		b.custom_minimum_size.y = 210
		b.add_theme_font_size_override("font_size", 30)
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		b.expand_icon = true
		b.add_theme_constant_override("icon_max_width",112)
		slots.add_child(b)
		_boutons_slots.append(b)
	StyleAzur.separateur(_bijoux)
	_bijoux.add_child(StyleAzur.texte("Le coffret de bijoux",35))
	var grille := GridContainer.new()
	grille.columns = 2
	grille.add_theme_constant_override("h_separation",16)
	grille.add_theme_constant_override("v_separation",16)
	_bijoux.add_child(grille)
	for i in 6:
		var b := StyleAzur.bouton("",func(): _selectionner_objet(i))
		b.custom_minimum_size.y = 280
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.expand_icon = true
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		b.add_theme_constant_override("icon_max_width",150)
		b.add_theme_font_size_override("font_size",28)
		grille.add_child(b)
		_boutons_objets.append(b)
	_vide = StyleAzur.plaque(_bijoux)
	var invitation := HBoxContainer.new()
	invitation.add_theme_constant_override("separation", 24)
	_vide.add_child(invitation)
	var couronne := StyleAzur.illustration("couronne", 124)
	couronne.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	invitation.add_child(couronne)
	var invitation_texte := VBoxContainer.new()
	invitation_texte.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	invitation_texte.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	invitation_texte.add_theme_constant_override("separation", 14)
	invitation.add_child(invitation_texte)
	invitation_texte.add_child(StyleAzur.texte("Votre collection commence ici",34))
	invitation_texte.add_child(StyleAzur.texte("Ouvrez les coffres de la campagne pour découvrir de nouveaux bijoux.",28,StyleAzur.ATTENUE))
	var pages := HBoxContainer.new()
	_bijoux.add_child(pages)
	_precedent = StyleAzur.bouton("‹ Précédent",func(): _changer_page(-1))
	_suivant = StyleAzur.bouton("Suivant ›",func(): _changer_page(1))
	pages.add_child(_precedent)
	_page_collection = StyleAzur.texte("", 24, StyleAzur.ATTENUE)
	_page_collection.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pages.add_child(_page_collection)
	pages.add_child(_suivant)
	var fiche := StyleAzur.plaque(_bijoux,true)
	_fiche_objet = fiche.get_parent() as PanelContainer
	fiche.add_theme_constant_override("separation", 20)
	fiche.add_child(StyleAzur.texte("À la loupe", 34, StyleAzur.IVOIRE))
	var apercu := HBoxContainer.new()
	apercu.add_theme_constant_override("separation",20)
	fiche.add_child(apercu)
	_portrait_objet = StyleAzur.image(0,128)
	_portrait_objet.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	apercu.add_child(_portrait_objet)
	_details = StyleAzur.texte("",30,StyleAzur.IVOIRE)
	_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details.add_theme_constant_override("line_spacing", 8)
	apercu.add_child(_details)
	_effets_objet = StyleAzur.texte("",28,StyleAzur.ATTENUE)
	_effets_objet.add_theme_constant_override("line_spacing", 8)
	fiche.add_child(_effets_objet)
	_actions_ligne = HBoxContainer.new()
	_actions_ligne.add_theme_constant_override("separation",12)
	col.add_child(_actions_ligne)
	for d in [["Équiper",_equiper],["Retirer",_retirer],["Forge",_ameliorer]]:
		var b := StyleAzur.bouton(d[0],d[1],d[0] == "Équiper")
		_actions_ligne.add_child(b)
		_actions.append(b)
	_changer_atelier(0)
	if not objet_initial.is_empty():
		for slot: String in SLOTS:
			if str(ReglagesJoueur.equipements.get(slot, "")) == objet_initial:
				_slot_selectionne = slot
				break
	_selectionner_slot(_slot_selectionne)
	if _objet_selectionne == objet_initial and not objet_initial.is_empty():
		_page = floori(float(maxi(0, _objets_compatibles().find(objet_initial))) / _boutons_objets.size())
		_rafraichir()
	Capture.programmer(self)

func _changer_atelier(index: int) -> void:
	_armes.visible = index == 1
	_bijoux.visible = index == 0
	_actions_ligne.visible = index == 0
	for i in _onglets_atelier.size():
		StyleAzur.case_objet(_onglets_atelier[i], i == index)

func _afficher_inventaire() -> void:
	_resume.text = _resume_heros()
	for i in 3:
		var id := str(ReglagesJoueur.equipements.get(SLOTS[i],""))
		_boutons_slots[i].icon = null if id.is_empty() else StyleAzur.icone(StyleAzur.icone_objet(id))
		_boutons_slots[i].text = NOMS_SLOTS[SLOTS[i]]+ ("\nLibre" if id.is_empty() else "\nNiveau %d" % ReglagesJoueur.niveau_objet(id))
		StyleAzur.case_objet(_boutons_slots[i],SLOTS[i] == _slot_selectionne)
	var ids := _objets_page()
	_vide.get_parent().visible = ids.is_empty()
	_precedent.get_parent().visible = _objets_compatibles().size() > 6
	for i in 6:
		var b := _boutons_objets[i]
		b.visible = i < ids.size()
		if i >= ids.size(): continue
		var id := ids[i]
		b.icon = StyleAzur.icone(StyleAzur.icone_objet(id))
		b.text = "%s\nNiveau %d" % [CatalogueObjets.OBJETS[id]["nom"], ReglagesJoueur.niveau_objet(id)]
		b.tooltip_text = str(CatalogueObjets.OBJETS[id]["nom"])
		StyleAzur.case_objet(b,id == _objet_selectionne)
	_effets_objet.text = ""
	_fiche_objet.visible = not _objet_selectionne.is_empty()
	_effets_objet.visible = not _objet_selectionne.is_empty()
	_details.text = "Sélectionnez un bijou pour consulter ses effets."
	_portrait_objet.visible = not _objet_selectionne.is_empty()
	if _objet_selectionne.is_empty(): return
	var id := _objet_selectionne
	_portrait_objet.texture = StyleAzur.icone(StyleAzur.icone_objet(id))
	var niveau := ReglagesJoueur.niveau_objet(id)
	_details.text = "%s · Niveau %d\n%s\n%s" % [CatalogueObjets.OBJETS[id]["nom"],niveau,CatalogueObjets.description_bonus(id,niveau),"Limite de forge atteinte" if niveau >= Reglages.FORGE_NIVEAU_MAX else "Forge : %d pierres" % ReglagesJoueur.cout_forge(id)]
	if niveau < Reglages.FORGE_NIVEAU_MAX:
		_details.text += "\nProchain niveau : " + CatalogueObjets.description_bonus(id,niveau+1)
	_effets_objet.text = CatalogueObjets.description_effets(id,niveau)+"\n\nUn pouvoir au niveau 10. Chaque niveau de forge augmente la base, avant les bonus en pourcentage.\nActif quand ce bijou est équipé. Effets identiques non cumulables."

func _nombre(valeur: float) -> String:
	return String.num(valeur, 1).trim_suffix(".0").replace(".", ",")

func _pourcentage(valeur: float) -> String:
	return _nombre(valeur * 100.0)

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
	_page_collection.text = "%d / %d" % [_page + 1, pages]
	_page = clampi(_page, 0, pages - 1)
	_precedent.disabled = _page <= 0
	_suivant.disabled = _page >= pages - 1
	_actions[0].disabled = _objet_selectionne.is_empty() or str(ReglagesJoueur.equipements.get(_slot_selectionne, "")) == _objet_selectionne
	_actions[1].disabled = str(ReglagesJoueur.equipements.get(_slot_selectionne, "")).is_empty()
	_actions[2].disabled = _objet_selectionne.is_empty() \
		or ReglagesJoueur.niveau_objet(_objet_selectionne) >= Reglages.FORGE_NIVEAU_MAX \
		or ReglagesJoueur.pierres_forge < ReglagesJoueur.cout_forge(_objet_selectionne)
	_afficher_inventaire()
	_afficher_armes()

func _resume_heros() -> String:
	var stats := Stats.depuis_reglages(ReglagesJoueur.rangs_competences_effectifs(),ReglagesJoueur.passifs_equipes_effectifs(),ReglagesJoueur.bonus_objets_effectifs(),ReglagesJoueur.niveau_compte_effectif())
	return "Attaque de base %s · Bonus d’attaque +%s %%\nAttaque réelle %s · Dégâts finaux +%s %%\nPV %d · Cadence %.2f /s\n%d capacités débloquées · %d pierres de forge" % [_nombre(stats.attaque_base),_pourcentage(stats.bonus_attaque),_nombre(stats.degats),_pourcentage(ReglagesJoueur.multiplicateur_degats_deblocages()-1.0),roundi(stats.pv_max),stats.cadence,ReglagesJoueur.nombre_capacites_debloquees(),ReglagesJoueur.pierres_forge]

func _selectionner_arme(id: String) -> void:
	_arme_selectionnee = id
	Sons.jouer("choix", -16.0)
	_afficher_armes()

func _equiper_arme() -> void:
	if ReglagesJoueur.equiper_projectile(_arme_selectionnee):
		Sons.jouer("choix", -10.0)
		_rafraichir()

func _ameliorer_arme() -> void:
	if ReglagesJoueur.ameliorer_arme(_arme_selectionnee):
		Sons.jouer("fusion", -10.0)
		_rafraichir()

func _afficher_armes() -> void:
	for enfant in _armes.get_children():
		_armes.remove_child(enfant)
		enfant.queue_free()
	_armes.add_child(StyleAzur.texte("L’arsenal alchimique", 35))
	_armes.add_child(StyleAzur.texte("Chaque arme change la forme de vos tirs. Sa forge augmente l’attaque de base de vos tirs, sorts et ultimes.", 26, StyleAzur.ATTENUE))
	if not CatalogueProjectiles.contient(_arme_selectionnee):
		_arme_selectionnee = ReglagesJoueur.projectile_equipe_effectif()
	var ligne := GridContainer.new()
	ligne.columns = 2
	ligne.add_theme_constant_override("h_separation",10)
	ligne.add_theme_constant_override("v_separation",10)
	_armes.add_child(ligne)
	var selection: Dictionary = CatalogueProjectiles.TYPES[_arme_selectionnee]
	var disponibles := ReglagesJoueur.projectiles_disponibles()
	for id: String in CatalogueProjectiles.TYPES:
		var arme: Dictionary = CatalogueProjectiles.TYPES[id]
		var disponible := id in disponibles
		var bouton := StyleAzur.bouton(str(arme["nom"]), func(): _selectionner_arme(id))
		bouton.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		bouton.add_theme_font_size_override("font_size",28)
		bouton.custom_minimum_size.y = 260
		bouton.icon = StyleAzur.icone_arme(id)
		bouton.expand_icon = true
		bouton.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bouton.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		bouton.add_theme_constant_override("icon_max_width",116)
		StyleAzur.case_objet(bouton,id == _arme_selectionnee)
		bouton.tooltip_text = str(arme["description"])
		if disponible:
			bouton.text += "\nNiveau %d%s" % [ReglagesJoueur.niveau_arme(id), " · Équipée" if id == ReglagesJoueur.projectile_equipe_effectif() else ""]
		else:
			bouton.text += "\nVerrouillée · Chapitre %d" % CatalogueProjectiles.niveau_deblocage(id)
		ligne.add_child(bouton)
	var niveau := ReglagesJoueur.niveau_arme(_arme_selectionnee)
	var disponible := _arme_selectionnee in disponibles
	var fiche_arme := StyleAzur.plaque(_armes)
	fiche_arme.add_child(StyleAzur.texte("%s · Niveau %d" % [selection["nom"], niveau], 34, StyleAzur.IVOIRE))
	fiche_arme.add_child(StyleAzur.texte("Attaque de base +%s\nPuissance du tir : %s %% de l’attaque réelle\nCadence ×%.2f\n%s" % [_nombre(CatalogueProjectiles.attaque_base(_arme_selectionnee,niveau)),_pourcentage(float(selection["coefficient_tir"])),float(selection.get("cadence_mult",1.0)),selection["description"]],28,StyleAzur.ATTENUE))
	if niveau < Reglages.FORGE_NIVEAU_MAX:
		fiche_arme.add_child(StyleAzur.texte("Prochain niveau : attaque de base +%s\nForge : %d pierres" % [_nombre(CatalogueProjectiles.attaque_base(_arme_selectionnee,niveau+1)),ReglagesJoueur.cout_forge_arme(_arme_selectionnee)],28,StyleAzur.ATTENUE))
	else:
		fiche_arme.add_child(StyleAzur.texte("Limite de forge atteinte",28,StyleAzur.ATTENUE))
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation",12)
	fiche_arme.add_child(actions)
	var equiper := StyleAzur.bouton("Équiper",_equiper_arme,true)
	equiper.disabled = not disponible or _arme_selectionnee == ReglagesJoueur.projectile_equipe_effectif()
	actions.add_child(equiper)
	var ameliorer := StyleAzur.bouton("Forge",_ameliorer_arme)
	ameliorer.disabled = not disponible or niveau >= Reglages.FORGE_NIVEAU_MAX \
		or ReglagesJoueur.pierres_forge < ReglagesJoueur.cout_forge_arme(_arme_selectionnee)
	actions.add_child(ameliorer)
