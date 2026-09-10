class_name Visuels3D
extends RefCounted

# Profil de rendu uniquement : aucune statistique de combat.
const OMBRES_ANDROID := false
const PARTICULES_MAX := 160
const PARTICULES_REDUITES := 48
# Pierre, eau et bordures : la palette de chaque monde reste lumineuse.
const AMBIANCES := [
	[Color("b5c3b0"), Color("488e96"), Color("c3cabb")],
	[Color("cab7a3"), Color("74949a"), Color("d9b78c")],
	[Color("b7cbd2"), Color("608fae"), Color("d0dce2")],
	[Color("c9c6ad"), Color("637ca0"), Color("d8c995")],
	[Color("b1c3a6"), Color("588e80"), Color("c4d2b2")],
	[Color("c0b7cb"), Color("777eab"), Color("d3c5de")],
	[Color("aeb7c9"), Color("60778d"), Color("bdc6d7")],
	[Color("b4c9bc"), Color("488f8a"), Color("c6d9c3")],
	[Color("c0b2c5"), Color("81789a"), Color("d5c2d3")],
	[Color("cfc2a6"), Color("548d94"), Color("e0ceab")],
]
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
