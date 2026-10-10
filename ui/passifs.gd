extends Control

signal ferme
signal page_demandee(index: int)
signal reglages

const FOND_PASSIF := preload("res://ui/composants/fond_carte_passif.gd")
const HAUTEUR_EMBLEME := 150.0
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
var _equipes_titre: Label
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
	# Les petits ecrans gardent la hauteur pour la collection.
	var cote := minf(150.0 if not compact else 118.0, (largeur - 60.0 - 18.0 * (_grille_equipes.columns - 1)) / _grille_equipes.columns)
	for index in _slots.size():
		var bloc := _slots[index].get_parent() as VBoxContainer
		bloc.custom_minimum_size.x = 0
		_slots[index].custom_minimum_size = Vector2.ONE * cote
		_slots[index].add_theme_font_size_override("font_size", 64)
		_icones_slots[index].position = Vector2.ONE * cote * 0.12
		_icones_slots[index].size = Vector2.ONE * cote * 0.76
		_textes_slots[index].add_theme_font_size_override("font_size", 26 if compact else 28)
		_rangs_slots[index].add_theme_font_size_override("font_size", 25)
	_cartes.columns = 3 if largeur >= 900.0 else 2
	_ligne_categories.vertical = largeur < 620.0
	_entete_collection.vertical = largeur < 800.0
	for categorie: String in _categories:
		var bouton: Button = _categories[categorie]
		bouton.add_theme_font_size_override("font_size", 28 if compact else 30)
	_adapter_cartes.call_deferred()

