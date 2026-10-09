extends Control

signal ferme
signal page_demandee(index: int)
signal reglages

const FOND_PASSIF := preload("res://ui/composants/fond_carte_passif.gd")
const GLYPHES_PASSIFS := {
	"vigueur": preload("res://assets/visual/interface/menu/passifs/glyphes/vigueur.svg"),
	"vitalite": preload("res://assets/visual/interface/menu/passifs/glyphes/vitalite.svg"),
	"carapace": preload("res://assets/visual/interface/menu/passifs/glyphes/carapace.svg"),
	"celerite": preload("res://assets/visual/interface/menu/passifs/glyphes/celerite.svg"),
	"pas_leger": preload("res://assets/visual/interface/menu/passifs/glyphes/pas_leger.svg"),
	"oeil_precis": preload("res://assets/visual/interface/menu/passifs/glyphes/oeil_precis.svg"),
	"impact_critique": preload("res://assets/visual/interface/menu/passifs/glyphes/impact_critique.svg"),
	"projectiles_vifs": preload("res://assets/visual/interface/menu/passifs/glyphes/projectiles_vifs.svg"),
	"soins_renforces": preload("res://assets/visual/interface/menu/passifs/glyphes/soins_renforces.svg"),
	"recuperation": preload("res://assets/visual/interface/menu/passifs/glyphes/recuperation.svg"),
	"moisson_vitale": preload("res://assets/visual/interface/menu/passifs/glyphes/moisson_vitale.svg"),
	"sang_froid": preload("res://assets/visual/interface/menu/passifs/glyphes/sang_froid.svg"),
	"rempart_initial": preload("res://assets/visual/interface/menu/passifs/glyphes/rempart_initial.svg"),
	"audace": preload("res://assets/visual/interface/menu/passifs/glyphes/audace.svg"),
	"butin_precieux": preload("res://assets/visual/interface/menu/passifs/glyphes/butin_precieux.svg"),
	"savoir_pratique": preload("res://assets/visual/interface/menu/passifs/glyphes/savoir_pratique.svg"),
}

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
	# Le contraste vient des caracteres ; la clairiere reste celle des autres menus.
	set_meta("surface_lecture", false)
	var contenu := StyleAzur.page(self, "Passifs", integre_menu)
	contenu.name = "CompositionPassifs"
	contenu.add_theme_constant_override("separation", 20)
	_construire_equipes(contenu)
	_construire_collection(contenu)
	resized.connect(_adapter_mise_en_page)
	_adapter_mise_en_page.call_deferred()
	_rafraichir()
	Capture.programmer(self)

func _texte(contenu: String, taille: int, couleur: Color, titre := false) -> Label:
	var label := StyleAzur.calligraphie(contenu, taille, couleur) if titre else StyleAzur.texte(contenu, taille, couleur)
	label.add_theme_font_size_override("font_size", taille)
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_color_override("font_outline_color", Color("17283ee0"))
	label.add_theme_color_override("font_shadow_color", Color("152239cc"))
	label.add_theme_constant_override("shadow_offset_y", 2)
	return label

func _adapter_mise_en_page() -> void:
	if _cartes == null: return
	var largeur := _defilement_collection.size.x
	var compact := largeur < 900.0
	_grille_equipes.columns = 4 if largeur >= 620.0 else 2
	var cote := minf(164.0, (largeur - 18.0 * (_grille_equipes.columns - 1)) / _grille_equipes.columns)
	for index in _slots.size():
		var bloc := _slots[index].get_parent() as VBoxContainer
		bloc.custom_minimum_size.x = 0
		_slots[index].custom_minimum_size = Vector2.ONE * cote
		_slots[index].add_theme_font_size_override("font_size", 28)
		_icones_slots[index].position = Vector2.ONE * cote * 0.12
		_icones_slots[index].size = Vector2.ONE * cote * 0.76
		_titres_slots[index].add_theme_font_size_override("font_size", 30 if compact else 32)
		_textes_slots[index].add_theme_font_size_override("font_size", 26 if compact else 28)
		_rangs_slots[index].add_theme_font_size_override("font_size", 25)
	_cartes.columns = 2 if largeur >= 900.0 else 1
	_ligne_categories.vertical = largeur < 620.0
	_entete_collection.vertical = largeur < 800.0
	for categorie: String in _categories:
		var bouton: Button = _categories[categorie]
		bouton.add_theme_font_size_override("font_size", 28 if compact else 30)
	_adapter_cartes.call_deferred()

