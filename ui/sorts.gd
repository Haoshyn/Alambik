extends Control

signal ferme
signal page_demandee(index: int)
signal reglages

const BANDEAU := preload("res://ui/composants/bandeau_accueil.tscn")
const CADRE_CARTE := preload("res://assets/visual/interface/menu/sorts/cadre_carte.svg")
const CADRE_ICONE := preload("res://assets/visual/interface/menu/sorts/cadre_icone.svg")
const MEDAILLON := preload("res://assets/visual/interface/menu/sorts/medaillon_equipe.svg")
const ORNEMENT := preload("res://assets/visual/interface/menu/sorts/ornement_titre.svg")

var integre_menu := false
var _categorie := "Actifs"
var _tri := 0
var _message := ""
var _cartes: GridContainer
var _grille_equipes: GridContainer
var _ligne_categories: BoxContainer
var _entete_collection: BoxContainer
var _statut: Label
var _collection: Label
var _bandeau: BandeauAccueil
var _fiche_popup: FenetreFiche
var _slots: Array[Button] = []
var _icones_slots: Array[TextureRect] = []
var _textes_slots: Array[Label] = []
var _rangs_slots: Array[Label] = []
var _categories: Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	theme = StyleAzur.theme_interface()
	if not integre_menu:
		StyleAzur.fond_atelier(self, true)
	var marge := MarginContainer.new()
	marge.name = "ZoneSureSorts"
	marge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(marge)
	resized.connect(_cadrer.bind(marge))
	_cadrer(marge)
	var defilement := DefilementTactile.new()
	defilement.name = "DefilementSorts"
	defilement.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	defilement.follow_focus = true
	marge.add_child(defilement)
	var contenu := VBoxContainer.new()
	contenu.name = "CompositionSorts"
	contenu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contenu.add_theme_constant_override("separation", 20)
	defilement.add_child(contenu)
	if integre_menu:
		_bandeau = BANDEAU.instantiate() as BandeauAccueil
		_bandeau.profil_demande.connect(func(): page_demandee.emit(0))
		_bandeau.reglages_demandes.connect(func(): reglages.emit())
		contenu.add_child(_bandeau)
	else:
		var retour := StyleAzur.bouton("‹  Retour", func(): ferme.emit())
		retour.custom_minimum_size = Vector2(190, 72)
		retour.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		contenu.add_child(retour)
	_construire_titre(contenu)
	_construire_categories(contenu)
	_construire_equipes(contenu)
	_construire_collection(contenu)
	resized.connect(_adapter_mise_en_page)
	_adapter_mise_en_page.call_deferred()
	_rafraichir()
	Capture.programmer(self)

func _cadrer(marge: MarginContainer) -> void:
	var lateral := maxi(28, int((size.x - 1080.0) * 0.5))
	marge.add_theme_constant_override("margin_left", maxi(lateral, int(Ecran.marge_gauche())))
	marge.add_theme_constant_override("margin_right", maxi(lateral, int(Ecran.marge_droite())))
	marge.add_theme_constant_override("margin_top", int(Ecran.marge_haute()) + 12)
	marge.add_theme_constant_override("margin_bottom", int(Ecran.marge_basse() + StyleAzur.HAUTEUR_NAVIGATION + StyleAzur.MARGE_NAVIGATION_BAS + 12) if integre_menu else int(Ecran.marge_basse()) + 24)

func _adapter_mise_en_page() -> void:
	if _cartes == null:
		return
	var marge_gauche := maxf(28.0, maxf((size.x - 1080.0) * 0.5, Ecran.marge_gauche()))
	var marge_droite := maxf(28.0, maxf((size.x - 1080.0) * 0.5, Ecran.marge_droite()))
	var largeur := maxf(0.0, size.x - marge_gauche - marge_droite)
	var compact := largeur < 900.0
	_grille_equipes.columns = 4 if largeur >= 620.0 else 2 if largeur >= 360.0 else 1
	_grille_equipes.add_theme_constant_override("h_separation", 7 if compact else 14)
	for index in _slots.size():
		var bloc := _slots[index].get_parent() as VBoxContainer
		bloc.custom_minimum_size.x = 148 if compact else 204
		_slots[index].custom_minimum_size = Vector2(128, 128) if compact else Vector2(180, 180)
		_slots[index].add_theme_font_size_override("font_size", 19 if compact else 25)
		_icones_slots[index].position = Vector2(19, 19) if compact else Vector2(29, 29)
		_icones_slots[index].size = Vector2(90, 90) if compact else Vector2(122, 122)
		_textes_slots[index].add_theme_font_size_override("font_size", 19 if compact else 24)
		_rangs_slots[index].add_theme_font_size_override("font_size", 18 if compact else 22)
	_cartes.columns = 2 if largeur >= 900.0 else 1
	_ligne_categories.vertical = largeur < 620.0
	_entete_collection.vertical = largeur < 760.0
	for categorie: String in _categories:
		var bouton: Button = _categories[categorie]
		bouton.add_theme_font_size_override("font_size", 24 if compact else 32)
		bouton.add_theme_constant_override("icon_max_width", 40 if compact else 55)

