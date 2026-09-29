extends RefCounted

const Listes = preload("res://tools/statistiques/listes.gd")
const Modeles = preload("res://tools/statistiques/modeles.gd")
const ProfilsAugments = preload("res://tools/statistiques/profils_augments.gd")
const ProfilCampagne = preload("res://tools/statistiques/profil_campagne.gd")
const Synthese = preload("res://tools/statistiques/synthese.gd")
const SyntheseProgression = preload("res://tools/statistiques/synthese_progression.gd")
const Simulation = preload("res://tools/statistiques/simulation_augments.gd")
const Soins = preload("res://data/progression/soins_run.gd")
const RetourCampagne = preload("res://tools/statistiques/retour_campagne.gd")
const EquilibrageProgression = preload("res://tools/statistiques/equilibrage_progression.gd")
const RythmeProgression = preload("res://tools/statistiques/rythme_progression.gd")
const MaturationProgression = preload("res://tools/statistiques/maturation_progression.gd")
const RythmeBoss = preload("res://tools/statistiques/rythme_boss.gd")
const ValeurSources = preload("res://tools/statistiques/valeur_sources.gd")

static func n(valeur: float, decimales := 2) -> String:
	return Listes.nombre(valeur, decimales)

static func generer() -> String:
	var lignes: Array[String] = ["# Liste mathématique", ""]
	Synthese.ajouter(lignes)
	ValeurSources.ajouter(lignes)
	_simulation_augments(lignes)
	_soins(lignes)
	_terrains(lignes)
	_retour_campagne(lignes)
	_equilibrage_progression(lignes)
	_rythme_progression(lignes)
	_rythme_boss(lignes)
	_maturation_progression(lignes)
	SyntheseProgression.ajouter(lignes)
	lignes.append_array(["## Les formules, en détail", "",
		"Les calculs suivants expliquent la fiche. Un **DPS** est une moyenne de dégâts par seconde, avec des tirs continus qui touchent. Les déplacements, obstacles, ratés et phases invulnérables réduisent le résultat réel. Les rebonds ne sont pas des dégâts gratuits sur la même cible.", "",
		"Les **PV effectifs** mesurent les dégâts bruts supportés avant la mort, hors esquive, soins, bouclier de salle et secondes vies (Courage, Sursis).", ""])
	_formules(lignes)
	_tirs_multiples(lignes)
	_heros(lignes)
	_ennemis(lignes)
	_sources(lignes)
	_augments(lignes)
	_economie(lignes)
	_comparer_farm(lignes)
	_methode(lignes)
	return "\n".join(lignes) + "\n"

static func _simulation_augments(lignes: Array[String]) -> void:
	var simulation := Simulation.simuler()
	var equilibre: Array = simulation["politiques"]["equilibre"]["salles"]
	var milieu: Dictionary = equilibre[9]["combat"]
	var fin: Dictionary = equilibre.back()["combat"]
	lignes.append_array(["## La puissance gagnée pendant une tentative", "",
		"**Un nouveau héros faisant des choix mixtes atteint en médiane ×%s DPS en salle 10 et ×%s en salle 20.** Les PV effectifs passent à ×%s en fin de run. Ces résultats viennent de %d tirages par orientation, avec les offres réelles du jeu, sans relance." % [n(float(milieu["dps_ratio"]["mediane"])), n(float(fin["dps_ratio"]["mediane"])), n(float(fin["ehp_ratio"]["mediane"])), Simulation.NOMBRE_RUNS], "",
		"Chaque run reçoit %d choix : un légendaire garanti au niveau %d, %d épiques placés sans remise parmi les autres niveaux et des rares ailleurs. Le tirage réel ajoute avec exactement %s %% de probabilité un second légendaire, en remplacement d’un rare ou d’un épique. Tous les niveaux hors %d sont éligibles, y compris le premier ; la probabilité marginale est donc %s %% par niveau éligible. Le total reste %d choix, avec au plus deux légendaires et %d ou %d épiques lorsqu’il y en a deux." % [ProgressionAugments.niveau_max(), ProgressionAugments.NIVEAU_LEGENDAIRE, ProgressionAugments.NOMBRE_EPIQUES, n(ProgressionAugments.CHANCE_LEGENDAIRE_BONUS * 100.0), ProgressionAugments.NIVEAU_LEGENDAIRE, n(ProgressionAugments.CHANCE_LEGENDAIRE_BONUS * 100.0 / float(ProgressionAugments.niveau_max() - 1)), ProgressionAugments.niveau_max(), ProgressionAugments.NOMBRE_EPIQUES - 1, ProgressionAugments.NOMBRE_EPIQUES], "",
		"Les distributions ci-dessous incluent ce bonus. Les paniers fixes et les parcours de référence le désactivent pour comparer des runs ordinaires à un légendaire ; leurs offres restent aléatoires et les monstres conservent leurs courbes fixes.", "",
		"L’orientation mixte choisit le meilleur compromis immédiat : **55 % du gain logarithmique de DPS + 45 % du gain logarithmique de PV effectifs**. Elle ne connaît pas les prochaines offres. Tout offensif utilise 100/0, offensif prudent 85/15 et défensif 20/80. Cela décrit des choix cohérents, pas la façon de jouer de chaque personne.", "",
		"Les soins, secondes vies, esquives, boucliers, mobilité et dégâts sur plusieurs cibles ne sont pas valorisés par ce score. Le bonus d’Élan vital après déplacement n’est pas inclus dans ce DPS de tir continu. Les résultats restent un modèle de puissance : ils ne prédisent pas les dégâts réellement évités ni une probabilité de victoire.", "",
		"**P10–P90** encadre les 80 % centraux des tirages. Les dégâts sont monocibles idéaux, tous les tirs frontaux touchent. Le familier est inclus ; le héros tire en continu.", ""])
	var donnees: Array = []
	for politique: String in Simulation.POLITIQUES:
		var resultat: Dictionary = simulation["politiques"][politique]["salles"].back()["combat"]
		var dps: Dictionary = resultat["dps_ratio"]
		var ehp: Dictionary = resultat["ehp_ratio"]
		var coups := float(resultat["pv_effectifs"]["mediane"]) / (float(CatalogueEnnemis.par_id("encrier_rampant")["degats"]) * Chapitres.facteur_degats(0, 19) * Reglages.ENNEMI_DEGATS_MULT)
		var libelle := str({"tout_offensif": "Tout offensif", "offensif": "Offensif prudent", "equilibre": "Équilibré", "defensif": "Défensif"}[politique])
		donnees.append([libelle, "×" + n(float(dps["mediane"])), "×%s–%s" % [n(float(dps["p10"])), n(float(dps["p90"]))], "×" + n(float(ehp["mediane"])), n(coups)])
	Listes.tableau(lignes, ["Choix", "DPS final médian / début", "DPS P10–P90", "PV effectifs / début", "Contacts de fragile supportés salle 19, sans soin"], donnees)
	lignes.append_array(["### Courbe d’une run au premier niveau de campagne", "",
		"Le héros commence avec la Baguette d’acier et l’Homoncule, sans attribut, maîtrise, passif, Cœur ni forge. Les colonnes indiquent les statistiques **pendant le combat** : les niveaux des salles précédentes sont reçus, le choix de fin de salle ne l’est pas. Aucun choix supplémentaire ne précède un boss.", ""])
	var salles: Array = []
	for ligne: Dictionary in equilibre:
		var numero := int(ligne["salle"])
		var combat: Dictionary = ligne["combat"]
		salles.append([numero, "×" + n(float(combat["dps_ratio"]["mediane"])), "×%s–%s" % [n(float(combat["dps_ratio"]["p10"])), n(float(combat["dps_ratio"]["p90"]))], "×" + n(float(combat["ehp_ratio"]["mediane"])), "×" + n(Chapitres.facteur_pv(0, numero)), "×" + n(Chapitres.facteur_degats(0, numero))])
	Listes.tableau(lignes, ["Salle", "DPS mixte médian", "DPS P10–P90", "PV effectifs mixtes", "PV monstres", "Dégâts monstres"], salles)
	var depart := Modeles.mesurer({})
	var exemples: Array = []
	for id: String in ["encrier_rampant", "plume_sentinelle", "tache_veloce", "sceau_belier"]:
		var ennemi := CatalogueEnnemis.par_id(id)
		var pv := float(ennemi["pv"])
		exemples.append([str(ennemi["nom"]), n(pv), ceili(pv / float(depart["tir_normal"])), ceili(pv * Chapitres.facteur_pv(0, 19) / float(depart["tir_normal"]))])
	Listes.tableau(lignes, ["Monstre", "PV salle 1", "Tirs normaux nécessaires salle 1", "Même arme sans augment salle 19"], exemples)
	lignes.append_array(["Les tirs ci-dessus excluent critiques et dégâts du familier pour rendre le repère « trois ou quatre attaques » lisible ; les costauds conservent leur rôle. La salle 19 n’a pas exactement les mêmes espèces que la salle 1 : la dernière colonne compare la même espèce à statistiques de salle différentes.", "",
		"Le premier niveau n’a aucun élite. Ses quatre premières salles ont moins de renforts, ses salles suivantes perdent une vague (minimum deux) et ses grandes salles restent plafonnées à l’effectif normal. Les projectiles et déplacements ennemis sont ralentis au début de la campagne, avec des annonces et repos allongés ; cette aide disparaît progressivement au troisième niveau. Aucun tutoriel ni protection d’invincibilité n’est ajouté.", ""])

