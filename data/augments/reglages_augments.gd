class_name ReglagesAugments
extends RefCounted

const COPIES_MAX := 2
const PROJECTILE_LATERAL_PART := 0.30
const TIR_DOUBLE_ECART := 24.0
const MALUS_TIRS_MULT := 0.70
const TIR_DOUBLE_PERTE_COPIE := 0.10
const PUISSANCE_BATTEMENT_MULT := 0.80
const ELAN_VITAL_CHARGE := 0.45
const ELAN_VITAL_BONUS_DEGATS := 0.45

const SATELLITES_NOMBRE := 2
const SATELLITES_ORBITE := 135.0
const SATELLITES_RAYON := 22.0
const SATELLITES_PERIODE := 2.8
const SATELLITES_INTERVALLE_IMPACT := 0.60
const SATELLITES_PART_ATTAQUE := 0.50

const TRAIT_INTERVALLE := 3.0
const TRAIT_PART_ATTAQUE := 1.50
const TRAIT_VITESSE := 1050.0
const TRAIT_PORTEE := 1600.0

const METEORITE_INTERVALLE := 5.0
const METEORITE_PART_ATTAQUE := 3.00
const METEORITE_RAYON := 120.0
const METEORITE_CHUTE := 0.45
const METEORITE_IMPACT_VISUEL := 0.25

static func puissance_tirs_paralleles(copies: int) -> float:
	if copies <= 0: return 1.0
	return maxf(Reglages.MODS_PLANCHER, MALUS_TIRS_MULT - TIR_DOUBLE_PERTE_COPIE * float(copies - 1))

# Salves, tirs paralleles et cadence partagent leurs gains de debit. Les formes
# restent visibles ; leur cumul attenue les impacts au lieu de multiplier le DPS.
static func puissance_tirs_cumules(salves: int, puissance_salve: float, copies_paralleles: int, cadence: float) -> float:
	var frontaux := 1 + maxi(0, copies_paralleles)
	var debit := float(salves) * puissance_salve \
		+ float(frontaux) * puissance_tirs_paralleles(copies_paralleles) + cadence - 2.0
	return maxf(Reglages.MODS_PLANCHER, debit / (float(salves * frontaux) * cadence))

static func impact_trait(attaque: float, copies: int) -> float:
	return attaque * TRAIT_PART_ATTAQUE * float(maxi(0, copies))

static func impact_meteorite(attaque: float) -> float:
	return attaque * METEORITE_PART_ATTAQUE

# Debit sur une cible immobile touchee a chaque declenchement, sans critique.
static func debit_periodique(attaque: float, copies_trait: int, meteorite: bool) -> float:
	return impact_trait(attaque, copies_trait) / TRAIT_INTERVALLE \
		+ (impact_meteorite(attaque) / METEORITE_INTERVALLE if meteorite else 0.0)
