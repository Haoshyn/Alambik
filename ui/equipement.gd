extends Control
signal ferme
const SLOTS := ["anneau", "bracelet", "collier"]
const NOMS_SLOTS := {"anneau":"Anneau", "bracelet":"Bracelet", "collier":"Collier"}
const OBJETS_PAR_PAGE := 20
const SOCLE := preload("res://ui/composants/socle_heros.gd")
const PORTRAIT := preload("res://ui/composants/portrait_heros_3d.gd")
# Bijoux a gauche, arme et familier a droite du heros (repere 960).
const PLACES_VITRINE := [Vector2(130, 110), Vector2(130, 370), Vector2(130, 630), Vector2(830, 180), Vector2(830, 480)]
const STATISTIQUES := [["Attaque", "force"], ["Défense", "armure"], ["PV", "vitalite"],
	["Critique", "precision"], ["Dégâts crit.", "puissance"], ["Cadence", "cadence"]]
var integre_menu := false
var objet_initial := ""
var _slot_selectionne := "anneau"
var _objet_selectionne := ""
var _arme_selectionnee := ""
var _page := 0
var _boutons_slots: Array[Button] = []
var _libelles_slots: Array[Label] = []
var _boutons_objets: Array[Button] = []
var _grille_inventaire: GridContainer
var _grille_armes: GridContainer
var _grille_familiers: GridContainer
var _precedent: Button
var _suivant: Button
var _resume: Label
var _valeurs_stats: Array[Label] = []
var _aide_coffret: Label
var _boutons_compagnons: Array[Button] = []
var _libelles_compagnons: Array[Label] = []
var _armes: VBoxContainer
var _boutons_armes: Dictionary = {}
var _lectures_armes: Dictionary = {}
var _atelier_actif := 0
var _familiers: VBoxContainer
var _familier_selectionne := "homoncule_encre"
var _boutons_familiers: Dictionary = {}
var _lectures_familiers: Dictionary = {}
var _bijoux: VBoxContainer
var _bilan: VBoxContainer
var _onglets_atelier: Array[Button] = []
var _page_collection: Label
var _fiche_popup: FenetreFiche
var _transition_atelier: Tween
var _message_forge := ""

func _ready() -> void:
	var col := StyleAzur.page(self,"Équipement",integre_menu)
	var onglets := BoxContainer.new()
	StyleAzur.adapter_ligne(onglets)
	onglets.add_theme_constant_override("separation", 14)
	col.add_child(onglets)
	for index in 3:
		var onglet := StyleAzur.bouton(["Reliques", "Armes", "Familiers"][index], func(): _changer_atelier(index))
		onglets.add_child(onglet)
		_onglets_atelier.append(onglet)
	var contenu := StyleAzur.defilement(col)
	# La vitrine deduit sa hauteur de sa largeur : une barre de defilement qui
	# apparait puis disparait relancerait la mise en page sans fin.
	(contenu.get_parent() as ScrollContainer).vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	_construire_vitrine(contenu)
	var bilan := VBoxContainer.new()
	contenu.add_child(bilan)
	_bilan = bilan
	# Fiche du heros en pastilles : une icone et un chiffre se lisent d'un coup d'oeil.
	var infos := StyleAzur.cartouche_infos(bilan, StyleAzur.CUIVRE)
	var grille_stats := GridContainer.new()
	grille_stats.name = "StatistiquesHeros"
	grille_stats.columns = 3
	grille_stats.add_theme_constant_override("h_separation", 14)
	grille_stats.add_theme_constant_override("v_separation", 10)
	infos.add_child(grille_stats)
	for entree: Array in STATISTIQUES:
		var pastille := HBoxContainer.new()
		pastille.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pastille.add_theme_constant_override("separation", 10)
		grille_stats.add_child(pastille)
		var icone := StyleAzur.vignette(str(entree[1]), 72)
		icone.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		pastille.add_child(icone)
		var lecture := VBoxContainer.new()
		lecture.add_theme_constant_override("separation", -6)
		pastille.add_child(lecture)
		var valeur := StyleJeu.texte("", 34, StyleJeu.OR, StyleJeu.CONTOUR_TEXTE, true)
		valeur.autowrap_mode = TextServer.AUTOWRAP_OFF
		lecture.add_child(valeur)
		var libelle := StyleJeu.texte(str(entree[0]), 22, StyleJeu.TEXTE_DOUX)
		libelle.autowrap_mode = TextServer.AUTOWRAP_OFF
		lecture.add_child(libelle)
		_valeurs_stats.append(valeur)
	_resume = StyleAzur.texte("", 26, StyleAzur.MENTHE)
	_resume.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	infos.add_child(_resume)
	_armes = VBoxContainer.new()
	_armes.add_theme_constant_override("separation", 20)
	contenu.add_child(_armes)
	_afficher_armes()
	_familiers = VBoxContainer.new()
	_familiers.add_theme_constant_override("separation", 20)
	contenu.add_child(_familiers)
	_bijoux = VBoxContainer.new()
	_bijoux.add_theme_constant_override("separation", 20)
	contenu.add_child(_bijoux)
	# Le coffret est un panneau serti : titre et cases ne reposent pas sur la clairiere.
	var coffret := StyleAzur.cartouche_infos(_bijoux, StyleAzur.LILAS)
	coffret.add_theme_constant_override("separation", 14)
	var titre_coffret := StyleAzur.calligraphie("Le coffret de bijoux", 40, StyleAzur.LILAS)
	titre_coffret.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coffret.add_child(titre_coffret)
	_aide_coffret = StyleAzur.texte("Terminez des niveaux de campagne pour gagner des bijoux.", 26, StyleJeu.TEXTE_DOUX)
	_aide_coffret.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coffret.add_child(_aide_coffret)
	var grille := GridContainer.new()
	grille.name = "GrilleInventaire"
	grille.columns = 5
	_grille_inventaire = grille
	grille.add_theme_constant_override("h_separation", 9)
	grille.add_theme_constant_override("v_separation", 9)
	coffret.add_child(grille)
	for i in OBJETS_PAR_PAGE:
		var b := StyleAzur.bouton("",func(): _selectionner_objet(i))
		b.name = "Objet_%d" % i
		b.custom_minimum_size = Vector2(145, 125)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.expand_icon = true
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		b.add_theme_constant_override("icon_max_width", 65)
		b.add_theme_font_size_override("font_size", 19)
		grille.add_child(b)
		_boutons_objets.append(b)
	var pages := BoxContainer.new()
	StyleAzur.adapter_ligne(pages)
	coffret.add_child(pages)
	_precedent = StyleAzur.bouton("‹ Précédent",func(): _changer_page(-1))
	_suivant = StyleAzur.bouton("Suivant ›",func(): _changer_page(1))
	pages.add_child(_precedent)
	_page_collection = StyleAzur.texte("", 24, StyleAzur.ATTENUE)
	_page_collection.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pages.add_child(_page_collection)
	pages.add_child(_suivant)
	resized.connect(_adapter_grilles)
	_adapter_grilles.call_deferred()
	_changer_atelier(0)
	if CatalogueObjets.OBJETS.has(objet_initial):
		_slot_selectionne = str(CatalogueObjets.OBJETS[objet_initial]["slot"])
	_selectionner_slot(_slot_selectionne, false)
	if not objet_initial.is_empty() and objet_initial in _objets_compatibles():
		_objet_selectionne = objet_initial
		_page = floori(float(maxi(0, _objets_compatibles().find(objet_initial))) / _boutons_objets.size())
		_rafraichir()
		_ouvrir_fiche_objet()
	Capture.programmer(self)

