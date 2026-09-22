class_name ParcoursTutoriel
extends RefCounted

static func etat() -> String:
	return str(ReglagesJoueur.parcours_tutoriel.get("etat", "nouveau"))

static func actif() -> bool:
	return etat() in ["nouveau", "combat", "accueil"]

static func niveau_a_faire() -> bool:
	return etat() in ["nouveau", "combat"]

static func annexes_ouvertes() -> bool:
	return etat() in ["accueil", "termine", "passe", "ancien"]

static func fait(cle: String) -> bool:
	return bool(ReglagesJoueur.parcours_tutoriel.get(cle, false))

static func noter(cle: String) -> void:
	if not actif() or fait(cle):
		return
	ReglagesJoueur.parcours_tutoriel[cle] = true
	ReglagesJoueur.sauvegarder()

static func commencer() -> void:
	if not niveau_a_faire():
		return
	ReglagesJoueur.parcours_tutoriel["etat"] = "combat"
	if not fait("arme_recue"):
		ReglagesJoueur.projectile_equipe = DonneesTutoriel.ARME
		ReglagesJoueur.parcours_tutoriel["arme_recue"] = true
	ReglagesJoueur.sauvegarder()

static func passer() -> void:
	if not actif():
		return
	ReglagesJoueur.parcours_tutoriel["etat"] = "passe"
	ReglagesJoueur.tutoriel_vu = true
	ReglagesJoueur.sauvegarder()

static func terminer_niveau(victoire: bool) -> Dictionary:
	var gain := 0
	if victoire and niveau_a_faire() and not fait("recompense_recue"):
		gain = DonneesTutoriel.recompense_gouttes()
		# Le marqueur et le solde sont enregistres ensemble ; ni une relance ni
		# les multiplicateurs de butin ne doivent gonfler ce cadeau d'initiation.
		ReglagesJoueur.gouttes += gain
		ReglagesJoueur.parcours_tutoriel["recompense_recue"] = true
		ReglagesJoueur.parcours_tutoriel["etat"] = "accueil"
		ReglagesJoueur.tutoriel_vu = true
		ReglagesJoueur.sauvegarder()
		ReglagesJoueur.maitrise_changee.emit()
	return {"nom": "Coffre d’initiation", "rang": 1 if victoire else 0,
		"gouttes": gain, "xp": 0, "pierres": 0, "objet": "", "sort": "",
		"coeur_mana": false, "cadeaux": []}

static func resultat_annexe(mode: String, sort_obtenu: String) -> void:
	if etat() != "accueil":
		return
	if mode == "mine":
		noter("mine_essayee")
	elif mode == "epreuve_sorts":
		noter("epreuve_essayee")
		if Sorts.ACTIFS.has(sort_obtenu) and ReglagesJoueur.rang_sort(sort_obtenu) > 0:
			if str(ReglagesJoueur.parcours_tutoriel.get("sort_epreuve", "")).is_empty():
				ReglagesJoueur.parcours_tutoriel["sort_epreuve"] = sort_obtenu
				ReglagesJoueur.sauvegarder()

static func sort_a_expliquer() -> String:
	var id := str(ReglagesJoueur.parcours_tutoriel.get("sort_epreuve", ""))
	return id if etat() == "accueil" and Sorts.ACTIFS.has(id) and ReglagesJoueur.rang_sort(id) > 0 else ""

static func prochaine_etape() -> String:
	if niveau_a_faire():
		return "combat"
	if etat() != "accueil":
		return ""
	if not fait("accueil_vu"):
		return "accueil"
	if not sort_a_expliquer().is_empty() and not fait("commandes_vues"):
		return "commandes"
	if not fait("maitrise_achetee") or ReglagesJoueur.specialisation.is_empty():
		return "maitrises"
	if not fait("musique_vue"):
		return "musique"
	if not fait("mine_essayee"):
		return "mine"
	if sort_a_expliquer().is_empty():
		return "epreuve_sorts"
	if not fait("sort_lance"):
		return "sort"
	return "fin"

static func conclure() -> void:
	if prochaine_etape() != "fin":
		return
	ReglagesJoueur.parcours_tutoriel["etat"] = "termine"
	ReglagesJoueur.sauvegarder()
