extends Node

# Etat de la run : les salles terminees remplissent le coffre, y compris
# lorsque la tentative se termine par une mort ou un abandon.

signal run_terminee(victoire: bool)
signal inventaire_change
signal experience_run_change

var niveau_epreuve := 1
var salles_terminees: Array[int] = []
var boss_vaincus: Array[int] = []
var bilan_run: Dictionary = {}
var destination_menu: Dictionary = {}
var nouvelle_tentative: Dictionary = {}
var salle_courante := 0
var chapitre := 0
var inventaire: Array[String] = []
var experience_run := 0
var niveau_run := 0
var niveaux_rares: Array[int] = []
var etage_legendaire := 0
var _relances_utilisees := 0
var rerolls_restants := 0:
	set(valeur):
		# Une source ajoutee pendant la run ne peut pas restituer les relances depensees.
		rerolls_restants = clampi(valeur, 0, maxi(0, Reglages.RELANCES_MAX_PAR_RUN - _relances_utilisees))
var mode_run := "grimoire"
var rng := RandomNumberGenerator.new()
var graine := 0
var mode_auto := false          # le bot headless pilote la run
var ennemis_abattus := 0
var elites_par_salle := {}
var temps_mine_restant := 0.0
# Compteurs de diagnostic : sans eux, un blocage ne dit pas si le heros tirait
# dans le vide, dans un mur, ou pas du tout.
var tirs_emis := 0
var tirs_touches := 0
var tirs_dans_un_mur := 0
var tirs_perdus := 0
var debut_run := 0.0
# Temps de jeu, compte en images : en headless le temps reel est compresse, et
# c'est la duree qu'un joueur passerait manette en main qui nous interesse.
var images_de_jeu := 0

func chapitre_courant() -> Dictionary:
	return Chapitres.par_index(chapitre)

func salles_du_chapitre() -> int:
	if mode_run == "epreuve_sorts":
		return 5
	if mode_run == "mine":
		return 1
	return int(chapitre_courant()["salles"])

func nom_run() -> String:
	if mode_run == "epreuve_sorts":
		return "Épreuve de magie · niveau %d" % niveau_epreuve
	if mode_run == "mine":
		return "Mine"
	return str(chapitre_courant()["nom"])

func est_boss_courant() -> bool:
	if mode_run == "epreuve_sorts":
		return true
	if mode_run == "mine":
		return get_tree().get_first_node_in_group("boss") != null
	return Chapitres.est_boss(chapitre, salle_courante)

func preparer_nouvelle_tentative() -> void:
	nouvelle_tentative = {"mode": mode_run, "chapitre": chapitre, "epreuve": niveau_epreuve}

func demarrer_run(graine_demandee: int = 0, salle_de_depart: int = 1, chapitre_demande := 0,
		mode_demande := "grimoire") -> void:
	var epreuve_demandee := ReglagesJoueur.niveau_epreuve_choisi
	if not nouvelle_tentative.is_empty():
		# Rejouer conserve la destination, mais jamais la salle, le tirage ou le bilan.
		mode_demande = str(nouvelle_tentative["mode"])
		chapitre_demande = int(nouvelle_tentative["chapitre"])
		epreuve_demandee = int(nouvelle_tentative["epreuve"])
		graine_demandee = 0
		salle_de_depart = 1
		nouvelle_tentative.clear()
	# Une graine explicite rend une run rejouable : c'est ce qui permet au bot
	# headless de reproduire un blocage au lieu de le raconter.
	graine = graine_demandee if graine_demandee != 0 else randi()
	rng = RandomNumberGenerator.new()
	rng.seed = graine
	mode_run = mode_demande if mode_demande in ["grimoire", "epreuve_sorts", "mine"] else "grimoire"
	# Le defi a sa propre courbe : il ne depend jamais du dernier livre consulte.
	chapitre = 0 if mode_run != "grimoire" else clampi(chapitre_demande, 0, Chapitres.nombre() - 1)
	niveau_epreuve = clampi(epreuve_demandee, 1, Epreuves.nombre())
	salles_terminees.clear()
	boss_vaincus.clear()
	bilan_run.clear()
	salle_courante = salle_de_depart
	inventaire = []
	experience_run = 0
	niveau_run = 0
	niveaux_rares = ProgressionAugments.tirer_niveaux_rares(rng) if mode_run == "grimoire" else []
	# Fixer le palier avant toute offre empeche une relance de changer sa rarete.
	etage_legendaire = ProgressionAugments.tirer_etage_legendaire(rng) if mode_run == "grimoire" else 0
	_relances_utilisees = 0
	rerolls_restants = ArbreCompetences.nombre_rerolls(ReglagesJoueur.rangs_competences_effectifs())
	_ajouter_heritage_reactif()
	ennemis_abattus = 0
	elites_par_salle.clear()
	temps_mine_restant = Reglages.MINE_DUREE if mode_run == "mine" else 0.0
	tirs_emis = 0
	tirs_touches = 0
	tirs_dans_un_mur = 0
	tirs_perdus = 0
	debut_run = Time.get_ticks_msec() / 1000.0
	images_de_jeu = 0

