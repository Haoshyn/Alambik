class_name AttaquesContactBoss
extends RefCounted

# Approche bornee, direction figee pendant l'annonce, une frappe puis du repos.
# La portee est mesuree depuis le centre du boss ; l'arc est en radians.
const PROFILS := {
	"la_rature": {"nom": "Balayage de griffes", "approche": 1.35, "vitesse": 1.75, "annonce": .60, "portee": 215.0, "arc": PI * .85, "repos": 1.10},
	"reliure_affamee": {"nom": "Morsure de reliure", "approche": 1.65, "vitesse": 1.55, "annonce": .65, "portee": 245.0, "arc": PI * .60, "repos": 1.20},
	"signet_sanglant": {"nom": "Entaille du signet", "approche": 1.30, "vitesse": 1.80, "annonce": .55, "portee": 230.0, "arc": PI * .65, "repos": 1.15},
	"roi_braises": {"nom": "Marteau de braise", "approche": 1.60, "vitesse": 1.60, "annonce": .80, "portee": 255.0, "arc": TAU, "repos": 1.40},
	"souverain_ombres": {"nom": "Fauchage d’ombre", "approche": 1.35, "vitesse": 1.85, "annonce": .65, "portee": 255.0, "arc": PI * .90, "repos": 1.25},
	"gardien_runes": {"nom": "Poing de schiste", "approche": 2.0, "vitesse": 2.0, "annonce": .80, "portee": 285.0, "arc": PI * .80, "repos": 1.50},
	"devoreur_neant": {"nom": "Morsure du néant", "approche": 1.65, "vitesse": 1.65, "annonce": .75, "portee": 275.0, "arc": PI * .70, "repos": 1.40},
	"grand_alambic": {"nom": "Choc du creuset", "approche": 1.80, "vitesse": 1.75, "annonce": .85, "portee": 280.0, "arc": TAU, "repos": 1.50},
}
const FRAPPE_DUREE := .18
const DISTANCE_ARRET := .78
const CHARGE_DISTANCE_MAX := 1150.0
const CHARGE_RECUPERATION := 1.10

static func enrichir(donnees: Dictionary, id: String) -> void:
	if not PROFILS.has(id): return
	donnees["contact_boss"] = id
	for cle in ["motifs_phase_1", "motifs_phase_2"]:
		var resultat: Array[String] = ["assaut_contact"]
		for motif: String in donnees[cle]:
			if motif != "pause": resultat.append(motif)
		resultat.append("pause")
		donnees[cle] = resultat

static func duree(profil: Dictionary) -> float:
	return float(profil["approche"]) + float(profil["annonce"]) + FRAPPE_DUREE + float(profil["repos"])

static func contient_cible(origine: Vector2, direction: Vector2, cible: Vector2, profil: Dictionary, rayon_cible: float) -> bool:
	var ecart := cible - origine
	var distance := ecart.length()
	if distance > float(profil["portee"]) + rayon_cible: return false
	if distance <= rayon_cible: return true
	var marge_angle := asin(clampf(rayon_cible / distance, 0.0, 1.0))
	return absf(direction.angle_to(ecart)) <= float(profil["arc"]) * .5 + marge_angle
