class_name Visuels3D
extends RefCounted

# Profil de rendu uniquement : aucune statistique de combat.
const HEROS_MODELE := "res://assets/3d/characters/mage_sculpte.glb"

const HEROS_CADENCE_COURSE := 1.0
const HEROS_TRANSITION_MOUVEMENT := 0.18
const HEROS_TRANSITION_TIR := 0.015
const HEROS_RETOUR_TIR := 0.045
const HEROS_LISSAGE_CADENCE := 9.0
const HEROS_LISSAGE_MOUVEMENT := 14.0
const HEROS_TRANSITION_IMPACT := 0.06
const HEROS_SEUIL_REPOS := 4.0
const HEROS_VITESSE_PLEINE_POSE := 180.0
const HEROS_CADENCE_MIN := 0.5
const HEROS_CADENCE_MAX := 2.0
const HEROS_SEUIL_TELEPORTATION := 160.0
const HEROS_LISSAGE_ORIENTATION := 14.0
const HEROS_INCLINAISON_VIRAGE := 0.075
const HEROS_OS_HAUT := [
	"torse", "tete", "chapeau", "bras_droite", "avant_bras_droite", "main_droite",
	"bras_gauche", "avant_bras_gauche", "main_gauche",
]
const OMBRES_ANDROID := false
const PARTICULES_MAX := 160
const PARTICULES_REDUITES := 48
const DEPOTS_EXPERIENCE_MAX := 96
const COMMUNS := {
	"goutte": "encrier_rampant", "plume": "plume_sentinelle", "dard": "tache_veloce",
	"masque": "scribe_essaimeur", "orbite": "folio_orbiteur", "belier": "sceau_belier",
	"ruban": "marge_harceleuse", "miroir": "miroir_encre", "phaseur": "cachet_phaseur",
	"fuseau": "fuseau_tisseur", "fiole": "fiole_volatile",
}

static func chemin_ennemi(donnees: Dictionary) -> String:
	if donnees.get("cerveau", "") == "boss":
		return "res://assets/3d/bosses/%s_%d.glb" % [
			"miniboss" if donnees.get("rang_boss", "") == "miniboss" else "boss",
			int(donnees.get("ornement", 0))]
	return "res://assets/3d/enemies/%s.glb" % str(COMMUNS.get(donnees.get("forme", ""), "encrier_rampant"))
