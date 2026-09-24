extends Node

# Options et meilleur resultat, gardes en local. Aucun SDK, aucune collecte :
# c'est explicitement hors perimetre de la V1.

const FICHIER := "user://alambic.cfg"
# La structure 5 x 7 conserve les indices lineaires de la version 2 : les
# victoires, le chapitre choisi et les garanties restent au meme rang.
const VERSION_CAMPAGNE := 2

var victoires := 0
var runs := 0
# Une entree par chapitre suffit : les annexes ne doivent jamais ouvrir la
# campagne ni contaminer sa meilleure progression.
var meilleures_par_chapitre := {}
var chapitre_choisi := 0
var gouttes := 0
var rangs_competences := {}
var version_maitrises := Reglages.MAITRISE_VERSION
var remboursement_maitrises := 0
var tutoriel_vu := false
var niveau_compte := 1
var experience_compte := 0
var attributs := {"force": 0, "vitalite": 0, "agilite": 0, "intelligence": 0, "sagesse": 0}
var specialisation := ""
var mode_dev := false
var volume_musique := 1.0
var volume_effets := 1.0
var piste_musique := "first_arcade"
var piste_menu := "accueil"
var secousses_ecran := true
var effets_reduits := false
var vibrations := true
# Comment le Sort actif part : visee manuelle apres l'icone, cible proche apres
# l'icone, ou tape courte sur l'ecran vers la cible proche.
var raccourci_sort := RaccourciTactile.MODE_DEFAUT
var sort_actif_equipe := ""
var ultime_equipe := ""
var passifs_equipes: Array[String] = []
var rangs_sorts := {}
var objets: Array[String] = []
var dernier_objet_obtenu := ""
var grands_coffres_sans_objet := {}
var epreuves_sans_sort := {}
var epreuves_sans_coeur := {}
var coeurs_mana := {}
var equipements := {"anneau": "", "bracelet": "", "collier": ""}
var projectile_equipe := "standard"
var familier_equipe := "homoncule_encre"
# Chaque bijou et chaque arme garde ses niveaux de forge sous son propre ID.
var forge_niveaux := {}
var version_forge := Reglages.FORGE_VERSION
var pierres_forge := 0
var mode_run_choisi := "grimoire"
var niveau_mine_choisi := 1
var niveau_epreuve_choisi := 1
var niveau_epreuve_debloque := 1
var sauvegarde_active := true

signal maitrise_changee
signal reglages_changes

func _ready() -> void:
	charger()
	Sons.appliquer_reglages()

