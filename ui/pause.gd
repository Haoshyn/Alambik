extends Control
signal termine
const REGLAGES := preload("res://ui/reglages.tscn")
var _inventaire: Control
var _reglages: Control

func _ready() -> void:
	var col := StyleAzur.page(self, "Pause")
	var contenu := StyleAzur.defilement(col)
	StyleAzur.banniere(contenu, "Une halte dans l’aventure", Jeu.nom_run(), "portail")
	var carnet := StyleAzur.plaque(contenu)
	var titre := StyleAzur.texte("VOTRE EXPÉDITION", 23, StyleAzur.CUIVRE)
	titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	carnet.add_child(titre)
	var chiffres := HBoxContainer.new()
	chiffres.add_theme_constant_override("separation", 16)
	carnet.add_child(chiffres)
	_statistique(chiffres, "%d / %d" % [Jeu.salle_courante, Jeu.salles_du_chapitre()], "Salle")
	_statistique(chiffres, str(Jeu.niveau_run), "Niveau")
	_statistique(chiffres, str(Jeu.inventaire.size()), "Augmentations")
	StyleAzur.separateur(contenu)
	contenu.add_child(_action("Mes améliorations", "navigation_sorts", _ouvrir_ameliorations))
	contenu.add_child(_action("Paramètres", "parametres", _ouvrir_reglages))
	var quitter := StyleAzur.bouton("Quitter l’aventure", _quitter_run)
	quitter.add_theme_color_override("font_color", StyleAzur.CORAIL)
	contenu.add_child(quitter)
	col.add_child(StyleAzur.bouton("Reprendre l’aventure", _reprendre, true))
	Capture.programmer(self)
	StyleInterface.animer_entree(self)

func _statistique(parent: HBoxContainer, valeur: String, legende: String) -> void:
	var bloc := VBoxContainer.new()
	bloc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(bloc)
	var nombre := StyleAzur.texte(valeur, 39, StyleAzur.IVOIRE)
	nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bloc.add_child(nombre)
	var texte := StyleAzur.texte(legende, 24, StyleAzur.ATTENUE)
	texte.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bloc.add_child(texte)

func _action(titre: String, glyphe: String, action: Callable) -> Button:
	var bouton := StyleAzur.bouton(titre, action)
	bouton.icon = StyleAzur.glyphe(glyphe)
	bouton.expand_icon = true
	bouton.add_theme_constant_override("icon_max_width", 66)
	bouton.add_theme_constant_override("h_separation", 24)
	return bouton

func _reprendre() -> void:
	Sons.jouer("choix", -12.0)
	StyleInterface.sortir_puis(self, func() -> void: termine.emit())

func _ouvrir_reglages() -> void:
	Sons.jouer("choix", -12.0)
	if _reglages != null: return
	var panneau := REGLAGES.instantiate()
	_reglages = panneau
	panneau.process_mode = Node.PROCESS_MODE_ALWAYS
	panneau.reprise_demandee.connect(_reprendre)
	add_child(panneau)
	panneau.ferme.connect(func() -> void:
		panneau.queue_free()
		_reglages = null)

func _ouvrir_ameliorations() -> void:
	if _inventaire != null:
		return
	Sons.jouer("choix", -12.0)
	_inventaire = _VueAmeliorations.new()
	_inventaire.reprise_demandee.connect(_reprendre)
	_inventaire.ferme.connect(func() -> void:
		_inventaire.queue_free()
		_inventaire = null)
	add_child(_inventaire)
	StyleInterface.animer_entree(_inventaire, 18.0)

func _quitter_run() -> void:
	Sons.jouer("choix", -10.0)
	Jeu.terminer_run(false)


class _VueAmeliorations:
	extends Control
	signal ferme
	signal reprise_demandee
	func _ready() -> void:
		var col := StyleAzur.page(self,"Mes améliorations")
		var liste := StyleAzur.defilement(col)
		StyleAzur.banniere(liste, "Le grimoire de cette aventure", "%d augmentations recueillies" % Jeu.inventaire.size(), "grimoire")
		if Jeu.inventaire.is_empty():
			var vide := StyleAzur.texte("Votre grimoire attend son premier pouvoir.\nGagnez un niveau pour choisir une augmentation.", 29, StyleAzur.ATTENUE)
			vide.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			liste.add_child(vide)
		for entree in Jeu.inventaire_groupe():
			var reactif := Jeu.reactif(str(entree[0]))
			if reactif == null: continue
			var carte := CarteReactif.new()
			carte.configurer(reactif)
			liste.add_child(carte)
			carte.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(StyleAzur.bouton("Reprendre l’aventure", func(): reprise_demandee.emit(), true))