func _construire_titre(parent: VBoxContainer) -> void:
	var bloc := VBoxContainer.new()
	bloc.name = "TitreSorts"
	bloc.add_theme_constant_override("separation", 0)
	parent.add_child(bloc)
	var titre := StyleAzur.texte("SORTS", 82, Color("e6e8ff"))
	titre.name = "Titre"
	titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titre.add_theme_font_override("font", Polices.LOGO)
	titre.add_theme_color_override("font_shadow_color", Color("363167"))
	titre.add_theme_constant_override("shadow_offset_y", 5)
	bloc.add_child(titre)
	var sous_titre := StyleAzur.texte("LA MAGIE RÉVÈLE CE QUI SOMMEILLE", 25, Color("c5d4f2"))
	sous_titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bloc.add_child(sous_titre)
	var ornement := TextureRect.new()
	ornement.name = "OrnementTitre"
	ornement.texture = ORNEMENT
	ornement.custom_minimum_size = Vector2(0, 42)
	ornement.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ornement.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ornement.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ornement.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bloc.add_child(ornement)

func _construire_categories(parent: VBoxContainer) -> void:
	var ligne := BoxContainer.new()
	ligne.name = "CategoriesSorts"
	ligne.add_theme_constant_override("separation", 12)
	parent.add_child(ligne)
	_ligne_categories = ligne
	for categorie in ["Actifs", "Passifs", "Ultimes"]:
		var bouton := Button.new()
		bouton.name = "Categorie_" + categorie
		bouton.text = categorie.to_upper()
		bouton.icon = _icone_sort({"Actifs": "onde_alchimique", "Passifs": "moisson_vitale", "Ultimes": "grand_oeuvre"}[categorie])
		bouton.expand_icon = true
		bouton.custom_minimum_size.y = 92
		bouton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bouton.add_theme_font_override("font", Polices.TITRE)
		bouton.add_theme_font_size_override("font_size", 32)
		bouton.add_theme_constant_override("icon_max_width", 55)
		bouton.pressed.connect(_afficher.bind(categorie))
		ligne.add_child(bouton)
		_categories[categorie] = bouton

func _construire_equipes(parent: VBoxContainer) -> void:
	parent.add_child(_titre_section("SORTS ÉQUIPÉS"))
	var grille := GridContainer.new()
	grille.name = "EmplacementsEquipes"
	grille.columns = 4
	grille.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grille.add_theme_constant_override("h_separation", 14)
	grille.add_theme_constant_override("v_separation", 10)
	parent.add_child(grille)
	_grille_equipes = grille
	for index in 4:
		var bloc := VBoxContainer.new()
		bloc.name = "Emplacement_" + str(index)
		bloc.custom_minimum_size.x = 204
		bloc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bloc.add_theme_constant_override("separation", 0)
		grille.add_child(bloc)
		var medaillon := Button.new()
		medaillon.name = "Medaillon_" + str(index)
		medaillon.custom_minimum_size = Vector2(180, 180)
		medaillon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		medaillon.add_theme_font_override("font", Polices.TITRE)
		medaillon.add_theme_font_size_override("font_size", 25)
		medaillon.add_theme_color_override("font_color", Color("d5e4f6"))
		for etat in ["normal", "hover", "pressed", "disabled"]:
			var style := StyleBoxTexture.new()
			style.texture = MEDAILLON
			style.modulate_color = Color("9daac2") if etat == "disabled" else Color("eafaff") if etat == "hover" else Color.WHITE
			medaillon.add_theme_stylebox_override(etat, style)
		medaillon.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		medaillon.pressed.connect(_retirer_slot.bind(index))
		bloc.add_child(medaillon)
		var icone := TextureRect.new()
		icone.name = "GlypheEquipe_" + str(index)
		icone.position = Vector2(29, 29)
		icone.size = Vector2(122, 122)
		icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icone.mouse_filter = Control.MOUSE_FILTER_IGNORE
		medaillon.add_child(icone)
		_icones_slots.append(icone)
		var rang := StyleAzur.texte("", 22, Color("b7ddf6"))
		rang.name = "RangEquipe_" + str(index)
		rang.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bloc.add_child(rang)
		_rangs_slots.append(rang)
		var legende := StyleAzur.texte("", 24, Color("e4ecff"))
		legende.name = "NomEquipe_" + str(index)
		legende.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		legende.custom_minimum_size.y = 64
		bloc.add_child(legende)
		_textes_slots.append(legende)
		_slots.append(medaillon)