static func _soins(lignes: Array[String]) -> void:
	lignes.append_array(["## Cœurs de soin et marge d’erreur", "",
		"Ces cœurs au sol sont distincts des **Cœurs de mana permanents**, qui augmentent les dégâts finaux. Un cœur de soin rend **%s %% des PV maximum × bonus de soins**, dans la limite des PV manquants." % n(Soins.SOIN_PART_PV_MAX * 100.0), ""])
	var quotas: Array = []
	for quota in Soins.PROBABILITES_QUOTAS.size():
		quotas.append([quota, "%s %%" % n(float(Soins.PROBABILITES_QUOTAS[quota]) * 100.0)])
	Listes.tableau(lignes, ["Cœurs déposés dans la rencontre", "Probabilité"], quotas)
	lignes.append_array(["Le budget est tiré une seule fois par salle/rencontre : **jamais plus de deux cœurs**, en moyenne %s. Les morts qui les déposent sont choisies parmi les ennemis prévus, sans compter les invocations. Un boss seul peut laisser les deux." % n(Soins.esperance_par_rencontre()), "",
		"À PV pleins, un cœur reste au sol. Il se ramasse en passant à proximité, sans traverser un obstacle ; ceux qui restent sont récupérés à la fin de la salle ou de la tentative. Si le héros est alors à PV pleins, chaque cœur inutilisé donne %d Goutte. Un héros mort n’est jamais ressuscité par cette collecte." % Soins.GOUTTES_PAR_COEUR_INUTILISE, "",
		"Sur %d salles, cela représente en moyenne %s cœurs, soit un potentiel de soin cumulé de %s %% d’une barre de vie avant bonus et pertes à PV pleins. Les choix épiques et légendaires n’ajoutent plus de soin automatique ; seul le soin propre d’un augment comme Égide reste actif. Ces quantités ne forment pas une réserve transportable et ne prouvent pas qu’un joueur survivra." % [Reglages.SALLES_PAR_RUN, n(Soins.esperance_par_rencontre() * Reglages.SALLES_PAR_RUN), n(Soins.esperance_par_rencontre() * Reglages.SALLES_PAR_RUN * Soins.SOIN_PART_PV_MAX * 100.0)], "",
		"En Mine, un quota est ouvert toutes les %s s, sur les %d premières morts admissibles de cette tranche. Les quotas inutilisés ne s’accumulent pas ; après le chronomètre, aucun nouveau quota n’apparaît." % [n(Soins.MINE_INTERVALLE_QUOTA), Soins.MINE_MORTS_CANDIDATES], "",
		"Les cœurs et Moisson vitale utilisent le soin garanti, distinct du plafond des soins de combat par salle. Récupération d’entrée reste dans le budget des soins de combat.", "",
		"En Mine aussi, les niveaux ne donnent aucun soin automatique. Les cœurs convertis donnent un montant fixe de Gouttes, sans multiplicateur d’équipement ni d’augment ; ces recettes ne sont pas incluses dans le parcours économique, qui ne simule pas les blessures ni les trajets.", ""])

static func _terrains(lignes: Array[String]) -> void:
	lignes.append_array(["## Terrains des cinq mondes", "",
		"Ces terrains apparaissent dans certaines salles ordinaires de campagne. Ils laissent libres l’entrée, la sortie et le passage central ; les salles de boss et les modes annexes gardent leur configuration. Les flaques ont des contours et des tailles variables, identiques entre deux visites de la même salle.", ""])
	var lignes_terrains: Array = []
	for monde in TerrainsMondes.PROFILS.size():
		var profil: Dictionary = TerrainsMondes.PROFILS[monde]
		var effet := ""
		match str(profil["type"]):
			"encre", "eau": effet = "Vitesse à %s %% dans la flaque ; tirs conservés" % n(float(profil["vitesse"]) * 100.0)
			"sable": effet = "Vitesse de %s %% à %s %% en %s s ; retour à la normale en sortant" % [n(TerrainsMondes.SABLE_VITESSE_INITIALE * 100.0),n(TerrainsMondes.SABLE_VITESSE_MINIMALE * 100.0),n(TerrainsMondes.SABLE_DUREE_ENFONCEMENT)]
			"vent": effet = "Poussée jusqu’à %s %% de la vitesse : %s %% face au vent, %s %% vent dans le dos, à pleine commande" % [n(TerrainsMondes.VENT_VARIATION_VITESSE * 100.0),n((1.0-TerrainsMondes.VENT_VARIATION_VITESSE)*100.0),n((1.0+TerrainsMondes.VENT_VARIATION_VITESSE)*100.0)]
			"lave": effet = "%s %% des PV maximum en dégâts bruts toutes les %s s ; défense, bouclier et invulnérabilité habituels" % [n(float(profil["degats"])*100.0),n(TerrainsMondes.INTERVALLE_DEGATS)]
		lignes_terrains.append([str(Chapitres.MONDES[monde]["nom"]),effet])
	Listes.tableau(lignes,["Monde","Effet sur le héros"],lignes_terrains)
	lignes.append_array(["Délai d’entrée en salle : %s s. Les effets cessent à l’ouverture du portail. Les ralentissements ne s’additionnent pas entre flaques." % n(TerrainsMondes.DELAI_ACTIVATION), "",
		"Vent : %s s de calme puis %s s de rafale, avec une indication de direction %s s avant. La poussée monte en %s s et retombe en %s s. La direction change entre les rafales ; le vent déplace aussi un héros à l’arrêt, sans annuler son tir automatique ni traverser les obstacles. Les effets réduits figent seulement le déplacement des traits visuels." % [n(TerrainsMondes.VENT_REPOS),n(TerrainsMondes.VENT_DUREE),n(TerrainsMondes.VENT_ANNONCE),n(TerrainsMondes.VENT_MONTEE),n(TerrainsMondes.VENT_DESCENTE)], ""])

static func _methode(lignes: Array[String]) -> void:
	lignes.append_array(["## Méthode et références consultées", "",
		"Les nombres de ce document proviennent du jeu et des scénarios décrits ; aucun jeu extérieur ne fournit les coefficients. Les références servent à choisir la méthode d’équilibrage.", "",
		"- [GEEvo — Rupp et Eckert, 2024](https://arxiv.org/abs/2404.18574) : simulation d’une économie avec des objectifs explicites de ressources et de dégâts dans le temps. Ici, cette approche motive la mesure conjointe des combats, achats et répétitions.",
		"- [GDC — Matt Woodward, Balancing the Economy for Albion Online](https://gdcvault.com/play/1024070/Balancing-the-Economy-for-Albion) : définir des repères et des contraintes d’économie avant de régler les valeurs. Ici, les repères sont le nombre d’attaques, les coups supportés, la durée des boss et le temps d’amélioration.",
		"- [Notes officielles Dead Cells, mise à jour 11](https://deadcells.com/patchnotes/11) : suppression de l’adaptation automatique des ennemis aux statistiques du joueur. Alambik conserve également des niveaux fixes : améliorer son build doit réellement faciliter un niveau déjà connu.", "",
		"Les hypothèses d’activité de tir et de choix sont vérifiables et modifiables dans le modèle. Une réussite en deux tentatives et le ressenti du farm devront être confrontés à des parties sur téléphone ; les calculs ne remplacent pas cette mesure.", ""])

