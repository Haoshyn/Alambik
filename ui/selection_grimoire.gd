extends Control
signal ferme
signal selection_changee
const TRANSITION := preload("res://ui/transition_grimoire.tscn")
var selection_seulement := false
var _monde := 0
var _chapitre_monde := 0
var _message := ""
var _lancement := false
var _zones_chapitres: Array[Button] = []
var _bouton_selectionner: Button
var _bouton_mine: Button
var _bouton_epreuve: Button
var _titre: Label
var _details: Label
var _liste_epreuves: VBoxContainer
var _apercu: Control

func _ready() -> void:
	_monde = clampi(ReglagesJoueur.chapitre_choisi / Chapitres.CHAPITRES_PAR_MONDE,0,Chapitres.MONDES.size()-1)
	_chapitre_monde = posmod(ReglagesJoueur.chapitre_choisi,Chapitres.CHAPITRES_PAR_MONDE)
	var col := StyleAzur.page(self,"Campagne & modes")
	var contenu := StyleAzur.defilement(col)
	contenu.add_child(StyleAzur.image(10,220))
	var navigation := HBoxContainer.new()
	contenu.add_child(navigation)
	navigation.add_child(StyleAzur.bouton("‹ Monde",func(): _changer_monde(-1)))
	navigation.add_child(StyleAzur.bouton("Monde ›",func(): _changer_monde(1)))
	_titre = StyleAzur.texte("",38)
	contenu.add_child(_titre)
	for i in Chapitres.CHAPITRES_PAR_MONDE:
		var b := StyleAzur.bouton("",func(): _choisir_chapitre(i))
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.custom_minimum_size.y = 145
		var ligne := HBoxContainer.new()
		contenu.add_child(ligne)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ligne.add_child(b)
		var info := StyleAzur.bouton("!", func(): _voir_loots("grimoire", _monde * Chapitres.CHAPITRES_PAR_MONDE + i))
		info.custom_minimum_size = Vector2(72, 72)
		info.tooltip_text = "Récompenses possibles"
		ligne.add_child(info)
		_zones_chapitres.append(b)
	_details = StyleAzur.texte("",28,StyleAzur.ATTENUE)
	contenu.add_child(_details)
	_bouton_selectionner = StyleAzur.bouton("Jouer ce chapitre",_selectionner,true)
	contenu.add_child(_bouton_selectionner)
	contenu.add_child(StyleAzur.texte("Autres aventures",35))
	_bouton_mine = StyleAzur.bouton("La Mine",func(): _choisir_mode("mine"))
	var ligne_mine := HBoxContainer.new()
	contenu.add_child(ligne_mine)
	_bouton_mine.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ligne_mine.add_child(_bouton_mine)
	var info_mine := StyleAzur.bouton("!", func(): _voir_loots("mine"))
	info_mine.custom_minimum_size.x = 72
	ligne_mine.add_child(info_mine)
	_bouton_epreuve = StyleAzur.bouton("Épreuves de magie",func(): _choisir_mode("epreuve_sorts"))
	contenu.add_child(_bouton_epreuve)
	_liste_epreuves = VBoxContainer.new()
	contenu.add_child(_liste_epreuves)
	_liste_epreuves.visible = ReglagesJoueur.mode_run_choisi == "epreuve_sorts"
	_liste_epreuves.add_child(StyleAzur.texte("Cinq boss · un choix d’augmentation entre chaque boss.
Terminez un niveau pour ouvrir le suivant. Rejouez-le pour monter ses sorts en rang.", 27, StyleAzur.ATTENUE))
	for i in Epreuves.nombre():
		var niveau := i + 1
		var ligne := HBoxContainer.new()
		_liste_epreuves.add_child(ligne)
		var noms: Array[String] = []
		for id in Epreuves.sorts(niveau): noms.append(str(Sorts.donnees(str(id))["nom"]))
		var b := StyleAzur.bouton("Niveau %d · %s" % [niveau, " / ".join(noms)], func(): _choisir_epreuve(niveau))
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size.y = 120
		b.disabled = not ReglagesJoueur.mode_dev and niveau > ReglagesJoueur.niveau_epreuve_debloque
		ligne.add_child(b)
		var info := StyleAzur.bouton("!", func(): _voir_loots("epreuve_sorts", 0, niveau))
		info.custom_minimum_size.x = 72
		ligne.add_child(info)
	_rafraichir()
	Capture.programmer(self)

func _choisir_mode(mode: String) -> void:
	if _lancement:
		return
	if not ReglagesJoueur.mode_debloque(mode):
		_message = "Terminez davantage de chapitres pour ouvrir ce mode."
		_rafraichir()
		return
	if mode == "epreuve_sorts":
		_liste_epreuves.visible = not _liste_epreuves.visible
		return
	ReglagesJoueur.choisir_mode_run(mode)
	selection_changee.emit()
	_fermer()

func _rafraichir() -> void:
	_titre.text = "%s · %s" % [Chapitres.MONDES[_monde]["nom"],DecorsMondes.profil(_monde)["nom"]]
	for i in Chapitres.CHAPITRES_PAR_MONDE:
		var index := _monde * Chapitres.CHAPITRES_PAR_MONDE + i
		var d := Chapitres.par_index(index)
		_zones_chapitres[i].text = "%s   ·   %s" % [d["nom"],"Accessible" if ReglagesJoueur.chapitre_debloque(index) else "Verrouillé"]
		_zones_chapitres[i].add_theme_stylebox_override("normal",StyleAzur.cadre(StyleAzur.PANNEAU,StyleAzur.MAGIE if i == _chapitre_monde else StyleAzur.CUIVRE))
	_bouton_selectionner.disabled = not ReglagesJoueur.chapitre_debloque(_index_selectionne())
	_bouton_epreuve.disabled = not ReglagesJoueur.mode_debloque("epreuve_sorts")
	_bouton_mine.disabled = not ReglagesJoueur.mode_debloque("mine")
	_bouton_epreuve.text = "Épreuves de magie" if not _bouton_epreuve.disabled else \
		"Épreuves de magie · niveau %d" % Reglages.EPREUVE_NIVEAU_DEBLOCAGE
	_bouton_mine.text = "La Mine" if not _bouton_mine.disabled else \
		"La Mine · niveau %d" % Reglages.MINE_NIVEAU_DEBLOCAGE
	_details.text = "Meilleur étage : %d / %d\n%s" % [ReglagesJoueur.meilleure_du_chapitre(_index_selectionne()),Chapitres.par_index(_index_selectionne())["salles"],_message]

func _index_selectionne() -> int:
	return _monde * Chapitres.CHAPITRES_PAR_MONDE + _chapitre_monde

func _changer_monde(direction: int) -> void:
	var nouveau := clampi(_monde + direction, 0, Chapitres.MONDES.size() - 1)
	if nouveau == _monde:
		return
	_monde = nouveau
	_message = ""
	# Conserver le numero de chapitre rend la comparaison entre mondes naturelle.
	# Si celui-ci est verrouille, la fiche le dit sans modifier le choix en cachette.
	Sons.jouer("choix", -16.0, 1.0 + float(direction) * 0.04)
	_rafraichir()

func _choisir_chapitre(index: int) -> void:
	if _lancement: return
	_chapitre_monde = clampi(index, 0, Chapitres.CHAPITRES_PAR_MONDE - 1)
	var chapitre := _index_selectionne()
	_message = "" if ReglagesJoueur.chapitre_debloque(chapitre) else "Ce chapitre est encore verrouillé."
	Sons.jouer("choix", -16.0)
	_rafraichir()
	if ReglagesJoueur.chapitre_debloque(chapitre):
		_selectionner()

func _selectionner() -> void:
	if _lancement: return
	var index := _index_selectionne()
	if not ReglagesJoueur.chapitre_debloque(index):
		_message = "Terminez le chapitre précédent pour ouvrir celui-ci."
		_rafraichir()
		return
	ReglagesJoueur.choisir_mode_run("grimoire")
	ReglagesJoueur.choisir_chapitre(index)
	Sons.jouer("choix", -10.0)
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

func _choisir_epreuve(niveau: int) -> void:
	if not ReglagesJoueur.choisir_epreuve(niveau): return
	selection_changee.emit()
	_fermer()

func _voir_loots(mode: String, chapitre := 0, niveau := 1) -> void:
	if is_instance_valid(_apercu): return
	_apercu = preload("res://ui/apercu_butin.gd").new()
	_apercu.mode = mode
	_apercu.chapitre = chapitre
	_apercu.niveau_epreuve = niveau
	add_child(_apercu)
	_apercu.ferme.connect(func():
		_apercu.queue_free()
		_apercu = null)
