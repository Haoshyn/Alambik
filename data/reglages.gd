class_name Reglages
extends RefCounted

# Source unique de l'equilibrage. Aucune de ces valeurs ne doit reapparaitre
# en dur ailleurs : les regler ne doit jamais demander de relire le combat.
#
# Ecart assume par rapport au plan : classe globale de constantes plutot
# qu'autoload. Un autoload n'existe que dans une SceneTree ; les suites de
# tests headless doivent pouvoir lire l'equilibrage sans en monter une.

# Le niveau de compte mesure l'avancement sans ajouter de statistiques.
# Equipement, maitrises et capacites debloquees portent la puissance permanente.
const NIVEAU_DEGATS_PAR_NIVEAU := 0.0
const NIVEAU_PV_PAR_NIVEAU := 0.0
const NIVEAU_CADENCE_PAR_NIVEAU := 0.0
# Hypothese non mesuree : niveau 30 vers la fin des 35 chapitres,
# avec 3 a 5 tentatives par chapitre, farm compris.
const NIVEAU_REFERENCE_FIN := 30
const XP_COMPTE_BASE := 10.0
const XP_COMPTE_PENTE := 4.0
const XP_COMPTE_QUADRATIQUE := 0.35

# Bases lisibles du premier chapitre, avant equipement et maitrises.
const HEROS_PV := 100.0
const HEROS_DEFENSE := 10.0
const HEROS_VITESSE := 560.0
const HEROS_ACCELERATION := 3100.0
const HEROS_FREINAGE := 4200.0
const HEROS_CADENCE := 1.6          # tirs par seconde
const HEROS_INVULNERABILITE := 0.6  # secondes apres un coup recu
const HEROS_RAYON := 20.0
const HEROS_ECHELLE := 0.78
const APPRENTISSAGE_DISTANCE_DEPLACEMENT := 96.0
const APPRENTISSAGE_GRACE_FIN := 1.2
# Repere conserve pour les outils historiques, jamais un plancher de combat.
const DEGATS_COUP_REFERENCE := 15.0
const SOIN_COMBAT_PAR_SALLE := 0.05
const INVOCATION_BOSS_INTERVALLE := 18.0
const INVOCATION_BOSS_SALVE := 2
const INVOCATION_BOSS_PLAFOND := 3
const INVOCATION_PV_MULT := 0.25
const INVOCATION_DEGATS_MULT := 0.50
const RECHARGE_PLANCHER := 0.45
const GEL_SORT_DUREE := 1.5
const GEL_ULTIME_DUREE := 3.0
const SORT_REPOUSSEE := 120.0
const GOUTTES_PAR_SALLE := 3
const ENNEMI_VITESSE_MULT := 1.12
# La densite ne suffit pas si chaque creature laisse trop de temps au joueur.
# Ces trois multiplicateurs renforcent la menace sans gonfler leurs PV : coups
# un peu plus lourds, projectiles plus difficiles a distancer et attaques plus
# frequentes. Les telegraphes restent inchanges, donc le danger reste lisible.
const ENNEMI_DEGATS_MULT := 1.00
const ENNEMI_PROJECTILE_VITESSE_MULT := 1.08
const ENNEMI_RECHARGE_MULT := 0.92
const ENNEMI_HITBOX_MULT := 0.72
const BOSS_HITBOX_MULT := 0.74

const TIR_DEGATS := 10.0
const MODS_PLANCHER := 0.05
const PROJECTILE_SUPPLEMENTAIRE_PART := 0.45
# Mesure : la creature la plus rapide file a 704 px/s. A 900, le projectile
# n'allait qu'a 1,28 fois sa vitesse et se faisait esquiver systematiquement ;
# un tir doit devancer sa cible d'un facteur deux au minimum.
const TIR_VITESSE := 1550.0
const TIR_RAYON := 10.0
# Reference utilisee seulement lorsqu'un effet reduit explicitement la portee.
# Sans reduction, un projectile vit jusqu'a un mur, une limite ou une cible.
const TIR_PORTEE := 1400.0
const TIR_DELAI_ARRET := 0.12       # temps d'arret avant que le tir reprenne
const TIR_PREPARATION := 0.05      # anticipation du bras avant la projection

