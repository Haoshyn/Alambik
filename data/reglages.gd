class_name Reglages
extends RefCounted

# Source unique de l'equilibrage. Aucune de ces valeurs ne doit reapparaitre
# en dur ailleurs : les regler ne doit jamais demander de relire le combat.
#
# Ecart assume par rapport au plan : classe globale de constantes plutot
# qu'autoload. Un autoload n'existe que dans une SceneTree ; les suites de
# tests headless doivent pouvoir lire l'equilibrage sans en monter une.

# Le niveau de compte mesure l'avancement et ouvre les paliers annexes ; il ne
# doit pas devenir une quatrieme source de statistiques qui se compose avec
# Maitrises + equipement + Passifs. La puissance permanente vient de ces trois
# systemes explicites, comme le fixe le design.
const NIVEAU_DEGATS_PAR_NIVEAU := 0.0
const NIVEAU_PV_PAR_NIVEAU := 0.0
const NIVEAU_CADENCE_PAR_NIVEAU := 0.0
# Niveau de compte vise aux alentours de la fin de campagne. La courbe d'XP est
# calibree sur ~30 victoires et plusieurs dizaines de tentatives partielles.
const NIVEAU_REFERENCE_FIN := 30
const XP_COMPTE_BASE := 10.0
const XP_COMPTE_PENTE := 4.0
const XP_COMPTE_QUADRATIQUE := 1.2

const HEROS_PV := 100.0
const HEROS_VITESSE := 560.0
const HEROS_ACCELERATION := 3100.0
const HEROS_FREINAGE := 4200.0
const HEROS_CADENCE := 2.4          # tirs par seconde
const HEROS_INVULNERABILITE := 0.6  # secondes apres un coup recu
const HEROS_RAYON := 20.0
const HEROS_ECHELLE := 0.78
const DEGATS_COUP_REFERENCE := 15.0
const SOIN_COMBAT_PAR_SALLE := 0.05
const ULTIMES_PAR_RUN := 4
const SORT_INTERVALLE_CHARGE := 0.18
const GOUTTES_PAR_SALLE := 3
const ENNEMI_VITESSE_MULT := 1.10
# La densite ne suffit pas si chaque creature laisse trop de temps au joueur.
# Ces trois multiplicateurs renforcent la menace sans gonfler leurs PV : coups
# un peu plus lourds, projectiles plus difficiles a distancer et attaques plus
# frequentes. Les telegraphes restent inchanges, donc le danger reste lisible.
const ENNEMI_DEGATS_MULT := 1.04
const ENNEMI_PROJECTILE_VITESSE_MULT := 1.06
const ENNEMI_RECHARGE_MULT := 0.97
const ENNEMI_HITBOX_MULT := 0.72
const BOSS_HITBOX_MULT := 0.74

const TIR_DEGATS := 10.0
const MODS_PLANCHER := 0.05
# Mesure : la creature la plus rapide file a 704 px/s. A 900, le projectile
# n'allait qu'a 1,28 fois sa vitesse et se faisait esquiver systematiquement ;
# un tir doit devancer sa cible d'un facteur deux au minimum.
const TIR_VITESSE := 1550.0
const TIR_RAYON := 10.0
const TIR_PORTEE := 1400.0
const TIR_DELAI_ARRET := 0.12       # temps d'arret avant que le tir reprenne
const TIR_PREPARATION := 0.05      # anticipation du bras avant la projection

const BRAISE_DEGATS_PAR_SECONDE := 6.0
const BRAISE_DUREE := 4.0
const GIVRE_RALENTISSEMENT := 0.45  # facteur de vitesse applique
const GIVRE_DUREE := 2.0
const ACIDE_VULNERABILITE := 1.25   # multiplicateur de degats subis
const ACIDE_DUREE := 4.0
const TERRE_DEGATS_MULT := 1.45
const TERRE_VITESSE_MULT := 0.75
const TERRE_RETARD_ATTAQUE := 2.0
# Lumiere reste un sustain visible mais ne transforme plus les builds a impacts
# multiples en source de soin quasi permanente.
const LUMIERE_VOL_DE_VIE := 0.025
# Tenebres garde ses gros chiffres ponctuels, avec un rendement moyen bien plus
# proche des autres Elements : 18 % de chance a x2,6 vaut ~+29 % en moyenne.
const TENEBRES_CHANCE_SURCHARGE := 0.18
const TENEBRES_SURCHARGE_MULT := 2.6
const REGENERATION_PART := 0.02
const AVIDITE_XP_MULT := 1.20
const AVIDITE_GOUTTES_MULT := 1.20
const COURAGEUX_BONUS_MAX := 0.70
const MANNEQUIN_DELAI := 1.2
const MANNEQUIN_DEGATS_MULT := 1.25
const MANNEQUIN_CADENCE_MULT := 1.15
const FAMILIER_TIR_INTERVALLE := 0.85
const FAMILIER_TIR_PART_DEGATS := 0.42
# Le familier tire depuis ce decalage, pas depuis le heros. Sa visee doit donc
# partir de la aussi : calculee depuis le heros, elle ratait de tout l'angle
# separant les deux points, d'autant plus visiblement que la cible etait proche.
const FAMILIER_DECALAGE := Vector2(72.0, -36.0)

