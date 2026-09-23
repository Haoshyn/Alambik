extends Control

signal termine
const COFFRE_FIN_OUVERTURE := 1.08
const COFFRE_REVELATION := 0.82
const COFFRE_DUREE_ECRAN := 5.2
const TRANSITION := preload("res://ui/transition_grimoire.tscn")
var _bilan: VBoxContainer
var _page: VBoxContainer
var _coffre: Button
var _recompenses: VBoxContainer
var _cadre_recompenses: Control
var _indication: Label
var _actions_fin: BoxContainer
var _boutons_sortie: Array[Button] = []
var _anim := 0.0
var _ouvert := false
var _revele := false
var _affiche := false
var _sortie := false

func _ready() -> void:
	_page = StyleAzur.page(self, "Carnet d’aventure")
	_bilan = StyleAzur.defilement(_page)
	StyleInterface.animer_entree(self)

func afficher(victoire: bool, salle_atteinte: int) -> void:
	if _affiche: return
	_affiche = true
	var gains := BilanRun.finaliser(victoire, salle_atteinte)
	StyleAzur.banniere(_bilan, "Victoire !" if victoire else "L’aventure s’achève", Jeu.nom_run(), "victoire" if victoire else "defaite")
	var parcours := StyleAzur.texte("%d salles terminées  ·  %d boss vaincus" % [Jeu.salles_terminees.size(), Jeu.boss_vaincus.size()], 28, StyleAzur.ATTENUE)
	parcours.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bilan.add_child(parcours)
	StyleAzur.separateur(_bilan)
	var nom_coffre := StyleAzur.texte(str(gains["nom"]), 36, StyleAzur.CUIVRE)
	nom_coffre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bilan.add_child(nom_coffre)
	_coffre = preload("res://ui/coffre_anime.gd").new()
	_coffre.rang = int(gains["rang"])
	_coffre.pressed.connect(_ouvrir)
	_bilan.add_child(_coffre)
	_indication = StyleAzur.texte("Touchez le coffre pour l’ouvrir", 30)
	_indication.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bilan.add_child(_indication)
	_recompenses = StyleAzur.plaque(_bilan, true)
	_cadre_recompenses = _recompenses.get_parent() as Control
	_cadre_recompenses.hide()
	for cle in ["gouttes", "xp", "pierres"]:
		var nombre := int(gains[cle])
		if nombre > 0:
			var illustration := str({"gouttes": "fiole", "xp": "astrolabe", "pierres": "forge"}[cle])
			var legende := str({"gouttes": "gouttes", "xp": "XP de compte", "pierres": "pierres de forge"}[cle])
			_ajouter_gain(StyleAzur.illustration(illustration, 76), "+%d %s" % [nombre, legende])
	var objet := str(gains["objet"])
	if not objet.is_empty():
		var donnees_objet: Dictionary = CatalogueObjets.OBJETS[objet]
		_ajouter_gain(StyleAzur.image(StyleAzur.icone_objet(objet), 76), str(donnees_objet["nom"]), "Équipement obtenu")
	var sort_ := str(gains["sort"])
	for cadeau in gains["cadeaux"]:
		var id_cadeau := str(cadeau)
		_ajouter_gain(StyleAzur.vignette(id_cadeau, 76), str(Sorts.donnees(id_cadeau)["nom"]), "Cadeau de campagne")
	if not sort_.is_empty():
		_ajouter_gain(StyleAzur.vignette(sort_, 76), str(Sorts.donnees(sort_)["nom"]), "Sort obtenu · Rang %d" % ReglagesJoueur.rang_sort(sort_))
	if bool(gains.get("coeur_mana", false)):
		_ajouter_gain(StyleAzur.illustration("astrolabe", 76), "Cœur de mana obtenu",
			"+10 % de dégâts finaux · %d / %d" % [ReglagesJoueur.nombre_coeurs_mana(), Epreuves.nombre()])
	if _recompenses.get_child_count() == 0:
		_recompenses.add_child(StyleAzur.texte("Le coffre est vide.\nTerminez une salle pour commencer à le remplir.", 30, StyleAzur.ENCRE))
	_afficher_ameliorations_disponibles()
	_actions_fin = BoxContainer.new()
	StyleAzur.adapter_ligne(_actions_fin)
	_actions_fin.add_theme_constant_override("separation", 18)
	_actions_fin.hide()
	_page.add_child(_actions_fin)
	_ajouter_action(_actions_fin, "Rejouer" if victoire else "Réessayer", _reessayer, true)
	_ajouter_action(_actions_fin, "Retour à l’accueil", _retourner)
	if Jeu.mode_auto: _ouvrir()