const BRAISE_PART_DEGATS_PAR_SECONDE := 0.10
const BRAISE_DUREE := 4.0
const GIVRE_RALENTISSEMENT := 0.45  # facteur de vitesse applique
const GIVRE_DUREE := 2.0
const ACIDE_VULNERABILITE := 1.25   # multiplicateur de degats subis
const ACIDE_DUREE := 4.0
const REGENERATION_PART := 0.05
const AVIDITE_XP_MULT := 1.30
const AVIDITE_GOUTTES_MULT := 1.30
const COURAGEUX_RETOUR_PV := 1.0
const MANNEQUIN_DEBUT := 0.5
const MANNEQUIN_FIN := 1.5
const MANNEQUIN_BONUS_MAX := 0.50
const RETARDEMENT_DELAI := 2.0
const EGIDE_REDUCTION := 0.50
const FAMILIER_TIREUR_ATTAQUE_MULT := 1.30
const FAMILIER_TIREUR_CADENCE_MULT := 1.20
const FAMILIER_TIR_INTERVALLE := 0.75
const FAMILIER_TIR_PART_DEGATS := 0.60
# Le familier tire depuis ce decalage, pas depuis le heros. Sa visee doit donc
# partir de la aussi : calculee depuis le heros, elle ratait de tout l'angle
# separant les deux points, d'autant plus visiblement que la cible etait proche.
const FAMILIER_DECALAGE := Vector2(72.0, -36.0)

# Viser ou la cible sera, pas ou elle est. Partage par le heros et le familier :
# une cible qui recule en ligne droite n'etait presque jamais touchee.
const ANTICIPATION_DUREE_MAX := 0.8
const ANTICIPATION_PART := 0.9
const METEORE_INTERVALLE := 3.0
const METEORE_PART_DEGATS := 3.0
const METEORE_RAYON := 220.0
const ZONE_HEROS_INTERVALLE := 0.50
const ZONE_HEROS_PART_DEGATS := 0.45
const ZONE_HEROS_RAYON := 210.0
const GARDIEN_INTERVALLE := 0.80
const GARDIEN_PART_DEGATS := 0.60
const GARDIEN_PV := 55.0
const GARDIEN_REAPPARITION := 5.0
const ORBE_RAYON := 150.0
const ORBE_PART_DEGATS := 1.0
# Un eclat qui frappe presque aussi fort que le tir d'origine transforme
# Eclat de verre en multiplicateur : c'etait la moitie des mains cassees.
const FRAGMENT_PART_DEGATS := 0.30
const FRAGMENT_PORTEE := 260.0
# Un trait qui traverse quatre ennemis en frappant chacun a pleine puissance
# est un multiplicateur deguise : il perd de la force a chaque cible, et a
# chaque rebond. C'est ce qui separe une bonne main d'une main cassee.
# Perforation et Ricochet sont des choix de trajectoire : ils doivent rester
# interessants dans les vagues denses au lieu de perdre un tiers de leur force
# des la premiere cible secondaire.
const PERFORATION_PERTE := 0.20
const REBOND_PERTE := 0.20
const HOMING_ROTATION_PAR_SECONDE := 8.0

# Ameliorations ajoutees au pool. Leurs valeurs pures vivent dans le catalogue ;
# seules celles que la logique doit lire sont ici.
const PEAU_DE_PIERRE_REDUCTION := 0.20
const SOIF_DE_SANG_PART := 0.01       # part des PV max rendue par elimination
const CHAINE_INTERVALLE := 1.4
const CHAINE_PART_DEGATS := 2.0
const CHAINE_CIBLES := 5
const CHAINE_PORTEE := 460.0          # distance maximale entre deux maillons

# Passifs. Une decouverte puis un doublon : le rang 2 double exactement l'effet.
const PASSIF_RANG_MAX := 2
const MOISSON_SEUIL := 6
const MOISSON_PART := 0.025
const REPRISE_DELAI := 10.0
const REPRISE_DEGATS := 0.15
const HERITAGE_AUGMENTS_RARES := 1
const RELANCES_MAX_PAR_RUN := 3
const CONTRAT_PART_DEGATS := 0.10
const CONTRAT_DUREE := 2.0
const CONTRAT_INTERVALLE := 1.0
const CONTRAT_RAYON := 64.0
const SORT_IMPRECATEUR_DEGATS := 0.15
const SORT_IMPRECATEUR_DUREE := 5.0
const SANG_FROID_RALENTISSEMENT := 0.10
const SANG_FROID_DUREE := 2.0
const AUDACE_BONUS := 0.20

