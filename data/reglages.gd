class_name Reglages
extends RefCounted

# Source unique de l'equilibrage. Aucune de ces valeurs ne doit reapparaitre
# en dur ailleurs : les regler ne doit jamais demander de relire le combat.
#
# Ecart assume par rapport au plan : classe globale de constantes plutot
# qu'autoload. Un autoload n'existe que dans une SceneTree ; les suites de
# tests headless doivent pouvoir lire l'equilibrage sans en monter une.

# Le niveau apporte un petit socle ; les points repartis portent l'essentiel
# de sa progression et restent distincts des multiplicateurs permanents.
const NIVEAU_DEGATS_PAR_NIVEAU := 0.01
const NIVEAU_PV_PAR_NIVEAU := 0.005
const NIVEAU_CADENCE_PAR_NIVEAU := 0.0
# Plafond commun au bareme d'XP et aux outils de dotation complete.
const NIVEAU_REFERENCE_FIN := 30
const XP_COMPTE_BASE := 10.0
const XP_COMPTE_PENTE := 4.0
const XP_COMPTE_QUADRATIQUE := 0.35
# Objectifs d'effort verifies hors ligne sur les parcours economiques.
const PROGRESSION_ECART_PLAFONDS := 0.20
const PROGRESSION_ECART_HEROS_MAITRISES := 0.10

# Bases lisibles du premier chapitre, avant equipement et maitrises.
const HEROS_PV := 100.0
const HEROS_DEFENSE := 10.0
const DEFENSE_REFERENCE := 100.0
const CRITIQUE_MULT_BASE := 1.50
const HEROS_VITESSE := 728.0
const HEROS_ACCELERATION := 3100.0
const HEROS_FREINAGE := 4200.0
const HEROS_CADENCE := 1.6          # tirs par seconde
const HEROS_INVULNERABILITE := 0.6  # secondes apres un coup recu
const HEROS_ECHELLE := 1.15
# Le cercle suit le mage tout en gardant une marge d'esquive sous sa silhouette.
const HEROS_RAYON := 22.0 * HEROS_ECHELLE
# Repere conserve pour les outils historiques, jamais un plancher de combat.
const SOIN_COMBAT_PAR_SALLE := 0.05
const INVOCATION_BOSS_INTERVALLE := 18.0
const INVOCATION_BOSS_SALVE := 2
const INVOCATION_BOSS_PLAFOND := 3
const INVOCATION_PV_MULT := 0.25
const INVOCATION_DEGATS_MULT := 0.50
const GOUTTES_PAR_SALLE := 3
const ENNEMI_VITESSE_MULT := 1.288
# La densite ne suffit pas si chaque creature laisse trop de temps au joueur.
# Les projectiles et les recharges portent le rythme ; EvolutionEnnemis
# le fait progresser tout en preservant une duree minimale d'annonce.
const ENNEMI_DEGATS_MULT := 1.00
const ENNEMI_PROJECTILE_VITESSE_MULT := 1.50
const ENNEMI_RECHARGE_MULT := 0.92
const ENNEMI_HITBOX_MULT := 0.72
const BOSS_HITBOX_MULT := 0.74
const ENNEMI_APPARITION_DUREE := 0.35
const ENNEMI_TELEGRAPHE_MIN := 0.60
const ENNEMI_CONTACT_ANNONCE := 0.48
const ENNEMI_CONTACT_MARGE := 24.0
const PHASE_ANNONCE := 0.85
const PHASE_PREPARATION_TIR := 0.70

const TIR_DEGATS := 10.0
const MODS_PLANCHER := 0.05
# Mesure : la creature la plus rapide file a 704 px/s. A 900, le projectile
# n'allait qu'a 1,28 fois sa vitesse et se faisait esquiver systematiquement ;
# un tir doit devancer sa cible d'un facteur deux au minimum.
const TIR_VITESSE := 1937.5
const TIR_RAYON := 10.0
# Reference utilisee seulement lorsqu'un effet reduit explicitement la portee.
# Sans reduction, un projectile vit jusqu'a un mur, une limite ou une cible.
const TIR_PORTEE := 1400.0
const TIR_DELAI_ARRET := 0.12       # temps d'arret avant que le tir reprenne
const TIR_PREPARATION := 0.05      # anticipation du bras avant la projection

const BRAISE_PART_DEGATS_PAR_SECONDE := 0.10
const BRAISE_DUREE := 4.0
const GIVRE_RALENTISSEMENT := 0.45  # facteur de vitesse applique
const GIVRE_DUREE := 2.5
const ACIDE_VULNERABILITE := 1.25   # multiplicateur de degats subis
const ACIDE_DUREE := 4.0
# Viser ou la cible sera, pas ou elle est. Partage par le heros et le familier :
# une cible qui recule en ligne droite n'etait presque jamais touchee.
const ANTICIPATION_DUREE_MAX := 0.8
const ANTICIPATION_PART := 0.9
# Un projectile traversant plusieurs cibles perd une part fixe de puissance.
const PERFORATION_PERTE := 0.20
const REBOND_PERTE := 0.10
const HOMING_ROTATION_PAR_SECONDE := 10.0

