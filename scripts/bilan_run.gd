class_name BilanRun
extends RefCounted

static func offre(victoire: bool) -> Dictionary:
	return ButinsRun.offre(Jeu.mode_run, Jeu.chapitre, Jeu.salles_terminees.size(), Jeu.boss_vaincus.size(),
		victoire, Jeu.niveau_epreuve, ReglagesJoueur.rangs_sorts, ReglagesJoueur.objets,
		ReglagesJoueur.grands_coffres_rates(Jeu.chapitre), ReglagesJoueur.epreuves_ratees(Jeu.niveau_epreuve))

static func multiplicateur_coffre() -> float:
	return ArbreCompetences.multiplicateur_coffre(ReglagesJoueur.rangs_competences_effectifs())

static func gouttes_finales(brut: int, avidite := false) -> int:
	return ReglagesJoueur.gain_gouttes(roundi(float(brut) * multiplicateur_coffre()
		* (Reglages.AVIDITE_GOUTTES_MULT if avidite else 1.0)))

# Calculer et attribuer une seule fois, meme si le bilan est reaffiche ou touche deux fois.
static func finaliser(victoire: bool, _salle_atteinte: int) -> Dictionary:
	if not Jeu.bilan_run.is_empty(): return Jeu.bilan_run
	var offre_finale := offre(victoire)
	var bilan := ButinsRun.tirer(offre_finale, Jeu.rng)
	Jeu.bilan_run = bilan
	var brut := roundi(float(bilan["gouttes"]) * multiplicateur_coffre()
		* (Reglages.AVIDITE_GOUTTES_MULT if "avidite" in Jeu.inventaire else 1.0))
	bilan["gouttes"] = ReglagesJoueur.gain_gouttes(brut)
	ReglagesJoueur.ajouter_gouttes(brut)
	var xp := int(bilan["xp"])
	bilan["xp"] = ReglagesJoueur.gain_experience_compte(xp)
	ReglagesJoueur.ajouter_experience_compte(xp)
	bilan["pierres"] = 0
	if Jeu.mode_run == "mine" and victoire:
		bilan["pierres"] = ReglagesJoueur.ajouter_pierres_forge(ReglagesJoueur.pierres_mine())
	if not str(bilan["objet"]).is_empty(): ReglagesJoueur.ajouter_objet(str(bilan["objet"]))
	if not str(bilan["sort"]).is_empty(): ReglagesJoueur.debloquer_sort(str(bilan["sort"]))
	if Jeu.mode_run == "epreuve_sorts" and victoire:
		if not (offre_finale["sorts"] as Array).is_empty():
			ReglagesJoueur.enregistrer_coffre_epreuve(Jeu.niveau_epreuve, not str(bilan["sort"]).is_empty())
		ReglagesJoueur.niveau_epreuve_debloque = maxi(ReglagesJoueur.niveau_epreuve_debloque, mini(Epreuves.nombre(), Jeu.niveau_epreuve + 1))
	if Jeu.mode_run == "grimoire":
		if victoire and not (offre_finale["objets"] as Array).is_empty(): ReglagesJoueur.enregistrer_grand_coffre(Jeu.chapitre, not str(bilan["objet"]).is_empty())
		var dernier_etage := 0
		for numero in Jeu.salles_terminees: dernier_etage = maxi(dernier_etage, numero)
		ReglagesJoueur.enregistrer_resultat(dernier_etage, victoire, Jeu.chapitre)
	elif not Jeu.est_retro():
		ReglagesJoueur.enregistrer_resultat_annexe(victoire)
	ReglagesJoueur.sauvegarder()
	return bilan