# Viser ou la cible sera, pas ou elle est. Partage par le heros et le familier :
# une cible qui recule en ligne droite n'etait presque jamais touchee.
const ANTICIPATION_DUREE_MAX := 0.8
const ANTICIPATION_PART := 0.9
const METEORE_INTERVALLE := 4.0
const METEORE_PART_DEGATS := 2.6
const METEORE_RAYON := 150.0
const ZONE_HEROS_INTERVALLE := 0.45
const ZONE_HEROS_PART_DEGATS := 0.32
const ZONE_HEROS_RAYON := 145.0
const GARDIEN_INTERVALLE := 0.75
const GARDIEN_PART_DEGATS := 0.55
const GARDIEN_PV := 55.0
const GARDIEN_REAPPARITION := 6.0
const ORBE_INTERVALLE := 2.0
const ORBE_MAX := 3
const ORBE_PART_DEGATS := 0.55
const PHENOMENE_AIR_INTERVALLE_MULT := 0.75
# Feu conserve son identite de brulure cumulative, mais quatre couches suffisent :
# a cadence de base, le plafond represente ~30 % de DPS soutenu supplementaire.
# Sans plafond, le DPS augmentait lineairement pendant toute la vie d'un boss.
const FEU_DOT_PART_PAR_SECONDE := 0.18
const FEU_DOT_CUMUL_MAX := 4
const PHENIX_RESURRECTIONS := 3
const PHENIX_PV_PART := 0.38
const EAU_RESURRECTIONS := 1
const AIR_RESURRECTIONS := 1
const AIR_RESURRECTION_PV_PART := 0.55
const TERRE_RESURRECTIONS := 1
const TERRE_RESURRECTION_PV_PART := 0.50
const TERRE_PROTECTION_DUREE := 6.0
const TERRE_PROTECTION_MULT := 0.45
const LUMIERE_RESURRECTIONS := 1
const LUMIERE_RESURRECTION_PV_PART := 0.55
const LUMIERE_AUREOLE_DUREE := 8.0
const LUMIERE_AUREOLE_DEGATS_MULT := 1.65
const TENEBRES_HEROS_DEGATS_MULT := 1.35
# Un eclat qui frappe presque aussi fort que le tir d'origine transforme
# Eclat de verre en multiplicateur : c'etait la moitie des mains cassees.
const FRAGMENT_PART_DEGATS := 0.28
const FRAGMENT_PORTEE := 260.0
# Un trait qui traverse quatre ennemis en frappant chacun a pleine puissance
# est un multiplicateur deguise : il perd de la force a chaque cible, et a
# chaque rebond. C'est ce qui separe une bonne main d'une main cassee.
# Perforation et Ricochet sont des choix de trajectoire : ils doivent rester
# interessants dans les vagues denses au lieu de perdre un tiers de leur force
# des la premiere cible secondaire.
const PERFORATION_PERTE := 0.20
const REBOND_PERTE := 0.22
const HOMING_ROTATION_PAR_SECONDE := 8.0

# Ameliorations ajoutees au pool. Leurs valeurs pures vivent dans le catalogue ;
# seules celles que la logique doit lire sont ici.
const PEAU_DE_PIERRE_REDUCTION := 0.30
const SOIF_DE_SANG_PART := 0.006      # part des PV max rendue par elimination
const CHAINE_INTERVALLE := 1.6
const CHAINE_PART_DEGATS := 0.52
const CHAINE_CIBLES := 4
const CHAINE_PORTEE := 340.0          # distance maximale entre deux maillons