# Vitrine commune aux trois ateliers : le heros sur son socle, entoure de sa
# parure, de son arme et de son familier, comme un ecran d'equipement de jeu.
func _construire_vitrine(parent: Control) -> void:
	var vitrine := CompositionArcane.new()
	vitrine.name = "Vitrine"
	vitrine.hauteur = 790
	vitrine.traces = [PackedVector2Array([PLACES_VITRINE[0], PLACES_VITRINE[1], PLACES_VITRINE[2]]), PackedVector2Array([PLACES_VITRINE[3], PLACES_VITRINE[4]])]
	parent.add_child(vitrine)
	var socle := SOCLE.new()
	socle.name = "Socle"
	socle.accent = StyleAzur.OR_VIF
	vitrine.placer(socle, Rect2(250, 450, 460, 170))
	var portrait := PORTRAIT.new()
	portrait.name = "PortraitHeros"
	vitrine.placer(portrait, Rect2(250, 0, 460, 800))
	var actions := [func(): _choisir_parure(SLOTS[0]), func(): _choisir_parure(SLOTS[1]),
		func(): _choisir_parure(SLOTS[2]), func(): _changer_atelier(1), func(): _changer_atelier(2)]
	for i in actions.size():
		var centre: Vector2 = PLACES_VITRINE[i]
		var b := StyleAzur.bouton_rond("", actions[i], 164)
		b.name = "Emplacement_" + ["anneau", "bracelet", "collier", "arme", "familier"][i]
		b.expand_icon = true
		b.add_theme_constant_override("icon_max_width", 104)
		vitrine.placer(b, Rect2(centre - Vector2.ONE * 82, Vector2.ONE * 164))
		var nom := StyleAzur.texte("", 26)
		nom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		# Hors conteneur, un retour a la ligne automatique relance la mise en page :
		# les libelles portent leurs sauts de ligne explicites.
		nom.autowrap_mode = TextServer.AUTOWRAP_OFF
		vitrine.placer(nom, Rect2(centre + Vector2(-130, 86), Vector2(260, 70)))
		if i < SLOTS.size():
			_boutons_slots.append(b)
			_libelles_slots.append(nom)
		else:
			_boutons_compagnons.append(b)
			_libelles_compagnons.append(nom)

func _choisir_parure(slot: String) -> void:
	if _atelier_actif != 0: _changer_atelier(0)
	_selectionner_slot(slot)