func _adapter_cartes() -> void:
	if _cartes.get_child_count() == 0: return
	# La taille des entrees ne change pas lorsque le filtre reduit la collection.
	var hauteur := 236.0 if _cartes.columns == 2 else 212.0
	for carte: Control in _cartes.get_children():
		carte.custom_minimum_size.y = hauteur

func _construire_categories(parent: VBoxContainer) -> void:
	var ligne := BoxContainer.new()
	ligne.name = "CategoriesPassifs"
	ligne.add_theme_constant_override("separation", 12)
	parent.add_child(ligne)
	_ligne_categories = ligne
	for categorie in ["Tous", "Offensif", "Défensif", "Utilitaire"]:
		var bouton := Button.new()
		bouton.name = "Categorie_" + categorie
		bouton.text = categorie
		bouton.toggle_mode = true
		bouton.custom_minimum_size.y = 96
		bouton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bouton.add_theme_font_override("font", Polices.JEU_FORT)
		bouton.add_theme_font_size_override("font_size", 30)
		bouton.add_theme_color_override("font_outline_color", Color("17283ef0"))
		bouton.add_theme_constant_override("outline_size", 2)
		bouton.pressed.connect(_afficher.bind(categorie))
		ligne.add_child(bouton)
		_categories[categorie] = bouton

func _construire_equipes(parent: VBoxContainer) -> void:
	var grille := GridContainer.new()
	grille.name = "PassifsEquipes"
	grille.columns = 4
	grille.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grille.add_theme_constant_override("h_separation", 18)
	grille.add_theme_constant_override("v_separation", 16)
	parent.add_child(grille)
	_grille_equipes = grille
	for index in Passifs.EMPLACEMENTS:
		var accent := FOND_PASSIF.accent_categorie("Tous")
		var bloc := VBoxContainer.new()
		bloc.name = "Emplacement_" + str(index)
		bloc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bloc.add_theme_constant_override("separation", 8)
		grille.add_child(bloc)
		var titre := _texte("Passif %d" % (index + 1), 32, StyleAzur.IVOIRE, true)
		titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bloc.add_child(titre)
		_titres_slots.append(titre)
		var medaillon := Button.new()
		medaillon.name = "Medaillon_" + str(index)
		medaillon.custom_minimum_size = Vector2(164, 164)
		medaillon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		medaillon.add_theme_font_override("font", Polices.JEU_FORT)
		medaillon.add_theme_font_size_override("font_size", 28)
		StyleAzur.texte_bouton_colore(medaillon, accent)
		medaillon.add_theme_color_override("font_disabled_color", accent.darkened(0.1))
		for etat in ["normal", "hover", "pressed", "disabled"]:
			var style := StyleAzur.cercle_teinte(accent, etat in ["hover", "pressed"])
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
		var legende := _texte("", 28, StyleAzur.IVOIRE, true)
		legende.name = "NomEquipe_" + str(index)
		legende.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		legende.custom_minimum_size.y = 64
		bloc.add_child(legende)
		_textes_slots.append(legende)
		var rang := _texte("", 25, StyleAzur.CUIVRE)
		rang.name = "RangEquipe_" + str(index)
		rang.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rang.custom_minimum_size.y = 30
		bloc.add_child(rang)
		_rangs_slots.append(rang)
		_slots.append(medaillon)

func _construire_collection(parent: VBoxContainer) -> void:
	var entete := BoxContainer.new()
	entete.name = "EnteteCollection"
	entete.add_theme_constant_override("separation", 12)
	parent.add_child(entete)
	_entete_collection = entete
	var titre := _texte("Collection des passifs", 38, StyleAzur.IVOIRE, true)
	titre.name = "TitreCollection"
	titre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entete.add_child(titre)
	var outils := HBoxContainer.new()
	outils.name = "OutilsCollection"
	outils.alignment = BoxContainer.ALIGNMENT_END
	outils.add_theme_constant_override("separation", 12)
	entete.add_child(outils)
	_collection = _texte("", 28, StyleAzur.CUIVRE)
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
	_construire_categories(parent)
	_statut = _texte("", 26, StyleAzur.IVOIRE)
	_statut.name = "IndicationsPassifs"
	parent.add_child(_statut)
	_cartes = GridContainer.new()
	_cartes.name = "GrilleCollection"
	_cartes.columns = 2
	_cartes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cartes.add_theme_constant_override("h_separation", 28)
	_cartes.add_theme_constant_override("v_separation", 16)
	_defilement_collection = DefilementTactile.new()
	_defilement_collection.name = "DefilementCollection"
	_defilement_collection.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_defilement_collection.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_defilement_collection.follow_focus = true
	parent.add_child(_defilement_collection)
	_defilement_collection.add_child(_cartes)
	_defilement_collection.resized.connect(_adapter_mise_en_page)