func _ajouter_action(parent: Node, titre: String, action: Callable, principal := false) -> void:
	var bouton := StyleAzur.bouton(titre, action, principal)
	parent.add_child(bouton)
	_boutons_sortie.append(bouton)

func _ajouter_gain(icone: Control, titre: String, sous_titre := "") -> void:
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 22)
	_recompenses.add_child(ligne)
	icone.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ligne.add_child(icone)
	var texte := VBoxContainer.new()
	texte.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texte.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ligne.add_child(texte)
	texte.add_child(StyleAzur.texte(titre, 32, StyleAzur.IVOIRE))
	if not sous_titre.is_empty():
		texte.add_child(StyleAzur.texte(sous_titre, 24, StyleAzur.ATTENUE))

func _afficher_ameliorations_disponibles() -> void:
	var disponibles := BilanRun.ameliorations_accessibles()
	if disponibles.is_empty():
		return
	StyleAzur.separateur(_recompenses)
	_recompenses.add_child(StyleAzur.texte("De nouvelles possibilités à l’atelier", 30, StyleAzur.CUIVRE))
	if disponibles.has("maitrise"):
		var achat: Dictionary = disponibles["maitrise"]
		var noeud: Dictionary = ArbreCompetences.NOEUDS[str(achat["id"])]
		_recompenses.add_child(StyleAzur.texte("Maîtrises : %s, rang %d · %d Gouttes\n%s" % [
			noeud["nom"], int(achat["rang"]), int(achat["cout"]), noeud["description"]], 26, StyleAzur.ENCRE))
		_ajouter_action(_recompenses, "Améliorer cette maîtrise", _retourner.bind("maitrises", str(achat["id"])))
	if disponibles.has("forge"):
		var achat: Dictionary = disponibles["forge"]
		var objet: Dictionary = CatalogueObjets.OBJETS[str(achat["id"])]
		_recompenses.add_child(StyleAzur.texte("Équipement : %s équipé, forge niveau %d · %d Pierres" % [
			objet["nom"], int(achat["rang"]), int(achat["cout"])], 26, StyleAzur.ENCRE))
		_ajouter_action(_recompenses, "Ouvrir la forge", _retourner.bind("equipement", str(achat["id"])))

func _ouvrir() -> void:
	if _ouvert: return
	_ouvert = true
	_anim = 0.0
	_coffre.disabled = true
	_indication.text = "Ouverture…"
	Sons.jouer("coffre", -5.0)

func _process(delta: float) -> void:
	if not _ouvert or _sortie: return
	_anim += delta * (1.8 if ReglagesJoueur.effets_reduits else 1.0)
	_coffre.ouverture = progression_ouverture(_anim)
	if not _revele and _anim >= COFFRE_REVELATION:
		_revele = true
		_indication.text = "Récompenses obtenues"
		_animer_recompenses()
	if Jeu.mode_auto and _anim >= COFFRE_DUREE_ECRAN: _retourner()