static func _formules(lignes: Array[String]) -> void:
	lignes.append_array(["### Ce qui s’additionne et ce qui se multiplie", ""])
	var formules: Array[String] = [
		"Attaque brute = base du héros à son niveau + Force + Intelligence + attaque de l’arme + attaque des trois bijoux.",
		"Attaque permanente = attaque brute × (1 + pourcentages d’équipement) × (1 + pourcentages de maîtrises) × (1 + pourcentages de passifs). Les bonus d’une même source s’additionnent ; les sources se multiplient.",
		"Attaque de run = attaque permanente × (1 + somme des bonus d’attaque des augments). Aucun augment ne réduit l’attaque en échange de défense.",
		"Dégâts d’un projectile = attaque de run × coefficient de l’arme × bonus de projectile (Perforation, Élan vital chargé) × malus indépendants de Salve, Battement triple et chaque Tir double × bonus finaux × éventuel critique. Le tir après coefficient d’arme constitue la référence à 100 %.",
		"Cadence = base × facteur d’attributs × facteur d’équipement × facteur de maîtrises × facteur de passifs × facteur des augments × facteur de l’arme.",
		"DPS frontal héros = dégâts moyens d’un projectile × poids des projectiles frontaux × salves × cadence.",
		"Critique moyen = 1 + chance critique × (coefficient critique − 1). Chance plafonnée à 100 %% ; critique de base ×%s. Couronne incisive convertit une part de la chance au-delà du plafond en dégâts critiques." % n(Reglages.CRITIQUE_MULT_BASE),
		"Bonus finaux = (1 + %s × nombre de Cœurs) × (1 + Audace + Reprise de souffle active + Élan offensif actif)." % n(Reglages.COEUR_MANA_BONUS_FINAL),
		"Cinquième impact est un facteur moyen supplémentaire de ×%s sur le héros quand l’anneau correspondant est équipé et forgé." % n(1.0 + (EffetsBijoux.IMPACT_MULTIPLICATEUR - 1.0) / float(EffetsBijoux.IMPACT_ATTAQUES)),
		"DPS familier = attaque propre × facteur permanent d’attaque × facteur d’attaque des augments × bonus finaux / intervalle. Chaque rang de forge reste utile. Pas de critique ni de salve du héros.",
		"DPS total = DPS héros + DPS familier. Les classes ajoutent 0 % à toutes ces sources.", "",
		"PV = (PV de base au niveau du héros + Vitalité + valeurs brutes des bijoux) × facteur d’équipement × facteur de maîtrises × facteur de passifs × facteur des augments. Égide multiplie le résultat après la somme des bonus de PV des autres augments.",
		"Défense = (base + Vitalité + valeurs brutes des bijoux/familiers) × facteur d’équipement × facteur de maîtrises × facteur de passifs × facteur des augments.",
		"Dégâts reçus = dégâts ennemis × facteur des augments × (1 + Audace) × (1 − réduction des maîtrises) × %s / (%s + Défense)." % [n(Reglages.DEFENSE_REFERENCE), n(Reglages.DEFENSE_REFERENCE)],
		"Les soins de combat par salle sont limités à %s %% des PV maximum × bonus de soins, budget fixé à l’entrée. Les cœurs au sol et Moisson vitale utilisent un soin garanti distinct ; les choix n’ajoutent aucun soin lié à leur rareté." % n(Reglages.SOIN_COMBAT_PAR_SALLE * 100.0)]
	for formule: String in formules:
		if not formule.is_empty(): lignes.append("- " + formule)
	lignes.append("")

static func _tirs_multiples(lignes: Array[String]) -> void:
	var stats := Stats.depuis_reglages()
	stats.degats = 1000.0
	var base_arme := CatalogueProjectiles.appliquer("lourd", Tir.de_base(stats)).degats
	lignes.append_array(["### Tir double, Salve et Battement triple", "",
		"**Tir double** ajoute un projectile parallèle. **Salve** ajoute une répétition de l’attaque. **Battement triple**, légendaire, ajoute deux répétitions. Chacun applique son propre coefficient ×%s aux dégâts de tous les projectiles ; leurs réductions se multiplient et restent actives avec les autres légendaires." % n(ReglagesAugments.MALUS_TIRS_MULT), "",
		"Exemple avec %s ATK et le Sceptre de cuivre : le coefficient d’arme porte le projectile à %s dégâts, qui devient notre référence à 100 %%. Les critiques et autres bonus finaux sont laissés de côté dans ce tableau." % [n(stats.degats), n(base_arme)], ""])
	var exemples: Array = [
		["Arme seule", []], ["Tir double", ["tir_multiple"]],
		["Tir double ×2", ["tir_multiple", "tir_multiple"]], ["Salve", ["salve"]],
		["Tir double + Salve", ["tir_multiple", "salve"]],
		["Battement triple", ["battement_triple"]],
		["Battement triple + Salve", ["battement_triple", "salve"]],
		["Tir double + Battement triple", ["tir_multiple", "battement_triple"]],
		["Tir double + Battement triple + Salve", ["tir_multiple", "battement_triple", "salve"]]]
	var donnees: Array = []
	for exemple: Array in exemples:
		var tir := CatalogueProjectiles.appliquer("lourd", Mods.appliquer(Tir.de_base(stats), Mods.depuis_l_inventaire(exemple[1])))
		var impact := tir.degats * tir.degats_finaux_projectile_mult
		donnees.append([str(exemple[0]), tir.nb_projectiles, tir.salves, n(impact),
			n(impact * tir.nb_projectiles * tir.salves), "×%s" % n(impact * tir.nb_projectiles * tir.salves / base_arme)])
	Listes.tableau(lignes, ["Choix", "Projectiles par salve", "Salves", "Dégâts par projectile", "Dégâts par attaque complète", "Gain sur l’arme seule"], donnees)
	var triple := Mods.appliquer(Tir.de_base(stats), Mods.depuis_l_inventaire(["battement_triple"]))
	var triple_salve := Mods.appliquer(Tir.de_base(stats), Mods.depuis_l_inventaire(["battement_triple", "salve"]))
	var gain_salve := float(triple_salve.salves) * triple_salve.degats_finaux_projectile_mult \
		/ (float(triple.salves) * triple.degats_finaux_projectile_mult)
	lignes.append_array(["Avec Battement triple, Salve fait passer de %d à %d salves, avec %s %% des dégâts de base par projectile : **×%s**, soit **+%s %% de DPS idéal** par rapport à Battement triple seul. Deux réductions de %s %% laissent **%s %%** des dégâts ; l’ajout d’un Tir double en laisse **%s %%**. Aucun légendaire n’annule ces réductions." % [triple.salves, triple_salve.salves, n(triple_salve.degats_finaux_projectile_mult * 100.0), n(gain_salve, 4), n((gain_salve - 1.0) * 100.0), n((1.0 - ReglagesAugments.MALUS_TIRS_MULT) * 100.0), n(pow(ReglagesAugments.MALUS_TIRS_MULT, 2) * 100.0), n(pow(ReglagesAugments.MALUS_TIRS_MULT, 3) * 100.0)], ""])

static func _heros(lignes: Array[String]) -> void:
	lignes.append_array(["### Bases du héros et attributs", "",
		"Au niveau 1 : %s PV ; %s Défense ; %s attaque ; %s tirs/s. Chaque niveau ajoute %s %% des PV initiaux et %s %% de l’attaque initiale, en plus des points à répartir. Au niveau maximal, le socle seul vaut %s PV et %s attaque." % [n(Reglages.HEROS_PV), n(Reglages.HEROS_DEFENSE), n(Reglages.TIR_DEGATS), n(Reglages.HEROS_CADENCE), n(Reglages.NIVEAU_PV_PAR_NIVEAU * 100.0), n(Reglages.NIVEAU_DEGATS_PAR_NIVEAU * 100.0), n(Stats.base_pv(Personnage.NIVEAU_MAX)), n(Stats.base_degats(Personnage.NIVEAU_MAX))],
		"Chaque niveau après le premier donne %d points, jusqu’au niveau %d : %d points au total." % [Personnage.POINTS_PAR_NIVEAU, Personnage.NIVEAU_MAX, Personnage.points_totaux(Personnage.NIVEAU_MAX)]])
	lignes.append("Pour un attribut offensif recevant p points : poids effectif = 2 × %s × p / (%s + p). Son bonus vaut coefficient du catalogue × poids effectif × croissance du héros. La Vitalité et la Sagesse conservent leur calcul linéaire." % [n(Personnage.POINTS_RENDEMENT), n(Personnage.POINTS_RENDEMENT)])
	lignes.append("Avec t = (niveau − 1) / (%d − 1), la croissance des attributs offensifs vaut %s + (1 − %s) × t² ; celle des statistiques de passifs vaut %s + (1 − %s) × t². Les bonus de rang restent proportionnels au rang acquis ; les pouvoirs conditionnels et utilitaires des passifs conservent leurs règles." % [Personnage.NIVEAU_MAX, n(Personnage.PUISSANCE_INITIALE), n(Personnage.PUISSANCE_INITIALE), n(Passifs.PUISSANCE_INITIALE, 4), n(Passifs.PUISSANCE_INITIALE, 4)])
	var attributs: Array = []
	for id: String in Personnage.ATTRIBUTS:
		var d: Dictionary = Personnage.ATTRIBUTS[id]
		attributs.append([str(d["nom"]), str(d["description"])])
	Listes.tableau(lignes, ["Attribut", "Effet des points"], attributs)