func charger() -> void:
	var config := ConfigFile.new()
	if config.load(FICHIER) != OK:
		return
	victoires = config.get_value("resultats", "victoires", 0)
	runs = config.get_value("resultats", "runs", 0)
	meilleures_par_chapitre = config.get_value("resultats", "par_chapitre", {})
	chapitre_choisi = config.get_value("options", "chapitre_choisi", 0)
	if int(config.get_value("campagne", "version", 1)) < VERSION_CAMPAGNE:
		_migrer_ancienne_campagne()
	# Migration transparente : les anciens points deviennent des gouttes.
	gouttes = int(config.get_value("monnaie", "gouttes", config.get_value("maitrise", "points", 0)))
	rangs_competences = config.get_value("maitrise", "rangs", {})
	version_maitrises = int(config.get_value("maitrise", "version", 1))
	_migrer_maitrises()
	tutoriel_vu = bool(config.get_value("aide", "premiers_pas", false))
	# Les anciennes sauvegardes utilisaient la section "heros" pour ce qui est
	# en realite une progression de compte.
	niveau_compte = maxi(1, int(config.get_value("compte", "niveau",
		config.get_value("heros", "niveau", 1))))
	niveau_compte = clampi(niveau_compte, 1, Personnage.NIVEAU_MAX)
	experience_compte = int(config.get_value("compte", "experience",
		config.get_value("heros", "experience", 0)))
	attributs = config.get_value("compte", "attributs", attributs)
	_normaliser_attributs()
	specialisation = str(config.get_value("compte", "specialisation", ""))
	if not specialisation.is_empty():
		specialisation = Personnage.specialisation_valide(specialisation)
	mode_dev = outils_developpement_disponibles() and bool(config.get_value("options", "mode_dev", false))
	volume_musique = clampf(float(config.get_value("audio", "musique", 1.0)), 0.0, 1.0)
	volume_effets = clampf(float(config.get_value("audio", "effets", 1.0)), 0.0, 1.0)
	piste_musique = Musiques.valider(str(config.get_value("audio", "piste", "first_arcade")))
	piste_menu = Musiques.valider(str(config.get_value("audio", "piste_menu", "accueil")), true)
	secousses_ecran = bool(config.get_value("accessibilite", "secousses", true))
	effets_reduits = bool(config.get_value("accessibilite", "effets_reduits", false))
	vibrations = bool(config.get_value("accessibilite", "vibrations", true))
	raccourci_sort = RaccourciTactile.mode_valide(str(config.get_value("commandes", "raccourci_sort",
		RaccourciTactile.MODE_DEFAUT)))
	sort_actif_equipe = str(config.get_value("sorts", "actif", ""))
	ultime_equipe = str(config.get_value("sorts", "ultime", ""))
	passifs_equipes.clear()
	for id in config.get_value("sorts", "passifs", []):
		var passif := str(id)
		if Sorts.PASSIFS.has(passif) and passifs_equipes.size() < nombre_slots_passifs():
			passifs_equipes.append(passif)
	var anciens_sorts_debloques: Array[String] = []
	for id in config.get_value("sorts", "debloques", []):
		var sort_id := str(id)
		if Sorts.contient(sort_id):
			anciens_sorts_debloques.append(sort_id)
	rangs_sorts = config.get_value("sorts", "rangs", {})
	# Migration : un sort utilisable dans une ancienne sauvegarde devient rang 1.
	for id in anciens_sorts_debloques:
		rangs_sorts[id] = maxi(1, int(rangs_sorts.get(id, 0)))
	objets.clear()
	for id in config.get_value("stuff", "objets", []):
		var objet := str(id)
		if CatalogueObjets.OBJETS.has(objet):
			objets.append(objet)
	dernier_objet_obtenu = str(config.get_value("stuff", "dernier", ""))
	grands_coffres_sans_objet = config.get_value("stuff", "pities", {})
	epreuves_sans_sort = config.get_value("epreuves", "pities", {})
	epreuves_sans_coeur = config.get_value("epreuves", "pities_coeur", {})
	coeurs_mana = config.get_value("epreuves", "coeurs_mana", {})
	equipements = config.get_value("stuff", "equipements", equipements)
	projectile_equipe = str(config.get_value("stuff", "projectile", "standard"))
	familier_equipe = str(config.get_value("stuff", "familier", "homoncule_encre"))
	if not CatalogueFamiliers.contient(familier_equipe): familier_equipe = "homoncule_encre"
	forge_niveaux = config.get_value("stuff", "forge", forge_niveaux)
	version_forge = int(config.get_value("stuff", "version_forge", 1))
	pierres_forge = maxi(0, int(config.get_value("stuff", "pierres_forge", 0)))
	_migrer_equipements()
	_migrer_forge_par_objet()
	_migrer_niveaux_forge()
	niveau_epreuve_debloque = clampi(int(config.get_value("epreuves", "debloque", 1)), 1, Epreuves.nombre())
	niveau_epreuve_choisi = clampi(int(config.get_value("epreuves", "choisi", 1)), 1, niveau_epreuve_debloque)
	# Une ancienne sauvegarde garde la difficulte automatique qu'elle connaissait.
	niveau_mine_choisi = clampi(int(config.get_value("mine", "choisi", maxi(1, niveau_mine_debloque()))),
		1, maxi(1, niveau_mine_debloque()))
	mode_run_choisi = str(config.get_value("options", "mode_run", "grimoire"))
	# Les anciens modes retires reviennent en campagne.
	if mode_run_choisi not in ["grimoire", "epreuve_sorts", "mine"] \
			or not mode_debloque(mode_run_choisi):
		mode_run_choisi = "grimoire"
	_valider_chapitre_choisi()
	# Les anciennes sauvegardes qui avaient deja passe les premiers chapitres
	# recoivent les deux cadeaux de campagne sans devoir les rejouer.
	if _synchroniser_recompenses_campagne():
		sauvegarder()

func sauvegarder() -> void:
	if not sauvegarde_active:
		return
	var config := ConfigFile.new()
	config.set_value("epreuves", "choisi", niveau_epreuve_choisi)
	config.set_value("epreuves", "debloque", niveau_epreuve_debloque)
	config.set_value("mine", "choisi", niveau_mine_choisi)
	config.set_value("resultats", "victoires", victoires)
	config.set_value("resultats", "runs", runs)
	config.set_value("resultats", "par_chapitre", meilleures_par_chapitre)
	config.set_value("options", "chapitre_choisi", chapitre_choisi)
	config.set_value("monnaie", "gouttes", gouttes)
	config.set_value("maitrise", "rangs", rangs_competences)
	config.set_value("maitrise", "version", version_maitrises)
	config.set_value("aide", "premiers_pas", tutoriel_vu)
	config.set_value("compte", "niveau", niveau_compte)
	config.set_value("compte", "experience", experience_compte)
	config.set_value("compte", "attributs", attributs)
	config.set_value("compte", "specialisation", specialisation)
	config.set_value("options", "mode_dev", mode_dev)
	config.set_value("audio", "musique", volume_musique)
	config.set_value("audio", "effets", volume_effets)
	config.set_value("audio", "piste", piste_musique)
	config.set_value("audio", "piste_menu", piste_menu)
	config.set_value("accessibilite", "secousses", secousses_ecran)
	config.set_value("accessibilite", "effets_reduits", effets_reduits)
	config.set_value("accessibilite", "vibrations", vibrations)
	config.set_value("commandes", "raccourci_sort", raccourci_sort)
	config.set_value("sorts", "actif", sort_actif_equipe)
	config.set_value("sorts", "ultime", ultime_equipe)
	config.set_value("sorts", "passifs", passifs_equipes)
	config.set_value("sorts", "rangs", rangs_sorts)
	config.set_value("stuff", "objets", objets)
	config.set_value("stuff", "dernier", dernier_objet_obtenu)
	config.set_value("stuff", "pities", grands_coffres_sans_objet)
	config.set_value("epreuves", "pities", epreuves_sans_sort)
	config.set_value("epreuves", "pities_coeur", epreuves_sans_coeur)
	config.set_value("epreuves", "coeurs_mana", coeurs_mana)
	config.set_value("stuff", "equipements", equipements)
	config.set_value("stuff", "projectile", projectile_equipe)
	config.set_value("stuff", "familier", familier_equipe)
	config.set_value("stuff", "forge", forge_niveaux)
	config.set_value("stuff", "version_forge", version_forge)
	config.set_value("stuff", "pierres_forge", pierres_forge)
	config.set_value("options", "mode_run", mode_run_choisi)
	config.set_value("campagne", "version", VERSION_CAMPAGNE)
	config.save(FICHIER)