const SCEAU_GARDE_REDUCTION := 0.15
const SCEAU_RUINE_VULNERABILITE := 1.15

const ONDE_CHOC_INTERVALLE := 3.0
const ONDE_CHOC_RAYON := 330.0
const ONDE_CHOC_PART_DEGATS := 2.0
const ONDE_CHOC_REPOUSSEE := 300.0

const ELAN_VITAL_CHARGE := 1.0
const ELAN_VITAL_PORTEE := 2400.0

const RAFALE_NOMBRE := 3
const RAFALE_INTERVALLE := 0.07

# La zone praticable suit le bord interieur de la peinture. L'ancienne limite
# englobait les remparts : les personnages semblaient traverser la pierre.
const ARENE_MARGE_LATERALE := 78.0
const ARENE_HAUT := 244.0
const ARENE_BAS := 220.0
const ARENE_MUR_EPAISSEUR := 72.0
const ARENE_TAILLE := Vector2(1260.0,1900.0)
const ARENE_CAMERA_ZOOM := 1.05
const ARENE_PASSAGE_MIN := 240.0
const ARENE_COMPOSITIONS := [
	[Rect2(0.32,0.42,0.36,0.07)],
	[Rect2(0.27,0.25,0.09,0.24),Rect2(0.64,0.57,0.09,0.20)],
	[Rect2(0.25,0.26,0.12,0.08),Rect2(0.64,0.26,0.10,0.08),Rect2(0.43,0.66,0.16,0.07)],
	[Rect2(0.26,0.30,0.23,0.06),Rect2(0.52,0.65,0.23,0.06)],
	[Rect2(0.43,0.30,0.14,0.35)],
	[Rect2(0.25,0.25,0.10,0.07),Rect2(0.65,0.25,0.10,0.07),Rect2(0.25,0.67,0.10,0.07),Rect2(0.65,0.67,0.10,0.07)],
	[Rect2(0.27,0.30,0.11,0.32),Rect2(0.64,0.43,0.10,0.10)],
	[Rect2(0.34,0.27,0.32,0.06),Rect2(0.40,0.66,0.20,0.10)],
]
# Retraits du sol raccordes aux collisions, hors de l'entree et du portail.
const ARENE_RETRAITS := [
	[],
	[Rect2(0.0,0.68,0.09,0.10)],
	[Rect2(0.91,0.53,0.09,0.12)],
	[Rect2(0.0,0.61,0.10,0.13)],
	[Rect2(0.0,0.22,0.09,0.15),Rect2(0.91,0.65,0.09,0.12)],
	[],
	[Rect2(0.89,0.74,0.11,0.09)],
	[Rect2(0.0,0.46,0.11,0.10),Rect2(0.91,0.46,0.09,0.10)],
]
const ECHELLE_VISUELLE_COMBAT := 1.08

# La longueur d'un chapitre et la place de ses alambics vivent dans
# data/chapitres.gd : ces constantes ne servent plus qu'au repli, quand aucun
# chapitre n'est charge.
const SALLES_PAR_RUN := 20

# La courbe entre chapitres vit dans data/progression_statistiques.gd.

# La campagne laisse de la marge au build dans les premieres salles, puis exige
# que sa puissance acquise suive la densite. Ces bases ne touchent que la courbe
# interne d'une run : la progression entre chapitres reste intacte.
const CAMPAGNE_PV_DEPART := 1.00
const CAMPAGNE_DEGATS_DEPART := 1.00
# Les dix choix de niveau et les trois choix de palier donnent au profil median
# environ x2,05 de degats utiles en fin de run. Les PV suivent ce profil ; les
# degats montent moins vite afin que l'esquive reste la reponse principale.
const MONTEE_PV := 1.05          # x2,05 entre la premiere et la derniere salle
const MONTEE_DEGATS := 0.38      # x1,38 sur les degats
const DEFI_MONTEE_PV := 1.0       # x2 entre la premiere et la derniere rencontre
const DEFI_MONTEE_DEGATS := 0.45  # x1,45 : la densite porte deja la pression
const DEFI_PV_BASE := 1.25
const DEFI_DEGATS_BASE := 0.75