static func _retour_campagne(lignes: Array[String]) -> void:
	var rapport := RetourCampagne.rapport()
	lignes.append_array(["## Retour offensif après les premières Épreuves", "",
		"%d comptes avec graines fixes : échec imposé en salle 9 du chapitre 1, puis victoire au même chapitre, suivie de zéro, cinq ou six victoires dans l’Épreuve 1. Ces victoires sont les hypothèses du scénario demandé ; aucun taux de réussite humain n’est déduit." % int(rapport["nombre"]), "",
		"Tous les points d’attribut vont en Force. Les achats maximisent le gain de DPS par coût, avec les seules ressources effectivement reçues ; l’équipement privilégie le DPS. Le compte repart sans augment à chaque tentative. Les offres d’augments suivent la politique tout offensive (%s %% dégâts, %s %% résistance), avec une seule légendaire garantie. Une offre sans gain offensif peut donner une défense incidente." % [n(float(Simulation.POLITIQUES["tout_offensif"]["poids_dps"]) * 100.0), n(float(Simulation.POLITIQUES["tout_offensif"]["poids_ehp"]) * 100.0)], "",
		"Le build offensif doit gagner du temps de combat sans banaliser les éliminations en une attaque. Les courbes fixes des ennemis sont recalibrées avec la puissance permanente et les augments. Aucun nombre minimum de coups ni ajustement au build ne s'applique en jeu.", "",
		"Les chapitres du tableau sont testés séparément avec le même compte après le farm, sans ajouter les récompenses des chapitres intermédiaires. Les résultats sont des médianes. Le taux d’élimination concerne les formes ordinaires des monstres prévus par les vagues, sans transformation en élite, sans critique, sans rebond ni dégâts gratuits du familier.", "",
		"Un projectile désigne un seul impact. Une attaque complète additionne les salves et projectiles frontaux qui touchent la même cible. Le temps du boss inclut le familier et les critiques moyens, à %s %% du DPS théorique ; il reste une estimation de débit." % n(RetourCampagne.Parcours.TIR_UTILE_BOSS * 100.0), ""])
	var lignes_cas: Array = []
	for cas: Dictionary in rapport["cas"]:
		if bool(cas["successives"]): continue
		lignes_cas.append([cas["epreuves"], cas["chapitre"], n(float(cas["dps_permanent"]["mediane"]), 1),
			n(float(cas["tirs_entree"]["mediane"]), 1), n(float(cas["un_projectile"]["mediane"]) * 100.0, 1) + " %",
			n(float(cas["une_attaque"]["mediane"]) * 100.0, 1) + " %", n(float(cas["boss_final"]["mediane"]), 1),
			n(float(cas["contacts_min"]["mediane"]), 1)])
	Listes.tableau(lignes, ["Victoires Épreuve 1", "Chapitre", "DPS permanent", "Projectiles à l’entrée",
		"Monstres en 1 projectile", "Monstres en 1 attaque", "Boss final, s", "Contacts minimum"], lignes_cas)
	var murs: Dictionary = rapport["murs_dps_observes"]
	var continuations: Array = []
	for chapitre: int in rapport["progression"]:
		var mesure: Dictionary = rapport["progression"][chapitre]
		continuations.append([chapitre, n(float(mesure["une_attaque"]["mediane"]) * 100.0, 1) + " %",
			n(float(mesure["boss_final"]["mediane"]), 1), n(float(mesure["contacts_min"]["mediane"]), 1)])
	lignes.append_array(["### Enchaîner réellement les chapitres après six Épreuves", "",
		"Cette fois, les achats et récompenses sont conservés entre deux chapitres. Le personnage continue à investir uniquement en dégâts permanents.", ""])
	Listes.tableau(lignes, ["Chapitre", "Monstres en 1 attaque", "Boss final, s", "Contacts minimum"], continuations)
	lignes.append_array(["Sans autre farm après les six Épreuves, **%d comptes sur %d** ne rencontrent aucun boss dépassant %s secondes sur les %d chapitres. Cela mesure uniquement leur puissance de tir, en supposant qu’ils survivent." % [int(rapport["comptes_sans_mur_dps"]), int(rapport["nombre"]), n(RetourCampagne.Parcours.BOSS_LIMITE), Chapitres.nombre()], ""])
	if not murs.is_empty():
		lignes.append_array(["Parmi les comptes qui rencontrent ce seuil de durée, le premier apparaît au chapitre médian **%s [P10 %s ; P90 %s]**." % [n(float(murs["mediane"]), 1), n(float(murs["p10"]), 1), n(float(murs["p90"]), 1)], ""])
	lignes.append_array([
		"Ce parcours offensif ignore volontairement le seuil de trois contacts pour isoler la puissance de tir. Les contacts minimum ci-dessus retiennent le monstre ordinaire le plus dangereux rencontré, hors élites. Les soins, esquives et blessures ne sont pas simulés.", "",
		"Le scénario de six niveaux d’Épreuve successifs s’arrête désormais après le premier : vaincre une Épreuve ne suffit plus, la campagne doit aussi avoir atteint son palier. Rejouer le niveau accessible reste autorisé.", ""])

static func _equilibrage_progression(lignes: Array[String]) -> void:
	var rapport := EquilibrageProgression.rapport()
	lignes.append_array(["## Progression ordinaire, deux défenses et sur-farm", "",
		"%d comptes par scénario, avec les mêmes graines. Tous commencent par l'échec en salle 9 puis la victoire au premier chapitre. Le parcours ordinaire enchaîne ensuite la campagne, équilibré ou tout offensif. Retour Épreuves ajoute six victoires à l'Épreuve 1. Sur-farm ajoute cinq Épreuves et six victoires supplémentaires au chapitre 1, avant de reprendre le chapitre 2." % int(rapport["nombre"]), "",
		"Chaque victoire est supposée : ces résultats mesurent la puissance du compte, pas un taux de réussite humain. Les ressources et achats sont conservés entre chapitres et viennent du vrai butin. Aucune maîtrise, forge ou pièce d'équipement maximale n'est accordée gratuitement.", "",
		"Le cas « Offensif + deux défenses » reprend le même compte offensif, mais remplace son choix légendaire par Égide et un choix épique par Peau de pierre, après leurs niveaux réels. Le nombre de choix, les raretés et les limites de copies sont conservés ; ces deux remplacements sont un stress volontaire, sans prétendre qu'ils figurent toujours dans les offres.", "",
		"Une attaque additionne ses salves et tous ses projectiles frontaux sur la même cible. Les critiques sont calculés par une loi binomiale : chaque salve a son propre tirage, commun à ses projectiles. Les rebonds, le familier, Élan vital chargé et les effets conditionnels ne donnent pas d'élimination gratuite dans ce taux. Les élites sont exclues, ce qui privilégie les éliminations faciles.", "",
		"Les lignes donnent des médianes de comptes, plus le P90 du taux avec critiques pour montrer les tirages favorables. Contacts équivalents = PV effectifs / dégâts bruts : 2,3 signifie mort au troisième coup identique, sans soin, esquive, bouclier ou seconde vie. Ce tableau prend le monstre médian ; le minimum est conservé dans les mesures détaillées. Le boss inclut familier et critiques moyens, avec %s %% de tir utile." % n(RetourCampagne.Parcours.TIR_UTILE_BOSS * 100.0), ""])
	var noms := {"equilibre": "Équilibré", "offensif": "Offensif", "offensif_deux_defenses": "Offensif + deux défenses", "retour_epreuves": "Retour Épreuves", "surfarm": "Sur-farm offensif"}
	var tableau: Array = []
	for scenario: String in rapport["scenarios"]:
		for chapitre: int in [2, 3, 7, 14, 35]:
			var mesure: Dictionary = rapport["scenarios"][scenario][chapitre]
			tableau.append([noms[scenario], chapitre, n(float(mesure["attaques"]["mediane"]), 1),
				n(float(mesure["une_attaque"]["mediane"]) * 100.0, 1) + " %",
				n(float(mesure["avec_critiques"]["mediane"]) * 100.0, 1) + " % / " + n(float(mesure["avec_critiques"]["p90"]) * 100.0, 1) + " %",
				n(float(mesure["contacts"]["mediane"]), 1), n(float(mesure["boss"]["mediane"]), 1)])
	Listes.tableau(lignes, ["Parcours", "Chapitre", "Attaques par monstre", "En 1 attaque normale", "Avec critiques : médiane / P90", "Contacts équivalents", "Boss final, s"], tableau)
	lignes.append_array(["### Annexes à leur premier déblocage", "",
		"Même compte après le chapitre 1 pour l'Épreuve 1, puis après le chapitre 3 pour la Mine 1, sans farm supplémentaire. Médianes des comptes. Les contacts prennent le boss le plus dangereux de l'Épreuve, ou le minimum contre un Encrier rampant pendant la Mine ; ils ne modélisent pas les collisions ni les soins. Les choix d'augments suivent la politique du compte.", ""])
	var annexes: Array = []
	for scenario: String in rapport["annexes"]:
		for mode: String in rapport["annexes"][scenario]:
			var mesure: Dictionary = rapport["annexes"][scenario][mode]
			annexes.append([noms[scenario], "Épreuve 1" if mode == "epreuve" else "Mine 1",
				n(float(mesure["contacts"]["mediane"]), 1), n(float(mesure["boss"]["mediane"]), 1)])
	Listes.tableau(lignes, ["Parcours", "Annexe", "Contacts équivalents", "Boss final, s"], annexes)
	var augment: Dictionary = rapport["augments"]["debut"]
	lignes.append_array(["### Budget des bonus offensifs et défensifs", "",
		"Comparaison d'un seul choix de même rareté sur le héros initial. Les multiplicateurs de survie excluent le soin immédiat d'Égide. Le gain au-dessus de ×1 reste comparable, avec une tolérance de 15 % ; la défense n'a plus de prime systématique.", ""])
	var paires: Array = []
	for paire: Array in [["sceau_ruine", "sceau_garde"], ["noyau_pesant", "peau_de_pierre"], ["frappe_lourde", "egide"]]:
		paires.append([CatalogueReactifs.par_id(paire[0]).nom, "×" + n(float(augment[paire[0]]["dps"])),
			CatalogueReactifs.par_id(paire[1]).nom, "×" + n(float(augment[paire[1]]["survie"]))])
	Listes.tableau(lignes, ["Choix offensif", "DPS héros", "Choix défensif", "PV effectifs"], paires)
	lignes.append_array(["Égide et Peau de pierre ensemble : **×%s PV effectifs**, en consommant un choix légendaire et un choix épique. Les deux effets ne donnent pas de DPS." % n(float(augment["deux_defenses"]["survie"])), ""])

