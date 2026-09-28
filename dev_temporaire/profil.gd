extends RefCounted

const COMPTE := preload("res://autoload/reglages_joueur.gd")
# Hypotheses de test, sans modifier les baremes du jeu.
const GRAINE := 20260928
const REPRISES_PAR_MONDE := 2
const MINES_PAR_MONDE := 2
const ESSAIS_PAR_EPREUVE := 3
const PART_EN_RESERVE := 0.20
const ATTRIBUTS := ["vitalite", "force", "vitalite", "force", "agilite", "intelligence", "sagesse"]
const PASSIFS_PREFERES := ["vigueur", "vitalite", "recuperation", "carapace", "moisson_vitale",
	"oeil_precis", "impact_critique", "celerite", "sang_froid", "pas_leger", "projectiles_vifs",
	"soins_renforces", "rempart_initial", "butin_precieux", "savoir_pratique", "audace"]

static func construire(monde: int, classe := Personnage.SPECIALISATION_DEFAUT) -> Node:
	if monde < 1 or monde > Chapitres.MONDES.size():
		return null
	# Ce compte reste hors de l'arbre : ni chargement de user://, ni sauvegarde.
	var compte := COMPTE.new()
	compte.sauvegarde_active = false
	compte.specialisation = Personnage.specialisation_valide(classe)
	compte.tutoriel_vu = true
	var hasard := RandomNumberGenerator.new()
	hasard.seed = GRAINE
	var prochaine_epreuve := 1
	for chapitre in monde * Chapitres.CHAPITRES_PAR_MONDE:
		if chapitre % Chapitres.CHAPITRES_PAR_MONDE == 0:
			# Une tentative arretee a mi-parcours par monde garde ses vraies recompenses.
			_recevoir(compte, hasard, "grimoire", chapitre, 1, false)
		_recevoir(compte, hasard, "grimoire", chapitre)
		while prochaine_epreuve <= compte.niveau_epreuve_accessible():
			for essai in ESSAIS_PAR_EPREUVE:
				_recevoir(compte, hasard, "epreuves", chapitre, prochaine_epreuve)
			prochaine_epreuve += 1
		if (chapitre + 1) % Chapitres.CHAPITRES_PAR_MONDE == 0:
			for reprise in REPRISES_PAR_MONDE:
				_recevoir(compte, hasard, "grimoire", chapitre)
			if compte.mode_debloque("mine"):
				for mine in MINES_PAR_MONDE:
					_recevoir(compte, hasard, "mine", chapitre, compte.niveau_mine_debloque())
	compte.chapitre_choisi = mini(monde * Chapitres.CHAPITRES_PAR_MONDE, Chapitres.nombre() - 1)
	compte.niveau_mine_choisi = maxi(1, compte.niveau_mine_debloque())
	compte.niveau_epreuve_choisi = maxi(1, compte.niveau_epreuve_accessible())
	compte.mode_run_choisi = "grimoire"
	return compte