func _migrer_maitrises() -> void:
	if version_maitrises >= Reglages.MAITRISE_VERSION: return
	remboursement_maitrises = 0
	if version_maitrises >= 2:
		for id in rangs_competences:
			if not ArbreCompetences.NOEUDS.has(id): continue
			for rang in clampi(int(rangs_competences[id]), 0, ArbreCompetences.rangs(str(id))):
				remboursement_maitrises += ArbreCompetences.cout(str(id), rang)
	else:
		for branche in ArbreCompetences.BRANCHES.values():
			for i in branche.size():
				var id: String = branche[i]
				var plafond := 2 if id in ["distillation","prescience"] else 1 if id == "savoir" else 10
				for rang in clampi(int(rangs_competences.get(id,0)),0,plafond):
					remboursement_maitrises += ArbreCompetences.ancien_cout(i, rang)
	gouttes += remboursement_maitrises
	rangs_competences.clear()
	version_maitrises = Reglages.MAITRISE_VERSION

func _migrer_ancienne_campagne() -> void:
	var anciennes: Dictionary = meilleures_par_chapitre.duplicate()
	var converties := {}
	for cle in anciennes:
		var monde := int(cle)
		var progression := clampi(int(anciennes[cle]), 0, 30)
		for acte in 3:
			var dans_acte := clampi(progression - acte * 10, 0, 10)
			if dans_acte > 0:
				converties[str(monde * 3 + acte)] = mini(Reglages.SALLES_PAR_RUN, dans_acte * 2)
	meilleures_par_chapitre = converties
	chapitre_choisi = clampi(chapitre_choisi * 3, 0, Chapitres.nombre() - 1)

func ajouter_objet(id: String) -> bool:
	if not CatalogueObjets.OBJETS.has(id) or id in objets:
		return false
	objets.append(id)
	dernier_objet_obtenu = id
	_equipement_automatique(id)
	sauvegarder()
	maitrise_changee.emit()
	return true

func _migrer_equipements() -> void:
	# La Bague devient le Bracelet ; les identifiants d'objets et leurs niveaux
	# restent intacts pour ne rien retirer aux anciennes sauvegardes.
	if not equipements.has("anneau"):
		equipements["anneau"] = str(equipements.get("anneau_gauche", ""))
	if not equipements.has("bracelet"):
		equipements["bracelet"] = str(equipements.get("anneau_droit", ""))
	equipements.erase("anneau_gauche")
	equipements.erase("anneau_droit")
	for slot in ["anneau", "bracelet", "collier"]:
		var id := str(equipements.get(slot, ""))
		if not CatalogueObjets.compatible(slot, id) or id not in objets:
			equipements[slot] = ""

func _migrer_forge_par_objet() -> void:
	# Anciennes sauvegardes : le niveau etait stocke sur le slot. On le donne a
	# l'objet actuellement equipe, puis on retire les trois anciennes cles.
	for slot in ["anneau", "bracelet", "collier", "anneau_gauche", "anneau_droit"]:
		if not forge_niveaux.has(slot):
			continue
		var slot_actuel: String = str({"anneau_gauche": "anneau", "anneau_droit": "bracelet"}.get(slot, slot))
		var id := str(equipements.get(slot_actuel, ""))
		if not id.is_empty():
			forge_niveaux[id] = maxi(int(forge_niveaux.get(id, 0)), int(forge_niveaux[slot]))
		forge_niveaux.erase(slot)

func _migrer_niveaux_forge() -> void:
	if version_forge >= Reglages.FORGE_VERSION: return
	if version_forge < 2:
		for id in forge_niveaux.keys():
			var ancien := clampi(int(forge_niveaux[id]), 0, Reglages.FORGE_ANCIEN_NIVEAU_MAX)
			# Arrondir en faveur du joueur preserve aussi un ancien niveau impair.
			forge_niveaux[id] = ceili(float(ancien) / Reglages.FORGE_REGROUPEMENT)
		version_forge = 2
	if version_forge < 3:
		for id in forge_niveaux.keys():
			var ancien := clampi(int(forge_niveaux[id]), 0,
				Reglages.FORGE_NIVEAU_MAX_AVANT_COMPRESSION)
			forge_niveaux[id] = ceili(float(ancien) / Reglages.FORGE_COMPRESSION)
	version_forge = Reglages.FORGE_VERSION

