class_name Visuels3D
extends RefCounted

# Profil de rendu uniquement : aucune statistique de combat.
const HEROS_MODELE := "res://scenes/3d/aster.tscn"
# Silhouette chibi d'Aster : echelle propre de chaque os, hors pistes d'animation
# (elles n'animent que positions et rotations). La collision reste HEROS_RAYON.
const HEROS_PROPORTIONS := {
	"Head": 1.28, "Thigh.L": .74, "Thigh.R": .74, "UpperArm.L": .86, "UpperArm.R": .86,
	"Spine": .9, "Foot.L": 1.25, "Foot.R": 1.25,
}
# Tissus nuit eclaircis vers un bleu roi, et liseré de contre-jour plus franc.
const HEROS_REHAUSSES := {"Velvet": Vector3(2.2, 1.9, 3.0), "Midnight": Vector3(1.7, 1.55, 2.2)}
const HEROS_FORCE_BORD := .55
# Taille d'ensemble du modele chibi ; les pieds restent poses au sol.
const HEROS_TAILLE_CHIBI := 1.12
# Hauteur projetee du modele natif ; la reserve de la barre reste fixe.
const HEROS_BARRE_VIE_HAUTEUR := 150.0
const HEROS_BARRE_VIE_MARGE := 30.0

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
	"Spine", "Chest", "UpperChest", "Neck", "Head", "Clavicle.R", "Clavicle.L",
	"UpperArm.R", "Forearm.R", "Hand.R", "UpperArm.L", "Forearm.L", "Hand.L",
]
const OMBRES_ANDROID := false
# Rendu « jeu » : courbe filmique, contraste et saturation releves, halo
# lumineux autour des tirs et impacts clairs. Le halo reste a mesurer sur
# telephone ; il disparait avec les effets reduits.
const LUEUR_ANDROID := true
const AMBIANCE_CONTRASTE := 1.12
const AMBIANCE_SATURATION := 1.18
const AMBIANCE_EXPOSITION := 1.05
const LUEUR_INTENSITE := 0.55
const LUEUR_SEUIL := 0.88
const PARTICULES_MAX := 160
const PARTICULES_REDUITES := 48
const DEPOTS_EXPERIENCE_MAX := 96
const COMMUNS := {
	"goutte": "encrier_rampant", "plume": "plume_sentinelle", "dard": "tache_veloce",
	"masque": "scribe_essaimeur", "orbite": "folio_orbiteur", "belier": "sceau_belier",
	"ruban": "marge_harceleuse", "miroir": "miroir_encre", "phaseur": "cachet_phaseur",
	"fuseau": "fuseau_tisseur", "fiole": "fiole_volatile",
}

static func regler_ambiance(environnement: Environment, reduit: bool) -> void:
	environnement.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environnement.tonemap_exposure = AMBIANCE_EXPOSITION
	environnement.tonemap_white = 2.4
	environnement.adjustment_enabled = true
	environnement.adjustment_contrast = AMBIANCE_CONTRASTE
	environnement.adjustment_saturation = AMBIANCE_SATURATION
	environnement.glow_enabled = not reduit and (OS.get_name() != "Android" or LUEUR_ANDROID)
	environnement.glow_intensity = LUEUR_INTENSITE
	environnement.glow_strength = 1.0
	environnement.glow_bloom = 0.0
	environnement.glow_hdr_threshold = LUEUR_SEUIL
	environnement.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT

static func chemin_ennemi(donnees: Dictionary) -> String:
	if donnees.get("cerveau", "") == "boss":
		return "res://assets/3d/bosses/%s_%d.glb" % [
			"miniboss" if donnees.get("rang_boss", "") == "miniboss" else "boss",
			int(donnees.get("ornement", 0))]
	return "res://assets/3d/enemies/%s.glb" % str(COMMUNS.get(donnees.get("forme", ""), "encrier_rampant"))
