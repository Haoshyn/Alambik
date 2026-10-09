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
# Les combats frappent sec (chute de hauteur, grain) ; les recompenses montent
# en arpege, plus long et plus brillant selon la rarete.
const PROFILS := {
	"tir": {
		"duree": 0.09, "variantes": 4, "priorite": 0, "intervalle_ms": 32,
		"simultanes": 2, "combat": true, "variation_hauteur": 0.03,
		"couches": [
			{"forme": "chute", "duree": 0.075, "frequence": 1150.0, "fin": 420.0, "courbe": 0.45, "gain": 0.62, "decroissance": 2.6},
			{"forme": "verre", "duree": 0.024, "frequence": 2100.0, "fin": 1500.0, "gain": 0.18},
			{"forme": "souffle", "duree": 0.03, "gain": 0.30, "filtre": 0.6, "filtre_fin": 0.15},
		],
	},
	"impact": {
		"duree": 0.13, "variantes": 4, "priorite": 0, "intervalle_ms": 38,
		"simultanes": 3, "combat": true, "variation_hauteur": 0.05,
		"couches": [
			{"forme": "chute", "duree": 0.11, "frequence": 420.0, "fin": 120.0, "courbe": 0.4, "gain": 0.78, "decroissance": 2.8},
			{"forme": "grain", "duree": 0.045, "gain": 0.52, "filtre": 0.35},
			{"forme": "verre", "debut": 0.006, "duree": 0.07, "frequence": 1500.0, "fin": 1150.0, "gain": 0.18},
		],
	},
	"critique": {
		"duree": 0.22, "variantes": 3, "priorite": 1, "intervalle_ms": 55,
		"simultanes": 2, "combat": true, "variation_hauteur": 0.03,
		"couches": [
			{"forme": "chute", "duree": 0.13, "frequence": 560.0, "fin": 140.0, "courbe": 0.35, "gain": 0.82, "decroissance": 2.4},
			{"forme": "grain", "duree": 0.05, "gain": 0.5, "filtre": 0.5},
			{"forme": "cloche", "debut": 0.004, "duree": 0.2, "frequence": 2350.0, "ratio": 2.76, "indice": 1.6, "gain": 0.30, "decroissance": 3.0},
			{"forme": "verre", "debut": 0.01, "duree": 0.09, "frequence": 3100.0, "fin": 2900.0, "gain": 0.14},
		],
	},
	"mort": {
		"duree": 0.34, "variantes": 3, "priorite": 1, "intervalle_ms": 60,
		"simultanes": 3, "combat": true, "variation_hauteur": 0.04,
		"couches": [
			{"forme": "chute", "duree": 0.26, "frequence": 300.0, "fin": 55.0, "courbe": 0.35, "gain": 0.78, "decroissance": 2.3},
			{"forme": "souffle", "duree": 0.22, "gain": 0.46, "filtre": 0.55, "filtre_fin": 0.05},
			{"forme": "verre", "debut": 0.03, "duree": 0.14, "frequence": 1240.0, "fin": 760.0, "gain": 0.22},
			{"forme": "triangle", "debut": 0.05, "duree": 0.12, "frequence": 1568.0, "fin": 1046.5, "gain": 0.12},
		],
	},
	"explosion": {
		"duree": 0.55, "variantes": 2, "priorite": 3, "intervalle_ms": 120,
		"simultanes": 1, "combat": true, "retrait": 0.25, "variation_hauteur": 0.03,
		"couches": [
			{"forme": "chute", "duree": 0.42, "frequence": 160.0, "fin": 38.0, "courbe": 0.3, "gain": 0.95, "decroissance": 2.0},
			{"forme": "souffle", "duree": 0.5, "gain": 0.7, "filtre": 0.7, "filtre_fin": 0.03, "decroissance": 1.8},
			{"forme": "grain", "duree": 0.06, "gain": 0.6, "filtre": 0.8},
		],
	},
	"degat": {
		"duree": 0.22, "variantes": 3, "priorite": 4, "intervalle_ms": 100,
		"simultanes": 1, "retrait": 0.22, "variation_hauteur": 0.015,
		"couches": [
			{"forme": "chute", "duree": 0.2, "frequence": 260.0, "fin": 62.0, "courbe": 0.4, "gain": 0.92, "decroissance": 2.4},
			{"forme": "carre", "duree": 0.06, "frequence": 330.0, "fin": 180.0, "gain": 0.22, "decroissance": 3.5},
			{"forme": "grain", "duree": 0.08, "gain": 0.6, "filtre": 0.35, "decroissance": 3.4},
		],
	},
	"clic": {
		"duree": 0.06, "variantes": 3, "priorite": 2, "intervalle_ms": 35,
		"simultanes": 2, "variation_hauteur": 0.02,
		"couches": [
			{"forme": "chute", "duree": 0.04, "frequence": 1400.0, "fin": 700.0, "courbe": 0.5, "gain": 0.5, "decroissance": 3.0},
			{"forme": "verre", "duree": 0.03, "frequence": 2600.0, "gain": 0.16, "decroissance": 3.5},
		],
	},
	"carte": {
		"duree": 0.16, "variantes": 3, "priorite": 2, "intervalle_ms": 40,
		"simultanes": 3, "variation_hauteur": 0.03,
		"couches": [
			{"forme": "souffle", "duree": 0.13, "gain": 0.42, "filtre": 0.05, "filtre_fin": 0.45, "attaque": 0.03, "decroissance": 1.6},
			{"forme": "verre", "debut": 0.1, "duree": 0.05, "frequence": 2200.0, "gain": 0.2, "decroissance": 3.0},
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
	"choix_rare": {
		"duree": 0.42, "variantes": 2, "priorite": 3, "intervalle_ms": 120,
		"simultanes": 1, "retrait": 0.2, "variation_hauteur": 0.0,
		"couches": [
			{"forme": "cloche", "duree": 0.3, "frequence": 783.99, "ratio": 2.0, "indice": 1.4, "gain": 0.5},
			{"forme": "cloche", "debut": 0.08, "duree": 0.32, "frequence": 1174.66, "ratio": 2.0, "indice": 1.4, "gain": 0.42},
			{"forme": "souffle", "duree": 0.1, "gain": 0.16, "filtre": 0.1, "filtre_fin": 0.6},
		],
	},
	"choix_epique": {
		"duree": 0.6, "variantes": 2, "priorite": 3, "intervalle_ms": 150,
		"simultanes": 1, "retrait": 0.3, "variation_hauteur": 0.0,
		"couches": [
			{"forme": "cloche", "duree": 0.32, "frequence": 659.26, "ratio": 2.0, "indice": 1.6, "gain": 0.46},
			{"forme": "cloche", "debut": 0.07, "duree": 0.34, "frequence": 880.0, "ratio": 2.0, "indice": 1.6, "gain": 0.42},
			{"forme": "cloche", "debut": 0.14, "duree": 0.44, "frequence": 1318.51, "ratio": 2.0, "indice": 1.8, "gain": 0.40},
			{"forme": "triangle", "debut": 0.14, "duree": 0.44, "frequence": 659.26, "gain": 0.18, "attaque": 0.05},
			{"forme": "souffle", "debut": 0.1, "duree": 0.4, "gain": 0.12, "filtre": 0.7, "filtre_fin": 0.9, "attaque": 0.1},
		],
	},
	"choix_legendaire": {
		"duree": 1.05, "variantes": 2, "priorite": 4, "intervalle_ms": 250,
		"simultanes": 1, "retrait": 0.6, "variation_hauteur": 0.0,
		"couches": [
			{"forme": "carre", "duree": 0.16, "frequence": 523.25, "gain": 0.26, "decroissance": 2.2},
			{"forme": "carre", "debut": 0.08, "duree": 0.16, "frequence": 659.26, "gain": 0.26, "decroissance": 2.2},
			{"forme": "carre", "debut": 0.16, "duree": 0.16, "frequence": 783.99, "gain": 0.26, "decroissance": 2.2},
			{"forme": "cloche", "debut": 0.24, "duree": 0.8, "frequence": 1046.5, "ratio": 2.0, "indice": 2.0, "gain": 0.5, "decroissance": 1.6},
			{"forme": "triangle", "debut": 0.24, "duree": 0.8, "frequence": 523.25, "gain": 0.3, "attaque": 0.03, "decroissance": 1.4},
			{"forme": "triangle", "debut": 0.24, "duree": 0.8, "frequence": 659.26, "gain": 0.22, "attaque": 0.03, "decroissance": 1.4},
			{"forme": "triangle", "debut": 0.24, "duree": 0.8, "frequence": 783.99, "gain": 0.2, "attaque": 0.03, "decroissance": 1.4},
			{"forme": "souffle", "debut": 0.22, "duree": 0.7, "gain": 0.16, "filtre": 0.85, "filtre_fin": 0.95, "attaque": 0.12, "decroissance": 1.5},
		],
	},
	"niveau": {
		"duree": 0.62, "variantes": 2, "priorite": 3, "intervalle_ms": 200,
		"simultanes": 1, "retrait": 0.35, "variation_hauteur": 0.0,
		"couches": [
			{"forme": "triangle", "duree": 0.14, "frequence": 587.33, "gain": 0.42, "decroissance": 2.0},
			{"forme": "triangle", "debut": 0.07, "duree": 0.14, "frequence": 739.99, "gain": 0.42, "decroissance": 2.0},
			{"forme": "triangle", "debut": 0.14, "duree": 0.14, "frequence": 880.0, "gain": 0.42, "decroissance": 2.0},
			{"forme": "cloche", "debut": 0.21, "duree": 0.4, "frequence": 1174.66, "ratio": 2.0, "indice": 1.8, "gain": 0.5, "decroissance": 1.8},
			{"forme": "carre", "debut": 0.21, "duree": 0.3, "frequence": 587.33, "gain": 0.14, "decroissance": 2.0},
		],
	},
	"xp": {
		"duree": 0.07, "variantes": 2, "priorite": 1, "intervalle_ms": 25,
		"simultanes": 3, "variation_hauteur": 0.0,
		"couches": [
			{"forme": "triangle", "duree": 0.06, "frequence": 1318.51, "fin": 1567.98, "gain": 0.45, "decroissance": 2.4},
			{"forme": "verre", "duree": 0.03, "frequence": 2637.0, "gain": 0.1},
		],
	},
	"salle": {
		"duree": 0.7, "variantes": 2, "priorite": 3, "intervalle_ms": 400,
		"simultanes": 1, "retrait": 0.3, "variation_hauteur": 0.0,
		"couches": [
			{"forme": "triangle", "duree": 0.16, "frequence": 587.33, "gain": 0.4, "decroissance": 2.0},
			{"forme": "triangle", "debut": 0.1, "duree": 0.16, "frequence": 783.99, "gain": 0.4, "decroissance": 2.0},
			{"forme": "cloche", "debut": 0.2, "duree": 0.48, "frequence": 1174.66, "ratio": 2.0, "indice": 1.5, "gain": 0.48, "decroissance": 1.7},
			{"forme": "triangle", "debut": 0.2, "duree": 0.48, "frequence": 587.33, "gain": 0.2, "attaque": 0.02, "decroissance": 1.6},
		],
	},
	"achat": {
		"duree": 0.46, "variantes": 2, "priorite": 3, "intervalle_ms": 120,
		"simultanes": 1, "retrait": 0.2, "variation_hauteur": 0.01,
		"couches": [
			{"forme": "chute", "duree": 0.05, "frequence": 900.0, "fin": 300.0, "courbe": 0.4, "gain": 0.4},
			{"forme": "cloche", "debut": 0.02, "duree": 0.2, "frequence": 1567.98, "ratio": 2.4, "indice": 1.8, "gain": 0.42},
			{"forme": "cloche", "debut": 0.09, "duree": 0.36, "frequence": 2093.0, "ratio": 2.4, "indice": 1.8, "gain": 0.44, "decroissance": 2.2},
		],
	},
	"victoire": {
		"duree": 1.5, "variantes": 1, "priorite": 4, "intervalle_ms": 800,
		"simultanes": 1, "retrait": 0.9, "variation_hauteur": 0.0,
		"couches": [
			{"forme": "carre", "duree": 0.18, "frequence": 523.25, "gain": 0.28, "decroissance": 2.0},
			{"forme": "carre", "debut": 0.12, "duree": 0.18, "frequence": 659.26, "gain": 0.28, "decroissance": 2.0},
			{"forme": "carre", "debut": 0.24, "duree": 0.18, "frequence": 783.99, "gain": 0.28, "decroissance": 2.0},
			{"forme": "carre", "debut": 0.36, "duree": 1.1, "frequence": 1046.5, "gain": 0.24, "attaque": 0.02, "decroissance": 1.3},
			{"forme": "triangle", "debut": 0.36, "duree": 1.1, "frequence": 523.25, "gain": 0.32, "attaque": 0.02, "decroissance": 1.2},
			{"forme": "triangle", "debut": 0.36, "duree": 1.1, "frequence": 659.26, "gain": 0.26, "attaque": 0.02, "decroissance": 1.2},
			{"forme": "cloche", "debut": 0.36, "duree": 1.0, "frequence": 2093.0, "ratio": 2.0, "indice": 1.4, "gain": 0.3, "decroissance": 1.8},
		],
	},
	"defaite": {
		"duree": 1.3, "variantes": 1, "priorite": 4, "intervalle_ms": 800,
		"simultanes": 1, "retrait": 0.8, "variation_hauteur": 0.0,
		"couches": [
			{"forme": "triangle", "duree": 0.3, "frequence": 392.0, "gain": 0.4, "decroissance": 1.6},
			{"forme": "triangle", "debut": 0.26, "duree": 0.3, "frequence": 349.23, "gain": 0.4, "decroissance": 1.6},
			{"forme": "triangle", "debut": 0.52, "duree": 0.75, "frequence": 311.13, "fin": 293.66, "gain": 0.42, "decroissance": 1.3},
			{"forme": "chute", "debut": 0.52, "duree": 0.6, "frequence": 120.0, "fin": 55.0, "courbe": 0.5, "gain": 0.4, "decroissance": 1.8},
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
	"choix_legendaire": {"duree_ms": 45, "amplitude": 0.55, "intervalle_ms": 700},
	"niveau": {"duree_ms": 20, "amplitude": 0.35, "intervalle_ms": 500},
	"explosion": {"duree_ms": 40, "amplitude": 0.6, "intervalle_ms": 400},
	"fusion": {"duree_ms": 22, "amplitude": 0.40, "intervalle_ms": 550},
	"coffre": {"duree_ms": 38, "amplitude": 0.48, "intervalle_ms": 700},
}