func _equipement_automatique(id: String) -> void:
	for slot in ["anneau", "bracelet", "collier"]:
		if str(equipements.get(slot, "")).is_empty() and CatalogueObjets.compatible(slot, id):
			equipements[slot] = id
			return

func equiper_objet(slot: String, id: String) -> bool:
	if id not in objets_disponibles() or not CatalogueObjets.compatible(slot, id):
		return false
	# Un anneau ne peut pas occuper les deux emplacements simultanement.
	for autre in equipements:
		if autre != slot and equipements[autre] == id:
			equipements[autre] = ""
	equipements[slot] = id
	sauvegarder()
	maitrise_changee.emit()
	return true

func retirer_objet(slot: String) -> bool:
	if slot not in equipements or str(equipements[slot]).is_empty():
		return false
	equipements[slot] = ""
	sauvegarder()
	maitrise_changee.emit()
	return true

func projectiles_disponibles() -> Array[String]:
	return CatalogueProjectiles.disponibles(niveau_campagne_atteint())

func projectile_equipe_effectif() -> String:
	return projectile_equipe if CatalogueProjectiles.debloque(projectile_equipe,
		niveau_campagne_atteint()) else "standard"

func equiper_projectile(id: String) -> bool:
	if not CatalogueProjectiles.debloque(id, niveau_campagne_atteint()):
		return false
	projectile_equipe = id
	sauvegarder()
	maitrise_changee.emit()
	return true

func niveau_arme(id: String) -> int:
	return clampi(int(forge_niveaux.get(id, 0)), 0, Reglages.FORGE_NIVEAU_MAX) \
		if CatalogueProjectiles.contient(id) else 0

func cout_forge_arme(id: String) -> int:
	return Reglages.cout_forge(niveau_arme(id))

func ameliorer_arme(id: String) -> bool:
	if id not in projectiles_disponibles() or niveau_arme(id) >= Reglages.FORGE_NIVEAU_MAX \
			or pierres_forge < cout_forge_arme(id):
		return false
	pierres_forge -= cout_forge_arme(id)
	forge_niveaux[id] = niveau_arme(id) + 1
	sauvegarder()
	maitrise_changee.emit()
	return true

func familiers_disponibles() -> Array[String]:
	return CatalogueFamiliers.disponibles(niveau_campagne_atteint())

func familier_equipe_effectif() -> String:
	return familier_equipe if familier_equipe in familiers_disponibles() else "homoncule_encre"

func equiper_familier(id: String) -> bool:
	if id not in familiers_disponibles():
		return false
	familier_equipe = id
	sauvegarder()
	maitrise_changee.emit()
	return true

func niveau_familier(id: String) -> int:
	return clampi(int(forge_niveaux.get(id, 0)), 0, Reglages.FORGE_NIVEAU_MAX) \
		if CatalogueFamiliers.contient(id) else 0

func ameliorer_familier(id: String) -> bool:
	var niveau := niveau_familier(id)
	var cout := Reglages.cout_forge(niveau)
	if id not in familiers_disponibles() or niveau >= Reglages.FORGE_NIVEAU_MAX or pierres_forge < cout:
		return false
	pierres_forge -= cout
	forge_niveaux[id] = niveau + 1
	sauvegarder()
	maitrise_changee.emit()
	return true

func niveau_objet(id: String) -> int:
	return clampi(int(forge_niveaux.get(id, 0)), 0, Reglages.FORGE_NIVEAU_MAX) \
		if CatalogueObjets.OBJETS.has(id) else 0

func cout_forge(id: String) -> int:
	return Reglages.cout_forge(niveau_objet(id))

func ameliorer_objet(id: String) -> bool:
	if id not in objets_disponibles() or niveau_objet(id) >= Reglages.FORGE_NIVEAU_MAX \
			or pierres_forge < cout_forge(id):
		return false
	pierres_forge -= cout_forge(id)
	forge_niveaux[id] = niveau_objet(id) + 1
	sauvegarder()
	maitrise_changee.emit()
	return true

func ajouter_pierres_forge(nombre: int) -> int:
	if nombre <= 0:
		return 0
	var gain := maxi(1, roundi(float(nombre) \
		* ArbreCompetences.multiplicateur_pierres(rangs_competences_effectifs())))
	pierres_forge += gain
	sauvegarder()
	maitrise_changee.emit()
	return gain

func grands_coffres_rates(chapitre: int) -> int:
	return maxi(0,int(grands_coffres_sans_objet.get(str(chapitre), 0)))

func enregistrer_grand_coffre(chapitre: int, objet_obtenu: bool) -> void:
	var cle := str(chapitre)
	grands_coffres_sans_objet[cle] = 0 if objet_obtenu else mini(Recompenses.GARANTIE_APRES_GRANDS_COFFRES-1,grands_coffres_rates(chapitre) + 1)
	sauvegarder()

func epreuves_ratees(niveau: int) -> int:
	return maxi(0,int(epreuves_sans_sort.get(str(niveau),0)))

func enregistrer_coffre_epreuve(niveau: int, sort_obtenu: bool) -> void:
	epreuves_sans_sort[str(niveau)] = 0 if sort_obtenu else mini(Reglages.EPREUVE_GARANTIE_CAPACITE-1,epreuves_ratees(niveau)+1)
	sauvegarder()

