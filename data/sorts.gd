class_name Sorts
extends RefCounted

const CombatPassifs = preload("res://data/passifs_combat.gd")
const BONUS_FINAL_PAR_DEBLOCAGE := 0.10

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
	"rempart_initial": {"nom": "Reprise de souffle", "description": "Après une blessure, ajoute 0,35 s d’invulnérabilité pour se dégager", "bonus_par_rang": 0.05},
	"heritage_reactif": {"nom": "Héritage réactif", "description": "Jusqu’à %d relances supplémentaires par aventure • plafond de %d au total, maîtrises comprises" % [Reglages.HERITAGE_RELANCES, Reglages.RELANCES_MAX_PAR_RUN]},
	"moisson_vitale": {"nom": "Moisson vitale", "description": "Récupère 3 % des PV max toutes les 6 éliminations, même si les soins d’augmentations sont épuisés", "bonus_par_rang": 0.003},
	"riposte_alchimique": {"nom": "Riposte alchimique", "description": "Une blessure déclenche une onde à 300 % de l’ATK cumulée, puis applique les bonus de dégâts finaux • repousse • récupération 2 s"},
	"seconde_chance": {"nom": "Seconde chance", "description": "Une fois par aventure, survit à la mort avec 50 % des PV max et un bouclier", "bonus_par_rang": 0.04},
	"reserve_ultime": {"nom": "Réserve d’ultime", "description": "Un sort actif qui touche un ennemi rend 5 s de récupération à l’ultime • une fois par lancement", "bonus_par_rang": CombatPassifs.RESERVE_GAIN_PAR_RANG},
	"sang_froid": {"nom": "Sang-froid", "description": "Se déplacer arme le prochain tir : ralentissement de givre et 2 perforations supplémentaires", "bonus_par_rang": CombatPassifs.SANG_FROID_REDUCTION_PAR_RANG},
	"dernier_rempart": {"nom": "Dernier rempart", "description": "Une blessure sous 50 % des PV repousse les ennemis proches et dissipe leurs projectiles • une fois par salle", "bonus_par_rang": CombatPassifs.REMPART_GAIN_PAR_RANG},
	"audace": {"nom": "Audace", "description": "Une blessure sous 60 % des PV recharge immédiatement le sort actif • une fois par salle", "bonus_par_rang": CombatPassifs.AUDACE_GAIN_PAR_RANG},
	"echo_alchimique": {"nom": "Écho alchimique", "description": "35 % de chance de répéter le sort actif avec 100 % de ses dégâts finaux et ses effets", "bonus_par_rang": 0.035},
}

# Reperes de campagne : les deux premieres capacites sont offertes.
# Les autres acquisitions et leurs doublons viennent des tables d'Epreuves.
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
	"vortex_alchimique": 26,
	"audace": 27,
	"purification_totale": 28,
	"echo_alchimique": 29,
}

const RECOMPENSES_CAMPAGNE := {
	2: "onde_alchimique",
	3: "grand_oeuvre",
}

static func contient(id: String) -> bool:
	return ACTIFS.has(id) or PASSIFS.has(id) or ULTIMES.has(id)

static func nombre_capacites_debloquees(rangs: Dictionary, tout_debloque := false) -> int:
	if tout_debloque:
		return ACTIFS.size() + PASSIFS.size() + ULTIMES.size()
	var nombre := 0
	for id in rangs:
		if contient(str(id)) and int(rangs[id]) > 0:
			nombre += 1
	return nombre

static func multiplicateur_degats_deblocages(rangs: Dictionary, tout_debloque := false) -> float:
	return 1.0 + nombre_capacites_debloquees(rangs, tout_debloque) * BONUS_FINAL_PAR_DEBLOCAGE

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
	var rang_affiche := clampi(rang, 1, Reglages.CAPACITE_RANG_MAX)
	var efficacite := 1.0 + float(rang_affiche - 1) * Reglages.CAPACITE_BONUS_PAR_RANG
	var passif := {id: efficacite}
	if ACTIFS.has(id) or ULTIMES.has(id):
		return "%s %% de l’ATK" % _pourcentage(float(donnees(id)["degats"]) * efficacite)
	match id:
		"rempart_initial": return "+%s s d’invulnérabilité après une blessure" % _nombre(bonus_invulnerabilite(passif))
		"heritage_reactif": return "Jusqu’à %d relance(s) supplémentaire(s) • maximum %d au total, maîtrises comprises" % [relances_heritage(passif), Reglages.RELANCES_MAX_PAR_RUN]
		"moisson_vitale": return "%s %% des PV toutes les %d éliminations" % [_pourcentage(soin_moisson(passif)), seuil_moisson(passif)]
		"riposte_alchimique": return "%s %% de l’ATK cumulée, puis bonus de dégâts finaux • récupération %s s" % [_pourcentage(Reglages.RIPOSTE_PART_DEGATS * efficacite), _nombre(Reglages.RIPOSTE_RECHARGE)]
		"seconde_chance": return "Résurrection avec %s %% des PV" % _pourcentage(soin_seconde_chance(passif))
		"reserve_ultime": return "%s s rendues à l’ultime quand le sort actif touche" % _nombre(temps_reserve(passif))
		"sang_froid": return "Tir givrant et +%d perforations après %s unités de déplacement" % [CombatPassifs.SANG_FROID_PERFORATIONS, _nombre(distance_sang_froid(passif))]
		"dernier_rempart": return "Repousse et dissipe dans un rayon de %s sous %s %% des PV • une fois par salle" % [_nombre(rayon_rempart(passif)), _pourcentage(CombatPassifs.REMPART_SEUIL_PV)]
		"audace": return "Sort actif rechargé sur blessure sous %s %% des PV • une fois par salle" % _pourcentage(seuil_audace(passif))
		"echo_alchimique": return "%s %% de chance de répéter %s %% des dégâts finaux du sort" % [_pourcentage(chance_echo(passif)), _pourcentage(Reglages.ECHO_PART_DEGATS)]
	return ""