func _afficher_vitrine() -> void:
	var arme := ReglagesJoueur.projectile_equipe_effectif()
	var familier := ReglagesJoueur.familier_equipe_effectif()
	var icones := [StyleAzur.icone_arme(arme), load("res://assets/visual/interface/menu/familiers/%s.svg" % familier) as Texture2D]
	var donnees_arme: Dictionary = CatalogueProjectiles.TYPES.get(arme, {})
	var donnees_familier: Dictionary = CatalogueFamiliers.TYPES.get(familier, {})
	var noms := ["Arme\n" + str(donnees_arme.get("nom", "")), "Familier\n" + str(donnees_familier.get("nom", ""))]
	var accents := [StyleAzur.ROUGE_VIF, StyleAzur.VERT_VIF]
	for i in _boutons_compagnons.size():
		var b: Button = _boutons_compagnons[i]
		b.icon = icones[i]
		b.add_theme_stylebox_override("normal", StyleAzur.cercle_teinte(accents[i], _atelier_actif == i + 1))
		_libelles_compagnons[i].text = noms[i]

func _changer_atelier(index: int) -> void:
	_atelier_actif = index
	_armes.visible = index == 1
	_familiers.visible = index == 2
	_bijoux.visible = index == 0
	_bilan.visible = index == 0
	if is_instance_valid(_transition_atelier): _transition_atelier.kill()
	for atelier: Control in [_armes, _familiers, _bijoux]: atelier.modulate.a = 1.0
	if not ReglagesJoueur.effets_reduits:
		var atelier: Control = [_bijoux, _armes, _familiers][index]
		atelier.modulate.a = 0.0
		_transition_atelier = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_transition_atelier.tween_property(atelier, "modulate:a", 1.0, 0.20)
	for i in _onglets_atelier.size():
		StyleAzur.onglet_symbolique(_onglets_atelier[i], [StyleAzur.icone(0), StyleAzur.icone_arme("standard"), StyleAzur.glyphe("familier_gardien")][i], i == index,
			[StyleAzur.OR_VIF, StyleAzur.ROUGE_VIF, StyleAzur.VERT_VIF][i])
		StyleAzur.bouton_enlumine(_onglets_atelier[i], [StyleAzur.OR_VIF, StyleAzur.ROUGE_VIF, StyleAzur.VERT_VIF][i], 38)
		_onglets_atelier[i].add_theme_stylebox_override("normal", StyleAzur.cadre_enlumine(
			[StyleAzur.OR_VIF, StyleAzur.ROUGE_VIF, StyleAzur.VERT_VIF][i], i == index))

func _adapter_grilles() -> void:
	if _grille_inventaire == null:
		return
	var largeur := maxf(0.0, size.x - maxf(28.0, Ecran.marge_gauche()) - maxf(28.0, Ecran.marge_droite()))
	_grille_inventaire.columns = clampi(floori((largeur + 9.0) / 154.0), 1, 5)
	if _grille_armes != null:
		_grille_armes.columns = 2 if largeur >= 840.0 else 1
	if _grille_familiers != null:
		_grille_familiers.columns = 2 if largeur >= 840.0 else 1

func _afficher_inventaire() -> void:
	var stats := _stats_heros()
	var valeurs := [_nombre(stats.degats), _nombre(stats.defense), str(roundi(stats.pv_max)),
		"%s %%" % _pourcentage(stats.critique), "+%s %%" % _pourcentage(stats.degats_critiques),
		"%d %%" % roundi(stats.cadence / Reglages.HEROS_CADENCE * 100.0)]
	for i in _valeurs_stats.size(): _valeurs_stats[i].text = str(valeurs[i])
	_resume.text = "Cœurs %d/%d · %d pierres de forge" % [ReglagesJoueur.nombre_coeurs_mana(), Epreuves.nombre(), ReglagesJoueur.pierres_forge]
	for i in SLOTS.size():
		var id := str(ReglagesJoueur.equipements.get(SLOTS[i],""))
		_boutons_slots[i].icon = StyleAzur.icone(2 if SLOTS[i] == "collier" else 0) if id.is_empty() else StyleAzur.icone(StyleAzur.icone_objet(id))
		_boutons_slots[i].add_theme_color_override("icon_normal_color", Color("98a8ca") if id.is_empty() else Color.WHITE)
		_libelles_slots[i].text = NOMS_SLOTS[SLOTS[i]]+ ("\nLibre" if id.is_empty() else "\nNiveau %d" % ReglagesJoueur.niveau_objet(id))
		var style_slot := StyleAzur.cercle_teinte([StyleAzur.OR_VIF, StyleAzur.BLEU_VIF, StyleAzur.MAUVE_VIF][i], SLOTS[i] == _slot_selectionne)
		_boutons_slots[i].add_theme_stylebox_override("normal", style_slot)
	var ids := _objets_page()
	var mondes: Array = Chapitres.MONDES + Chapitres.MONDES_RETIRES
	_precedent.get_parent().visible = _objets_compatibles().size() > OBJETS_PAR_PAGE
	_aide_coffret.visible = _objets_compatibles().is_empty()
	# Les cases vides completent seulement la derniere rangee : un coffret
	# presque vide ne doit pas remplir l'ecran de cases eteintes.
	var colonnes := maxi(1, _grille_inventaire.columns)
	var cases := maxi(colonnes, ceili(float(ids.size()) / colonnes) * colonnes)
	for i in OBJETS_PAR_PAGE:
		var b := _boutons_objets[i]
		b.visible = i < cases
		b.disabled = i >= ids.size()
		if i >= ids.size():
			b.icon = null
			b.text = ""
			b.tooltip_text = "Emplacement vide"
			_styler_carte(b, Color("7292b8"), false, true)
			continue
		var id := ids[i]
		b.icon = StyleAzur.icone(StyleAzur.icone_objet(id))
		b.text = "%s\nNiveau %d" % [CatalogueObjets.OBJETS[id]["nom"], ReglagesJoueur.niveau_objet(id)]
		b.tooltip_text = str(CatalogueObjets.OBJETS[id]["nom"])
		var objet: Dictionary = CatalogueObjets.OBJETS[id]
		var monde: Dictionary = mondes[clampi(int(objet["monde"]), 0, mondes.size() - 1)]
		var accent_objet: Color = monde["teinte"]
		_styler_carte(b, accent_objet, id == _objet_selectionne)