func coeur_mana_obtenu(niveau: int) -> bool:
	return bool(coeurs_mana.get(str(niveau), false))

func epreuves_sans_coeur_mana(niveau: int) -> int:
	return maxi(0, int(epreuves_sans_coeur.get(str(niveau), 0)))

func enregistrer_coeur_mana(niveau: int, obtenu: bool) -> void:
	var cle := str(niveau)
	if coeur_mana_obtenu(niveau):
		return
	if obtenu:
		coeurs_mana[cle] = true
		epreuves_sans_coeur[cle] = 0
	else:
		epreuves_sans_coeur[cle] = mini(Reglages.EPREUVE_GARANTIE_COEUR - 1,
			epreuves_sans_coeur_mana(niveau) + 1)
	sauvegarder()

func nombre_coeurs_mana() -> int:
	var total := 0
	for niveau in coeurs_mana:
		if bool(coeurs_mana[niveau]):
			total += 1
	return total

func multiplicateur_coeurs_mana() -> float:
	return 1.0 + float(nombre_coeurs_mana()) * Reglages.COEUR_MANA_BONUS_FINAL

func definir_reglages_audio(musique: float, effets: float) -> void:
	volume_musique = clampf(musique, 0.0, 1.0)
	volume_effets = clampf(effets, 0.0, 1.0)
	Sons.appliquer_reglages()
	sauvegarder()
	reglages_changes.emit()

func definir_piste_musique(id: String) -> void:
	if not Musiques.contient(id) or id == piste_musique:
		return
	piste_musique = id
	Sons.appliquer_reglages()
	sauvegarder()
	reglages_changes.emit()

func definir_piste_menu(id: String) -> void:
	if not Musiques.contient(id, true) or id == piste_menu:
		return
	piste_menu = id
	Sons.appliquer_reglages()
	sauvegarder()
	reglages_changes.emit()

func definir_raccourci_sort(mode: String) -> void:
	var demande := RaccourciTactile.mode_valide(mode)
	if demande == raccourci_sort:
		return
	raccourci_sort = demande
	sauvegarder()
	reglages_changes.emit()

func definir_accessibilite(secousses: bool, reduire_effets: bool) -> void:
	secousses_ecran = secousses
	effets_reduits = reduire_effets
	sauvegarder()
	reglages_changes.emit()

func definir_vibrations(actives: bool) -> void:
	if vibrations == actives:
		return
	vibrations = actives
	sauvegarder()
	reglages_changes.emit()

func ajouter_gouttes(nombre: int) -> void:
	if mode_dev:
		return
	if nombre <= 0:
		return
	gouttes += gain_gouttes(nombre)
	sauvegarder()
	maitrise_changee.emit()

func experience_compte_requise() -> int:
	if niveau_compte >= Personnage.NIVEAU_MAX:
		return 0
	var profondeur := maxi(0, niveau_compte - 1)
	return maxi(1, roundi(Reglages.XP_COMPTE_BASE \
		+ float(profondeur) * Reglages.XP_COMPTE_PENTE \
		+ float(profondeur * profondeur) * Reglages.XP_COMPTE_QUADRATIQUE))

func ajouter_experience_compte(nombre: int) -> void:
	if nombre <= 0 or niveau_compte >= Personnage.NIVEAU_MAX:
		return
	var gain := gain_experience_compte(nombre)
	experience_compte += maxi(1, gain)
	while niveau_compte < Personnage.NIVEAU_MAX and experience_compte >= experience_compte_requise():
		var requis := experience_compte_requise()
		experience_compte -= requis
		niveau_compte += 1
	if niveau_compte >= Personnage.NIVEAU_MAX:
		experience_compte = 0
	sauvegarder()
	maitrise_changee.emit()

func niveau_compte_effectif() -> int:
	return clampi(niveau_compte, 1, Personnage.NIVEAU_MAX)

func _normaliser_attributs() -> void:
	var propres := {}
	for id in Personnage.ATTRIBUTS:
		propres[id] = maxi(0, int(attributs.get(id, 0)))
	attributs = propres
	var excedent := Personnage.points_depenses(attributs) - Personnage.points_totaux(niveau_compte_effectif())
	if excedent <= 0:
		return
	# Une sauvegarde corrompue perd d'abord les derniers attributs de la liste,
	# sans jamais produire de points negatifs.
	for id in ["sagesse", "intelligence", "agilite", "vitalite", "force"]:
		var retrait := mini(excedent, int(attributs[id]))
		attributs[id] = int(attributs[id]) - retrait
		excedent -= retrait
		if excedent <= 0:
			break

func points_attributs_disponibles() -> int:
	return maxi(0, Personnage.points_totaux(niveau_compte_effectif()) \
		- Personnage.points_depenses(attributs))

func rang_attribut(id: String) -> int:
	return maxi(0, int(attributs.get(id, 0))) if Personnage.ATTRIBUTS.has(id) else 0

func augmenter_attribut(id: String) -> bool:
	if not Personnage.ATTRIBUTS.has(id) or points_attributs_disponibles() <= 0:
		return false
	attributs[id] = rang_attribut(id) + 1
	sauvegarder()
	maitrise_changee.emit()
	return true