func _construire_collection(parent: VBoxContainer) -> void:
	var entete := BoxContainer.new()
	entete.name = "EnteteCollection"
	entete.add_theme_constant_override("separation", 12)
	parent.add_child(entete)
	_entete_collection = entete
	var titre := StyleAzur.texte("COLLECTION DES SORTS", 34, Color("c3d8ff"))
	titre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entete.add_child(titre)
	_collection = StyleAzur.texte("", 26, Color("e9dff0"))
	_collection.autowrap_mode = TextServer.AUTOWRAP_OFF
	entete.add_child(_collection)
	var tri := OptionButton.new()
	tri.name = "TriCollection"
	tri.custom_minimum_size = Vector2(205, 62)
	tri.add_item("Découverte")
	tri.add_item("Nom")
	tri.add_item("Rang")
	tri.item_selected.connect(func(index: int):
		_tri = index
		_rendre())
	for etat in ["normal", "hover", "pressed", "disabled"]:
		var style_tri := StyleBoxFlat.new()
		style_tri.bg_color = Color("283a5c") if etat == "hover" else Color("192741")
		style_tri.border_color = Color("9dadd4")
		style_tri.set_border_width_all(2)
		style_tri.set_corner_radius_all(18)
		style_tri.content_margin_left = 15
		style_tri.content_margin_right = 15
		tri.add_theme_stylebox_override(etat, style_tri)
	tri.add_theme_color_override("font_color", Color("e5ebff"))
	tri.add_theme_font_size_override("font_size", 24)
	entete.add_child(tri)
	_statut = StyleAzur.texte("", 25, Color("9ff5d2"))
	parent.add_child(_statut)
	_cartes = GridContainer.new()
	_cartes.name = "GrilleCollection"
	_cartes.columns = 2
	_cartes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cartes.add_theme_constant_override("h_separation", 18)
	_cartes.add_theme_constant_override("v_separation", 18)
	parent.add_child(_cartes)

func _titre_section(titre: String) -> VBoxContainer:
	var ligne := VBoxContainer.new()
	ligne.add_theme_constant_override("separation", 8)
	var label := StyleAzur.texte(titre, 32, Color("c3d8ff"))
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ligne.add_child(label)
	var filet := ColorRect.new()
	filet.color = Color("739dc6b3")
	filet.custom_minimum_size.y = 2
	ligne.add_child(filet)
	return ligne

func _icone_sort(id: String) -> Texture2D:
	return load("res://assets/visual/interface/menu/sorts/icones/" + id + ".svg") as Texture2D

func _style_carte() -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = CADRE_CARTE
	for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		style.set_texture_margin(cote, 40)
		style.set_content_margin(cote, 16)
	return style

func _style_onglet(categorie: String, choisi: bool) -> StyleBoxFlat:
	var accent := _couleur_categorie(categorie)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("17213be8").lerp(Color(accent, 0.92), 0.30 if choisi else 0.09)
	style.border_color = accent if choisi else Color("7d90b3")
	style.set_border_width_all(3 if choisi else 2)
	style.set_corner_radius_all(23)
	style.shadow_color = Color(accent, 0.38) if choisi else Color("11182b66")
	style.shadow_size = 10 if choisi else 4
	return style

func _badge(contenu: String, accent: Color) -> PanelContainer:
	var panneau := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("16213ce8").lerp(Color(accent, 0.95), 0.22)
	style.border_color = accent
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 9
	style.content_margin_right = 9
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	panneau.add_theme_stylebox_override("panel", style)
	var texte := StyleAzur.texte(contenu, 18, Color("eaf2ff"))
	texte.autowrap_mode = TextServer.AUTOWRAP_OFF
	panneau.add_child(texte)
	return panneau

