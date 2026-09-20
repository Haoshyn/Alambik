extends Control
signal campagne
signal mine
signal epreuve
signal reglages
signal jouer
signal page_demandee(index: int)

var _surface: Control
var _gouttes: Label
var _pierres: Label
var _chapitre: Label
var _sous_titre: Label
var _niveau: Label
var _experience: ProgressBar
var _haut: Control
var _bas: Control
var _raccourcis: Control
var _mine: Button
var _epreuve: Button

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	StyleAzur.fond_atelier(self)
	var illustration := TextureRect.new()
	illustration.texture = preload("res://assets/visual/arcane/accueil.png")
	illustration.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(illustration)
	illustration.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_surface = Control.new()
	_surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_surface)
	_haut = Control.new()
	_haut.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_surface.add_child(_haut)
	var profil := PanelContainer.new()
	HabillagePeint.appliquer(profil)
	profil.position = Vector2(28, 16)
	profil.size = Vector2(828, 114)
	var contour_profil := StyleAzur.cadre().duplicate() as StyleBoxTexture
	contour_profil.content_margin_top = 17
	contour_profil.content_margin_bottom = 17
	profil.add_theme_stylebox_override("panel", contour_profil)
	_haut.add_child(profil)
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 18)
	profil.add_child(ligne)
	ligne.add_child(StyleAzur.illustration("couronne", 80))
	var identite := VBoxContainer.new()
	identite.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identite.add_theme_constant_override("separation", 4)
	ligne.add_child(identite)
	_niveau = StyleAzur.texte("", 29)
	identite.add_child(_niveau)
	_experience = ProgressBar.new()
	HabillagePeint.appliquer(_experience)
	_experience.custom_minimum_size.y = 14
	_experience.show_percentage = false
	_experience.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_experience.add_theme_stylebox_override("background", StyleAzur.jauge(false))
	_experience.add_theme_stylebox_override("fill", StyleAzur.jauge(true, StyleAzur.MAGIE))
	identite.add_child(_experience)
	var parametres := StyleAzur.bouton("", func(): reglages.emit())
	parametres.position = Vector2(882, 16)
	parametres.size = Vector2(112, 114)
	parametres.tooltip_text = "Paramètres"
	_haut.add_child(parametres)
	var rouage := StyleAzur.illustration("parametres", 0)
	parametres.add_child(rouage)
	rouage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rouage.offset_left = 12
	rouage.offset_right = -12
	rouage.offset_top = 12
	rouage.offset_bottom = -12
	_gouttes = _ressource(Vector2(28, 148), "gouttes", StyleAzur.MAGIE)
	_pierres = _ressource(Vector2(524, 148), "pierres", StyleAzur.CUIVRE)
	var titre := StyleAzur.texte("ALAMBIK", 70, StyleAzur.IVOIRE)
	titre.position = Vector2(120, 250)
	titre.size = Vector2(784, 90)
	titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titre.add_theme_constant_override("outline_size", 8)
	titre.add_theme_color_override("font_outline_color", Color("192d5b"))
	_haut.add_child(titre)
	_bas = Control.new()
	_bas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_surface.add_child(_bas)
	_raccourcis = Control.new()
	_raccourcis.position.y = 188
	_raccourcis.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bas.add_child(_raccourcis)
	_mine = _raccourci("forge", "La Mine", func(): mine.emit(), Vector2(48, 0))
	_epreuve = _raccourci("astrolabe", "Épreuves", func(): epreuve.emit(), Vector2(528, 0))
	var destination := StyleAzur.bouton("", func(): campagne.emit())
	destination.position = Vector2(48, 0)
	destination.size = Vector2(928, 168)
	_bas.add_child(destination)
	var marge := MarginContainer.new()
	marge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	marge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for cote in ["left", "right", "top", "bottom"]:
		marge.add_theme_constant_override("margin_" + cote, 24)
	destination.add_child(marge)
	var itineraire := HBoxContainer.new()
	itineraire.mouse_filter = Control.MOUSE_FILTER_IGNORE
	itineraire.add_theme_constant_override("separation", 18)
	marge.add_child(itineraire)
	itineraire.add_child(StyleAzur.illustration("grimoire", 108))
	var textes := VBoxContainer.new()
	textes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	itineraire.add_child(textes)
	textes.add_child(StyleAzur.texte("VOTRE PROCHAINE AVENTURE", 21, StyleAzur.MAGIE))
	_chapitre = StyleAzur.texte("", 32)
	textes.add_child(_chapitre)
	_sous_titre = StyleAzur.texte("", 24, StyleAzur.ATTENUE)
	textes.add_child(_sous_titre)
	itineraire.add_child(StyleAzur.texte("›", 52, StyleAzur.CUIVRE))
	var jouer_bouton := StyleAzur.bouton("JOUER", func(): jouer.emit(), true)
	StyleAzur.habiller_accueil(jouer_bouton, true)
	jouer_bouton.position = Vector2(158, 330)
	jouer_bouton.size = Vector2(708, 138)
	_illustrer_bouton(jouer_bouton, "portail", 86, 48)
	_bas.add_child(jouer_bouton)
	resized.connect(_cadrer)
	_cadrer()
	rafraichir()