static func _rythme_progression(lignes: Array[String]) -> void:
	var rapport := RythmeProgression.rapport()
	var profil: Dictionary = rapport["profil"]
	lignes.append_array(["## Entrée des niveaux et rendement des achats", "",
		"Le cas de départ reprend un héros niveau 4, Baguette d’acier forge 1 et Force maîtrisée rang 6. Ses points d’attribut restent non dépensés ; il n’a ni bijou, passif, Cœur ni augment. Les attaques sont normales, sans critique ni contribution du familier. Les quatre premières salles sont aussi mesurées sans aucun augment pour vérifier leur accessibilité indépendamment du hasard.", ""])
	var especes: Array = []
	for id: String in profil["especes"]:
		var espece: Dictionary = profil["especes"][id]
		especes.append([str(CatalogueEnnemis.par_id(id)["nom"]), n(float(espece["pv"])), n(float(profil["attaque"])), int(espece["attaques"])])
	Listes.tableau(lignes, ["Monstre du niveau 2, salle 1", "PV", "Dégâts par attaque", "Attaques nécessaires"], especes)
	var achats: Array = []
	for achat: Dictionary in rapport["achats"]:
		achats.append([str(achat["nom"]), int(achat["prix"]), n(float(achat["tir"])), "+%s %%" % n(float(achat["gain_tir"]) * 100.0), "+%s %%" % n(float(achat["gain_dps"]) * 100.0)])
	Listes.tableau(lignes, ["Achat depuis ce profil", "Coût dans sa monnaie", "Dégâts par tir", "Gain par tir", "Gain de DPS total"], achats)
	lignes.append_array(["Le coût d’une arme est payé en Pierres, celui d’une maîtrise en Gouttes. Les autres statistiques et l’équipement restent identiques pendant ces comparaisons.", "",
		"### Campagne seule avec quelques reprises", "",
		"%d comptes équilibrés avec les mêmes graines de référence. Le premier monde ne contient aucune reprise ajoutée. Le scénario reprend ensuite des niveaux déjà terminés : %s. Ce calendrier est une hypothèse de mesure, jamais une obligation ni un nombre d’essais prédit pour le joueur." % [int(rapport["nombre"]), _calendrier_reprises()], "",
		"Les victoires sont supposées pour isoler l’économie ; les butins, possessions, coûts et achats sont réels. Pendant une reprise destinée aux dégâts, les achats et augments privilégient l’attaque ; les attributs déjà répartis restent identiques. Les premières salles sont mesurées sans augment, les durées de boss utilisent ensuite les vrais tirages de run et les mêmes hypothèses de tir utile que les autres simulations.", ""])
	var entrees: Array = []
	for chapitre: int in [2, 7, 14, 21, 28, 35]:
		var entree: Dictionary = rapport["entrees"][chapitre]
		entrees.append([chapitre, n(float(entree["attaques"]["mediane"]), 1), n(float(entree["attaques"]["p90"]), 1), n(float(entree["dps"]["mediane"])), n(float(entree["boss"]["mediane"]), 1)])
	Listes.tableau(lignes, ["Niveau", "Attaques d’entrée sans augment", "P90", "DPS permanent", "Boss final, s"], entrees)
	lignes.append_array(["Ce stress n’effectue aucune Mine ni Épreuve : il ne reçoit aucun passif ni Cœur, et manque de budget de forge. Il montre le retard accumulé si ces sources sont omises ; ses victoires supposées ne signifient pas que ce compte peut terminer la campagne.", "",
		"### Entrées après renforcement réellement financé", "",
		"Les trois comptes du parcours conditionnel reçoivent uniquement les coffres des salles validées, puis financent les activités et achats choisis aux murs. Le tableau prend leur état avant la tentative victorieuse. Les quatre premières salles restent mesurées sans augment. Le temps par monstre tient compte de la cadence, des critiques et du familier, à la même activité de tir que les autres modèles ; les attaques normales les excluent.", ""])
	var renforcees: Array = []
	for chapitre: int in rapport["entrees_renforcees"]:
		var entree: Dictionary = rapport["entrees_renforcees"][chapitre]
		renforcees.append([chapitre, n(float(entree["attaques"]["mediane"]), 1), n(float(entree["secondes"]["mediane"]), 1), n(float(entree["dps"]["mediane"])), n(float(entree["boss"]["mediane"]), 1)])
	Listes.tableau(lignes, ["Niveau", "Attaques normales à l’entrée", "Temps par monstre, s", "DPS permanent", "Boss final, s"], renforcees)
	var farms: Array = []
	for chapitre: int in rapport["farm"]:
		var farm: Dictionary = rapport["farm"][chapitre]
		farms.append([chapitre, int(RythmeProgression.REPRISES[chapitre - 1]), "+%s %%" % n(float(farm["gain_dps"]["mediane"]) * 100.0), "%s %%" % n(float(farm["gain_survie"]["mediane"]) * 100.0)])
	Listes.tableau(lignes, ["Niveau rejoué", "Reprises", "Gain médian de DPS permanent", "Variation de PV effectifs"], farms)
	lignes.append_array(["Ces gains comparent le compte juste avant et juste après les reprises, sans augment. Ils incluent uniquement les achats financés et le butin effectivement reçu. Une amélioration déjà acquise profite aussi aux anciennes armes et maîtrises sauvegardées. Le ressenti et le nombre de répétitions souhaitable restent à vérifier sur téléphone.", ""])