func _ajouter_heritage_reactif() -> void:
	var nombre := Sorts.augments_heritage(ReglagesJoueur.passifs_equipes_effectifs())
	if nombre <= 0:
		return
	var rares: Array[String] = []
	for id in CatalogueReactifs.ids():
		var reactif := CatalogueReactifs.par_id(id)
		if reactif != null and reactif.rarete == Reactif.RARE:
			rares.append(id)
	for i in mini(nombre, rares.size()):
		var index := rng.randi_range(0, rares.size() - 1)
		inventaire.append(rares[index])
		rares.remove_at(index)

func consommer_relance(rarete: String) -> bool:
	if not ProgressionAugments.relance_autorisee(rarete) or rerolls_restants <= 0:
		return false
	rerolls_restants -= 1
	_relances_utilisees += 1
	return true

func ajouter_reactif(id: String) -> void:
	inventaire.append(id)
	inventaire_change.emit()

func seuils_experience_run() -> Array:
	return ProgressionAugments.XP_SEUILS if mode_run == "grimoire" else Reglages.XP_RUN_SEUILS

func gagner_experience_run(nombre: int) -> int:
	var seuils := seuils_experience_run()
	if niveau_run >= seuils.size() or nombre <= 0:
		return 0
	var multiplicateur := Reglages.AVIDITE_XP_MULT if "avidite" in inventaire else 1.0
	experience_run += maxi(1, roundi(float(nombre) * multiplicateur))
	var plafond := ProgressionAugments.plafond_salle(salle_courante, salles_du_chapitre()) \
		if mode_run == "grimoire" else seuils.size()
	return _monter_niveaux_run(plafond)

func garantir_niveaux_fin_salle() -> int:
	if mode_run != "grimoire":
		return 0
	var cible := ProgressionAugments.plafond_salle(salle_courante, salles_du_chapitre())
	if cible <= niveau_run:
		return 0
	var seuils := seuils_experience_run()
	experience_run = maxi(experience_run, int(seuils[cible - 1]))
	return _monter_niveaux_run(cible)

func _monter_niveaux_run(plafond: int) -> int:
	var seuils := seuils_experience_run()
	var niveaux_gagnes := 0
	while niveau_run < mini(plafond, seuils.size()) \
			and experience_run >= int(seuils[niveau_run]):
		niveau_run += 1
		niveaux_gagnes += 1
	experience_run_change.emit()
	return niveaux_gagnes

func experience_vers_prochain_niveau() -> Dictionary:
	var seuils := seuils_experience_run()
	if niveau_run >= seuils.size():
		return {"actuelle": 1, "requise": 1}
	var precedente := 0 if niveau_run == 0 else int(seuils[niveau_run - 1])
	var requise := int(seuils[niveau_run]) - precedente
	return {"actuelle": clampi(experience_run - precedente, 0, requise),
		"requise": requise}

func copies(id: String) -> int:
	return DraftLogique.copies(inventaire, id)

# L'inventaire garde ses doublons — c'est ce qui empile les reactifs — mais
# l'affichage, lui, doit montrer une pastille par reactif avec son compte.
func inventaire_groupe() -> Array:
	var ordre: Array[String] = []
	var comptes := {}
	for id in inventaire:
		if not id in ordre:
			ordre.append(id)
			comptes[id] = 0
		comptes[id] += 1
	var resultat: Array = []
	for id in ordre:
		resultat.append([id, comptes[id]])
	return resultat

func reactif(id: String) -> Reactif:
	return CatalogueReactifs.par_id(id)

func ameliorations_effectives() -> Array:
	return inventaire.duplicate()

func mods() -> Array:
	return Mods.depuis_l_inventaire(ameliorations_effectives())

func duree_run() -> float:
	return float(images_de_jeu) / float(Engine.physics_ticks_per_second)

func terminer_run(victoire: bool) -> void:
	run_terminee.emit(victoire)

func marquer_salle_terminee(numero: int) -> void:
	if not salles_terminees.has(numero): salles_terminees.append(numero)

func marquer_boss_vaincu(numero: int) -> void:
	if not boss_vaincus.has(numero): boss_vaincus.append(numero)
