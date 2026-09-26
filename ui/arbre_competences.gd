extends Control
signal ferme
const VOILE_MAITRISES := preload("res://shaders/voile_maitrises.gdshader")
const FONDS_NOEUDS := [
	preload("res://assets/visual/interface/menu/noeud_offensif.svg"),
	preload("res://assets/visual/interface/menu/noeud_defensif.svg"),
	preload("res://assets/visual/interface/menu/noeud_utilitaire.svg"),
]
const FOND_RANG := preload("res://assets/visual/interface/menu/rang_maitrise.svg")
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
	var voile := ColorRect.new()
	voile.name = "VoileMaitrises"
	voile.color = Color.WHITE
	voile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var matiere := ShaderMaterial.new()
	matiere.shader = VOILE_MAITRISES
	voile.material = matiere
	add_child(voile)
	voile.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	move_child(voile, col.get_parent().get_index())
	var reset := StyleAzur.bouton("Réinitialiser les maîtrises", _reinitialiser)
	reset.name = "ReinitialiserMaitrises"
	reset.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	reset.custom_minimum_size = Vector2(440, 68)
	reset.add_theme_font_size_override("font_size", 30)
	StyleAzur.texte_bouton_colore(reset, StyleAzur.CUIVRE)
	for etat in ["normal", "hover", "pressed"]:
		var style_reset := StyleAzur.sceau(false, Color.WHITE, etat == "pressed")
		for cote in [SIDE_TOP, SIDE_BOTTOM]: style_reset.set_content_margin(cote, 10)
		reset.add_theme_stylebox_override(etat, style_reset)
	col.add_child(reset)
	var fiche := StyleAzur.plaque(col, true)
	fiche.name = "DetailsMaitriseFixes"
	_solde = StyleAzur.texte("",25,StyleAzur.IVOIRE)
	_solde.visible = not integre_menu
	col.add_child(_solde)
	var contenu := StyleAzur.defilement(col)
	var branches := CompositionArcane.new()
	branches.hauteur = 3060
	contenu.add_child(branches)
	var index_branche := 0
	for branche in ArbreCompetences.BRANCHES:
		var accent: Color = [StyleAzur.ROUGE_VIF, StyleAzur.VERT_VIF, StyleAzur.MAUVE_VIF][index_branche]
		var fond_noeud: Texture2D = FONDS_NOEUDS[index_branche]
		var dossier: String = ["offensif", "defensif", "utilitaire"][index_branche]
		var centre_x := 145.0 + index_branche * 315.0
		var decalage: float = [0.0, 95.0, 40.0][index_branche]
		var titre := StyleAzur.calligraphie(branche, 48, accent.lightened(0.15))
		titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		branches.placer(titre, Rect2(centre_x - 145, decalage + 20, 290, 54))
		var trace := PackedVector2Array()
		var rang_noeud := 0
		index_branche += 1
		for identifiant in ArbreCompetences.BRANCHES[branche]:
			var id := str(identifiant)
			if _selection.is_empty(): _selection = id
			var b := StyleAzur.bouton("",func():
				_selection = id
				_message = ""
				_rafraichir())
			b.name = "Noeud_" + id
			b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			var majeur := ArbreCompetences.rangs(id) == 1
			var diametre := 216.0 if majeur else 190.0
			b.custom_minimum_size = Vector2.ONE * diametre
			b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			b.set_meta("majeur", majeur)
			var icone := TextureRect.new()
			icone.name = "Glyphe_" + id
			icone.texture = load("res://assets/visual/interface/menu/glyphes/%s/%s.svg" % [dossier, id]) as Texture2D
			icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icone.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var cote_icone := (182.0 if majeur else 168.0) * 0.9
			icone.position = Vector2.ONE * (diametre - cote_icone) * 0.5
			icone.size = Vector2.ONE * cote_icone
			b.add_child(icone)
			b.set_meta("embleme", icone.texture)
			b.set_meta("icone", icone)
			b.set_meta("accent", accent)
			b.set_meta("fond", fond_noeud)
			var rang_fond := Panel.new()
			rang_fond.name = "CapsuleRang_" + id
			rang_fond.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var style_rang := StyleBoxTexture.new()
			style_rang.texture = FOND_RANG
			style_rang.set_texture_margin(SIDE_LEFT, 28)
			style_rang.set_texture_margin(SIDE_RIGHT, 28)
			style_rang.set_texture_margin(SIDE_TOP, 18)
			style_rang.set_texture_margin(SIDE_BOTTOM, 18)
			rang_fond.add_theme_stylebox_override("panel", style_rang)
			var rang := StyleAzur.texte("", 30, Color("ffe9bd"))
			rang.add_theme_font_override("font", Polices.CHIFFRES)
			rang.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			rang.autowrap_mode = TextServer.AUTOWRAP_OFF
			rang_fond.add_child(rang)
			rang.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			b.set_meta("rang", rang)
			b.set_meta("rang_fond", rang_fond)
			b.add_theme_stylebox_override("hover", _style_noeud(fond_noeud, true, true))
			b.add_theme_stylebox_override("pressed", _style_noeud(fond_noeud, true, true))
			b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
			var oscillation := float([0, 40, -24, 28][rang_noeud % 4])
			var centre := Vector2(centre_x + oscillation, 180 + rang_noeud * 276 + decalage)
			trace.append(centre)
			branches.placer(b, Rect2(centre - Vector2.ONE * diametre * 0.5, Vector2.ONE * diametre))
			branches.placer(rang_fond, Rect2(centre.x - 64.0, centre.y + diametre * 0.5 + 4.0, 128.0, 46.0))
			rang_noeud += 1
			_noeuds[id] = b
		branches.traces.append(trace)
	# La fiche garde sa hauteur pour ne pas deplacer les sceaux a chaque selection.
	var lecture_fixe := DefilementTactile.new()
	lecture_fixe.custom_minimum_size.y = 200
	lecture_fixe.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	fiche.add_child(lecture_fixe)
	var ligne_details := HBoxContainer.new()
	ligne_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ligne_details.add_theme_constant_override("separation",24)
	lecture_fixe.add_child(ligne_details)
	_embleme = StyleAzur.image(8,88)
	_embleme.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ligne_details.add_child(_embleme)
	var texte_details := VBoxContainer.new()
	texte_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texte_details.add_theme_constant_override("separation", 12)
	ligne_details.add_child(texte_details)
	_titre_details = StyleAzur.calligraphie("", 44, StyleAzur.CUIVRE)
	texte_details.add_child(_titre_details)
	_details = StyleAzur.texte("",34,StyleAzur.LILAS)
	_details.add_theme_font_override("font", Polices.TITRE)
	_details.add_theme_constant_override("line_spacing", 6)
	texte_details.add_child(_details)
	_message_details = StyleAzur.texte("",26,StyleAzur.MENTHE)
	_message_details.add_theme_constant_override("line_spacing", 6)
	texte_details.add_child(_message_details)
	_achat = StyleAzur.bouton("Améliorer",_ameliorer,true)
	fiche.add_child(_achat)
	for bouton: Button in _noeuds.values():
		bouton.pressed.connect(func(): lecture_fixe.scroll_vertical = 0)
	_rafraichir()
	Capture.programmer(self)

