extends Control
signal ferme
var integre_menu := false
var _selection := ""
var _message := ""
var _details: Label
var _solde: Label
var _achat: Button
var _noeuds := {}

func _ready() -> void:
	var col := StyleAzur.page(self,"Maîtrises",integre_menu)
	_solde = StyleAzur.texte("",30,StyleAzur.MAGIE)
	col.add_child(_solde)
	var contenu := StyleAzur.defilement(col)
	var branches := HBoxContainer.new()
	branches.add_theme_constant_override("separation",18)
	contenu.add_child(branches)
	var index := 0
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
			b.custom_minimum_size.y = 205
			b.add_theme_font_size_override("font_size",25)
			b.icon = StyleAzur.glyphe(id)
			b.expand_icon = true
			b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
			b.add_theme_constant_override("icon_max_width",90)
			ligne.add_child(b)
			_noeuds[id] = b
			var lien := StyleAzur.texte("│",26,StyleAzur.CUIVRE)
			lien.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			ligne.add_child(lien)
		index += 1
	_details = StyleAzur.texte("",28,StyleAzur.ENCRE)
	StyleAzur.plaque(col,true).add_child(_details)
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
		b.modulate = Color.WHITE if ouvert else Color(0.65,0.72,0.75)
		b.text = "%s\n%d / %d" % [ArbreCompetences.NOEUDS[id]["nom"],ReglagesJoueur.rang_competence(id),ArbreCompetences.rangs(id)]
		b.add_theme_stylebox_override("normal",StyleAzur.cadre(StyleAzur.PANNEAU,StyleAzur.MAGIE if id == _selection else StyleAzur.CUIVRE))
	var n: Dictionary = ArbreCompetences.NOEUDS[_selection]
	_details.text = "%s\n%s\n%s" % [n["nom"],ArbreCompetences.description_effective(_selection),_message]
	_achat.text = "Améliorer · %d gouttes" % ReglagesJoueur.cout_competence(_selection)
	_achat.disabled = ReglagesJoueur.rang_competence(_selection) >= ArbreCompetences.rangs(_selection) or (not ReglagesJoueur.mode_dev and (not ArbreCompetences.prerequis_atteint(_selection,ReglagesJoueur.rangs_competences) or ReglagesJoueur.gouttes < ReglagesJoueur.cout_competence(_selection)))
	var requis := str(n.get("requis",""))
	if not requis.is_empty() and not ArbreCompetences.prerequis_atteint(_selection,ReglagesJoueur.rangs_competences):
		_details.text += "\nPrérequis : %s au maximum" % ArbreCompetences.NOEUDS[requis]["nom"]

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