func _styler_carte(bouton: Button, accent: Color, selection: bool, vide := false) -> void:
	# Cases du coffret : emplacement creuse quand il est vide, email teinte par
	# le monde d'origine sinon, avec une lueur sur la piece choisie.
	for etat in ["normal", "hover", "pressed", "disabled"]:
		var style := (StyleJeu.panneau(Color() if vide else accent, 18.0, 0.6 if vide else 0.96) as StyleBoxJeu).duplicate() as StyleBoxJeu
		style.epaisseur = 2.0 if vide else 6.0
		style.reflet = 0.0 if vide else 0.18
		style.liseret = 0.08 if vide else 0.35
		if vide:
			style.monture_haut = Color("7d82a6")
			style.monture_bas = Color("454966")
			style.largeur_monture = 2.0
			style.ombre = Color(0, 0, 0, 0.0)
		elif selection:
			style.lueur = Color(accent.lightened(0.35), 0.85)
			style.lueur_taille = 10.0
		if etat == "hover" and not vide:
			style.face_haut = style.face_haut.lightened(0.1)
		if etat == "pressed":
			style.enfonce = true
		style.content_margin_left = 8.0
		style.content_margin_right = 8.0
		style.content_margin_top = 8.0
		style.content_margin_bottom = 10.0
		bouton.add_theme_stylebox_override(etat, style)
	bouton.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	bouton.add_theme_color_override("font_color", Color("f1f5ff"))
	bouton.add_theme_color_override("font_disabled_color", Color("a9b8d1"))

func _nombre(valeur: float) -> String:
	return str(roundi(valeur))

# Les facteurs d'arme se lisent comme les augments : un ecart entier en pourcentage.
func _ecart(facteur: float) -> String:
	var ecart := roundi((facteur - 1.0) * 100.0)
	return "normale" if ecart == 0 else "%s%d %%" % ["+" if ecart > 0 else "−", absi(ecart)]

func _pourcentage(valeur: float) -> String:
	return _nombre(valeur * 100.0)

func _selectionner_slot(slot: String, ouvrir_fiche := true) -> void:
	_slot_selectionne = slot
	_page = 0
	var equipe := str(ReglagesJoueur.equipements.get(slot, ""))
	_objet_selectionne = equipe
	if _objet_selectionne.is_empty():
		var disponibles := _objets_compatibles()
		if not disponibles.is_empty():
			_objet_selectionne = disponibles[0]
	_rafraichir()
	if ouvrir_fiche and not equipe.is_empty():
		_ouvrir_fiche_objet()

func _selectionner_objet(index: int) -> void:
	var visibles := _objets_page()
	if index >= visibles.size():
		return
	_objet_selectionne = visibles[index]
	Sons.jouer("choix", -16.0)
	_rafraichir()
	_ouvrir_fiche_objet()

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
	var debut := _page * OBJETS_PAR_PAGE
	return tous.slice(debut, mini(debut + OBJETS_PAR_PAGE, tous.size()))

func _changer_page(direction: int) -> void:
	var pages := maxi(1, ceili(float(_objets_compatibles().size()) / float(OBJETS_PAR_PAGE)))
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
	if str(ReglagesJoueur.equipements.get(_slot_selectionne, "")) != _objet_selectionne:
		return
	if ReglagesJoueur.retirer_objet(_slot_selectionne):
		Sons.jouer("choix", -12.0)
		_rafraichir()

func _ameliorer() -> void:
	if _objet_selectionne.is_empty():
		return
	if ReglagesJoueur.ameliorer_objet(_objet_selectionne):
		_message_forge = "Forge réussie · niveau %d" % ReglagesJoueur.niveau_objet(_objet_selectionne)
		Sons.jouer("fusion", -10.0)
		_rafraichir()

func _rafraichir() -> void:
	var compatibles := _objets_compatibles()
	var pages := maxi(1, ceili(float(compatibles.size()) / float(OBJETS_PAR_PAGE)))
	_page_collection.text = "%d / %d" % [_page + 1, pages]
	_page = clampi(_page, 0, pages - 1)
	_precedent.disabled = _page <= 0
	_suivant.disabled = _page >= pages - 1
	_afficher_inventaire()
	_afficher_armes()
	_afficher_familiers()
	_afficher_vitrine()