static func progression_rang(id: String) -> String:
	if id == "heritage_reactif":
		if Reglages.HERITAGE_RELANCES >= Reglages.RELANCES_MAX_PAR_RUN:
			return "Plafond atteint dès le rang 1 : %d relances par aventure, toutes sources confondues." % Reglages.RELANCES_MAX_PAR_RUN
		return "+1 relance tous les %d rangs, jusqu’au plafond de %d par aventure, toutes sources confondues." % [Reglages.PASSIF_RANGS_PAR_PALIER, Reglages.RELANCES_MAX_PAR_RUN]
	if id == "rempart_initial":
		return "+%s s d’invulnérabilité par rang." % _nombre(gain_passif_par_rang(id))
	if id == "reserve_ultime":
		return "+%s s rendues par rang." % _nombre(gain_passif_par_rang(id))
	if id == "sang_froid":
		return "−%s unités de déplacement nécessaires par rang." % _nombre(gain_passif_par_rang(id))
	if id == "dernier_rempart":
		return "+%s de rayon par rang." % _nombre(gain_passif_par_rang(id))
	if id == "audace":
		return "+%s points au seuil de PV par rang." % _pourcentage(gain_passif_par_rang(id))
	if PASSIFS.has(id) and id != "riposte_alchimique":
		return "+%s point(s) de pourcentage par rang." % _pourcentage(gain_passif_par_rang(id))
	return "+%s %% du coefficient d’ATK de départ par rang." % _pourcentage(Reglages.CAPACITE_BONUS_PAR_RANG)

static func _a(passifs: Dictionary, id: String) -> bool:
	return passifs.has(id)

static func rang_passif(passifs: Dictionary, id: String) -> int:
	if not _a(passifs, id): return 0
	var efficacite := float(passifs[id])
	return clampi(1 + roundi((efficacite - 1.0) / Reglages.CAPACITE_BONUS_PAR_RANG), 1, Reglages.CAPACITE_RANG_MAX)

# L'efficacite est reconstruite a partir du rang sauvegarde. Les passifs la
# convertissent en points fixes adaptes a leur effet, sans changer les acquis.
static func gain_passif_par_rang(id: String) -> float:
	var passif: Dictionary = PASSIFS.get(id, {})
	return float(passif.get("bonus_par_rang", 0.0))

static func bonus_passif(passifs: Dictionary, id: String, base: float) -> float:
	var rang := rang_passif(passifs, id)
	return 0.0 if rang == 0 else base + float(rang - 1) * gain_passif_par_rang(id)

static func relances_heritage(passifs: Dictionary) -> int:
	var rang := rang_passif(passifs, "heritage_reactif")
	if rang == 0:
		return 0
	return mini(Reglages.RELANCES_MAX_PAR_RUN, Reglages.HERITAGE_RELANCES + floori(float(rang - 1) / Reglages.PASSIF_RANGS_PAR_PALIER))

static func seuil_moisson(_passifs: Dictionary) -> int:
	return Reglages.MOISSON_SEUIL

static func soin_moisson(passifs: Dictionary) -> float:
	return bonus_passif(passifs, "moisson_vitale", Reglages.MOISSON_PART)

static func bonus_invulnerabilite(passifs: Dictionary) -> float:
	return bonus_passif(passifs, "rempart_initial", Reglages.REPRISE_INVULNERABILITE)

static func soin_seconde_chance(passifs: Dictionary) -> float:
	return bonus_passif(passifs, "seconde_chance", Reglages.SECONDE_CHANCE_PART)

static func chance_echo(passifs: Dictionary) -> float:
	return bonus_passif(passifs, "echo_alchimique", Reglages.ECHO_CHANCE)

static func temps_reserve(passifs: Dictionary) -> float:
	return bonus_passif(passifs, "reserve_ultime", CombatPassifs.RESERVE_SECONDES)

static func distance_sang_froid(passifs: Dictionary) -> float:
	var rang := rang_passif(passifs, "sang_froid")
	return CombatPassifs.SANG_FROID_DISTANCE - maxi(0, rang - 1) * CombatPassifs.SANG_FROID_REDUCTION_PAR_RANG

static func seuil_audace(passifs: Dictionary) -> float:
	return bonus_passif(passifs, "audace", CombatPassifs.AUDACE_SEUIL_PV)

static func rayon_rempart(passifs: Dictionary) -> float:
	return bonus_passif(passifs, "dernier_rempart", CombatPassifs.REMPART_RAYON)

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