# Passifs. On n'en equipe qu'un, deux avec la Maitrise Utilitaire : un Passif
# doit donc changer une facon de jouer, pas ajouter un pourcentage anecdotique.
# Chacun porte en plus un effet permanent, faute de quoi la moitie d'entre eux
# ne se remarquait jamais en combat.
const MOISSON_SEUIL := 6
const MOISSON_PART := 0.02
const SANG_FROID_SEUIL := 8
const SANG_FROID_RECHARGE := 0.30      # recharge du Sort en moins, en permanence
const REMPART_REDUCTION := 0.18        # degats recus en moins, en permanence
const RIPOSTE_RAYON := 320.0
const RIPOSTE_PART_DEGATS := 2.80
const RIPOSTE_REPOUSSEE := 420.0
const SECONDE_CHANCE_PART := 0.30      # une seule resurrection par run
const RESERVE_ULTIME_CHARGES := 1
const RESERVE_ULTIME_REMISE := 0.20    # charge requise en moins
const HERITAGE_AMELIORATIONS := 2
const ECHO_CHANCE := 0.40
const ECHO_PART_DEGATS := 0.70
const AUDACE_SEUIL_PV := 0.60
const AUDACE_BONUS := 0.45
const DERNIER_REMPART_SEUIL_PV := 0.40
const DERNIER_REMPART_REDUCTION := 0.45

# Equipement. Le palier du compte fait monter tous les objets possedes ensemble :
# une trouvaille ancienne reste donc viable au Monde X au lieu d'etre remplacee
# automatiquement par la meme silhouette avec dix fois plus de statistiques.
# +9 % par Monde laisse une progression sensible sans faire du stuff une source
# de puissance exponentielle a lui seul.
const OBJET_CROISSANCE_PAR_MONDE := 1.09

# Sceaux. L'aura ne fait aucun degat : elle marque, ce qui la rend lisible face
# aux Phenomenes qui, eux, frappent.
const SCEAU_GARDE_REDUCTION := 0.22
const SCEAU_AURA_CIBLES_SOIN_MAX := 3
const SCEAU_RUINE_VULNERABILITE := 1.30
const SCEAU_AURA_INTERVALLE := 0.55
const SCEAU_AURA_RAYON := 240.0
const SCEAU_AURA_RAYON_AIR_MULT := 1.85
const SCEAU_AURA_SOIN := 0.004      # part des PV max par creature marquee, Lumiere
const SCEAU_AURA_DEGATS := 0.02     # trace symbolique : l'aura marque, elle ne tue pas

const ONDE_CHOC_INTERVALLE := 3.2
const ONDE_CHOC_RAYON := 300.0
const ONDE_CHOC_PART_DEGATS := 1.15
const ONDE_CHOC_REPOUSSEE := 300.0

# Elan vital : l'inverse de Mannequin, il recompense le deplacement.
const ELAN_VITAL_DEGATS_MULT := 1.35
const ELAN_VITAL_DUREE := 1.1       # secondes de bonus apres s'etre deplace

const FLAQUE_DUREE := 3.0
const FLAQUE_RAYON := 70.0
const NUAGE_DUREE := 3.5
const NUAGE_RAYON := 130.0
const GEL_BREF_DUREE := 0.7
const RAFALE_NOMBRE := 2
const RAFALE_INTERVALLE := 0.07

# La zone praticable suit le bord interieur de la peinture. L'ancienne limite
# englobait les remparts : les personnages semblaient traverser la pierre.
const ARENE_MARGE_LATERALE := 78.0
const ARENE_HAUT := 244.0
const ARENE_BAS := 220.0
const ARENE_MUR_EPAISSEUR := 72.0
const ARENE_HAUTEUR_MAX := 1540.0
const ARENE_TAILLE := Vector2(1260.0,1900.0)
const ARENE_CAMERA_ZOOM := 1.05
const ARENE_PASSAGE_MIN := 240.0
const ARENE_OBSTACLE_TAILLE := Vector2(156.0,94.0)
const ARENE_COMPOSITIONS := [
	[Vector2(0.40,0.28),Vector2(0.60,0.50),Vector2(0.40,0.72)],
	[Vector2(0.59,0.29),Vector2(0.39,0.50),Vector2(0.60,0.73)],
	[Vector2(0.41,0.29),Vector2(0.61,0.51),Vector2(0.39,0.73)],
]
# Retraits du sol raccordes aux collisions, hors de l'entree et du portail.
const ARENE_RETRAITS := [
	[Rect2(0.0,0.13,0.12,0.22),Rect2(0.90,0.49,0.10,0.25)],
	[Rect2(0.0,0.45,0.10,0.26),Rect2(0.87,0.15,0.13,0.20)],
	[Rect2(0.0,0.20,0.11,0.25),Rect2(0.89,0.55,0.11,0.16)],
]
const ECHELLE_VISUELLE_COMBAT := 1.08

