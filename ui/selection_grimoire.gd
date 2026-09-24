extends Control

signal ferme
signal selection_changee

const TRANSITION := preload("res://ui/transition_grimoire.tscn")
var selection_seulement := false
var _monde := 0
var _chapitre_monde := 0
var _lancement := false
var _zones_chapitres: Array[RepereCampagne] = []
var _bouton_selectionner: Button
var _titre: Label
var _indice_monde: Label
var _sous_titre: Label
var _progression: Label
var _selection_titre: Label
var _details: Label
var _carte: CarteCampagne
var _panneau_selection: PanelContainer
var _precedent: Button
var _suivant: Button
var _apercu: Control

func _ready() -> void:
	_monde = clampi(ReglagesJoueur.chapitre_choisi / Chapitres.CHAPITRES_PAR_MONDE, 0, Chapitres.MONDES.size() - 1)
	_chapitre_monde = posmod(ReglagesJoueur.chapitre_choisi, Chapitres.CHAPITRES_PAR_MONDE)
	# La campagne possede son propre fond calme pour ne pas laisser l'accueil traverser la carte.
	StyleAzur.fond_atelier(self, true, true)
	var col := StyleAzur.page(self, "Campagne")
	var contenu := StyleAzur.defilement(col)
	var navigation := HBoxContainer.new()
	navigation.add_theme_constant_override("separation", 8)
	contenu.add_child(navigation)
	_precedent = StyleAzur.bouton_rond("‹", func(): _changer_monde(-1), 76.0)
	_precedent.tooltip_text = "Monde précédent"
	navigation.add_child(_precedent)
	var textes := VBoxContainer.new()
	textes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textes.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	textes.add_theme_constant_override("separation", 4)
	navigation.add_child(textes)
	_indice_monde = StyleAzur.texte("", 20, StyleAzur.CUIVRE)
	_titre = StyleAzur.texte("", 44)
	_sous_titre = StyleAzur.texte("", 23, StyleAzur.ATTENUE)
	_progression = StyleAzur.texte("", 20, StyleAzur.MAGIE)
	for etiquette in [_indice_monde, _titre, _sous_titre, _progression]:
		etiquette.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		textes.add_child(etiquette)
	_suivant = StyleAzur.bouton_rond("›", func(): _changer_monde(1), 76.0)
	_suivant.tooltip_text = "Monde suivant"
	navigation.add_child(_suivant)
	_carte = CarteCampagne.new()
	_carte.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_adapter_carte()
	contenu.add_child(_carte)
	resized.connect(_adapter_carte)
	for i in Chapitres.CHAPITRES_PAR_MONDE:
		var etape := RepereCampagne.new()
		_carte.ajouter_etape(etape)
		etape.activee.connect(_choisir_chapitre)
		_zones_chapitres.append(etape)
	_panneau_selection = PanelContainer.new()
	_panneau_selection.add_theme_stylebox_override("panel", _style_selection(StyleAzur.VIOLET))
	contenu.add_child(_panneau_selection)
	var selection := VBoxContainer.new()
	selection.add_theme_constant_override("separation", 10)
	_panneau_selection.add_child(selection)
	var presentation := HBoxContainer.new()
	presentation.add_theme_constant_override("separation", 14)
	selection.add_child(presentation)
	presentation.add_child(StyleAzur.illustration("fiole", 64))
	var textes_selection := VBoxContainer.new()
	textes_selection.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	presentation.add_child(textes_selection)
	_selection_titre = StyleAzur.texte("", 21, StyleAzur.CUIVRE)
	textes_selection.add_child(_selection_titre)
	_details = StyleAzur.texte("", 23, StyleAzur.ATTENUE)
	textes_selection.add_child(_details)
	var actions := BoxContainer.new()
	StyleAzur.adapter_ligne(actions, 390.0)
	actions.add_theme_constant_override("separation", 10)
	selection.add_child(actions)
	_bouton_selectionner = StyleAzur.bouton("Choisir ce niveau" if selection_seulement else "Jouer ce niveau", _selectionner, true)
	actions.add_child(_bouton_selectionner)
	var butin := StyleAzur.bouton("", func(): _voir_loots(_index_selectionne()))
	butin.icon = preload("res://assets/visual/interface/coffre_ferme.png")
	butin.custom_minimum_size = Vector2(128, 88)
	butin.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	butin.add_theme_constant_override("icon_max_width", 48)
	butin.accessibility_name = "Voir le butin"
	butin.tooltip_text = "Butin du niveau"
	actions.add_child(butin)
	_rafraichir()
	Capture.programmer(self)

func _adapter_carte() -> void:
	if not is_instance_valid(_carte):
		return
	_carte.custom_minimum_size.y = clampf(size.y * 0.36, 280.0, 520.0)

