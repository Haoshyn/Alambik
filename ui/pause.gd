extends Control
signal termine
const REGLAGES := preload("res://ui/reglages.tscn")
var _inventaire: Control
var _reglages: Control

func _ready() -> void:
	var col := StyleAzur.page(self,"Pause")
	var contenu := StyleAzur.defilement(col)
	contenu.add_child(StyleAzur.image(10,280))
	contenu.add_child(StyleAzur.texte("%s · Salle %d / %d" % [Jeu.nom_run(),Jeu.salle_courante,Jeu.salles_du_chapitre()],36))
	contenu.add_child(StyleAzur.texte("Niveau %d · %d améliorations" % [Jeu.niveau_run,Jeu.inventaire.size()],29,StyleAzur.ATTENUE))
	contenu.add_child(StyleAzur.bouton("Reprendre",_reprendre,true))
	contenu.add_child(StyleAzur.bouton("Mes améliorations",_ouvrir_ameliorations))
	contenu.add_child(StyleAzur.bouton("Paramètres",_ouvrir_reglages))
	contenu.add_child(StyleAzur.bouton("Quitter l’aventure",_quitter_run))
	Capture.programmer(self)

func _reprendre() -> void:
	Sons.jouer("choix", -12.0)
	StyleInterface.sortir_puis(self, func() -> void: termine.emit())

func _ouvrir_reglages() -> void:
	Sons.jouer("choix", -12.0)
	if _reglages != null: return
	var panneau := REGLAGES.instantiate()
	_reglages = panneau
	panneau.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(panneau)
	panneau.ferme.connect(func() -> void:
		panneau.queue_free()
		_reglages = null)

func _ouvrir_ameliorations() -> void:
	if _inventaire != null:
		return
	Sons.jouer("choix", -12.0)
	_inventaire = _VueAmeliorations.new()
	_inventaire.ferme.connect(func() -> void:
		_inventaire.queue_free()
		_inventaire = null)
	add_child(_inventaire)
	StyleInterface.animer_entree(_inventaire, 18.0)

func _quitter_run() -> void:
	Sons.jouer("choix", -10.0)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


class _VueAmeliorations:
	extends Control
	signal ferme
	func _ready() -> void:
		var col := StyleAzur.page(self,"Mes améliorations")
		var liste := StyleAzur.defilement(col)
		if Jeu.inventaire.is_empty():
			liste.add_child(StyleAzur.texte("Aucune amélioration pour le moment.",29))
		for entree in Jeu.inventaire_groupe():
			var reactif := Jeu.reactif(str(entree[0]))
			if reactif == null: continue
			var carte := CarteReactif.new()
			carte.configurer(reactif)
			carte.mouse_filter = Control.MOUSE_FILTER_IGNORE
			liste.add_child(carte)