static func _recevoir(compte: Node, hasard: RandomNumberGenerator, mode: String,
		chapitre: int, niveau := 1, victoire := true) -> void:
	var salles := Chapitres.salles(chapitre)
	var boss := 0
	if mode == "grimoire":
		if not victoire:
			salles = floori(float(salles) * 0.5)
		var donnees: Dictionary = Chapitres.par_index(chapitre)
		for salle: int in donnees["bosses"]:
			if salle <= salles:
				boss += 1
	elif mode == "epreuves":
		var tentative: Node = Jeu.get_script().new()
		tentative.mode_run = mode
		salles = tentative.salles_du_chapitre()
		tentative.free()
		boss = salles
	else:
		salles = 1
		boss = 1
	var offre := ButinsRun.offre(mode, chapitre, salles, boss, victoire, niveau,
		compte.rangs_passifs, compte.objets, compte.grands_coffres_rates(chapitre),
		compte.epreuves_ratees(niveau), Mine.palier(niveau), Reglages.MINE_DUREE,
		compte.coeur_mana_obtenu(niveau), compte.epreuves_sans_coeur_mana(niveau))
	var butin := ButinsRun.tirer(offre, hasard)
	# Memes calculateurs que le bilan, sans bonus d'augments, d'elites ou de soins inutilises.
	var gouttes := roundi(float(butin["gouttes"]) * ArbreCompetences.multiplicateur_coffre(compte.rangs_competences))
	var gain_gouttes: int = compte.gain_gouttes(gouttes)
	compte.ajouter_gouttes(gouttes)
	compte.ajouter_experience_compte(int(butin["xp"]))
	var gain_pierres: int = compte.ajouter_pierres_forge(int(butin["pierres"]))
	compte.set_meta("gouttes_recues", int(compte.get_meta("gouttes_recues", 0)) + gain_gouttes)
	compte.set_meta("pierres_recues", int(compte.get_meta("pierres_recues", 0)) + gain_pierres)
	var objet := str(butin["objet"])
	var passif := str(butin["passif"])
	if not objet.is_empty():
		compte.ajouter_objet(objet)
	if not passif.is_empty():
		compte.debloquer_passif(passif)
	if mode == "grimoire":
		if victoire and not (offre["objets"] as Array).is_empty():
			compte.enregistrer_grand_coffre(chapitre, not objet.is_empty())
		compte.enregistrer_resultat(salles, victoire, chapitre)
	else:
		compte.enregistrer_resultat_annexe(victoire)
	if mode == "epreuves":
		if not (offre["passifs"] as Array).is_empty():
			compte.enregistrer_coffre_epreuve(niveau, not passif.is_empty())
		compte.enregistrer_coeur_mana(niveau, bool(butin["coeur_mana"]))
		compte.niveau_epreuve_debloque = maxi(compte.niveau_epreuve_debloque, mini(Epreuves.nombre(), niveau + 1))
	_developper(compte)

static func _developper(compte: Node) -> void:
	while compte.points_attributs_disponibles() > 0:
		var depenses := Personnage.points_depenses(compte.attributs)
		compte.augmenter_attribut(ATTRIBUTS[depenses % ATTRIBUTS.size()])
	var armes: Array[String] = compte.projectiles_disponibles()
	var familiers: Array[String] = compte.familiers_disponibles()
	compte.equiper_projectile(armes.back())
	compte.equiper_familier(familiers.back())
	compte.passifs_equipes.clear()
	for id: String in PASSIFS_PREFERES:
		if compte.passif_debloque(id) and compte.passifs_equipes.size() < compte.nombre_slots_passifs():
			compte.basculer_passif(id)
	# Acheter les rangs abordables dans les trois branches, sans optimiser le DPS.
	var reserve_gouttes := ceili(float(compte.gouttes) * PART_EN_RESERVE)
	while true:
		var selection := ""
		var prix := int(compte.gouttes) - reserve_gouttes + 1
		for id: String in ArbreCompetences.NOEUDS:
			if compte.peut_acheter_competence(id) and compte.cout_competence(id) < prix:
				selection = id
				prix = compte.cout_competence(id)
		if selection.is_empty():
			break
		compte.acheter_competence(selection)
	var reserve_pierres := ceili(float(compte.pierres_forge) * PART_EN_RESERVE)
	var forges := {str(compte.projectile_equipe): "arme", str(compte.familier_equipe): "familier"}
	for id: String in compte.equipements.values():
		if not id.is_empty():
			forges[id] = "objet"
	while true:
		var selection := ""
		var prix := int(compte.pierres_forge) - reserve_pierres + 1
		for id: String in forges:
			var rang := int(compte.forge_niveaux.get(id, 0))
			if rang < Reglages.FORGE_NIVEAU_MAX and Reglages.cout_forge(rang) < prix:
				selection = id
				prix = Reglages.cout_forge(rang)
		if selection.is_empty():
			break
		compte.call("ameliorer_" + str(forges[selection]), selection)