# Un Amélioration se reprend, mais pas indefiniment : six choix doivent construire
# un build, pas empiler automatiquement la meme carte.
const COPIES_MAX := 3
const SOIN_AVANT_BOSS := 0.30
const VISEE_VITESSE_TEMPS := 0.10

# Avec ~154 ennemis communs par chapitre, l'ancien bareme donnait les six choix
# beaucoup trop tot. Ces seuils replacent approximativement les choix 2/4/5/6
# avant les salles 5/10/15/20, meme avec les nouvelles vagues plus denses.
const XP_RUN_SEUILS := [10, 26, 55, 80, 145, 220]

# Les 170 victoires du parcours de reference donnent au moins 11 560 Gouttes
# meme sans compter la croissance. Les reprises et annexes financent les
# variantes ; completer les trois branches reste un objectif de tres long terme.
const MAITRISE_COUTS := [10, 15, 25, 40, 60, 100, 150, 250, 400, 600]
const MAITRISE_VERSION := 3
const MAITRISE_COUT_MAJEUR := 4
const MAITRISE_RANG_MAX := 10
const MAITRISE_COUT_AJOUT_PAR_RANG := 0.25
const COUT_PAS_ARRONDI := 5
const GOUTTES_MULT_PAR_CHAPITRE := 1.055

# L'ATK equipee porte la courbe de campagne ; les rangs renforcent les sorts
# sans ajouter une seconde croissance automatique avec le chapitre.
const CAPACITE_RANG_MAX := 10
const CAPACITE_BONUS_PAR_RANG := 0.10
# Une premiere capacite manquante est garantie ; cette limite porte les doublons.
const EPREUVE_GARANTIE_CAPACITE := 5
const EPREUVE_GARANTIE_COEUR := 10
const COEUR_MANA_BONUS_FINAL := 0.10
const EPREUVE_NIVEAU_DEBLOCAGE := 2
const MINE_NIVEAU_DEBLOCAGE := 4

# Vingt niveaux remplacent les cent : un nouveau niveau regroupe cinq anciens
# achats, puissance et cout cumule compris. La version 1 passait deja par un
# regroupement par deux ; la migration se fait donc en deux etapes.
const FORGE_VERSION := 3
const FORGE_ANCIEN_NIVEAU_MAX := 60
const FORGE_REGROUPEMENT := 2
const FORGE_NIVEAU_MAX_AVANT_COMPRESSION := 100
const FORGE_COMPRESSION := 5
const FORGE_NIVEAU_MAX := 20
const FORGE_COUT_BASE := 10
const FORGE_COUT_PAR_NIVEAU := 2
const PIERRES_CAMPAGNE_PAR_SALLE := 1.0
const PIERRES_CAMPAGNE_VICTOIRE := 5.0
const PIERRES_CAMPAGNE_CROISSANCE := 0.08
const MINE_PIERRES_RECOMPENSE := 80
const MINE_PIERRES_PAR_PALIER := 6
# Le boss complete la recompense ; une defaite finance deja la reprise.
const MINE_PIERRES_PART_SURVIE := 0.65

static func cout_maitrise(cout_base: int, rang_acquis: int) -> int:
	var brut := float(cout_base) * (1.0 + MAITRISE_COUT_AJOUT_PAR_RANG * float(maxi(0, rang_acquis)))
	return maxi(COUT_PAS_ARRONDI, roundi(brut / float(COUT_PAS_ARRONDI)) * COUT_PAS_ARRONDI)

static func cout_forge(niveau_acquis: int) -> int:
	var niveau := clampi(niveau_acquis, 0, FORGE_NIVEAU_MAX - 1)
	var total := 0
	for ancien_niveau in range(niveau * FORGE_COMPRESSION, (niveau + 1) * FORGE_COMPRESSION):
		var brut := float(FORGE_COUT_BASE + FORGE_COUT_PAR_NIVEAU * ancien_niveau)
		total += maxi(COUT_PAS_ARRONDI,
			roundi(brut / float(COUT_PAS_ARRONDI)) * COUT_PAS_ARRONDI)
	return total

