extends Control
signal ferme
var mode := "grimoire"
var chapitre := 0
var niveau_epreuve := 1

func _ready() -> void:
	var col := StyleAzur.defilement(StyleAzur.page(self, "Récompenses possibles"))
	var salles := Reglages.SALLES_PAR_RUN if mode == "grimoire" else 5 if mode == "epreuve_sorts" else 1
	var boss := 4 if mode == "grimoire" else 5 if mode == "epreuve_sorts" else 1
	var offre := ButinsRun.offre(mode, chapitre, salles, boss, true, niveau_epreuve,
		ReglagesJoueur.rangs_sorts, ReglagesJoueur.objets, ReglagesJoueur.grands_coffres_rates(chapitre), ReglagesJoueur.epreuves_ratees(niveau_epreuve))
	var titre := str(Chapitres.par_index(chapitre)["nom"]) if mode == "grimoire" else "Épreuve de magie · niveau %d" % niveau_epreuve if mode == "epreuve_sorts" else "La Mine"
	col.add_child(StyleAzur.texte(titre, 36))
	col.add_child(StyleAzur.texte("Coffre d’une aventure terminée", 29, StyleAzur.ATTENUE))
	for cadeau in offre["cadeaux"]:
		_ajouter_carte(col, str(cadeau), "sort", 1.0)
	col.add_child(StyleAzur.texte("%d–%d gouttes\n%d XP de compte" % [BilanRun.gouttes_finales(int(offre["gouttes_min"])), BilanRun.gouttes_finales(int(offre["gouttes_max"])), ReglagesJoueur.gain_experience_compte(int(offre["xp"]))], 32))
	if mode == "mine":
		var pierres := roundi(float(ReglagesJoueur.pierres_mine()) * ArbreCompetences.multiplicateur_pierres(ReglagesJoueur.rangs_competences_effectifs()))
		col.add_child(StyleAzur.texte("%d pierres de forge · 100 %%" % pierres, 30))
	for type in ["objet", "sort"]:
		var candidats: Array = offre[type + "s"]
		if candidats.is_empty(): continue
		var chance := float(offre["chance_" + type])
		for id in candidats:
			_ajouter_carte(col, str(id), type, chance / float(candidats.size()))
	if mode == "epreuve_sorts":
		if not (offre["sorts"] as Array).is_empty():
			col.add_child(StyleAzur.texte("Garantie de ce niveau : un sort sous %d victoire(s) maximum. Le compteur repart après chaque sort obtenu." % maxi(1,Reglages.EPREUVE_GARANTIE_CAPACITE-ReglagesJoueur.epreuves_ratees(niveau_epreuve)),27,StyleAzur.ATTENUE))
		col.add_child(StyleAzur.texte("Un sort au maximum. Les sorts au rang maximal sortent du tirage.\nSans sort : %.0f %%" % [(1.0 - float(offre["chance_sort"])) * 100.0], 27, StyleAzur.ATTENUE))
	elif mode == "grimoire":
		if not (offre["objets"] as Array).is_empty():
			col.add_child(StyleAzur.texte("Garantie de ce chapitre : objet sous %d victoire(s) maximum." % (1 if chapitre == 0 else maxi(1,Recompenses.GARANTIE_APRES_GRANDS_COFFRES-ReglagesJoueur.grands_coffres_rates(chapitre))),27,StyleAzur.ATTENUE))
		col.add_child(StyleAzur.texte("Sans objet : %.0f %%\nPremier chapitre : objet garanti à la première victoire. Un objet manquant garanti au plus tard au 3e coffre complet, s’il reste un objet à obtenir." % [(1.0 - float(offre["chance_objet"])) * 100.0], 27, StyleAzur.ATTENUE))
	col.add_child(StyleAzur.texte("Chaque salle remplit le coffre ; chaque boss augmente son rang. Abandon ou défaite : les gains des salles terminées restent acquis. Objets et sorts exigent la victoire finale.\nMontants avec vos bonus actuels, hors augmentations de l’aventure. Aucune salle terminée : coffre vide.", 27, StyleAzur.ATTENUE))

var _detail: Control

func _ajouter_carte(col: VBoxContainer, id: String, type: String, chance: float) -> void:
	var d: Dictionary = CatalogueObjets.OBJETS[id] if type == "objet" else Sorts.donnees(id)
	var carte := StyleAzur.bouton("%s · %.1f %%\n%s\nToucher pour voir les détails" % [d["nom"], chance * 100.0,
		_resume_objet(id, 0) if type == "objet" else d["description"]], func(): _ouvrir_detail(id, type))
	carte.name = "Carte_" + id
	carte.icon = StyleAzur.icone(StyleAzur.icone_objet(id)) if type == "objet" else StyleAzur.glyphe(id)
	carte.expand_icon = true
	carte.add_theme_constant_override("icon_max_width", 120)
	carte.add_theme_font_size_override("font_size", 26)
	carte.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	carte.custom_minimum_size.y = 180
	StyleAzur.case_objet(carte)
	col.add_child(carte)

func _resume_objet(id: String, niveau: int) -> String:
	var bonus := CatalogueObjets.bonus_objet(id, niveau)
	return "Dégâts +%s %% · PV +%s %%" % [_pourcentage(float(bonus["degats"])), _pourcentage(float(bonus["pv"]))]

func _pourcentage(valeur: float) -> String:
	return String.num(valeur * 100.0, 1).trim_suffix(".0").replace(".", ",")

func _ouvrir_detail(id: String, type: String) -> void:
	if is_instance_valid(_detail): _detail.queue_free()
	_detail = Control.new()
	_detail.add_user_signal("ferme")
	add_child(_detail)
	_detail.connect("ferme", func(): _detail.queue_free())
	var d: Dictionary = CatalogueObjets.OBJETS[id] if type == "objet" else Sorts.donnees(id)
	var col := StyleAzur.defilement(StyleAzur.page(_detail, str(d["nom"])))
	col.add_child(StyleAzur.image(StyleAzur.icone_objet(id), 240) if type == "objet" else StyleAzur.vignette(id, 240))
	if type == "objet":
		col.add_child(StyleAzur.texte("À l’obtention\n" + _resume_objet(id, 0), 30))
		col.add_child(StyleAzur.texte("Forge 10\n" + _resume_objet(id, 10), 30))
		col.add_child(StyleAzur.texte(CatalogueObjets.description_effets(id, 10), 28))
		col.add_child(StyleAzur.texte("Un seul pouvoir au niveau 10. Ensuite, la forge augmente uniquement les dégâts et les PV, avec un coût croissant.", 26, StyleAzur.ATTENUE))
	else:
		col.add_child(StyleAzur.texte(str(d["description"]), 30))
		col.add_child(StyleAzur.texte("Rang 1 : %s\nRang %d : %s" % [Sorts.resume_rang(id, 1), Reglages.CAPACITE_RANG_MAX, Sorts.resume_rang(id, Reglages.CAPACITE_RANG_MAX)], 28))
		col.add_child(StyleAzur.texte("Les doublons améliorent cette capacité, jusqu’au rang %d. %s" % [Reglages.CAPACITE_RANG_MAX, Sorts.progression_rang(id)], 26, StyleAzur.ATTENUE))
