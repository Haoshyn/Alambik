extends Control

signal ferme
signal page_demandee(index: int)
signal reglages

const FOND_PASSIF := preload("res://ui/composants/fond_carte_passif.gd")


var integre_menu := false
var _categorie := "Tous"
var _tri := 0
var _message := ""
var _defilement_collection: DefilementTactile
var _cartes: GridContainer
var _grille_equipes: GridContainer
var _ligne_categories: BoxContainer
var _entete_collection: BoxContainer
var _statut: Label
var _collection: Label
var _fiche_popup: FenetreFiche
var _slots: Array[Button] = []
var _icones_slots: Array[TextureRect] = []
var _textes_slots: Array[Label] = []
var _titres_slots: Array[Label] = []
var _rangs_slots: Array[Label] = []
var _categories: Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	theme = StyleAzur.theme_interface()
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	# Le fond calme assure le contraste sans ajouter de boites sous chaque texte.
	set_meta("surface_lecture", false)
	_construire_fond()
	var marge := MarginContainer.new()
	marge.name = "ZoneSurePassifs"
	marge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(marge)
	resized.connect(_cadrer.bind(marge))
	_cadrer(marge)
	var contenu := VBoxContainer.new()
	contenu.name = "CompositionPassifs"
	contenu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contenu.add_theme_constant_override("separation", 28)
	marge.add_child(contenu)
	if not integre_menu:
		var retour := StyleAzur.bouton("‹  Retour", func(): ferme.emit())
		retour.custom_minimum_size = Vector2(190, 72)
		retour.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		contenu.add_child(retour)
	_construire_categories(contenu)
	_construire_equipes(contenu)
	_construire_collection(contenu)
	resized.connect(_adapter_mise_en_page)
	_adapter_mise_en_page.call_deferred()
	_rafraichir()
	Capture.programmer(self)

func _construire_fond() -> void:
	var nuance := Gradient.new()
	nuance.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	nuance.colors = PackedColorArray([Color("292d48"), Color("22283e"), Color("302b43")])
	var texture := GradientTexture2D.new()
	texture.gradient = nuance
	texture.width = 64
	texture.height = 128
	texture.fill_from = Vector2.ZERO
	texture.fill_to = Vector2.ONE
	var fond := TextureRect.new()
	fond.name = "NuancePassifs"
	fond.texture = texture
	fond.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fond)
	fond.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _cadrer(marge: MarginContainer) -> void:
	var lateral := maxi(28, int((size.x - 1080.0) * 0.5))
	marge.add_theme_constant_override("margin_left", maxi(lateral, int(Ecran.marge_gauche())))
	marge.add_theme_constant_override("margin_right", maxi(lateral, int(Ecran.marge_droite())))
	marge.add_theme_constant_override("margin_top", int(Ecran.marge_haute()) + 36)
	marge.add_theme_constant_override("margin_bottom", int(Ecran.marge_basse() + StyleAzur.HAUTEUR_NAVIGATION + StyleAzur.MARGE_NAVIGATION_BAS + 12) if integre_menu else int(Ecran.marge_basse()) + 24)

func _adapter_mise_en_page() -> void:
	if _cartes == null: return
	var largeur := _defilement_collection.size.x
	var compact := largeur < 900.0
	(_ligne_categories.get_parent() as VBoxContainer).add_theme_constant_override("separation", 20 if compact else 28)
	_grille_equipes.columns = 4 if largeur >= 620.0 else 2
	_grille_equipes.add_theme_constant_override("h_separation", 16)
	var cote := minf(208.0, (largeur - 36.0 - 16.0 * (_grille_equipes.columns - 1)) / _grille_equipes.columns)
	for index in _slots.size():
		var bloc := _slots[index].get_parent() as VBoxContainer
		bloc.custom_minimum_size.x = 0
		_slots[index].custom_minimum_size = Vector2.ONE * cote
		_slots[index].add_theme_font_size_override("font_size", 28)
		_icones_slots[index].position = Vector2.ONE * cote * 0.15
		_icones_slots[index].size = Vector2.ONE * cote * 0.7
		_titres_slots[index].add_theme_font_size_override("font_size", 32 if compact else 36)
		_textes_slots[index].add_theme_font_size_override("font_size", 28 if compact else 30)
		_rangs_slots[index].add_theme_font_size_override("font_size", 28)
	_cartes.columns = 2 if largeur >= 900.0 else 1
	_ligne_categories.vertical = largeur < 620.0
	_entete_collection.vertical = largeur < 800.0
	for categorie: String in _categories:
		var bouton: Button = _categories[categorie]
		bouton.add_theme_font_size_override("font_size", 28 if compact else 30)
		bouton.add_theme_constant_override("icon_max_width", 32 if compact else 36)
	_adapter_cartes.call_deferred()