func diminuer_attribut(id: String) -> bool:
	if not Personnage.ATTRIBUTS.has(id) or rang_attribut(id) <= 0:
		return false
	attributs[id] = rang_attribut(id) - 1
	sauvegarder()
	maitrise_changee.emit()
	return true

func reinitialiser_attributs() -> void:
	for id in Personnage.ATTRIBUTS:
		attributs[id] = 0
	sauvegarder()
	maitrise_changee.emit()

func bonus_attributs() -> Dictionary:
	return Personnage.bonus(attributs)

func specialisation_effective() -> String:
	return specialisation if Personnage.SPECIALISATIONS.has(specialisation) else ""

func choisir_specialisation(id: String) -> bool:
	if not Personnage.SPECIALISATIONS.has(id) or id == specialisation:
		return false
	specialisation = id
	sauvegarder()
	maitrise_changee.emit()
	return true

func titre_compte() -> String:
	return "COMPTE"

func rang_competence(id: String) -> int:
	if not ArbreCompetences.NOEUDS.has(id):
		return 0
	return ArbreCompetences.rangs(id) if mode_dev \
		else clampi(int(rangs_competences.get(id, 0)), 0, ArbreCompetences.rangs(id))

func gouttes_affichees() -> String:
	return "∞" if mode_dev else str(gouttes)

func rangs_competences_effectifs() -> Dictionary:
	if mode_dev:
		var tous_les_rangs := {}
		for id in ArbreCompetences.NOEUDS:
			tous_les_rangs[id] = ArbreCompetences.rangs(id)
		return tous_les_rangs
	return rangs_competences

func objets_disponibles() -> Array[String]:
	if not mode_dev:
		return objets
	var tous: Array[String] = []
	for id in CatalogueObjets.OBJETS:
		tous.append(id)
	return tous

func bonus_objets_effectifs() -> Dictionary:
	var bonus := CatalogueObjets.bonus_effectifs(equipements, forge_niveaux, monde_equipement_atteint())
	var arme := projectile_equipe_effectif()
	bonus["attaque_base"] = float(bonus.get("attaque_base", 0.0)) \
		+ CatalogueProjectiles.attaque_base(arme, niveau_arme(arme))
	var bonus_arme := CatalogueProjectiles.bonus_heros(arme)
	for champ in bonus_arme:
		bonus[champ] = float(bonus.get(champ, 0.0)) + float(bonus_arme[champ])
	var bonus_familier: Dictionary = CatalogueFamiliers.bonus_heros(familier_equipe_effectif())
	for champ in bonus_familier:
		bonus[champ] = float(bonus.get(champ, 0.0)) \
			+ float(bonus_familier[champ])
	return bonus

func passifs_equipes_effectifs() -> Dictionary:
	var resultat := {}
	for id in passifs_equipes:
		if Sorts.PASSIFS.has(id) and sort_debloque(id):
			resultat[id] = rang_sort(id)
	return resultat

func effets_objets_effectifs() -> Array[String]:
	return CatalogueObjets.effets_equipes(equipements, forge_niveaux)

func cout_competence(id: String) -> int:
	return ArbreCompetences.cout(id, rang_competence(id))

func peut_acheter_competence(id: String) -> bool:
	if not ArbreCompetences.NOEUDS.has(id):
		return false
	return rang_competence(id) < ArbreCompetences.rangs(id) \
		and (mode_dev or ArbreCompetences.prerequis_atteint(id, rangs_competences)) \
		and (mode_dev or gouttes >= cout_competence(id))

func acheter_competence(id: String) -> bool:
	if not peut_acheter_competence(id):
		return false
	if not mode_dev:
		gouttes -= cout_competence(id)
	rangs_competences[id] = rang_competence(id) + 1
	sauvegarder()
	maitrise_changee.emit()
	return true

func equiper_sort(id: String, type: String) -> void:
	if not sort_debloque(id):
		return
	if type == "actif" and Sorts.ACTIFS.has(id):
		sort_actif_equipe = id
	elif type == "ultime" and Sorts.ULTIMES.has(id):
		ultime_equipe = id
	sauvegarder()
	maitrise_changee.emit()

func retirer_sort(type: String) -> bool:
	if type == "actif" and not sort_actif_equipe.is_empty():
		sort_actif_equipe = ""
	elif type == "ultime" and not ultime_equipe.is_empty():
		ultime_equipe = ""
	else:
		return false
	sauvegarder()
	maitrise_changee.emit()
	return true

func basculer_passif(id: String) -> String:
	if not Sorts.PASSIFS.has(id) or not sort_debloque(id):
		return "verrouille"
	if id in passifs_equipes:
		passifs_equipes.erase(id)
		sauvegarder()
		maitrise_changee.emit()
		return "retire"
	if passifs_equipes.size() >= nombre_slots_passifs():
		return "plein"
	passifs_equipes.append(id)
	sauvegarder()
	maitrise_changee.emit()
	return "equipe"

func nombre_slots_passifs() -> int:
	return 2 if ArbreCompetences.donne_second_passif(rangs_competences_effectifs()) else 1

