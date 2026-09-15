class_name Sorts
extends RefCounted

# Les recharges sont en secondes de jeu et ne dependent ni des impacts ni des morts.
const ACTIFS := {
	"onde_alchimique": {"nom": "Onde alchimique", "description": "Repousse la zone ciblée • 12 s de récupération", "recharge": 12.0, "rayon": 180.0, "degats": 5.0, "effet": "repousse"},
	"nova_de_givre": {"nom": "Nova de givre", "description": "Gèle la zone ciblée • 16 s de récupération", "recharge": 16.0, "rayon": 210.0, "degats": 6.0, "effet": "givre"},
	"barrage_de_braise": {"nom": "Barrage de braise", "description": "Embrase la zone ciblée • 18 s de récupération", "recharge": 18.0, "rayon": 190.0, "degats": 8.0, "effet": "braise"},
	"impulsion_foudroyante": {"nom": "Impulsion foudroyante", "description": "Frappe précise ciblée • 20 s de récupération", "recharge": 20.0, "rayon": 130.0, "degats": 10.0, "effet": ""},
	"explosion_corrosive": {"nom": "Explosion corrosive", "description": "Fragilise la zone ciblée • 22 s de récupération", "recharge": 22.0, "rayon": 170.0, "degats": 11.0, "effet": "acide"},
}

const ULTIMES := {
	"grand_oeuvre": {"nom": "Le Grand Œuvre", "description": "Frappe toute la salle • récupération 75 s", "recharge": 75.0, "degats": 14.0, "effet": ""},
	"temps_suspendu": {"nom": "Temps suspendu", "description": "Gèle toute la salle pendant 5 s • récupération 55 s", "recharge": 55.0, "degats": 4.0, "effet": "givre"},
	"transmutation_totale": {"nom": "Transmutation totale", "description": "Frappe et fragilise toute la salle • récupération 90 s", "recharge": 90.0, "degats": 19.0, "effet": "acide"},
}

const PASSIFS := {
	"rempart_initial": {"nom": "Rempart initial", "description": "Bouclier à chaque salle • -12 % de dégâts subis en permanence"},
	"heritage_reactif": {"nom": "Héritage réactif", "description": "Commence chaque grimoire avec 2 Améliorations aléatoires"},
	"moisson_vitale": {"nom": "Moisson vitale", "description": "Toutes les 6 éliminations, récupère 2 % des PV • soins limités à 5 % par salle"},
	"riposte_alchimique": {"nom": "Riposte alchimique", "description": "Être touché déclenche une déflagration massive qui repousse"},
	"seconde_chance": {"nom": "Seconde chance", "description": "Une fois par aventure, survit à la mort avec 30 % des PV"},
	"reserve_ultime": {"nom": "Réserve d’ultime", "description": "Délai de récupération de l’ultime réduit de 45 %"},
	"sang_froid": {"nom": "Sang-froid", "description": "Délai de récupération du sort actif réduit de 15 %"},
	"dernier_rempart": {"nom": "Dernier rempart", "description": "Sous 40 % de PV, subit 30 % de dégâts en moins"},
	"audace": {"nom": "Audace", "description": "Sous 60 % de PV, inflige 30 % de dégâts en plus"},
	"echo_alchimique": {"nom": "Écho alchimique", "description": "25 % de chance que le Sort frappe une seconde fois à 60 %"},
}

# La campagne revele l'arsenal par petites touches. Les deux premieres capacites
# sont offertes afin que la boucle Sort + Ultime existe des le Monde I ; les
# suivantes entrent seulement dans la pool des Epreuves au fil des chapitres.
const NIVEAUX_DEBLOCAGE := {
	"onde_alchimique": 2,
	"grand_oeuvre": 3,
	"rempart_initial": 4,
	"nova_de_givre": 5,
	"heritage_reactif": 6,
	"temps_suspendu": 7,
	"moisson_vitale": 8,
	"barrage_de_braise": 10,
	"riposte_alchimique": 11,
	"seconde_chance": 13,
	"impulsion_foudroyante": 15,
	"reserve_ultime": 17,
	"sang_froid": 19,
	"transmutation_totale": 21,
	"dernier_rempart": 23,
	"explosion_corrosive": 25,
	"audace": 27,
	"echo_alchimique": 29,
}