func _etiquettes(id: String, donnees: Dictionary) -> PackedStringArray:
	if _categorie == "Passifs":
		var roles := {"moisson_vitale": "SOIN", "sang_froid": "CONTRÔLE", "riposte_alchimique": "DÉGÂTS", "reserve_ultime": "DÉGÂTS", "rempart_initial": "DÉGÂTS", "heritage_reactif": "DÉPART", "audace": "RISQUE", "echo_alchimique": "ÉCHO"}
		return PackedStringArray(["PASSIF", str(roles.get(id, "SOUTIEN"))])
	var effet := str(donnees.get("effet", ""))
	var roles_actifs := {"repousse": "ZONE", "givre": "GIVRE", "braise": "BRAISE", "acide": "ACIDE", "attire": "CONTRÔLE", "purifie": "PURIFIE"}
	return PackedStringArray(["ULTIME" if _categorie == "Ultimes" else "DÉGÂTS", str(roles_actifs.get(effet, "ZONE"))])

func _rendre() -> void:
	if _bandeau != null:
		_bandeau.afficher(ReglagesJoueur.niveau_compte_effectif(), ReglagesJoueur.experience_compte,
			ReglagesJoueur.experience_compte_requise(), ReglagesJoueur.gouttes_affichees(), str(ReglagesJoueur.pierres_forge))
	_collection.text = "%d / %d" % [ReglagesJoueur.nombre_capacites_debloquees(), Sorts.nombre_capacites_debloquees({}, true)]
	_statut.text = _message
	_statut.visible = not _message.is_empty()
	for cat: String in _categories:
		var bouton: Button = _categories[cat]
		var choisi := cat == _categorie
		for etat in ["normal", "hover", "pressed", "disabled"]:
			bouton.add_theme_stylebox_override(etat, _style_onglet(cat, choisi))
		bouton.add_theme_color_override("font_color", Color("eef5ff") if choisi else Color("cfdbf0"))
		bouton.add_theme_color_override("icon_normal_color", Color.WHITE if choisi else Color("c7bfce"))
	var passifs := ReglagesJoueur.passifs_equipes
	var equipes := [ReglagesJoueur.sort_actif_equipe, str(passifs[0]) if passifs.size() > 0 else "", str(passifs[1]) if passifs.size() > 1 else "", ReglagesJoueur.ultime_equipe]
	for index in 4:
		var id := str(equipes[index])
		var vide := id.is_empty()
		var verrouille := index == 2 and ReglagesJoueur.nombre_slots_passifs() < 2
		var categorie: String = ["Actifs", "Passifs", "Passifs", "Ultimes"][index]
		var legende: String = ["Actif", "Passif I", "Passif II", "Ultime"][index]
		var accent := _couleur_categorie(categorie)
		_slots[index].text = "FERMÉ" if verrouille else "VIDE" if vide else ""
		_slots[index].disabled = verrouille
		_slots[index].tooltip_text = "Débloquez Double discipline dans Maîtrises" if verrouille else "Emplacement %s vide" % legende if vide else "Retirer %s" % str(Sorts.donnees(id).get("nom", "Sort"))
		_slots[index].accessibility_name = _slots[index].tooltip_text
		_icones_slots[index].visible = not vide and not verrouille
		if not vide and not verrouille:
			_icones_slots[index].texture = _icone_sort(id)
		_rangs_slots[index].text = "MAÎTRISE REQUISE" if verrouille else "" if vide else "RANG %d" % ReglagesJoueur.rang_sort(id)
		_rangs_slots[index].add_theme_color_override("font_color", accent)
		_textes_slots[index].text = legende if vide or verrouille else str(Sorts.donnees(id).get("nom", "Sort"))
		_textes_slots[index].add_theme_color_override("font_color", accent if vide else Color("eaf1ff"))
	for enfant in _cartes.get_children():
		_cartes.remove_child(enfant)
		enfant.queue_free()
	var ids := _ids()
	for index in ids.size():
		var id := ids[index]
		var donnees: Dictionary = _catalogue()[id]
		var ouvert := ReglagesJoueur.sort_debloque(id)
		var equipe := id == ReglagesJoueur.sort_actif_equipe or id == ReglagesJoueur.ultime_equipe or id in ReglagesJoueur.passifs_equipes
		_cartes.add_child(_carte_sort(id, donnees, index, ouvert, equipe))