func _adapter_cartes() -> void:
	if _cartes.get_child_count() == 0: return
	var lignes := ceili(float(_cartes.get_child_count()) / _cartes.columns)
	var hauteur := clampf((_defilement_collection.size.y - 20.0 * (lignes - 1)) / lignes, 308.0, 390.0)
	for carte: Control in _cartes.get_children():
		carte.custom_minimum_size.y = hauteur

func _construire_categories(parent: VBoxContainer) -> void:
	var ligne := BoxContainer.new()
	ligne.name = "CategoriesPassifs"
	ligne.add_theme_constant_override("separation", 18)
	parent.add_child(ligne)
	_ligne_categories = ligne
	for categorie in ["Tous", "Offensif", "Défensif", "Utilitaire"]:
		var bouton := Button.new()
		bouton.name = "Categorie_" + categorie
		bouton.text = categorie
		bouton.icon = StyleAzur.glyphe({"Tous": "savoir", "Offensif": "puissance", "Défensif": "rempart", "Utilitaire": "collecte"}[categorie])
		bouton.expand_icon = true
		bouton.custom_minimum_size.y = 110
		bouton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bouton.add_theme_font_override("font", Polices.GRIMOIRE)
		bouton.add_theme_font_size_override("font_size", 40)
		bouton.add_theme_constant_override("icon_max_width", 60)
		bouton.add_theme_constant_override("h_separation", 14)
		bouton.pressed.connect(_afficher.bind(categorie))
		ligne.add_child(bouton)
		_categories[categorie] = bouton

func _construire_equipes(parent: VBoxContainer) -> void:
	var fond := MarginContainer.new()
	fond.name = "PassifsEquipes"
	for cote in ["left", "right", "top", "bottom"]: fond.add_theme_constant_override("margin_" + cote, 18)
	parent.add_child(fond)
	var grille := GridContainer.new()
	grille.name = "EmplacementsEquipes"
	grille.columns = 4
	grille.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grille.add_theme_constant_override("h_separation", 16)
	grille.add_theme_constant_override("v_separation", 18)
	fond.add_child(grille)
	_grille_equipes = grille
	for index in Passifs.EMPLACEMENTS:
		var accent := _couleur_categorie("Tous")
		var bloc := VBoxContainer.new()
		bloc.name = "Emplacement_" + str(index)
		bloc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bloc.add_theme_constant_override("separation", 8)
		grille.add_child(bloc)
		var titre := StyleAzur.calligraphie("Passif %d" % (index + 1), 36, accent)
		titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bloc.add_child(titre)
		_titres_slots.append(titre)
		var medaillon := Button.new()
		medaillon.name = "Medaillon_" + str(index)
		medaillon.custom_minimum_size = Vector2(208, 208)
		medaillon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		medaillon.add_theme_font_override("font", Polices.GRIMOIRE)
		medaillon.add_theme_font_size_override("font_size", 28)
		StyleAzur.texte_bouton_colore(medaillon, accent)
		medaillon.add_theme_color_override("font_disabled_color", accent.darkened(0.1))
		for etat in ["normal", "hover", "pressed", "disabled"]:
			var style := StyleAzur.cercle(etat in ["hover", "pressed"])
			style.modulate_color = Color.WHITE.lerp(accent, 0.2)
			medaillon.add_theme_stylebox_override(etat, style)
		medaillon.add_theme_stylebox_override("focus", StyleAzur.cercle(true))
		medaillon.pressed.connect(_retirer_slot.bind(index))
		bloc.add_child(medaillon)
		var icone := TextureRect.new()
		icone.name = "GlypheEquipe_" + str(index)
		icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icone.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icone.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		medaillon.add_child(icone)
		_icones_slots.append(icone)
		var legende := StyleAzur.calligraphie("", 30, accent.lightened(0.15))
		legende.name = "NomEquipe_" + str(index)
		legende.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		legende.custom_minimum_size.y = 80
		bloc.add_child(legende)
		_textes_slots.append(legende)
		var rang := StyleAzur.texte("", 26, accent)
		rang.name = "RangEquipe_" + str(index)
		rang.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rang.custom_minimum_size.y = 38
		bloc.add_child(rang)
		_rangs_slots.append(rang)
		_slots.append(medaillon)

