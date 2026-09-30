extends Control
signal ferme
var mode := "grimoire"
var chapitre := 0
var niveau_epreuve := 1
var niveau_mine := 1

func _ready() -> void:
	var col := StyleAzur.defilement(StyleAzur.page(self, "Récompenses possibles"))
	var salles := Reglages.SALLES_PAR_RUN if mode == "grimoire" else 5 if mode == "epreuves" else 1
	var boss := 4 if mode == "grimoire" else 5 if mode == "epreuves" else 1
	var offre := ButinsRun.offre(mode, chapitre, salles, boss, true, niveau_epreuve,
		ReglagesJoueur.rangs_passifs, ReglagesJoueur.objets, ReglagesJoueur.grands_coffres_rates(chapitre),
		ReglagesJoueur.epreuves_ratees(niveau_epreuve), Mine.palier(niveau_mine), 0.0,
		ReglagesJoueur.coeur_mana_obtenu(niveau_epreuve),
		ReglagesJoueur.epreuves_sans_coeur_mana(niveau_epreuve))
	var titre := str(Chapitres.par_index(chapitre)["nom"]) if mode == "grimoire" else "Épreuve · niveau %d" % niveau_epreuve if mode == "epreuves" else "La Mine · niveau %d" % niveau_mine
	StyleAzur.banniere(col, titre, "", "couronne")
	col.add_child(StyleAzur.texte("DANS VOTRE COFFRE", 24, StyleAzur.CUIVRE))
	var ressources := StyleAzur.plaque(col, true)
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 24)
	ressources.add_child(ligne)
	ligne.add_child(StyleAzur.illustration("fiole", 120))
	var gains := StyleAzur.texte("%d–%d gouttes\n%d XP de compte" % [BilanRun.gouttes_finales(int(offre["gouttes_min"])), BilanRun.gouttes_finales(int(offre["gouttes_max"])), ReglagesJoueur.gain_experience_compte(int(offre["xp"]))], 32)
	gains.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ligne.add_child(gains)
	var pierres := roundi(float(offre["pierres"]) * ArbreCompetences.multiplicateur_pierres(ReglagesJoueur.rangs_competences_effectifs()))
	if pierres > 0:
		ressources.add_child(StyleAzur.texte("%d pierres de forge · garanties" % pierres, 29, StyleAzur.CUIVRE))
	StyleAzur.separateur(col)
	for type in ["objet", "passif"]:
		var candidats: Array = offre[type + "s"]
		if candidats.is_empty(): continue
		var chance := float(offre["chance_" + type])
		for id in candidats:
			_ajouter_carte(col, str(id), type, chance / float(candidats.size()))
	var precisions := StyleAzur.plaque(col, true)
	precisions.add_child(StyleAzur.texte("À savoir", 29, StyleAzur.ENCRE))
	if mode == "epreuves":
		if not (offre["passifs"] as Array).is_empty():
			precisions.add_child(StyleAzur.texte("Garantie de ce niveau : un passif sous %d victoire(s) maximum. Le compteur repart après chaque passif obtenu." % maxi(1,Reglages.EPREUVE_GARANTIE_CAPACITE-ReglagesJoueur.epreuves_ratees(niveau_epreuve)),27,StyleAzur.ATTENUE))
		precisions.add_child(StyleAzur.texte("Un passif au maximum. Les passifs au rang maximal sortent du tirage.\nSans passif : %.0f %%" % [(1.0 - float(offre["chance_passif"])) * 100.0], 27, StyleAzur.ATTENUE))
		if ReglagesJoueur.coeur_mana_obtenu(niveau_epreuve):
			precisions.add_child(StyleAzur.texte("Cœur de mana déjà obtenu dans ce niveau.", 27, StyleAzur.CUIVRE))
		else:
			precisions.add_child(StyleAzur.texte("Cœur de mana : %.0f %% · garanti sous %d victoire(s) maximum. Un seul pour ce niveau." % [float(offre["chance_coeur"]) * 100.0, maxi(1, Reglages.EPREUVE_GARANTIE_COEUR - ReglagesJoueur.epreuves_sans_coeur_mana(niveau_epreuve))], 27, StyleAzur.CUIVRE))
	elif mode == "grimoire":
		if not (offre["objets"] as Array).is_empty():
			precisions.add_child(StyleAzur.texte("Garantie de ce niveau : objet sous %d victoire(s) complètes maximum." % maxi(1,Recompenses.GARANTIE_APRES_GRANDS_COFFRES-ReglagesJoueur.grands_coffres_rates(chapitre)),27,StyleAzur.ATTENUE))
		precisions.add_child(StyleAzur.texte("Sans objet à la victoire : %.0f %%\nUn objet manquant garanti au plus tard au %de coffre complet du même niveau." % [(1.0 - float(offre["chance_objet"])) * 100.0, Recompenses.GARANTIE_APRES_GRANDS_COFFRES], 27, StyleAzur.ATTENUE))
		var paliers: Array[String] = []
		for coffre: Dictionary in Recompenses.COFFRES:
			var palier := int(coffre["palier"])
			if palier > 0 and palier < Reglages.SALLES_PAR_RUN:
				paliers.append("%d salles terminées : %.1f %%" % [palier, float(coffre["chance_objet"]) * 100.0])
		precisions.add_child(StyleAzur.texte("Même en cas de défaite, le coffre peut donner un bijou manquant :\n" + " · ".join(paliers)
			+ ".\nLes défaites ne font pas avancer le compteur des trois victoires.", 27, StyleAzur.ATTENUE))
	precisions.add_child(StyleAzur.texte("Gains conservés après chaque salle. Les boss améliorent le coffre.\nPassifs et Cœurs de mana : victoire en Épreuve.\nMontants avec vos bonus, hors augments.", 27, StyleAzur.ATTENUE))

