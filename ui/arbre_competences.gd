extends Control
signal ferme
var integre_menu := false
var _selection := ""
var _message := ""
var _details: Label
var _solde: Label
var _achat: Button
var _noeuds := {}
var _embleme: TextureRect

func _ready() -> void:
	var col := StyleAzur.page(self,"Maîtrises",integre_menu)
	_solde = StyleAzur.texte("",28,StyleAzur.IVOIRE)
	_solde.visible = not integre_menu
	col.add_child(_solde)
	var contenu := StyleAzur.defilement(col)
	var branches := HBoxContainer.new()
	branches.add_theme_constant_override("separation",18)
	contenu.add_child(branches)
	for branche in ArbreCompetences.BRANCHES:
		var ligne := VBoxContainer.new()
		ligne.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		branches.add_child(ligne)
		var titre := StyleAzur.texte(branche,29)
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
			b.custom_minimum_size = Vector2(174,174)
			b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			b.add_theme_font_size_override("font_size",25)
			var icone := StyleAzur.vignette(id, 112, true)
			icone.position = Vector2(31, 18)
			b.add_child(icone)
			b.set_meta("embleme", icone.texture)
			var rang := StyleAzur.texte("", 22)
			rang.position = Vector2(8, 128)
			rang.size = Vector2(158, 30)
			rang.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			b.add_child(rang)
			b.set_meta("rang", rang)
			b.add_theme_stylebox_override("hover", StyleAzur.cadre(Color("476ba3"), StyleAzur.MAGIE, 64))
			b.add_theme_stylebox_override("pressed", StyleAzur.cadre(Color("793e92"), StyleAzur.MAGIE, 64))
			b.add_theme_stylebox_override("focus", StyleAzur.cadre(Color.TRANSPARENT, StyleAzur.MAGIE, 64))
			ligne.add_child(b)
			_noeuds[id] = b
			var lien := StyleAzur.texte("│",26,StyleAzur.MAGIE)
			lien.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			ligne.add_child(lien)
	var fiche := StyleAzur.plaque(col,true)
	var ligne_details := HBoxContainer.new()
	ligne_details.add_theme_constant_override("separation",24)
	fiche.add_child(ligne_details)
	_embleme = StyleAzur.image(8,120)
	ligne_details.add_child(_embleme)
	_details = StyleAzur.texte("",28,StyleAzur.ENCRE)
	_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ligne_details.add_child(_details)
	_achat = StyleAzur.bouton("Améliorer",_ameliorer,true)
	col.add_child(_achat)
	col.add_child(StyleAzur.bouton("Réinitialiser les maîtrises",_reinitialiser))
	_rafraichir()
	Capture.programmer(self)

func _rafraichir() -> void:
	_solde.text = "%s gouttes disponibles" % ReglagesJoueur.gouttes_affichees()
	for id in _noeuds:
		var b: Button = _noeuds[id]
		var ouvert := ReglagesJoueur.mode_dev or ArbreCompetences.prerequis_atteint(id,ReglagesJoueur.rangs_competences)
		b.modulate = Color.WHITE if ouvert else Color("687ba9")
		var rang: Label = b.get_meta("rang")
		rang.text = "%d / %d" % [ReglagesJoueur.rang_competence(id),ArbreCompetences.rangs(id)] if ouvert else "Verrouillé"
		if ouvert and id == _selection: rang.text = "◆ " + rang.text
		elif ouvert and ReglagesJoueur.rang_competence(id) > 0: rang.text = "✓ " + rang.text
		b.tooltip_text = str(ArbreCompetences.NOEUDS[id]["nom"])
		b.add_theme_font_size_override("font_size",22)
		b.add_theme_color_override("font_color",StyleAzur.IVOIRE)
		b.add_theme_stylebox_override("normal",StyleAzur.cadre(Color("793e92") if id == _selection else Color("285c85") if ReglagesJoueur.rang_competence(id) > 0 else Color("303564") if ouvert else Color("252943"),StyleAzur.MAGIE if id == _selection else StyleAzur.CUIVRE,64))
	var n: Dictionary = ArbreCompetences.NOEUDS[_selection]
	_embleme.texture = _noeuds[_selection].get_meta("embleme")
	_details.text = "%s\n%s\n%s" % [n["nom"],ArbreCompetences.description_effective(_selection),_message]
	_achat.text = "Améliorer · %d gouttes" % ReglagesJoueur.cout_competence(_selection)
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
