class_name ProgressionAugments
extends RefCounted

# Le rattrapage garantit dix niveaux avant le boss, meme avec peu d'XP.
# Les trois choix de boss, dont un legendaire, sont independants de ces niveaux.
const XP_SEUILS := [4, 20, 32, 50, 70, 90, 112, 140, 180, 220]
const SALLES_NIVEAUX := [1, 3, 4, 6, 8, 9, 11, 13, 16, 19]
const ETAGES_EPIQUES := [5, 10, 15]
const NOMBRE_RARES := 4
const NOMBRE_CHOIX := 3
const COMMUNS := ["soin", "poudre_vive", "reserve_vitale"]
const SOIN_CHOIX := 0.30
const SOIN_EPIQUE := 0.30
const BONUS_COMMUN := 0.10
const DERNIER_NIVEAU_AVIDITE := 6

# Enveloppes cibles de conception, pas une mesure du catalogue ni des parties.
# La refonte des augments permet des synergies exactes qui les depassent ; ces
# tableaux ne pilotent jamais la difficulte fixe des ennemis.
const GAIN_OFFENSIF_FAIBLE := [1.00, 1.04, 1.08, 1.13, 1.18, 1.24, 1.30, 1.36, 1.42, 1.48]
const GAIN_OFFENSIF_MEDIAN := [1.00, 1.08, 1.16, 1.26, 1.37, 1.49, 1.62, 1.75, 1.90, 2.05]
const GAIN_OFFENSIF_FORT := [1.00, 1.12, 1.25, 1.42, 1.62, 1.85, 2.12, 2.43, 2.76, 3.10]
const GAIN_SURVIE_FAIBLE := [1.00, 1.02, 1.04, 1.07, 1.10, 1.14, 1.18, 1.22, 1.27, 1.32]
const GAIN_SURVIE_MEDIAN := [1.00, 1.04, 1.08, 1.13, 1.18, 1.24, 1.30, 1.37, 1.44, 1.52]
const GAIN_SURVIE_FORT := [1.00, 1.07, 1.14, 1.23, 1.33, 1.44, 1.56, 1.69, 1.83, 1.98]

# Les trajectoires peuvent maintenant se combiner ; Ricochet + Perforation
# possede volontairement sa synergie sans perte et sans cible repetee.
const INCOMPATIBLES := {}
const INCOMPATIBLES_ARMES := {}

static func niveau_max() -> int:
	return XP_SEUILS.size()

static func plafond_salle(salle: int, total_salles: int) -> int:
	var avancement := float(maxi(0, salle)) / float(maxi(1, total_salles - 1))
	var cible := 0
	for palier: int in SALLES_NIVEAUX:
		if avancement >= float(palier) / float(SALLES_NIVEAUX.back()):
			cible += 1
	return cible

static func tirer_niveaux_rares(rng: RandomNumberGenerator) -> Array[int]:
	var disponibles: Array[int] = []
	var rares: Array[int] = []
	for niveau in range(1, niveau_max() + 1):
		disponibles.append(niveau)
	# Tirage sans remise : quatre rares exactement, sans dependance aux relances.
	for choix in NOMBRE_RARES:
		var index := rng.randi_range(0, disponibles.size() - 1)
		rares.append(disponibles[index])
		disponibles.remove_at(index)
	rares.sort()
	return rares

static func rarete_niveau(niveau: int, rares: Array[int]) -> String:
	return Reactif.RARE if niveau in rares else Reactif.COMMUN

static func tirer_etage_legendaire(rng: RandomNumberGenerator) -> int:
	return int(ETAGES_EPIQUES[rng.randi_range(0, ETAGES_EPIQUES.size() - 1)])

static func relance_autorisee(rarete: String) -> bool:
	return rarete not in [Reactif.COMMUN, Reactif.LEGENDAIRE]