static func _rythme_boss(lignes: Array[String]) -> void:
	var rapport := RythmeBoss.rapport()
	var normale := Reglages.CAMPAGNE_BOSS_DUREE_NORMALE
	var signature := Reglages.CAMPAGNE_BOSS_DUREE_SIGNATURE
	lignes.append_array(["## Durée des boss avec un build équilibré", "",
		"**Cibles approximatives au niveau attendu : %s–%s secondes pour un boss ordinaire, %s–%s secondes pour le boss de fin de monde.** Des augments favorables aux dégâts rapprochent du bas, des tirages défavorables rapprochent du haut. Le full offensif et le sur-farm peuvent aller plus vite ; un compte sous-équipé peut dépasser ces repères." % [n(normale.x, 0), n(normale.y, 0), n(signature.x, 0), n(signature.y, 0)], "",
		"Les PV sont fixes. Aucun chronomètre, plafond de dégâts ou ajustement au héros ne force un combat dans ces intervalles. Les critères de confort du parcours utilisent leur borne haute pour mesurer le renforcement nécessaire ; ce sont des règles du modèle hors jeu.", "",
		"Pour chaque fin de monde, %d comptes ont réellement payé leur équipement et leurs améliorations avec les coffres du parcours conditionnel. Leur configuration précédant la première victoire est rejouée sur %d autres tirages équilibrés, sans filtrer les échecs et sans légendaire bonus. Les quatre boss sont mesurés, avec les augments disponibles avant leur salle." % [int(rapport["comptes"]), int(rapport["tirages"])], "",
		"Le temps estimé = PV du boss / (DPS × %s %% de tir utile), familier et critiques moyens inclus. Il exclut annonces et menus. P25 et P75 décrivent des tirages assez favorables ou défavorables aux dégâts ; P10–P90 montre une dispersion plus large. Ces quantiles ne sont pas des durées garanties, ni une mesure en partie." % n(RythmeBoss.Parcours.TIR_UTILE_BOSS * 100.0, 0), ""])
	var donnees: Array = []
	for cas: Dictionary in rapport["cas"]:
		var chapitre := int(cas["chapitre"]) - 1
		for salle: Dictionary in cas["salles"]:
			var duree: Dictionary = salle["duree"]
			donnees.append([Chapitres.libelle_court(chapitre), int(salle["salle"]), "Fin de monde" if bool(salle["signature"]) else "Ordinaire",
				"%s–%s" % [n(float(salle["cible_min"]), 0), n(float(salle["cible_max"]), 0)], n(float(duree["p25"]), 1),
				n(float(duree["mediane"]), 1), n(float(duree["p75"]), 1), "%s–%s" % [n(float(duree["p10"]), 1), n(float(duree["p90"]), 1)]])
	Listes.tableau(lignes, ["Niveau", "Salle", "Boss", "Cible, s", "P25, s", "Médiane, s", "P75, s", "P10–P90, s"], donnees)
	lignes.append("")

static func _calendrier_reprises() -> String:
	var etapes: Array[String] = []
	for chapitre: int in RythmeProgression.REPRISES:
		etapes.append("%d reprise(s) du niveau %d" % [int(RythmeProgression.REPRISES[chapitre]), chapitre + 1])
	return ", ".join(etapes)

static func _maturation_progression(lignes: Array[String]) -> void:
	var rapport := MaturationProgression.rapport()
	var couts: Dictionary = rapport["couts"]
	lignes.append_array(["## Effort pour atteindre les cinq plafonds", "",
		"La cible porte aussi sur le temps de progression : les cinq plafonds doivent rester dans une même période, avec au plus %s %% d’écart de temps total dans les parcours de référence. Le niveau maximum du héros doit rester à moins de %s %% du temps nécessaire aux dernières maîtrises. Ces marges contrôlent un modèle de progression ; elles ne garantissent pas le temps d’un joueur." % [n(Reglages.PROGRESSION_ECART_PLAFONDS * 100.0, 0), n(Reglages.PROGRESSION_ECART_HEROS_MAITRISES * 100.0, 0)], "",
		"Chaque compte part de zéro, paie tous ses achats et conserve les anciennes forges. Le scénario comprend l’échec initial en salle 9, puis les %d chapitres. Campagne prioritaire réserve les annexes à la fin ; Mixte ajoute une Mine et une Épreuve tous les trois chapitres quand elles sont accessibles. Les victoires sont supposées pour comparer l’économie, avec les vrais tirages, garanties, bonus économiques et durées de combat du modèle." % Chapitres.nombre(), "",
		"Ensuite, chaque cycle peut contenir deux replays du dernier chapitre, une Mine et trois Épreuves. Une activité n’est répétée que si sa progression manque encore : continuer à récolter une monnaie après avoir tout acheté fausserait la comparaison. Ce calendrier est une hypothèse de farm, pas une obligation de jeu.", "",
		"Le maximum signifie : niveau %d et tous ses points, les cinq emplacements équipés forge %d, les trois arbres complets, les %d passifs rang %d et leurs statistiques arrivées à maturité, puis les %d Cœurs. Forger toute la collection d’armes et de bijoux dépasse ce build complet et reste un objectif supplémentaire." % [Personnage.NIVEAU_MAX, Reglages.FORGE_NIVEAU_MAX, Passifs.CATALOGUE.size(), Passifs.RANG_MAX, Epreuves.nombre()], "",
		"Les étapes 50 et 75 % comptent le budget d’XP consommé, le coût courant des rangs possédés en forge et maîtrises, ou les acquisitions pour passifs et Cœurs. Ce ne sont pas des pourcentages de DPS. Les statistiques des passifs continuent de croître avec le héros, même après l’obtention des cartes.", "",
		"Budgets complets avant bonus de récompense : %d XP, %d Gouttes, %d Pierres pour cinq objets, %d acquisitions de passifs et %d Cœurs. Les Pierres investies dans les anciens objets ne sont jamais transférées ni remboursées par le scénario." % [int(couts["xp"]), int(couts["gouttes"]), int(couts["pierres"]), int(couts["rangs_passifs"]), int(couts["coeurs"])], ""])
	var noms := {"attributs": "Héros / attributs", "equipement": "Équipement actif", "maitrises": "Trois arbres de maîtrises", "passifs": "Passifs complets", "coeurs": "Cœurs de mana"}
	for strategie: String in MaturationProgression.STRATEGIES:
		var titre := "Campagne prioritaire" if strategie == "campagne" else "Mixte"
		lignes.append_array(["### " + titre, "",
			"Médianes de %d comptes ; temps cumulé depuis le compte neuf, en heures. Tir utile, choix et transitions suivent les mêmes hypothèses que les autres parcours." % int(rapport["nombre"]), ""])
		var tableau: Array = []
		for famille: String in MaturationProgression.FAMILLES:
			var etapes: Dictionary = rapport["strategies"][strategie][famille]
			var ligne: Array = [str(noms[famille])]
			for seuil: String in ["50", "75", "100"]:
				var distribution: Dictionary = etapes[seuil]
				ligne.append(n(float(distribution["mediane"]) / 3600.0)
					if int(distribution["mesures"]) == int(rapport["nombre"]) else "Non atteint")
			tableau.append(ligne)
		Listes.tableau(lignes, ["Famille", "50 %", "75 %", "Maximum"], tableau)
	lignes.append_array(["Le ressenti des premiers niveaux, la rentabilité du farm tardif et ces durées restent à confirmer sur téléphone. Un joueur privilégiant exclusivement un mode fera avancer les sources correspondantes plus vite ; les plafonds ne sont jamais verrouillés entre eux.", ""])