func _icone_passif(id: String) -> Texture2D:
	# Les prechargements directs empechent le retour vers les anciennes planches raster.
	var texture: Texture2D = GLYPHES_PASSIFS[id]
	return texture

func _style_onglet(categorie: String, choisi: bool) -> StyleBox:
	var accent := FOND_PASSIF.accent_categorie(categorie)
	var style := StyleAzur.cadre_enlumine(accent, choisi, choisi)
	for cote in [SIDE_LEFT, SIDE_RIGHT]: style.set_content_margin(cote, 20)
	for cote in [SIDE_TOP, SIDE_BOTTOM]: style.set_content_margin(cote, 16)
	return style

func _rendre() -> void:
	_collection.text = "%d / %d découverts" % [ReglagesJoueur.nombre_passifs_debloques(), Passifs.CATALOGUE.size()]
	_statut.text = _message if not _message.is_empty() else "%d emplacements · %d rangs · À obtenir en Épreuves" % [Passifs.EMPLACEMENTS, Passifs.RANG_MAX]
	_statut.visible = true
	for cat: String in _categories:
		var bouton: Button = _categories[cat]
		var choisi := cat == _categorie
		bouton.set_pressed_no_signal(choisi)
		for etat in ["normal", "hover", "pressed", "disabled"]:
			bouton.add_theme_stylebox_override(etat, _style_onglet(cat, choisi or etat in ["hover", "pressed"]))
		bouton.add_theme_stylebox_override("focus", _style_onglet(cat, true))
		StyleAzur.texte_bouton_colore(bouton, FOND_PASSIF.accent_categorie(cat) if choisi else StyleAzur.IVOIRE)
	var equipes := ReglagesJoueur.passifs_equipes
	for index in Passifs.EMPLACEMENTS:
		var id := str(equipes[index]) if index < equipes.size() else ""
		var vide := id.is_empty()
		_slots[index].text = "+" if vide else ""
		_slots[index].disabled = vide
		_slots[index].tooltip_text = "Emplacement %d libre" % (index + 1) if vide else "Retirer %s" % str(Passifs.donnees(id)["nom"])
		_slots[index].accessibility_name = _slots[index].tooltip_text
		_icones_slots[index].visible = not vide
		if not vide: _icones_slots[index].texture = _icone_passif(id)
		_rangs_slots[index].text = "" if vide else "Rang %d / %d" % [ReglagesJoueur.rang_passif(id), Passifs.RANG_MAX]
		_textes_slots[index].text = "Libre" if vide else str(Passifs.donnees(id)["nom"])
	for enfant in _cartes.get_children():
		_cartes.remove_child(enfant)
		enfant.queue_free()
	var ids := _ids()
	for id: String in ids:
		var donnees: Dictionary = _catalogue()[id]
		var ouvert := ReglagesJoueur.passif_debloque(id)
		var equipe := id in ReglagesJoueur.passifs_equipes
		_cartes.add_child(_carte_passif(id, donnees, ouvert, equipe))
	_adapter_cartes.call_deferred()

