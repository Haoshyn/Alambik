class_name Stats
extends RefCounted

var pv_max: float
var pv: float
var soin_restant := INF
var vitesse: float
var cadence: float          # tirs par seconde
var attaque_base: float
var bonus_attaque: float
var degats: float           # ATK reelle permanente, avant coefficients et degats finaux
var vitesse_projectile: float
var portee: float

# Le parametre niveau est conserve pour compatibilite avec la progression, mais
# le niveau de compte ne donne plus de statistiques brutes. Maitrises, Passifs
# et equipement portent la progression permanente de combat.
static func base_pv(niveau: int) -> float:
	return Reglages.HEROS_PV * (1.0 + float(maxi(0, niveau - 1)) * Reglages.NIVEAU_PV_PAR_NIVEAU)

static func base_degats(niveau: int) -> float:
	return Reglages.TIR_DEGATS * (1.0 + float(maxi(0, niveau - 1)) * Reglages.NIVEAU_DEGATS_PAR_NIVEAU)

static func base_cadence(niveau: int) -> float:
	return Reglages.HEROS_CADENCE * (1.0 + float(maxi(0, niveau - 1)) * Reglages.NIVEAU_CADENCE_PAR_NIVEAU)

static func depuis_reglages(rangs: Dictionary = {}, passifs: Dictionary = {}, objets: Dictionary = {},
		niveau := 1) -> Stats:
	var s := Stats.new()
	s.pv_max = (base_pv(niveau) + float(objets.get("pv_base", 0.0)) + ArbreCompetences.bonus_pv(rangs)) \
		* ArbreCompetences.multiplicateur_pv(rangs) * Sorts.multiplicateur_pv(passifs)
	s.pv = s.pv_max
	s.vitesse = Reglages.HEROS_VITESSE * ArbreCompetences.multiplicateur_vitesse(rangs) * Sorts.multiplicateur_vitesse(passifs) * (1.0 + float(objets.get("vitesse", 0.0)))
	s.cadence = base_cadence(niveau) * ArbreCompetences.multiplicateur_cadence(rangs) * Sorts.multiplicateur_cadence(passifs) * (1.0 + float(objets.get("cadence", 0.0)))
	s.attaque_base = base_degats(niveau) + float(objets.get("attaque_base", 0.0))
	s.bonus_attaque = ArbreCompetences.bonus_attaque(rangs)
	s.degats = s.attaque_reelle()
	s.vitesse_projectile = Reglages.TIR_VITESSE * ArbreCompetences.multiplicateur_projectile(rangs) * Sorts.multiplicateur_projectile(passifs)
	s.portee = Reglages.TIR_PORTEE * ArbreCompetences.multiplicateur_projectile(rangs) * Sorts.multiplicateur_projectile(passifs)
	return s

func attaque_reelle(bonus_supplementaire := 0.0) -> float:
	return attaque_base * maxf(Reglages.MODS_PLANCHER, 1.0 + bonus_attaque + bonus_supplementaire)

func blesser(montant: float) -> void:
	pv = maxf(0.0, pv - montant)

func soigner(montant: float) -> void:
	if est_mort():
		return
	var rendu := minf(maxf(0.0, montant), minf(pv_max - pv, soin_restant))
	pv += rendu
	soin_restant -= rendu

func soigner_garanti(montant: float) -> void:
	# Une riposte mortelle peut tuer un ennemi et declencher un soin avant que
	# le heros traite sa mort ; seule Seconde chance doit pouvoir le relever.
	if est_mort():
		return
	pv = minf(pv_max, pv + maxf(0.0, montant))

func est_mort() -> bool:
	return pv <= 0.0