static func _ennemis(lignes: Array[String]) -> void:
	var salles := Reglages.SALLES_PAR_RUN
	lignes.append_array(["## Croissance des monstres", "",
		"Le niveau global va de 1 à %d : %d mondes × %d niveaux. Chaque tentative de campagne comporte %d salles." % [Chapitres.nombre(), Chapitres.MONDES.size(), Chapitres.CHAPITRES_PAR_MONDE, salles],
		"", "Avec p = niveau global − 1 et a = min(p, %d) : **facteur PV de niveau = %s^a × %s^(a × (a − 1) / 2) × %s^(p − a) × [1 + %s × (1 − %s^(p^%s))]**." % [Reglages.CAMPAGNE_PV_CHAPITRES_INITIAUX, n(Reglages.CAMPAGNE_PV_PAR_CHAPITRE, 4), n(Reglages.CAMPAGNE_PV_ACCELERATION, 4), n(Reglages.CAMPAGNE_PV_PAR_CHAPITRE_TARDIF, 4), n(Reglages.CAMPAGNE_PV_RENFORT_INITIAL), n(Reglages.CAMPAGNE_PV_TRANSITION), n(Reglages.CAMPAGNE_PV_TRANSITION_EXPOSANT)],
		"Avec b = max(p − %d, 0), **facteur dégâts de niveau = %s^p × %s^(p × (p − 1) / 2) × [1 + %s × (1 − %s^b)]**. Les non-boss appliquent aussi le coefficient global %s." % [Reglages.CAMPAGNE_PV_CHAPITRES_INITIAUX, n(Reglages.CAMPAGNE_DEGATS_PAR_CHAPITRE, 4), n(Reglages.CAMPAGNE_DEGATS_ACCELERATION, 4), n(Reglages.CAMPAGNE_DEGATS_RENFORT_TARDIF), n(Reglages.CAMPAGNE_DEGATS_TRANSITION_TARDIVE), n(Reglages.ENNEMI_DEGATS_MULT)], "",
		"Le premier chapitre reste à ×1. Le renfort arrive progressivement, puis tend vers ×%s. La croissance composée des niveaux suivants laisse davantage de place au renforcement vers la fin de campagne. Les dégâts gardent leur courbe distincte. Un changement de monde n’ajoute pas une seconde hausse cachée." % n(1.0 + Reglages.CAMPAGNE_PV_RENFORT_INITIAL),
		"", "Dans une tentative : facteur PV = %s^(salle − 1) × produit des paliers franchis ; facteur dégâts = %s^(salle − 1) × produit de leurs paliers. Les deux commencent à ×1." % [n(Reglages.CAMPAGNE_PV_PAR_SALLE, 4), n(Reglages.CAMPAGNE_DEGATS_PAR_SALLE, 4)],
		"Entre deux salles : +%s %% de PV et +%s %% de dégâts, avec les hausses supplémentaires du tableau. Ces paliers s’appliquent à l’entrée des salles indiquées et ne donnent aucun choix d’augment supplémentaire." % [n((Reglages.CAMPAGNE_PV_PAR_SALLE - 1.0) * 100.0), n((Reglages.CAMPAGNE_DEGATS_PAR_SALLE - 1.0) * 100.0)],
		"Les boss de campagne ajoutent un renfort de niveau [1 + %s × (1 − %s^b)], puis leur propre croissance de PV par salle : %s^(salle − 1), avec leurs propres paliers dans le tableau. Ils conservent ainsi des durées de combat distinctes de l’endurance des monstres ordinaires. Le renfort de dégâts après le premier monde rend les investissements en résistance utiles ; il tend vers ×%s sans s’emballer." % [n(Reglages.CAMPAGNE_PV_BOSS_RENFORT_TARDIF), n(Reglages.CAMPAGNE_PV_BOSS_TRANSITION_TARDIVE), n(Reglages.CAMPAGNE_PV_BOSS_PAR_SALLE, 4), n(1.0 + Reglages.CAMPAGNE_DEGATS_RENFORT_TARDIF)],
		"Le premier boss, à l’étage %d de chaque niveau, ajoute ×%s à ses PV pour alléger le combat avant le premier légendaire. Ce facteur concerne la campagne et figure dans les calculs de progression et les simulations ; les boss des autres étages et des annexes gardent leur endurance." % [int(Chapitres.par_index(0)["bosses"][0]), n(Chapitres.PV_PREMIER_BOSS_MULT)],
		"", "Les facteurs sont bornés à la dernière campagne. Ils ne lisent jamais les achats, les morts ni le build du joueur.", "", "### Facteurs par niveau, avant la salle", ""])
	var niveaux: Array = []
	for chapitre in Chapitres.nombre():
		niveaux.append([Chapitres.libelle_court(chapitre), "×" + n(ProgressionStatistiques.facteur_pv(chapitre)), "×" + n(ProgressionStatistiques.facteur_pv(chapitre) * ProgressionStatistiques.facteur_boss(chapitre)), "×" + n(ProgressionStatistiques.facteur_degats(chapitre))])
	Listes.tableau(lignes, ["Niveau", "PV ordinaires", "PV boss", "Dégâts"], niveaux)
	var paliers: Array = []
	var salles_paliers: Array[int] = []
	for courbe: Dictionary in [Reglages.CAMPAGNE_PV_PALIERS, Reglages.CAMPAGNE_PV_BOSS_PALIERS, Reglages.CAMPAGNE_DEGATS_PALIERS]:
		for salle: int in courbe:
			if salle not in salles_paliers: salles_paliers.append(salle)
	salles_paliers.sort()
	for salle: int in salles_paliers:
		paliers.append([salle, "×" + n(float(Reglages.CAMPAGNE_PV_PALIERS.get(salle, 1.0))),
			"×" + n(float(Reglages.CAMPAGNE_PV_BOSS_PALIERS.get(salle, 1.0))),
			"×" + n(float(Reglages.CAMPAGNE_DEGATS_PALIERS.get(salle, 1.0)))])
	Listes.tableau(lignes, ["Salle", "Hausse PV ordinaires", "Hausse PV boss", "Hausse dégâts supplémentaire"], paliers)
	lignes.append_array(["### Facteurs par salle, à multiplier par ceux du niveau", ""])
	var facteurs_salles: Array = []
	for salle in range(1, salles + 1):
		facteurs_salles.append([salle, "×" + n(Chapitres.facteur_pv(0, salle), 3), "×" + n(Chapitres.facteur_pv(0, salle, true), 3), "×" + n(Chapitres.facteur_degats(0, salle), 3)])
	Listes.tableau(lignes, ["Salle", "PV ordinaires", "PV boss", "Dégâts"], facteurs_salles)
	lignes.append_array(["### Élites, boss et modes annexes", "",
		"- **Élite** : PV ×%s ; dégâts ×%s. **Miniboss** : PV ×%s ; dégâts ×%s. **Boss signature** : PV ×%s avant coefficient propre au monde ; dégâts ×%s." % [n(RangsEnnemis.ELITE_PV), n(RangsEnnemis.ELITE_DEGATS), n(Reglages.MINIBOSS_PV_MULT * Reglages.BOSS_ENDURANCE_MULT), n(Reglages.MINIBOSS_DEGATS_MULT), n(Reglages.BOSS_SIGNATURE_PV_MULT * Reglages.BOSS_ENDURANCE_MULT), n(Reglages.BOSS_SIGNATURE_DEGATS_MULT)],
		"- **Épreuve** : même facteur de niveau, PV ×%s × (1 + %s)^t, dégâts ×%s × (1 + %s)^t. t va de 0 à 1 pendant les rencontres." % [n(Reglages.DEFI_PV_BASE), n(Reglages.DEFI_MONTEE_PV), n(Reglages.DEFI_DEGATS_BASE), n(Reglages.DEFI_MONTEE_DEGATS)],
		"- **Mine** : même facteur de niveau, PV ×%s × (1 + %s)^t, dégâts ×%s × (1 + %s)^t, t = temps / %s s borné entre 0 et 1." % [n(Reglages.MINE_PV_MULT), n(Reglages.MINE_MONTEE_PV), n(Reglages.MINE_DEGATS_MULT), n(Reglages.MINE_MONTEE_DEGATS), n(Reglages.MINE_DUREE)],
		"- **Boss de Mine** : facteur supplémentaire PV ×%s et dégâts ×%s. En Mine et Épreuve, tous les boss appliquent aussi ×%s PV ; pas les coefficients de rang de la campagne." % [n(Reglages.MINE_BOSS_PV_MULT), n(Reglages.MINE_BOSS_DEGATS_MULT), n(EvolutionEnnemis.ANNEXE_PV_BOSS * Reglages.BOSS_ENDURANCE_MULT)], "",
		"Les évolutions de comportement accélèrent certains tirs/déplacements et ajoutent des salves à leurs seuils ; elles n’ajoutent pas une autre croissance des PV.", ""])
	var signatures: Array = []
	for monde in Chapitres.MONDES.size():
		var chapitre := (monde + 1) * Chapitres.CHAPITRES_PAR_MONDE - 1
		var id := str(Chapitres.MONDES[monde]["boss_signature"])
		signatures.append([str(Chapitres.MONDES[monde]["nom"]), str(CatalogueEnnemis.par_id(id)["nom"]),
			"×" + n(float(Chapitres.MONDES[monde]["pv_signature_mult"])), "×" + n(Chapitres.facteur_boss_signature(chapitre) * Reglages.BOSS_ENDURANCE_MULT)])
	Listes.tableau(lignes, ["Monde", "Boss signature", "Coefficient propre de PV en campagne", "Facteur de rang final, hors niveau et salle"], signatures)
	lignes.append("")

static func _sources(lignes: Array[String]) -> void:
	lignes.append_array(["## Progression d’un équipement de fin de campagne", "",
		"Cette comparaison conserve un ensemble fixe du dernier monde : Alambic souverain + Golem de forge + anneau/bracelet/collier du monde V, tous forgés au maximum. Elle sert à lire les étapes d’achat ; la fiche optimisée du début utilise une autre sélection.", "",
		"Maîtrises = tous les rangs. Passifs = Vigueur, Célérité, Œil précis et Vitalité, chacun rang 2.",
		"Les étapes s’ajoutent dans cet ordre : leur gain marginal dépend donc de ce qui est déjà acheté. Aucune double attribution d’un pourcentage.", ""])
	var depart := Modeles.mesurer({})
	var precedent := float(depart["dps"])
	var donnees: Array = []
	for etape: Dictionary in Modeles.paliers_sources():
		var m := Modeles.mesurer(etape["build"])
		donnees.append([str(etape["nom"]), n(float(m["attaque"])), n(float(m["tir_moyen"])),
			"%s + %s = **%s**" % [n(float(m["dps_heros"])), n(float(m["dps_familier"])), n(float(m["dps"]))],
			"+%s %%" % n((float(m["dps"]) / precedent - 1.0) * 100.0), n(float(m["pv"])), n(float(m["defense"]))])
		precedent = float(m["dps"])
	Listes.tableau(lignes, ["Étape", "ATK", "Impact moyen", "DPS héros + familier", "Gain sur l’étape précédente", "PV", "Défense"], donnees)
	var maitrises_seules := Modeles.mesurer({"maitrises": Modeles.toutes_maitrises()})
	lignes.append("Maîtrises seules sur le matériel de départ : DPS %s, soit +%s %% par rapport au départ." % [n(float(maitrises_seules["dps"])), n((float(maitrises_seules["dps"]) / float(depart["dps"]) - 1.0) * 100.0)])
	lignes.append("")