var _detail: Control

func _ajouter_carte(col: VBoxContainer, id: String, type: String, chance: float) -> void:
	var d: Dictionary = CatalogueObjets.OBJETS[id] if type == "objet" else Passifs.donnees(id)
	var carte := StyleAzur.bouton("", func(): _ouvrir_detail(id, type))
	carte.name = "Carte_" + id
	carte.custom_minimum_size.y = 204
	var marge := MarginContainer.new()
	marge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	marge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for cote in ["left", "right", "top", "bottom"]:
		marge.add_theme_constant_override("margin_" + cote, 44)
	carte.add_child(marge)
	var ligne := HBoxContainer.new()
	ligne.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ligne.add_theme_constant_override("separation", 22)
	marge.add_child(ligne)
	ligne.add_child(StyleAzur.image(StyleAzur.icone_objet(id), 128) if type == "objet" else StyleAzur.vignette(id, 128))
	var textes := VBoxContainer.new()
	textes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ligne.add_child(textes)
	textes.add_child(StyleAzur.texte("GARANTI" if chance >= 1.0 else "CHANCE D’OBTENTION · %.1f %%" % (chance * 100.0), 22, StyleAzur.CUIVRE))
	textes.add_child(StyleAzur.texte(str(d["nom"]), 32))
	textes.add_child(StyleAzur.texte(_resume_objet(id, 0) if type == "objet" else str(d["description"]), 25, StyleAzur.ATTENUE))
	var consulter := HBoxContainer.new()
	consulter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	consulter.add_theme_constant_override("separation", 8)
	var consulter_texte := StyleAzur.texte("Consulter les pouvoirs", 24, StyleAzur.MAGIE)
	consulter_texte.autowrap_mode = TextServer.AUTOWRAP_OFF
	consulter_texte.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	consulter.add_child(consulter_texte)
	consulter.add_child(StyleAzur.illustration("fleche_droite", 28))
	textes.add_child(consulter)
	marge.minimum_size_changed.connect(func(): carte.custom_minimum_size.y = maxf(204.0, marge.get_combined_minimum_size().y))
	StyleAzur.case_objet(carte)
	col.add_child(carte)

func _resume_objet(id: String, niveau: int) -> String:
	return CatalogueObjets.description_bonus(id, niveau)

func _ouvrir_detail(id: String, type: String) -> void:
	if is_instance_valid(_detail): _detail.queue_free()
	_detail = Control.new()
	_detail.add_user_signal("ferme")
	add_child(_detail)
	_detail.connect("ferme", func(): _detail.queue_free())
	var d: Dictionary = CatalogueObjets.OBJETS[id] if type == "objet" else Passifs.donnees(id)
	var col := StyleAzur.defilement(StyleAzur.page(_detail, str(d["nom"])))
	var presentation := StyleAzur.plaque(col, true)
	presentation.add_child(StyleAzur.image(StyleAzur.icone_objet(id), 240) if type == "objet" else StyleAzur.vignette(id, 240))
	presentation.add_child(StyleAzur.texte("RELIQUE DE L’ATELIER" if type == "objet" else "PASSIF PERMANENT", 24, StyleAzur.CUIVRE))
	StyleAzur.separateur(col)
	if type == "objet":
		col.add_child(StyleAzur.texte("À l’obtention\n" + _resume_objet(id, 0), 30))
		col.add_child(StyleAzur.texte("Forge 10\n" + _resume_objet(id, 10), 30))
		col.add_child(StyleAzur.texte(CatalogueObjets.description_effets(id, 10), 28))
		col.add_child(StyleAzur.texte("Pouvoir spécial au niveau 10.\nForge : Attaque et statistique principale améliorées.", 26, StyleAzur.ATTENUE))
	else:
		col.add_child(StyleAzur.texte(str(d["description"]), 30))
		var rang_max := Passifs.rang_max(id)
		col.add_child(StyleAzur.texte("Rang 1 : %s\nRang %d : %s" % [Passifs.resume_rang(id, 1, ReglagesJoueur.niveau_compte_effectif()), rang_max, Passifs.resume_rang(id, rang_max, ReglagesJoueur.niveau_compte_effectif())], 28))
		col.add_child(StyleAzur.texte("Les doublons améliorent ce passif, jusqu’au rang %d. %s" % [rang_max, Passifs.progression_rang(id)], 26, StyleAzur.ATTENUE))
		col.add_child(StyleAzur.texte("Cœurs de mana : +%d %% aux dégâts acquis par cœur, au maximum %d (+%d %%)." % [roundi(Reglages.COEUR_MANA_BONUS_FINAL * 100.0), Epreuves.nombre(), roundi((Reglages.multiplicateur_coeurs(Epreuves.nombre()) - 1.0) * 100.0)], 26, StyleAzur.ATTENUE))