func _nouvelle_fiche(titre: String, glyphe: String) -> FenetreFiche:
	if is_instance_valid(_fiche_popup) and _fiche_popup.visible and not _fiche_popup.fermeture_en_cours():
		_fiche_popup.vider()
	else:
		if is_instance_valid(_fiche_popup): _fiche_popup.queue_free()
		_fiche_popup = FenetreFiche.new()
		_fiche_popup.presentation_soignee = true
		_fiche_popup.set_meta("surface_lecture", false)
		_fiche_popup.largeur_max = 820.0
		_fiche_popup.hauteur_max = 1100.0
		var parent_fiche: Node = get_parent().get_parent() if integre_menu else self
		parent_fiche.add_child(_fiche_popup)
	_fiche_popup.configurer(titre, glyphe)
	if not _message_forge.is_empty():
		var confirmation := StyleAzur.texte(_message_forge, 28, StyleAzur.VERT_VIF)
		confirmation.name = "ConfirmationForge"
		_fiche_popup.contenu.add_child(confirmation)
		_fiche_popup.souligner_validation()
		_message_forge = ""
	return _fiche_popup

func _lecture_fiche(fiche: FenetreFiche) -> VBoxContainer:
	var lecture := VBoxContainer.new()
	lecture.add_theme_constant_override("separation", 16)
	fiche.contenu.add_child(lecture)
	return lecture

func _progression_forge(fiche: FenetreFiche, actuel: Dictionary, suivant: Dictionary, niveau: int, cout: int) -> void:
	if niveau >= Reglages.FORGE_NIVEAU_MAX:
		fiche.contenu.add_child(StyleAzur.texte("Forge au niveau maximum", 27, StyleAzur.CUIVRE))
		return
	var progression := VBoxContainer.new()
	progression.name = "ProgressionForge"
	progression.add_theme_constant_override("separation", 10)
	fiche.contenu.add_child(progression)
	progression.add_child(StyleAzur.texte("Niveau %d → %d" % [niveau, niveau + 1], 30, StyleAzur.OR_VIF))
	var libelles := {"attaque_base": "Attaque brute", "pv_base": "PV bruts", "defense_base": "Défense brute", "attaque_mult": "Attaque", "attaque_familier": "Attaque du familier"}
	for champ: String in suivant:
		var avant := float(actuel.get(champ, 0.0))
		var apres := float(suivant[champ])
		if is_equal_approx(avant, apres): continue
		var pourcent := champ.ends_with("_mult")
		var unite := " %" if pourcent else ""
		var facteur := 100.0 if pourcent else 1.0
		progression.add_child(StyleAzur.texte("%s  %s%s → %s%s  (+%s%s)" % [str(libelles.get(champ, champ)), _nombre(avant * facteur), unite, _nombre(apres * facteur), unite, _nombre((apres - avant) * facteur), unite], 26, StyleAzur.MENTHE))
	var manque := maxi(0, cout - ReglagesJoueur.pierres_forge)
	progression.add_child(StyleAzur.texte("%d pierres · réserve %d%s" % [cout, ReglagesJoueur.pierres_forge, " · il manque %d" % manque if manque > 0 else ""], 26, StyleAzur.CUIVRE))

func _action_fiche(ligne: BoxContainer, titre: String, symbole: String, couleur: Color, action: Callable, actif := true) -> void:
	var bouton := StyleAzur.bouton(titre, action)
	bouton.icon = StyleAzur.texture_interface(symbole)
	bouton.expand_icon = true
	bouton.add_theme_constant_override("icon_max_width", 38)
	bouton.custom_minimum_size.y = 104
	bouton.disabled = not actif
	StyleAzur.action_coloree(bouton, couleur)
	ligne.add_child(bouton)

func _actions_fiche(fiche: FenetreFiche) -> BoxContainer:
	var ligne := BoxContainer.new()
	StyleAzur.adapter_ligne(ligne, 600.0)
	ligne.add_theme_constant_override("separation", 12)
	fiche.pied.visible = true
	fiche.pied.add_child(ligne)
	return ligne

func _agir_objet(action: String) -> void:
	match action:
		"equiper": _equiper()
		"retirer": _retirer()
		"forger": _ameliorer()
	_ouvrir_fiche_objet()

func _ouvrir_fiche_objet() -> void:
	if not CatalogueObjets.OBJETS.has(_objet_selectionne):
		return
	var objet: Dictionary = CatalogueObjets.OBJETS[_objet_selectionne]
	var fiche := _nouvelle_fiche(str(objet["nom"]), "forge")
	var niveau := ReglagesJoueur.niveau_objet(_objet_selectionne)
	var equipe := str(ReglagesJoueur.equipements.get(_slot_selectionne, "")) == _objet_selectionne
	fiche.contenu.add_child(StyleAzur.texte("%s · Niveau %d%s" % [NOMS_SLOTS[_slot_selectionne], niveau, " · Équipé" if equipe else ""], 28, StyleAzur.OR_VIF))
	var lecture := _lecture_fiche(fiche)
	lecture.add_child(StyleAzur.image(StyleAzur.icone_objet(_objet_selectionne), 132))
	lecture.add_child(StyleAzur.texte(CatalogueObjets.description_bonus(_objet_selectionne, niveau), 27))
	lecture.add_child(StyleAzur.texte(CatalogueObjets.description_effets(_objet_selectionne, niveau), 23, StyleAzur.ATTENUE))
	_progression_forge(fiche, CatalogueObjets.bonus_objet(_objet_selectionne, niveau), CatalogueObjets.bonus_objet(_objet_selectionne, niveau + 1), niveau, ReglagesJoueur.cout_forge(_objet_selectionne))
	if niveau < Reglages.FORGE_NIVEAU_MAX and niveau + 1 in EffetsBijoux.PALIERS:
		fiche.contenu.add_child(StyleAzur.texte("Ce rang débloque le pouvoir de la relique", 27, StyleAzur.OR_VIF))
	var ligne := _actions_fiche(fiche)
	_action_fiche(ligne, "Équiper", "validation", StyleAzur.VERT_VIF, func(): _agir_objet("equiper"), not equipe)
	_action_fiche(ligne, "Retirer", "non", StyleAzur.CORAIL, func(): _agir_objet("retirer"), equipe)
	_action_fiche(ligne, "Forge", "forge", StyleAzur.OR_VIF, func(): _agir_objet("forger"), niveau < Reglages.FORGE_NIVEAU_MAX and ReglagesJoueur.pierres_forge >= ReglagesJoueur.cout_forge(_objet_selectionne))