func _style_noeud(fond: Texture2D, selection := false, ouvert := true) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = fond
	style.modulate_color = Color("fff6e8") if selection and ouvert else Color.WHITE if ouvert else Color("bbc3d0")
	return style


func _rafraichir() -> void:
	_solde.text = "%s gouttes disponibles" % ReglagesJoueur.gouttes_affichees()
	for id in _noeuds:
		var b: Button = _noeuds[id]
		var ouvert := ReglagesJoueur.mode_dev or ArbreCompetences.prerequis_atteint(id,ReglagesJoueur.rangs_competences)
		var icone: TextureRect = b.get_meta("icone")
		var rang: Label = b.get_meta("rang")
		rang.text = "%d / %d" % [ReglagesJoueur.rang_competence(id),ArbreCompetences.rangs(id)]
		rang.add_theme_color_override("font_color", Color("ffe9bd") if ouvert else Color("b7b9ca"))
		var rang_fond: Panel = b.get_meta("rang_fond")
		rang_fond.modulate.a = 1.0 if ouvert else 0.68
		b.tooltip_text = str(ArbreCompetences.NOEUDS[id]["nom"]) + (" · Pouvoir majeur" if ArbreCompetences.rangs(id)==1 else "")
		icone.modulate = Color.WHITE if ouvert else Color(1.0, 1.0, 1.0, 0.88)
		var fond: Texture2D = b.get_meta("fond")
		b.add_theme_stylebox_override("normal", _style_noeud(fond, id == _selection, ouvert))
	var n: Dictionary = ArbreCompetences.NOEUDS[_selection]
	var selection: Button = _noeuds[_selection]
	_embleme.texture = selection.get_meta("embleme")
	var accent_selection: Color = selection.get_meta("accent")
	_embleme.modulate = Color.WHITE.lerp(accent_selection, 0.22)
	_titre_details.text = "%s · %d / %d" % [str(n["nom"]), ReglagesJoueur.rang_competence(_selection), ArbreCompetences.rangs(_selection)]
	_titre_details.add_theme_color_override("font_color", accent_selection.darkened(0.52))
	StyleAzur.action_coloree(_achat, accent_selection)
	_details.add_theme_color_override("font_color", accent_selection.darkened(0.62))
	_message_details.text = _message
	_message_details.visible = not _message.is_empty()
	var rang_actuel := ReglagesJoueur.rang_competence(_selection)
	_details.text = "Bonus : %s" % ArbreCompetences.valeur_au_rang(_selection, rang_actuel)
	if rang_actuel < ArbreCompetences.rangs(_selection):
		_details.text += "\nRang suivant : %s" % ArbreCompetences.valeur_au_rang(_selection, rang_actuel + 1)
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