func _style_selection(teinte: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("202b50").lerp(teinte, 0.18)
	style.border_color = Color(teinte.r, teinte.g, teinte.b, 0.9)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 28
	style.corner_radius_bottom_right = 18
	style.corner_radius_bottom_left = 28
	style.shadow_color = Color("111a37a8")
	style.shadow_size = 5
	style.set_content_margin(SIDE_LEFT, 16)
	style.set_content_margin(SIDE_RIGHT, 16)
	style.set_content_margin(SIDE_TOP, 12)
	style.set_content_margin(SIDE_BOTTOM, 12)
	return style

func _rafraichir() -> void:
	var monde: Dictionary = Chapitres.MONDES[_monde]
	_indice_monde.text = "MONDE %d / %d" % [_monde + 1, Chapitres.MONDES.size()]
	_titre.text = str(monde["nom"])
	_sous_titre.text = str(monde["sous_titre"])
	var teinte: Color = monde["teinte"]
	_titre.add_theme_color_override("font_color", StyleAzur.IVOIRE.lerp(teinte, 0.38))
	_indice_monde.add_theme_color_override("font_color", teinte.lightened(0.2))
	_sous_titre.add_theme_color_override("font_color", StyleAzur.IVOIRE.lerp(teinte, 0.16))
	_details.add_theme_color_override("font_color", StyleAzur.IVOIRE.lerp(teinte, 0.18))
	_carte.afficher_monde(_monde)
	_panneau_selection.add_theme_stylebox_override("panel", _style_selection(teinte))
	_precedent.disabled = _monde == 0
	_suivant.disabled = _monde == Chapitres.MONDES.size() - 1
	var portes_franchies := 0
	for i in Chapitres.CHAPITRES_PAR_MONDE:
		var index := _monde * Chapitres.CHAPITRES_PAR_MONDE + i
		var chapitre: Dictionary = Chapitres.par_index(index)
		var accessible := ReglagesJoueur.chapitre_debloque(index)
		var termine := ReglagesJoueur.meilleure_du_chapitre(index) >= int(chapitre["salles"])
		if termine:
			portes_franchies += 1
		var statut := "Verrouillé" if not accessible else "Sélectionné" if i == _chapitre_monde else "Terminé" if termine else "Disponible"
		if i == Chapitres.CHAPITRES_PAR_MONDE - 1:
			statut = "Boss · " + statut
		_zones_chapitres[i].afficher(i + 1, i == _chapitre_monde, accessible, statut,
			i == Chapitres.CHAPITRES_PAR_MONDE - 1, termine, teinte)
	_progression.text = "%d / %d niveaux terminés" % [portes_franchies, Chapitres.CHAPITRES_PAR_MONDE]
	var index := _index_selectionne()
	var chapitre: Dictionary = Chapitres.par_index(index)
	var accessible := ReglagesJoueur.chapitre_debloque(index)
	_selection_titre.text = "NIVEAU %02d · %s" % [_chapitre_monde + 1,
		"BOSS DU MONDE" if _chapitre_monde == Chapitres.CHAPITRES_PAR_MONDE - 1 else str(monde["nom"]).to_upper()]
	_details.text = "Meilleur étage : %d / %d" % [
		ReglagesJoueur.meilleure_du_chapitre(index), int(chapitre["salles"])]
	if not accessible:
		_details.text += "\nTerminez le niveau précédent pour ouvrir ce niveau."
	if accessible:
		_bouton_selectionner.text = "Choisir ce niveau" if selection_seulement else "Jouer ce niveau"
	else:
		_bouton_selectionner.text = "Niveau verrouillé"
	_bouton_selectionner.disabled = not accessible

func _index_selectionne() -> int:
	return _monde * Chapitres.CHAPITRES_PAR_MONDE + _chapitre_monde

func _changer_monde(direction: int) -> void:
	var nouveau := clampi(_monde + direction, 0, Chapitres.MONDES.size() - 1)
	if nouveau == _monde:
		return
	_monde = nouveau
	Sons.jouer("choix", -16.0, 1.0 + float(direction) * 0.04)
	_rafraichir()

func _choisir_chapitre(numero: int) -> void:
	if _lancement:
		return
	_chapitre_monde = clampi(numero - 1, 0, Chapitres.CHAPITRES_PAR_MONDE - 1)
	Sons.jouer("choix", -16.0)
	_rafraichir()

func _selectionner() -> void:
	if _lancement:
		return
	var index := _index_selectionne()
	if not ReglagesJoueur.chapitre_debloque(index):
		return
	ReglagesJoueur.choisir_mode_run("grimoire")
	ReglagesJoueur.choisir_chapitre(index)
	Sons.jouer("choix", -10.0)
	if selection_seulement:
		selection_changee.emit()
		_fermer()
	else:
		_lancer_chapitre(index)

func _lancer_chapitre(index: int) -> void:
	if _lancement:
		return
	_lancement = true
	Sons.demarrer_musique_combat()
	var transition := TRANSITION.instantiate()
	transition.configurer(Chapitres.par_index(index))
	add_child(transition)
	transition.terminee.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/run.tscn"))

func _fermer() -> void:
	if _lancement:
		return
	Sons.jouer("choix", -14.0)
	StyleInterface.sortir_puis(self, func() -> void: ferme.emit())

func _voir_loots(index: int) -> void:
	if is_instance_valid(_apercu):
		return
	_apercu = preload("res://ui/apercu_butin.gd").new()
	_apercu.mode = "grimoire"
	_apercu.chapitre = index
	add_child(_apercu)
	_apercu.ferme.connect(func():
		_apercu.queue_free()
		_apercu = null)
