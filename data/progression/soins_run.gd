class_name SoinsRun
extends RefCounted

const PROBABILITES_QUOTAS := [0.15, 0.80, 0.05]
const SOIN_PART_PV_MAX := 0.08
const GOUTTES_PAR_COEUR_INUTILISE := 1
const RAYON_RAMASSAGE := 70.0
const MARGE_DEPOT := 20.0
const ECART_DEPOTS := 46.0
const MINE_INTERVALLE_QUOTA := 30.0
const MINE_MORTS_CANDIDATES := 6

static func quota_pour_tirage(tirage: float) -> int:
	var seuil := 1.0
	for quota in range(PROBABILITES_QUOTAS.size() - 1, -1, -1):
		seuil -= float(PROBABILITES_QUOTAS[quota])
		if tirage >= seuil: return quota
	return 0

static func esperance_par_rencontre() -> float:
	var moyenne := 0.0
	for quota in PROBABILITES_QUOTAS.size():
		moyenne += float(quota) * float(PROBABILITES_QUOTAS[quota])
	return moyenne

static func indices_de_morts(combattants: int, quota: int, alea: RandomNumberGenerator) -> Array[int]:
	var indices: Array[int] = []
	if combattants <= 0: return indices
	var candidats: Array[int] = []
	for numero in range(1, combattants + 1): candidats.append(numero)
	for _coeur in clampi(quota, 0, PROBABILITES_QUOTAS.size() - 1):
		# Une rencontre composee d'un seul boss conserve aussi le quota de deux.
		if candidats.is_empty():
			indices.append(1)
		else:
			var index := alea.randi_range(0, candidats.size() - 1)
			indices.append(candidats[index])
			candidats.remove_at(index)
	indices.sort()
	return indices

static func compter_combattants(vagues: Array) -> int:
	var nombre := 0
	for vague: Array in vagues: nombre += vague.size()
	return nombre

static func intervalle_mine(temps: float, duree: float) -> int:
	# Attendre le boss apres le chronometre ne cree aucun nouveau budget de soin.
	var dernier := maxi(0, ceili(duree / MINE_INTERVALLE_QUOTA) - 1)
	return clampi(floori(temps / MINE_INTERVALLE_QUOTA), 0, dernier)

static func soin_base(pv_max: float) -> float:
	return maxf(0.0, pv_max) * SOIN_PART_PV_MAX
