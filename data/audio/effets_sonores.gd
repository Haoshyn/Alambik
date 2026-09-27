extends RefCounted

# Timbres originaux, composes ici pour ne pas disperser les reglages de mixage.
const TAUX := 22050
const VOIX := 10
const PIC_MAX := 0.88
const ATTAQUE := 0.002
const SORTIE := 0.006
const VARIATION_TIMBRE := 0.018
const BUS_COMBAT := "EffetsCombat"
const RETRAIT_COMBAT_DB := -6.0
const RETRAIT_MUSIQUE_DB := -2.5
const ATTAQUE_RETRAIT := 0.025
const SORTIE_RETRAIT := 0.18
const VIBRATION_INTERVALLE_MS := 160

# Les motifs de recompense gardent leurs intervalles, meme avec une variante.
const PROFILS := {
	"tir": {
		"duree": 0.085, "variantes": 4, "priorite": 0, "intervalle_ms": 32,
		"simultanes": 2, "combat": true, "variation_hauteur": 0.025,
		"couches": [
			{"forme": "corps", "duree": 0.07, "frequence": 930.0, "fin": 470.0, "gain": 0.66, "decroissance": 2.8},
			{"forme": "verre", "duree": 0.022, "frequence": 1840.0, "fin": 1430.0, "gain": 0.16},
			{"forme": "grain", "duree": 0.016, "gain": 0.28, "filtre": 0.42},
		],
	},
	"impact": {
		"duree": 0.12, "variantes": 4, "priorite": 0, "intervalle_ms": 40,
		"simultanes": 3, "combat": true, "variation_hauteur": 0.04,
		"couches": [
			{"forme": "corps", "duree": 0.095, "frequence": 330.0, "fin": 145.0, "gain": 0.72, "decroissance": 3.0},
			{"forme": "grain", "duree": 0.037, "gain": 0.46, "filtre": 0.3},
			{"forme": "verre", "debut": 0.008, "duree": 0.08, "frequence": 1420.0, "fin": 1130.0, "gain": 0.20},
		],
	},
	"mort": {
		"duree": 0.3, "variantes": 3, "priorite": 1, "intervalle_ms": 65,
		"simultanes": 3, "combat": true, "variation_hauteur": 0.035,
		"couches": [
			{"forme": "corps", "duree": 0.24, "frequence": 225.0, "fin": 66.0, "gain": 0.72, "decroissance": 2.5},
			{"forme": "grain", "duree": 0.17, "gain": 0.42, "filtre": 0.16},
			{"forme": "verre", "debut": 0.035, "duree": 0.14, "frequence": 1140.0, "fin": 740.0, "gain": 0.22},
			{"forme": "verre", "debut": 0.08, "duree": 0.2, "frequence": 780.0, "fin": 450.0, "gain": 0.16},
		],
	},
	"degat": {
		"duree": 0.19, "variantes": 3, "priorite": 4, "intervalle_ms": 100,
		"simultanes": 1, "retrait": 0.20, "variation_hauteur": 0.015,
		"couches": [
			{"forme": "corps", "duree": 0.17, "frequence": 215.0, "fin": 76.0, "gain": 0.86, "decroissance": 2.6},
			{"forme": "corps", "duree": 0.052, "frequence": 970.0, "fin": 350.0, "gain": 0.31, "decroissance": 3.8},
			{"forme": "grain", "duree": 0.072, "gain": 0.55, "filtre": 0.35, "decroissance": 3.6},
		],
	},
	"choix": {
		"duree": 0.15, "variantes": 3, "priorite": 2, "intervalle_ms": 45,
		"simultanes": 2, "variation_hauteur": 0.012,
		"couches": [
			{"forme": "verre", "duree": 0.11, "frequence": 880.0, "gain": 0.66, "decroissance": 2.6},
			{"forme": "verre", "debut": 0.022, "duree": 0.12, "frequence": 1320.0, "gain": 0.35, "decroissance": 3.0},
		],
	},
	"fusion": {
		"duree": 0.66, "variantes": 2, "priorite": 3, "intervalle_ms": 160,
		"simultanes": 2, "retrait": 0.46, "variation_hauteur": 0.0,
		"couches": [
			{"forme": "corps", "duree": 0.31, "frequence": 290.0, "fin": 610.0, "gain": 0.25, "attaque": 0.016},
			{"forme": "verre", "debut": 0.015, "duree": 0.32, "frequence": 587.33, "gain": 0.46},
			{"forme": "verre", "debut": 0.085, "duree": 0.38, "frequence": 739.99, "gain": 0.41},
			{"forme": "verre", "debut": 0.16, "duree": 0.42, "frequence": 880.0, "gain": 0.39},
			{"forme": "verre", "debut": 0.23, "duree": 0.42, "frequence": 1174.66, "gain": 0.32},
		],
	},
	"coffre": {
		"duree": 0.88, "variantes": 2, "priorite": 3, "intervalle_ms": 200,
		"simultanes": 1, "retrait": 0.62, "variation_hauteur": 0.0,
		"couches": [
			{"forme": "corps", "duree": 0.045, "frequence": 410.0, "fin": 240.0, "gain": 0.52},
			{"forme": "grain", "duree": 0.025, "gain": 0.22, "filtre": 0.4},
			{"forme": "verre", "debut": 0.045, "duree": 0.40, "frequence": 523.25, "gain": 0.50},
			{"forme": "verre", "debut": 0.11, "duree": 0.45, "frequence": 659.25, "gain": 0.44},
			{"forme": "verre", "debut": 0.175, "duree": 0.50, "frequence": 783.99, "gain": 0.41},
			{"forme": "verre", "debut": 0.245, "duree": 0.62, "frequence": 1046.50, "gain": 0.35, "decroissance": 2.5},
		],
	},
	"portail": {
		"duree": 0.58, "variantes": 2, "priorite": 2, "intervalle_ms": 180,
		"simultanes": 1, "variation_hauteur": 0.01,
		"couches": [
			{"forme": "air", "duree": 0.44, "gain": 0.20, "filtre": 0.08, "attaque": 0.09, "decroissance": 1.2},
			{"forme": "corps", "duree": 0.40, "frequence": 300.0, "fin": 690.0, "gain": 0.35, "attaque": 0.04},
			{"forme": "verre", "debut": 0.07, "duree": 0.44, "frequence": 698.46, "gain": 0.42},
			{"forme": "verre", "debut": 0.15, "duree": 0.42, "frequence": 1047.69, "gain": 0.25},
		],
	},
	"boss": {
		"duree": 0.73, "variantes": 2, "priorite": 3, "intervalle_ms": 250,
		"simultanes": 1, "retrait": 0.43, "variation_hauteur": 0.015,
		"couches": [
			{"forme": "corps", "duree": 0.62, "frequence": 156.0, "fin": 72.0, "gain": 0.60, "attaque": 0.005, "decroissance": 1.8},
			{"forme": "corps", "duree": 0.69, "frequence": 233.0, "fin": 108.0, "gain": 0.27, "attaque": 0.012},
			{"forme": "grain", "duree": 0.24, "gain": 0.47, "filtre": 0.12},
			{"forme": "verre", "debut": 0.035, "duree": 0.42, "frequence": 620.0, "fin": 415.0, "gain": 0.21},
		],
	},
}

const VIBRATIONS := {
	"degat": {"duree_ms": 32, "amplitude": 0.65, "intervalle_ms": 240},
	"fusion": {"duree_ms": 22, "amplitude": 0.40, "intervalle_ms": 550},
	"coffre": {"duree_ms": 38, "amplitude": 0.48, "intervalle_ms": 700},
}