func _construire_collection(parent: VBoxContainer) -> void:
	var entete := BoxContainer.new()
	entete.name = "EnteteCollection"
	entete.add_theme_constant_override("separation", 12)
	parent.add_child(entete)
	_entete_collection = entete
	var titre := StyleAzur.calligraphie("Collection des passifs", 38, StyleAzur.LILAS)
	titre.name = "TitreCollection"
	titre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entete.add_child(titre)
	var outils := HBoxContainer.new()
	outils.name = "OutilsCollection"
	outils.alignment = BoxContainer.ALIGNMENT_END
	outils.add_theme_constant_override("separation", 12)
	entete.add_child(outils)
	_collection = StyleAzur.texte("", 30, StyleAzur.CUIVRE)
	_collection.autowrap_mode = TextServer.AUTOWRAP_OFF
	outils.add_child(_collection)
	var tri := OptionButton.new()
	tri.name = "TriCollection"
	tri.custom_minimum_size = Vector2(205, 62)
	tri.add_item("Découverte")
	tri.add_item("Nom")
	tri.add_item("Rang")
	tri.item_selected.connect(func(index: int):
		_tri = index
		_rendre())
	for etat in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style_tri := StyleAzur.cadre_enlumine(StyleAzur.LILAS, etat in ["hover", "focus"])
		for cote in [SIDE_LEFT, SIDE_RIGHT]: style_tri.set_content_margin(cote, 22)
		for cote in [SIDE_TOP, SIDE_BOTTOM]: style_tri.set_content_margin(cote, 12)
		tri.add_theme_stylebox_override(etat, style_tri)
	StyleAzur.texte_bouton_colore(tri, StyleAzur.CUIVRE)
	tri.add_theme_font_size_override("font_size", 28)
	outils.add_child(tri)
	_statut = StyleAzur.texte("", 25, Color("9ff5d2"))
	_statut.name = "IndicationsPassifs"
	parent.add_child(_statut)
	_cartes = GridContainer.new()
	_cartes.name = "GrilleCollection"
	_cartes.columns = 2
	_cartes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cartes.add_theme_constant_override("h_separation", 18)
	_cartes.add_theme_constant_override("v_separation", 20)
	_defilement_collection = DefilementTactile.new()
	_defilement_collection.name = "DefilementCollection"
	_defilement_collection.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_defilement_collection.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_defilement_collection.follow_focus = true
	parent.add_child(_defilement_collection)
	_defilement_collection.add_child(_cartes)
	_defilement_collection.resized.connect(_adapter_mise_en_page)

func _icone_passif(id: String) -> Texture2D:
	return StyleAzur.glyphe(str(Passifs.donnees(id).get("icone", "savoir")))

func _style_onglet(categorie: String, choisi: bool) -> StyleBoxTexture:
	var accent := _couleur_categorie(categorie)
	var style := StyleAzur.cadre_enlumine(accent, choisi)
	for cote in [SIDE_LEFT, SIDE_RIGHT]: style.set_content_margin(cote, 20)
	for cote in [SIDE_TOP, SIDE_BOTTOM]: style.set_content_margin(cote, 16)
	return style

func _rendre() -> void:
	_collection.text = "%d / %d" % [ReglagesJoueur.nombre_passifs_debloques(), Passifs.CATALOGUE.size()]
	_statut.text = _message if not _message.is_empty() else "%d passifs équipés au maximum · %d rangs · Exclusivement en Épreuves" % [Passifs.EMPLACEMENTS, Passifs.RANG_MAX]
	_statut.visible = true
	for cat: String in _categories:
		var bouton: Button = _categories[cat]
		var choisi := cat == _categorie
		for etat in ["normal", "hover", "pressed", "disabled"]:
			bouton.add_theme_stylebox_override(etat, _style_onglet(cat, choisi))
		StyleAzur.texte_bouton_colore(bouton, _couleur_categorie(cat))
	var equipes := ReglagesJoueur.passifs_equipes
	for index in Passifs.EMPLACEMENTS:
		var id := str(equipes[index]) if index < equipes.size() else ""
		var vide := id.is_empty()
		_slots[index].text = "Libre" if vide else ""
		_slots[index].disabled = vide
		_slots[index].tooltip_text = "Emplacement %d libre" % (index + 1) if vide else "Retirer %s" % str(Passifs.donnees(id)["nom"])
		_slots[index].accessibility_name = _slots[index].tooltip_text
		_icones_slots[index].visible = not vide
		if not vide: _icones_slots[index].texture = _icone_passif(id)
		_rangs_slots[index].text = "" if vide else "Rang %d / %d" % [ReglagesJoueur.rang_passif(id), Passifs.RANG_MAX]
		_rangs_slots[index].visible = not vide
		_textes_slots[index].text = "À équiper" if vide else str(Passifs.donnees(id)["nom"])
	for enfant in _cartes.get_children():
		_cartes.remove_child(enfant)
		enfant.queue_free()
	var ids := _ids()
	for index in ids.size():
		var id := ids[index]
		var donnees: Dictionary = _catalogue()[id]
		var ouvert := ReglagesJoueur.passif_debloque(id)
		var equipe := id in ReglagesJoueur.passifs_equipes
		_cartes.add_child(_carte_passif(id, donnees, index, ouvert, equipe))
	_adapter_cartes.call_deferred()