static func _augments(lignes: Array[String]) -> void:
	lignes.append_array(["## Choix offensifs, mixtes ou défensifs", "",
		"Même budget ordinaire par exemple : %d rares, %d épiques et un légendaire, soit %d choix. Le légendaire bonus est désactivé dans ces références. Les offres restent aléatoires ; ces builds ne sont pas garantis." % [ProgressionAugments.niveau_max() - ProgressionAugments.NOMBRE_EPIQUES - 1, ProgressionAugments.NOMBRE_EPIQUES, ProgressionAugments.niveau_max()],
		"La référence est le profil complet précédent, sans les bonus conditionnels d’anneau. Les boucliers et soins ne sont pas inclus dans les PV effectifs.", ""])
	var base := Modeles.complet()
	var reference := Modeles.mesurer(base)
	var donnees: Array = []
	var compositions: Array[String] = []
	for nom: String in ProfilsAugments.PROFILS:
		var configuration := base.duplicate(true)
		configuration["augments"] = ProfilsAugments.PROFILS[nom]
		var m := Modeles.mesurer(configuration)
		var noms: Array[String] = []
		for id: String in ProfilsAugments.PROFILS[nom]: noms.append(CatalogueReactifs.par_id(id).nom)
		compositions.append("- **%s** : %s." % [nom.capitalize(), ", ".join(noms)])
		var boucliers := int(Mods.bonus_heros(Mods.depuis_l_inventaire(configuration["augments"]), "boucliers_salle_add"))
		donnees.append([nom.capitalize(), "%s (×%s)" % [n(float(m["dps"])), n(float(m["dps"]) / float(reference["dps"]))],
			n(float(m["pv"])), n(float(m["defense"])), "%s (×%s)" % [n(float(m["pv_effectifs"])), n(float(m["pv_effectifs"]) / float(reference["pv_effectifs"]))], boucliers])
	Listes.tableau(lignes, ["Orientation", "DPS", "PV", "Défense", "PV effectifs", "Coups bloqués par salle"], donnees)
	lignes.append_array(compositions)
	lignes.append("")

static func _economie(lignes: Array[String]) -> void:
	lignes.append_array(["## Pourquoi farmer", "",
		"La campagne seule sans rejouer limite le budget de forge et de maîtrises. Les Épreuves sont l’unique source de nouveaux passifs et de Cœurs.", "",
		"La Mine donne plus de Pierres par victoire, et les échecs avancés en rapportent déjà une partie. La progression permanente est conservée entre les tentatives.", "",
		"La Mine donne aussi %d XP de compte répartis sur ses %s minutes de survie, même en cas d’échec, puis %d XP supplémentaires pour le boss vaincu (%d au total avant bonus)." % [ButinsRun.XP_MINE_SURVIE, n(Reglages.MINE_DUREE / 60.0), ButinsRun.XP_MINE_BOSS, ButinsRun.XP_MINE_SURVIE + ButinsRun.XP_MINE_BOSS], "",
		"Un mur de statistiques signifie beaucoup de tirs pour tuer et très peu de coups supportés ; les augments de la tentative n’effacent pas un grand retard d’équipement.", "",
		"Ce n’est pas une interdiction de lancer le niveau ni une preuve qu’un joueur sans aucun coup reçu ne pourra jamais le terminer. Une difficulté ressentie doit encore être validée en jouant.", "", "### Rendement de la Mine, avant bonus de pierres", ""])
	var rendements: Array = []
	for niveau in [1, 8, 15, 22, 29, 35]:
		rendements.append([niveau, Reglages.pierres_mine(niveau - 1)])
	Listes.tableau(lignes, ["Palier de campagne correspondant", "Pierres par victoire complète"], rendements)
	var cout_forge := 0
	for niveau in Reglages.FORGE_NIVEAU_MAX: cout_forge += Reglages.cout_forge(niveau)
	lignes.append_array(["", "Forge complète d’un objet : %d Pierres. Cinq emplacements équipés : %d Pierres, hors achats sur d’anciens modèles." % [cout_forge, cout_forge * 5],
		"", "Les prix exacts sont dans la [liste des items](liste_items.md) et la [liste des maîtrises](liste_maitrises.md).", ""])

static func _comparer_farm(lignes: Array[String]) -> void:
	var budget := ProfilCampagne.budget()
	var campagne := ProfilCampagne.construire()
	var complet := Modeles.complet()
	complet["conditions"] = true
	var chapitre := Chapitres.nombre() - 1
	var salle := Reglages.SALLES_PAR_RUN
	var d: Dictionary = Chapitres.par_index(chapitre)
	var boss: Dictionary = CatalogueEnnemis.par_id(str(d["boss"]))
	var fragile: Dictionary = CatalogueEnnemis.par_id("encrier_rampant")
	var facteur_pv := Chapitres.facteur_pv(chapitre, salle)
	var facteur_degats := Chapitres.facteur_degats(chapitre, salle)
	var boss_pv := float(boss["pv"]) * Chapitres.facteur_pv(chapitre, salle, true) * Chapitres.facteur_boss_signature(chapitre) * Reglages.BOSS_ENDURANCE_MULT
	var boss_degats := float(boss["degats"]) * facteur_degats * Reglages.BOSS_SIGNATURE_DEGATS_MULT
	var fragile_pv := float(fragile["pv"]) * facteur_pv
	var fragile_degats := float(fragile["degats"]) * facteur_degats * Reglages.ENNEMI_DEGATS_MULT
	lignes.append_array(["## Contre-épreuve : accorder toutes les victoires sans farm", "",
		"Cette comparaison accorde hypothétiquement toutes les victoires jusqu’au dernier niveau pour tester les limites du budget de campagne. Elle **ne prétend pas que ce joueur aurait réellement franchi les murs précédents**.", "",
		"- **Campagne seule hypothétique** : une victoire complète accordée sur chacun des %d premiers niveaux, sans répétition, Mine ni Épreuve." % int(budget["chapitres_vaincus"]),
		"- **Budget de base** : %d à %d Gouttes, %d Pierres, %d XP, soit niveau %d et %d points." % [int(budget["gouttes_min"]), int(budget["gouttes_max"]), int(budget["pierres"]), int(budget["xp"]), int(budget["niveau"]), int(budget["points_attributs"])],
		"- Les bonus économiques, élites et échecs ne sont pas comptés. Les derniers modèles d’équipement sont accordés, sans coût de forge perdu sur les anciens : c’est un scénario explicite, pas une borne optimale.",
		"- **Achats retenus** : %d Gouttes de maîtrises et %d Pierres. Arme forge 10, anneau et bracelet forge 8, collier forge 5, familier forge 1." % [int(budget["cout_maitrises"]), int(budget["cout_forge"])],
		"- **Attributs** : 25 Force, 35 Vitalité, 15 Agilité, 20 Intelligence. Aucun passif et aucun Cœur. Tous les achats sont finançables même avec les coffres minimum.",
		"- **Profil développé** : l’ensemble fixe du dernier monde présenté plus haut, avec effet d’anneau à son maximum. Les deux profils restent sans augment pour comparer leurs fondations.", "",
		"Dernière salle du dernier niveau : fragile %s PV / %s dégâts bruts ; boss %s PV / %s dégâts bruts." % [n(fragile_pv), n(fragile_degats), n(boss_pv), n(boss_degats)], ""])
	var donnees: Array = []
	for profil: Dictionary in [{"nom": "Campagne seule, achats ci-dessus", "build": campagne}, {"nom": "Profil développé par le farm", "build": complet}]:
		var m := Modeles.mesurer(profil["build"])
		donnees.append([str(profil["nom"]), n(float(m["dps"])), n(float(m["pv_effectifs"])),
			n(fragile_pv / float(m["tir_moyen"])), n(float(m["pv_effectifs"]) / fragile_degats),
			n(float(m["pv_effectifs"]) / boss_degats), n(boss_pv / float(m["dps"]))])
	Listes.tableau(lignes, ["Profil", "DPS", "PV effectifs", "Impacts pour tuer le fragile", "Contacts de fragile supportés", "Coups de boss supportés", "Secondes de tir idéal sur le boss"], donnees)
	lignes.append_array(["Moins de 1 coup supporté signifie qu’un seul coup tue, hors Sursis. Le temps sur le boss est théorique, avant augments et temps d’esquive.", ""])
