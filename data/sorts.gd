class_name Sorts
extends RefCounted

# Les recharges sont en secondes de jeu ; certains passifs rendent du temps.
const ACTIFS := {
	"onde_alchimique": {"nom": "Onde alchimique", "description": "400 % de l’ATK • repousse la zone • récupération 12 s", "recharge": 12.0, "rayon": 180.0, "degats": 4.0, "effet": "repousse"},
	"nova_de_givre": {"nom": "Nova de givre", "description": "350 % de l’ATK • gèle la zone pendant 1,5 s • récupération 15 s", "recharge": 15.0, "rayon": 210.0, "degats": 3.5, "effet": "givre"},
	"barrage_de_braise": {"nom": "Barrage de braise", "description": "500 % de l’ATK • embrase la zone • récupération 15 s", "recharge": 15.0, "rayon": 190.0, "degats": 5.0, "effet": "braise"},
	"impulsion_foudroyante": {"nom": "Impulsion foudroyante", "description": "800 % de l’ATK • zone concentrée • récupération 20 s", "recharge": 20.0, "rayon": 130.0, "degats": 8.0, "effet": ""},
	"explosion_corrosive": {"nom": "Explosion corrosive", "description": "550 % de l’ATK • fragilise la zone • récupération 20 s", "recharge": 20.0, "rayon": 170.0, "degats": 5.5, "effet": "acide"},
	"vortex_alchimique": {"nom": "Vortex alchimique", "description": "450 % de l’ATK • attire les ennemis vers le point visé • récupération 18 s", "recharge": 18.0, "rayon": 260.0, "degats": 4.5, "effet": "attire", "attraction": 180.0},
}

const ULTIMES := {
	"grand_oeuvre": {"nom": "Le Grand Œuvre", "description": "1 200 % de l’ATK dans toute la salle • récupération 75 s", "recharge": 75.0, "degats": 12.0, "effet": ""},
	"temps_suspendu": {"nom": "Temps suspendu", "description": "350 % de l’ATK et gel de 3 s dans toute la salle • récupération 60 s", "recharge": 60.0, "degats": 3.5, "effet": "givre"},
	"transmutation_totale": {"nom": "Transmutation totale", "description": "1 300 % de l’ATK et fragilité dans toute la salle • récupération 90 s", "recharge": 90.0, "degats": 13.0, "effet": "acide"},
	"purification_totale": {"nom": "Purification totale", "description": "800 % de l’ATK dans toute la salle • dissipe tous les projectiles ennemis • récupération 70 s", "recharge": 70.0, "degats": 8.0, "effet": "purifie"},
}

const PASSIFS := {
	# L'identifiant reste stable pour conserver les rangs et les emplacements sauvegardes.
	"moisson_vitale": {"nom": "Moisson vitale", "description": "Récupère 2,5 % des PV max toutes les 6 éliminations • 5 % au rang 2"},
	"sang_froid": {"nom": "Sang-froid", "description": "Les tirs ralentissent les ennemis de 10 % • 20 % au rang 2"},
	"riposte_alchimique": {"nom": "Contrat d’alchimie", "description": "Chaque tir qui touche laisse 2 s une petite flaque cumulable infligeant 10 % des dégâts du tir par seconde • 20 % au rang 2"},
	"reserve_ultime": {"nom": "Sort imprécateur", "description": "Après un sort actif, dégâts +15 % pendant 5 s • +30 % au rang 2"},
	"rempart_initial": {"nom": "Reprise de souffle", "description": "Après 10 s sans subir de dégâts, dégâts +15 % • +30 % au rang 2"},
	"heritage_reactif": {"nom": "Héritage réactif", "description": "Commence l’aventure avec 1 augment rare aléatoire • 2 au rang 2"},
	"audace": {"nom": "Audace", "description": "Dégâts infligés et subis +20 % • +40 % au rang 2"},
	"echo_alchimique": {"nom": "Écho alchimique", "description": "Lancer un sort actif lance un autre sort actif aléatoire au même endroit • 2 sorts au rang 2"},
}

# Reperes de campagne : les deux premieres capacites sont offertes.
# Les autres acquisitions et leurs doublons viennent des tables d'Epreuves.
const NIVEAUX_DEBLOCAGE := {
	"onde_alchimique": 2,
	"grand_oeuvre": 3,
	"moisson_vitale": 4,
	"nova_de_givre": 5,
	"sang_froid": 6,
	"temps_suspendu": 7,
	"riposte_alchimique": 8,
	"barrage_de_braise": 10,
	"reserve_ultime": 11,
	"rempart_initial": 13,
	"impulsion_foudroyante": 15,
	"heritage_reactif": 17,
	"audace": 19,
	"transmutation_totale": 21,
	"echo_alchimique": 23,
	"explosion_corrosive": 25,
	"vortex_alchimique": 26,
	"purification_totale": 28,
}

const RECOMPENSES_CAMPAGNE := {
	2: "onde_alchimique",
	3: "grand_oeuvre",
}

static func contient(id: String) -> bool:
	return ACTIFS.has(id) or PASSIFS.has(id) or ULTIMES.has(id)

static func rang_max(id: String) -> int:
	return Reglages.PASSIF_RANG_MAX if PASSIFS.has(id) else Reglages.CAPACITE_RANG_MAX

static func nombre_capacites_debloquees(rangs: Dictionary, tout_debloque := false) -> int:
	if tout_debloque:
		return ACTIFS.size() + PASSIFS.size() + ULTIMES.size()
	var nombre := 0
	for id in rangs:
		if contient(str(id)) and int(rangs[id]) > 0:
			nombre += 1
	return nombre