func _carte_passif(id: String, donnees: Dictionary, index: int, ouvert: bool, equipe: bool) -> PanelContainer:
	var accent := FOND_PASSIF.accent_pour(id)
	var carte := PanelContainer.new()
	carte.name = "Carte_" + id
	carte.mouse_filter = Control.MOUSE_FILTER_PASS
	carte.custom_minimum_size.y = 308
	carte.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	carte.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	var ouvrir := Button.new()
	ouvrir.name = "Details_" + id
	ouvrir.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	ouvrir.mouse_filter = Control.MOUSE_FILTER_PASS
	ouvrir.accessibility_name = "Détails de " + str(donnees["nom"])
	ouvrir.tooltip_text = ouvrir.accessibility_name
	for etat in ["normal", "hover", "pressed", "focus"]:
		ouvrir.add_theme_stylebox_override(etat, StyleBoxEmpty.new())
	ouvrir.pressed.connect(_ouvrir_fiche.bind(index))
	carte.add_child(ouvrir)
	var fond := FOND_PASSIF.new()
	fond.name = "Ambiance_" + id
	fond.identifiant = id
	carte.add_child(fond)
	ouvrir.mouse_entered.connect(fond.illuminer.bind(true))
	ouvrir.mouse_exited.connect(fond.illuminer.bind(false))
	ouvrir.focus_entered.connect(fond.illuminer.bind(true))
	ouvrir.focus_exited.connect(fond.illuminer.bind(false))
	ouvrir.button_down.connect(fond.illuminer.bind(true))
	ouvrir.button_up.connect(fond.illuminer.bind(false))
	var marge := MarginContainer.new()
	for cote in ["left", "right"]: marge.add_theme_constant_override("margin_" + cote, 32)
	for cote in ["top", "bottom"]: marge.add_theme_constant_override("margin_" + cote, 28)
	carte.add_child(marge)
	var contenu := VBoxContainer.new()
	contenu.add_theme_constant_override("separation", 12)
	marge.add_child(contenu)
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 18)
	contenu.add_child(ligne)
	var icone := TextureRect.new()
	icone.name = "Glyphe_" + id
	icone.texture = _icone_passif(id)
	icone.custom_minimum_size = Vector2(124, 124)
	icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icone.modulate = Color.WHITE if ouvert else Color("b3a9c7")
	icone.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	ligne.add_child(icone)
	var textes := VBoxContainer.new()
	textes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textes.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	textes.add_theme_constant_override("separation", 6)
	ligne.add_child(textes)
	var nom := StyleAzur.calligraphie(str(donnees["nom"]), 40, accent)
	nom.name = "Nom_" + id
	textes.add_child(nom)
	var rang := StyleAzur.texte("Rang %d" % ReglagesJoueur.rang_passif(id) if ouvert else "À découvrir", 27, StyleAzur.CUIVRE)
	textes.add_child(rang)
	var description := StyleAzur.texte(str(donnees["description"]), 28, StyleAzur.LILAS)
	description.size_flags_vertical = Control.SIZE_EXPAND_FILL
	description.max_lines_visible = 3
	description.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	contenu.add_child(description)
	var etat := StyleAzur.texte("Équipé" if equipe else "Disponible" if ouvert else "À obtenir en Épreuve", 28, StyleAzur.VERT_VIF if equipe else accent)
	etat.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	contenu.add_child(etat)
	# Les enfants decoratifs laissent toute la carte au bouton et le glissement au defilement.
	_ignorer_souris(marge)
	return carte

func _ignorer_souris(noeud: Control) -> void:
	noeud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for enfant in noeud.get_children():
		if enfant is Control: _ignorer_souris(enfant)

