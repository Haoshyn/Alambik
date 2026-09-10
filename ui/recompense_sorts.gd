extends Control



signal termine

var etage_recompense := 1
var _recompense := {}
var _anim := 0.0

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_recompense = Recompenses.tirer_epreuve(Jeu.rng, ReglagesJoueur.rangs_sorts,
		ReglagesJoueur.niveau_campagne_atteint())
	if _recompense["type"] == "gouttes":
		ReglagesJoueur.ajouter_gouttes(int(_recompense["quantite"]))
	else:
		ReglagesJoueur.debloquer_sort(str(_recompense["id"]))
	_construire()
	StyleInterface.animer_entree(self)
	if Jeu.mode_auto:
		await get_tree().create_timer(0.15).timeout
		_quitter()

func _construire() -> void:
	var col := StyleAzur.page(self,"Récompense des Épreuves")
	var contenu := StyleAzur.defilement(col)
	contenu.add_child(StyleAzur.vignette(str(_recompense.get("id","collecte")),250))
	if _recompense["type"] == "gouttes":
		contenu.add_child(StyleAzur.texte("+%d gouttes" % int(_recompense["quantite"]),42))
	else:
		var id := str(_recompense["id"])
		var donnees := Sorts.donnees(id)
		contenu.add_child(StyleAzur.texte(str(donnees["nom"]),42))
		contenu.add_child(StyleAzur.texte(str(donnees["description"]),31,StyleAzur.ATTENUE))
		contenu.add_child(StyleAzur.texte("Rang %d / %d" % [ReglagesJoueur.rang_sort(id),Reglages.CAPACITE_RANG_MAX],30,StyleAzur.MAGIE))
	contenu.add_child(StyleAzur.texte("La récompense a été ajoutée à votre collection.",28))
	col.add_child(StyleAzur.bouton("Continuer" if etage_recompense < Jeu.salles_du_chapitre() else "Terminer les Épreuves",_quitter,true))

func _quitter() -> void:
	StyleInterface.sortir_puis(self, func() -> void: termine.emit())