const RELANCES_MAX_PAR_RUN := 3

const RAFALE_INTERVALLE := 0.07

# La zone praticable suit le bord interieur de la peinture. L'ancienne limite
# englobait les remparts : les personnages semblaient traverser la pierre.
const ARENE_MARGE_LATERALE := 78.0
const ARENE_HAUT := 244.0
const ARENE_BAS := 220.0
const ARENE_MUR_EPAISSEUR := 72.0
const ARENE_TAILLE := Vector2(1197.0,1995.0)
const ARENE_CAMERA_ZOOM := 0.9975
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

# Chaque chapitre garde le meme nombre de salles ; les boss et les choix
# occupent les emplacements definis dans Chapitres.
const SALLES_PAR_RUN := 20

# Les ennemis suivent une courbe fixe ; les ressources annexes permettent
# de prendre de l'avance sans adapter la difficulte au joueur.
const CAMPAGNE_PV_PAR_CHAPITRE := 1.045
const CAMPAGNE_PV_CHAPITRES_INITIAUX := 7
const CAMPAGNE_PV_PAR_CHAPITRE_TARDIF := 1.11
const CAMPAGNE_PV_BOSS_RENFORT_TARDIF := 1.10
const CAMPAGNE_PV_BOSS_TRANSITION_TARDIVE := 0.93
# Cibles du build equilibre ; elles ne bornent jamais un combat joue.
const CAMPAGNE_BOSS_DUREE_NORMALE := Vector2(30.0, 45.0)
const CAMPAGNE_BOSS_DUREE_SIGNATURE := Vector2(45.0, 60.0)
const CAMPAGNE_PV_ACCELERATION := 1.0
# Le renfort arrive progressivement : les premieres salles restent accessibles
# sans augment. La croissance composee reporte le besoin de farm vers la fin.
const CAMPAGNE_PV_RENFORT_INITIAL := 1.9
const CAMPAGNE_PV_TRANSITION := 0.94
const CAMPAGNE_PV_TRANSITION_EXPOSANT := 1.5
const CAMPAGNE_DEGATS_PAR_CHAPITRE := 1.04
const CAMPAGNE_DEGATS_ACCELERATION := 1.0002
# Apres le premier monde, le socle seul ne suffit plus a encaisser longtemps.
# Le renfort borne preserve une marge pour les comptes qui investissent en PV.
const CAMPAGNE_DEGATS_RENFORT_TARDIF := 1.20
const CAMPAGNE_DEGATS_TRANSITION_TARDIVE := 0.90
# Les monstres ordinaires suivent la puissance des augments. Les boss gardent
# leur propre rythme de PV pour eviter d'allonger tous leurs combats.
const CAMPAGNE_PV_PAR_SALLE := 1.12
const CAMPAGNE_PV_BOSS_PAR_SALLE := 1.045
const CAMPAGNE_DEGATS_PAR_SALLE := 1.023
# Les paliers suivent les choix deja recus, sans lire l'inventaire du joueur.
const CAMPAGNE_PV_PALIERS := {2: 1.08, 4: 1.45, 9: 1.70, 15: 1.20}
const CAMPAGNE_PV_BOSS_PALIERS := {3: 1.08, 5: 1.15, 10: 1.70, 15: 1.20}
const CAMPAGNE_DEGATS_PALIERS := {5: 1.05, 10: 1.05, 15: 1.05}
# Les premiers choix restent accessibles avant le crescendo geometrique.
const DEFI_MONTEE_PV := 1.0       # x2 entre la premiere et la derniere rencontre
const DEFI_MONTEE_DEGATS := 0.45  # x1,45 : la densite porte deja la pression
const DEFI_PV_BASE := 2.50
const DEFI_DEGATS_BASE := 1.00

# Les choix de Mine suivent les eliminations pendant la survie.
# La campagne emploie son propre calendrier dans ProgressionAugments.
const XP_RUN_SEUILS := [10, 26, 55, 80, 145, 220]

# Le prix d'un rang augmente lineairement ; aucune sequence d'achats n'est imposee.
const MAITRISE_COUTS := [10, 15, 25, 30, 40, 50, 60, 80, 100, 120]
const MAITRISE_VERSION := 3
const MAITRISE_COUT_MAJEUR := 4
const MAITRISE_RANG_MAX := 10
const MAITRISE_COUT_AJOUT_PAR_RANG := 0.25
const COUT_PAS_ARRONDI := 5
const GOUTTES_MULT_PAR_CHAPITRE := 1.055
const EQUIPEMENT_CROISSANCE_PAR_PALIER := 1.008

