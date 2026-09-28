extends RefCounted

# Enveloppes visuelles uniquement ; les collisions restent sur les acteurs 2D.
const ATTAQUE_DUREE := 0.32
const ATTAQUE_REARMEMENT := 0.10
const IMPACT_DUREE := 0.16
const LISSAGE_POSE := 18.0
const LISSAGE_ORIENTATION := 12.0
const CADENCE_MIN := 0.65
const CADENCE_MAX := 1.65
const PREPARATION_INCLINAISON := 0.14
const CHARGE_INCLINAISON := 0.24
const RECUL := 0.11
const PHASE_HAUTEUR := 0.12
const PHASE_ECHELLE_MIN := 0.28
const PHASE_RETOUR_PART := 0.5
const IMPACTS_MAX := 32
const IMPACTS_REDUITS := 10
const PERCUSSION_DUREE := 0.30
const DISSIPATION_DUREE := 0.52
const DISSIPATION_CORPS_DUREE := 0.24
const DISSIPATION_CORPS_REDUITE := 0.12
const DISSIPATIONS_MAX := 16
const DISSIPATIONS_REDUITES := 4
const PERCUSSION_RAYON := 34.0
const DISSIPATION_RAYON := 100.0
const LOB_HAUTEUR := 160.0
const ANNONCE_COULEUR := Color("ff3f42")
const ANNONCE_CONTRASTE := Color("471322")
const ANNONCE_TRAIT := 4.0
const ANNONCE_ANNEAU_PORTEE := 340.0
const ZONES_COULEURS := {
	"impact": Color("c49aff"), "eboulis": Color("e3bd7e"),
	"maree": Color("77d9ed"), "foudre": Color("ffed9e"), "braise": Color("ff9b50"),
}