func _adapter_cartes() -> void:
	if _cartes.get_child_count() == 0: return
	# La taille des entrees ne change pas lorsque le filtre reduit la collection.
	for carte: Control in _cartes.get_children():
		carte.custom_minimum_size.y = 372.0

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
	# Les quatre emplacements forment un seul ensemble serti, comme une barre d'equipement.
	var panneau := PanelContainer.new()
	panneau.name = "PanneauEquipes"
	var style_panneau := (StyleJeu.panneau(StyleAzur.MAUVE_VIF, 30.0, 0.95) as StyleBoxJeu).duplicate() as StyleBoxJeu
	style_panneau.content_margin_top = 18.0
	style_panneau.content_margin_bottom = 20.0
	panneau.add_theme_stylebox_override("panel", style_panneau)
	parent.add_child(panneau)
	var colonne := VBoxContainer.new()
	colonne.add_theme_constant_override("separation", 12)
	panneau.add_child(colonne)
	_equipes_titre = _texte("", 32, StyleAzur.IVOIRE, true)
	_equipes_titre.name = "TitreEquipes"
	_equipes_titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	colonne.add_child(_equipes_titre)
	var grille := GridContainer.new()
	grille.name = "PassifsEquipes"
	grille.columns = 4
	grille.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grille.add_theme_constant_override("h_separation", 18)
	grille.add_theme_constant_override("v_separation", 16)
	colonne.add_child(grille)
	_grille_equipes = grille
	for index in Passifs.EMPLACEMENTS:
		var accent := FOND_PASSIF.accent_categorie("Tous")
		var bloc := VBoxContainer.new()
		bloc.name = "Emplacement_" + str(index)
		bloc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bloc.add_theme_constant_override("separation", 8)
		grille.add_child(bloc)
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
		legende.custom_minimum_size.y = 40
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
	_cartes.add_theme_constant_override("h_separation", 18)
	_cartes.add_theme_constant_override("v_separation", 22)
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
	_statut.visible = not _message.is_empty() or _defilement_collection.size.x >= 900.0
	for cat: String in _categories:
		var bouton: Button = _categories[cat]
		var choisi := cat == _categorie
		bouton.set_pressed_no_signal(choisi)
		for etat in ["normal", "hover", "pressed", "disabled"]:
			bouton.add_theme_stylebox_override(etat, _style_onglet(cat, choisi or etat in ["hover", "pressed"]))
		bouton.add_theme_stylebox_override("focus", _style_onglet(cat, true))
		StyleAzur.texte_bouton_colore(bouton, FOND_PASSIF.accent_categorie(cat) if choisi else StyleAzur.IVOIRE)
	var equipes := ReglagesJoueur.passifs_equipes
	_equipes_titre.text = "Passifs équipés · %d / %d" % [equipes.size(), Passifs.EMPLACEMENTS]
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
	carte.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Une tuile sertie par passif : le texte ne repose jamais sur la clairiere.
	var style := (StyleJeu.panneau(accent if ouvert else Color("6d7190"), 28.0, 0.95) as StyleBoxJeu).duplicate() as StyleBoxJeu
	for cote in [SIDE_LEFT, SIDE_RIGHT]: style.set_content_margin(cote, 16)
	style.content_margin_top = 18.0
	style.content_margin_bottom = 22.0
	if equipe:
		style.monture_haut = StyleAzur.VERT_VIF.lightened(0.4)
		style.monture_bas = StyleAzur.VERT_VIF.darkened(0.3)
		style.lueur = Color(StyleAzur.VERT_VIF, 0.6)
		style.lueur_taille = 12.0
	carte.add_theme_stylebox_override("panel", style)
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
	fond.verrouille = not ouvert
	fond.centre_embleme = Vector2(0.5, HAUTEUR_EMBLEME * 0.5)
	fond.rayon_embleme = HAUTEUR_EMBLEME * 0.5 - 12.0
	carte.add_child(fond)
	ouvrir.mouse_entered.connect(fond.illuminer.bind(true))
	ouvrir.mouse_exited.connect(fond.illuminer.bind(false))
	ouvrir.focus_entered.connect(fond.illuminer.bind(true))
	ouvrir.focus_exited.connect(fond.illuminer.bind(false))
	ouvrir.button_down.connect(fond.illuminer.bind(true))
	ouvrir.button_up.connect(fond.illuminer.bind(false))
	var textes := VBoxContainer.new()
	textes.add_theme_constant_override("separation", 6)
	carte.add_child(textes)
	var emplacement_icone := CenterContainer.new()
	emplacement_icone.custom_minimum_size.y = HAUTEUR_EMBLEME
	textes.add_child(emplacement_icone)
	var icone := TextureRect.new()
	icone.name = "Glyphe_" + id
	icone.texture = _icone_passif(id)
	icone.custom_minimum_size = Vector2.ONE * (HAUTEUR_EMBLEME - 46.0)
	icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	# Verrouille : silhouette eteinte, la couleur revient a la decouverte.
	icone.modulate = Color.WHITE if ouvert else Color(0.5, 0.52, 0.66, 0.9)
	icone.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	emplacement_icone.add_child(icone)
	var nom := _texte(str(donnees["nom"]), 32, StyleAzur.IVOIRE if ouvert else StyleJeu.TEXTE_DOUX, true)
	nom.name = "Nom_" + id
	nom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nom.autowrap_mode = TextServer.AUTOWRAP_OFF
	nom.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	nom.clip_text = true
	textes.add_child(nom)
	var rang_actuel := ReglagesJoueur.rang_passif(id)
	var rang := _texte("Rang %d / %d" % [rang_actuel, Passifs.rang_max(id)] if ouvert else "À découvrir", 25, StyleJeu.OR if ouvert else Color("aeb2c8"))
	rang.name = "Rang_" + id
	rang.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	textes.add_child(rang)
	var description := _texte(Passifs.resume_rang(id, maxi(1, rang_actuel), ReglagesJoueur.niveau_compte_effectif()), 27, StyleAzur.IVOIRE)
	description.name = "Description_" + id
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.size_flags_vertical = Control.SIZE_EXPAND_FILL
	description.custom_minimum_size.y = 72
	description.max_lines_visible = 2
	description.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	textes.add_child(description)
	var etat := _texte("Équipé" if equipe else str(donnees["categorie"]), 24, StyleAzur.VERT_VIF if equipe else accent)
	etat.name = "Etat_" + id
	etat.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	textes.add_child(etat)
	# Les enfants decoratifs laissent toute la carte au bouton et le glissement au defilement.
	_ignorer_souris(textes)
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