func sort_actif_effectif() -> String:
	return sort_actif_equipe if sort_debloque(sort_actif_equipe) else ""

func ultime_effectif() -> String:
	return ultime_equipe if sort_debloque(ultime_equipe) else ""

func sort_debloque(id: String) -> bool:
	return Sorts.contient(id) and (mode_dev or rang_sort(id) > 0)

func nombre_capacites_debloquees() -> int:
	return Sorts.nombre_capacites_debloquees(rangs_sorts, mode_dev)

func multiplicateur_degats_deblocages() -> float:
	return 1.0

func sort_decouvert(id: String) -> bool:
	return Sorts.contient(id) and (mode_dev or rang_sort(id) > 0 \
		or Epreuves.niveau_pour(id) <= niveau_epreuve_debloque)

func rang_sort(id: String) -> int:
	return Sorts.rang_max(id) if mode_dev and Sorts.contient(id) \
		else clampi(int(rangs_sorts.get(id, 0)), 0, Sorts.rang_max(id))

func efficacite_sort(id: String) -> float:
	var rang := rang_sort(id)
	if Sorts.PASSIFS.has(id):
		return float(rang)
	return 0.0 if rang <= 0 else 1.0 + float(rang - 1) * Reglages.CAPACITE_BONUS_PAR_RANG

func debloquer_sort(id: String) -> bool:
	if not Sorts.contient(id) or not sort_decouvert(id) or rang_sort(id) >= Sorts.rang_max(id):
		return false
	rangs_sorts[id] = rang_sort(id) + 1
	sauvegarder()
	maitrise_changee.emit()
	return true

func reinitialiser_arbre() -> int:
	var rembourses := 0
	for id in rangs_competences:
		if not ArbreCompetences.NOEUDS.has(id):
			continue
		for rang in int(rangs_competences[id]):
			rembourses += ArbreCompetences.cout(id, rang)
	gouttes += rembourses
	rangs_competences.clear()
	sauvegarder()
	maitrise_changee.emit()
	return rembourses

func outils_developpement_disponibles() -> bool:
	return OS.is_debug_build()

func _valider_chapitre_choisi() -> void:
	chapitre_choisi = clampi(chapitre_choisi, 0, Chapitres.nombre() - 1)
	if not chapitre_debloque(chapitre_choisi):
		chapitre_choisi = niveau_campagne_atteint() - 1

func definir_mode_dev(actif: bool) -> void:
	# Une sauvegarde de travail ne doit pas activer les avantages de debug
	# quand elle est ouverte par une version destinee aux joueurs.
	mode_dev = actif and outils_developpement_disponibles()
	if not mode_dev:
		# Un objet seulement equipe pour un test ne doit pas devenir un vrai drop.
		_migrer_equipements()
		_valider_chapitre_choisi()
		if not mode_debloque(mode_run_choisi):
			mode_run_choisi = "grimoire"
		niveau_epreuve_choisi = clampi(niveau_epreuve_choisi, 1, niveau_epreuve_debloque)
	sauvegarder()
	maitrise_changee.emit()
	reglages_changes.emit()

func reinitialiser_progression() -> void:
	tutoriel_vu = false
	niveau_epreuve_choisi = 1
	niveau_epreuve_debloque = 1
	victoires = 0
	runs = 0
	meilleures_par_chapitre.clear()
	chapitre_choisi = 0
	gouttes = 0
	rangs_competences.clear()
	niveau_compte = 1
	experience_compte = 0
	attributs = {"force": 0, "vitalite": 0, "agilite": 0, "intelligence": 0, "sagesse": 0}
	specialisation = ""
	sort_actif_equipe = ""
	ultime_equipe = ""
	passifs_equipes.clear()
	rangs_sorts.clear()
	objets.clear()
	dernier_objet_obtenu = ""
	grands_coffres_sans_objet.clear()
	epreuves_sans_sort.clear()
	epreuves_sans_coeur.clear()
	coeurs_mana.clear()
	equipements = {"anneau": "", "bracelet": "", "collier": ""}
	projectile_equipe = "standard"
	familier_equipe = "homoncule_encre"
	forge_niveaux = {}
	pierres_forge = 0
	mode_run_choisi = "grimoire"
	sauvegarder()
	maitrise_changee.emit()
	reglages_changes.emit()

func enregistrer_resultat(salle: int, victoire: bool, chapitre := 0) -> void:
	runs += 1
	if victoire:
		victoires += 1
	var cle := str(chapitre)
	if salle > int(meilleures_par_chapitre.get(cle, 0)):
		meilleures_par_chapitre[cle] = salle
	var capacite_offerte := _synchroniser_recompenses_campagne()
	sauvegarder()
	if capacite_offerte:
		maitrise_changee.emit()

func _synchroniser_recompenses_campagne() -> bool:
	var change := false
	var niveau := niveau_campagne_atteint()
	for cle_niveau in Sorts.RECOMPENSES_CAMPAGNE:
		if niveau < int(cle_niveau):
			continue
		var id := Sorts.recompense_campagne(int(cle_niveau))
		if id.is_empty() or rang_sort(id) > 0:
			continue
		rangs_sorts[id] = 1
		if Sorts.ACTIFS.has(id) and sort_actif_equipe.is_empty():
			sort_actif_equipe = id
		elif Sorts.ULTIMES.has(id) and ultime_equipe.is_empty():
			ultime_equipe = id
		change = true
	return change

