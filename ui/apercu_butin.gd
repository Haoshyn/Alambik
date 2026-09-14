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
		ReglagesJoueur.rangs_sorts, ReglagesJoueur.objets, ReglagesJoueur.grands_coffres_rates(chapitre))
	var titre := str(Chapitres.par_index(chapitre)["nom"]) if mode == "grimoire" else "Épreuve de magie · niveau %d" % niveau_epreuve if mode == "epreuve_sorts" else "La Mine"
	col.add_child(StyleAzur.texte(titre, 36))
	col.add_child(StyleAzur.texte("Coffre d’une aventure terminée", 29, StyleAzur.ATTENUE))
	for cadeau in offre["cadeaux"]:
		col.add_child(StyleAzur.texte("Cadeau de campagne · %s · 100 %%" % Sorts.donnees(str(cadeau))["nom"], 29))
	col.add_child(StyleAzur.texte("%d–%d gouttes\n%d XP de compte" % [BilanRun.gouttes_finales(int(offre["gouttes_min"])), BilanRun.gouttes_finales(int(offre["gouttes_max"])), ReglagesJoueur.gain_experience_compte(int(offre["xp"]))], 32))
	if mode == "mine":
		var pierres := roundi(float(ReglagesJoueur.pierres_mine()) * ArbreCompetences.multiplicateur_pierres(ReglagesJoueur.rangs_competences_effectifs()))
		col.add_child(StyleAzur.texte("%d pierres de forge · 100 %%" % pierres, 30))
	for type in ["objet", "sort"]:
		var candidats: Array = offre[type + "s"]
		if candidats.is_empty(): continue
		var chance := float(offre["chance_" + type])
		for id in candidats:
			var d: Dictionary = Sorts.donnees(str(id)) if type == "sort" else CatalogueObjets.OBJETS[id]
			col.add_child(StyleAzur.texte("%s · %.1f %%" % [d["nom"], chance * 100.0 / float(candidats.size())], 29))
	if mode == "epreuve_sorts":
		col.add_child(StyleAzur.texte("Un sort au maximum. Les sorts au rang maximal sortent du tirage.\nSans sort : %.0f %%" % [(1.0 - float(offre["chance_sort"])) * 100.0], 27, StyleAzur.ATTENUE))
	elif mode == "grimoire":
		col.add_child(StyleAzur.texte("Sans objet : %.0f %%\nUn objet manquant garanti au plus tard au 5e coffre complet, s’il reste un objet à obtenir." % [(1.0 - float(offre["chance_objet"])) * 100.0], 27, StyleAzur.ATTENUE))
	col.add_child(StyleAzur.texte("Chaque salle remplit le coffre ; chaque boss augmente son rang. Abandon ou défaite : les gains des salles terminées restent acquis. Objets et sorts exigent la victoire finale.\nMontants avec vos bonus actuels, hors augmentations de l’aventure. Aucune salle terminée : coffre vide.", 27, StyleAzur.ATTENUE))
