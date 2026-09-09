class_name Visuels3D
extends RefCounted

# Profil de rendu uniquement : aucune statistique de combat.
const OMBRES_ANDROID := false
const PARTICULES_MAX := 160
const PARTICULES_REDUITES := 48
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