func _ressource(position_: Vector2, icone: String, accent: Color) -> Label:
	var cartouche := PanelContainer.new()
	HabillagePeint.appliquer(cartouche)
	cartouche.position = position_
	cartouche.size = Vector2(470, 86)
	var contour := StyleAzur.cadre(StyleAzur.PANNEAU, accent).duplicate() as StyleBoxTexture
	contour.content_margin_top = 12
	contour.content_margin_bottom = 12
	cartouche.add_theme_stylebox_override("panel", contour)
	_haut.add_child(cartouche)
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 14)
	cartouche.add_child(ligne)
	ligne.add_child(StyleAzur.illustration(icone, 62))
	var valeur := StyleAzur.texte("", 30, StyleAzur.IVOIRE)
	valeur.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	valeur.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ligne.add_child(valeur)
	return valeur

func _raccourci(embleme: String, titre: String, action: Callable, position_: Vector2) -> Button:
	var bouton := StyleAzur.bouton(titre, action)
	bouton.position = position_
	bouton.size = Vector2(448, 120)
	_illustrer_bouton(bouton, embleme, 82, 26)
	for etat in ["normal", "hover", "pressed", "disabled"]:
		var contour := bouton.get_theme_stylebox(etat).duplicate() as StyleBoxTexture
		contour.content_margin_left = 126
		bouton.add_theme_stylebox_override(etat, contour)
	bouton.add_theme_font_size_override("font_size", 25)
	_raccourcis.add_child(bouton)
	return bouton

func _illustrer_bouton(bouton: Button, embleme: String, cote: float, retrait: float) -> void:
	# L'image garde son detourage sans appliquer le shader a la police du bouton.
	var icone := StyleAzur.illustration(embleme, 0)
	bouton.add_child(icone)
	icone.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
	icone.offset_left = retrait
	icone.offset_right = retrait + cote
	icone.offset_top = -cote * 0.5
	icone.offset_bottom = cote * 0.5

func _cadrer() -> void:
	if _surface == null: return
	var facteur := minf(size.x / 1024.0, size.y / 1700.0)
	if facteur <= 0.0: return
	var hauteur := (size.y - Ecran.marge_basse() - StyleAzur.HAUTEUR_NAVIGATION) / facteur
	_surface.scale = Vector2.ONE * facteur
	_surface.size = Vector2(1024, hauteur)
	_surface.position = Vector2((size.x - 1024.0 * facteur) * 0.5, 0)
	_haut.position.y = Ecran.marge_haute() / facteur
	_bas.position.y = hauteur - 506

func rafraichir() -> void:
	if _gouttes == null: return
	_gouttes.text = "%s gouttes" % ReglagesJoueur.gouttes_affichees()
	_pierres.text = "%d pierres" % ReglagesJoueur.pierres_forge
	_niveau.text = "Alchimiste · niveau %d" % ReglagesJoueur.niveau_compte_effectif()
	_experience.max_value = ReglagesJoueur.experience_compte_requise()
	_experience.value = ReglagesJoueur.experience_compte
	_mine.disabled = not ReglagesJoueur.mode_debloque("mine")
	_mine.text = "La Mine" if not _mine.disabled else "Mine · niv. %d" % Reglages.MINE_NIVEAU_DEBLOCAGE
	_epreuve.disabled = not ReglagesJoueur.mode_debloque("epreuve_sorts")
	_epreuve.text = "Épreuves" if not _epreuve.disabled else "Épreuves · niv. %d" % Reglages.EPREUVE_NIVEAU_DEBLOCAGE
	var mode := ReglagesJoueur.mode_run_choisi
	var chapitre: Dictionary = Chapitres.par_index(ReglagesJoueur.chapitre_choisi)
	_chapitre.text = "%s · Chapitre %d" % [Chapitres.MONDES[int(chapitre["monde"])]["nom"], int(chapitre["chapitre_monde"])] if mode == "grimoire" else ("La Mine" if mode == "mine" else "Épreuve · niveau %d" % ReglagesJoueur.niveau_epreuve_choisi)
	_sous_titre.text = "Choisir un chapitre ou changer de mode"
