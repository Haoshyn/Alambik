class_name ProgressionDeveloppement
extends RefCounted

static func preparer(chapitre_destination: int) -> Dictionary:
	if not ReglagesJoueur.outils_developpement_disponibles() \
			or chapitre_destination < 0 or chapitre_destination >= Chapitres.nombre():
		return {}
	var profil: Node = ReglagesJoueur.get_script().new()
	profil.sauvegarde_active = false
	profil.tutoriel_vu = true
	profil.parcours_tutoriel = {"etat": "termine", "arme_recue": true, "recompense_recue": true}
	profil.gouttes = DonneesTutoriel.recompense_gouttes()
	var alea := RandomNumberGenerator.new()
	alea.seed = AvanceDeveloppement.GRAINE
	var journal: Array[Dictionary] = []
	var prochaine_epreuve := 1
	for palier in range(chapitre_destination + 1):
		# Un niveau d'epreuve est farme une seule fois, au palier de sa courbe.
		# La Mine change a chaque chapitre ouvert, destination comprise.
		while prochaine_epreuve <= Epreuves.nombre() and Epreuves.palier(prochaine_epreuve) <= palier:
			for repetition in AvanceDeveloppement.VICTOIRES_PAR_NIVEAU:
				journal.append(_victoire(profil, "epreuve_sorts", palier, prochaine_epreuve, alea))
			prochaine_epreuve += 1
		for repetition in AvanceDeveloppement.VICTOIRES_PAR_NIVEAU:
			journal.append(_victoire(profil, "mine", palier, 1, alea))
		if palier == chapitre_destination:
			break
		for repetition in AvanceDeveloppement.VICTOIRES_PAR_NIVEAU:
			journal.append(_victoire(profil, "grimoire", palier, 1, alea))
	profil.chapitre_choisi = chapitre_destination
	profil.mode_run_choisi = "grimoire"
	var resultat := {"progression": profil.capturer_progression(), "journal": journal,
		"chapitre": chapitre_destination, "graine": AvanceDeveloppement.GRAINE,
		"campagnes": chapitre_destination * AvanceDeveloppement.VICTOIRES_PAR_NIVEAU,
		"mines": (chapitre_destination + 1) * AvanceDeveloppement.VICTOIRES_PAR_NIVEAU,
		"epreuves": (prochaine_epreuve - 1) * AvanceDeveloppement.VICTOIRES_PAR_NIVEAU}
	profil.free()
	return resultat

static func _victoire(profil: Node, mode: String, palier: int, niveau_epreuve: int,
		alea: RandomNumberGenerator) -> Dictionary:
	var salles := Chapitres.salles(palier) if mode == "grimoire" else (5 if mode == "epreuve_sorts" else 1)
	var boss: int = (Chapitres.par_index(palier)["bosses"] as Array).size() if mode == "grimoire" else salles
	var offre := ButinsRun.offre(mode, palier, salles, boss, true, niveau_epreuve,
		profil.rangs_sorts, profil.objets, profil.grands_coffres_rates(palier),
		profil.epreuves_ratees(niveau_epreuve), palier, Reglages.MINE_DUREE,
		profil.coeur_mana_obtenu(niveau_epreuve), profil.epreuves_sans_coeur_mana(niveau_epreuve))
	var elites := 0
	if mode == "grimoire":
		elites = _elites_campagne(palier, alea.randi())
		var bonus := RangsEnnemis.bonus_gouttes(palier, elites)
		offre["gouttes_min"] = int(offre["gouttes_min"]) + bonus
		offre["gouttes_max"] = int(offre["gouttes_max"]) + bonus
	var bilan := ButinsRun.tirer(offre, alea)
	BilanRun.attribuer(bilan, offre, profil, mode, palier, niveau_epreuve, salles, true)
	return {"mode": mode, "palier": palier, "epreuve": niveau_epreuve, "elites": elites, "bilan": bilan}

static func _elites_campagne(chapitre: int, graine: int) -> int:
	if chapitre < RangsEnnemis.PREMIER_CHAPITRE_ELITES:
		return 0
	var nombre := 0
	for salle in range(1, Chapitres.salles(chapitre) + 1):
		if Chapitres.est_boss(chapitre, salle):
			continue
		var alea := RandomNumberGenerator.new()
		alea.seed = graine + chapitre * 104729 + salle * 7919
		for vague: Array in Vagues.pour_salle(salle, chapitre, graine):
			# Hypothese du profil : chaque vague est nettoyee avant la suivante.
			if not vague.is_empty() and alea.randf() < RangsEnnemis.CHANCE_ELITE_PAR_VAGUE:
				alea.randi_range(0, vague.size() - 1)
				nombre += 1
	return nombre