# La longueur d'un chapitre et la place de ses alambics vivent dans
# data/chapitres.gd : ces constantes ne servent plus qu'au repli, quand aucun
# chapitre n'est charge.
const SALLES_PAR_RUN := 20

# La campagne n'est pas le contenu d'optimisation ultime. Avec les vagues denses,
# +3,5 % PV par chapitre suffit : le chapitre 30 commence vers x2,7 et demande
# surtout un bon build et de bonnes esquives, pas toutes les Maitrises du jeu.
const COURBE_PV_PAR_PALIER := 1.035
# La densite multiplie aussi les occasions d'etre touche. Les degats individuels
# montent donc plus doucement afin qu'un joueur habile puisse compenser le farm.
const COURBE_DEGATS_PAR_PALIER := 1.018
# Le debut est volontairement genereux puis rejoint la courbe sur trois Mondes :
# apprendre a gerer trois ou quatre vagues ne doit pas exiger de farmer Monde I.
const COURBE_DOUCEUR_DEBUT := 0.42
const COURBE_PALIERS_DOUCEUR := 9

# Le crescendo interne est lui aussi modere : les salles tardives ont deja plus
# de vagues. Les statistiques servent a maintenir la tension, pas a doubler une
# seconde fois la difficulte apportee par la densite.
const MONTEE_PV := 0.75          # x1,75 entre la premiere et la derniere salle
const MONTEE_DEGATS := 0.30      # x1,30 sur les degats
const DEFI_MONTEE_PV := 3.0       # x4 entre la premiere et la derniere rencontre
const DEFI_MONTEE_DEGATS := 1.0   # x2 sur les degats, en plus de la densite
const DEFI_PV_BASE := 1.25
const DEFI_DEGATS_BASE := 1.15

# Un Amélioration se reprend, mais pas indefiniment : six choix doivent construire
# un build, pas empiler automatiquement la meme carte.
const COPIES_MAX := 3
const SOIN_ALAMBIC := 0.50   # respiration garantie avant chaque boss

# Avec ~154 ennemis communs par chapitre, l'ancien bareme donnait les six choix
# beaucoup trop tot. Ces seuils replacent approximativement les choix 2/4/5/6
# avant les salles 5/10/15/20, meme avec les nouvelles vagues plus denses.
const XP_RUN_SEUILS := [10, 26, 55, 80, 145, 220]

# Economie longue : les couts restent fixes, c'est le revenu de campagne qui
# accelere. Avec un grand coffre moyen de 14 Gouttes et x1,20 par chapitre, une
# campagne sans farm finance environ 30 % des premiers rangs a mi-parcours,
# 47-50 % vers 70 % du jeu et 80 % a la premiere fin. Les rangs 2-5 restent le
# vrai puits de farm apres cette premiere progression.
const MAITRISE_COUTS := [8, 12, 20, 35, 60, 100, 170, 280, 460, 760]
const MAITRISE_RANG_MAX := 10
const MAITRISE_RANGS_PLEINS := 3
const MAITRISE_POIDS_TARDIF := 2.0 / 7.0
const MAITRISE_COUT_PAR_RANG := 1.35
const GOUTTES_MULT_PAR_CHAPITRE := 1.20

# Capacites d'Epreuve : le premier exemplaire debloque la regle de jeu ; neuf
# doublons apportent ensuite +54 % au maximum, pas un second exemplaire complet.
const CAPACITE_RANG_MAX := 10
const CAPACITE_BONUS_PAR_RANG := 0.06
# Cinq miniboss donnent cinq jets : a 20 %, une Epreuve complete rapporte en
# moyenne une capacite, contre cinq auparavant. Le repli monetaire reste faible.
const EPREUVE_CHANCE_CAPACITE := 0.20
const EPREUVE_NIVEAU_DEBLOCAGE := 2
const MINE_NIVEAU_DEBLOCAGE := 4