func _animer_recompenses() -> void:
	_cadre_recompenses.show()
	_actions_fin.show()
	if ReglagesJoueur.effets_reduits:
		return
	_cadre_recompenses.modulate.a = 0.0
	_actions_fin.modulate.a = 0.0
	var apparition := create_tween().set_parallel(true)
	apparition.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	apparition.tween_property(_cadre_recompenses, "modulate:a", 1.0, 0.24)
	var index := 0
	for noeud in _recompenses.get_children():
		if not noeud is Control:
			continue
		var element := noeud as Control
		if index == 0:
			index += 1
			continue
		element.modulate.a = 0.0
		element.pivot_offset = element.size * 0.5
		element.scale = Vector2.ONE * 0.96
		var retard := 0.08 + float(index - 1) * 0.075
		apparition.tween_property(element, "modulate:a", 1.0, 0.23).set_delay(retard)
		apparition.tween_property(element, "scale", Vector2.ONE, 0.31).set_delay(retard)
		index += 1
	apparition.tween_property(_actions_fin, "modulate:a", 1.0, 0.24).set_delay(0.18 + float(index) * 0.075)

func _verrouiller_sortie() -> bool:
	if _sortie or not _revele: return false
	_sortie = true
	for bouton in _boutons_sortie:
		bouton.disabled = true
	return true

func _reessayer() -> void:
	if not _verrouiller_sortie(): return
	Jeu.preparer_nouvelle_tentative()
	Sons.jouer("choix", -10.0)
	Sons.demarrer_musique_combat()
	var transition := TRANSITION.instantiate()
	transition.configurer({"nom": Jeu.nom_run()})
	transition.process_mode = Node.PROCESS_MODE_ALWAYS
	transition.terminee.connect(_changer_scene.bind("res://scenes/run.tscn", transition), CONNECT_ONE_SHOT)
	add_child(transition)

func _retourner(page_menu := "aventure", selection := "") -> void:
	if not _verrouiller_sortie(): return
	if Jeu.mode_auto:
		get_tree().paused = false
		Sons.arreter()
		await get_tree().create_timer(0.3).timeout
		get_tree().quit()
		return
	Jeu.destination_menu = {"page": page_menu, "selection": selection}
	Sons.jouer("choix", -12.0)
	StyleInterface.sortir_puis(_page, _changer_scene.bind("res://scenes/menu.tscn"), 0.0)

func _changer_scene(chemin: String, transition: Control = null) -> void:
	var arbre := get_tree()
	var erreur := arbre.change_scene_to_file(chemin)
	if erreur == OK:
		# Le combat termine reste suspendu jusqu'a son retrait de l'arbre.
		arbre.paused = false
		return
	if is_instance_valid(transition):
		transition.queue_free()
	Jeu.nouvelle_tentative.clear()
	Jeu.destination_menu.clear()
	_sortie = false
	for bouton in _boutons_sortie:
		bouton.disabled = false
	if _page.has_meta("sortie_interface_en_cours"):
		_page.remove_meta("sortie_interface_en_cours")
	_page.mouse_filter = Control.MOUSE_FILTER_PASS
	_page.modulate.a = 1.0
	_page.scale = Vector2.ONE
	_indication.text = "Impossible d’ouvrir cet écran. Réessayez."
	Sons.musique_calme()

func _notification(quoi: int) -> void:
	if quoi == NOTIFICATION_WM_GO_BACK_REQUEST and _affiche:
		if _revele: _retourner()
		else: _ouvrir()

static func progression_ouverture(temps: float) -> float:
	var brut := clampf(temps / COFFRE_FIN_OUVERTURE, 0.0, 1.0)
	if brut < 0.13:
		return -0.035 * sin(brut / 0.13 * PI)
	if brut < 0.77:
		var mouvement := (brut - 0.13) / 0.64
		return 1.045 * (1.0 - pow(1.0 - mouvement, 3.0))
	var pose := (brut - 0.77) / 0.23
	return 1.0 + 0.045 * (1.0 + cos(PI * pose)) * 0.5