func enregistrer_resultat_annexe(victoire: bool) -> void:
	runs += 1
	if victoire:
		victoires += 1
	sauvegarder()

func meilleure_du_chapitre(chapitre: int) -> int:
	return int(meilleures_par_chapitre.get(str(chapitre), 0))

# Le niveau de campagne est le chapitre actuellement ouvert, de 1 a 35. Une
# simple tentative ne monte donc plus artificiellement les annexes : il faut
# terminer le chapitre precedent pour faire avancer leur palier.
func niveau_campagne_atteint() -> int:
	if mode_dev:
		return Chapitres.nombre()
	var dernier_debloque := 0
	for chapitre in range(1, Chapitres.nombre()):
		if not chapitre_debloque(chapitre):
			break
		dernier_debloque = chapitre
	return dernier_debloque + 1

func palier_atteint() -> int:
	return niveau_campagne_atteint() - 1

func niveau_mine_debloque() -> int:
	return clampi(niveau_campagne_atteint() - Reglages.MINE_NIVEAU_DEBLOCAGE + 1, 0, Mine.nombre())

func choisir_mine(niveau: int) -> bool:
	if not mode_debloque("mine") or niveau < 1 or niveau > niveau_mine_debloque():
		return false
	niveau_mine_choisi = niveau
	choisir_mode_run("mine")
	return true

func mode_debloque(mode: String) -> bool:
	if mode_dev or mode == "grimoire":
		return true
	if mode == "epreuve_sorts":
		return niveau_campagne_atteint() >= Reglages.EPREUVE_NIVEAU_DEBLOCAGE
	if mode == "mine":
		return niveau_campagne_atteint() >= Reglages.MINE_NIVEAU_DEBLOCAGE
	return false

# Les objets deja trouves rattrapent le Monde le plus avance actuellement
# accessible. Terminer le dernier chapitre d'un Monde suffit donc a faire monter son
# ancien equipement avant meme la premiere tentative du Monde suivant.
func monde_equipement_atteint() -> int:
	if mode_dev:
		return Chapitres.MONDES.size() - 1
	var dernier_debloque := 0
	for chapitre in Chapitres.nombre():
		if not chapitre_debloque(chapitre):
			break
		dernier_debloque = chapitre
	return int(Chapitres.par_index(dernier_debloque)["monde"])

func pierres_mine() -> int:
	return Reglages.pierres_mine(Mine.palier(niveau_mine_choisi))

# Un chapitre s'ouvre quand le precedent a ete termine. Le premier est toujours
# ouvert : personne ne doit rester devant une porte close au premier lancement.
func chapitre_debloque(chapitre: int) -> bool:
	if mode_dev:
		return true
	if chapitre <= 0:
		return true
	var precedent := Chapitres.par_index(chapitre - 1)
	return meilleure_du_chapitre(chapitre - 1) >= int(precedent["salles"])

func choisir_chapitre(chapitre: int) -> void:
	chapitre_choisi = clampi(chapitre, 0, Chapitres.nombre() - 1)
	sauvegarder()

func choisir_mode_run(mode: String) -> void:
	if mode not in ["grimoire", "epreuve_sorts", "mine"] or not mode_debloque(mode):
		return
	mode_run_choisi = mode
	sauvegarder()

func recharge_sort(id: String, mods_liste: Array = []) -> float:
	var base := float(Sorts.donnees(id).get("recharge", 0.0))
	var intelligence := float(bonus_attributs().get("recuperation_sorts", 0.0))
	var recharge := Sorts.recharge(id, passifs_equipes_effectifs(), rangs_competences_effectifs(),
		projectile_equipe_effectif(), Mods.facteur_heros(mods_liste, "recharge_sorts_mult"))
	recharge *= maxf(0.05, 1.0 - intelligence) \
		* Personnage.multiplicateur_recharge(specialisation_effective())
	return maxf(base * Reglages.RECHARGE_PLANCHER, recharge)

func choisir_epreuve(niveau: int) -> bool:
	if not mode_debloque("epreuve_sorts") or niveau < 1 or niveau > (Epreuves.nombre() if mode_dev else niveau_epreuve_debloque): return false
	niveau_epreuve_choisi = niveau
	choisir_mode_run("epreuve_sorts")
	return true

func gain_gouttes(nombre: int) -> int:
	if nombre <= 0: return 0
	var bonus_butin := float(bonus_attributs().get("butin", 0.0)) \
		+ float(bonus_objets_effectifs().get("butin", 0.0))
	return maxi(1, roundi(float(nombre) * ArbreCompetences.multiplicateur_collecte(
		rangs_competences_effectifs()) * (1.0 + bonus_butin)))

func gain_experience_compte(nombre: int) -> int:
	if nombre <= 0 or niveau_compte >= Personnage.NIVEAU_MAX:
		return 0
	return maxi(1, roundi(float(nombre) * ArbreCompetences.multiplicateur_experience(
		rangs_competences_effectifs())))
