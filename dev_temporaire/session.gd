extends RefCounted

const PROFIL := preload("res://dev_temporaire/profil.gd")
const DOSSIER := "user://dev_temporaire"
const ORIGINAL := DOSSIER + "/compte_original.cfg"
# Correspondance avec la sauvegarde existante ; aucune nouvelle cle dans alambic.cfg.
const CHAMPS := {
	"victoires": ["resultats", "victoires"],
	"runs": ["resultats", "runs"],
	"meilleures_par_chapitre": ["resultats", "par_chapitre"],
	"chapitre_choisi": ["options", "chapitre_choisi"],
	"gouttes": ["monnaie", "gouttes"],
	"rangs_competences": ["maitrise", "rangs"],
	"version_maitrises": ["maitrise", "version"],
	"tutoriel_vu": ["aide", "premiers_pas"],
	"niveau_compte": ["compte", "niveau"],
	"experience_compte": ["compte", "experience"],
	"attributs": ["compte", "attributs"],
	"specialisation": ["compte", "specialisation"],
	"mode_dev": ["options", "mode_dev"],
	"passifs_equipes": ["passifs", "equipes"],
	"rangs_passifs": ["passifs", "rangs"],
	"objets": ["stuff", "objets"],
	"dernier_objet_obtenu": ["stuff", "dernier"],
	"grands_coffres_sans_objet": ["stuff", "pities"],
	"epreuves_sans_passif": ["epreuves", "pities"],
	"epreuves_sans_coeur": ["epreuves", "pities_coeur"],
	"coeurs_mana": ["epreuves", "coeurs_mana"],
	"equipements": ["stuff", "equipements"],
	"projectile_equipe": ["stuff", "projectile"],
	"familier_equipe": ["stuff", "familier"],
	"forge_niveaux": ["stuff", "forge"],
	"version_forge": ["stuff", "version_forge"],
	"pierres_forge": ["stuff", "pierres_forge"],
	"mode_run_choisi": ["options", "mode_run"],
	"niveau_mine_choisi": ["mine", "choisi"],
	"niveau_epreuve_choisi": ["epreuves", "choisi"],
	"niveau_epreuve_debloque": ["epreuves", "debloque"],
}

static func active() -> bool:
	return FileAccess.file_exists(ORIGINAL)

static func capturer(compte: Node) -> Dictionary:
	var etat := {}
	for champ: String in CHAMPS:
		etat[champ] = compte.get(champ)
	return etat.duplicate(true)

static func appliquer(monde: int) -> String:
	if monde < 1 or monde > Chapitres.MONDES.size() or not ReglagesJoueur.sauvegarde_active:
		return "Ce profil ne peut pas être appliqué."
	var avant := capturer(ReglagesJoueur)
	if active():
		if _original().is_empty():
			return "La copie du compte d’origine est illisible. Aucun changement appliqué."
	else:
		var erreur := DirAccess.make_dir_recursive_absolute(DOSSIER)
		if erreur != OK:
			return "Impossible de protéger le compte d’origine (%s)." % error_string(erreur)
		var copie := ConfigFile.new()
		copie.set_value("temporaire", "compte", avant)
		erreur = copie.save(ORIGINAL + ".nouveau")
		if erreur == OK:
			erreur = DirAccess.rename_absolute(ORIGINAL + ".nouveau", ORIGINAL)
		if erreur != OK:
			return "Impossible de protéger le compte d’origine (%s)." % error_string(erreur)
	var compte := PROFIL.construire(monde, ReglagesJoueur.specialisation)
	var cible := capturer(compte)
	compte.free()
	return _remplacer(cible, avant)

static func restaurer() -> String:
	if not ReglagesJoueur.sauvegarde_active:
		return "La sauvegarde est désactivée."
	var origine := _original()
	if origine.is_empty():
		return "La copie du compte d’origine est absente ou illisible."
	var erreur := _remplacer(origine, capturer(ReglagesJoueur))
	if not erreur.is_empty():
		return erreur
	var suppression := DirAccess.remove_absolute(ORIGINAL)
	if suppression != OK:
		return "Compte restauré ; fermeture du mode dev impossible (%s). Réessayez." % error_string(suppression)
	return ""

static func _original() -> Dictionary:
	var copie := ConfigFile.new()
	if copie.load(ORIGINAL) != OK:
		return {}
	var valeur: Variant = copie.get_value("temporaire", "compte", {})
	if not valeur is Dictionary:
		return {}
	var etat: Dictionary = valeur
	for champ: String in CHAMPS:
		if not etat.has(champ) or typeof(etat[champ]) != typeof(ReglagesJoueur.get(champ)):
			return {}
	return etat

static func _installer(etat: Dictionary) -> void:
	var copie := etat.duplicate(true)
	for champ: String in CHAMPS:
		ReglagesJoueur.set(champ, copie[champ])

static func _remplacer(cible: Dictionary, avant: Dictionary) -> String:
	_installer(cible)
	ReglagesJoueur.sauvegarder()
	# Lire le fichier brut preserve aussi les selections du debug historique,
	# que le chargeur peut normaliser (par exemple un bijou equipe sans drop).
	var controle := ConfigFile.new()
	var conforme := controle.load(ReglagesJoueur.FICHIER) == OK
	if conforme:
		for champ: String in CHAMPS:
			var cle: Array = CHAMPS[champ]
			if controle.get_value(cle[0], cle[1], null) != cible[champ]:
				conforme = false
				break
	if not conforme:
		_installer(avant)
		ReglagesJoueur.sauvegarder()
		return "Écriture du profil impossible. Le compte précédent est conservé et sa copie reste disponible."
	Jeu.nouvelle_tentative.clear()
	Jeu.destination_menu.clear()
	Jeu.bilan_run.clear()
	ReglagesJoueur.maitrise_changee.emit()
	ReglagesJoueur.reglages_changes.emit()
	return ""