func _carte_passif(id: String, donnees: Dictionary, ouvert: bool, equipe: bool) -> PanelContainer:
	var accent := FOND_PASSIF.accent_pour(id)
	var carte := PanelContainer.new()
	carte.name = "Carte_" + id
	carte.mouse_filter = Control.MOUSE_FILTER_PASS
	carte.custom_minimum_size.y = 236
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
	ouvrir.pressed.connect(_ouvrir_fiche.bind(id))
	carte.add_child(ouvrir)
	var fond := FOND_PASSIF.new()
	fond.name = "Ambiance_" + id
	fond.identifiant = id
	fond.equipe = equipe
	carte.add_child(fond)
	ouvrir.mouse_entered.connect(fond.illuminer.bind(true))
	ouvrir.mouse_exited.connect(fond.illuminer.bind(false))
	ouvrir.focus_entered.connect(fond.illuminer.bind(true))
	ouvrir.focus_exited.connect(fond.illuminer.bind(false))
	ouvrir.button_down.connect(fond.illuminer.bind(true))
	ouvrir.button_up.connect(fond.illuminer.bind(false))
	var marge := MarginContainer.new()
	for cote in ["left", "right"]: marge.add_theme_constant_override("margin_" + cote, 12)
	for cote in ["top", "bottom"]: marge.add_theme_constant_override("margin_" + cote, 18)
	carte.add_child(marge)
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 16)
	marge.add_child(ligne)
	var icone := TextureRect.new()
	icone.name = "Glyphe_" + id
	icone.texture = _icone_passif(id)
	icone.custom_minimum_size = Vector2(112, 112)
	icone.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icone.modulate.a = 1.0 if ouvert else 0.78
	icone.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	ligne.add_child(icone)
	var textes := VBoxContainer.new()
	textes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textes.add_theme_constant_override("separation", 8)
	ligne.add_child(textes)
	var nom := _texte(str(donnees["nom"]), 36, StyleAzur.IVOIRE, true)
	nom.name = "Nom_" + id
	textes.add_child(nom)
	var rang_actuel := ReglagesJoueur.rang_passif(id)
	var rang := _texte("Rang %d / %d" % [rang_actuel, Passifs.rang_max(id)] if ouvert else "À découvrir · Rang 1", 25, accent)
	rang.name = "Rang_" + id
	textes.add_child(rang)
	var description := _texte(Passifs.resume_rang(id, maxi(1, rang_actuel), ReglagesJoueur.niveau_compte_effectif()), 28, StyleAzur.IVOIRE)
	description.name = "Description_" + id
	description.size_flags_vertical = Control.SIZE_EXPAND_FILL
	description.max_lines_visible = 2
	description.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	textes.add_child(description)
	var etat := _texte("Équipé" if equipe else str(donnees["categorie"]), 25, StyleAzur.VERT_VIF if equipe else accent)
	etat.name = "Etat_" + id
	textes.add_child(etat)
	# Les enfants decoratifs laissent toute la carte au bouton et le glissement au defilement.
	_ignorer_souris(marge)
	return carte

func _ignorer_souris(noeud: Control) -> void:
	noeud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for enfant in noeud.get_children():
		if enfant is Control: _ignorer_souris(enfant)

func _ouvrir_fiche(id: String) -> void:
	var donnees: Dictionary = _catalogue()[id]
	if is_instance_valid(_fiche_popup): _fiche_popup.queue_free()
	var fiche := FenetreFiche.new()
	fiche.presentation_soignee = true
	fiche.accent = FOND_PASSIF.accent_pour(id)
	fiche.set_meta("surface_lecture", false)
	fiche.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var parent_fiche: Node = get_parent().get_parent() if integre_menu else self
	parent_fiche.add_child(fiche)
	_fiche_popup = fiche
	fiche.configurer(str(donnees["nom"]), "grimoire")
	fiche.definir_embleme(_icone_passif(id))
	var contenu := fiche.contenu
	var categorie := str(donnees["categorie"])
	contenu.add_child(_texte(categorie + " · " + ("Débloqué" if ReglagesJoueur.passif_debloque(id) else "À découvrir"), 25, FOND_PASSIF.accent_categorie(categorie)))
	var lecture := VBoxContainer.new()
	lecture.add_theme_constant_override("separation", 16)
	contenu.add_child(lecture)
	lecture.add_child(_texte(str(donnees["description"]), 30, StyleAzur.IVOIRE))
	var rang := ReglagesJoueur.rang_passif(id)
	lecture.add_child(_texte("Rang %d / %d · %s" % [rang, Passifs.rang_max(id), Passifs.resume_rang(id, rang, ReglagesJoueur.niveau_compte_effectif())], 28, StyleAzur.CUIVRE))
	lecture.add_child(_texte(Passifs.progression_rang(id), 26, StyleAzur.MENTHE))
	var equipe := id in ReglagesJoueur.passifs_equipes
	if ReglagesJoueur.passif_debloque(id):
		var action_passif := StyleAzur.bouton("Retirer" if equipe else "Équiper", func():
			_choisir_passif(id)
			fiche.fermer(), true)
		StyleAzur.action_coloree(action_passif, FOND_PASSIF.accent_categorie(categorie))
		contenu.add_child(action_passif)
	else:
		lecture.add_child(_texte(Epreuves.provenance(id), 28, StyleAzur.CUIVRE))

func fermer_fiche() -> bool:
	if not is_instance_valid(_fiche_popup) or not _fiche_popup.visible: return false
	_fiche_popup.fermer()
	return true

func _exit_tree() -> void:
	if is_instance_valid(_fiche_popup): _fiche_popup.queue_free()

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
		(_categories[categorie] as Button).set_pressed_no_signal(true)
		return
	_defilement_collection.scroll_vertical = 0
	_categorie = categorie
	_message = ""
	Sons.jouer("choix", -17.0)
	_rafraichir()

func _choisir_passif(id: String) -> void:
	if not Passifs.contient(id): return
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
