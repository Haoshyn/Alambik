class_name ProgressionAugments
extends RefCounted

# La campagne distribue 25 choix avant le boss final. L'XP peut les avancer
# pendant une salle ; sa fin garantit le palier pour ne pas penaliser un tirage
# de vagues peu genereux. Le plafond empeche de farmer les invocations d'un boss.
const XP_SEUILS := [4, 8, 14, 20, 26, 34, 42, 52, 65, 80, 88, 96, 105,
	115, 125, 135, 145, 155, 165, 175, 184, 193, 202, 211, 220]
const NIVEAUX_LEGENDAIRES := [5, 10, 15, 20, 25]
const NOMBRE_CHOIX := 3
const CHANCE_RARE_DEBUT := 0.15
const CHANCE_RARE_FIN := 0.35
const SOIN_NIVEAU := 0.01
const SOIN_CHOIX := 0.16
const SOIN_AVANT_BOSS := 0.20
const DERNIER_NIVEAU_AVIDITE := 15

# Ces trajectoires se remplacent, elles ne se cumulent pas dans Projectile.
# Ne jamais vendre au joueur une amelioration neutralisee par son build.
const INCOMPATIBLES := {
	"trait_transpercant": ["perforation", "ricochet"],
	"perforation": ["trait_transpercant"],
	"ricochet": ["trait_transpercant"],
}

static func niveau_max() -> int:
	return XP_SEUILS.size()

static func est_legendaire(niveau: int) -> bool:
	return niveau in NIVEAUX_LEGENDAIRES

static func plafond_salle(salle: int, total_salles: int) -> int:
	var salles_utiles := maxi(1, total_salles - 1)
	return clampi(floori(float(maxi(0, salle) * niveau_max()) / float(salles_utiles)),
		0, niveau_max())

static func tirer_rarete(niveau: int, rng: RandomNumberGenerator) -> String:
	if est_legendaire(niveau):
		return Reactif.LEGENDAIRE
	var avancement := clampf(float(niveau - 1) / float(niveau_max() - 1), 0.0, 1.0)
	var chance := lerpf(CHANCE_RARE_DEBUT, CHANCE_RARE_FIN, avancement)
	return Reactif.RARE if rng.randf() < chance else Reactif.COMMUN

static func prochain_legendaire(niveau: int) -> int:
	for palier: int in NIVEAUX_LEGENDAIRES:
		if palier > niveau:
			return palier
	return 0