func _agir_arme(forger: bool) -> void:
	if forger: _ameliorer_arme()
	else: _equiper_arme()
	_ouvrir_fiche_arme()

func _ouvrir_fiche_arme() -> void:
	if not CatalogueProjectiles.contient(_arme_selectionnee):
		return
	var arme: Dictionary = CatalogueProjectiles.TYPES[_arme_selectionnee]
	var niveau := ReglagesJoueur.niveau_arme(_arme_selectionnee)
	var disponible := _arme_selectionnee in ReglagesJoueur.projectiles_disponibles()
	var equipe := _arme_selectionnee == ReglagesJoueur.projectile_equipe_effectif()
	var fiche := _nouvelle_fiche(str(arme["nom"]), "forge")
	fiche.contenu.add_child(StyleAzur.texte("Niveau %d%s" % [niveau, " · Équipée" if equipe else ""], 27, StyleAzur.ROUGE_VIF))
	var lecture := _lecture_fiche(fiche)
	var image_arme := TextureRect.new()
	image_arme.texture = StyleAzur.icone_arme(_arme_selectionnee)
	image_arme.custom_minimum_size = Vector2(132, 132)
	image_arme.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image_arme.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	lecture.add_child(image_arme)
	lecture.add_child(StyleAzur.texte("Attaque +%s · Tir %s %% · Cadence %s" % [_nombre(CatalogueProjectiles.attaque_base(_arme_selectionnee, niveau)), _pourcentage(float(arme["coefficient_tir"])), _ecart(float(arme.get("cadence_mult", 1.0)))], 27))
	lecture.add_child(StyleAzur.texte(str(arme["description"]), 26))
	_progression_forge(fiche, {"attaque_base": CatalogueProjectiles.attaque_base(_arme_selectionnee, niveau)}, {"attaque_base": CatalogueProjectiles.attaque_base(_arme_selectionnee, niveau + 1)}, niveau, ReglagesJoueur.cout_forge_arme(_arme_selectionnee))
	var ligne := _actions_fiche(fiche)
	_action_fiche(ligne, "Équiper", "validation", StyleAzur.VERT_VIF, func(): _agir_arme(false), disponible and not equipe)
	_action_fiche(ligne, "Forge", "forge", StyleAzur.OR_VIF, func(): _agir_arme(true), disponible and niveau < Reglages.FORGE_NIVEAU_MAX and ReglagesJoueur.pierres_forge >= ReglagesJoueur.cout_forge_arme(_arme_selectionnee))

func _agir_familier(forger: bool) -> void:
	if forger: _ameliorer_familier()
	else: _equiper_familier()
	_ouvrir_fiche_familier()

func _ouvrir_fiche_familier() -> void:
	if not CatalogueFamiliers.contient(_familier_selectionne):
		return
	var familier: Dictionary = CatalogueFamiliers.TYPES[_familier_selectionne]
	var niveau := ReglagesJoueur.niveau_familier(_familier_selectionne)
	var disponible := _familier_selectionne in ReglagesJoueur.familiers_disponibles()
	var equipe := _familier_selectionne == ReglagesJoueur.familier_equipe_effectif()
	var fiche := _nouvelle_fiche(str(familier["nom"]), "astrolabe")
	fiche.contenu.add_child(StyleAzur.texte("Niveau %d%s" % [niveau, " · Équipé" if equipe else ""], 27, StyleAzur.VERT_VIF))
	var lecture := _lecture_fiche(fiche)
	lecture.add_child(StyleAzur.texte("Attaque %s · une attaque toutes les %s s" % [_nombre(CatalogueFamiliers.attaque(_familier_selectionne, niveau)), _nombre(float(familier["intervalle"]))], 27))
	lecture.add_child(StyleAzur.texte(str(familier["description"]), 26))
	lecture.add_child(StyleAzur.texte("Bonus d’attaque permanents et de run partagés, sans critique ni salve du héros.", 25))
	_progression_forge(fiche, {"attaque_familier": CatalogueFamiliers.attaque(_familier_selectionne, niveau)}, {"attaque_familier": CatalogueFamiliers.attaque(_familier_selectionne, niveau + 1)}, niveau, Reglages.cout_forge(niveau))
	var ligne := _actions_fiche(fiche)
	_action_fiche(ligne, "Équiper", "validation", StyleAzur.VERT_VIF, func(): _agir_familier(false), disponible and not equipe)
	_action_fiche(ligne, "Forge", "forge", StyleAzur.OR_VIF, func(): _agir_familier(true), disponible and niveau < Reglages.FORGE_NIVEAU_MAX and ReglagesJoueur.pierres_forge >= Reglages.cout_forge(niveau))