# Un court lot de victoires donne une amelioration certaine, meme sans chance.
const EPREUVE_GARANTIE_CAPACITE := 2
const EPREUVE_GARANTIE_COEUR := 3
const COEUR_MANA_BONUS_FINAL := 0.15
const EPREUVE_NIVEAU_DEBLOCAGE := 2
const MINE_NIVEAU_DEBLOCAGE := 4

# Les regroupements restent ceux des migrations historiques. Le prix courant
# donne acces a la premiere forge apres deux echecs a 5 puis 10 salles.
const FORGE_VERSION := 3
const FORGE_ANCIEN_NIVEAU_MAX := 60
const FORGE_REGROUPEMENT := 2
const FORGE_NIVEAU_MAX_AVANT_COMPRESSION := 100
const FORGE_COMPRESSION := 5
const FORGE_NIVEAU_MAX := 20
const FORGE_COUT_BASE := 30
const FORGE_COUT_PAR_NIVEAU := 10
const FORGE_COUT_QUADRATIQUE := 1
const PIERRES_CAMPAGNE_PAR_SALLE := 2.0
const PIERRES_CAMPAGNE_VICTOIRE := 10.0
const PIERRES_CAMPAGNE_CROISSANCE := 0.04
const MINE_PIERRES_RECOMPENSE := 140
# Le rendement tardif doit financer un remplacement forge en quelques runs.
const MINE_PIERRES_PAR_PALIER := 60
# Le boss complete la recompense ; une defaite finance deja la reprise.
const MINE_PIERRES_PART_SURVIE := 0.65

static func experience_compte_requise(niveau: int) -> int:
	if niveau >= NIVEAU_REFERENCE_FIN:
		return 0
	var profondeur := maxi(0, niveau - 1)
	return maxi(1, roundi(XP_COMPTE_BASE + float(profondeur) * XP_COMPTE_PENTE
		+ float(profondeur * profondeur) * XP_COMPTE_QUADRATIQUE))

static func cout_maitrise(cout_base: int, rang_acquis: int) -> int:
	var brut := float(cout_base) * (1.0 + MAITRISE_COUT_AJOUT_PAR_RANG * float(maxi(0, rang_acquis)))
	return maxi(COUT_PAS_ARRONDI, roundi(brut / float(COUT_PAS_ARRONDI)) * COUT_PAS_ARRONDI)

static func cout_forge(niveau_acquis: int) -> int:
	var niveau := clampi(niveau_acquis, 0, FORGE_NIVEAU_MAX - 1)
	var brut := float(FORGE_COUT_BASE + FORGE_COUT_PAR_NIVEAU * niveau
		+ FORGE_COUT_QUADRATIQUE * niveau * niveau)
	return maxi(COUT_PAS_ARRONDI, roundi(brut / float(COUT_PAS_ARRONDI)) * COUT_PAS_ARRONDI)

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
const MINE_DEGATS_MULT := 0.60
const MINE_MONTEE_PV := 2.0
const MINE_MONTEE_DEGATS := 1.0
const MINE_BOSS_PV_MULT := 12.0
const MINE_BOSS_DEGATS_MULT := 0.80
# Demande de soin soumise au budget de combat unique de cette rencontre.
const MINE_CAMERA_ZOOM := 0.74
const MINE_XP_RAYON_RAMASSAGE := 70.0

# Plus de vagues ne doit pas provoquer une avalanche instantanee chez un joueur
# un peu en retard. Un joueur puissant declenche toujours la suivante des que la
# vague est nettoyee ; ce delai ne ralentit donc jamais artificiellement un clear.
const DELAI_VAGUE_FORCE := 12.0
const DELAI_VAGUE_PAR_RENFORT := 0.8
const DELAI_VAGUE_NETTOYEE := 0.85
const DELAI_VAGUE_SATUREE := 1.0
const APPARITION_ANNONCE := 1.0
const APPARITION_BOSS_ANNONCE := 1.30
const APPARITION_DISTANCE_HEROS := 320.0
const XP_RAMASSAGE_DUREE := 0.55
# Un invocateur qui produit plus vite qu'on ne tue rend la salle infinie : la
# sonde a bloque deux fois dessus. Le plafond est une regle de jeu, pas un
# pansement — il borne aussi ce que l'ecran doit rester capable d'afficher.
const PLAFOND_ENNEMIS := 10

# La courbe de chapitre porte la progression ; aucun second crescendo de PV.
# Ces coefficients de campagne precedent la reserve d'endurance commune.
const MINIBOSS_PV_MULT := 4.56
const BOSS_SIGNATURE_PV_MULT := 5.00
# Reserve supplementaire commune a la campagne, la Mine et les Epreuves.
const BOSS_ENDURANCE_MULT := 0.70
const MINIBOSS_DEGATS_MULT := 1.00
const BOSS_SIGNATURE_DEGATS_MULT := 1.10
const BOSS_PROJECTILE_VITESSE_MULT := 2.625
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
