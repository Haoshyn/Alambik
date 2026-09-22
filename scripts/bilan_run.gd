class_name BilanRun
extends RefCounted

static func offre(victoire: bool) -> Dictionary:
	var resultat := ButinsRun.offre(Jeu.mode_run, Jeu.chapitre, Jeu.salles_terminees.size(), Jeu.boss_vaincus.size(),
		victoire, Jeu.niveau_epreuve, ReglagesJoueur.rangs_sorts, ReglagesJoueur.objets,
		ReglagesJoueur.grands_coffres_rates(Jeu.chapitre), ReglagesJoueur.epreuves_ratees(Jeu.niveau_epreuve),
		ReglagesJoueur.palier_atteint(), maxf(0.0, Reglages.MINE_DUREE - Jeu.temps_mine_restant),
		ReglagesJoueur.coeur_mana_obtenu(Jeu.niveau_epreuve),
		ReglagesJoueur.epreuves_sans_coeur_mana(Jeu.niveau_epreuve))

	if Jeu.mode_run == "grimoire":
		var nombre := 0
		for salle in Jeu.salles_terminees:
			nombre += int(Jeu.elites_par_salle.get(salle, 0))
		var bonus := RangsEnnemis.bonus_gouttes(Jeu.chapitre, nombre)
		resultat["gouttes_min"] = int(resultat["gouttes_min"]) + bonus
		resultat["gouttes_max"] = int(resultat["gouttes_max"]) + bonus
	return resultat

static func multiplicateur_coffre() -> float:
	return ArbreCompetences.multiplicateur_coffre(ReglagesJoueur.rangs_competences_effectifs())

static func gouttes_finales(brut: int, avidite := false) -> int:
	return ReglagesJoueur.gain_gouttes(roundi(float(brut) * multiplicateur_coffre()
		* (Reglages.AVIDITE_GOUTTES_MULT if avidite else 1.0)))

# Lire le solde apres attribution du coffre : un achat devenu possible doit
# rester visible meme si le joueur oublie de consulter les autres onglets.
static func ameliorations_accessibles() -> Dictionary:
	var resultat := {}
	var maitrise: Dictionary = {}
	for id: String in ArbreCompetences.NOEUDS:
		if not ReglagesJoueur.peut_acheter_competence(id):
			continue
		var noeud: Dictionary = ArbreCompetences.NOEUDS[id]
		var combat := str(noeud["categorie"]) != "Utilitaire"
		var cout := ReglagesJoueur.cout_competence(id)
		if maitrise.is_empty() or (combat and not bool(maitrise["combat"])) \
				or (combat == bool(maitrise["combat"]) and cout < int(maitrise["cout"])):
			maitrise = {"id": id, "cout": cout, "combat": combat,
				"rang": ReglagesJoueur.rang_competence(id) + 1}
	if not maitrise.is_empty():
		resultat["maitrise"] = maitrise
	var forge: Dictionary = {}
	var possedes := ReglagesJoueur.objets_disponibles()
	for valeur in ReglagesJoueur.equipements.values():
		var id := str(valeur)
		if not CatalogueObjets.OBJETS.has(id) or id not in possedes:
			continue
		var niveau := ReglagesJoueur.niveau_objet(id)
		var cout := ReglagesJoueur.cout_forge(id)
		if niveau >= Reglages.FORGE_NIVEAU_MAX or cout > ReglagesJoueur.pierres_forge:
			continue
		if forge.is_empty() or cout < int(forge["cout"]):
			forge = {"id": id, "cout": cout, "rang": niveau + 1}
	if not forge.is_empty():
		resultat["forge"] = forge
	return resultat

# Calculer et attribuer une seule fois, meme si le bilan est reaffiche ou touche deux fois.
static func finaliser(victoire: bool, _salle_atteinte: int) -> Dictionary:
	if not Jeu.bilan_run.is_empty(): return Jeu.bilan_run
	if Jeu.mode_run == DonneesTutoriel.MODE:
		Jeu.bilan_run = ParcoursTutoriel.terminer_niveau(victoire)
		return Jeu.bilan_run
	var offre_finale := offre(victoire)
	var bilan := ButinsRun.tirer(offre_finale, Jeu.rng)
	Jeu.bilan_run = bilan
	var dernier_etage := 0
	for numero in Jeu.salles_terminees:
		dernier_etage = maxi(dernier_etage, numero)
	attribuer(bilan, offre_finale, ReglagesJoueur, Jeu.mode_run, Jeu.chapitre,
		Jeu.niveau_epreuve, dernier_etage, victoire, "avidite" in Jeu.inventaire)
	ParcoursTutoriel.resultat_annexe(Jeu.mode_run, str(bilan["sort"]))
	return bilan

# L'avance de developpement utilise exactement l'attribution normale sur un
# profil detache : preparer un apercu ne touche ni la partie ni sa sauvegarde.
static func attribuer(bilan: Dictionary, offre_finale: Dictionary, profil: Node,
		mode: String, chapitre: int, niveau_epreuve: int, dernier_etage: int,
		victoire: bool, avidite := false) -> void:
	var coffre_mult: float = ArbreCompetences.multiplicateur_coffre(profil.rangs_competences_effectifs())
	var brut := roundi(float(bilan["gouttes"]) * coffre_mult
		* (Reglages.AVIDITE_GOUTTES_MULT if avidite else 1.0))
	bilan["gouttes"] = profil.gain_gouttes(brut)
	profil.ajouter_gouttes(brut)
	var xp := int(bilan["xp"])
	bilan["xp"] = profil.gain_experience_compte(xp)
	profil.ajouter_experience_compte(xp)
	bilan["pierres"] = profil.ajouter_pierres_forge(int(bilan["pierres"]))
	if not str(bilan["objet"]).is_empty(): profil.ajouter_objet(str(bilan["objet"]))
	if not str(bilan["sort"]).is_empty(): profil.debloquer_sort(str(bilan["sort"]))
	if mode == "epreuve_sorts" and victoire:
		if not (offre_finale["sorts"] as Array).is_empty():
			profil.enregistrer_coffre_epreuve(niveau_epreuve, not str(bilan["sort"]).is_empty())
		if not profil.coeur_mana_obtenu(niveau_epreuve):
			profil.enregistrer_coeur_mana(niveau_epreuve, bool(bilan["coeur_mana"]))
		profil.niveau_epreuve_debloque = maxi(profil.niveau_epreuve_debloque, mini(Epreuves.nombre(), niveau_epreuve + 1))
	if mode == "grimoire":
		if victoire and not (offre_finale["objets"] as Array).is_empty():
			profil.enregistrer_grand_coffre(chapitre, not str(bilan["objet"]).is_empty())
		profil.enregistrer_resultat(dernier_etage, victoire, chapitre)
	else:
		profil.enregistrer_resultat_annexe(victoire)
	profil.sauvegarder()