const RECOMPENSES_CAMPAGNE := {
	2: "onde_alchimique",
	3: "grand_oeuvre",
}

static func contient(id: String) -> bool:
	return ACTIFS.has(id) or PASSIFS.has(id) or ULTIMES.has(id)

static func niveau_deblocage(id: String) -> int:
	return int(NIVEAUX_DEBLOCAGE.get(id, Chapitres.nombre()))

static func disponible_au_niveau(id: String, niveau_campagne: int) -> bool:
	return contient(id) and niveau_campagne >= niveau_deblocage(id)

static func recompense_campagne(niveau_campagne: int) -> String:
	return str(RECOMPENSES_CAMPAGNE.get(niveau_campagne, ""))

static func donnees(id: String) -> Dictionary:
	for catalogue in [ACTIFS, PASSIFS, ULTIMES]:
		if catalogue.has(id):
			return catalogue[id]
	return {}

static func _a(passifs: Dictionary, id: String) -> bool:
	return passifs.has(id)

static func multiplicateur_degats(passifs: Dictionary) -> float:
	return 1.0

# Rempart initial ne valait qu'un bouclier par salle, soit un coup encaisse
# toutes les deux minutes. Il porte maintenant une reduction permanente.
static func multiplicateur_degats_recus(passifs: Dictionary) -> float:
	return maxf(0.30, 1.0 - Reglages.REMPART_REDUCTION * float(passifs.get("rempart_initial", 0.0)))

static func multiplicateur_vitesse(passifs: Dictionary) -> float:
	return 1.0

static func multiplicateur_cadence(passifs: Dictionary) -> float:
	return 1.0

static func multiplicateur_projectile(passifs: Dictionary) -> float:
	return 1.0

static func multiplicateur_pv(passifs: Dictionary) -> float:
	return 1.0

static func soin_par_salle(passifs: Dictionary) -> float:
	return 0.0

static func donne_bouclier(passifs: Dictionary) -> bool:
	return _a(passifs, "rempart_initial")

static func multiplicateur_recharge_active(passifs: Dictionary) -> float:
	return maxf(0.25, 1.0 - Reglages.SANG_FROID_RECHARGE * float(passifs.get("sang_froid", 0.0)))

static func multiplicateur_charge_ultime(passifs: Dictionary) -> float:
	return maxf(0.35, 1.0 - Reglages.RESERVE_ULTIME_REMISE * float(passifs.get("reserve_ultime", 0.0)))

static func multiplicateur_degats_conditionnel(passifs: Dictionary, ratio_pv: float) -> float:
	return (1.0 + Reglages.AUDACE_BONUS * float(passifs.get("audace", 0.0))) \
		if ratio_pv < Reglages.AUDACE_SEUIL_PV else 1.0

static func multiplicateur_degats_recus_conditionnel(passifs: Dictionary, ratio_pv: float) -> float:
	return (1.0 - Reglages.DERNIER_REMPART_REDUCTION * float(passifs.get("dernier_rempart", 0.0))) \
		if ratio_pv < Reglages.DERNIER_REMPART_SEUIL_PV else 1.0

static func recharge(id: String, passifs: Dictionary, maitrises: Dictionary, arme: String) -> float:
	var d := donnees(id)
	var facteur := multiplicateur_charge_ultime(passifs) if ULTIMES.has(id) else multiplicateur_recharge_active(passifs)
	facteur *= ArbreCompetences.multiplicateur_recharge(maitrises)
	facteur *= float(CatalogueProjectiles.TYPES.get(arme, {}).get("recharge_mult", 1.0))
	return float(d.get("recharge", 0.0)) * maxf(Reglages.RECHARGE_PLANCHER, facteur)