static func pierres_mine(palier: int) -> int:
	return MINE_PIERRES_RECOMPENSE + MINE_PIERRES_PAR_PALIER * maxi(0, palier)

# Les annexes suivent la puissance brute du chapitre atteint sans reprendre la
# douceur pedagogique des premiers chapitres de campagne.
static func facteur_annexe_pv(palier: int) -> float:
	return ProgressionStatistiques.facteur_pv(palier)

static func facteur_annexe_degats(palier: int) -> float:
	return ProgressionStatistiques.facteur_degats(palier)

# La Mine est une survie complete : peu de pression au depart, une horde qui
# monte pendant cinq minutes, puis un boss. Les multiplicateurs s'appliquent
# progressivement aux ennemis apparus, pas retroactivement a ceux deja presents.
const MINE_DUREE := 300.0
const MINE_INTERVALLE_DEBUT := 1.40
const MINE_INTERVALLE_FIN := 0.45
const MINE_PLAFOND_DEBUT := 4
const MINE_PLAFOND_FIN := 14
const MINE_PV_MULT := 0.75
const MINE_DEGATS_MULT := 0.30
const MINE_MONTEE_PV := 2.0
const MINE_MONTEE_DEGATS := 1.0
const MINE_BOSS_PV_MULT := 2.00
const MINE_BOSS_DEGATS_MULT := 0.80
const MINE_SOIN_NIVEAU := 0.30
const MINE_CAMERA_ZOOM := 0.74

# Plus de vagues ne doit pas provoquer une avalanche instantanee chez un joueur
# un peu en retard. Un joueur puissant declenche toujours la suivante des que la
# vague est nettoyee ; ce delai ne ralentit donc jamais artificiellement un clear.
const DELAI_VAGUE_FORCE := 8.5
# Un invocateur qui produit plus vite qu'on ne tue rend la salle infinie : la
# sonde a bloque deux fois dessus. Le plafond est une regle de jeu, pas un
# pansement — il borne aussi ce que l'ecran doit rester capable d'afficher.
const PLAFOND_ENNEMIS := 10

# La courbe de chapitre porte la progression ; aucun second crescendo de PV.
# Recalibres sur l'attaque de reference 14, sans ancien bonus final d'arme :
# environ 40 attaques pour un miniboss salle 5 et 70 pour une signature salle 20.
const MINIBOSS_PV_MULT := 2.28
const BOSS_SIGNATURE_PV_MULT := 2.50
const MINIBOSS_DEGATS_MULT := 1.00
const BOSS_SIGNATURE_DEGATS_MULT := 1.10
const BOSS_PROJECTILE_VITESSE_MULT := 1.20
const BOSS_CADENCE_MOTIF_MULT := 0.90
const BOSS_APPARITION_DUREE := 0.85
const BOSS_TELEGRAPHE_SIGNATURE := 0.72
const BOSS_CADENCES_SIGNATURE := {
	"griffure": 0.58, "echo_errata": 0.72, "quadrillage": 0.68,
	"machoire": 0.76, "calligraphie": 0.15, "indexation": 0.48,
	"onde_marge": 0.74, "rosace": 0.88, "estampille": 0.82,
	"copie_double": 0.52, "frontieres_encre": 0.78, "remparts_terre": 0.92,
	"marees_eau": 0.68, "couloirs_air": 0.50, "foyers_feu": 1.02,
}
const BOSS_DUREES_MOTIFS := {
	"barrage_horizontal": 3.0, "eventail_lent": 3.2, "barrage_croise": 3.4,
	"invocation": 1.2, "charge": 2.6, "spirale": 3.1, "anneau_breche": 3.2,
	"pluie": 3.0, "poursuite": 2.8, "griffure": 2.9, "echo_errata": 3.0,
	"quadrillage": 3.1, "machoire": 3.0, "calligraphie": 3.1, "indexation": 2.9,
	"onde_marge": 3.0, "rosace": 3.1, "estampille": 3.0, "copie_double": 3.0,
	"frontieres_encre": 3.2, "remparts_terre": 3.1, "marees_eau": 3.2,
	"couloirs_air": 3.0, "foyers_feu": 3.3,
	"pause_phase_1": 1.15, "pause_phase_2": 0.90,
}

const PORTAIL_RAYON := 82.0