func fermer_fiche() -> bool:
	if not is_instance_valid(_fiche_popup) or not _fiche_popup.visible:
		return false
	_fiche_popup.fermer()
	return true

func _exit_tree() -> void:
	if is_instance_valid(_fiche_popup):
		_fiche_popup.queue_free()

func _stats_heros() -> Stats:
	return Stats.depuis_reglages(ReglagesJoueur.rangs_competences_effectifs(),
		ReglagesJoueur.passifs_equipes_effectifs(), ReglagesJoueur.bonus_objets_effectifs(),
		ReglagesJoueur.niveau_compte_effectif(), ReglagesJoueur.attributs, ReglagesJoueur.specialisation_effective())

func _selectionner_arme(id: String) -> void:
	_arme_selectionnee = id
	Sons.jouer("choix", -16.0)
	_afficher_armes()
	_ouvrir_fiche_arme()

func _equiper_arme() -> void:
	if ReglagesJoueur.equiper_projectile(_arme_selectionnee):
		Sons.jouer("choix", -10.0)
		_rafraichir()

func _ameliorer_arme() -> void:
	if ReglagesJoueur.ameliorer_arme(_arme_selectionnee):
		_message_forge = "Forge réussie · niveau %d" % ReglagesJoueur.niveau_arme(_arme_selectionnee)
		Sons.jouer("fusion", -10.0)
		_rafraichir()

func _couleur_arme(id: String) -> Color:
	match id:
		"standard": return Color("76c9e8")
		"veloce": return Color("70e3bb")
		"lourd": return Color("e9a96d")
		"chercheur": return Color("bd9bf0")
		"explosif": return Color("ef857a")
		"prisme": return Color("80dfed")
		"resonant": return Color("83aefa")
		"draconique": return Color("ec89a9")
		"neant": return Color("ab80e8")
		"royal": return Color("e4c489")
	return StyleAzur.BLEU_VIF

func _couleur_familier(id: String) -> Color:
	match id:
		"homoncule_encre": return Color("75e4e9")
		"salamandre": return Color("ef9672")
		"ondine": return Color("8bbfff")
		"sylphe": return Color("b5a0f2")
		"golem": return Color("bad48f")
	return StyleAzur.VERT_VIF

func _creer_carte_atelier(grille: GridContainer, nom: String, texture: Texture2D, accent: Color, action: Callable) -> Dictionary:
	var bouton := Button.new()
	bouton.name = nom
	bouton.custom_minimum_size = Vector2(310, 226)
	bouton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bouton.pressed.connect(action)
	grille.add_child(bouton)
	var gravure := CadreAtelier.new()
	gravure.accent = accent
	bouton.add_child(gravure)
	var marges := MarginContainer.new()
	marges.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marges.add_theme_constant_override("margin_left", 13)
	marges.add_theme_constant_override("margin_right", 13)
	marges.add_theme_constant_override("margin_top", 13)
	marges.add_theme_constant_override("margin_bottom", 13)
	bouton.add_child(marges)
	marges.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var ligne := HBoxContainer.new()
	ligne.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ligne.add_theme_constant_override("separation", 12)
	marges.add_child(ligne)
	var cadre_image := PanelContainer.new()
	cadre_image.custom_minimum_size = Vector2(131, 170)
	cadre_image.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cadre_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fond_image := StyleBoxFlat.new()
	fond_image.bg_color = Color("354f6c").lerp(accent, 0.20)
	fond_image.border_color = accent
	fond_image.set_border_width_all(2)
	fond_image.set_corner_radius_all(16)
	for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		fond_image.set_content_margin(cote, 5)
	cadre_image.add_theme_stylebox_override("panel", fond_image)
	ligne.add_child(cadre_image)
	var image := TextureRect.new()
	image.name = "Illustration"
	image.texture = texture
	image.custom_minimum_size = Vector2(121, 160)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cadre_image.add_child(image)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 5)
	ligne.add_child(details)
	var titre := StyleAzur.texte("", 26, Color("f4f6ff"))
	titre.name = "Nom"
	details.add_child(titre)
	var stats := StyleAzur.texte("", 23, accent)
	stats.name = "Statistiques"
	details.add_child(stats)
	var effet := StyleAzur.texte("", 20, Color("dce6f5"))
	effet.name = "Effet"
	details.add_child(effet)
	var espace := Control.new()
	espace.size_flags_vertical = Control.SIZE_EXPAND_FILL
	details.add_child(espace)
	var etat := StyleAzur.texte("", 19, accent)
	etat.name = "Etat"
	details.add_child(etat)
	return {"bouton": bouton, "image": image, "titre": titre, "stats": stats, "effet": effet, "etat": etat}

