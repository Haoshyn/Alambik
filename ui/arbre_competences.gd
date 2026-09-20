extends Control
signal ferme
var integre_menu := false
var maitrise_initiale := ""
var _selection := ""
var _message := ""
var _titre_details: Label
var _details: Label
var _message_details: Label
var _solde: Label
var _achat: Button
var _noeuds := {}
var _embleme: TextureRect

func _ready() -> void:
	if ArbreCompetences.NOEUDS.has(maitrise_initiale):
		_selection = maitrise_initiale
	if ReglagesJoueur.remboursement_maitrises > 0:
		_message = "Arbre réorganisé : %d gouttes remboursées." % ReglagesJoueur.remboursement_maitrises
	var col := StyleAzur.page(self,"Maîtrises",integre_menu)
	StyleAzur.banniere(col, "La constellation des savoirs", "Les bonus d’attaque renforcent l’attaque de base de votre équipement.", "astrolabe")
	_solde = StyleAzur.texte("",28,StyleAzur.IVOIRE)
	_solde.visible = not integre_menu
	col.add_child(_solde)
	var contenu := StyleAzur.defilement(col)
	var branches := HBoxContainer.new()
	branches.add_theme_constant_override("separation",18)
	contenu.add_child(branches)
	var index_branche := 0
	for branche in ArbreCompetences.BRANCHES:
		var accent: Color = [StyleAzur.CORAIL, StyleAzur.MENTHE, StyleAzur.CUIVRE][index_branche]
		index_branche += 1
		var socle := PanelContainer.new()
		HabillagePeint.appliquer(socle)
		socle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		socle.add_theme_stylebox_override("panel", StyleAzur.cadre(StyleAzur.PANNEAU, accent))
		branches.add_child(socle)
		var ligne := VBoxContainer.new()
		ligne.add_theme_constant_override("separation", 10)
		socle.add_child(ligne)
		ligne.add_child(StyleAzur.illustration(["couronne", "fiole", "astrolabe"][index_branche - 1], 76))
		var titre := StyleAzur.texte(branche,30,StyleAzur.IVOIRE)
		titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ligne.add_child(titre)
		for identifiant in ArbreCompetences.BRANCHES[branche]:
			var id := str(identifiant)
			if _selection.is_empty(): _selection = id
			var b := StyleAzur.bouton("",func():
				_selection = id
				_message = ""
				_rafraichir())
			b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			b.custom_minimum_size = Vector2(192,178)
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var marge := MarginContainer.new()
			marge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			marge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			for cote in ["left", "right", "top", "bottom"]:
				marge.add_theme_constant_override("margin_" + cote, 16)
			b.add_child(marge)
			var contenu_noeud := VBoxContainer.new()
			contenu_noeud.mouse_filter = Control.MOUSE_FILTER_IGNORE
			contenu_noeud.alignment = BoxContainer.ALIGNMENT_CENTER
			contenu_noeud.add_theme_constant_override("separation", 8)
			marge.add_child(contenu_noeud)
			var icone := StyleAzur.vignette(id, 90, true)
			icone.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			contenu_noeud.add_child(icone)
			b.set_meta("embleme", icone.texture)
			b.set_meta("icone", icone)
			b.set_meta("accent", accent)
			var rang := StyleAzur.texte("", 28, StyleAzur.IVOIRE)
			rang.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			contenu_noeud.add_child(rang)
			b.set_meta("rang", rang)
			b.add_theme_stylebox_override("hover", _style_noeud(accent, true))
			b.add_theme_stylebox_override("pressed", _style_noeud(StyleAzur.MAGIE, true))
			var focus := _style_noeud(StyleAzur.IVOIRE, true)
			focus.draw_center = false
			b.add_theme_stylebox_override("focus", focus)
			if ArbreCompetences.rangs(id) == 1:
				var majeur := StyleAzur.texte("Pouvoir majeur", 24, StyleAzur.IVOIRE)
				majeur.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				ligne.add_child(majeur)
			ligne.add_child(b)
			_noeuds[id] = b
	var fiche := StyleAzur.plaque(col,true)
	var ligne_details := HBoxContainer.new()
	ligne_details.add_theme_constant_override("separation",24)
	fiche.add_child(ligne_details)
	_embleme = StyleAzur.image(8,120)
	_embleme.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ligne_details.add_child(_embleme)
	var texte_details := VBoxContainer.new()
	texte_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texte_details.add_theme_constant_override("separation", 12)
	ligne_details.add_child(texte_details)
	_titre_details = StyleAzur.texte("",34,StyleAzur.IVOIRE)
	texte_details.add_child(_titre_details)
	_details = StyleAzur.texte("",28,StyleAzur.IVOIRE)
	_details.add_theme_constant_override("line_spacing", 6)
	texte_details.add_child(_details)
	_message_details = StyleAzur.texte("",28,StyleAzur.IVOIRE)
	_message_details.add_theme_constant_override("line_spacing", 6)
	fiche.add_child(_message_details)
	_achat = StyleAzur.bouton("Améliorer",_ameliorer,true)
	col.add_child(_achat)
	contenu.add_child(StyleAzur.bouton("Réinitialiser les maîtrises",_reinitialiser))
	_rafraichir()
	Capture.programmer(self)

