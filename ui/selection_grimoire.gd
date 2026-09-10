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
var _titre: Label
var _details: Label

func _ready() -> void:
	_monde = clampi(ReglagesJoueur.chapitre_choisi / 3,0,Chapitres.MONDES.size()-1)
	_chapitre_monde = posmod(ReglagesJoueur.chapitre_choisi,3)
	var col := StyleAzur.page(self,"Campagne & modes")
	var contenu := StyleAzur.defilement(col)
	contenu.add_child(StyleAzur.image(10,220))
	var navigation := HBoxContainer.new()
	contenu.add_child(navigation)
	navigation.add_child(StyleAzur.bouton("‹ Monde",func(): _changer_monde(-1)))
	navigation.add_child(StyleAzur.bouton("Monde ›",func(): _changer_monde(1)))
	_titre = StyleAzur.texte("",38)
	contenu.add_child(_titre)
	for i in 3:
		var b := StyleAzur.bouton("",func(): _choisir_chapitre(i))
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.custom_minimum_size.y = 145
		contenu.add_child(b)
		_zones_chapitres.append(b)
	_details = StyleAzur.texte("",28,StyleAzur.ATTENUE)
	contenu.add_child(_details)
	_bouton_selectionner = StyleAzur.bouton("Choisir cette campagne",_selectionner,true)
	contenu.add_child(_bouton_selectionner)
	contenu.add_child(StyleAzur.texte("Autres aventures",35))
	contenu.add_child(StyleAzur.bouton("La Mine",func(): _choisir_mode("mine")))
	contenu.add_child(StyleAzur.bouton("Épreuves de magie",func(): _choisir_mode("epreuve_sorts")))
	_rafraichir()
	Capture.programmer(self)

func _choisir_mode(mode: String) -> void:
	if _lancement: return
	ReglagesJoueur.choisir_mode_run(mode)
	selection_changee.emit()
	_fermer()

func _rafraichir() -> void:
	_titre.text = str(Chapitres.MONDES[_monde]["nom"])
	for i in 3:
		var index := _monde*3+i
		var d := Chapitres.par_index(index)
		_zones_chapitres[i].text = "%s   ·   %s" % [d["nom"],"Accessible" if ReglagesJoueur.chapitre_debloque(index) else "Verrouillé"]
		_zones_chapitres[i].add_theme_stylebox_override("normal",StyleAzur.cadre(StyleAzur.PANNEAU,StyleAzur.MAGIE if i == _chapitre_monde else StyleAzur.CUIVRE))
	_bouton_selectionner.disabled = not ReglagesJoueur.chapitre_debloque(_index_selectionne())
	_details.text = "Meilleur étage : %d / %d\n%s" % [ReglagesJoueur.meilleure_du_chapitre(_index_selectionne()),Chapitres.par_index(_index_selectionne())["salles"],_message]

func _index_selectionne() -> int:
	return _monde * 3 + _chapitre_monde

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
	_chapitre_monde = clampi(index, 0, 2)
	var chapitre := _index_selectionne()
	_message = "" if ReglagesJoueur.chapitre_debloque(chapitre) else "Ce chapitre est encore verrouillé."
	Sons.jouer("choix", -16.0)
	_rafraichir()

func _selectionner() -> void:
	var index := _index_selectionne()
	if not ReglagesJoueur.chapitre_debloque(index):
		_message = "Terminez le chapitre précédent pour ouvrir celui-ci."
		_rafraichir()
		return
	ReglagesJoueur.choisir_mode_run("grimoire")
	ReglagesJoueur.choisir_chapitre(index)
	Sons.jouer("choix", -10.0)
	if selection_seulement:
		selection_changee.emit()
		StyleInterface.sortir_puis(self, func() -> void: ferme.emit())
		return
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