# La Forge appartient a l'objet. Son cout croit geometriquement pour que les
# derniers niveaux restent un objectif de farm et non une formalite.
# La Forge multiplie le profil de l'objet : un seul facteur, quel que soit le
# champ, sinon deux constantes devraient rester egales sans que rien ne le dise.
const FORGE_BONUS_PAR_NIVEAU := 0.015
const FORGE_NIVEAU_MAX := 60
const FORGE_COUT_BASE := 8
const FORGE_COUT_CROISSANCE := 1.055
const MINE_PIERRES_RECOMPENSE := 25
# +12 % par chapitre produit environ x1,40 par Monde et x27 sur les trente
# paliers. Cela donne une vraie acceleration sans le x512 qu'impliquerait un
# doublement a chacun des dix Mondes.
const MINE_PIERRES_MULT_PAR_PALIER := 1.12

static func cout_maitrise(cout_base: int, rang_acquis: int) -> int:
	return maxi(1, roundi(float(cout_base) * pow(MAITRISE_COUT_PAR_RANG, float(rang_acquis))))

static func cout_forge(niveau_acquis: int) -> int:
	return maxi(1, roundi(float(FORGE_COUT_BASE) * pow(FORGE_COUT_CROISSANCE, float(niveau_acquis))))

static func pierres_mine(palier: int) -> int:
	return maxi(1, roundi(float(MINE_PIERRES_RECOMPENSE) \
		* pow(MINE_PIERRES_MULT_PAR_PALIER, float(maxi(0, palier)))))

# Les annexes suivent la puissance brute du chapitre atteint sans reprendre la
# douceur pedagogique des premiers chapitres de campagne.
static func facteur_annexe_pv(palier: int) -> float:
	return pow(COURBE_PV_PAR_PALIER, float(maxi(0, palier)))

static func facteur_annexe_degats(palier: int) -> float:
	return pow(COURBE_DEGATS_PAR_PALIER, float(maxi(0, palier)))

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
const DELAI_VAGUE_FORCE := 7.0
# Un invocateur qui produit plus vite qu'on ne tue rend la salle infinie : la
# sonde a bloque deux fois dessus. Le plafond est une regle de jeu, pas un
# pansement — il borne aussi ce que l'ecran doit rester capable d'afficher.
const PLAFOND_ENNEMIS := 10

# Le rythme des adversaires majeurs est regle ici pour que leurs telegraphes
# puissent etre ajustes ensemble sans fouiller le moteur de motifs. L'objectif
# "environ cinq fois plus fort" est un budget de rencontre, pas cinq fois chaque
# statistique : x3 endurance, +10 % degats, ~11 % de salves en plus et +20 %
# vitesse de projectile. La menace vient donc surtout d'un pattern qu'il faut
# esquiver plus longtemps, sans transformer chaque impact en quasi one-shot.
# Les miniboss restent nettement plus courts pour ne pas casser le rythme.
const MINIBOSS_PV_MULT := 6.5
const BOSS_SIGNATURE_PV_MULT := 5.0
const MINIBOSS_DEGATS_MULT := 1.00
const BOSS_SIGNATURE_DEGATS_MULT := 1.10
const BOSS_PROJECTILE_VITESSE_MULT := 1.20
const BOSS_CADENCE_MOTIF_MULT := 0.90
const BOSS_APPARITION_DUREE := 0.85
const BOSS_TELEGRAPHE_SIGNATURE := 0.42
const BOSS_CADENCES_SIGNATURE := {
	"griffure": 0.58, "echo_errata": 0.72, "quadrillage": 0.68,
	"machoire": 0.76, "calligraphie": 0.15, "indexation": 0.48,
	"onde_marge": 0.74, "rosace": 0.88, "estampille": 0.82,
	"copie_double": 0.52,
}
const BOSS_DUREES_MOTIFS := {
	"barrage_horizontal": 3.0, "eventail_lent": 3.2, "barrage_croise": 3.4,
	"invocation": 1.2, "charge": 2.6, "spirale": 3.1, "anneau_breche": 3.2,
	"pluie": 3.0, "poursuite": 2.8, "griffure": 2.9, "echo_errata": 3.0,
	"quadrillage": 3.1, "machoire": 3.0, "calligraphie": 3.1, "indexation": 2.9,
	"onde_marge": 3.0, "rosace": 3.1, "estampille": 3.0, "copie_double": 3.0,
	"pause_phase_1": 1.15, "pause_phase_2": 0.90,
}

const PORTAIL_RAYON := 82.0

# Le prototype retro doit se laisser parcourir avant de juger son style. Il
# presente tout son bestiaire en une salle sans reprendre la courbe de campagne.
const RETRO_PV_MULT := 0.62
const RETRO_DEGATS_MULT := 0.48