func _style_noeud(accent: Color, selection := false, ouvert := true) -> StyleBoxFlat:
	# Les petites cellules gardent la place pour l'icone et le rang plutot que l'ornement.
	var style := StyleBoxFlat.new()
	style.bg_color = StyleAzur.FOND.lerp(accent, 0.18 if selection else 0.04) if ouvert else StyleAzur.FOND.darkened(0.12)
	style.border_color = accent if ouvert else StyleAzur.ATTENUE.darkened(0.4)
	style.set_border_width_all(4 if selection else 2)
	style.set_corner_radius_all(20)
	for cote in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		style.set_content_margin(cote, 16)
	return style

func _rafraichir() -> void:
	_solde.text = "%s gouttes disponibles" % ReglagesJoueur.gouttes_affichees()
	for id in _noeuds:
		var b: Button = _noeuds[id]
		var ouvert := ReglagesJoueur.mode_dev or ArbreCompetences.prerequis_atteint(id,ReglagesJoueur.rangs_competences)
		var icone: TextureRect = b.get_meta("icone")
		icone.modulate = Color.WHITE if ouvert else Color("8691a8")
		var rang: Label = b.get_meta("rang")
		rang.text = "%d / %d" % [ReglagesJoueur.rang_competence(id),ArbreCompetences.rangs(id)] if ouvert else "Verrouillé"
		if ouvert and id == _selection: rang.text = "◆ " + rang.text
		elif ouvert and ReglagesJoueur.rang_competence(id) > 0: rang.text = "✓ " + rang.text
		b.tooltip_text = str(ArbreCompetences.NOEUDS[id]["nom"]) + (" · Pouvoir majeur" if ArbreCompetences.rangs(id)==1 else "")
		var accent: Color = b.get_meta("accent")
		b.add_theme_stylebox_override("normal",_style_noeud(accent, id == _selection, ouvert))
	var n: Dictionary = ArbreCompetences.NOEUDS[_selection]
	var selection: Button = _noeuds[_selection]
	_embleme.texture = selection.get_meta("embleme")
	_titre_details.text = str(n["nom"])
	_details.text = ArbreCompetences.description_effective(_selection)
	_message_details.text = _message
	_message_details.visible = not _message.is_empty()
	var rang_actuel := ReglagesJoueur.rang_competence(_selection)
	_details.text += "\nBonus du nœud : %s" % ArbreCompetences.valeur_au_rang(_selection, rang_actuel)
	if rang_actuel < ArbreCompetences.rangs(_selection):
		_details.text += " → %s" % ArbreCompetences.valeur_au_rang(_selection, rang_actuel + 1)
	_achat.text = "%s · %d gouttes" % ["Débloquer" if ArbreCompetences.rangs(_selection)==1 else "Améliorer",ReglagesJoueur.cout_competence(_selection)]
	_achat.disabled = ReglagesJoueur.rang_competence(_selection) >= ArbreCompetences.rangs(_selection) or (not ReglagesJoueur.mode_dev and (not ArbreCompetences.prerequis_atteint(_selection,ReglagesJoueur.rangs_competences) or ReglagesJoueur.gouttes < ReglagesJoueur.cout_competence(_selection)))
	var requis := str(n.get("requis",""))
	if not requis.is_empty() and not ArbreCompetences.prerequis_atteint(_selection,ReglagesJoueur.rangs_competences):
		_details.text += "\nPrérequis : %s au rang 1" % ArbreCompetences.NOEUDS[requis]["nom"]

func _ameliorer() -> void:
	if _selection.is_empty():
		return
	var id := _selection
	var noeud: Dictionary = ArbreCompetences.NOEUDS[id]
	var rang := ReglagesJoueur.rang_competence(id)
	if rang >= ArbreCompetences.rangs(id):
		_message = "%s est au rang maximum." % noeud["nom"]
	elif not ReglagesJoueur.mode_dev and not ArbreCompetences.prerequis_atteint(id, ReglagesJoueur.rangs_competences):
		var requis: Dictionary = ArbreCompetences.NOEUDS[noeud["requis"]]
		_message = "Terminez d’abord %s." % requis["nom"]
	elif not ReglagesJoueur.mode_dev and ReglagesJoueur.gouttes < ReglagesJoueur.cout_competence(id):
		_message = "Il manque %d Gouttes." % (ReglagesJoueur.cout_competence(id) - ReglagesJoueur.gouttes)
	elif ReglagesJoueur.acheter_competence(id):
		_message = "%s rang %d/%d : bonus permanent actif." % [noeud["nom"],
			ReglagesJoueur.rang_competence(id), ArbreCompetences.rangs(id)]
		Sons.jouer("fusion", -12.0)
	_rafraichir()

func _reinitialiser() -> void:
	var rembourses := ReglagesJoueur.reinitialiser_arbre()
	_message = "Réinitialisation : %d Gouttes remboursées." % rembourses
	Sons.jouer("choix", -12.0)
	_rafraichir()