func _ouvrir_fiche(index: int) -> void:
	var id := _ids()[index]
	var donnees: Dictionary = _catalogue()[id]
	if is_instance_valid(_fiche_popup): _fiche_popup.queue_free()
	var fiche := FenetreFiche.new()
	fiche.set_meta("surface_lecture", false)
	fiche.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var parent_fiche: Node = get_parent().get_parent() if integre_menu else self
	parent_fiche.add_child(fiche)
	_fiche_popup = fiche
	fiche.configurer(str(donnees["nom"]), id)
	fiche.definir_embleme(_icone_passif(id))
	var contenu := fiche.contenu
	contenu.add_child(StyleAzur.texte(str(donnees["categorie"]) + " · " + ("Débloqué" if ReglagesJoueur.passif_debloque(id) else "À découvrir"), 25, _couleur_categorie(_categorie)))
	var lecture := VBoxContainer.new()
	lecture.add_theme_constant_override("separation", 16)
	contenu.add_child(lecture)
	lecture.add_child(StyleAzur.texte(str(donnees["description"]), 30, StyleAzur.LILAS))
	var rang := ReglagesJoueur.rang_passif(id)
	lecture.add_child(StyleAzur.texte("Rang %d / %d · %s" % [rang, Passifs.rang_max(id), Passifs.resume_rang(id, rang)], 28, StyleAzur.CUIVRE))
	lecture.add_child(StyleAzur.texte(Passifs.progression_rang(id), 26, StyleAzur.MENTHE))
	var equipe := id in ReglagesJoueur.passifs_equipes
	if ReglagesJoueur.passif_debloque(id):
		var action_passif := StyleAzur.bouton("Retirer" if equipe else "Équiper", func():
			_choisir_index(index)
			fiche.fermer(), true)
		StyleAzur.action_coloree(action_passif, _couleur_categorie(_categorie))
		contenu.add_child(action_passif)
	else:
		lecture.add_child(StyleAzur.texte(Epreuves.provenance(id), 28, StyleAzur.CUIVRE))

func fermer_fiche() -> bool:
	if not is_instance_valid(_fiche_popup) or not _fiche_popup.visible: return false
	_fiche_popup.fermer()
	return true

func _exit_tree() -> void:
	if is_instance_valid(_fiche_popup): _fiche_popup.queue_free()

func _couleur_categorie(categorie: String) -> Color:
	match categorie:
		"Offensif": return Color("ffb58a")
		"Défensif": return Color("9ddeff")
		"Utilitaire": return Color("d5b6ff")
	return Color("67e7b1")

func _catalogue() -> Dictionary:
	var resultat := {}
	for id: String in Passifs.CATALOGUE:
		var donnees: Dictionary = Passifs.CATALOGUE[id]
		if _categorie == "Tous" or str(donnees["categorie"]) == _categorie:
			resultat[id] = donnees
	return resultat

func _ids() -> Array[String]:
	var ids: Array[String] = []
	for id in _catalogue(): ids.append(id)
	if _tri == 1:
		ids.sort_custom(func(a: String, b: String) -> bool:
			var donnees_a: Dictionary = _catalogue()[a]
			var donnees_b: Dictionary = _catalogue()[b]
			return str(donnees_a["nom"]).nocasecmp_to(str(donnees_b["nom"])) < 0)
	elif _tri == 2:
		ids.sort_custom(func(a: String, b: String) -> bool:
			return ReglagesJoueur.rang_passif(a) > ReglagesJoueur.rang_passif(b))
	return ids

func _afficher(categorie: String) -> void:
	if categorie == _categorie:
		return
	_defilement_collection.scroll_vertical = 0
	_categorie = categorie
	_message = ""
	Sons.jouer("choix", -17.0)
	_rafraichir()

func _choisir_index(index: int) -> void:
	var ids := _ids()
	if index >= ids.size(): return
	var id := ids[index]
	var resultat := ReglagesJoueur.basculer_passif(id)
	var nom := str(Passifs.donnees(id)["nom"])
	match resultat:
		"equipe": _message = "%s équipé." % nom
		"retire": _message = "%s retiré." % nom
		"plein": _message = "Les 4 emplacements sont occupés. Retirez un passif pour en équiper un autre."
		_: _message = "%s : %s." % [nom, Epreuves.provenance(id)]
	Sons.jouer("choix", -12.0)
	_rafraichir()

func _retirer_slot(index: int) -> void:
	if index >= ReglagesJoueur.passifs_equipes.size(): return
	var id := ReglagesJoueur.passifs_equipes[index]
	ReglagesJoueur.basculer_passif(id)
	_message = "%s retiré." % str(Passifs.donnees(id)["nom"])
	Sons.jouer("choix", -12.0)
	_rafraichir()

func _rafraichir() -> void:
	_rendre()