func _carte_sort(id: String, donnees: Dictionary, index: int, ouvert: bool, equipe: bool) -> PanelContainer:
	var accent := _couleur_categorie(_categorie)
	var carte := PanelContainer.new()
	carte.name = "Carte_" + id
	carte.custom_minimum_size = Vector2(440, 255)
	carte.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	carte.add_theme_stylebox_override("panel", _style_carte())
	var contenu := VBoxContainer.new()
	contenu.add_theme_constant_override("separation", 8)
	carte.add_child(contenu)
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 14)
	contenu.add_child(ligne)
	var cadre_icone := PanelContainer.new()
	cadre_icone.custom_minimum_size = Vector2(144, 144)
	cadre_icone.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var style_icone := StyleBoxTexture.new()
	style_icone.texture = CADRE_ICONE
	for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		style_icone.set_texture_margin(cote, 33)
		style_icone.set_content_margin(cote, 5)
	cadre_icone.add_theme_stylebox_override("panel", style_icone)
	ligne.add_child(cadre_icone)
	var icone := TextureRect.new()
	icone.name = "Glyphe_" + id
	icone.texture = _icone_sort(id)
	icone.custom_minimum_size = Vector2(134, 134)
	icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icone.modulate = Color.WHITE if ouvert else Color("9ca9b9")
	cadre_icone.add_child(icone)
	var textes := VBoxContainer.new()
	textes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textes.add_theme_constant_override("separation", 3)
	ligne.add_child(textes)
	var nom := Button.new()
	nom.name = "Details_" + id
	nom.text = str(donnees["nom"])
	nom.alignment = HORIZONTAL_ALIGNMENT_LEFT
	nom.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nom.add_theme_font_override("font", Polices.TITRE)
	nom.add_theme_font_size_override("font_size", 28)
	nom.add_theme_color_override("font_color", Color("eaf2ff"))
	nom.add_theme_color_override("font_hover_color", accent)
	for etat in ["normal", "hover", "pressed", "focus"]:
		nom.add_theme_stylebox_override(etat, StyleBoxEmpty.new())
	nom.pressed.connect(_ouvrir_fiche.bind(index))
	textes.add_child(nom)
	var rang := StyleAzur.texte("Niveau %d" % ReglagesJoueur.rang_sort(id) if ouvert else "À découvrir", 23, accent)
	textes.add_child(rang)
	var description := StyleAzur.texte(str(donnees["description"]), 20, Color("e0e5ed"))
	description.custom_minimum_size.y = 65
	description.max_lines_visible = 3
	description.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	textes.add_child(description)
	var pied := HBoxContainer.new()
	pied.add_theme_constant_override("separation", 5)
	contenu.add_child(pied)
	for etiquette in _etiquettes(id, donnees):
		pied.add_child(_badge(etiquette, accent))
	var espace := Control.new()
	espace.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pied.add_child(espace)
	var action := Button.new()
	action.name = "Action_" + id
	action.text = "Retirer" if equipe else "Équiper" if ouvert else "Voir"
	action.custom_minimum_size = Vector2(104, 48)
	action.add_theme_font_override("font", Polices.TITRE)
	action.add_theme_font_size_override("font_size", 21)
	StyleAzur.action_coloree(action, Color("50cb9a") if equipe else accent, 13)
	action.pressed.connect(_choisir_index.bind(index) if ouvert else _ouvrir_fiche.bind(index))
	pied.add_child(action)
	return carte

func _ouvrir_fiche(index: int) -> void:
	var id := _ids()[index]
	var donnees: Dictionary = _catalogue()[id]
	if is_instance_valid(_fiche_popup): _fiche_popup.queue_free()
	var fiche := FenetreFiche.new()
	var parent_fiche: Node = get_parent().get_parent() if integre_menu else self
	parent_fiche.add_child(fiche)
	_fiche_popup = fiche
	fiche.configurer(str(donnees["nom"]), id)
	fiche.definir_embleme(_icone_sort(id))
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
		var action_sort := StyleAzur.bouton("Retirer" if equipe else "Équiper", func():
			_choisir_index(index)
			fiche.fermer(), true)
		StyleAzur.action_coloree(action_sort, _couleur_categorie(_categorie))
		contenu.add_child(action_sort)
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
		"Passifs": return Color("67e7b1")
		"Ultimes": return Color("ffae83")
	return Color("dc89f5")

func _catalogue() -> Dictionary:
	match _categorie:
		"Passifs": return Sorts.PASSIFS
		"Ultimes": return Sorts.ULTIMES
	return Sorts.ACTIFS

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
			return ReglagesJoueur.rang_sort(a) > ReglagesJoueur.rang_sort(b))
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