func _afficher_armes() -> void:
	if _boutons_armes.is_empty():
		_armes.add_child(StyleAzur.calligraphie("Arsenal alchimique", 44, StyleAzur.CORAIL))
		var ligne := GridContainer.new()
		ligne.name = "GrilleArmes"
		ligne.columns = 2
		_grille_armes = ligne
		ligne.add_theme_constant_override("h_separation", 10)
		ligne.add_theme_constant_override("v_separation", 10)
		_armes.add_child(ligne)
		for id: String in CatalogueProjectiles.TYPES:
			var lecture := _creer_carte_atelier(ligne, "Arme_" + id, StyleAzur.icone_arme(id), _couleur_arme(id), func(): _selectionner_arme(id))
			_boutons_armes[id] = lecture["bouton"]
			_lectures_armes[id] = lecture
	if not CatalogueProjectiles.contient(_arme_selectionnee):
		_arme_selectionnee = ReglagesJoueur.projectile_equipe_effectif()
	var disponibles := ReglagesJoueur.projectiles_disponibles()
	for id: String in CatalogueProjectiles.TYPES:
		var arme: Dictionary = CatalogueProjectiles.TYPES[id]
		var disponible := id in disponibles
		var bouton: Button = _boutons_armes[id]
		var lecture: Dictionary = _lectures_armes[id]
		var titre: Label = lecture["titre"]
		var stats: Label = lecture["stats"]
		var effet: Label = lecture["effet"]
		var etat: Label = lecture["etat"]
		var image: TextureRect = lecture["image"]
		var niveau := ReglagesJoueur.niveau_arme(id)
		titre.text = str(arme["nom"])
		stats.text = "ATQ +%s  ·  Tir %s %%" % [_nombre(CatalogueProjectiles.attaque_base(id, niveau)), _pourcentage(float(arme["coefficient_tir"]))]
		effet.text = str(arme["description"])
		etat.text = "NIVEAU %d  ·  ÉQUIPÉE" % niveau if id == ReglagesJoueur.projectile_equipe_effectif() else "NIVEAU %d" % niveau if disponible else "VERROUILLÉE · %s" % Chapitres.libelle_court(CatalogueProjectiles.niveau_deblocage(id) - 1)
		image.modulate = Color.WHITE if disponible else Color("a5b6cf")
		bouton.tooltip_text = str(arme["description"])
		_styler_carte(bouton, _couleur_arme(id), id == _arme_selectionnee)

func _selectionner_familier(id: String) -> void:
	_familier_selectionne = id
	Sons.jouer("choix", -16.0)
	_afficher_familiers()
	_ouvrir_fiche_familier()

func _equiper_familier() -> void:
	if ReglagesJoueur.equiper_familier(_familier_selectionne):
		Sons.jouer("choix", -10.0)
		_rafraichir()

func _ameliorer_familier() -> void:
	if ReglagesJoueur.ameliorer_familier(_familier_selectionne):
		_message_forge = "Forge réussie · niveau %d" % ReglagesJoueur.niveau_familier(_familier_selectionne)
		Sons.jouer("fusion", -10.0)
		_rafraichir()

func _afficher_familiers() -> void:
	if _boutons_familiers.is_empty():
		_familiers.add_child(StyleAzur.texte("Compagnons", 35, Color("dcefff")))
		var grille := GridContainer.new()
		grille.name = "GrilleFamiliers"
		grille.columns = 2
		_grille_familiers = grille
		grille.add_theme_constant_override("h_separation", 10)
		grille.add_theme_constant_override("v_separation", 10)
		_familiers.add_child(grille)
		for valeur in CatalogueFamiliers.TYPES:
			var id := str(valeur)
			var texture := load("res://assets/visual/interface/menu/familiers/" + id + ".svg") as Texture2D
			var lecture := _creer_carte_atelier(grille, "Familier_" + id, texture, _couleur_familier(id), func(): _selectionner_familier(id))
			_boutons_familiers[id] = lecture["bouton"]
			_lectures_familiers[id] = lecture
	if not CatalogueFamiliers.contient(_familier_selectionne):
		_familier_selectionne = ReglagesJoueur.familier_equipe_effectif()
	var disponibles := ReglagesJoueur.familiers_disponibles()
	for valeur in CatalogueFamiliers.TYPES:
		var id := str(valeur)
		var donnees: Dictionary = CatalogueFamiliers.TYPES[id]
		var bouton: Button = _boutons_familiers[id]
		var lecture: Dictionary = _lectures_familiers[id]
		var titre: Label = lecture["titre"]
		var stats: Label = lecture["stats"]
		var effet: Label = lecture["effet"]
		var etat: Label = lecture["etat"]
		var image: TextureRect = lecture["image"]
		var niveau := ReglagesJoueur.niveau_familier(id)
		titre.text = str(donnees["nom"])
		stats.text = "ATQ %s  ·  toutes les %s s" % [_nombre(CatalogueFamiliers.attaque(id, niveau)), _nombre(float(donnees["intervalle"]))]
		effet.text = str(donnees["description"])
		etat.text = "NIVEAU %d  ·  ÉQUIPÉ" % niveau if id == ReglagesJoueur.familier_equipe_effectif() else "NIVEAU %d" % niveau if id in disponibles else "VERROUILLÉ · %s" % Chapitres.libelle_court(CatalogueFamiliers.niveau_deblocage(id) - 1)
		image.modulate = Color.WHITE if id in disponibles else Color("a5b6cf")
		bouton.tooltip_text = str(donnees["description"])
		_styler_carte(bouton, _couleur_familier(id), id == _familier_selectionne)