static func multiplicateur_degats_deblocages(rangs: Dictionary, tout_debloque := false) -> float:
	return 1.0

static func niveau_deblocage(id: String) -> int:
	return int(NIVEAUX_DEBLOCAGE.get(id, Chapitres.nombre()))

static func recompense_campagne(niveau_campagne: int) -> String:
	return str(RECOMPENSES_CAMPAGNE.get(niveau_campagne, ""))

static func donnees(id: String) -> Dictionary:
	for catalogue in [ACTIFS, PASSIFS, ULTIMES]:
		if catalogue.has(id):
			return catalogue[id]
	return {}

static func _pourcentage(valeur: float) -> String:
	return _nombre(valeur * 100.0)

static func _nombre(valeur: float) -> String:
	return String.num(valeur, 2).trim_suffix(".00").trim_suffix(".0").replace(".", ",")

static func resume_rang(id: String, rang: int) -> String:
	var rang_affiche := clampi(rang, 1, rang_max(id))
	var efficacite := 1.0 + float(rang_affiche - 1) * Reglages.CAPACITE_BONUS_PAR_RANG
	var passif := {id: rang_affiche}
	if ACTIFS.has(id) or ULTIMES.has(id):
		return "%s %% de l’ATK" % _pourcentage(float(donnees(id)["degats"]) * efficacite)
	match id:
		"rempart_initial": return "+%s %% de dégâts après %s s sans blessure" % [_pourcentage(bonus_reprise(passif)), _nombre(Reglages.REPRISE_DELAI)]
		"heritage_reactif": return "%d augment(s) rare(s) aléatoire(s) au début de l’aventure" % augments_heritage(passif)
		"moisson_vitale": return "%s %% des PV toutes les %d éliminations" % [_pourcentage(soin_moisson(passif)), seuil_moisson(passif)]
		"riposte_alchimique": return "Flaque de %s s : %s %% des dégâts du tir par seconde" % [_nombre(Reglages.CONTRAT_DUREE), _pourcentage(part_contrat(passif))]
		"reserve_ultime": return "+%s %% de dégâts pendant %s s après un sort actif" % [_pourcentage(bonus_sort_imprecateur(passif)), _nombre(Reglages.SORT_IMPRECATEUR_DUREE)]
		"sang_froid": return "Les tirs ralentissent de %s %% pendant %s s" % [_pourcentage(ralentissement_sang_froid(passif)), _nombre(Reglages.SANG_FROID_DUREE)]
		"audace": return "Dégâts infligés et subis +%s %%" % _pourcentage(bonus_audace(passif))
		"echo_alchimique": return "%d autre(s) sort(s) actif(s) aléatoire(s) au même endroit" % nombre_echos(passif)
	return ""

static func progression_rang(id: String) -> String:
	if PASSIFS.has(id):
		return "Un seul doublon : le rang 2 double l’effet du passif."
	return "+%s %% du coefficient d’ATK de départ par rang." % _pourcentage(Reglages.CAPACITE_BONUS_PAR_RANG)

static func _a(passifs: Dictionary, id: String) -> bool:
	return passifs.has(id)

static func rang_passif(passifs: Dictionary, id: String) -> int:
	if not _a(passifs, id): return 0
	return clampi(roundi(float(passifs[id])), 1, Reglages.PASSIF_RANG_MAX)

static func effet_double(passifs: Dictionary, id: String, base: float) -> float:
	return base * float(rang_passif(passifs, id))

static func augments_heritage(passifs: Dictionary) -> int:
	return rang_passif(passifs, "heritage_reactif") * Reglages.HERITAGE_AUGMENTS_RARES

static func seuil_moisson(_passifs: Dictionary) -> int:
	return Reglages.MOISSON_SEUIL

static func soin_moisson(passifs: Dictionary) -> float:
	return effet_double(passifs, "moisson_vitale", Reglages.MOISSON_PART)

static func bonus_reprise(passifs: Dictionary) -> float:
	return effet_double(passifs, "rempart_initial", Reglages.REPRISE_DEGATS)

static func part_contrat(passifs: Dictionary) -> float:
	return effet_double(passifs, "riposte_alchimique", Reglages.CONTRAT_PART_DEGATS)

static func bonus_sort_imprecateur(passifs: Dictionary) -> float:
	return effet_double(passifs, "reserve_ultime", Reglages.SORT_IMPRECATEUR_DEGATS)

static func ralentissement_sang_froid(passifs: Dictionary) -> float:
	return effet_double(passifs, "sang_froid", Reglages.SANG_FROID_RALENTISSEMENT)

static func bonus_audace(passifs: Dictionary) -> float:
	return effet_double(passifs, "audace", Reglages.AUDACE_BONUS)

static func nombre_echos(passifs: Dictionary) -> int:
	return rang_passif(passifs, "echo_alchimique")

static func bonus_invulnerabilite(_passifs: Dictionary) -> float:
	return 0.0

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

static func recharge(id: String, _passifs: Dictionary, maitrises: Dictionary, arme: String,
		facteur_augments := 1.0) -> float:
	var d := donnees(id)
	var facteur := ArbreCompetences.multiplicateur_recharge(maitrises) * facteur_augments
	facteur *= float(CatalogueProjectiles.TYPES.get(arme, {}).get("recharge_mult", 1.0))
	return float(d.get("recharge", 0.0)) * maxf(Reglages.RECHARGE_PLANCHER, facteur)
